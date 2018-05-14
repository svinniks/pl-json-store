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
    
    v_value_cache_capacity PLS_INTEGER := c_VALUE_CACHE_DEFAULT_CAPACITY;
    
    v_json_value_cache t_json_value_cache;
    
    v_value_cache_entries t_value_cache_entries;
    v_value_cache_head_id VARCHAR2(30);
    v_value_cache_tail_id VARCHAR2(30);
    
    TYPE t_integer_indexed_numbers IS 
        TABLE OF NUMBER 
        INDEX BY PLS_INTEGER;
    
    TYPE t_query_element_cache IS 
        TABLE OF t_query_elements 
        INDEX BY VARCHAR2(32000); 
        
    v_query_element_cache t_query_element_cache;
    
    TYPE t_varchar_indexed_booleans IS
        TABLE OF BOOLEAN
        INDEX BY VARCHAR2(32000);
        
    v_valid_paths t_varchar_indexed_booleans;
        
    TYPE t_query_statement_cache IS
        TABLE OF t_query_statement
        INDEX BY VARCHAR2(32000);
        
    v_query_statement_cache t_query_statement_cache;
    
    c_DATE_FORMAT CONSTANT VARCHAR2(4000) := 'FXYYYY-MM-DD';
    
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
        default_message_resolver.register_message('JDOC-00010', 'Type conversion error!');
        default_message_resolver.register_message('JDOC-00011', 'Property ":1" type mismatch!');
        default_message_resolver.register_message('JDOC-00012', 'Value is not an array!');
        default_message_resolver.register_message('JDOC-00013', 'Invalid array element index :1!');
        default_message_resolver.register_message('JDOC-00014', 'Requested target is not an array!');
        default_message_resolver.register_message('JDOC-00015', 'Unexpected :1 in a non-branching query!');
        default_message_resolver.register_message('JDOC-00016', 'Duplicate property/alias ":1"!');
        default_message_resolver.register_message('JDOC-00017', 'Alias too long!');
        default_message_resolver.register_message('JDOC-00018', 'Property name ":1" is too long to be a column name!');
        default_message_resolver.register_message('JDOC-00019', 'Alias not specified for a leaf wildcard property!');
        default_message_resolver.register_message('JDOC-00020', 'Variable name too long!');
        default_message_resolver.register_message('JDOC-00021', 'Value is not an object!');
        default_message_resolver.register_message('JDOC-00022', 'Invalid property name!');
        default_message_resolver.register_message('JDOC-00023', 'Column alias for a wildcard not specified!');
        default_message_resolver.register_message('JDOC-00024', 'Value :1 is pinned!');
        default_message_resolver.register_message('JDOC-00025', 'Reserved field reference can''t be optional!');
        default_message_resolver.register_message('JDOC-00026', 'Reserved field reference can''t be branched!');
        default_message_resolver.register_message('JDOC-00027', 'Reserved field reference can''t have child elements!');
        default_message_resolver.register_message('JDOC-00028', 'Reserved field reference can''t be the topmost query element!');
        default_message_resolver.register_message('JDOC-00029', 'The topmost query element can''t be optional!');
        default_message_resolver.register_message('JDOC-00030', 'Empty JSON specified!');
        default_message_resolver.register_message('JDOC-00031', 'Value ID not specified!');
        default_message_resolver.register_message('JDOC-00032', 'Invalid cache capacity :1!');
        default_message_resolver.register_message('JDOC-00033', 'Value has pinned children!');
        default_message_resolver.register_message('JDOC-00034', 'Root can''t be unpinned!');
        default_message_resolver.register_message('JDOC-00035', 'Root can''t be deleted!');
        default_message_resolver.register_message('JDOC-00036', 'Optional elements are not allowed in path expressions!');
        default_message_resolver.register_message('JDOC-00037', 'Branching is not allowed in path expressions!');
        default_message_resolver.register_message('JDOC-00038', 'Aliases are not allowed in path expressions!');
        default_message_resolver.register_message('JDOC-00039', 'Reserved fields are not allowed in path expressions!');
        default_message_resolver.register_message('JDOC-00040', 'Not all variables bound!');
        default_message_resolver.register_message('JDOC-00041', 'Property name missing!');
    END;
    
    /* Some usefull functions */
    
    FUNCTION iif (
         p_condition IN BOOLEAN,
         p_value_if_true IN VARCHAR2,
         p_value_if_false IN VARCHAR2 := NULL
    ) 
    RETURN VARCHAR2 IS
    BEGIN
        IF p_condition THEN
            RETURN p_value_if_true;
        ELSE
            RETURN p_value_if_false;
        END IF;
    END;
    
    /* Generic JSON value parse event constant functions */
    
    FUNCTION string_events (
        p_value IN VARCHAR2
    )
    RETURN json_parser.t_parse_events IS
    
        v_parse_event json_parser.t_parse_event;
    
    BEGIN
            
        v_parse_event.name := 'STRING';
        v_parse_event.value := p_value;
        
        RETURN json_parser.t_parse_events(v_parse_event);
    
    END;
    
    FUNCTION date_events (
        p_value IN DATE
    )
    RETURN json_parser.t_parse_events IS
    
        v_parse_event json_parser.t_parse_event;
    
    BEGIN
            
        IF p_value IS NULL THEN
            v_parse_event.name := 'NULL';
        ELSE
            v_parse_event.name := 'STRING';
            v_parse_event.value := TO_CHAR(p_value, 'YYYY-MM-DD');
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
    
    /* Value cache management methods */
    
    PROCEDURE reset_value_cache IS
    BEGIN
    
        v_json_value_cache.DELETE;
        v_value_cache_entries.DELETE;

        v_value_cache_head_id := NULL;
        v_value_cache_tail_id := NULL;
        
    END;
    
    FUNCTION get_cached_values
    RETURN t_json_values PIPELINED IS
    
        v_id VARCHAR2(30);
        
    BEGIN
    
        v_id := v_value_cache_head_id;
        
        WHILE v_id IS NOT NULL LOOP
            PIPE ROW(v_json_value_cache(v_id));
            v_id := v_value_cache_entries(v_id).next_entry_id;
        END LOOP;
    
        RETURN;
    
    END;
    
    PROCEDURE unlink_value_cache_entry (
        p_id IN VARCHAR2,
        p_delete_entry IN BOOLEAN := TRUE
    ) IS

        v_entry_id VARCHAR2(30);    
        v_prev_entry_id VARCHAR2(30);
        v_next_entry_id VARCHAR2(30);
    
    BEGIN

        v_entry_id := p_id;    
        v_prev_entry_id := v_value_cache_entries(v_entry_id).prev_entry_id;
        v_next_entry_id := v_value_cache_entries(v_entry_id).next_entry_id;
    
        IF v_prev_entry_id IS NOT NULL THEN
            v_value_cache_entries(v_prev_entry_id).next_entry_id := v_next_entry_id;
        ELSE
            v_value_cache_head_id := v_next_entry_id;
        END IF;
        
        IF v_next_entry_id IS NOT NULL THEN
            v_value_cache_entries(v_next_entry_id).prev_entry_id := v_prev_entry_id;
        ELSE
            v_value_cache_tail_id := v_prev_entry_id;
        END IF;
        
        IF p_delete_entry THEN
            v_value_cache_entries.DELETE(v_entry_id);
        END IF;
    
    END;
    
    PROCEDURE set_value_cache_capacity (
        p_capacity IN PLS_INTEGER
    ) IS
    BEGIN
    
        IF p_capacity IS NULL OR p_capacity < 1 THEN
            -- Invalid cache capacity :1!
            error$.raise('JDOC-00032', NVL(TO_CHAR(p_capacity), 'NULL'));
        END IF;
        
        FOR v_i IN p_capacity + 1..v_json_value_cache.COUNT LOOP
            v_json_value_cache.DELETE(v_value_cache_tail_id);
            unlink_value_cache_entry(v_value_cache_tail_id);
        END LOOP;
        
        v_value_cache_capacity := p_capacity;
    
    END;
    
    PROCEDURE link_value_cache_entry (
        p_id IN VARCHAR2
    ) IS
    BEGIN
    
        v_value_cache_entries(p_id).prev_entry_id := NULL;
        v_value_cache_entries(p_id).next_entry_id := v_value_cache_head_id;
        
        IF v_value_cache_head_id IS NOT NULL THEN
            v_value_cache_entries(v_value_cache_head_id).prev_entry_id := p_id;
        END IF;
        
        v_value_cache_head_id := p_id;
        
        IF v_value_cache_tail_id IS NULL THEN
            v_value_cache_tail_id := p_id;
        END IF;
    
    END;
    
    PROCEDURE cache_value (
        p_value IN t_value
    ) IS 
    
        v_entry_id VARCHAR2(30);
    
    BEGIN
    
        v_entry_id := p_value.id;
        
        IF v_json_value_cache.EXISTS(v_entry_id) THEN
        
            IF v_entry_id != v_value_cache_head_id THEN
                unlink_value_cache_entry(v_entry_id, FALSE);
                link_value_cache_entry(v_entry_id);
            END IF;
            
        ELSE
        
            v_json_value_cache(v_entry_id) := p_value;
            
            IF v_json_value_cache.COUNT > v_value_cache_capacity THEN
                v_json_value_cache.DELETE(v_value_cache_tail_id);
                unlink_value_cache_entry(v_value_cache_tail_id);
            END IF;
                
            link_value_cache_entry(v_entry_id);
            
        END IF;
    
    END;
    
    FUNCTION get_value (
        p_id IN NUMBER
    )
    RETURN t_value IS
    
        v_entry_id VARCHAR2(30);
        v_value t_value;
        
    BEGIN
    
        IF p_id IS NULL THEN
            -- Value ID not specified!
            error$.raise('JDOC-00031');
        END IF;
    
        v_entry_id := p_id;
    
        IF v_json_value_cache.EXISTS(v_entry_id) THEN
        
            IF v_entry_id != v_value_cache_head_id THEN
                unlink_value_cache_entry(v_entry_id, FALSE);
                link_value_cache_entry(v_entry_id);
            END IF;
            
            RETURN v_json_value_cache(v_entry_id);
        
        ELSE
        
            BEGIN
            
                SELECT *
                INTO v_value
                FROM json_values
                WHERE id = p_id;
            
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    -- Value :1 does not exist!
                    error$.raise('JDOC-00009', '#' || v_entry_id);
            END;
        
            v_json_value_cache(v_entry_id) := v_value;
        
            IF v_json_value_cache.COUNT > v_value_cache_capacity THEN
                v_json_value_cache.DELETE(v_value_cache_tail_id);
                unlink_value_cache_entry(v_value_cache_tail_id);
            END IF;
                
            link_value_cache_entry(v_entry_id);
            
            RETURN v_value;
        
        END IF;
    
    END;
    
    PROCEDURE pin_cached_value (
        p_value_id IN NUMBER
    ) IS
    
        v_entry_id VARCHAR2(30);
    
    BEGIN
    
        v_entry_id := p_value_id;
    
        IF v_json_value_cache.EXISTS(v_entry_id) THEN
            v_json_value_cache(v_entry_id).locked := 'T';
        END IF;
    
    END;
    
    PROCEDURE unpin_cached_value (
        p_value_id IN NUMBER
    ) IS
    
        v_entry_id VARCHAR2(30);
    
    BEGIN
    
        v_entry_id := p_value_id;
    
        IF v_json_value_cache.EXISTS(v_entry_id) THEN
            v_json_value_cache(v_entry_id).locked := NULL;
        END IF;
    
    END;
    
    /* JSON query API methods */
    
    FUNCTION parse_query (
        p_query IN VARCHAR2
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
            
                push('I', 0);
            
            ELSIF p_value IN ('_id', '_key', '_value', '_path') THEN
            
                IF v_stack.COUNT = 1 THEN
                    -- Reserved field reference can''t be the topmost query element!
                    error$.raise('JDOC-00028');
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
                error$.raise('JDOC-00020');
            END IF;
         
            push('V', UPPER(p_value));
        
        END;
        
        PROCEDURE push_anchor_variable (
            p_value IN VARCHAR2
        ) IS
        BEGIN
        
            IF LENGTH(p_value) > 30 THEN
                -- Variable name too long
                error$.raise('JDOC-00020');
            END IF;
         
            push('A', UPPER(p_value));
        
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
                error$.raise('JDOC-00001', v_char);
                
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
                error$.raise('JDOC-00001', v_char);
                
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
                    error$.raise('JDOC-00001', v_char);
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
                v_state := 'r_anchor_variable';
                
            ELSIF NOT space THEN
            
                -- Unexpected character ":1"!
                error$.raise('JDOC-00001', v_char);
                
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
                error$.raise('JDOC-00001', v_char);
                
            END IF;
                    
        END;
        
        PROCEDURE r_anchor_variable IS
        BEGIN
        
            IF INSTR('qwertyuioplkjhgfdsazxcvbnm1234567890_$#', LOWER(v_char)) > 0 THEN
            
                v_value := v_value || v_char;
                
            ELSIF v_char = '.' THEN
            
                push_anchor_variable(v_value);
                v_state := 'lf_element';
                
            ELSIF v_char = ',' THEN
            
                push_anchor_variable(v_value);
                pop_sibling;
                
                IF (v_stack.COUNT = 1) THEN
                    v_state := 'lf_root_element';
                ELSE
                    v_state := 'lf_child';
                END IF;
                
            ELSIF v_char = ')' THEN
            
                push_anchor_variable(v_value);
                pop_branch;
                v_state := 'lf_comma';
                
            ELSIF v_char = '[' THEN
            
                push_anchor_variable(v_value);
                v_state := 'lf_array_element'; 
                
            ELSIF v_char = '(' THEN
            
                push_anchor_variable(v_value);
                branch;
                v_state := 'lf_child'; 
                
            ELSIF space THEN
            
                push_anchor_variable(v_value);
                v_state := 'lf_separator';
                
            ELSIF v_char = '?' THEN
            
                push_anchor_variable(v_value);
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
        
        PROCEDURE lf_name_variable IS
        BEGIN
        
            IF INSTR('qwertyuioplkjhgfdsazxcvbnm', LOWER(v_char)) > 0 THEN
            
                v_value := v_char;
                v_state := 'r_name_variable';
                
            ELSE
            
                -- Unexpected character ":1"!
                error$.raise('JDOC-00001', v_char);
            
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
            
                push_name_variable(v_value);
                v_state := 'lf_separator';
            
            ELSIF space THEN
            
                push_name_variable(v_value);
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
                WHEN 'r_anchor_variable' THEN r_anchor_variable;
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
        ELSIF v_state = 'r_anchor_variable' THEN
            push_anchor_variable(v_value);
        ELSIF v_state = 'r_name_variable' THEN
            push_name_variable(v_value);
        ELSIF v_state NOT IN ('lf_separator', 'lf_comma') THEN 
            -- Unexpected end of the input!
            error$.raise('JDOC-00002');
        END IF;
        
        IF branching THEN
            -- Unexpected end of the input!
            error$.raise('JDOC-00002');
        END IF;
    
        v_query_element_cache(p_query) := v_query_elements;
        
        RETURN v_query_elements;
    
    END;
    
    FUNCTION parse_path (
        p_path IN VARCHAR2
    )
    RETURN t_query_elements IS
    
        v_path_elements t_query_elements;
                
        PROCEDURE validate_element (
            p_i IN PLS_INTEGER
        ) IS
        BEGIN
        
            IF v_path_elements(p_i).optional THEN
                -- Optional elements are not allowed in path expressions!
                error$.raise('JDOC-00036');
            ELSIF v_path_elements(p_i).next_sibling_i IS NOT NULL THEN
                -- Branching is not allowed in path expressions!
                error$.raise('JDOC-00037');
            ELSIF v_path_elements(p_i).alias IS NOT NULL THEN
                -- Aliases are not allowed in path expressions!
                error$.raise('JDOC-00038');
            ELSIF v_path_elements(p_i).type = 'F' THEN
                -- Reserved fields are not allowed in path expressions!
                error$.raise('JDOC-00039');
            END IF;
            
            IF v_path_elements(p_i).first_child_i IS NOT NULL THEN
                validate_element(v_path_elements(p_i).first_child_i);
            END IF;
        
        END;
    
    BEGIN
    
        v_path_elements := parse_query(p_path);
        
        IF NOT v_valid_paths.EXISTS(p_path) THEN
            
            validate_element(1);
        
            v_valid_paths(p_path) := TRUE;
        
        END IF;
        
        RETURN v_path_elements;
    
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
    
    FUNCTION get_query_bind_numbers (
        p_query_elements IN t_query_elements
    )
    RETURN t_numbers IS
    
        TYPE t_variable_numbers IS 
            TABLE OF NUMBER 
            INDEX BY VARCHAR2(30);
            
        v_variable_numbers t_variable_numbers;
        v_bind_numbers t_numbers;
        
        PROCEDURE visit_element (
            p_i IN PLS_INTEGER
        ) IS
        BEGIN
        
            IF p_query_elements(p_i).type IN ('V', 'A') THEN
                
                IF NOT v_variable_numbers.EXISTS(p_query_elements(p_i).value) THEN
                    v_variable_numbers(p_query_elements(p_i).value) := v_variable_numbers.COUNT + 1;
                END IF;
                
                v_bind_numbers.EXTEND(1);
                v_bind_numbers(v_bind_numbers.COUNT) := v_variable_numbers(p_query_elements(p_i).value);
            
            END IF;
        
            IF p_query_elements(p_i).first_child_i IS NOT NULL THEN
                visit_element(p_query_elements(p_i).first_child_i);
            END IF;
            
            IF p_query_elements(p_i).next_sibling_i IS NOT NULL THEN
                visit_element(p_query_elements(p_i).next_sibling_i);
            END IF;
        
        END;
        
    BEGIN
    
        v_bind_numbers := t_numbers();
        visit_element(1);
        
        RETURN v_bind_numbers;
    
    END;    
    
    FUNCTION get_query_constants (
        p_query_elements IN t_query_elements
    )
    RETURN t_varchars IS
    
        v_constants t_varchars;
    
        PROCEDURE visit_element (
            p_i IN PLS_INTEGER
        ) IS
        BEGIN
        
            IF p_query_elements(p_i).type IN ('N', 'I') THEN
                v_constants.EXTEND(1);
                v_constants(v_constants.COUNT) := p_query_elements(p_i).value;
            END IF;
        
            IF p_query_elements(p_i).first_child_i IS NOT NULL THEN
                visit_element(p_query_elements(p_i).first_child_i); 
            END IF;
            
            IF p_query_elements(p_i).next_sibling_i IS NOT NULL THEN
                visit_element(p_query_elements(p_i).next_sibling_i);
            END IF;
        
        END;
    
    BEGIN
    
        v_constants := t_varchars();
        
        visit_element(1);
        
        RETURN v_constants;
    
    END;
    
    FUNCTION get_query_statement (
        p_query_elements IN t_query_elements,
        p_query_type IN CHAR,
        p_column_count IN PLS_INTEGER := NULL
    )
    RETURN t_query_statement IS
    
        v_cache_key VARCHAR2(32000);
    
        v_line VARCHAR2(32000);
        
        v_constant_number PLS_INTEGER;
        v_variable_number PLS_INTEGER;
        
        v_table_instance_counter PLS_INTEGER;
        v_comma CHAR;
        v_and VARCHAR2(10);
        v_column_count PLS_INTEGER;
        
        TYPE t_variable_numbers IS 
            TABLE OF PLS_INTEGER
            INDEX BY VARCHAR2(30);
        
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
            
            IF p_query_elements(p_i).type IN ('I', 'N') THEN
                v_constant_number := v_constant_number + 1;
            ELSIF p_query_elements(p_i).type IN ('A', 'V') THEN
                v_variable_number := v_variable_number + 1;
            END IF;
                    
            IF p_query_elements(p_i).first_child_i IS NOT NULL THEN
            
                select_list_visit(p_query_elements(p_i).first_child_i, v_table_instance);
                
            ELSE
            
                v_column_count := v_column_count + 1;
            
                IF p_query_type = c_TABLE_QUERY AND v_column_count <= NVL(p_column_count, v_column_count) THEN
                
                    IF p_query_elements(p_i).type = 'F' THEN
                    
                        add_text(
                            CASE p_query_elements(p_i).value 
                                WHEN 'key' THEN 
                                    v_comma || 'j' || v_table_instance || '.name' 
                                WHEN 'path' THEN
                                    v_comma || 'NULL'
                                ELSE 
                                    v_comma || 'j' || v_table_instance || '.' || p_query_elements(p_i).value 
                            END
                        );
                        
                    ELSE
                    
                        add_text(v_comma || 'j' || v_table_instance || '.value');
                        
                    END IF;
                    
                ELSIF p_query_type = c_VALUE_QUERY THEN
                
                    add_text(v_comma || 'j' || v_table_instance || '.*');
                    
                ELSIF p_query_type = c_PROPERTY_QUERY THEN
                
                    add_text(v_comma || 'j' || p_parent_table_instance || '.id,j' || p_parent_table_instance || '.type,j' || v_table_instance || '.id,j' || v_table_instance || '.type,:');
                    
                    IF p_query_elements(p_i).type = 'N' THEN
                        add_text('const' || v_constant_number);
                    ELSE
                        add_text('var' || v_variable_number);
                    END IF;
                    
                    add_text(' AS name,j' || v_table_instance || '.locked');
                    
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
                    
                    IF p_query_elements(p_i).optional 
                       OR (p_query_type = c_PROPERTY_QUERY AND p_query_elements(p_i).first_child_i IS NULL) THEN
                        add_text('(+)');
                    END IF;
                    
                    add_text('=j' || p_parent_table_instance || '.id');
                    
                    v_and := ' AND ';
                    
                END IF;
                
                IF p_query_elements(p_i).type = 'N' THEN
                
                    add_text(v_and || 'j' || v_table_instance || '.name');
                    
                    IF p_query_elements(p_i).optional 
                       OR (p_query_type = c_PROPERTY_QUERY AND p_query_elements(p_i).first_child_i IS NULL) THEN
                        add_text('(+)');
                    END IF;
                    
                    v_constant_number := v_constant_number + 1;
                    add_text('=:const' || v_constant_number);
                    
                    v_and := ' AND ';
                    
                ELSIF p_query_elements(p_i).type = 'I' THEN
                
                    add_text(v_and || 'j' || v_table_instance || '.id');
                    
                    IF p_query_elements(p_i).optional THEN
                        add_text('(+)');
                    END IF;
                    
                    v_constant_number := v_constant_number + 1;
                    add_text('=TO_NUMBER(:const' || v_constant_number || ')');
                    
                    v_and := ' AND ';
                    
                ELSIF p_query_elements(p_i).type = 'V' THEN
                
                    add_text(v_and || 'j' || v_table_instance || '.name');
                    
                    IF p_query_elements(p_i).optional 
                       OR (p_query_type = c_PROPERTY_QUERY AND p_query_elements(p_i).first_child_i IS NULL) THEN
                        add_text('(+)');
                    END IF;
                                
                    v_variable_number := v_variable_number + 1;        
                    add_text('=:var' || v_variable_number);
                    
                    v_and := ' AND ';
                    
                ELSIF p_query_elements(p_i).type = 'A' THEN
                
                    add_text(v_and || 'j' || v_table_instance || '.id');
                    
                    IF p_query_elements(p_i).optional THEN
                        add_text('(+)');
                    END IF;
                                        
                    v_variable_number := v_variable_number + 1; 
                    add_text('=TO_NUMBER(:var' || v_variable_number || ')');
                    
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
        v_constant_number := 0;
        v_variable_number := 0;
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
        v_constant_number := 0;
        v_variable_number := 0;
        v_and := ' WHERE '; 
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
    
        v_bind_numbers t_numbers;
        v_constants t_varchars;
        
        v_cursor_id INTEGER;
    
    BEGIN
        
        
        v_bind_numbers := get_query_bind_numbers(p_query_elements);
        v_constants := get_query_constants(p_query_elements);
        
        v_cursor_id := DBMS_SQL.OPEN_CURSOR();
        
        IF p_query_statement.statement_clob IS NOT NULL THEN
            DBMS_SQL.PARSE(v_cursor_id, p_query_statement.statement_clob, DBMS_SQL.NATIVE);
        ELSE
            DBMS_SQL.PARSE(v_cursor_id, p_query_statement.statement, DBMS_SQL.NATIVE);
        END IF;
               
        IF p_bind IS NULL THEN
        
            IF v_bind_numbers.COUNT > 0 THEN
                -- Not all variables bound!
                error$.raise('JDOC-00040');
            END IF;
            
        ELSE
        
            FOR v_i IN 1..v_bind_numbers.COUNT LOOP
            
                IF v_bind_numbers(v_i) > p_bind.COUNT THEN
                    -- Not all variables bound!
                    error$.raise('JDOC-00040');
                END IF;
                
                DBMS_SQL.BIND_VARIABLE(v_cursor_id, ':var' || v_i, p_bind(v_bind_numbers(v_i)));
            
            END LOOP;
            
        END IF;
        
        FOR v_i IN 1..v_constants.COUNT LOOP
            DBMS_SQL.BIND_VARIABLE(v_cursor_id, ':const' || v_i, v_constants(v_i));
        END LOOP;
        
        RETURN v_cursor_id;
    
    END;
    
    FUNCTION to_refcursor (
        p_cursor_id IN INTEGER
    )
    RETURN SYS_REFCURSOR IS
    
        v_cursor_id INTEGER;
    
    BEGIN
    
        v_cursor_id := p_cursor_id;
        
        RETURN DBMS_SQL.TO_REFCURSOR(v_cursor_id);
    
    END;
    
    /* JSON value retrieval and serialization */
    
    FUNCTION request_value (
        p_path IN VARCHAR2,
        p_path_elements IN t_query_elements, 
        p_bind IN bind
    ) 
    RETURN NUMBER IS
        
        v_path_statement t_query_statement;
        
        v_cursor_id INTEGER;
        v_result INTEGER;
        v_fetched_row_count INTEGER;
        
        v_number NUMBER;
        v_string VARCHAR2(4000);
        v_char CHAR;
        
        v_value t_value;
    
    BEGIN

        v_path_statement := get_query_statement(p_path_elements, c_VALUE_QUERY);
        v_cursor_id := prepare_query(p_path_elements, v_path_statement, p_bind);
        
        DBMS_SQL.DEFINE_COLUMN(v_cursor_id, 1, v_number);
        DBMS_SQL.DEFINE_COLUMN(v_cursor_id, 2, v_number);
        DBMS_SQL.DEFINE_COLUMN_CHAR(v_cursor_id, 3, v_char, 1);
        DBMS_SQL.DEFINE_COLUMN(v_cursor_id, 4, v_string, 4000);
        DBMS_SQL.DEFINE_COLUMN(v_cursor_id, 5, v_string, 4000);
        DBMS_SQL.DEFINE_COLUMN_CHAR(v_cursor_id, 6, v_char, 1);
        
        BEGIN
        
            v_fetched_row_count := DBMS_SQL.EXECUTE_AND_FETCH(v_cursor_id, TRUE);
            
        EXCEPTION
            WHEN NO_DATA_FOUND OR TOO_MANY_ROWS THEN
                DBMS_SQL.CLOSE_CURSOR(v_cursor_id);
                RAISE;
        END;
        
        DBMS_SQL.COLUMN_VALUE(v_cursor_id, 1, v_value.id);
        DBMS_SQL.COLUMN_VALUE(v_cursor_id, 2, v_value.parent_id);
        DBMS_SQL.COLUMN_VALUE_CHAR(v_cursor_id, 3, v_value.type);
        DBMS_SQL.COLUMN_VALUE(v_cursor_id, 4, v_value.name);
        DBMS_SQL.COLUMN_VALUE(v_cursor_id, 5, v_value.value);
        DBMS_SQL.COLUMN_VALUE_CHAR(v_cursor_id, 6, v_value.locked);
        
        DBMS_SQL.CLOSE_CURSOR(v_cursor_id);
        
        cache_value(v_value);
        
        RETURN v_value.id;
        
    END;
    
    FUNCTION request_value (
        p_path IN VARCHAR2,
        p_bind IN bind,
        p_raise_not_found IN BOOLEAN := FALSE
    ) 
    RETURN NUMBER IS
    BEGIN
    
        RETURN request_value(NULL, p_path, p_bind, p_raise_not_found);
    
    END;
    
    FUNCTION request_value (
        p_parent_value_id IN NUMBER,
        p_path IN VARCHAR2,
        p_bind IN bind,
        p_raise_not_found IN BOOLEAN := FALSE
    ) 
    RETURN NUMBER IS
    
        v_parent_value t_value;
        v_path_elements t_query_elements;    
    
        v_bind bind;
    
    BEGIN
    
        v_path_elements := parse_path(p_path);
    
        IF p_parent_value_id IS NOT NULL THEN
        
            v_parent_value := get_value(p_parent_value_id);
            
            v_path_elements.EXTEND(1);
            v_path_elements(v_path_elements.COUNT) := v_path_elements(1);
            
            v_path_elements(1).type := 'I';
            v_path_elements(1).value := p_parent_value_id;
            v_path_elements(1).first_child_i := v_path_elements.COUNT;
            
        END IF;
        
        BEGIN
        
            RETURN request_value(p_path, v_path_elements, p_bind);
            
        EXCEPTION
        
            WHEN NO_DATA_FOUND THEN
            
                IF p_raise_not_found THEN
                    -- Value :1 does not exist!
                    error$.raise('JDOC-00009', p_path);
                ELSE
                    RETURN NULL;
                END IF;
                
            WHEN TOO_MANY_ROWS THEN
            
                -- Multiple values found at the path :1!
                error$.raise('JDOC-00004', p_path);
                
        END; 
        
    END;
    
    FUNCTION request_property (
        p_parent_value_id IN NUMBER,
        p_path IN VARCHAR2,
        p_bind IN bind
    ) 
    RETURN t_property IS
    
        v_parent_value t_value;
    
        v_path_elements t_query_elements;
        v_path_statement t_query_statement;
    
        v_cursor_id INTEGER;
        v_fetched_row_count INTEGER;
        
        v_number NUMBER;
        v_char CHAR;
        v_string VARCHAR2(4000);
        
        v_property t_property;
            
    BEGIN
    
        v_path_elements := parse_path(p_path);
        
        IF v_path_elements(v_path_elements.COUNT).type NOT IN ('N', 'V') THEN
            -- Invalid property name!
            error$.raise('JDOC-00022');
        END IF;
        
        IF p_parent_value_id IS NOT NULL THEN
        
            v_parent_value := get_value(p_parent_value_id);
            
            v_path_elements.EXTEND(1);
            v_path_elements(v_path_elements.COUNT) := v_path_elements(1);
            
            v_path_elements(1).type := 'I';
            v_path_elements(1).value := p_parent_value_id;
            v_path_elements(1).first_child_i := v_path_elements.COUNT;
            
        END IF;
        
        IF v_path_elements.COUNT < 2 THEN
            -- Property name missing!
            error$.raise('JDOC-00041');
        END IF;
        
        v_path_statement := get_query_statement(v_path_elements, c_PROPERTY_QUERY);
        v_cursor_id := prepare_query(v_path_elements, v_path_statement, p_bind);
        
        DBMS_SQL.DEFINE_COLUMN(v_cursor_id, 1, v_number);
        DBMS_SQL.DEFINE_COLUMN_CHAR(v_cursor_id, 2, v_char, 1);
        DBMS_SQL.DEFINE_COLUMN(v_cursor_id, 3, v_number);
        DBMS_SQL.DEFINE_COLUMN_CHAR(v_cursor_id, 4, v_char, 1);
        DBMS_SQL.DEFINE_COLUMN(v_cursor_id, 5, v_string, 4000);
        DBMS_SQL.DEFINE_COLUMN_CHAR(v_cursor_id, 6, v_char, 1);
        
        BEGIN
        
            v_fetched_row_count := DBMS_SQL.EXECUTE_AND_FETCH(v_cursor_id, TRUE);
            
        EXCEPTION
        
            WHEN NO_DATA_FOUND THEN
            
                DBMS_SQL.CLOSE_CURSOR(v_cursor_id);
        
                -- No container for property at path :1 could be found!
                error$.raise('JDOC-00007', p_path);
            
            WHEN TOO_MANY_ROWS THEN
            
                DBMS_SQL.CLOSE_CURSOR(v_cursor_id);
        
                -- Multiple values found at the path :1!
                error$.raise('JDOC-00004', p_path);
                
        END;
        
        DBMS_SQL.COLUMN_VALUE(v_cursor_id, 1, v_property.parent_id);
        DBMS_SQL.COLUMN_VALUE_CHAR(v_cursor_id, 2, v_property.parent_type);
        DBMS_SQL.COLUMN_VALUE(v_cursor_id, 3, v_property.property_id);
        DBMS_SQL.COLUMN_VALUE_CHAR(v_cursor_id, 4, v_property.property_type);
        DBMS_SQL.COLUMN_VALUE(v_cursor_id, 5, v_property.property_name);
        DBMS_SQL.COLUMN_VALUE_CHAR(v_cursor_id, 6, v_property.property_locked);
        
        DBMS_SQL.CLOSE_CURSOR(v_cursor_id);
        
        RETURN v_property;
        
    END;
    
    PROCEDURE get_parse_events (
        p_value_id IN NUMBER,
        p_parse_events OUT json_parser.t_parse_events
    ) IS
        
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
                 SELECT /*+ ORDERED USE_NL(jsvl) */
                        jsvl.id
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
        
        p_parse_events := json_parser.t_parse_events();
        v_json_stack := t_chars();
        v_last_lvl := 0;
    
        FOR v_value IN c_values(p_value_id) LOOP
        
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
                            v_length := v_length + 2 + NVL(LENGTH(v_value), 0);
                                
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
    
    /* Cached value casting to the scalar types and JSON */
    
    FUNCTION get_string (
        p_value_id IN NUMBER
    ) 
    RETURN VARCHAR2 IS
    
        v_value t_value;
    
    BEGIN
    
        IF p_value_id IS NULL THEN
            RETURN NULL;
        END IF; 
        
        v_value := get_value(p_value_id);
        
        IF v_value.type IN ('S', 'N', 'E') THEN
            RETURN v_value.value;
        ELSE
            -- Type conversion error!
            error$.raise('JDOC-00010');
        END IF;
    
    END;
    
    FUNCTION get_date (
        p_value_id IN NUMBER
    )
    RETURN DATE IS
    
        v_string_value VARCHAR2(4000);
    
    BEGIN
    
        v_string_value := get_string(p_value_id);
        
        IF v_string_value IS NULL THEN
            RETURN NULL;
        END IF;
        
        BEGIN
            RETURN TO_DATE(v_string_value, c_DATE_FORMAT);
        EXCEPTION
            WHEN OTHERS THEN
                -- Type conversion error!
                error$.raise('JDOC-00010');
        END;
    
    END;
   
    FUNCTION get_number (
        p_value_id IN NUMBER
    ) 
    RETURN NUMBER IS
    
        v_value t_value;
    
    BEGIN
    
        IF p_value_id IS NULL THEN
            RETURN NULL;
        END IF; 
        
        v_value := get_value(p_value_id);
        
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
        p_value_id IN NUMBER
    ) 
    RETURN BOOLEAN IS
    
        v_value t_value;
    
    BEGIN
    
        IF p_value_id IS NULL THEN
            RETURN NULL;
        END IF; 
        
        v_value := get_value(p_value_id);
        
        IF v_value.type IN ('B', 'E') THEN
            RETURN v_value.value = 'true';
        ELSE
            -- Type conversion error!
            error$.raise('JDOC-00010');
        END IF;
    
    END;
    
    FUNCTION get_json (
        p_value_id IN NUMBER
    ) 
    RETURN VARCHAR2 IS
    
        v_value t_value;
        
        v_parse_events json_parser.t_parse_events;
    
        v_json VARCHAR2(32000);
        v_json_clob CLOB;
    
    BEGIN
    
        IF p_value_id IS NULL THEN
            RETURN NULL;
        END IF; 
        
        v_value := get_value(p_value_id);
        
        json_core.get_parse_events(p_value_id, v_parse_events);
        json_core.serialize_value(v_parse_events, v_json, v_json_clob);
        
        RETURN v_json;
    
    END;
    
    FUNCTION get_json_clob (
        p_value_id IN NUMBER
    ) 
    RETURN CLOB IS
    
        v_value t_value;
        
        v_parse_events json_parser.t_parse_events;
    
        v_json VARCHAR2(32000);
        v_json_clob CLOB;
    
    BEGIN
    
        IF p_value_id IS NULL THEN
            RETURN NULL;
        END IF; 
        
        v_value := get_value(p_value_id);
        
        DBMS_LOB.CREATETEMPORARY(v_json_clob, TRUE);
        
        json_core.get_parse_events(p_value_id, v_parse_events);
        json_core.serialize_value(v_parse_events, v_json, v_json_clob);
        
        RETURN v_json_clob;
    
    END;
    
    /* Some usefull generic methods */
    
    FUNCTION is_string (
        p_value_id IN NUMBER
    )
    RETURN BOOLEAN IS
    
        v_value t_value;
    
    BEGIN
    
        v_value := get_value(p_value_id);
        
        RETURN v_value.type = 'S';
    
    END;
    
    FUNCTION is_date (
        p_value_id IN NUMBER
    )
    RETURN BOOLEAN IS
    
        v_value t_value;
        v_dummy DATE;
    
    BEGIN
    
        v_value := get_value(p_value_id);
        
        IF v_value.type != 'S' THEN
        
            RETURN FALSE;
            
        ELSE
        
            BEGIN
            
                v_dummy := TO_DATE(v_value.value, c_DATE_FORMAT);
                
                RETURN TRUE;
                
            EXCEPTION
                WHEN OTHERS THEN
                
                    RETURN FALSE;
                    
            END;
        
        END IF;
    
    END;
    
    FUNCTION is_number (
        p_value_id IN NUMBER
    )
    RETURN BOOLEAN IS
    
        v_value t_value;
    
    BEGIN
    
        v_value := get_value(p_value_id);
        
        RETURN v_value.type = 'N';
    
    END;
    
    FUNCTION is_boolean (
        p_value_id IN NUMBER
    )
    RETURN BOOLEAN IS
    
        v_value t_value;
    
    BEGIN
    
        v_value := get_value(p_value_id);
        
        RETURN v_value.type = 'B';
    
    END;
    
    FUNCTION is_null (
        p_value_id IN NUMBER
    )
    RETURN BOOLEAN IS
    
        v_value t_value;
    
    BEGIN
    
        v_value := get_value(p_value_id);
        
        RETURN v_value.type = 'E';
    
    END;
    
    FUNCTION is_object (
        p_value_id IN NUMBER
    )
    RETURN BOOLEAN IS
    
        v_value t_value;
    
    BEGIN
    
        v_value := get_value(p_value_id);
        
        RETURN v_value.type IN ('O', 'R');
    
    END;
    
    FUNCTION is_array (
        p_value_id IN NUMBER
    )
    RETURN BOOLEAN IS
    
        v_value t_value;
    
    BEGIN
    
        v_value := get_value(p_value_id);
        
        RETURN v_value.type = 'A';
    
    END;
    
    /* Special object methods */
    
    FUNCTION get_keys (
        p_object_id IN NUMBER
    )
    RETURN t_varchars IS
    
        v_value t_value;
        v_keys t_varchars;
    
    BEGIN
    
        v_value := get_value(p_object_id);
     
        IF v_value.type NOT IN ('O', 'R') THEN
            -- Value is not an object!
            error$.raise('JDOC-00021');
        END IF;
        
        SELECT name
        BULK COLLECT INTO v_keys
        FROM json_values
        WHERE parent_id = p_object_id;
        
        RETURN v_keys;
    
    END;
    
    /* Special array methods */
    
    FUNCTION get_length (
        p_array_id IN NUMBER
    )
    RETURN NUMBER IS 
    
        v_value t_value;
        v_length NUMBER;
    
    BEGIN
    
        v_value := get_value(p_array_id);
    
        IF v_value.type != 'A' THEN
            -- Value is not an array!
            error$.raise('JDOC-00012');
        END IF;
        
        SELECT NVL(MAX(to_index(name)) + 1, 0)
        INTO v_length
        FROM json_values 
        WHERE parent_id = p_array_id;
        
        RETURN v_length;
    
    END;
    
    /* JSON creation and modification methods */
    
    FUNCTION create_json (
        p_parent_id IN NUMBER,
        p_name IN VARCHAR2,
        p_content_parse_events IN json_parser.t_parse_events
    ) 
    RETURN NUMBER IS
    BEGIN
    
        RETURN json_writer.write_json(p_parent_id, p_name, p_content_parse_events, 1);
        
    END;
    
    FUNCTION create_json (
        p_content_parse_events IN json_parser.t_parse_events
    )
    RETURN NUMBER IS
    BEGIN
    
        RETURN create_json(NULL, NULL, p_content_parse_events);
        
    END;
    
    FUNCTION set_property (
        p_path IN VARCHAR2,
        p_bind IN bind,
        p_content_parse_events IN json_parser.t_parse_events
    )
    RETURN NUMBER IS
    BEGIN
    
        RETURN set_property(NULL, p_path, p_bind, p_content_parse_events);
    
    END;
    
    FUNCTION set_property (
        p_parent_value_id IN NUMBER,
        p_path IN VARCHAR2,
        p_bind IN bind,
        p_content_parse_events IN json_parser.t_parse_events
    )
    RETURN NUMBER IS

        v_property t_property;

        v_parent_id NUMBER;
        
        v_index NUMBER;
        v_length NUMBER;
        v_gap_values t_json_values;

    BEGIN

        v_property := request_property(p_parent_value_id, p_path, p_bind);
        v_index := to_index(v_property.property_name);
        
        v_gap_values := t_json_values();

        IF v_property.property_locked = 'T' THEN
            -- Value :1 is locked!
            error$.raise('JDOC-00024', p_path);
        ELSIF v_property.parent_type NOT IN ('R', 'O', 'A') THEN
            -- Scalar values and null can't have properties!
            error$.raise('JDOC-00008');
        END IF;

        IF v_property.property_id IS NOT NULL THEN
            
            DELETE FROM json_values
            WHERE id = v_property.property_id;
            
        END IF;

        IF v_property.parent_type = 'A' THEN
                
            IF v_index IS NULL THEN
                -- Array element index must be a non-negative integer!
                error$.raise('JDOC-00013');
            END IF;
                
            v_length := get_length(v_property.parent_id);
                
            IF v_index > v_length THEN
                    
                FOR v_j IN v_length..v_index - 1 LOOP
                    
                    v_gap_values.EXTEND(1);
                        
                    v_gap_values(v_gap_values.COUNT).parent_id := v_property.parent_id;
                    v_gap_values(v_gap_values.COUNT).type := 'E';
                    v_gap_values(v_gap_values.COUNT).name := v_j;
                    
                END LOOP;
                
            END IF;
            
        END IF;
                
        IF v_gap_values.COUNT > 0 THEN
        
            FORALL v_i IN 1..v_gap_values.COUNT
                INSERT INTO json_values(id, parent_id, type, name)
                VALUES(jsvl_id.NEXTVAL, v_gap_values(v_i).parent_id, 'E', v_gap_values(v_i).name);
        
        END IF;

        RETURN create_json (
            v_property.parent_id
           ,v_property.property_name
           ,p_content_parse_events
        );

    END;
    
    FUNCTION push_json (
        p_array_id IN NUMBER,
        p_content_parse_events IN json_parser.t_parse_events
    )
    RETURN NUMBER IS
    BEGIN
    
        RETURN create_json(
            p_array_id,
            get_length(p_array_id),
            p_content_parse_events
        );
    
    END;
    
    PROCEDURE apply_value (
        p_value IN t_value,
        p_content_parse_events IN json_parser.t_parse_events,
        p_event_i IN OUT NOCOPY PLS_INTEGER,
        p_check_types IN BOOLEAN
    ) IS
        
        v_event json_parser.t_parse_event;
        v_value_id NUMBER;
        
        v_child_value_name VARCHAR2(4000);
        v_child_value_row json_values%ROWTYPE;
        
        v_item_i PLS_INTEGER;
        
    BEGIN
    
        v_event := p_content_parse_events(p_event_i);
        
        IF p_value.type = 'R' AND v_event.name != 'START_OBJECT' THEN
        
            -- Property :1 type mismatch!
            error$.raise('JDOC-00011', p_value.name);
        
        ELSIF (p_value.type = 'S' AND v_event.name != 'STRING')
           OR (p_value.type = 'N' AND v_event.name != 'NUMBER')
           OR (p_value.type = 'B' AND v_event.name != 'BOOLEAN')
           OR (p_value.type = 'E' AND v_event.name != 'NULL')
           OR (p_value.type = 'O' AND v_event.name != 'START_OBJECT')
           OR (p_value.type = 'A' AND v_event.name != 'START_ARRAY') THEN
           
           IF p_check_types AND p_value.type != 'E' AND v_event.name != 'NULL' THEN
               -- Property :1 type mismatch!
               error$.raise('JDOC-00011', p_value.name);
           END IF;
           
           DELETE FROM json_values
           WHERE id = p_value.id;
        
           v_value_id := json_writer.write_json(
               p_value.parent_id, 
               p_value.name, 
               p_content_parse_events, 
               p_event_i
           );
        
        ELSIF p_value.type IN ('S', 'N', 'B') AND p_value.value != v_event.value THEN
            
            UPDATE json_values
            SET value = v_event.value
            WHERE id = p_value.id;
        
        ELSIF p_value.type IN ('O', 'R') THEN
        
            p_event_i := p_event_i + 1;
            
            WHILE p_content_parse_events(p_event_i).name != 'END_OBJECT' LOOP
            
                v_child_value_name := p_content_parse_events(p_event_i).value;
            
                BEGIN
                
                    SELECT *
                    INTO v_child_value_row
                    FROM json_values
                    WHERE parent_id = p_value.id
                          AND name = v_child_value_name;
                
                    p_event_i := p_event_i + 1;
                    
                    apply_value(v_child_value_row, p_content_parse_events, p_event_i, p_check_types);               
                
                EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                    
                        p_event_i := p_event_i + 1;
                        
                        v_value_id := json_writer.write_json(
                            p_value.id, 
                            v_child_value_name, 
                            p_content_parse_events, 
                            p_event_i
                        );
                
                END;
            
                p_event_i := p_event_i + 1;
            
            END LOOP;
        
        ELSIF p_value.type = 'A' THEN
       
            v_item_i := 0;
            p_event_i := p_event_i + 1;
            
            WHILE p_content_parse_events(p_event_i).name != 'END_ARRAY' LOOP
            
                BEGIN
                
                    SELECT *
                    INTO v_child_value_row
                    FROM json_values
                    WHERE parent_id = p_value.id
                          AND name = TO_CHAR(v_item_i);
                    
                    apply_value(v_child_value_row, p_content_parse_events, p_event_i, p_check_types);               
                
                EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                    
                        v_value_id := json_writer.write_json(
                            p_value.id, 
                            v_item_i, 
                            p_content_parse_events, 
                            p_event_i
                        );
                
                END;
            
                p_event_i := p_event_i + 1;
                v_item_i := v_item_i + 1;
            
            END LOOP;
    
        END IF;
        
    
    END;
    
    PROCEDURE apply_json (
        p_value_id IN NUMBER,
        p_content_parse_events json_parser.t_parse_events,
        p_check_types IN BOOLEAN
    ) IS
        
        v_value t_value;
        v_event_i PLS_INTEGER;
    
    BEGIN

        v_value := get_value(p_value_id);
        v_event_i := 1;
        
        apply_value(v_value, p_content_parse_events, v_event_i, p_check_types);
        
    END;
    
    PROCEDURE delete_value (
        p_value_id IN NUMBER
    ) IS
    
        v_value t_value;
        v_parent t_value;
    
    BEGIN
    
        v_value := get_value(p_value_id);
        
        IF v_value.type = 'R' THEN
            -- Root can''t be deleted!
            error$.raise('JDOC-00035');
        ELSIF v_value.locked = 'T' THEN
            -- Value :1 is locked!
            error$.raise('JDOC-00024', '#' || p_value_id);
        END IF;
        
        DELETE FROM json_values
        WHERE id = p_value_id;
        
        IF v_value.parent_id IS NOT NULL THEN
        
            v_parent := get_value(v_value.parent_id);
        
            IF v_parent.type = 'A' THEN
                
                INSERT INTO json_values(id, parent_id, type, name)
                VALUES(jsvl_id.NEXTVAL, v_parent.id, 'E', v_value.name);
                
            END IF;
            
        END IF;
    
    END;
    
    /* Value locking/unlocking methods */
    
    PROCEDURE pin (
        p_value_id IN NUMBER,
        p_pin_tree IN BOOLEAN
    ) IS
    
        v_value t_value;
        
        v_parent_ids t_numbers;
        v_child_ids t_numbers;
        v_ids_to_pin t_numbers;
    
    BEGIN
    
        v_value := get_value(p_value_id);
        
        SELECT id
        BULK COLLECT INTO v_parent_ids
        FROM json_values
        START WITH id = p_value_id
        CONNECT BY PRIOR parent_id = id
                   AND locked IS NULL
        FOR UPDATE;
        
        IF p_pin_tree THEN
        
            SELECT id
            BULK COLLECT INTO v_child_ids
            FROM json_values
            WHERE locked IS NULL
            START WITH parent_id = p_value_id
            CONNECT BY PRIOR id = parent_id
            FOR UPDATE;
            
        ELSE
        
            v_child_ids := t_numbers();
        
        END IF;
        
        v_ids_to_pin := v_parent_ids MULTISET UNION v_child_ids;
        
        FORALL v_i IN 1..v_ids_to_pin.COUNT
            UPDATE json_values
            SET locked = 'T'
            WHERE id = v_ids_to_pin(v_i);
            
        FOR v_i IN 1..v_ids_to_pin.COUNT LOOP
            pin_cached_value(v_ids_to_pin(v_i));
        END LOOP;
    
    END;
    
    PROCEDURE unpin (
        p_value_id IN NUMBER,
        p_unpin_tree IN BOOLEAN
    ) IS
    
        v_value t_value;
        
        CURSOR c_pinned_child (
            p_parent_id IN NUMBER
        ) IS
        SELECT 1
        FROM json_values
        WHERE parent_id = p_parent_id
              AND locked = 'T';
        
        v_dummy NUMBER;
        
        v_ids_to_unpin t_numbers;
    
    BEGIN
    
        v_value := get_value(p_value_id);
        
        IF v_value.type = 'R' THEN
            -- Root can''t be unlocked!
            error$.raise('JDOC-00034');
        END IF;
        
        IF p_unpin_tree THEN
        
            SELECT id
            BULK COLLECT INTO v_ids_to_unpin
            FROM json_values
            WHERE locked = 'T'
            START WITH id = p_value_id
            CONNECT BY PRIOR id = parent_id
            FOR UPDATE;
            
        ELSE
        
            OPEN c_pinned_child(p_value_id);
        
            FETCH c_pinned_child
            INTO v_dummy;
            
            IF c_pinned_child%FOUND THEN
                -- Value has locked children!
                error$.raise('JDOC-00033');
            END IF;  
            
            v_ids_to_unpin := t_numbers(p_value_id);
            
        END IF;
        
        FORALL v_i IN 1..v_ids_to_unpin.COUNT
            UPDATE json_values
            SET locked = NULL
            WHERE id = v_ids_to_unpin(v_i);
            
        FOR v_i IN 1..v_ids_to_unpin.COUNT LOOP
            unpin_cached_value(v_ids_to_unpin(v_i));
        END LOOP;
    
    END;
    
BEGIN
    register_messages;
END;
