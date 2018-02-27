CREATE OR REPLACE PACKAGE BODY json_store IS

    /* 
        Copyright 2017 Sergejs Vinniks

        Licensed under the Apache License, Version 2.0 (the "License");
        you may not use this file except in compliance with the License.
        You may obtain a copy of the License at
     
          http://www.apache.org/licenses/LICENSE-2.0

        Unless required by applicable law or agreed to in writing, software
        distributed under the License is distributed on an "AS IS" BASIS,
        WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
        See the License for the specific language governing permissions and
        limitations under the License.
    */

    -- TODO: variables in set_xxx, get_xxx etc

    TYPE t_json_values IS 
        TABLE OF json_values%ROWTYPE;

    TYPE t_integer_indexed_numbers IS 
        TABLE OF NUMBER 
        INDEX BY PLS_INTEGER;
        
    TYPE t_varchar_indexed_varchars IS 
        TABLE OF VARCHAR2(32000) 
        INDEX BY VARCHAR2(32000);

    v_property_request_sqls t_varchar_indexed_varchars;
    v_value_request_sqls t_varchar_indexed_varchars;
    
    TYPE t_query_element_cache IS 
        TABLE OF t_query_elements 
        INDEX BY VARCHAR2(32000); 
        
    v_query_element_cache t_query_element_cache;
        
    TYPE t_query_statement_cache IS
        TABLE OF t_query_statement
        INDEX BY VARCHAR2(32000);
        
    v_query_statement_cache t_query_statement_cache;
        
    PROCEDURE register_messages IS
    BEGIN
        default_message_resolver.register_message('JDOC-00001', 'Unexpected character ":1"!');
        default_message_resolver.register_message('JDOC-00002', 'Unexpected end of the input!');
        default_message_resolver.register_message('JDOC-00003', 'Root can''t be modified!');
        default_message_resolver.register_message('JDOC-00004', 'Multiple values found at the path :1!');
        default_message_resolver.register_message('JDOC-00005', 'Empty path specified!');
        default_message_resolver.register_message('JDOC-00006', 'Root requested as a property!');
        default_message_resolver.register_message('JDOC-00007', 'No container for property at path :1 could be found!');
        default_message_resolver.register_message('JDOC-00008', 'Scalar values and null can''t have properties!');
        default_message_resolver.register_message('JDOC-00009', 'Value :1 does not exist!');
        default_message_resolver.register_message('JDOC-00010', 'Type conversion error!');
        default_message_resolver.register_message('JDOC-00011', 'Property :1 type mismatch!');
        default_message_resolver.register_message('JDOC-00012', ':1 is not an array!');
        default_message_resolver.register_message('JDOC-00013', 'Invalid array element index :1!');
        default_message_resolver.register_message('JDOC-00014', 'Requested target is not an array!');
        default_message_resolver.register_message('JDOC-00015', 'Unexpected :1 in a non-branching query!');
        default_message_resolver.register_message('JDOC-00016', 'Duplicate property/alias :1!');
        default_message_resolver.register_message('JDOC-00017', 'Alias too long!');
        default_message_resolver.register_message('JDOC-00018', 'Property name :1 is too long to be a column name!');
        default_message_resolver.register_message('JDOC-00019', 'Alias not specified for a leaf wildcard property!');
        default_message_resolver.register_message('JDOC-00020', 'Variable name is not a valid number!');
        default_message_resolver.register_message('JDOC-00021', 'Only variables with names 1 .. :1 are supported!');
        default_message_resolver.register_message('JDOC-00022', 'Root can''t be optional!');
        default_message_resolver.register_message('JDOC-00023', 'Column alias for a wildcard not specified!');
        default_message_resolver.register_message('JDOC-00024', 'Value :1 is locked!');
        default_message_resolver.register_message('JDOC-00025', 'Value :1 has locked children!');
    END;
    
    FUNCTION get_length (
        p_array_id IN NUMBER
    )
    RETURN NUMBER;

    FUNCTION parse_path (
        p_path IN VARCHAR2
    )
    RETURN t_path_elements IS

        v_state VARCHAR2(30);
        v_char CHAR;
        v_value VARCHAR2(4000);

        p_path_elements t_path_elements;

        PROCEDURE add_element
            (p_type IN CHAR
            ,p_value IN VARCHAR2 := NULL) IS
        BEGIN
            p_path_elements.EXTEND(1);
            p_path_elements(p_path_elements.COUNT).type := p_type;
            p_path_elements(p_path_elements.COUNT).value := p_value;
        END;

        FUNCTION space
        RETURN BOOLEAN IS
        BEGIN

            RETURN v_char IN (' ', CHR(10), CHR(13), CHR(9));

        END;

        PROCEDURE lfElement IS
        BEGIN

            IF INSTR('qwertyuioplkjhgfdsazxcvbnm$_', LOWER(v_char)) > 0 THEN

                v_value := v_char;
                v_state := 'rName';

            ELSIF v_char = '#' THEN

                v_value := NULL;
                v_state := 'lfId';

            ELSIF v_char = '"' THEN

                v_value := NULL;
                v_state := 'rQuotedName';

            ELSIF NOT space THEN

                -- Unexpected character ":1"!
                error$.raise('JDOC-00001', v_char);

            END IF;

        END;

        PROCEDURE lfRoot IS
        BEGIN

            IF v_char = '$' THEN

                add_element('R');
                v_state := 'lfDot';

            ELSIF v_char = '[' THEN

                v_state := 'lfArrayElement';

            ELSE

                lfElement;

            END IF;

        END;

        PROCEDURE rName IS
        BEGIN

            IF INSTR('qwertyuioplkjhgfdsazxcvbnm1234567890_$', LOWER(v_char)) > 0 THEN

                v_value := v_value || v_char;

            ELSIF v_char = '.' THEN

                add_element('N', v_value);
                v_state := 'lfElement';

            ELSIF v_char = '[' THEN

                add_element('N', v_value);
                v_state := 'lfArrayElement';

            ELSIF space THEN

                add_element('N', v_value);
                v_state := 'lfDot';

            ELSE

                -- Unexpected character ":1"!
                error$.raise('JDOC-00001', v_char);

            END IF;

        END;

        PROCEDURE lfId IS
        BEGIN

            IF INSTR('1234567890', v_char) > 0 THEN

                v_value := v_char;
                v_state := 'rId';

            ELSE

                -- Unexpected character ":1"!
                error$.raise('JDOC-00001', v_char);

            END IF;

        END;

        PROCEDURE rId IS
        BEGIN

            IF INSTR('1234567890', v_char) > 0 THEN

                v_value := v_value || v_char;

            ELSIF v_char = '.' THEN

                add_element('I', v_value);
                v_state := 'lfElement';

            ELSIF v_char = '[' THEN

                add_element('I', v_value);
                v_state := 'lfArrayElement';

            ELSIF space THEN

                add_element('I', v_value);
                v_state := 'lfDot';

            ELSE

                -- Unexpected character ":1"!
                error$.raise('JDOC-00001', v_char);

            END IF;

        END;

        PROCEDURE lfDot IS
        BEGIN

            IF v_char = '.' THEN

                v_state := 'lfElement';

            ELSIF v_char = '[' THEN

                v_state := 'lfArrayElement';

            ELSIF NOT space THEN

                -- Unexpected character ":1"!
                error$.raise('JDOC-00001', v_char);

            END IF;

        END;

        PROCEDURE rQuotedName IS
        BEGIN

            IF v_char = '"' THEN

                add_element('N', v_value);
                v_state := 'lfDot';

            ELSIF v_char = '\' THEN

                v_state := 'rEscaped';

            ELSE

                v_value := v_value || v_char;

            END IF;

        END;

        PROCEDURE rEscaped IS
        BEGIN

            v_value := v_value || v_char;
            v_state := 'rQuotedName';

        END;

        PROCEDURE lfArrayElement IS
        BEGIN

            IF INSTR('1234567890', v_char) > 0 THEN

                v_value := v_char;
                v_state := 'rArrayElement';

            ELSIF v_char = '"' THEN

                v_value := NULL;
                v_state := 'rQuotedArrayElement';

            ELSIF NOT space THEN

                -- Unexpected character ":1"!
                error$.raise('JDOC-00001', v_char);

            END IF;

        END;

        PROCEDURE rArrayElement IS
        BEGIN

            IF INSTR('1234567890', v_char) > 0 THEN

                v_value := v_value || v_char;

            ELSIF v_char = ']' THEN

                add_element('N', v_value);
                v_state := 'lfDot';

            ELSIF space THEN

                add_element('N', v_value);
                v_state := 'lfClosingBracket';

            ELSE

                -- Unexpected character ":1"!
                error$.raise('JDOC-00001', v_char);

            END IF;

        END;

        PROCEDURE rQuotedArrayElement IS
        BEGIN

            IF v_char = '"' THEN

                add_element('N', v_value);
                v_state := 'lfClosingBracket';

            ELSIF v_char = '\' THEN

                v_state := 'rEscapedA';

            ELSE

                v_value := v_value || v_char;

            END IF;

        END;

        PROCEDURE rEscapedA IS
        BEGIN

            v_value := v_value || v_char;
            v_state := 'rQuotedArrayElement';

        END;

        PROCEDURE lfClosingBracket IS
        BEGIN

            IF v_char = ']' THEN

                v_state := 'lfDot';

            ELSIF NOT space THEN

                -- Unexpected character ":1"!
                error$.raise('JDOC-00001', v_char);

            END IF;

        END;

    BEGIN

        p_path_elements := t_path_elements();
        v_state := 'lfRoot';

        FOR v_i IN 1..NVL(LENGTH(p_path), 0) LOOP

            v_char := SUBSTR(p_path, v_i, 1);

            CASE v_state
                WHEN 'lfRoot' THEN lfRoot;
                WHEN 'rName' THEN rName;
                WHEN 'lfId' THEN lfId;
                WHEN 'rId' THEN rId;
                WHEN 'lfDot' THEN lfDot;
                WHEN 'lfElement' THEN lfElement;
                WHEN 'rQuotedName' THEN rQuotedName;
                WHEN 'rEscaped' THEN rEscaped;
                WHEN 'lfArrayElement' THEN lfArrayElement;
                WHEN 'rArrayElement' THEN rArrayElement;
                WHEN 'rQuotedArrayElement' THEN rQuotedArrayElement;
                WHEN 'lfClosingBracket' THEN lfClosingBracket;
                WHEN 'rEscapedA' THEN rEscapedA;
            END CASE;

        END LOOP;

        IF v_state = 'rName' THEN

            add_element('N', v_value);

        ELSIF v_state = 'rId' THEN

            add_element('I', v_value);

        ELSIF v_state NOT IN ('lfDot', 'lfRoot') THEN

            -- Unexpected end of the input!
            error$.raise('JDOC-00002');

        END IF;

        RETURN p_path_elements;

    END;
    
    FUNCTION parse_query (
        p_query IN VARCHAR2,
        p_optional_allowed IN BOOLEAN := TRUE,
        p_aliases_allowed IN BOOLEAN := TRUE
    )
    RETURN t_query_elements IS
    
        v_query_elements t_query_elements;
        
        v_char CHAR;
        v_state VARCHAR2(30);
        
        TYPE t_stack_node IS RECORD (
            element_i PLS_INTEGER
           ,last_child_i PLS_INTEGER 
           ,branching BOOLEAN
        );
        
        TYPE t_stack IS TABLE OF t_stack_node;
        
        v_stack t_stack;
        
        v_value VARCHAR2(4000);
        
        TYPE t_aliases IS TABLE OF BOOLEAN INDEX BY VARCHAR2(30);
        
        v_aliases t_aliases;
        
        PROCEDURE init_stack IS
        BEGIN
        
            v_stack := t_stack();
            
            v_stack.EXTEND(1);
            v_stack(1).branching := FALSE;
            
        END;
        
        PROCEDURE push
            (p_type IN CHAR
            ,p_value IN VARCHAR2 := NULL) IS
            
            v_element_i PLS_INTEGER;
            
        BEGIN
        
            v_query_elements.EXTEND(1);
            v_element_i := v_query_elements.COUNT;
            
            v_query_elements(v_element_i).type := p_type;
            v_query_elements(v_element_i).value := p_value;
            v_query_elements(v_element_i).optional := FALSE;
        
            IF v_stack(v_stack.COUNT).element_i IS NOT NULL
               AND v_query_elements(v_stack(v_stack.COUNT).element_i).first_child_i IS NULL THEN
               
                v_query_elements(v_stack(v_stack.COUNT).element_i).first_child_i := v_element_i;
               
            END IF;
        
            IF v_stack(v_stack.COUNT).last_child_i IS NOT NULL THEN
            
                v_query_elements(v_stack(v_stack.COUNT).last_child_i).next_sibling_i := v_element_i;
                
            END IF;
            
            v_stack(v_stack.COUNT).last_child_i := v_element_i;
        
            v_stack.EXTEND(1);
            v_stack(v_stack.COUNT).element_i := v_element_i;
            v_stack(v_stack.COUNT).branching := FALSE;
            
        END;
        
        PROCEDURE push_name (
            p_value IN VARCHAR2,
            p_simple IN BOOLEAN := FALSE
        ) IS
        BEGIN
        
            IF p_simple AND p_value = '$' THEN
            
                IF v_stack.COUNT > 1 THEN
                    -- 'Root requested as a property!'
                    error$.raise('JDOC-00006');
                END IF;
                
                push('R');
            
            ELSE
            
                push('N', p_value);
            
            END IF;
        
        END;
        
        PROCEDURE push_variable
            (p_value IN VARCHAR2) IS
            
            v_variable NUMBER;
            
        BEGIN
        
            BEGIN
                v_variable := TO_NUMBER(p_value);
            EXCEPTION
                WHEN OTHERS THEN
                    -- Variable name is not a valid number!
                    error$.raise('JDOC-00020');
            END;

            IF v_variable > 20 THEN
                -- Only variables with names 1 .. :1 are supported!
                error$.raise('JDOC-00021', 20);
            END IF;
            
            push('V', p_value);
        
        END;
        
        PROCEDURE pop_sibling (
            p_character IN CHAR := ','
        ) IS
        BEGIN
        
            LOOP
            
                IF v_stack.COUNT = 0 THEN
                    -- 'Unexpected :1 in a non-branching query!'
                    error$.raise('JDOC-00015', p_character);
                END IF;
                
                EXIT WHEN v_stack(v_stack.COUNT).branching;
                
                v_stack.TRIM(1);
            
            END LOOP;
        
        END;
        
        PROCEDURE pop_branch IS
        BEGIN
        
            pop_sibling(')');
            v_stack.TRIM(1);
        
        END;
        
        PROCEDURE set_alias
            (p_alias IN VARCHAR2) IS
        BEGIN
        
            v_query_elements(v_stack(v_stack.COUNT).element_i).alias := p_alias;
            v_aliases(p_alias) := TRUE;
        
        END;
        
        PROCEDURE set_optional IS
        BEGIN
        
            
            IF v_query_elements(v_stack(v_stack.COUNT).element_i).TYPE = 'R' THEN
                -- Root can''t be optional!
                error$.raise('JDOC-00022');
            END IF;
        
            v_query_elements(v_stack(v_stack.COUNT).element_i).optional := TRUE;
        
        END;
        
        FUNCTION optional 
        RETURN BOOLEAN IS
        BEGIN
        
            RETURN v_query_elements(v_stack(v_stack.COUNT).element_i).optional;
        
        END;
        
        PROCEDURE branch IS
        BEGIN
            v_stack(v_stack.COUNT).branching := TRUE;
        END;
        
        FUNCTION branching
        RETURN BOOLEAN IS
        BEGIN
        
            FOR v_i IN 1..v_stack.COUNT LOOP
                IF v_stack(v_i).branching THEN
                    RETURN TRUE;
                END IF;
            END LOOP;
        
            RETURN FALSE;
            
        END;
            
        FUNCTION space 
        RETURN BOOLEAN IS
        BEGIN
            RETURN v_char IN (' ', CHR(9), CHR(10), CHR(13));
        END;
        
        PROCEDURE lf_element IS
        BEGIN
        
            IF INSTR('qwertyuioplkjhgfdsazxcvbnm$_', LOWER(v_char)) > 0 THEN
            
                v_value := v_char;
                v_state := 'r_name';
                
            ELSIF v_char = '#' THEN
            
                v_value := NULL;
                v_state := 'lf_id';  
                
            ELSIF v_char = '*' THEN
            
                push('W');
                v_state := 'lf_separator';
                
            ELSIF v_char = ':' THEN
            
                v_value := NULL;
                v_state := 'lf_variable';
                            
            ELSIF NOT space THEN
            
                -- Unexpected character ":1"!
                error$.raise('JDOC-00001', v_char);
                
            END IF;
        
        END;
        
        PROCEDURE lf_root IS
        BEGIN
        
            IF v_char = '(' THEN
            
                branch;
                v_state := 'lf_element';
                
            ELSIF v_char = '[' THEN
            
                v_state := 'lf_array_element';
                
            ELSE
            
                lf_element;
                
            END IF;
        
        END;
        
        PROCEDURE lf_child IS
        BEGIN
        
            IF v_char = '.' THEN
            
                v_state := 'lf_element';
                
            ELSIF v_char = '[' THEN
            
                v_state := 'lf_array_element';
                
            ELSIF NOT space THEN
            
                -- Unexpected character ":1"!
                error$.raise('JDOC-00001', v_char);
            
            END IF;
        
        END;
        
        PROCEDURE r_name IS
        BEGIN
        
            IF INSTR('qwertyuioplkjhgfdsazxcvbnm1234567890$_', LOWER(v_char)) > 0 THEN
            
                v_value := v_value || v_char;
                
            ELSIF v_char = '.' THEN
            
                push_name(v_value, TRUE);
                v_state := 'lf_element';
                
            ELSIF v_char = ',' THEN
            
                push_name(v_value, TRUE);
                pop_sibling;
                
                IF (v_stack.COUNT = 1) THEN
                    v_state := 'lf_element';
                ELSE
                    v_state := 'lf_child';
                END IF;
                
            ELSIF v_char = ')' THEN
            
                push_name(v_value, TRUE);
                pop_branch;
                v_state := 'lf_comma';
                
            ELSIF v_char = '[' THEN
               
                push_name(v_value, TRUE);
                v_state := 'lf_array_element';    
                
            ELSIF v_char = '(' THEN
            
                push_name(v_value, TRUE);
                branch;
                v_state := 'lf_child';
                
            ELSIF space THEN
            
                push_name(v_value, TRUE);
                v_state := 'lf_separator';
                
            ELSIF v_char = '?' AND p_optional_allowed THEN
            
                push_name(v_value, TRUE);
                set_optional;
                v_state := 'lf_separator';
                               
            ELSE
            
                -- Unexpected character ":1"!
                error$.raise('JDOC-00001', v_char);
                
            END IF;
        
        END;
        
        PROCEDURE lf_comma IS
        BEGIN
        
            IF v_char = ',' THEN
            
                pop_sibling;
                
                IF (v_stack.COUNT = 1) THEN
                    v_state := 'lf_element';
                ELSE
                    v_state := 'lf_child';
                END IF;
                
            ELSIF v_char = ')' THEN
            
                pop_branch;
                
            ELSIF NOT space THEN
            
                -- Unexpected character ":1"!
                error$.raise('JDOC-00001', v_char);
                
            END IF;
            
        END;
        
        PROCEDURE lf_separator IS
        BEGIN
        
            IF v_char = ')' THEN
              
                pop_branch;
                v_state := 'lf_comma';
                
            ELSIF v_char = ',' THEN
            
                pop_sibling;
                
                IF (v_stack.COUNT = 1) THEN
                    v_state := 'lf_element';
                ELSE
                    v_state := 'lf_child';
                END IF;
                
                
            ELSIF v_char = '(' THEN
            
                branch;
                v_state := 'lf_child';  
                
            ELSIF LOWER(v_char) = 'a' AND p_aliases_allowed THEN
            
                v_state := 'lf_as_s';
                
            ELSIF v_char = '?' AND p_optional_allowed THEN
            
                IF optional THEN
                    -- Unexpected character ":1"!
                    error$.raise('JDOC-00001', v_char);
                END IF; 
                
                set_optional;
                
            ELSE
            
                lf_child;
                
            END IF;
        
        END;
        
        PROCEDURE lf_id IS
        BEGIN
        
            IF INSTR('1234567890', v_char) > 0 THEN
            
                v_value := v_char;
                v_state := 'r_id';
                
            ELSIF NOT space THEN
            
                -- Unexpected character ":1"!
                error$.raise('JDOC-00001', v_char);
                
            END IF;
        
        END;
        
        PROCEDURE r_id IS
        BEGIN
        
            IF INSTR('1234567890', v_char) > 0 THEN
            
                v_value := v_value || v_char;
                
            ELSIF v_char = '.' THEN
            
                push('I', v_value);
                v_state := 'lf_element';
                
            ELSIF v_char = ',' THEN
            
                push('I', v_value);
                pop_sibling;
                
                IF (v_stack.COUNT = 1) THEN
                    v_state := 'lf_element';
                ELSE
                    v_state := 'lf_child';
                END IF;
                
            ELSIF v_char = ')' THEN
            
                push('I', v_value);
                pop_branch;
                v_state := 'lf_comma';
                
            ELSIF v_char = '[' THEN
            
                push('I', v_value);
                v_state := 'lf_array_element'; 
                
            ELSIF v_char = '(' THEN
            
                push('I', v_value);
                branch;
                v_state := 'lf_child'; 
                
            ELSIF space THEN
            
                push('I', v_value);
                v_state := 'lf_separator';
                
            ELSIF v_char = '?' AND p_optional_allowed THEN
            
                push('I', v_value);
                set_optional;
                v_state := 'lf_separator';
                
            ELSE
            
                -- Unexpected character ":1"!
                error$.raise('JDOC-00001', v_char);
                
            END IF;
                    
        END;
        
        PROCEDURE lf_array_element IS
        BEGIN
        
            IF INSTR('1234567890', v_char) > 0 THEN
            
                v_value := v_char;
                v_state := 'r_array_element';
                
            ELSIF v_char = '"' THEN
            
                v_value := NULL;
                v_state := 'r_quoted_name';
                
            ELSIF v_char = '*' THEN
            
                push('W');
                v_state := 'lf_array_element_end'; 
            
            ELSIF v_char = ':' THEN
            
                v_value := NULL;
                v_state := 'lf_array_variable';
                
            ELSIF NOT space THEN
            
                -- Unexpected character ":1"!
                error$.raise('JDOC-00001', v_char);
            
            END IF;
        
        END;
        
        PROCEDURE r_array_element IS
        BEGIN
        
            IF INSTR('1234567890', v_char) > 0 THEN
            
                v_value := v_value || v_char;
                
            ELSIF v_char = ']' THEN
            
                push_name(v_value);
                v_state := 'lf_separator';
            
            ELSIF space THEN
            
                push_name(v_value);
                v_state := 'lf_array_element_end';
                
            ELSE
            
                -- Unexpected character ":1"!
                error$.raise('JDOC-00001', v_char);
            
            END IF;    
        
        END;
        
        PROCEDURE lf_array_element_end IS
        BEGIN
        
            IF v_char = ']' THEN
            
                v_state := 'lf_separator';
                
            ELSIF NOT space THEN
           
                -- Unexpected character ":1"!
                error$.raise('JDOC-00001', v_char);
            
            END IF;
        
        END;
        
        PROCEDURE r_quoted_name IS
        BEGIN
        
            IF v_char = '"' THEN
            
                push_name(v_value);
                v_state := 'lf_array_element_end';
                
            ELSIF v_char = '\' THEN
            
                v_state := 'r_escaped';
                
            ELSE
            
                v_value := v_value || v_char;
            
            END IF;
        
        END;
        
        PROCEDURE r_escaped IS
        BEGIN
        
            v_value := v_value || v_char;
            v_state := 'r_quoted_name';
        
        END;
        
        PROCEDURE lf_as_s IS
        BEGIN
        
            IF LOWER(v_char) = 's' THEN
            
                v_state := 'lf_space_after_as';
                
            ELSE
            
                -- Unexpected character ":1"!
                error$.raise('JDOC-00001', v_char);
            
            END IF;
            
        
        END;
        
        PROCEDURE lf_space_after_as IS
        BEGIN
        
            IF space THEN
                
                v_state := 'lf_alias';
                
            ELSE
            
                -- Unexpected character ":1"!
                error$.raise('JDOC-00001', v_char);
            
            END IF;
        
        END;
        
        PROCEDURE lf_alias IS
        BEGIN
        
            IF INSTR('qwertyuioplkjhgfdsazxcvbnm', LOWER(v_char)) > 0 THEN
            
                v_state := 'r_alias';
                v_value := v_char;
                
            ELSIF v_char = '"' THEN
            
                v_value := NULL;
                v_state := 'r_quoted_alias';    
                
            ELSIF NOT space THEN
                
                -- Unexpected character ":1"!
                error$.raise('JDOC-00001', v_char);
            
            END IF;
        
        END;
        
        PROCEDURE r_alias IS
        BEGIN
        
            IF INSTR('qwertyuioplkjhgfdsazxcvbnm1234567890_$', LOWER(v_char)) > 0 THEN
            
                IF LENGTH(v_value) = 30 THEN
            
                    -- Alias too long!
                    error$.raise('JDOC-00017');
                    
                END IF;
            
                v_value := v_value || v_char;

            ELSIF v_char = ',' THEN
            
                set_alias(UPPER(v_value));
                pop_sibling;
                
                IF (v_stack.COUNT = 1) THEN
                    v_state := 'lf_element';
                ELSE
                    v_state := 'lf_child';
                END IF;
                
            ELSIF v_char = ')' THEN
            
                set_alias(UPPER(v_value));
                pop_branch;
                v_state := 'lf_comma';
                
            ELSIF space THEN
            
                set_alias(UPPER(v_value));
                v_state := 'lf_comma';
                
            ELSE
            
                -- Unexpected character ":1"!
                error$.raise('JDOC-00001', v_char);
                
            END IF;
                
        
        END;
        
        PROCEDURE r_quoted_alias IS
        BEGIN
        
            IF v_char = '"' THEN
            
                set_alias(v_value);
                v_state := 'lf_comma';
                
            ELSIF LENGTH(v_value) = 30 THEN
            
                -- Alias too long!
                error$.raise('JDOC-00017');
                
            ELSE
            
                v_value := v_value || v_char;
            
            END IF;
        
        END;
        
        PROCEDURE lf_variable IS
        BEGIN
        
            IF INSTR('123456789', v_char) > 0 THEN
            
                v_value := v_char;
                v_state := 'r_variable';
                
            ELSE
            
                -- Unexpected character ":1"!
                error$.raise('JDOC-00001', v_char);
            
            END IF;
        
        END;
        
        PROCEDURE r_variable IS
        BEGIN
        
            IF INSTR('1234567890', v_char) > 0 THEN
            
                v_value := v_value || v_char;
                
            ELSIF v_char = '.' THEN
            
                push_variable(v_value);
                v_state := 'lf_element';
                
            ELSIF v_char = ',' THEN
            
                push_variable(v_value);
                pop_sibling;
                
                IF (v_stack.COUNT = 1) THEN
                    v_state := 'lf_element';
                ELSE
                    v_state := 'lf_child';
                END IF;
                
            ELSIF v_char = ')' THEN
            
                push_variable(v_value);
                pop_branch;
                v_state := 'lf_comma';
                
            ELSIF v_char = '[' THEN
            
                push_variable(v_value);
                v_state := 'lf_array_element'; 
                
            ELSIF v_char = '(' THEN
            
                push_variable(v_value);
                branch;
                v_state := 'lf_child'; 
                
            ELSIF space THEN
            
                push_variable(v_value);
                v_state := 'lf_separator';
                
            ELSIF v_char = '?' AND p_optional_allowed THEN
            
                push_variable(v_value);
                set_optional;
                v_state := 'lf_separator';
                
            ELSE
            
                -- Unexpected character ":1"!
                error$.raise('JDOC-00001', v_char);
                
            END IF;
        
        END;
        
        PROCEDURE lf_array_variable IS
        BEGIN
        
            IF INSTR('123456789', v_char) > 0 THEN
            
                v_value := v_char;
                v_state := 'r_array_variable';
                
            ELSE
            
                -- Unexpected character ":1"!
                error$.raise('JDOC-00001', v_char);
            
            END IF;
        
        END;
        
        PROCEDURE r_array_variable IS
        BEGIN
        
            IF INSTR('1234567890', v_char) > 0 THEN
            
                v_value := v_value || v_char;
                
            ELSIF v_char = ']' THEN
            
                push_variable(v_value);
                v_state := 'lf_separator';
            
            ELSIF space THEN
            
                push_variable(v_value);
                v_state := 'lf_array_element_end';
                
            ELSE
            
                -- Unexpected character ":1"!
                error$.raise('JDOC-00001', v_char);
            
            END IF;    
        
        END;
        
    BEGIN
    
        IF v_query_element_cache.EXISTS(p_query) THEN
            RETURN v_query_element_cache(p_query);
        END IF;
    
        v_query_elements := t_query_elements();
        init_stack;
        
        v_state := 'lf_root';
        
        FOR v_i IN 1..NVL(LENGTH(p_query), 0) LOOP
        
            v_char := SUBSTR(p_query, v_i, 1);
            
            CASE v_state
                WHEN 'lf_root' THEN lf_root;
                WHEN 'lf_child' THEN lf_child;
                WHEN 'lf_element' THEN lf_element;
                WHEN 'r_name' THEN r_name;
                WHEN 'lf_comma' THEN lf_comma;
                WHEN 'lf_separator' THEN lf_separator;
                WHEN 'lf_id' THEN lf_id;
                WHEN 'r_id' THEN r_id;
                WHEN 'lf_array_element' THEN lf_array_element;
                WHEN 'r_array_element' THEN r_array_element;
                WHEN 'lf_array_element_end' THEN lf_array_element_end;
                WHEN 'r_quoted_name' THEN r_quoted_name;
                WHEN 'r_escaped' THEN r_escaped;
                WHEN 'lf_as_s' THEN lf_as_s;
                WHEN 'lf_space_after_as' THEN lf_space_after_as;
                WHEN 'lf_alias' THEN lf_alias;
                WHEN 'r_alias' THEN r_alias;
                WHEN 'r_quoted_alias' THEN r_quoted_alias;
                WHEN 'lf_variable' THEN lf_variable;
                WHEN 'r_variable' THEN r_variable;
                WHEN 'lf_array_variable' THEN lf_array_variable;
                WHEN 'r_array_variable' THEN r_array_variable;
            END CASE;
        
        END LOOP;
        
        IF v_state = 'r_name' THEN
            push_name(v_value, TRUE);
        ELSIF v_state = 'r_id' THEN
            push('I', v_value);
        ELSIF v_state = 'r_alias' THEN
            set_alias(UPPER(v_value));
        ELSIF v_state = 'r_variable' THEN
            push_variable(v_value);
        ELSIF v_state NOT IN ('lf_separator', 'lf_comma') THEN 
            -- Unexpected end of the input!
            error$.raise('JDOC-00002');
        END IF;
        
        IF branching THEN
            -- Unexpected end of the input!
            error$.raise('JDOC-00002');
        END IF;
    
        FOR v_i IN 1..v_query_elements.COUNT LOOP
            IF v_query_elements(v_i).type = 'R' AND v_query_elements(v_i).first_child_i IS NULL THEN
                -- 'Root requested as a property!'
                error$.raise('JDOC-00006');
            END IF; 
        END LOOP;
        
        v_query_element_cache(p_query) := v_query_elements;
        
        RETURN v_query_elements;
    
    END;
    
    FUNCTION get_query_signature (
        p_query_elements IN t_query_elements
    )
    RETURN VARCHAR2 IS
    
        v_signature VARCHAR2(4000);
        
        PROCEDURE visit_element (
            p_i IN PLS_INTEGER
        ) IS
        BEGIN
        
            v_signature := v_signature || p_query_elements(p_i).type || CASE WHEN p_query_elements(p_i).optional THEN '?' END;
        
            IF p_query_elements(p_i).first_child_i IS NOT NULL THEN
                v_signature := v_signature || '(';
                visit_element(p_query_elements(p_i).first_child_i);
                v_signature := v_signature || ')';
            END IF;
            
            IF p_query_elements(p_i).next_sibling_i IS NOT NULL THEN
                visit_element(p_query_elements(p_i).next_sibling_i);
            END IF;
        
        END;
    
    BEGIN
    
        v_signature := '(';
        visit_element(1);
        v_signature := v_signature || ')';
        
        RETURN v_signature;
    
    END;
    
    FUNCTION get_query_column_names (
        p_query_elements IN t_query_elements
    )
    RETURN t_varchars IS
    
        TYPE t_unique_names IS 
            TABLE OF BOOLEAN 
            INDEX BY VARCHAR2(30);
            
        v_unique_column_names t_unique_names;
        v_column_names t_varchars;
        
        PROCEDURE add_column_name (
            p_name IN VARCHAR2
        ) IS
        BEGIN
            
            IF LENGTH(p_name) > 30 THEN
                -- Property name :1 is too long to be a column name!
                error$.raise('JDOC-00018', p_name);
            END IF;
            
            IF v_unique_column_names.EXISTS(p_name) THEN
                -- Duplicate property/alias :1!
                error$.raise('JDOC-00016');
            END IF;
            
            v_column_names.EXTEND(1);
            v_column_names(v_column_names.COUNT) := p_name;
            
            v_unique_column_names(p_name) := TRUE;
        
        END;
        
        PROCEDURE visit_element (
            p_i IN PLS_INTEGER
        ) IS
        BEGIN
        
            IF p_query_elements(p_i).first_child_i IS NOT NULL THEN
            
                visit_element(p_query_elements(p_i).first_child_i);
                
            ELSE
            
                IF p_query_elements(p_i).alias IS NOT NULL THEN
                
                    add_column_name(p_query_elements(p_i).alias);
                    
                ELSIF p_query_elements(p_i).type = 'I' THEN
                
                    add_column_name('#' || p_query_elements(p_i).value);
                    
                ELSIF p_query_elements(p_i).type = 'V' THEN
                
                    add_column_name(':' || p_query_elements(p_i).value);
    
                 
                ELSIF p_query_elements(p_i).type = 'W' THEN
                
                    -- Column alias for a wildcard not specified!
                    error$.raise('JDOC-00023');
                    
                ELSE
                
                    add_column_name(p_query_elements(p_i).value);
                    
                END IF; 
            
            END IF;
            
            IF p_query_elements(p_i).next_sibling_i IS NOT NULL THEN
                visit_element(p_query_elements(p_i).next_sibling_i);
            END IF;
        
        END;
    
    BEGIN
    
        v_column_names := t_varchars();
        
        visit_element(1);
        
        RETURN v_column_names;
    
    END;
    
    FUNCTION get_query_variable_names (
        p_query_elements IN t_query_elements
    )
    RETURN t_varchars IS
    
        TYPE t_unique_names IS 
            TABLE OF BOOLEAN 
            INDEX BY VARCHAR2(30);
            
        v_unique_variable_names t_unique_names;
        v_variable_name VARCHAR2(30);
        
        v_variable_names t_varchars;
        
        PROCEDURE visit_element (
            p_i IN PLS_INTEGER
        ) IS
        BEGIN
        
            IF p_query_elements(p_i).type = 'V' THEN
                v_unique_variable_names(p_query_elements(p_i).value) := TRUE;
            END IF;
        
            IF p_query_elements(p_i).first_child_i IS NOT NULL THEN
                visit_element(p_query_elements(p_i).first_child_i);
            END IF;
            
            IF p_query_elements(p_i).next_sibling_i IS NOT NULL THEN
                visit_element(p_query_elements(p_i).next_sibling_i);
            END IF;
        
        END;
        
    BEGIN
    
        visit_element(1);
    
        v_variable_names := t_varchars();
        v_variable_name := v_unique_variable_names.FIRST;
        
        WHILE v_variable_name IS NOT NULL LOOP
        
            v_variable_names.EXTEND(1);
            v_variable_names(v_variable_names.COUNT) := v_variable_name;
        
            v_variable_name := v_unique_variable_names.NEXT(v_variable_name);
        
        END LOOP;
        
        RETURN v_variable_names;
    
    END;    
    
    FUNCTION get_query_values (
        p_query_elements IN t_query_elements
    )
    RETURN t_varchars IS
    
        v_values t_varchars;
    
        PROCEDURE visit_element (
            p_i IN PLS_INTEGER
        ) IS
        BEGIN
        
            IF p_query_elements(p_i).type IN ('N', 'I') THEN
                v_values.EXTEND(1);
                v_values(v_values.COUNT) := p_query_elements(p_i).value;
            END IF;
        
            IF p_query_elements(p_i).first_child_i IS NOT NULL THEN
                visit_element(p_query_elements(p_i).first_child_i);
            END IF;
            
            IF p_query_elements(p_i).next_sibling_i IS NOT NULL THEN
                visit_element(p_query_elements(p_i).next_sibling_i);
            END IF;
        
        END;
    
    BEGIN
    
        v_values := t_varchars();
        
        visit_element(1);
        
        RETURN v_values;
    
    END;
    
    FUNCTION get_query_statement (
        p_query_elements IN t_query_elements,
        p_select IN PLS_INTEGER
    )
    RETURN t_query_statement IS
    
        v_signature VARCHAR2(32000);
    
        v_line VARCHAR2(32000);
        
        v_table_instance_counter PLS_INTEGER;
        v_variable_counter PLS_INTEGER;
        v_comma CHAR;
        v_and VARCHAR2(5);
        
        v_statement t_query_statement;
    
        PROCEDURE add_text (
            p_text IN VARCHAR2,
            p_parent_instance IN PLS_INTEGER := NULL
        ) IS
        BEGIN
            
            IF LENGTH(v_line) + LENGTH(p_text) > 32000 THEN
            
                IF v_statement.statement_clob IS NULL THEN
                    DBMS_LOB.CREATETEMPORARY(v_statement.statement_clob, TRUE);
                END IF;
            
                DBMS_LOB.APPEND(v_statement.statement_clob, v_line);
            
                v_line := NULL;
                
            END IF;
            
            v_line := v_line || p_text;
        
        END;
    
        PROCEDURE select_list_visit (
            p_i PLS_INTEGER
        ) IS
            
            v_table_instance PLS_INTEGER;
            
        BEGIN
        
            v_table_instance_counter := v_table_instance_counter + 1;
            v_table_instance := v_table_instance_counter;
                    
            IF p_query_elements(p_i).first_child_i IS NOT NULL THEN
                select_list_visit(p_query_elements(p_i).first_child_i);
            ELSE
            
                CASE p_select 
                    WHEN c_VALUE THEN
                        add_text(v_comma || 'j' || v_table_instance || '.value');
                    WHEN c_VALUE_RECORD THEN
                        add_text(v_comma || 'j' || v_table_instance || '.id,j' || v_table_instance || '.type,j' || v_table_instance || '.value');
                END CASE;
                
                v_comma := ',';
                
            END IF;
            
            IF p_query_elements(p_i).next_sibling_i IS NOT NULL THEN
                select_list_visit(p_query_elements(p_i).next_sibling_i);
            END IF;
        
        END;
        
        PROCEDURE from_list_visit (
            p_i PLS_INTEGER
        ) IS
            
            v_table_instance PLS_INTEGER;
            
        BEGIN
        
            v_table_instance_counter := v_table_instance_counter + 1;
            v_table_instance := v_table_instance_counter;
        
            IF p_query_elements(p_i).type = 'R' THEN
                add_text(v_comma || '(SELECT 0 AS id FROM dual) j' || v_table_instance);
            ELSE
                add_text(v_comma || 'json_values j' || v_table_instance);
            END IF;
            
            v_comma := ',';
        
            IF p_query_elements(p_i).first_child_i IS NOT NULL THEN
                from_list_visit(p_query_elements(p_i).first_child_i);
            END IF;
            
            IF p_query_elements(p_i).next_sibling_i IS NOT NULL THEN
                from_list_visit(p_query_elements(p_i).next_sibling_i);
            END IF;
        
        END;
        
        PROCEDURE where_list_visit (
            p_i PLS_INTEGER,
            p_parent_i IN PLS_INTEGER,
            p_parent_table_instance IN PLS_INTEGER
        ) IS
            
            v_table_instance PLS_INTEGER;
            
        BEGIN
        
            v_table_instance_counter := v_table_instance_counter + 1;
            v_table_instance := v_table_instance_counter;
            
            IF p_parent_table_instance IS NOT NULL THEN
            
                add_text(v_and || 'NVL(j' || v_table_instance || '.parent_id');
                
                IF p_query_elements(p_i).optional THEN
                    add_text('(+)');
                END IF;
                
                add_text(',0)=j' || p_parent_table_instance || '.id');
                
                v_and := ' AND ';
                
            END IF;
            
            IF p_query_elements(p_i).type = 'N' THEN
            
                add_text(v_and || 'j' || v_table_instance || '.name');
                
                IF p_query_elements(p_i).optional THEN
                    add_text('(+)');
                END IF;
                
                v_variable_counter := v_variable_counter + 1;
                add_text('=:v' || v_variable_counter);
                
                v_and := ' AND ';
                
            ELSIF p_query_elements(p_i).type = 'I' THEN
            
                add_text(v_and || 'j' || v_table_instance || '.id');
                
                IF p_query_elements(p_i).optional THEN
                    add_text('(+)');
                END IF;
                
                v_variable_counter := v_variable_counter + 1;
                add_text('=TO_NUMBER(:v' || v_variable_counter || ')');
                
                v_and := ' AND ';
                
            ELSIF p_query_elements(p_i).type = 'V' THEN
            
                add_text(v_and || 'j' || v_table_instance || '.name');
                
                IF p_query_elements(p_i).optional THEN
                    add_text('(+)');
                END IF;
                
                add_text('=:' || p_query_elements(p_i).value);
                
                v_and := ' AND ';
                
            END IF;
        
            IF p_query_elements(p_i).first_child_i IS NOT NULL THEN
                where_list_visit(p_query_elements(p_i).first_child_i, p_i, v_table_instance);
            END IF;
            
            IF p_query_elements(p_i).next_sibling_i IS NOT NULL THEN
                where_list_visit(p_query_elements(p_i).next_sibling_i, p_parent_i, p_parent_table_instance);
            END IF;
                
        END;
    
    BEGIN
    
        v_signature := p_select || get_query_signature(p_query_elements);
        
        IF v_query_statement_cache.EXISTS(v_signature) THEN
            dbms_output.put_line('cached ' || v_signature);
            RETURN v_query_statement_cache(v_signature);
        END IF;    
    
        v_table_instance_counter := 0;
        v_comma := NULL; 
        add_text('SELECT ');
        select_list_visit(1);
        
        v_table_instance_counter := 0;
        v_comma := NULL; 
        add_text(' FROM ');
        from_list_visit(1);
        
        v_table_instance_counter := 0;
        v_variable_counter := 0;
        v_and := NULL; 
        add_text(' WHERE ');
        where_list_visit(1, NULL, NULL);
        
        IF v_line IS NOT NULL AND v_statement.statement_clob IS NOT NULL THEN
            DBMS_LOB.APPEND(v_statement.statement_clob, v_line);
        END IF;
        
        IF v_statement.statement_clob IS NULL THEN
            v_statement.statement := v_line;
        END IF;
        
        dbms_output.put_line(v_line);
        
        v_query_statement_cache(v_signature) := v_statement;
        
        RETURN v_statement;
    
    END;
    
    PROCEDURE request_properties (
        p_path_elements IN t_path_elements,
        p_properties OUT SYS_REFCURSOR
    ) IS

        v_path_signature VARCHAR2(4000);

        v_start_level PLS_INTEGER;
        v_sql VARCHAR2(32000);

        v_path_values t_varchars;

        FUNCTION field (
            p_i IN PLS_INTEGER
        )
        RETURN VARCHAR2 IS
        BEGIN
            RETURN CASE p_path_elements(p_i).type
                       WHEN 'I' THEN 'id'
                       ELSE 'name'
                   END;
        END;

    BEGIN

        IF p_path_elements.COUNT = 0 THEN
            -- Empty path specified!
            error$.raise('JDOC-00005');
        ELSIF p_path_elements(p_path_elements.COUNT).type = 'R' THEN
            -- Root requested as a property!
            error$.raise('JDOC-00006');
        END IF;

        FOR v_i IN 1..p_path_elements.COUNT LOOP
            v_path_signature := v_path_signature || p_path_elements(v_i).type;
        END LOOP;

        IF v_property_request_sqls.EXISTS(v_path_signature) THEN

            v_sql := v_property_request_sqls(v_path_signature);

        ELSE

            v_sql := 'WITH path_values AS
    (SELECT column_value AS value, ROWNUM AS rn
     FROM TABLE(:path_values))
';

            IF p_path_elements.COUNT = 1 THEN

                v_sql := v_sql || 'SELECT parent.id, parent.type, property.id, property.type, property.name, property.locked
FROM json_values property
    ,json_values parent
WHERE property.' || field(1) || ' = :property_value
      AND parent.id(+) = property.parent_id';

            ELSIF p_path_elements.COUNT = 2 AND p_path_elements(1).type = 'R' THEN

                v_sql := v_sql || 'SELECT NULL, NULL, jsvl.id, jsvl.type, jsvl.name, jsvl.locked
FROM (SELECT jsvl.*, 0 AS nvl_parent_id
      FROM json_values jsvl
      WHERE ' || field(2) || ' = :property_value
            AND parent_id IS NULL) jsvl
    ,(SELECT 0 AS id
      FROM dual) root
WHERE jsvl.nvl_parent_id(+) = root.id';

            ELSE

                v_start_level := CASE p_path_elements(1).type WHEN 'R' THEN 2 ELSE 1 END;

                v_sql := v_sql || 'SELECT l' || (p_path_elements.COUNT - 1) || '.id, l' || (p_path_elements.COUNT - 1) || '.type, property.id, property.type, property.name, property.locked
FROM ';

                FOR v_i IN v_start_level..p_path_elements.COUNT - 1 LOOP
                    v_sql := v_sql || 'json_values l' || v_i || ', ';
                END LOOP;

                v_sql := v_sql || 'json_values property
WHERE 1=1';

                IF p_path_elements(1).type = 'R' THEN
                    v_sql := v_sql || '
      AND l2.parent_id IS NULL';
                END IF;

                FOR v_i IN v_start_level..p_path_elements.COUNT - 1 LOOP

                    v_sql := v_sql || '
      AND l' || v_i || '.' || field(v_i) || ' = (SELECT value FROM path_values WHERE rn = ' || v_i || ')';

                    IF v_i > v_start_level THEN
                        v_sql := v_sql || '
      AND l' || v_i || '.parent_id = l' || (v_i - 1) || '.id';
                    END IF;

                END LOOP;

                IF p_path_elements(p_path_elements.COUNT).type = 'I' THEN

                    v_sql := v_sql || '
      AND property.parent_id = l' || (p_path_elements.COUNT - 1) || '.id
      AND property.id = :property_value';

                ELSE

                    v_sql := v_sql || '
      AND property.parent_id(+) = l' || (p_path_elements.COUNT - 1) || '.id
      AND property.name(+) = :property_value';

                END IF;

            END IF;

            v_property_request_sqls(v_path_signature) := v_sql;

        END IF;

        v_path_values := t_varchars();
        v_path_values.EXTEND(p_path_elements.COUNT - 1);

        FOR v_i IN 1..p_path_elements.COUNT - 1 LOOP
            v_path_values(v_i) := p_path_elements(v_i).value;
        END LOOP;

        OPEN p_properties
        FOR v_sql
        USING  
            IN v_path_values, 
            IN p_path_elements(p_path_elements.COUNT).value;

    END;

    PROCEDURE request_properties (
        p_path IN VARCHAR2,
        p_properties OUT SYS_REFCURSOR
    ) IS
    BEGIN
        request_properties(parse_path(p_path), p_properties);
    END;

    FUNCTION request_properties (
        p_path IN VARCHAR2
    )
    RETURN t_properties PIPELINED IS

        c_properties SYS_REFCURSOR;
        v_properties t_properties;

        c_fetch_limit CONSTANT PLS_INTEGER := 100;

    BEGIN

        request_properties(p_path, c_properties);

        LOOP

            v_properties := t_properties();

            FETCH c_properties
            BULK COLLECT INTO v_properties
            LIMIT c_fetch_limit;

            FOR v_i IN 1..v_properties.COUNT LOOP
                PIPE ROW(v_properties(v_i));
            END LOOP;

            EXIT WHEN v_properties.COUNT < c_fetch_limit;

        END LOOP;

        CLOSE c_properties;

        RETURN;

    END;

    PROCEDURE create_json (
        p_parent_ids IN t_numbers,
        p_name IN VARCHAR2,
        p_content_parse_events IN json_parser.t_parse_events,
        p_event_i IN OUT NOCOPY PLS_INTEGER,
        p_created_ids IN OUT NOCOPY t_numbers,
        p_id IN NUMBER := NULL
    ) IS
    
        v_json_values t_json_values;

        v_event_i PLS_INTEGER;
        v_id NUMBER;

        v_id_map t_integer_indexed_numbers;

        FUNCTION next_id
        RETURN NUMBER IS
        BEGIN
            -- Local "artifitial" identifiers must be negative to not overlap with the existing ones!
            v_id := v_id - 1;
            RETURN v_id;
        END;

        PROCEDURE flush_values IS

            v_ids t_numbers;
            v_id_count NUMBER;

        BEGIN

            v_id_count := NVL(v_id_map.FIRST, 0) - v_id;

            SELECT jsvl_id.NEXTVAL
            BULK COLLECT INTO v_ids
            FROM dual
            CONNECT BY LEVEL <= v_id_count;

            FOR v_i IN 1..v_ids.COUNT LOOP
                v_id_map(NVL(v_id_map.FIRST, 0) - 1) := v_ids(v_i);
            END LOOP;

            FOR v_i IN 1..v_json_values.COUNT LOOP

                IF v_id_map.EXISTS(v_json_values(v_i).id) THEN
                    v_json_values(v_i).id := v_id_map(v_json_values(v_i).id);
                END IF;

                IF v_id_map.EXISTS(v_json_values(v_i).parent_id) THEN
                    v_json_values(v_i).parent_id := v_id_map(v_json_values(v_i).parent_id);
                END IF;

            END LOOP;

            FORALL v_i IN 1..v_json_values.COUNT
                INSERT INTO json_values
                VALUES v_json_values(v_i);

            v_json_values := t_json_values();

        END;

        PROCEDURE insert_value (
            p_value json_values%ROWTYPE
        ) IS

            c_flush_amount CONSTANT PLS_INTEGER := 200;

        BEGIN

            v_json_values.EXTEND(1);
            v_json_values(v_json_values.COUNT) := p_value;

            IF v_json_values.COUNT = c_flush_amount THEN
                flush_values;
            END IF;

        END;

        FUNCTION create_value (
            p_parent_id IN NUMBER,
            p_name IN VARCHAR2,
            p_id IN NUMBER := NULL
        )
        RETURN NUMBER IS

            v_value json_values%ROWTYPE;
            v_child_id NUMBER;

            v_name VARCHAR2(4000);
            v_i PLS_INTEGER;

        BEGIN

            v_value.id := CASE WHEN p_id IS NULL THEN next_id ELSE p_id END;
            v_value.parent_id := p_parent_id;
            v_value.name := p_name;

            IF p_content_parse_events(v_event_i).name = 'STRING' THEN

                v_value.type := 'S';
                v_value.value := p_content_parse_events(v_event_i).value;

                insert_value(v_value);

            ELSIF p_content_parse_events(v_event_i).name = 'NUMBER' THEN

                v_value.type := 'N';
                v_value.value := p_content_parse_events(v_event_i).value;

                insert_value(v_value);

            ELSIF p_content_parse_events(v_event_i).name = 'BOOLEAN' THEN

                v_value.type := 'B';
                v_value.value := p_content_parse_events(v_event_i).value;

                insert_value(v_value);

            ELSIF p_content_parse_events(v_event_i).name = 'NULL' THEN

                v_value.type := 'E';
                v_value.value := NULL;

                insert_value(v_value);

            ELSIF p_content_parse_events(v_event_i).name = 'START_OBJECT' THEN

                v_value.type := 'O';
                v_value.value := NULL;

                insert_value(v_value);

                v_event_i := v_event_i + 1;

                WHILE p_content_parse_events(v_event_i).name != 'END_OBJECT' LOOP

                    v_name := p_content_parse_events(v_event_i).value;
                    v_event_i := v_event_i + 1;

                    v_child_id := create_value(v_value.id, v_name);
                    v_event_i := v_event_i + 1;

                END LOOP;

            ELSIF p_content_parse_events(v_event_i).name = 'START_ARRAY' THEN

                v_value.type := 'A';
                v_value.value := NULL;

                insert_value(v_value);

                v_i := 0;
                v_event_i := v_event_i + 1;

                WHILE p_content_parse_events(v_event_i).name != 'END_ARRAY' LOOP

                    v_child_id := create_value(v_value.id, v_i);

                    v_event_i := v_event_i + 1;
                    v_i := v_i + 1;

                END LOOP;

            END IF;

            RETURN v_value.id;

        END;

    BEGIN

        v_json_values := t_json_values();
        v_id := 0;

        p_created_ids := t_numbers();

        FOR v_i IN 1..p_parent_ids.COUNT LOOP

            v_event_i := p_event_i;

            p_created_ids.EXTEND(1);
            p_created_ids(p_created_ids.COUNT) := create_value(p_parent_ids(v_i), p_name, p_id);

        END LOOP;

        flush_values;

        p_event_i := v_event_i;

        FOR v_i IN 1..p_created_ids.COUNT LOOP
            IF v_id_map.EXISTS(p_created_ids(v_i)) THEN
                p_created_ids(v_i) := v_id_map(p_created_ids(v_i));
            END IF;
        END LOOP;

    END;

    FUNCTION create_json (
        p_parent_ids IN t_numbers,
        p_name IN VARCHAR2,
        p_content_parse_events IN json_parser.t_parse_events,
        p_id IN NUMBER := NULL
    ) 
    RETURN t_numbers IS
    
        v_event_i PLS_INTEGER;
        v_created_ids t_numbers;
    
    BEGIN
    
        v_event_i := 1;
        create_json(p_parent_ids, p_name, p_content_parse_events, v_event_i, v_created_ids, p_id);
        
        RETURN v_created_ids;
    
    END;

    FUNCTION create_json (
        p_content IN VARCHAR2
    )
    RETURN NUMBER IS
        v_created_ids t_numbers;
    BEGIN
        RETURN create_json(t_numbers(NULL), NULL, json_parser.parse(p_content))(1);
    END;
    
    FUNCTION create_json_clob (
        p_content IN CLOB
    )
    RETURN NUMBER IS
    BEGIN
        RETURN create_json(t_numbers(NULL), NULL, json_parser.parse(p_content))(1);
    END;

    FUNCTION string_events (
        p_value IN VARCHAR2
    )
    RETURN json_parser.t_parse_events IS
    
        v_parse_event json_parser.t_parse_event;
    
    BEGIN
    
        IF p_value IS NULL THEN
            v_parse_event.name := 'NULL';
        ELSE
            v_parse_event.name := 'STRING';
            v_parse_event.value := p_value;
        END IF;
        
        RETURN json_parser.t_parse_events(v_parse_event);
    
    END;
    
    FUNCTION number_events (
        p_value IN NUMBER
    )
    RETURN json_parser.t_parse_events IS
    
        v_parse_event json_parser.t_parse_event;
    
    BEGIN
    
        IF p_value IS NULL THEN
            v_parse_event.name := 'NULL';
        ELSE
            v_parse_event.name := 'NUMBER';
            v_parse_event.value := p_value;
        END IF;
        
        RETURN json_parser.t_parse_events(v_parse_event);
    
    END;
    
    FUNCTION boolean_events (
        p_value IN BOOLEAN
    )
    RETURN json_parser.t_parse_events IS
    
        v_parse_event json_parser.t_parse_event;
    
    BEGIN
    
        IF p_value IS NULL THEN
            v_parse_event.name := 'NULL';
        ELSE
            v_parse_event.name := 'BOOLEAN';
            v_parse_event.value := CASE WHEN p_value THEN 'true' ELSE 'false' END;
        END IF;
        
        RETURN json_parser.t_parse_events(v_parse_event);
    
    END;
    
    FUNCTION null_events
    RETURN json_parser.t_parse_events IS
    
        v_parse_event json_parser.t_parse_event;
    
    BEGIN
    
        v_parse_event.name := 'NULL';
                
        RETURN json_parser.t_parse_events(v_parse_event);
    
    END;
    
    FUNCTION object_events
    RETURN json_parser.t_parse_events IS
    
        v_start_event json_parser.t_parse_event;
        v_end_event json_parser.t_parse_event;

    BEGIN

        v_start_event.name := 'START_OBJECT';
        v_end_event.name := 'END_OBJECT';
        
        RETURN json_parser.t_parse_events(v_start_event, v_end_event);
        
    END;
    
    FUNCTION array_events
    RETURN json_parser.t_parse_events IS
    
        v_start_event json_parser.t_parse_event;
        v_end_event json_parser.t_parse_event;

    BEGIN

        v_start_event.name := 'START_ARRAY';
        v_end_event.name := 'END_ARRAY';
        
        RETURN json_parser.t_parse_events(v_start_event, v_end_event);
        
    END;

    FUNCTION create_string (
        p_value IN VARCHAR2
    )
    RETURN NUMBER IS
    BEGIN

        RETURN create_json(t_numbers(NULL), NULL, string_events(p_value))(1);

    END;

    FUNCTION create_number (
        p_value IN NUMBER
    )
    RETURN NUMBER IS
    BEGIN

        RETURN create_json(t_numbers(NULL), NULL, number_events(p_value))(1);

    END;

    FUNCTION create_boolean (
        p_value IN BOOLEAN
    )
    RETURN NUMBER IS
    BEGIN

        RETURN create_json(t_numbers(NULL), NULL, boolean_events(p_value))(1);

    END;

    FUNCTION create_null
    RETURN NUMBER IS
    BEGIN

        RETURN create_json(t_numbers(NULL), NULL, null_events)(1);

    END;

    FUNCTION create_object
    RETURN NUMBER IS
    BEGIN

        RETURN create_json(t_numbers(NULL), NULL, object_events)(1);

    END;

    FUNCTION create_array
    RETURN NUMBER IS
    BEGIN

        RETURN create_json(t_numbers(NULL), NULL, array_events)(1);

    END;

    FUNCTION set_property (
        p_path IN VARCHAR2,
        p_content_parse_events IN json_parser.t_parse_events,
        p_exact IN BOOLEAN := TRUE
    )
    RETURN t_numbers IS

        v_path_elements t_path_elements;

        c_properties SYS_REFCURSOR;
        v_properties t_properties;

        v_existing_ids t_numbers;
        v_parent_ids t_numbers;
        
        v_index NUMBER;
        v_length NUMBER;
        v_gap_values t_json_values;

    BEGIN

        v_path_elements := parse_path(p_path);
        request_properties(v_path_elements, c_properties);

        FETCH c_properties
        BULK COLLECT INTO v_properties;

        CLOSE c_properties;

        IF p_exact AND v_properties.COUNT > 1 THEN
            -- Multiple values found at the path :1!
            error$.raise('JDOC-00004', p_path);
        ELSIF v_properties.COUNT = 0 THEN
            -- No container for property at path :1 could be found!
            error$.raise('JDOC-00007', p_path);
        END IF;

        v_index := to_index(v_path_elements(v_path_elements.COUNT).value);
        
        v_existing_ids := t_numbers();
        v_gap_values := t_json_values();
        
        v_parent_ids := t_numbers();

        FOR v_i IN 1..v_properties.COUNT LOOP

            IF v_properties(v_i).property_locked = 'T' THEN
                -- Value :1 is locked!
                error$.raise('JDOC-00024');
            END IF;

            IF NVL(v_properties(v_i).parent_type, 'R') NOT IN ('R', 'O', 'A') THEN
                -- Scalar values and null can't have properties!
                error$.raise('JDOC-00008');
            END IF;

            IF v_properties(v_i).property_id IS NOT NULL THEN
                v_existing_ids.EXTEND(1);
                v_existing_ids(v_existing_ids.COUNT) := v_properties(v_i).property_id;
            END IF;

            v_parent_ids.EXTEND(1);
            v_parent_ids(v_parent_ids.COUNT) := v_properties(v_i).parent_id;
            
            IF v_properties(v_i).parent_type = 'A' THEN
                
                IF v_index IS NULL THEN
                    -- Array element index must be a non-negative integer!
                    error$.raise('JDOC-00013', v_path_elements(v_path_elements.COUNT).value);
                END IF;
                
                v_length := get_length(v_properties(v_i).parent_id);
                
                IF v_index > v_length THEN
                    
                    FOR v_j IN v_length..v_index - 1 LOOP
                    
                        v_gap_values.EXTEND(1);
                        
                        v_gap_values(v_gap_values.COUNT).parent_id := v_properties(v_i).parent_id;
                        v_gap_values(v_gap_values.COUNT).type := 'E';
                        v_gap_values(v_gap_values.COUNT).name := v_j;
                    
                    END LOOP;
                
                END IF;
            
            END IF;

        END LOOP;

        IF v_existing_ids.COUNT > 0 THEN

            FORALL v_i IN 1..v_existing_ids.COUNT
                DELETE FROM json_values
                WHERE id = v_existing_ids(v_i);

        END IF;
        
        IF v_gap_values.COUNT > 0 THEN
        
            FORALL v_i IN 1..v_gap_values.COUNT
                INSERT INTO json_values(id, parent_id, type, name)
                VALUES(jsvl_id.NEXTVAL, v_gap_values(v_i).parent_id, 'E', v_gap_values(v_i).name);
        
        END IF;

        IF v_path_elements(v_path_elements.COUNT).type = 'N' THEN
          
            RETURN create_json
                (v_parent_ids
                ,v_path_elements(v_path_elements.COUNT).value
                ,p_content_parse_events);
            
        ELSE
          
            RETURN create_json
                (v_parent_ids
                ,v_properties(1).property_name
                ,p_content_parse_events
                ,v_path_elements(v_path_elements.COUNT).value);
                
        END IF;

    END;

    FUNCTION set_json (
        p_path IN VARCHAR2,
        p_content IN VARCHAR2
    )
    RETURN NUMBER IS
    BEGIN
        RETURN set_property(p_path, json_parser.parse(p_content))(1);
    END;
    
    PROCEDURE set_json (
        p_path IN VARCHAR2,
        p_content IN VARCHAR2
    ) IS
        
        v_dummy NUMBER;
        
    BEGIN
    
        v_dummy := set_json(p_path, p_content);
    
    END;
    
    FUNCTION set_json_clob (
        p_path IN VARCHAR2,
        p_content IN CLOB
    )
    RETURN NUMBER IS
    BEGIN
        RETURN set_property(p_path, json_parser.parse(p_content))(1);
    END;

    PROCEDURE set_json_clob (
        p_path IN VARCHAR2,
        p_content IN CLOB
    ) IS
        
        v_dummy NUMBER;
        
    BEGIN
    
        v_dummy := set_json_clob(p_path, p_content); 
    
    END;

    FUNCTION set_string (
        p_path IN VARCHAR2,
        p_value IN VARCHAR2
    )
    RETURN NUMBER IS
    BEGIN

        RETURN set_property(p_path, string_events(p_value))(1);

    END;
    
    PROCEDURE set_string (
        p_path IN VARCHAR2,
        p_value IN VARCHAR2
    ) IS
        
        v_dummy NUMBER;
        
    BEGIN

        v_dummy := set_string(p_path, p_value);

    END;

    FUNCTION set_number (
        p_path IN VARCHAR2,
        p_value IN NUMBER
    )
    RETURN NUMBER IS
    BEGIN

        RETURN set_property(p_path, number_events(p_value))(1);

    END;
    
    PROCEDURE set_number (
        p_path IN VARCHAR2,
        p_value IN NUMBER
    ) IS
        
        v_dummy NUMBER;
        
    BEGIN

        v_dummy := set_number(p_path, p_value);

    END;

    FUNCTION set_boolean (
        p_path IN VARCHAR2,
        p_value IN BOOLEAN
    )
    RETURN NUMBER IS
    BEGIN

        RETURN set_property(p_path, boolean_events(p_value))(1);

    END;
    
    PROCEDURE set_boolean (
        p_path IN VARCHAR2,
        p_value IN BOOLEAN
    ) IS
        
        v_dummy NUMBER;
        
    BEGIN

        v_dummy := set_boolean(p_path, p_value);

    END;

    FUNCTION set_null (
        p_path IN VARCHAR2
    )
    RETURN NUMBER IS
    BEGIN

        RETURN set_property(p_path, null_events)(1);

    END;
    
    PROCEDURE set_null (
        p_path IN VARCHAR2
    ) IS
    
        v_dummy NUMBER;
        
    BEGIN
        v_dummy := set_null(p_path);
    END;

    FUNCTION set_object (
        p_path IN VARCHAR2
    )
    RETURN NUMBER IS
    BEGIN

        RETURN set_property(p_path, object_events)(1);

    END;
    
    PROCEDURE set_object (
        p_path IN VARCHAR2
    ) IS
        
        v_dummy NUMBER;
        
    BEGIN
        v_dummy := set_property(p_path, object_events)(1);
    END;

    FUNCTION set_array (
        p_path IN VARCHAR2
    )
    RETURN NUMBER IS
    BEGIN

        RETURN set_property(p_path, array_events)(1);

    END;
    
    PROCEDURE set_array (
        p_path IN VARCHAR2
    ) IS
        
        v_dummy NUMBER;
        
    BEGIN
        v_dummy := set_property(p_path, array_events)(1);
    END;
    
    PROCEDURE request_values (
        p_path_elements IN t_path_elements,
        p_values OUT SYS_REFCURSOR
    ) IS
        
        v_path_signature VARCHAR2(4000);

        v_start_level PLS_INTEGER;
        v_comma VARCHAR2(10);
        v_sql VARCHAR2(32000);

        v_path_values t_varchars;

        FUNCTION field
            (p_i IN PLS_INTEGER)
        RETURN VARCHAR2 IS
        BEGIN
            RETURN CASE p_path_elements(p_i).type
                       WHEN 'I' THEN 'id'
                       ELSE 'name'
                   END;
        END;

    BEGIN

        IF p_path_elements.COUNT = 0 THEN
            -- Empty path specified!
            error$.raise('JDOC-00005');
        END IF;

        FOR v_i IN 1..p_path_elements.COUNT LOOP
            v_path_signature := v_path_signature || p_path_elements(v_i).type;
        END LOOP;

        IF v_value_request_sqls.EXISTS(v_path_signature) THEN

            v_sql := v_value_request_sqls(v_path_signature);

        ELSE

            v_sql := 'WITH path_values AS
    (SELECT column_value AS value, ROWNUM AS rn
     FROM TABLE(:path_values))
';

            IF p_path_elements.COUNT = 1 AND p_path_elements(1).type = 'R' THEN

                v_sql := v_sql || 'SELECT NULL, ''R'', NULL
FROM dual';

            ELSE

                v_start_level := CASE p_path_elements(1).type WHEN 'R' THEN 2 ELSE 1 END;

                v_sql := v_sql || 'SELECT l' || p_path_elements.COUNT || '.id, l' || p_path_elements.COUNT || '.type, l' || p_path_elements.COUNT || '.value
FROM ';

                FOR v_i IN v_start_level..p_path_elements.COUNT LOOP
                  
                    v_sql := v_sql || v_comma || 'json_values l' || v_i;
                    
                    v_comma := '
    ,';
    
                END LOOP;

                v_sql := v_sql || '
WHERE 1=1';

                IF p_path_elements(1).type = 'R' THEN
                    v_sql := v_sql || '
      AND l2.parent_id IS NULL';
                END IF;

                FOR v_i IN v_start_level..p_path_elements.COUNT LOOP

                    v_sql := v_sql || '
      AND l' || v_i || '.' || field(v_i) || ' = (SELECT value FROM path_values WHERE rn = ' || v_i || ')';

                    IF v_i > v_start_level THEN
                        v_sql := v_sql || '
      AND l' || v_i || '.parent_id = l' || (v_i - 1) || '.id';
                    END IF;

                END LOOP;

            END IF;

            v_value_request_sqls(v_path_signature) := v_sql;

        END IF;

        v_path_values := t_varchars();
        v_path_values.EXTEND(p_path_elements.COUNT);

        FOR v_i IN 1..p_path_elements.COUNT LOOP
            v_path_values(v_i) := p_path_elements(v_i).value;
        END LOOP;

        OPEN p_values
        FOR v_sql
        USING IN v_path_values;

    END;
    
    PROCEDURE request_values (
        p_path IN VARCHAR2,
        p_values OUT SYS_REFCURSOR
    ) IS
    BEGIN
        request_values(parse_path(p_path), p_values);
    END;
        
    FUNCTION request_values (
        p_path IN VARCHAR2
    )
    RETURN t_values PIPELINED IS
    
        c_values SYS_REFCURSOR;
        
        v_values t_values;
        c_fetch_limit CONSTANT PLS_INTEGER := 1000;
    
    BEGIN

        request_values(p_path, c_values);
        
        LOOP
        
            v_values := t_values();
            
            FETCH c_values 
            BULK COLLECT INTO v_values
            LIMIT c_fetch_limit;
            
            FOR v_i IN 1..v_values.COUNT LOOP
                PIPE ROW(v_values(v_i));
            END LOOP;
            
            EXIT WHEN v_values.COUNT < c_fetch_limit;
        
        END LOOP;
        
        CLOSE c_values;

    END;
    
    FUNCTION request_value (
        p_path IN VARCHAR2
    ) 
    RETURN t_value IS
    
        c_values SYS_REFCURSOR;
        v_values t_values;
    
    BEGIN

        request_values(p_path, c_values);
        
        FETCH c_values
        BULK COLLECT INTO v_values;
        
        CLOSE c_values;
        
        IF v_values.COUNT = 0 THEN
            -- Value :1 does not exist!
            error$.raise('JDOC-00009', p_path);
        ELSIF v_values.COUNT > 1 THEN
            -- Multiple values found at the path :1!
            error$.raise('JDOC-00004', p_path);
        END IF;
        
        RETURN v_values(1);

    END;
    
    FUNCTION get_string (
        p_path IN VARCHAR2
    )
    RETURN VARCHAR2 IS

        v_value t_value;
    
    BEGIN

        v_value := request_value(p_path);
        
        IF v_value.type IN ('S', 'N', 'E') THEN
            RETURN v_value.value;
        ELSE
            -- Type conversion error!
            error$.raise('JDOC-00010');
        END IF;

    END;
    
    FUNCTION get_number (
        p_path IN VARCHAR2
    )
    RETURN NUMBER IS
    
        v_value t_value;
    
    BEGIN

        v_value := request_value(p_path);
        
        IF v_value.type IN ('N', 'E') THEN
          
            RETURN v_value.value;
            
        ELSIF v_value.type = 'S' THEN
          
            BEGIN
                RETURN v_value.value;
            EXCEPTION
                WHEN OTHERS THEN
                    -- Type conversion error!
                    error$.raise('JDOC-00010');
            END;
            
        ELSE
          
            -- Type conversion error!
            error$.raise('JDOC-00010');
            
        END IF;

    END;
    
    FUNCTION get_boolean (
        p_path IN VARCHAR2
    )
    RETURN BOOLEAN IS
    
        v_value t_value;
    
    BEGIN

        v_value := request_value(p_path);

        IF v_value.type IN ('B', 'E') THEN
            RETURN v_value.value = 'true';
        ELSE
            -- Type conversion error!
            error$.raise('JDOC-00010');
        END IF;

    END;
    
    FUNCTION escape_string (
        p_string IN VARCHAR2
    )
    RETURN VARCHAR2 IS

        v_result VARCHAR2(4000);

    BEGIN

        v_result := REPLACE(p_string, '\', '\\');
        v_result := REPLACE(v_result, '"', '\"');
        v_result := REPLACE(v_result, '/', '\/');
        v_result := REPLACE(v_result, CHR(8), '\b');
        v_result := REPLACE(v_result, CHR(12), '\f');
        v_result := REPLACE(v_result, CHR(10), '\n');
        v_result := REPLACE(v_result, CHR(13), '\r');
        v_result := REPLACE(v_result, CHR(9), '\t');

        RETURN v_result;

    END;
    
    PROCEDURE serialize_value (
        p_parse_events IN json_parser.t_parse_events,
        p_json IN OUT NOCOPY VARCHAR2,
        p_json_clob IN OUT NOCOPY CLOB
    ) IS
        
        v_value VARCHAR2(4000);
        v_length PLS_INTEGER;

        TYPE t_booleans IS 
            TABLE OF BOOLEAN;
            
        v_comma_stack t_booleans;
                
    BEGIN
      
        v_comma_stack := t_booleans(FALSE);
        v_length := 0;

        FOR v_i IN 1..p_parse_events.COUNT LOOP
        
            IF p_parse_events(v_i).name IN ('END_OBJECT', 'END_ARRAY') THEN
               
                p_json := p_json || CASE p_parse_events(v_i).name WHEN 'END_OBJECT' THEN '}' ELSE ']' END;
                
                v_length := v_length + 1;
                v_comma_stack.TRIM(1);
                
            ELSE
            
                IF v_comma_stack(v_comma_stack.COUNT) THEN
                    p_json := p_json || ',';
                    v_length := v_length + 1;
                END IF;
                
                v_comma_stack(v_comma_stack.COUNT) := TRUE;
            
                IF p_parse_events(v_i).name IN ('START_OBJECT', 'START_ARRAY') THEN
                
                    p_json:= p_json || CASE p_parse_events(v_i).name WHEN 'START_OBJECT' THEN '{' ELSE '[' END;
                
                    v_length := v_length + 1;
                                        
                    v_comma_stack.EXTEND(1);
                    v_comma_stack(v_comma_stack.COUNT) := FALSE;
                
                ELSE
                
                    CASE p_parse_events(v_i).name
                    
                        WHEN 'NAME' THEN
                        
                            v_value := escape_string(p_parse_events(v_i).value);
                        
                            p_json := p_json || '"' || v_value || '":';
                            v_length := v_length + 3 + LENGTH(v_value);
                            
                            v_comma_stack(v_comma_stack.COUNT) := FALSE;
                            
                        WHEN 'STRING' THEN
                      
                            v_value := escape_string(p_parse_events(v_i).value);
                                
                            p_json := p_json || '"' || v_value || '"';
                            v_length := v_length + 2 + LENGTH(v_value);
                                
                        WHEN 'NUMBER' THEN
                              
                            p_json := p_json || p_parse_events(v_i).value;
                            v_length := v_length + 2 + LENGTH(p_parse_events(v_i).value);
                                
                        WHEN 'BOOLEAN' THEN
                              
                            p_json := p_json || p_parse_events(v_i).value;
                            v_length := v_length + LENGTH(p_parse_events(v_i).value);
                                
                        WHEN 'NULL' THEN
                              
                            p_json := p_json || 'null';  
                            v_length := v_length + 4;
                    
                    END CASE;
                
                END IF;
                
            END IF;
            
            
            IF p_json_clob IS NOT NULL AND v_length >= 25000 THEN
                
                dbms_lob.append(p_json_clob, p_json);
                    
                p_json := NULL;
                v_length := 0;
                    
            END IF;
            
        
        END LOOP;
        
        IF p_json_clob IS NOT NULL AND p_json IS NOT NULL THEN
            dbms_lob.append(p_json_clob, p_json);
            p_json := NULL;
        END IF;
    
    END;
    
    FUNCTION get_json (
        p_path IN VARCHAR2
    )
    RETURN VARCHAR2 IS
    
        v_json VARCHAR2(32000);
        v_json_clob CLOB;
    
    BEGIN
      
        serialize_value(get_parse_events(p_path), v_json, v_json_clob);
        
        RETURN v_json;
    
    END;
    
    FUNCTION get_json_clob (
        p_path IN VARCHAR2
    )
    RETURN CLOB IS
        
        v_json VARCHAR2(32000);
        v_json_clob CLOB;
    
    BEGIN
      
        
        dbms_lob.createtemporary(v_json_clob, TRUE);
        serialize_value(get_parse_events(p_path), v_json, v_json_clob);
        
        RETURN v_json_clob;
    
    END;
    
    PROCEDURE apply_value (
        p_value_row IN json_values%ROWTYPE,
        p_content_parse_events IN json_parser.t_parse_events,
        p_event_i IN OUT NOCOPY PLS_INTEGER,
        p_check_types IN BOOLEAN
    ) IS
        
        v_event json_parser.t_parse_event;
        v_created_ids t_numbers;
        
        v_child_value_name VARCHAR2(4000);
        v_child_value_row json_values%ROWTYPE;
        
        v_item_i PLS_INTEGER;
        
    BEGIN
    
        v_event := p_content_parse_events(p_event_i);
        
        IF p_value_row.type = 'R' AND v_event.name != 'START_OBJECT' THEN
        
            -- Property :1 type mismatch!
            error$.raise('JDOC-00011', p_value_row.name);
        
        ELSIF (p_value_row.type = 'S' AND v_event.name != 'STRING')
           OR (p_value_row.type = 'N' AND v_event.name != 'NUMBER')
           OR (p_value_row.type = 'B' AND v_event.name != 'BOOLEAN')
           OR (p_value_row.type = 'E' AND v_event.name != 'NULL')
           OR (p_value_row.type = 'O' AND v_event.name != 'START_OBJECT')
           OR (p_value_row.type = 'A' AND v_event.name != 'START_ARRAY') THEN
           
           IF p_check_types AND p_value_row.type != 'E' AND v_event.name != 'NULL' THEN
               -- Property :1 type mismatch!
               error$.raise('JDOC-00011', p_value_row.name);
           END IF;
           
           DELETE FROM json_values
           WHERE id = p_value_row.id;
        
           create_json(t_numbers(p_value_row.parent_id), p_value_row.name, p_content_parse_events, p_event_i, v_created_ids);
        
        ELSIF p_value_row.type IN ('S', 'N', 'B') AND p_value_row.value != v_event.value THEN
            
            UPDATE json_values
            SET value = v_event.value
            WHERE id = p_value_row.id;
        
        ELSIF p_value_row.type = 'R' THEN
        
            p_event_i := p_event_i + 1;
            
            WHILE p_content_parse_events(p_event_i).name != 'END_OBJECT' LOOP
            
                v_child_value_name := p_content_parse_events(p_event_i).value;
            
                BEGIN
                
                    SELECT *
                    INTO v_child_value_row
                    FROM json_values
                    WHERE NVL(parent_id, 0) = 0
                          AND name = v_child_value_name;
                
                    p_event_i := p_event_i + 1;
                    
                    apply_value(v_child_value_row, p_content_parse_events, p_event_i, p_check_types);               
                
                EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                    
                        p_event_i := p_event_i + 1;
                        
                        create_json(t_numbers(NULL), v_child_value_name, p_content_parse_events, p_event_i, v_created_ids);
                
                END;
            
                p_event_i := p_event_i + 1;
            
            END LOOP;
        
        ELSIF p_value_row.type = 'O' THEN
        
            p_event_i := p_event_i + 1;
            
            WHILE p_content_parse_events(p_event_i).name != 'END_OBJECT' LOOP
            
                v_child_value_name := p_content_parse_events(p_event_i).value;
            
                BEGIN
                
                    SELECT *
                    INTO v_child_value_row
                    FROM json_values
                    WHERE NVL(parent_id, 0) = p_value_row.id
                          AND name = v_child_value_name;
                
                    p_event_i := p_event_i + 1;
                    
                    apply_value(v_child_value_row, p_content_parse_events, p_event_i, p_check_types);               
                
                EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                    
                        p_event_i := p_event_i + 1;
                        
                        create_json(t_numbers(p_value_row.id), v_child_value_name, p_content_parse_events, p_event_i, v_created_ids);
                
                END;
            
                p_event_i := p_event_i + 1;
            
            END LOOP;
        
        ELSIF p_value_row.type = 'A' THEN
       
            v_item_i := 0;
            p_event_i := p_event_i + 1;
            
            WHILE p_content_parse_events(p_event_i).name != 'END_ARRAY' LOOP
            
                BEGIN
                
                    SELECT *
                    INTO v_child_value_row
                    FROM json_values
                    WHERE NVL(parent_id, 0) = p_value_row.id
                          AND name = TO_CHAR(v_item_i);
                    
                    apply_value(v_child_value_row, p_content_parse_events, p_event_i, p_check_types);               
                
                EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                    
                        create_json(t_numbers(p_value_row.id), v_item_i, p_content_parse_events, p_event_i, v_created_ids);
                
                END;
            
                p_event_i := p_event_i + 1;
                v_item_i := v_item_i + 1;
            
            END LOOP;
    
        END IF;
        
    
    END;
    
    PROCEDURE apply_json (
        p_path IN VARCHAR2,
        p_content_parse_events json_parser.t_parse_events,
        p_check_types IN BOOLEAN
    ) IS
        
        c_values SYS_REFCURSOR;
        v_values t_values;
        
        v_value_row json_values%ROWTYPE;
        
        v_event_i PLS_INTEGER;
    
    BEGIN

        request_values(p_path, c_values);
        
        FETCH c_values
        BULK COLLECT INTO v_values;
        
        CLOSE c_values;
        
        IF v_values.COUNT = 0 THEN
            -- Value :1 does not exist!
            error$.raise('JDOC-00009', p_path);
        END IF;
        
        FOR v_i IN 1..v_values.COUNT LOOP
        
            IF v_values(v_i).type = 'R' THEN
            
                v_value_row := NULL;
                v_value_row.type := 'R';
                v_value_row.name := '$';
                
            ELSE
            
                SELECT *
                INTO v_value_row
                FROM json_values
                WHERE id = v_values(v_i).id;
                
            END IF;
            
            v_event_i := 1;
        
            apply_value(v_value_row, p_content_parse_events, v_event_i, p_check_types);
            
        END LOOP;
    
    END;
    
    PROCEDURE apply_json (
        p_path IN VARCHAR2,
         -- @json
        p_content IN VARCHAR2,
        p_check_types IN BOOLEAN := FALSE
    ) IS
    BEGIN
        apply_json(p_path, json_parser.parse(p_content), p_check_types);
    END;
        
    PROCEDURE apply_json_clob (
        p_path IN VARCHAR2,
        -- @json
        p_content IN VARCHAR2,
        p_check_types IN BOOLEAN := FALSE
    ) IS
    BEGIN
        apply_json(p_path, json_parser.parse(p_content), p_check_types);
    END;
    
    FUNCTION get_length (
        p_array_id IN NUMBER
    )
    RETURN NUMBER IS
    
        v_length NUMBER;
    
    BEGIN
    
        SELECT NVL(MAX(to_index(name)), -1)
        INTO v_length
        FROM json_values
        WHERE NVL(parent_id, 0) = p_array_id;
        
        RETURN v_length + 1;
    
    END; 
        
    
    FUNCTION get_length (
        p_path IN VARCHAR2
    )
    RETURN NUMBER IS
    
        v_array t_value;
                
    BEGIN
    
        v_array := request_value(p_path);
        
        IF v_array.type != 'A' THEN
            -- :1 is not an array!
            error$.raise('JDOC-00012', p_path);
        END IF;
        
        RETURN get_length(v_array.id);
    
    END;
    
    
    FUNCTION push_property (
        p_path IN VARCHAR2,
        p_content_parse_events IN json_parser.t_parse_events,
        p_exact IN BOOLEAN := TRUE
    )
    RETURN t_numbers IS
    
        c_values SYS_REFCURSOR;
        v_values t_values;
        
        v_ids t_numbers;
        v_all_ids t_numbers;
    
    BEGIN
    
        request_values(p_path, c_values);
    
        FETCH c_values
        BULK COLLECT INTO v_values;
        
        CLOSE c_values;
        
        IF p_exact AND v_values.COUNT > 1 THEN
            -- Multiple values found at the path :1!
            error$.raise('JDOC-00004', p_path);
        ELSIF v_values.COUNT = 0 THEN
            -- Value :1 does not exist
            error$.raise('JDOC-00009', p_path);
        END IF;
    
        v_all_ids := t_numbers();
        
        FOR v_i IN 1..v_values.COUNT LOOP
            
            IF v_values(v_i).type != 'A' THEN
                -- Requested target is not an array!
                error$.raise('JDOC-00014');
            END IF;
            
            v_ids := create_json(
                t_numbers(v_values(v_i).id)
               ,get_length(v_values(v_i).id) 
               ,p_content_parse_events);
            
            FOR v_i IN 1..v_ids.COUNT LOOP
                v_all_ids.EXTEND(1);
                v_all_ids(v_all_ids.COUNT) := v_ids(v_i);
            END LOOP;
        
        END LOOP;
    
        RETURN v_all_ids;
        
    END;
    
    FUNCTION push_string (
        p_path IN VARCHAR2,
        p_value IN VARCHAR2
    )
    RETURN NUMBER IS
    BEGIN

        RETURN push_property(p_path, string_events(p_value))(1);

    END;
    
    PROCEDURE push_string (
        p_path IN VARCHAR2,
        p_value IN VARCHAR2
    ) IS
        
        v_dummy NUMBER;
        
    BEGIN
        v_dummy := push_string(p_path, p_value);
    END;
   
    FUNCTION push_number (
        p_path IN VARCHAR2,
        p_value IN NUMBER
    )
    RETURN NUMBER IS
    BEGIN

        RETURN push_property(p_path, number_events(p_value))(1);

    END;
    
    PROCEDURE push_number (
        p_path IN VARCHAR2,
        p_value IN NUMBER
    ) IS
        
        v_dummy NUMBER;
        
    BEGIN
        v_dummy := push_number(p_path, p_value);
    END;
    
    FUNCTION push_boolean (
        p_path IN VARCHAR2,
        p_value IN BOOLEAN
    )
    RETURN NUMBER IS
    BEGIN

        RETURN push_property(p_path, boolean_events(p_value))(1);

    END;
    
    PROCEDURE push_boolean (
        p_path IN VARCHAR2,
        p_value IN BOOLEAN
    ) IS
        
        v_dummy NUMBER;
        
    BEGIN
        v_dummy := push_boolean(p_path, p_value);
    END;
    
    FUNCTION push_null (
        p_path IN VARCHAR2
    )
    RETURN NUMBER IS
    BEGIN

        RETURN push_property(p_path, null_events)(1);

    END;
        
    PROCEDURE push_null (
        p_path IN VARCHAR2
    ) IS
        
        v_dummy NUMBER;
        
    BEGIN
        v_dummy := push_null(p_path);
    END;
    
    FUNCTION push_object (
        p_path IN VARCHAR2
    )
    RETURN NUMBER IS
    BEGIN

        RETURN push_property(p_path, object_events)(1);

    END;
        
    PROCEDURE push_object (
        p_path IN VARCHAR2
    ) IS
        
        v_dummy NUMBER;
        
    BEGIN
        v_dummy := push_object(p_path);
    END;
        
    FUNCTION push_array (
        p_path IN VARCHAR2
    )
    RETURN NUMBER IS
    BEGIN

        RETURN push_property(p_path, array_events)(1);

    END;
        
    PROCEDURE push_array (
        p_path IN VARCHAR2
    ) IS
        
        v_dummy NUMBER;
        
    BEGIN
        v_dummy := push_array(p_path);
    END;
        
    FUNCTION push_json (
        p_path IN VARCHAR2,
        p_content IN VARCHAR2
    )
    RETURN NUMBER IS
    BEGIN
    
        RETURN push_property(p_path, json_parser.parse(p_content))(1);
    
    END;
        
    PROCEDURE push_json (
        p_path IN VARCHAR2,
        p_content IN VARCHAR2
    ) IS
        
        v_dummy NUMBER;
        
    BEGIN
        v_dummy := push_json(p_path, p_content);
    END;
        
    FUNCTION push_json_clob (
        p_path IN VARCHAR2,
        p_content IN CLOB
    )
    RETURN NUMBER IS
    BEGIN
    
        RETURN push_property(p_path, json_parser.parse(p_content))(1);
    
    END;
        
    PROCEDURE push_json_clob (
        p_path IN VARCHAR2,
        p_content IN CLOB
    ) IS
        
        v_dummy NUMBER;
        
    BEGIN
        v_dummy := push_json(p_path, p_content);
    END;
    
    PROCEDURE delete_value (
        p_path IN VARCHAR2
    ) IS
        
        c_properties SYS_REFCURSOR;
        v_properties t_properties;
        
        v_value t_value;
        
    BEGIN
    
        request_properties(p_path, c_properties);
        
        FETCH c_properties
        BULK COLLECT INTO v_properties;
        
        CLOSE c_properties;
        
        IF v_properties.COUNT > 1 THEN
            -- Multiple values found at the path :1!
            error$.raise('JDOC-00004', p_path);
        ELSIF v_properties.COUNT = 0 OR v_properties(v_properties.COUNT).property_id IS NULL THEN
            -- Value :1 does not exist!
            error$.raise('JDOC-00009', p_path);
        END IF;
        
        FOR v_i IN 1..v_properties.COUNT LOOP
            
            IF v_properties(v_i).property_locked = 'T' THEN
                -- Value :1 is locked!
                error$.raise('JDOC-00024');
            END IF;
        
            DELETE FROM json_values
            WHERE id = v_properties(v_i).property_id;
        
            IF v_properties(v_i).parent_type = 'A' THEN
            
                INSERT INTO json_values(id, parent_id, type, name)
                VALUES(jsvl_id.NEXTVAL, v_properties(v_i).parent_id, 'E', v_properties(v_i).property_name);
            
            END IF;
        
        END LOOP;

    
    END;
    
    PROCEDURE lock_value (
        p_path IN VARCHAR2
    ) IS
    
        v_value t_value;
        t_ids_to_lock t_numbers;
    
    BEGIN
    
        v_value := request_value(p_path);
    
        SELECT id
        BULK COLLECT INTO t_ids_to_lock
        FROM json_values
        START WITH id = v_value.id
        CONNECT BY PRIOR parent_id = id
        FOR UPDATE;
        
        FORALL v_i IN 1..t_ids_to_lock.COUNT
            UPDATE json_values
            SET locked = 'T'
            WHERE id = t_ids_to_lock(v_i);
    
    END;
    
    PROCEDURE unlock_value (
        p_path IN VARCHAR2
    ) IS
    
        v_value t_value;
        v_dummy NUMBER;
        
        CURSOR c_locked_child (
            p_parent_id IN NUMBER
        ) IS
        SELECT 1
        FROM json_values
        WHERE NVL(parent_id, 0) = p_parent_id
              AND locked = 'T';
    
    BEGIN
        
        v_value := request_value(p_path);
        
        OPEN c_locked_child(v_value.id);
        
        FETCH c_locked_child
        INTO v_dummy;
        
        IF c_locked_child%FOUND THEN
            -- Value :1 has locked children!
            error$.raise('JDOC-00025');
        END IF;
        
        UPDATE json_values
        SET locked = NULL
        WHERE id = v_value.id;
        
    
    END;
    
    FUNCTION get_parse_events (
        p_path IN VARCHAR2
    )
    RETURN json_parser.t_parse_events IS
    
        v_path_value t_value;
        
        TYPE t_chars IS 
            TABLE OF CHAR;
            
        v_json_stack t_chars;
        
        v_last_lvl PLS_INTEGER;
        
        v_events json_parser.t_parse_events;
    
        CURSOR c_values (p_root_id IN NUMBER) IS
            WITH parent_jsvl(id, type, name, value, lvl, ord) AS
                (SELECT id
                       ,type
                       ,name
                       ,value
                       ,1 AS lvl
                       ,0
                 FROM json_values
                 WHERE id = p_root_id
                 UNION ALL
                 SELECT jsvl.id
                       ,jsvl.type
                       ,jsvl.name
                       ,jsvl.value
                       ,parent_jsvl.lvl + 1
                       ,CASE parent_jsvl.type
                            WHEN 'A' THEN
                                TO_NUMBER(jsvl.name)
                            ELSE
                                jsvl.id
                        END
                 FROM parent_jsvl
                     ,json_values jsvl
                 WHERE NVL(jsvl.parent_id, 0) = parent_jsvl.id
                 ORDER BY 6)
            SEARCH DEPTH FIRST BY ord SET dummy
            SELECT type
                  ,name
                  ,value
                  ,lvl
            FROM parent_jsvl;
            
        PROCEDURE add_event (
            p_name IN VARCHAR2,
            p_value IN VARCHAR2 := NULL
        ) IS
        BEGIN
        
            v_events.EXTEND(1);
            
            v_events(v_events.COUNT).name := p_name;
            v_events(v_events.COUNT).value := p_value;        
        END;
                
    BEGIN
        
        v_path_value := request_value(p_path);
    
        v_events := json_parser.t_parse_events();
        v_json_stack := t_chars();
        v_last_lvl := 0;
    
        FOR v_value IN c_values(v_path_value.id) LOOP
        
            FOR v_i IN v_value.lvl..v_last_lvl LOOP
                  
                IF v_json_stack(v_json_stack.COUNT) = 'O' THEN
                    add_event('END_OBJECT');                        
                ELSIF v_json_stack(v_json_stack.COUNT) = 'A' THEN
                    add_event('END_ARRAY');
                END IF;
                    
                v_json_stack.TRIM(1);   
                    
            END LOOP;
            
            IF v_value.name IS NOT NULL 
               AND v_json_stack.COUNT > 0
               AND v_json_stack(v_json_stack.COUNT) = 'O' THEN

                add_event('NAME', v_value.name);
                   
            END IF;
            
            CASE v_value.type
                  
                WHEN 'S' THEN
                    add_event('STRING', v_value.value);  
                WHEN 'N' THEN
                    add_event('NUMBER', v_value.value);  
                WHEN 'B' THEN
                    add_event('BOOLEAN', v_value.value);
                WHEN 'E' THEN
                    add_event('NULL');
                WHEN 'O' THEN
                    add_event('START_OBJECT');
                WHEN 'A' THEN
                    add_event('START_ARRAY');
                
            END CASE;
            
            v_json_stack.EXTEND(1);
            v_json_stack(v_json_stack.COUNT) := v_value.type;
                
            v_last_lvl := v_value.lvl;
        
        END LOOP;
        
        FOR v_i IN REVERSE 1..v_json_stack.COUNT LOOP
          
             IF v_json_stack(v_i) = 'O' THEN
                 add_event('END_OBJECT');    
             ELSIF v_json_stack(v_i) = 'A' THEN
                 add_event('END_ARRAY');
             END IF;
        
        END LOOP;
    
        RETURN v_events;
    
    END;
    
    FUNCTION get_5_value_table (
        p_query IN VARCHAR2,
        p_variable_1 IN VARCHAR2 := NULL,
        p_variable_2 IN VARCHAR2 := NULL,
        p_variable_3 IN VARCHAR2 := NULL,
        p_variable_4 IN VARCHAR2 := NULL,
        p_variable_5 IN VARCHAR2 := NULL,
        p_variable_6 IN VARCHAR2 := NULL,
        p_variable_7 IN VARCHAR2 := NULL,
        p_variable_8 IN VARCHAR2 := NULL,
        p_variable_9 IN VARCHAR2 := NULL,
        p_variable_10 IN VARCHAR2 := NULL,
        p_variable_11 IN VARCHAR2 := NULL,
        p_variable_12 IN VARCHAR2 := NULL,
        p_variable_13 IN VARCHAR2 := NULL,
        p_variable_14 IN VARCHAR2 := NULL,
        p_variable_15 IN VARCHAR2 := NULL,
        p_variable_16 IN VARCHAR2 := NULL,
        p_variable_17 IN VARCHAR2 := NULL,
        p_variable_18 IN VARCHAR2 := NULL,
        p_variable_19 IN VARCHAR2 := NULL,
        p_variable_20 IN VARCHAR2 := NULL
    )
    RETURN t_5_value_table PIPELINED IS
    
        v_dummy NUMBER;
    
        v_query t_json_query;
        v_row t_varchars;
        
        v_value_row t_5_value_row;
    
    BEGIN
    
        v_query := t_json_query(NULL);
        v_dummy := t_json_query.odcitablestart(
            v_query, 
            p_query,
            p_variable_1,
            p_variable_2,
            p_variable_3,
            p_variable_4,
            p_variable_5,
            p_variable_6,
            p_variable_7,
            p_variable_8,
            p_variable_9,
            p_variable_10,
            p_variable_11,
            p_variable_12,
            p_variable_13,
            p_variable_14,
            p_variable_15,
            p_variable_16,
            p_variable_17,
            p_variable_18,
            p_variable_19,
            p_variable_20
        );
        
        v_row := t_varchars();
        v_row.extend(5);
    
        WHILE v_query.fetch_row(v_row) LOOP
        
            v_value_row.value_1 := v_row(1);
            v_value_row.value_2 := v_row(2);
            v_value_row.value_3 := v_row(3);
            v_value_row.value_4 := v_row(4);
            v_value_row.value_5 := v_row(5);
            
            
            PIPE ROW(v_value_row);
        
        END LOOP;
    
        v_dummy := v_query.odcitableclose;
    
        RETURN;
    
    END;
    
    FUNCTION get_10_value_table (
        p_query IN VARCHAR2,
        p_variable_1 IN VARCHAR2 := NULL,
        p_variable_2 IN VARCHAR2 := NULL,
        p_variable_3 IN VARCHAR2 := NULL,
        p_variable_4 IN VARCHAR2 := NULL,
        p_variable_5 IN VARCHAR2 := NULL,
        p_variable_6 IN VARCHAR2 := NULL,
        p_variable_7 IN VARCHAR2 := NULL,
        p_variable_8 IN VARCHAR2 := NULL,
        p_variable_9 IN VARCHAR2 := NULL,
        p_variable_10 IN VARCHAR2 := NULL,
        p_variable_11 IN VARCHAR2 := NULL,
        p_variable_12 IN VARCHAR2 := NULL,
        p_variable_13 IN VARCHAR2 := NULL,
        p_variable_14 IN VARCHAR2 := NULL,
        p_variable_15 IN VARCHAR2 := NULL,
        p_variable_16 IN VARCHAR2 := NULL,
        p_variable_17 IN VARCHAR2 := NULL,
        p_variable_18 IN VARCHAR2 := NULL,
        p_variable_19 IN VARCHAR2 := NULL,
        p_variable_20 IN VARCHAR2 := NULL
    )
    RETURN t_10_value_table PIPELINED IS
    
        v_dummy NUMBER;
    
        v_query t_json_query;
        v_row t_varchars;
        
        v_value_row t_10_value_row;
    
    BEGIN
    
        v_query := t_json_query(NULL);
        v_dummy := t_json_query.odcitablestart(
            v_query, 
            p_query,
            p_variable_1,
            p_variable_2,
            p_variable_3,
            p_variable_4,
            p_variable_5,
            p_variable_6,
            p_variable_7,
            p_variable_8,
            p_variable_9,
            p_variable_10,
            p_variable_11,
            p_variable_12,
            p_variable_13,
            p_variable_14,
            p_variable_15,
            p_variable_16,
            p_variable_17,
            p_variable_18,
            p_variable_19,
            p_variable_20
        );
        
        v_row := t_varchars();
        v_row.extend(10);
    
        WHILE v_query.fetch_row(v_row) LOOP
        
            v_value_row.value_1 := v_row(1);
            v_value_row.value_2 := v_row(2);
            v_value_row.value_3 := v_row(3);
            v_value_row.value_4 := v_row(4);
            v_value_row.value_5 := v_row(5);
            v_value_row.value_6 := v_row(6);
            v_value_row.value_7 := v_row(7);
            v_value_row.value_8 := v_row(8);
            v_value_row.value_9 := v_row(9);
            v_value_row.value_10 := v_row(10);
            
            PIPE ROW(v_value_row);
        
        END LOOP;
    
        v_dummy := v_query.odcitableclose;
    
        RETURN;
    
    END;
    
    FUNCTION get_15_value_table (
        p_query IN VARCHAR2,
        p_variable_1 IN VARCHAR2 := NULL,
        p_variable_2 IN VARCHAR2 := NULL,
        p_variable_3 IN VARCHAR2 := NULL,
        p_variable_4 IN VARCHAR2 := NULL,
        p_variable_5 IN VARCHAR2 := NULL,
        p_variable_6 IN VARCHAR2 := NULL,
        p_variable_7 IN VARCHAR2 := NULL,
        p_variable_8 IN VARCHAR2 := NULL,
        p_variable_9 IN VARCHAR2 := NULL,
        p_variable_10 IN VARCHAR2 := NULL,
        p_variable_11 IN VARCHAR2 := NULL,
        p_variable_12 IN VARCHAR2 := NULL,
        p_variable_13 IN VARCHAR2 := NULL,
        p_variable_14 IN VARCHAR2 := NULL,
        p_variable_15 IN VARCHAR2 := NULL,
        p_variable_16 IN VARCHAR2 := NULL,
        p_variable_17 IN VARCHAR2 := NULL,
        p_variable_18 IN VARCHAR2 := NULL,
        p_variable_19 IN VARCHAR2 := NULL,
        p_variable_20 IN VARCHAR2 := NULL
    )
    RETURN t_15_value_table PIPELINED IS
    
        v_dummy NUMBER;
    
        v_query t_json_query;
        v_row t_varchars;
        
        v_value_row t_15_value_row;
    
    BEGIN
    
        v_query := t_json_query(NULL);
        v_dummy := t_json_query.odcitablestart(
            v_query, 
            p_query,
            p_variable_1,
            p_variable_2,
            p_variable_3,
            p_variable_4,
            p_variable_5,
            p_variable_6,
            p_variable_7,
            p_variable_8,
            p_variable_9,
            p_variable_10,
            p_variable_11,
            p_variable_12,
            p_variable_13,
            p_variable_14,
            p_variable_15,
            p_variable_16,
            p_variable_17,
            p_variable_18,
            p_variable_19,
            p_variable_20
        );
        
        v_row := t_varchars();
        v_row.extend(15);
    
        WHILE v_query.fetch_row(v_row) LOOP
        
            v_value_row.value_1 := v_row(1);
            v_value_row.value_2 := v_row(2);
            v_value_row.value_3 := v_row(3);
            v_value_row.value_4 := v_row(4);
            v_value_row.value_5 := v_row(5);
            v_value_row.value_6 := v_row(6);
            v_value_row.value_7 := v_row(7);
            v_value_row.value_8 := v_row(8);
            v_value_row.value_9 := v_row(9);
            v_value_row.value_10 := v_row(10);
            v_value_row.value_11 := v_row(11);
            v_value_row.value_12 := v_row(12);
            v_value_row.value_13 := v_row(13);
            v_value_row.value_14 := v_row(14);
            v_value_row.value_15 := v_row(15);
            
            PIPE ROW(v_value_row);
        
        END LOOP;
    
        v_dummy := v_query.odcitableclose;
    
        RETURN;
    
    END;
    
    FUNCTION get_20_value_table (
        p_query IN VARCHAR2,
        p_variable_1 IN VARCHAR2 := NULL,
        p_variable_2 IN VARCHAR2 := NULL,
        p_variable_3 IN VARCHAR2 := NULL,
        p_variable_4 IN VARCHAR2 := NULL,
        p_variable_5 IN VARCHAR2 := NULL,
        p_variable_6 IN VARCHAR2 := NULL,
        p_variable_7 IN VARCHAR2 := NULL,
        p_variable_8 IN VARCHAR2 := NULL,
        p_variable_9 IN VARCHAR2 := NULL,
        p_variable_10 IN VARCHAR2 := NULL,
        p_variable_11 IN VARCHAR2 := NULL,
        p_variable_12 IN VARCHAR2 := NULL,
        p_variable_13 IN VARCHAR2 := NULL,
        p_variable_14 IN VARCHAR2 := NULL,
        p_variable_15 IN VARCHAR2 := NULL,
        p_variable_16 IN VARCHAR2 := NULL,
        p_variable_17 IN VARCHAR2 := NULL,
        p_variable_18 IN VARCHAR2 := NULL,
        p_variable_19 IN VARCHAR2 := NULL,
        p_variable_20 IN VARCHAR2 := NULL
    )
    RETURN t_20_value_table PIPELINED IS
    
        v_dummy NUMBER;
    
        v_query t_json_query;
        v_row t_varchars;
        
        v_value_row t_20_value_row;
    
    BEGIN
    
        v_query := t_json_query(NULL);
        v_dummy := t_json_query.odcitablestart(
            v_query, 
            p_query,
            p_variable_1,
            p_variable_2,
            p_variable_3,
            p_variable_4,
            p_variable_5,
            p_variable_6,
            p_variable_7,
            p_variable_8,
            p_variable_9,
            p_variable_10,
            p_variable_11,
            p_variable_12,
            p_variable_13,
            p_variable_14,
            p_variable_15,
            p_variable_16,
            p_variable_17,
            p_variable_18,
            p_variable_19,
            p_variable_20
        );
        
        v_row := t_varchars();
        v_row.extend(20);
    
        WHILE v_query.fetch_row(v_row) LOOP
        
            v_value_row.value_1 := v_row(1);
            v_value_row.value_2 := v_row(2);
            v_value_row.value_3 := v_row(3);
            v_value_row.value_4 := v_row(4);
            v_value_row.value_5 := v_row(5);
            v_value_row.value_6 := v_row(6);
            v_value_row.value_7 := v_row(7);
            v_value_row.value_8 := v_row(8);
            v_value_row.value_9 := v_row(9);
            v_value_row.value_10 := v_row(10);
            v_value_row.value_11 := v_row(11);
            v_value_row.value_12 := v_row(12);
            v_value_row.value_13 := v_row(13);
            v_value_row.value_14 := v_row(14);
            v_value_row.value_15 := v_row(15);
            v_value_row.value_16 := v_row(16);
            v_value_row.value_17 := v_row(17);
            v_value_row.value_18 := v_row(18);
            v_value_row.value_19 := v_row(19);
            v_value_row.value_20 := v_row(10);
            
            PIPE ROW(v_value_row);
        
        END LOOP;
    
        v_dummy := v_query.odcitableclose;
    
        RETURN;
    
    END;
    
    -- TODO
    FUNCTION get_value_table_cursor (
        p_query IN VARCHAR2
    )
    RETURN SYS_REFCURSOR IS 
    
        v_cursor SYS_REFCURSOR;
    
    BEGIN
    
        RETURN v_cursor;
        
    END;

BEGIN
    register_messages;
END;

