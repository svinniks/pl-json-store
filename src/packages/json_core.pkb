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
    
    TYPE t_query_cache IS 
        TABLE OF PLS_INTEGER 
        INDEX BY STRING; 
        
    v_query_cache t_query_cache;
    v_anchored_query_cache t_query_cache;
    
    TYPE t_valid_paths IS
        TABLE OF PLS_INTEGER
        INDEX BY PLS_INTEGER;
        
    v_valid_paths t_valid_paths;
    
    TYPE t_variable_numbers IS 
        TABLE OF NUMBER 
        INDEX BY VARCHAR2(30);
            
    v_variable_numbers t_variable_numbers;
    
    PROCEDURE register_messages IS
    BEGIN
        default_message_resolver.register_message('JDC-00001', 'Unexpected character ":1"!');
        default_message_resolver.register_message('JDC-00002', 'Unexpected end of the input!');
        default_message_resolver.register_message('JDC-00003', 'Root can''t be modified!');
        default_message_resolver.register_message('JDC-00004', 'Multiple values found at path :1!');
        default_message_resolver.register_message('JDC-00005', 'Empty path specified!');
        default_message_resolver.register_message('JDC-00006', 'Root requested as a property!');
        default_message_resolver.register_message('JDC-00007', 'No container for property at path :1 could be found!');
        default_message_resolver.register_message('JDC-00008', 'Scalar values and null can''t have properties!');
        default_message_resolver.register_message('JDC-00009', 'Value :1 does not exist!');
        default_message_resolver.register_message('JDC-00010', 'Type conversion error!');
        default_message_resolver.register_message('JDC-00011', 'Property ":1" type mismatch!');
        default_message_resolver.register_message('JDC-00012', 'Value is not an array!');
        default_message_resolver.register_message('JDC-00013', 'Invalid array element index :1!');
        default_message_resolver.register_message('JDC-00014', 'Requested target is not an array!');
        default_message_resolver.register_message('JDC-00015', 'Unexpected :1 in a non-branching query!');
        default_message_resolver.register_message('JDC-00016', 'Duplicate property/alias ":1"!');
        default_message_resolver.register_message('JDC-00017', 'Alias too long!');
        default_message_resolver.register_message('JDC-00018', 'Property name ":1" is too long to be a column name!');
        default_message_resolver.register_message('JDC-00019', 'Alias not specified for a leaf wildcard property!');
        default_message_resolver.register_message('JDC-00020', 'Variable name too long!');
        default_message_resolver.register_message('JDC-00021', 'Value is not an object!');
        default_message_resolver.register_message('JDC-00022', 'Invalid property name!');
        default_message_resolver.register_message('JDC-00023', 'Column alias for a wildcard not specified!');
        default_message_resolver.register_message('JDC-00024', 'Value :1 is pinned!');
        default_message_resolver.register_message('JDC-00025', 'Reserved field reference can''t be optional!');
        default_message_resolver.register_message('JDC-00026', 'Reserved field reference can''t be branched!');
        default_message_resolver.register_message('JDC-00027', 'Reserved field reference can''t have child elements!');
        default_message_resolver.register_message('JDC-00028', 'Reserved field reference can''t be the topmost query element!');
        default_message_resolver.register_message('JDC-00029', 'The topmost query element can''t be optional!');
        default_message_resolver.register_message('JDC-00030', 'Empty JSON specified!');
        default_message_resolver.register_message('JDC-00031', 'Value ID not specified!');
        default_message_resolver.register_message('JDC-00032', 'Invalid cache capacity :1!');
        default_message_resolver.register_message('JDC-00033', 'Value has pinned children!');
        default_message_resolver.register_message('JDC-00034', 'Root can''t be unpinned!');
        default_message_resolver.register_message('JDC-00035', 'Root can''t be deleted!');
        default_message_resolver.register_message('JDC-00036', 'Optional elements are not allowed in path expressions!');
        default_message_resolver.register_message('JDC-00037', 'Branching is not allowed in path expressions!');
        default_message_resolver.register_message('JDC-00038', 'Aliases are not allowed in path expressions!');
        default_message_resolver.register_message('JDC-00039', 'Reserved fields are not allowed in path expressions!');
        default_message_resolver.register_message('JDC-00040', 'Not all variables bound!');
        default_message_resolver.register_message('JDC-00041', 'Property name missing!');
        default_message_resolver.register_message('JDC-00042', 'Can''t apply to an anonymous scalar value!');
        default_message_resolver.register_message('JDC-00043', 'Can''t replace anonymous composite!');
        default_message_resolver.register_message('JDC-00044', 'Can''t replace the root!');
        default_message_resolver.register_message('JDC-00045', 'Applying which alters value ID is not allowed!');
        default_message_resolver.register_message('JDC-00046', 'Path must be either anchored or start with a value ID!');
        default_message_resolver.register_message('JDC-00047', 'Wildcards are not allowed in path expressions!');
        default_message_resolver.register_message('JDC-00048', 'Builder not specified!');
        default_message_resolver.register_message('JDC-00049', 'Property value not specified!');
    END;
    
    -- Do-nothing procedure to initialize error messages from another packages
    
    PROCEDURE touch IS
    BEGIN
        NULL;
    END;
    
    -- Generic functions
    
    FUNCTION to_json_char (
        p_value IN NUMBER
    )
    RETURN VARCHAR2 IS
    
        v_value_string VARCHAR2(50);
    
    BEGIN
    
        v_value_string := TO_CHAR(p_value, 'TM', 'NLS_NUMERIC_CHARACTERS=''.,''');
            
        IF p_value > 0 AND p_value < 1 THEN
            v_value_string := '0' || v_value_string;
        ELSIF p_value < 0 AND p_value > -1 THEN
            v_value_string := REPLACE(v_value_string, '-.', '-0.');
        END IF;
        
        RETURN v_value_string;
    
    END;
    
    FUNCTION to_json_char (
        p_value IN DATE
    )
    RETURN VARCHAR2 IS
    BEGIN
    
        RETURN TO_CHAR(p_value, 'YYYY-MM-DD');
    
    END;
    
    FUNCTION to_json_char (
        p_value IN BOOLEAN
    )
    RETURN VARCHAR2 IS
    BEGIN
    
        IF p_value IS NULL THEN
            RETURN NULL;
        ELSIF p_value THEN
            RETURN 'true';
        ELSE
            RETURN 'false';
        END IF;
    
    END;
    
    -- Simple JSON value parse event generators
    
    FUNCTION string_events (
        p_value IN VARCHAR2
    )
    RETURN t_varchars IS
    BEGIN
        RETURN t_varchars('S' || p_value);
    END;
    
    FUNCTION number_events (
        p_value IN NUMBER
    )
    RETURN t_varchars IS
    BEGIN
    
        IF p_value IS NULL THEN
            RETURN t_varchars('E');
        ELSE
            RETURN t_varchars('N' || to_json_char(p_value));
        END IF;
    
    END;
    
    FUNCTION date_events (
        p_value IN DATE
    )
    RETURN t_varchars IS
    BEGIN
            
        IF p_value IS NULL THEN
            RETURN t_varchars('E');
        ELSE
            RETURN t_varchars('S' || to_json_char(p_value));
        END IF;
    
    END;
    
    FUNCTION boolean_events (
        p_value IN BOOLEAN
    )
    RETURN t_varchars IS
    BEGIN
    
        IF p_value IS NULL THEN
            RETURN t_varchars('E');
        ELSE
            RETURN t_varchars('B' || to_json_char(p_value));
        END IF;
    
    END;
    
    FUNCTION null_events
    RETURN t_varchars IS
    BEGIN
        RETURN t_varchars('E');
    END;
    
    FUNCTION object_events
    RETURN t_varchars IS
    BEGIN
        RETURN t_varchars('{', '}');
    END;
    
    FUNCTION array_events
    RETURN t_varchars IS
    BEGIN
        RETURN t_varchars('[', ']');
    END;
    
    -- Serialization/deserialization methods
    
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
        p_content_parse_events IN t_varchars,
        p_json IN OUT NOCOPY VARCHAR2,
        p_json_clob IN OUT NOCOPY CLOB
    ) IS
        
        v_event VARCHAR2(4000);
        v_event_name CHAR;
        v_event_value VARCHAR2(4000);
    
        v_name VARCHAR2(4000);
        v_length PLS_INTEGER;

        TYPE t_booleans IS 
            TABLE OF BOOLEAN;
            
        v_comma_stack t_booleans;
        
        v_context_stack t_varchars;
        v_element_i_stack t_numbers;
        v_element_i NUMBER;
        
        PROCEDURE append (
            p_string IN VARCHAR2
        ) IS
        BEGIN
        
            IF p_string IS NOT NULL THEN
            
                p_json := p_json || p_string;
                v_length := v_length + LENGTH(p_string);
                
                IF p_json_clob IS NOT NULL AND v_length >= 25000 THEN
                
                    DBMS_LOB.APPEND(p_json_clob, p_json);
                        
                    p_json := NULL;
                    v_length := 0;
                        
                END IF;
                
            END IF;
        
        END;
                
    BEGIN
      
        v_comma_stack := t_booleans(FALSE);
        v_context_stack := t_varchars();
        v_element_i_stack := t_numbers();
        
        v_length := 0;

        FOR v_i IN 1..p_content_parse_events.COUNT LOOP
        
            v_event := p_content_parse_events(v_i);
            v_event_name := SUBSTR(v_event, 1, 1);
        
            CASE v_event_name
              
                WHEN '}' THEN
                
                    append('}'); 
                    
                    v_comma_stack.TRIM(1);
                    v_context_stack.TRIM(1);
                
                WHEN ']' THEN
              
                    append(']'); 
                    
                    v_comma_stack.TRIM(1);
                    v_context_stack.TRIM(1);
                    v_element_i_stack.TRIM(1);
                
                WHEN 'E' THEN
            
                    IF v_comma_stack(v_comma_stack.COUNT) THEN
                        append(',');
                    END IF;
                    
                    append(v_name);
                    append('null');
                
                    v_comma_stack(v_comma_stack.COUNT) := TRUE;
                    v_name := NULL;
            
                WHEN ':' THEN
                
                    v_event_value := SUBSTR(v_event, 2);
                
                    IF v_context_stack(v_context_stack.COUNT) = '{' THEN
                    
                        v_name := v_name || '"' || escape_string(v_event_value) || '":';
                        
                    ELSE
                    
                        v_element_i := v_event_value;
                        
                        FOR v_i IN v_element_i_stack(v_element_i_stack.COUNT) + 1..v_element_i LOOP
                            
                            IF v_comma_stack(v_comma_stack.COUNT) THEN
                                append(',');
                            END IF;
                                
                            append('null');

                            v_comma_stack(v_comma_stack.COUNT) := TRUE;
                        
                        END LOOP;
                        
                        v_element_i_stack(v_element_i_stack.COUNT) := v_element_i + 1;
                    
                    END IF;
                
                ELSE
                
                    IF v_comma_stack(v_comma_stack.COUNT) THEN
                        append(',');
                    END IF;
                        
                    append(v_name);
                        
                    v_name := NULL;
                    v_comma_stack(v_comma_stack.COUNT) := TRUE;
                    
                    IF v_event_name IN ('{', '[') THEN
                        
                        append(v_event_name);
                        
                        v_context_stack.EXTEND(1);
                        v_context_stack(v_context_stack.COUNT) := v_event_name;
                        
                        IF v_event_name = '[' THEN
                            v_element_i_stack.EXTEND(1);
                            v_element_i_stack(v_element_i_stack.COUNT) := 0;
                        END IF;
                                                
                        v_comma_stack.EXTEND(1);
                        v_comma_stack(v_comma_stack.COUNT) := FALSE;
                        
                    ELSE
                        
                        v_event_value := SUBSTR(v_event, 2);
                    
                        CASE v_event_name
                            WHEN 'S' THEN
                                append('"' || escape_string(v_event_value) || '"');
                            WHEN 'N' THEN
                                append(v_event_value);
                            WHEN 'B' THEN
                                append(v_event_value);
                        END CASE;
                        
                    END IF;
                    
            END CASE;
            
        END LOOP;
        
        IF p_json_clob IS NOT NULL AND p_json IS NOT NULL THEN
            DBMS_LOB.APPEND(p_json_clob, p_json);
            p_json := NULL;
        END IF;
    
    END;
    
    -- JSON query API methods
    
    PROCEDURE dump (
        p_query_elements OUT t_query_elements
    ) IS
    BEGIN
        p_query_elements := v_query_elements;
    END;
    
    FUNCTION parse_query (
        p_query IN VARCHAR2,
        p_anchored IN BOOLEAN := FALSE
    ) 
    RETURN PLS_INTEGER IS
    
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
        v_constant_number PLS_INTEGER;
        
        TYPE t_aliases IS 
            TABLE OF BOOLEAN 
            INDEX BY VARCHAR2(30);
        
        v_aliases t_aliases;
        
        v_result PLS_INTEGER;
        
        PROCEDURE init_stack IS
        BEGIN
        
            v_stack := t_stack();
            
            v_stack.EXTEND(1);
            v_stack(1).branching := FALSE;
            
        END;
        
        PROCEDURE push(
            p_type IN CHAR,
            p_value IN VARCHAR2 := NULL
        ) IS
            
            v_element_i PLS_INTEGER;
            v_element t_query_element;
            
            v_top t_stack_node;
            
        BEGIN
        
            v_top := v_stack(v_stack.COUNT);
        
            IF v_stack.COUNT > 1 AND v_query_elements(v_top.element_i).type = 'F' THEN
                -- Reserved field reference can''t have child elements!
                error$.raise('JDC-00027');
            END IF;
        
            v_query_elements.EXTEND(1);
            v_element_i := v_query_elements.COUNT;
            v_result := NVL(v_result, v_element_i);
            
            v_element.type := p_type;
            v_element.optional := FALSE;
            
            IF v_element.type IN (':', '#') THEN
            
                IF NOT v_variable_numbers.EXISTS(p_value) THEN
                    v_variable_numbers(p_value) := v_variable_numbers.COUNT + 1;
                END IF;
                
                v_element.bind_number := v_variable_numbers(p_value);
                
            ELSIF v_element.type IN ('R', 'N', 'I') THEN
                
                v_constant_number := v_constant_number + 1;
                v_element.bind_number := v_constant_number;
            
            END IF;
            
            v_element.value := p_value;
            
            v_query_elements(v_element_i) := v_element;
            
            IF v_top.element_i IS NOT NULL
               AND v_query_elements(v_top.element_i).first_child_i IS NULL 
            THEN
                v_query_elements(v_top.element_i).first_child_i := v_element_i;
            END IF;
        
            IF v_top.last_child_i IS NOT NULL THEN
                v_query_elements(v_top.last_child_i).next_sibling_i := v_element_i;
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
            
                push('R');
            
            ELSIF p_value IN ('_id', '_type', '_key', '_value', '_path') THEN
            
                IF v_stack.COUNT = 1 THEN
                    -- Reserved field reference can''t be the topmost query element!
                    error$.raise('JDC-00028');
                END IF;
            
                push('F', SUBSTR(p_value, 2));
            
            ELSE
            
                push('N', p_value);
            
            END IF;
        
        END;
        
        PROCEDURE push_name_variable (
            p_value IN VARCHAR2
        ) IS
        BEGIN
        
            IF LENGTH(p_value) > 30 THEN
                -- Variable name too long
                error$.raise('JDC-00020');
            END IF;
         
            push(':', UPPER(p_value));
        
        END;
        
        PROCEDURE push_id_variable (
            p_value IN VARCHAR2
        ) IS
        BEGIN
        
            IF LENGTH(p_value) > 30 THEN
                -- Variable name too long
                error$.raise('JDC-00020');
            END IF;
         
            push('#', UPPER(p_value));
        
        END;
        
        PROCEDURE pop_sibling (
            p_character IN CHAR := ','
        ) IS
        BEGIN
        
            LOOP
            
                IF v_stack.COUNT = 0 THEN
                    -- 'Unexpected :1 in a non-branching query!'
                    error$.raise('JDC-00015', p_character);
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
                error$.raise('JDC-00029');
            ELSIF v_query_elements(v_stack(v_stack.COUNT).element_i).TYPE = 'F' THEN
                -- Reserved field reference can''t be optional!
                error$.raise('JDC-00025');
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
                error$.raise('JDC-00026');
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
        
        PROCEDURE lf_element;
        
        PROCEDURE lf_root_branch IS
        BEGIN
        
            IF v_char = '(' THEN
            
                branch;
                v_state := 'lf_root_element';
            
            ELSIF v_char = '[' THEN
            
                v_state := 'lf_array_element';
                
            ELSE
            
                lf_element;
                
            END IF;
        
        END;
        
        PROCEDURE lf_root_element IS
        BEGIN
        
            IF v_char = '[' THEN
                
                v_state := 'lf_array_element';
                
            ELSE
            
                lf_element;
            
            END IF;
        
        END;
        
        PROCEDURE lf_element IS
        BEGIN
        
            IF INSTR('qwertyuioplkjhgfdsazxcvbnm$_', LOWER(v_char)) > 0 THEN
            
                v_value := v_char;
                v_state := 'r_name';
                
            ELSIF v_char = '#' THEN
            
                v_value := NULL;
                v_state := 'lf_anchor';    
                
            ELSIF v_char = '*' THEN
            
                push('W');
                v_state := 'lf_separator';
                
            ELSIF v_char = ':' THEN
            
                v_value := NULL;
                v_state := 'lf_name_variable';
                            
            ELSIF NOT space THEN
            
                -- Unexpected character ":1"!
                error$.raise('JDC-00001', v_char);
                
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
                error$.raise('JDC-00001', v_char);
            
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
                    v_state := 'lf_root_element';
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
                
            ELSIF v_char = '?' THEN
            
                push_name(v_value, TRUE);
                set_optional;
                v_state := 'lf_separator';
                               
            ELSE
            
                -- Unexpected character ":1"!
                error$.raise('JDC-00001', v_char);
                
            END IF;
        
        END;
        
        PROCEDURE lf_comma IS
        BEGIN
        
            IF v_char = ',' THEN
            
                pop_sibling;
                
                IF (v_stack.COUNT = 1) THEN
                    v_state := 'lf_root_element';
                ELSE
                    v_state := 'lf_child';
                END IF;
                
            ELSIF v_char = ')' THEN
            
                pop_branch;
                
            ELSIF NOT space THEN
            
                -- Unexpected character ":1"!
                error$.raise('JDC-00001', v_char);
                
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
                    v_state := 'lf_root_element';
                ELSE
                    v_state := 'lf_child';
                END IF;
                
                
            ELSIF v_char = '(' THEN
            
                branch;
                v_state := 'lf_child';  
                
            ELSIF LOWER(v_char) = 'a' THEN
            
                v_state := 'lf_as_s';
                
            ELSIF v_char = '?' THEN
            
                IF optional THEN
                    -- Unexpected character ":1"!
                    error$.raise('JDC-00001', v_char);
                END IF; 
                
                set_optional;
                
            ELSE
            
                lf_child;
                
            END IF;
        
        END;
        
        PROCEDURE lf_anchor IS
        BEGIN
        
            IF INSTR('1234567890', v_char) > 0 THEN
            
                v_value := v_char;
                v_state := 'r_anchor_id';
                
            ELSIF INSTR('qwertyuioplkjhgfdsazxcvbnm', LOWER(v_char)) > 0 THEN
            
                v_value := v_char;
                v_state := 'r_id_variable';
                
            ELSIF NOT space THEN
            
                -- Unexpected character ":1"!
                error$.raise('JDC-00001', v_char);
                
            END IF;
        
        END;
        
        PROCEDURE r_anchor_id IS
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
                    v_state := 'lf_root_element';
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
                
            ELSIF v_char = '?' THEN
            
                push('I', v_value);
                set_optional;
                v_state := 'lf_separator';
                
            ELSE
            
                -- Unexpected character ":1"!
                error$.raise('JDC-00001', v_char);
                
            END IF;
                    
        END;
        
        PROCEDURE r_id_variable IS
        BEGIN
        
            IF INSTR('qwertyuioplkjhgfdsazxcvbnm1234567890_$#', LOWER(v_char)) > 0 THEN
            
                v_value := v_value || v_char;
                
            ELSIF v_char = '.' THEN
            
                push_id_variable(v_value);
                v_state := 'lf_element';
                
            ELSIF v_char = ',' THEN
            
                push_id_variable(v_value);
                pop_sibling;
                
                IF (v_stack.COUNT = 1) THEN
                    v_state := 'lf_root_element';
                ELSE
                    v_state := 'lf_child';
                END IF;
                
            ELSIF v_char = ')' THEN
            
                push_id_variable(v_value);
                pop_branch;
                v_state := 'lf_comma';
                
            ELSIF v_char = '[' THEN
            
                push_id_variable(v_value);
                v_state := 'lf_array_element'; 
                
            ELSIF v_char = '(' THEN
            
                push_id_variable(v_value);
                branch;
                v_state := 'lf_child'; 
                
            ELSIF space THEN
            
                push_id_variable(v_value);
                v_state := 'lf_separator';
                
            ELSIF v_char = '?' THEN
            
                push_id_variable(v_value);
                set_optional;
                v_state := 'lf_separator';
                
            ELSE
            
                -- Unexpected character ":1"!
                error$.raise('JDC-00001', v_char);
                
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
                error$.raise('JDC-00001', v_char);
            
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
                error$.raise('JDC-00001', v_char);
            
            END IF;    
        
        END;
        
        PROCEDURE lf_array_element_end IS
        BEGIN
        
            IF v_char = ']' THEN
            
                v_state := 'lf_separator';
                
            ELSIF NOT space THEN
           
                -- Unexpected character ":1"!
                error$.raise('JDC-00001', v_char);
            
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
                error$.raise('JDC-00001', v_char);
            
            END IF;
            
        
        END;
        
        PROCEDURE lf_space_after_as IS
        BEGIN
        
            IF space THEN
                
                v_state := 'lf_alias';
                
            ELSE
            
                -- Unexpected character ":1"!
                error$.raise('JDC-00001', v_char);
            
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
                error$.raise('JDC-00001', v_char);
            
            END IF;
        
        END;
        
        PROCEDURE r_alias IS
        BEGIN
        
            IF INSTR('qwertyuioplkjhgfdsazxcvbnm1234567890_$', LOWER(v_char)) > 0 THEN
            
                IF LENGTH(v_value) = 30 THEN
            
                    -- Alias too long!
                    error$.raise('JDC-00017');
                    
                END IF;
            
                v_value := v_value || v_char;

            ELSIF v_char = ',' THEN
            
                set_alias(UPPER(v_value));
                pop_sibling;
                
                IF (v_stack.COUNT = 1) THEN
                    v_state := 'lf_root_element';
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
                error$.raise('JDC-00001', v_char);
                
            END IF;
                
        
        END;
        
        PROCEDURE r_quoted_alias IS
        BEGIN
        
            IF v_char = '"' THEN
            
                set_alias(v_value);
                v_state := 'lf_comma';
                
            ELSIF LENGTH(v_value) = 30 THEN
            
                -- Alias too long!
                error$.raise('JDC-00017');
                
            ELSE
            
                v_value := v_value || v_char;
            
            END IF;
        
        END;
        
        PROCEDURE lf_name_variable IS
        BEGIN
        
            IF INSTR('qwertyuioplkjhgfdsazxcvbnm', LOWER(v_char)) > 0 THEN
            
                v_value := v_char;
                v_state := 'r_name_variable';
                
            ELSE
            
                -- Unexpected character ":1"!
                error$.raise('JDC-00001', v_char);
            
            END IF;
        
        END;
        
        PROCEDURE r_name_variable IS
        BEGIN
        
            IF INSTR('qwertyuioplkjhgfdsazxcvbnm1234567890_$#', LOWER(v_char)) > 0 THEN
            
                v_value := v_value || v_char;
                
            ELSIF v_char = '.' THEN
            
                push_name_variable(v_value);
                v_state := 'lf_element';
                
            ELSIF v_char = ',' THEN
            
                push_name_variable(v_value);
                pop_sibling;
                
                IF (v_stack.COUNT = 1) THEN
                    v_state := 'lf_root_element';
                ELSE
                    v_state := 'lf_child';
                END IF;
                
            ELSIF v_char = ')' THEN
            
                push_name_variable(v_value);
                pop_branch;
                v_state := 'lf_comma';
                
            ELSIF v_char = '[' THEN
            
                push_name_variable(v_value);
                v_state := 'lf_array_element'; 
                
            ELSIF v_char = '(' THEN
            
                push_name_variable(v_value);
                branch;
                v_state := 'lf_child'; 
                
            ELSIF space THEN
            
                push_name_variable(v_value);
                v_state := 'lf_separator';
                
            ELSIF v_char = '?' THEN
            
                push_name_variable(v_value);
                set_optional;
                v_state := 'lf_separator';
                
            ELSE
            
                -- Unexpected character ":1"!
                error$.raise('JDC-00001', v_char);
                
            END IF;
        
        END;
        
        PROCEDURE lf_array_variable IS
        BEGIN
        
            IF INSTR('qwertyuioplkjhgfdsazxcvbnm', LOWER(v_char)) > 0 THEN
            
                v_value := v_char;
                v_state := 'r_array_variable';
                
            ELSE
            
                -- Unexpected character ":1"!
                error$.raise('JDC-00001', v_char);
            
            END IF;
        
        END;
        
        PROCEDURE r_array_variable IS
        BEGIN
        
            IF INSTR('qwertyuioplkjhgfdsazxcvbnm1234567890_$#', LOWER(v_char)) > 0 THEN
            
                v_value := v_value || v_char;
                
            ELSIF v_char = ']' THEN
            
                push_name_variable(v_value);
                v_state := 'lf_separator';
            
            ELSIF space THEN
            
                push_name_variable(v_value);
                v_state := 'lf_array_element_end';
                
            ELSE
            
                -- Unexpected character ":1"!
                error$.raise('JDC-00001', v_char);
            
            END IF;    
        
        END;
        
    BEGIN
    
        IF p_anchored AND v_anchored_query_cache.EXISTS(p_query) THEN
            RETURN v_anchored_query_cache(p_query);
        ELSIF NOT p_anchored AND v_query_cache.EXISTS(p_query) THEN
            RETURN v_query_cache(p_query);
        END IF;
    
        init_stack;
        
        v_variable_numbers.DELETE;
        v_constant_number := 0;
        
        IF p_anchored THEN
            push('A');
        END IF;
        
        v_state := 'lf_root_branch';
        
        FOR v_i IN 1..NVL(LENGTH(p_query), 0) LOOP
        
            v_char := SUBSTR(p_query, v_i, 1);
            
            CASE v_state
                WHEN 'lf_root_branch' THEN lf_root_branch;
                WHEN 'lf_root_element' THEN lf_root_element;
                WHEN 'lf_element' THEN lf_element;
                WHEN 'lf_child' THEN lf_child;
                WHEN 'r_name' THEN r_name;
                WHEN 'lf_comma' THEN lf_comma;
                WHEN 'lf_separator' THEN lf_separator;
                WHEN 'lf_anchor' THEN lf_anchor;
                WHEN 'r_anchor_id' THEN r_anchor_id;
                WHEN 'r_id_variable' THEN r_id_variable;
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
                WHEN 'lf_name_variable' THEN lf_name_variable;
                WHEN 'r_name_variable' THEN r_name_variable;
                WHEN 'lf_array_variable' THEN lf_array_variable;
                WHEN 'r_array_variable' THEN r_array_variable;
            END CASE;
        
        END LOOP;
        
        IF v_state = 'r_name' THEN
            push_name(v_value, TRUE);
        ELSIF v_state = 'r_alias' THEN
            set_alias(UPPER(v_value));
        ELSIF v_state = 'r_anchor_id' THEN
            push('I', v_value);
        ELSIF v_state = 'r_id_variable' THEN
            push_id_variable(v_value);
        ELSIF v_state = 'r_name_variable' THEN
            push_name_variable(v_value);
        ELSIF v_state NOT IN ('lf_separator', 'lf_comma') THEN 
            -- Unexpected end of the input!
            error$.raise('JDC-00002');
        END IF;
        
        IF branching THEN
            -- Unexpected end of the input!
            error$.raise('JDC-00002');
        END IF;
    
        IF p_anchored THEN
            v_anchored_query_cache(p_query) := v_result;
        ELSE
            v_query_cache(p_query) := v_result;
        END IF;
        
        RETURN v_result;
    
    END;
    
    FUNCTION parse_path (
        p_path IN VARCHAR2,
        p_anchored IN BOOLEAN := FALSE
    )
    RETURN PLS_INTEGER IS
    
        v_path_element_i PLS_INTEGER;
                
        PROCEDURE validate_element (
            p_i IN PLS_INTEGER
        ) IS
            v_element t_query_element;
        BEGIN
        
            v_element := v_query_elements(p_i);
        
            IF v_element.optional THEN
                -- Optional elements are not allowed in path expressions!
                error$.raise('JDC-00036');
            ELSIF v_element.next_sibling_i IS NOT NULL THEN
                -- Branching is not allowed in path expressions!
                error$.raise('JDC-00037');
            ELSIF v_element.alias IS NOT NULL THEN
                -- Aliases are not allowed in path expressions!
                error$.raise('JDC-00038');
            ELSIF v_element.type = 'F' THEN
                -- Reserved fields are not allowed in path expressions!
                error$.raise('JDC-00039');
            ELSIF v_element.type = 'W' THEN
                -- Wildcards are not allowed in path expressions!
                error$.raise('JDC-00047');
            END IF;
            
            IF v_element.first_child_i IS NOT NULL THEN
                validate_element(v_element.first_child_i);
            END IF;
        
        END;
    
    BEGIN
    
        
        IF p_anchored AND v_anchored_query_cache.EXISTS(p_path) THEN
            v_path_element_i := v_anchored_query_cache(p_path);
        ELSIF NOT p_anchored AND v_query_cache.EXISTS(p_path) THEN
            v_path_element_i := v_query_cache(p_path);
        ELSE
            v_path_element_i := parse_query(p_path, p_anchored);
        END IF;
        
        
        
        --v_path_element_i := parse_query(p_path, p_anchored);
            
        IF NOT v_valid_paths.EXISTS(v_path_element_i) THEN
        
            IF v_query_elements(v_path_element_i).type NOT IN ('A', 'R', 'I', '#') THEN
                 -- Path must be either anchored or start with a value ID!
                 error$.raise('JDC-00046');
            END IF;
            
            validate_element(v_path_element_i);
            v_valid_paths(v_path_element_i) := NULL;
            
        END IF;
        
        RETURN v_path_element_i;
    
    END;
    
    FUNCTION get_query_column_names (
        p_query_element_i IN PLS_INTEGER
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
                error$.raise('JDC-00018', p_name);
            END IF;
            
            IF v_unique_column_names.EXISTS(p_name) THEN
                -- Duplicate property/alias :1!
                error$.raise('JDC-00016', p_name);
            END IF;
            
            v_column_names.EXTEND(1);
            v_column_names(v_column_names.COUNT) := p_name;
            
            v_unique_column_names(p_name) := TRUE;
        
        END;
        
        PROCEDURE visit_element (
            p_i IN PLS_INTEGER
        ) IS
            v_element t_query_element;
        BEGIN
            
            v_element := v_query_elements(p_i);
        
            IF v_element.first_child_i IS NOT NULL THEN
                visit_element(v_element.first_child_i);
            ELSE
            
                IF v_element.alias IS NOT NULL THEN
                    add_column_name(v_element.alias);
                ELSIF v_element.type = 'W' THEN
                    -- Column alias for a wildcard not specified!
                    error$.raise('JDC-00023');
                ELSE
                    add_column_name(v_element.value);
                END IF; 
            
            END IF;
            
            IF v_element.next_sibling_i IS NOT NULL THEN
                visit_element(v_element.next_sibling_i);
            END IF;
        
        END;
    
    BEGIN
    
        v_column_names := t_varchars();
        
        visit_element(p_query_element_i);
        
        RETURN v_column_names;
    
    END;
    
BEGIN
    register_messages;    
END;    