CREATE OR REPLACE PACKAGE BODY json_core IS

    /* 
        Copyright 2018 Sergejs Vinniks

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
    
    TYPE t_json_values IS 
        TABLE OF json_values%ROWTYPE;

    TYPE t_integer_indexed_numbers IS 
        TABLE OF NUMBER 
        INDEX BY PLS_INTEGER;
    
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
        default_message_resolver.register_message('JDOC-00004', 'Multiple values found at path :1!');
        default_message_resolver.register_message('JDOC-00005', 'Empty path specified!');
        default_message_resolver.register_message('JDOC-00006', 'Root requested as a property!');
        default_message_resolver.register_message('JDOC-00007', 'No container for property at path :1 could be found!');
        default_message_resolver.register_message('JDOC-00008', 'Scalar values and null can''t have properties!');
        default_message_resolver.register_message('JDOC-00009', 'Value :1 does not exist!');
        default_message_resolver.register_message('JDOC-00011', 'Property ":1" type mismatch!');
        default_message_resolver.register_message('JDOC-00013', 'Invalid array element index :1!');
        default_message_resolver.register_message('JDOC-00014', 'Requested target is not an array!');
        default_message_resolver.register_message('JDOC-00015', 'Unexpected :1 in a non-branching query!');
        default_message_resolver.register_message('JDOC-00016', 'Duplicate property/alias ":1"!');
        default_message_resolver.register_message('JDOC-00017', 'Alias too long!');
        default_message_resolver.register_message('JDOC-00018', 'Property name ":1" is too long to be a column name!');
        default_message_resolver.register_message('JDOC-00019', 'Alias not specified for a leaf wildcard property!');
        default_message_resolver.register_message('JDOC-00020', 'Variable name too long!');
        default_message_resolver.register_message('JDOC-00021', '');
        default_message_resolver.register_message('JDOC-00022', '');
        default_message_resolver.register_message('JDOC-00023', 'Column alias for a wildcard not specified!');
        default_message_resolver.register_message('JDOC-00024', 'Value :1 is locked!');
        default_message_resolver.register_message('JDOC-00025', 'Reserved field reference can''t be optional!');
        default_message_resolver.register_message('JDOC-00026', 'Reserved field reference can''t be branched!');
        default_message_resolver.register_message('JDOC-00027', 'Reserved field reference can''t have child elements!');
        default_message_resolver.register_message('JDOC-00028', 'Reserved field reference can''t be the topmost query element!');
        default_message_resolver.register_message('JDOC-00029', 'The topmost query element can''t be optional!');
    END;
    
    FUNCTION parse_query (
        p_query IN VARCHAR2,
        p_query_type IN PLS_INTEGER := c_VALUE_TABLE_QUERY
    )
    RETURN t_query_elements IS
    
        v_cache_key VARCHAR2(32000);
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
        
            IF v_stack.COUNT > 1 AND v_query_elements(v_stack(v_stack.COUNT).element_i).type = 'F' THEN
                -- Reserved field reference can''t have child elements!
                error$.raise('JDOC-00027');
            END IF;
        
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
            
            ELSIF p_value IN ('_id', '_key', '_value') AND p_query_type IN (c_VALUE_TABLE_QUERY, c_X_VALUE_TABLE_QUERY) THEN
            
                IF v_stack.COUNT = 1 THEN
                    -- Reserved field reference can''t be the topmost query element!
                    error$.raise('JDOC-00028');
                END IF;
            
                push('F', SUBSTR(p_value, 2));
            
            ELSE
            
                push('N', p_value);
            
            END IF;
        
        END;
        
        PROCEDURE push_variable
            (p_value IN VARCHAR2) IS
            
            v_variable NUMBER;
            
        BEGIN
        
            IF LENGTH(p_value) > 30 THEN
                -- Variable name too long
                error$.raise('JDOC-00020');
            END IF;
         
            push('V', UPPER(p_value));
        
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
        
            IF v_stack.COUNT = 2 THEN
                -- The topmost query element can''t be optional!
                error$.raise('JDOC-00029');
            ELSIF v_query_elements(v_stack(v_stack.COUNT).element_i).TYPE = 'F' THEN
                -- Reserved field reference can''t be optional!
                error$.raise('JDOC-00025');
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
        
            IF v_stack.COUNT > 1 AND v_query_elements(v_stack(v_stack.COUNT).element_i).TYPE = 'F' THEN
                -- Reserved field reference can''t be branched!
                error$.raise('JDOC-00026');
            END IF;
        
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
        
            IF v_char = '(' AND p_query_type IN (c_VALUE_TABLE_QUERY, c_X_VALUE_TABLE_QUERY) THEN
            
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
                
            ELSIF v_char = '(' AND p_query_type IN (c_VALUE_TABLE_QUERY, c_X_VALUE_TABLE_QUERY) THEN
            
                push_name(v_value, TRUE);
                branch;
                v_state := 'lf_child';
                
            ELSIF space THEN
            
                push_name(v_value, TRUE);
                v_state := 'lf_separator';
                
            ELSIF v_char = '?' AND p_query_type IN (c_VALUE_TABLE_QUERY, c_X_VALUE_TABLE_QUERY) THEN
            
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
                
                
            ELSIF v_char = '(' AND p_query_type IN (c_VALUE_TABLE_QUERY, c_X_VALUE_TABLE_QUERY) THEN
            
                branch;
                v_state := 'lf_child';  
                
            ELSIF LOWER(v_char) = 'a' AND p_query_type IN (c_VALUE_TABLE_QUERY) THEN
            
                v_state := 'lf_as_s';
                
            ELSIF v_char = '?' AND p_query_type IN (c_VALUE_TABLE_QUERY, c_X_VALUE_TABLE_QUERY) THEN
            
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
                
            ELSIF v_char = '(' AND p_query_type IN (c_VALUE_TABLE_QUERY, c_X_VALUE_TABLE_QUERY) THEN
            
                push('I', v_value);
                branch;
                v_state := 'lf_child'; 
                
            ELSIF space THEN
            
                push('I', v_value);
                v_state := 'lf_separator';
                
            ELSIF v_char = '?' AND p_query_type IN (c_VALUE_TABLE_QUERY, c_X_VALUE_TABLE_QUERY) THEN
            
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
        
            IF INSTR('qwertyuioplkjhgfdsazxcvbnm', LOWER(v_char)) > 0 THEN
            
                v_value := v_char;
                v_state := 'r_variable';
                
            ELSE
            
                -- Unexpected character ":1"!
                error$.raise('JDOC-00001', v_char);
            
            END IF;
        
        END;
        
        PROCEDURE r_variable IS
        BEGIN
        
            IF INSTR('qwertyuioplkjhgfdsazxcvbnm1234567890_$#', LOWER(v_char)) > 0 THEN
            
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
                
            ELSIF v_char = '(' AND p_query_type IN (c_VALUE_TABLE_QUERY, c_X_VALUE_TABLE_QUERY) THEN
            
                push_variable(v_value);
                branch;
                v_state := 'lf_child'; 
                
            ELSIF space THEN
            
                push_variable(v_value);
                v_state := 'lf_separator';
                
            ELSIF v_char = '?' AND p_query_type IN (c_VALUE_TABLE_QUERY, c_X_VALUE_TABLE_QUERY) THEN
            
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
        
            IF INSTR('qwertyuioplkjhgfdsazxcvbnm', LOWER(v_char)) > 0 THEN
            
                v_value := v_char;
                v_state := 'r_array_variable';
                
            ELSE
            
                -- Unexpected character ":1"!
                error$.raise('JDOC-00001', v_char);
            
            END IF;
        
        END;
        
        PROCEDURE r_array_variable IS
        BEGIN
        
            IF INSTR('qwertyuioplkjhgfdsazxcvbnm1234567890_$#', LOWER(v_char)) > 0 THEN
            
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
    
        v_cache_key := p_query_type || p_query;
    
        IF v_query_element_cache.EXISTS(v_cache_key) THEN
            RETURN v_query_element_cache(v_cache_key);
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
    
        IF p_query_type = c_PROPERTY_QUERY AND v_query_elements.COUNT > 1 THEN
            v_query_elements(v_query_elements.COUNT).optional := TRUE;
        END IF;
        
        v_query_element_cache(v_cache_key) := v_query_elements;
        
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
        
            IF p_query_elements(p_i).type = 'F' THEN
                v_signature := v_signature || SUBSTR(p_query_elements(p_i).value, 1, 1); 
            ELSE
                v_signature := v_signature || p_query_elements(p_i).type || CASE WHEN p_query_elements(p_i).optional THEN '?' END;
            END IF;
        
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
                error$.raise('JDOC-00016', p_name);
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
    
    FUNCTION get_query_variable_count (
        p_query_elements IN t_query_elements
    )
    RETURN PLS_INTEGER IS
    
        TYPE t_unique_names IS 
            TABLE OF BOOLEAN 
            INDEX BY VARCHAR2(30);
            
        v_unique_variable_names t_unique_names;
        
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
        
        RETURN v_unique_variable_names.COUNT;
    
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
        p_query_type IN PLS_INTEGER,
        p_column_count IN PLS_INTEGER := NULL
    )
    RETURN t_query_statement IS
    
        v_cache_key VARCHAR2(32000);
    
        v_line VARCHAR2(32000);
        
        v_table_instance_counter PLS_INTEGER;
        v_auto_variable_number PLS_INTEGER;
        v_comma CHAR;
        v_and VARCHAR2(5);
        v_column_count PLS_INTEGER;
        
        TYPE t_variable_numbers IS 
            TABLE OF PLS_INTEGER
            INDEX BY VARCHAR2(30);
            
        v_variable_numbers t_variable_numbers;
        v_variable_number PLS_INTEGER;
        
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
            p_i PLS_INTEGER,
            p_parent_table_instance IN PLS_INTEGER
        ) IS
            
            v_table_instance PLS_INTEGER;
            
        BEGIN
            
            IF p_query_elements(p_i).type = 'F' THEN
                v_table_instance := p_parent_table_instance;
            ELSE
                v_table_instance_counter := v_table_instance_counter + 1;
                v_table_instance := v_table_instance_counter;
            END IF;
                    
            IF p_query_elements(p_i).first_child_i IS NOT NULL THEN
            
                select_list_visit(p_query_elements(p_i).first_child_i, v_table_instance);
                
            ELSE
            
                v_column_count := v_column_count + 1;
            
                IF p_query_type = c_VALUE_TABLE_QUERY OR (p_query_type = c_X_VALUE_TABLE_QUERY AND v_column_count <= NVL(p_column_count, v_column_count)) THEN
                
                    add_text(v_comma || 'j' || v_table_instance || '.');
                
                    IF p_query_elements(p_i).type = 'F' THEN
                        add_text(CASE p_query_elements(p_i).value WHEN 'key' THEN 'name' ELSE p_query_elements(p_i).value END);
                    ELSE
                        add_text('value');
                    END IF;
                    
                ELSIF p_query_type = c_VALUE_QUERY THEN
                
                    add_text(v_comma || 'j' || v_table_instance || '.id,j' || v_table_instance || '.type,j' || v_table_instance || '.value');
                    
                ELSIF p_query_type = c_PROPERTY_QUERY THEN
                
                    IF p_parent_table_instance IS NULL THEN
                        add_text(v_comma || 'j' || v_table_instance || '.parent_id,(SELECT type FROM json_values WHERE id=j' || v_table_instance || '.parent_id)');
                    ELSE 
                        add_text(v_comma || 'j' || p_parent_table_instance || '.id,j' || p_parent_table_instance || '.type');
                    END IF;
                
                    add_text(',j' || v_table_instance || '.id,j' || v_table_instance || '.type,j' || v_table_instance || '.name,j' || v_table_instance || '.locked');
                    
                END IF;    
                
                v_comma := ',';
                
            END IF;
            
            IF p_query_elements(p_i).next_sibling_i IS NOT NULL THEN
                select_list_visit(p_query_elements(p_i).next_sibling_i, p_parent_table_instance);
            END IF;
        
        END;
        
        PROCEDURE from_list_visit (
            p_i PLS_INTEGER
        ) IS
            
            v_table_instance PLS_INTEGER;
            
        BEGIN
        
            IF p_query_elements(p_i).type != 'F'  THEN
            
                v_table_instance_counter := v_table_instance_counter + 1;
                v_table_instance := v_table_instance_counter;
                
                add_text(v_comma || 'json_values j' || v_table_instance);
                        
                v_comma := ',';
                
            END IF;
        
            IF p_query_elements(p_i).first_child_i IS NOT NULL THEN
                from_list_visit(p_query_elements(p_i).first_child_i);
            END IF;
            
            IF p_query_elements(p_i).next_sibling_i IS NOT NULL THEN
                from_list_visit(p_query_elements(p_i).next_sibling_i);
            END IF;
        
        END;
        
        PROCEDURE where_list_visit (
            p_i PLS_INTEGER,
            p_parent_table_instance IN PLS_INTEGER
        ) IS
            
            v_table_instance PLS_INTEGER;
            
        BEGIN
        
            IF p_query_elements(p_i).type = 'F' THEN
            
                v_table_instance := p_parent_table_instance;
                
            ELSE
            
                v_table_instance_counter := v_table_instance_counter + 1;
                v_table_instance := v_table_instance_counter;
                
            
                IF p_parent_table_instance IS NOT NULL THEN
                
                    add_text(v_and || 'j' || v_table_instance || '.parent_id');
                    
                    IF p_query_elements(p_i).optional THEN
                        add_text('(+)');
                    END IF;
                    
                    add_text('=j' || p_parent_table_instance || '.id');
                    
                    v_and := ' AND ';
                    
                END IF;
                
                IF p_query_elements(p_i).type = 'R' THEN
                
                    add_text(v_and || 'j' || v_table_instance || '.id=0');
                    
                    v_and := ' AND ';
                
                ELSIF p_query_elements(p_i).type = 'N' THEN
                
                    add_text(v_and || 'j' || v_table_instance || '.name');
                    
                    IF p_query_elements(p_i).optional THEN
                        add_text('(+)');
                    END IF;
                    
                    v_auto_variable_number := v_auto_variable_number + 1;
                    add_text('=:v' || v_auto_variable_number);
                    
                    v_and := ' AND ';
                    
                ELSIF p_query_elements(p_i).type = 'I' THEN
                
                    add_text(v_and || 'j' || v_table_instance || '.id');
                    
                    IF p_query_elements(p_i).optional THEN
                        add_text('(+)');
                    END IF;
                    
                    v_auto_variable_number := v_auto_variable_number + 1;
                    add_text('=TO_NUMBER(:v' || v_auto_variable_number || ')');
                    
                    v_and := ' AND ';
                    
                ELSIF p_query_elements(p_i).type = 'V' THEN
                
                    add_text(v_and || 'j' || v_table_instance || '.name');
                    
                    IF p_query_elements(p_i).optional THEN
                        add_text('(+)');
                    END IF;
                    
                    IF NOT v_variable_numbers.EXISTS(p_query_elements(p_i).value) THEN
                        v_variable_number := v_variable_number + 1;
                        v_variable_numbers(p_query_elements(p_i).value) := v_variable_number;
                    END IF;
                    
                    add_text('=:' || v_variable_numbers(p_query_elements(p_i).value));
                    
                    v_and := ' AND ';
                    
                END IF;
                
            END IF;
        
            IF p_query_elements(p_i).first_child_i IS NOT NULL THEN
                where_list_visit(p_query_elements(p_i).first_child_i, v_table_instance);
            END IF;
            
            IF p_query_elements(p_i).next_sibling_i IS NOT NULL THEN
                where_list_visit(p_query_elements(p_i).next_sibling_i, p_parent_table_instance);
            END IF;
                
        END;
    
    BEGIN
    
        v_cache_key := p_query_type || '[' || p_column_count || ']' || get_query_signature(p_query_elements);
        
        IF v_query_statement_cache.EXISTS(v_cache_key) THEN
            RETURN v_query_statement_cache(v_cache_key);
        END IF;    
    
        v_table_instance_counter := 0;
        v_column_count := 0;
        v_comma := NULL; 
        add_text('SELECT ');
        select_list_visit(1, NULL);
        
        FOR v_i IN v_column_count + 1..NVL(p_column_count, v_column_count) LOOP
            add_text(v_comma || 'NULL');
            v_comma := ',';
        END LOOP;
        
        v_table_instance_counter := 0;
        v_comma := NULL; 
        add_text(' FROM ');
        from_list_visit(1);
        
        v_table_instance_counter := 0;
        v_auto_variable_number := 0;
        v_variable_number := 0;
        v_and := NULL; 
        add_text(' WHERE ');
        where_list_visit(1, NULL);
        
        IF v_line IS NOT NULL AND v_statement.statement_clob IS NOT NULL THEN
            DBMS_LOB.APPEND(v_statement.statement_clob, v_line);
        END IF;
        
        IF v_statement.statement_clob IS NULL THEN
            v_statement.statement := v_line;
        END IF;
        
        v_query_statement_cache(v_cache_key) := v_statement;
        
        RETURN v_statement;
    
    END;
    
    FUNCTION prepare_query (
        p_query_elements IN t_query_elements,
        p_query_statement IN t_query_statement,
        p_bind IN bind
    )
    RETURN INTEGER IS
    
        v_variable_count PLS_INTEGER;
        v_query_values t_varchars;
        
        v_cursor_id INTEGER;
        v_result INTEGER;
    
    BEGIN
        
        v_variable_count := get_query_variable_count(p_query_elements);
        v_query_values := get_query_values(p_query_elements);
        
        v_cursor_id := DBMS_SQL.OPEN_CURSOR();
        
        IF p_query_statement.statement_clob IS NOT NULL THEN
            DBMS_SQL.PARSE(v_cursor_id, p_query_statement.statement_clob, DBMS_SQL.NATIVE);
        ELSE
            DBMS_SQL.PARSE(v_cursor_id, p_query_statement.statement, DBMS_SQL.NATIVE);
        END IF;
               
        IF p_bind IS NOT NULL THEN 
            FOR v_i IN 1..LEAST(v_variable_count, p_bind.COUNT) LOOP
                DBMS_SQL.BIND_VARIABLE(v_cursor_id, ':' || v_i, p_bind(v_i));
            END LOOP;
        END IF;
        
        FOR v_i IN 1..v_query_values.COUNT LOOP
            DBMS_SQL.BIND_VARIABLE(v_cursor_id, ':v' || v_i, v_query_values(v_i));
        END LOOP;
        
        v_result := DBMS_SQL.EXECUTE(v_cursor_id);
        
        RETURN v_cursor_id;
    
    END;
    
    FUNCTION prepare_query (
        p_query IN VARCHAR2,
        p_bind IN bind,
        p_query_type IN PLS_INTEGER
    )
    RETURN INTEGER IS
    
        v_query_elements t_query_elements;
        v_query_statement t_query_statement;
    
    BEGIN
    
        v_query_elements := parse_query(p_query, p_query_type);
        v_query_statement := get_query_statement(v_query_elements, p_query_type);
    
        RETURN prepare_query (
            v_query_elements,
            v_query_statement,
            p_bind
        );     
    
    END;
    
    PROCEDURE request_properties (
        p_query_elements IN t_query_elements,
        p_bind IN bind,
        p_properties OUT SYS_REFCURSOR
    ) IS
    
        v_cursor_id INTEGER;
        v_query_statement t_query_statement;
            
    BEGIN
    
        IF p_query_elements(p_query_elements.COUNT).type = 'R' THEN
            -- Root requested as a property!
            error$.raise('JDOC-00006');
        END IF;
    
        v_query_statement := get_query_statement(p_query_elements, c_PROPERTY_QUERY);
    
        v_cursor_id := prepare_query(
            p_query_elements, 
            v_query_statement,
            p_bind
        );
        
        p_properties := DBMS_SQL.TO_REFCURSOR(v_cursor_id);
        
    END;
    
    PROCEDURE request_properties (
        p_path IN VARCHAR2,
        p_bind IN bind,
        p_properties OUT SYS_REFCURSOR
    ) IS
    
        v_query_elements t_query_elements;
    
    BEGIN
    
        v_query_elements := parse_query(p_path, c_PROPERTY_QUERY);
    
        request_properties(
            v_query_elements,
            p_bind,  
            p_properties
        );
                
    END;
    
    FUNCTION request_properties (
        p_path IN VARCHAR2,
        p_bind IN bind
    )
    RETURN t_properties PIPELINED IS

        c_properties SYS_REFCURSOR;
        v_properties t_properties;

        c_fetch_limit CONSTANT PLS_INTEGER := 100;

    BEGIN

        request_properties(
            p_path,
            p_bind,
            c_properties
        );

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
    
    FUNCTION set_property (
        p_path IN VARCHAR2,
        p_bind IN bind,
        p_content_parse_events IN json_parser.t_parse_events,
        p_exact IN BOOLEAN := TRUE
    )
    RETURN t_numbers IS

        v_query_elements t_query_elements;

        c_properties SYS_REFCURSOR;
        v_properties t_properties;

        v_existing_ids t_numbers;
        v_parent_ids t_numbers;
        
        v_index NUMBER;
        v_length NUMBER;
        v_gap_values t_json_values;

    BEGIN

        v_query_elements := parse_query(p_path, c_PROPERTY_QUERY);
        
        request_properties(
            v_query_elements, 
            p_bind,
            c_properties
        );

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

        v_index := to_index(v_query_elements(v_query_elements.COUNT).value);
        
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
                    error$.raise('JDOC-00013');
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

        IF v_query_elements(v_query_elements.COUNT).type = 'N' THEN
          
            RETURN create_json
                (v_parent_ids
                ,v_query_elements(v_query_elements.COUNT).value
                ,p_content_parse_events);
            
        ELSE
        
            RETURN create_json
                (v_parent_ids
                ,v_properties(1).property_name
                ,p_content_parse_events
                ,v_query_elements(v_query_elements.COUNT).value);
                
        END IF;

    END;
    
    PROCEDURE request_values (
        p_path IN VARCHAR2,
        p_bind IN bind,
        p_values OUT SYS_REFCURSOR
    ) IS
    
        v_cursor_id INTEGER;
    
    BEGIN
    
        v_cursor_id := prepare_query(p_path, p_bind, c_VALUE_QUERY);
        p_values := DBMS_SQL.TO_REFCURSOR(v_cursor_id);
        
    END;
        
    FUNCTION request_values (
        p_path IN VARCHAR2,
        p_bind IN bind
    )
    RETURN t_values PIPELINED IS
    
        c_values SYS_REFCURSOR;
        
        v_values t_values;
        c_fetch_limit CONSTANT PLS_INTEGER := 1000;
    
    BEGIN

        request_values(p_path, p_bind, c_values);
        
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
        p_path IN VARCHAR2,
        p_bind IN bind
    ) 
    RETURN t_value IS
    
        c_values SYS_REFCURSOR;
        v_values t_values;
    
    BEGIN

        request_values(p_path, p_bind, c_values);
        
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
                    WHERE parent_id = 0
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
                    WHERE parent_id = p_value_row.id
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
                    WHERE parent_id = p_value_row.id
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
        p_bind IN bind,
        p_check_types IN BOOLEAN
    ) IS
        
        c_values SYS_REFCURSOR;
        v_values t_values;
        
        v_value_row json_values%ROWTYPE;
        
        v_event_i PLS_INTEGER;
    
    BEGIN

        request_values(p_path, p_bind, c_values);
        
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
    
    FUNCTION get_length (
        p_array_id IN NUMBER
    )
    RETURN NUMBER IS
    
        v_length NUMBER;
    
    BEGIN
    
        SELECT NVL(MAX(to_index(name)), -1)
        INTO v_length
        FROM json_values
        WHERE parent_id = p_array_id;
        
        RETURN v_length + 1;
    
    END;
    
    FUNCTION push_property (
        p_path IN VARCHAR2,
        p_bind IN bind,
        p_content_parse_events IN json_parser.t_parse_events,
        p_exact IN BOOLEAN := TRUE
    )
    RETURN t_numbers IS
    
        c_values SYS_REFCURSOR;
        v_values t_values;
        
        v_ids t_numbers;
        v_all_ids t_numbers;
    
    BEGIN
    
        request_values(p_path, p_bind, c_values);
    
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
    
    PROCEDURE get_parse_events (
        p_path IN VARCHAR2,
        p_parse_events OUT json_parser.t_parse_events,
        p_bind IN bind := NULL
    ) IS
    
        v_path_value t_value;
        
        TYPE t_chars IS 
            TABLE OF CHAR;
            
        v_json_stack t_chars;
        
        v_last_lvl PLS_INTEGER;
    
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
                 WHERE jsvl.parent_id = parent_jsvl.id
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
        
            p_parse_events.EXTEND(1);
            
            p_parse_events(p_parse_events.COUNT).name := p_name;
            p_parse_events(p_parse_events.COUNT).value := p_value;        
        END;
                
    BEGIN
        
        v_path_value := request_value(p_path, p_bind);
    
        p_parse_events := json_parser.t_parse_events();
        v_json_stack := t_chars();
        v_last_lvl := 0;
    
        FOR v_value IN c_values(v_path_value.id) LOOP
        
            FOR v_i IN v_value.lvl..v_last_lvl LOOP
                  
                IF v_json_stack(v_json_stack.COUNT) IN ('O', 'R') THEN
                    add_event('END_OBJECT');                        
                ELSIF v_json_stack(v_json_stack.COUNT) = 'A' THEN
                    add_event('END_ARRAY');
                END IF;
                    
                v_json_stack.TRIM(1);   
                    
            END LOOP;
            
            IF v_value.name IS NOT NULL 
               AND v_json_stack.COUNT > 0
               AND v_json_stack(v_json_stack.COUNT) IN ('O', 'R') THEN

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
                WHEN 'R' THEN
                    add_event('START_OBJECT');
                WHEN 'A' THEN
                    add_event('START_ARRAY');
                
            END CASE;
            
            v_json_stack.EXTEND(1);
            v_json_stack(v_json_stack.COUNT) := v_value.type;
                
            v_last_lvl := v_value.lvl;
        
        END LOOP;
        
        FOR v_i IN REVERSE 1..v_json_stack.COUNT LOOP
          
             IF v_json_stack(v_i) IN ('O', 'R') THEN
                 add_event('END_OBJECT');    
             ELSIF v_json_stack(v_i) = 'A' THEN
                 add_event('END_ARRAY');
             END IF;
        
        END LOOP;
    
    END;
    
    FUNCTION get_parse_events (
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    )
    RETURN json_parser.t_parse_events PIPELINED IS
        v_parse_events json_parser.t_parse_events;
    BEGIN
    
        get_parse_events(p_path, v_parse_events, p_bind);
        
        FOR v_i IN 1..v_parse_events.COUNT LOOP
            PIPE ROW(v_parse_events(v_i));
        END LOOP;
        
        RETURN;
        
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
                
                DBMS_LOB.APPEND(p_json_clob, p_json);
                    
                p_json := NULL;
                v_length := 0;
                    
            END IF;
            
        
        END LOOP;
        
        IF p_json_clob IS NOT NULL AND p_json IS NOT NULL THEN
            DBMS_LOB.APPEND(p_json_clob, p_json);
            p_json := NULL;
        END IF;
    
    END;
    
BEGIN
    register_messages;
END;
