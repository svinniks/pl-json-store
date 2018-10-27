CREATE OR REPLACE PACKAGE BODY transient_json_store IS
    
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
        
    TYPE t_value_child_ids IS
        TABLE OF PLS_INTEGER
        INDEX BY VARCHAR2(4000);
    
    v_value_child_ids t_value_child_ids;
    
    v_released_ids t_numbers;
    v_released_id_count PLS_INTEGER;
    
    PROCEDURE init IS
        v_root json_core.t_json_value;
    BEGIN
    
        json_core.touch;
    
        v_root.id := 1;
        v_root.type := 'R';
        v_root.locked := 'T';
    
        v_values := t_json_values(v_root);
        
        v_released_ids := t_numbers();
        v_released_id_count := 0;
        
    END;
    
    FUNCTION allocate_value
    RETURN NUMBER IS
    
        v_id NUMBER;
        
    BEGIN
    
        IF v_released_id_count > 0 THEN
            v_id := v_released_ids(v_released_id_count);
            v_released_id_count := v_released_id_count - 1;
        ELSE
            v_values.EXTEND(1);
            v_id := v_values.COUNT;
        END IF;
        
        RETURN v_id;
    
    END;
    
    PROCEDURE dispose_value (
        p_id IN NUMBER
    ) IS
    
        v_name VARCHAR2(4000);
        v_next_name VARCHAR2(4000);
        v_pattern VARCHAR2(31);
    
    BEGIN
    
        IF v_released_id_count = v_released_ids.COUNT THEN
            v_released_ids.EXTEND(1);
        END IF;
        
        v_values(p_id).type := NULL;
        v_released_id_count := v_released_id_count + 1;
        v_released_ids(v_released_id_count) := p_id;
        
        v_name := v_value_child_ids.NEXT(p_id || '-');
        v_pattern := p_id || '-%';
        
        WHILE v_name LIKE v_pattern LOOP
        
            dispose_value(v_value_child_ids(v_name));
            
            v_next_name := v_value_child_ids.NEXT(v_name);
            v_value_child_ids.DELETE(v_name);
            v_name := v_next_name;
                        
        END LOOP;
    
    END;
    
    FUNCTION get_value (
        p_id IN NUMBER
    )
    RETURN json_core.t_json_value IS
        v_value json_core.t_json_value;
    BEGIN
    
        IF p_id IS NULL THEN
            -- Value ID not specified!
            error$.raise('JDC-00031');
        ELSIF NOT v_values.EXISTS(p_id) THEN
            -- Value :1 does not exist!
            error$.raise('JDC-00009', '#' || p_id);
        END IF;
        
        v_value := v_values(p_id);
        
        IF v_value.type IS NULL THEN
            -- Value :1 does not exist!
            error$.raise('JDC-00009', '#' || p_id);
        END IF;
        
        RETURN v_value;
    
    END;
    
    FUNCTION dump_value (
        p_id IN NUMBER
    )
    RETURN t_json_values IS
        
        v_result t_json_values;
        
        PROCEDURE visit_value (
            p_id IN NUMBER
        ) IS
        
            v_value json_core.t_json_value;
            
            v_name VARCHAR2(4000);
            v_pattern VARCHAR2(4000);
            
        BEGIN
            
            v_value := v_values(p_id);
            
            v_result.EXTEND(1);
            v_result(v_result.COUNT) := v_value;
            
            v_name := v_value_child_ids.NEXT(p_id || '-');
            v_pattern := p_id || '-%';
            
            WHILE v_name LIKE v_pattern LOOP
                visit_value(v_value_child_ids(v_name));
                v_name := v_value_child_ids.NEXT(v_name);
            END LOOP;
        
        END;
        
    BEGIN
    
        v_result := t_json_values();
        visit_value(p_id);
        
        RETURN v_result;
    
    END;
    
    -- Generic methods for JSON value retrieval and serialization
    
    FUNCTION request_value (
        p_anchor_id IN NUMBER,
        p_path IN VARCHAR2,
        p_bind IN bind,
        p_path_element_i IN PLS_INTEGER,
        p_property IN BOOLEAN
    ) 
    RETURN NUMBER IS
        
        v_element json_core.t_query_element;
    
        v_value_id NUMBER;
        v_value json_core.t_json_value;
        
        v_next_value json_core.t_json_value;
        v_next_value_id NUMBER;
        v_next_value_key VARCHAR2(4000);
        
        FUNCTION get_bind_value (
            p_bind_i IN PLS_INTEGER
        )
        RETURN VARCHAR2 IS
        BEGIN
        
            IF p_bind IS NULL
               OR p_bind_i > p_bind.COUNT 
            THEN
                -- Not all variables bound!
                error$.raise('JDC-00040');
            END IF;
            
            RETURN p_bind(p_bind_i);
        
        END;
        
    BEGIN

        v_element := json_core.v_query_elements(p_path_element_i);
        
        LOOP
        
            IF v_element.type IN ('A', 'R', 'I', '#') THEN
            
                CASE v_element.type
                    WHEN 'A' THEN
                        v_next_value_id := p_anchor_id;
                    WHEN 'R' THEN
                        v_next_value_id := 1;
                    WHEN 'I' THEN
                        v_next_value_id := v_element.value;
                    WHEN '#' THEN
                        v_next_value_id := get_bind_value(v_element.bind_number);
                END CASE;
                
                IF v_values.EXISTS(v_next_value_id) THEN
                    
                    v_next_value := v_values(v_next_value_id);
                    
                    IF v_next_value.type IS NOT NULL 
                       AND (v_value_id IS NULL
                            OR v_next_value.parent_id = v_value_id) 
                    THEN
                        v_value_id := v_next_value_id;
                    ELSE
                        v_value_id := NULL;
                    END IF;                        
                
                ELSE
                    v_value_id := NULL;
                END IF;
                
            ELSIF v_element.type IN ('N', ':') THEN
                
                IF v_element.type = 'N' THEN
                    v_next_value_key := v_element.value;
                ELSE
                    v_next_value_key := get_bind_value(v_element.bind_number);
                END IF;
                
                v_value := v_values(v_value_id);
                
                IF v_value.type = 'A' THEN
                    v_next_value_key := LPAD(v_next_value_key, 12, '0');
                END IF;
                
                v_next_value_key := v_value_id || '-' || v_next_value_key; 
                        
                IF v_value_child_ids.EXISTS(v_next_value_key) THEN
                    v_value_id :=  v_value_child_ids(v_next_value_key);
                ELSE
                    v_value_id := NULL;
                END IF;    
                    
            END IF;
        
            EXIT WHEN v_value_id IS NULL;
            EXIT WHEN v_element.first_child_i IS NULL;
            
            v_element := json_core.v_query_elements(v_element.first_child_i);
            
            EXIT WHEN p_property AND v_element.first_child_i IS NULL;
            
        END LOOP;

        RETURN v_value_id;
        
    END;
    
    FUNCTION request_value (
        p_anchor_id IN NUMBER,
        p_path IN VARCHAR2,
        p_bind IN bind,
        p_raise_not_found IN BOOLEAN := FALSE
    ) 
    RETURN NUMBER IS
        v_value_id NUMBER;
    BEGIN
    
        v_value_id := request_value(
            p_anchor_id, 
            p_path, 
            p_bind, 
            json_core.parse_path(p_path, p_anchor_id IS NOT NULL), 
            FALSE
        );
        
        IF v_value_id IS NULL AND p_raise_not_found THEN
            -- Value :1 does not exist!
            error$.raise('JDC-00009', p_path);
        END IF;
        
        RETURN v_value_id;
        
    END;
    
    FUNCTION request_property (
        p_anchor_id IN NUMBER,
        p_path IN VARCHAR2,
        p_bind IN bind
    ) 
    RETURN t_property IS
    
        v_path_element_i PLS_INTEGER;
        v_path_length PLS_INTEGER;
        v_property_element json_core.t_query_element;
        
        v_property t_property;
        v_property_key VARCHAR2(4000);
        v_property_value json_core.t_json_value;
        
        v_bind_i NUMBER;
            
    BEGIN
    
        v_path_element_i := json_core.parse_path(p_path, p_anchor_id IS NOT NULL);
        
        v_property_element := json_core.v_query_elements(v_path_element_i);
        v_path_length := 1;
        
        WHILE v_property_element.first_child_i IS NOT NULL LOOP
        
            v_property_element := json_core.v_query_elements(v_property_element.first_child_i);
            v_path_length := v_path_length + 1;
            
        END LOOP;
        
        IF v_path_length < 2 THEN
            -- Property name missing!
            error$.raise('JDC-00041');
        ELSIF v_property_element.type = 'N' THEN
            v_property.property_name := v_property_element.value;
        ELSIF v_property_element.type = ':' THEN
            
            v_bind_i := v_property_element.bind_number;
        
            IF p_bind IS NULL
               OR v_bind_i > p_bind.COUNT 
            THEN
                -- Not all variables bound!
                error$.raise('JDC-00040');
            END IF;
            
            v_property.property_name := p_bind(v_bind_i);
            
        ELSE
            -- Invalid property name!
            error$.raise('JDC-00022');
        END IF;
        
        v_property.parent_id := request_value(p_anchor_id, p_path, p_bind, v_path_element_i, TRUE);
        
        IF v_property.parent_id IS NULL THEN
            -- No container for property at path :1 could be found!
            error$.raise('JDC-00007', p_path);
        END IF;
        
        v_property.parent_type := v_values(v_property.parent_id).type;
        
        v_property_key := v_property.parent_id || '-' || v_property.property_name;
        
        IF v_value_child_ids.EXISTS(v_property_key) THEN
            v_property_value := v_values(v_value_child_ids(v_property_key));
            v_property.property_id := v_property_value.id;
            v_property.property_type := v_property_value.type;
            v_property.property_locked := v_property_value.locked;
        END IF;
        
        RETURN v_property;
        
    END;
    
    FUNCTION get_parse_events (
        p_value_id IN NUMBER,
        p_serialize_nulls IN BOOLEAN
    ) 
    RETURN t_varchars IS
    
        v_parse_events t_varchars;
    
        PROCEDURE add_event (
            p_name IN CHAR,
            p_value IN VARCHAR2 := NULL
        ) IS
        BEGIN
            v_parse_events.EXTEND(1);
            v_parse_events(v_parse_events.COUNT) := p_name || p_value;
        END;
        
        PROCEDURE visit_value (
            p_value IN json_core.t_json_value
        ) IS
        
            v_child_id PLS_INTEGER;
            v_child json_core.t_json_value;
        
            v_name VARCHAR2(4000);
            v_pattern VARCHAR2(4000);
            
        BEGIN   
        
            CASE p_value.type
                WHEN 'S' THEN
                    add_event('S', p_value.value);
                WHEN 'N' THEN
                    add_event('N', p_value.value);
                WHEN 'B' THEN
                    add_event('B', p_value.value);
                WHEN 'E' THEN
                    IF NVL(p_serialize_nulls, FALSE) OR 
                       p_value.id = p_value_id 
                    THEN
                        add_event('E');
                    END IF;
                WHEN 'O' THEN
                    add_event('{');
                WHEN 'R' THEN
                    add_event('{');
                WHEN 'A' THEN
                    add_event('[');
            END CASE;
            
            IF p_value.type IN ('O', 'R', 'A') THEN
            
                v_name := v_value_child_ids.NEXT(p_value.id || '-');
                v_pattern := p_value.id || '-%';
                
                WHILE v_name LIKE v_pattern LOOP
                
                    v_child_id := v_value_child_ids(v_name);
                    v_child := v_values(v_child_id);
                    
                    IF v_child.type != 'E' OR NVL(p_serialize_nulls, FALSE) THEN
                        add_event(':', v_child.name);
                    END IF;
                        
                    visit_value(v_child);
                    
                    v_name := v_value_child_ids.NEXT(v_name);
                    
                END LOOP;
            
            END IF;
            
            IF p_value.type IN ('O', 'R') THEN
                add_event('}');
            ELSIF p_value.type = 'A' THEN
                add_event(']');
            END IF;
            
        END;
        
    BEGIN
    
        v_parse_events := t_varchars();
        visit_value(get_value(p_value_id));
        
        RETURN v_parse_events;
        
    END;
    
    -- Special object methods
    
    FUNCTION get_keys (
        p_object_id IN NUMBER
    )
    RETURN t_varchars IS
    
        v_value json_core.t_json_value;
        
        v_name VARCHAR2(4000);
        v_pattern VARCHAR2(4000);
        
        v_keys t_varchars;
    
    BEGIN
    
        v_value := get_value(p_object_id);
     
        IF v_value.type NOT IN ('O', 'R') THEN
            -- Value is not an object!
            error$.raise('JDC-00021');
        END IF;
        
        v_name := v_value_child_ids.NEXT(p_object_id || '-');
        v_pattern := p_object_id || '-%';
        
        v_keys := t_varchars();
        
        WHILE v_name LIKE v_pattern LOOP
                
            v_keys.EXTEND(1);
            v_keys(v_keys.COUNT) := v_values(v_value_child_ids(v_name)).name;
                        
            v_name := v_value_child_ids.NEXT(v_name);
                        
        END LOOP;
        
        RETURN v_keys;
    
    END;
    
    -- Special array methods
    
    FUNCTION get_length (
        p_array_id IN NUMBER
    )
    RETURN NUMBER IS 
    
        v_value json_core.t_json_value;
        
        v_name VARCHAR2(4000);
        v_pattern VARCHAR2(4000);
    
    BEGIN
    
        v_value := get_value(p_array_id);
    
        IF v_value.type != 'A' THEN
            -- Value is not an array!
            error$.raise('JDC-00012');
        END IF;
        
        v_name := v_value_child_ids.PRIOR(p_array_id || '-999999999999');
        v_pattern := p_array_id || '-%';
        
        IF v_name LIKE v_pattern THEN
            RETURN v_values(v_value_child_ids(v_name)).name + 1;
        ELSE
            RETURN 0;
        END IF;
    
    END;
    
    FUNCTION index_of (
        p_array_id IN NUMBER,
        p_type IN VARCHAR2,
        p_value IN VARCHAR2,
        p_from_index IN NUMBER
    )
    RETURN NUMBER IS
    
        v_value json_core.t_json_value;
        
        v_name VARCHAR2(4000);
        v_pattern VARCHAR2(4000);
    
    BEGIN
    
        v_value := get_value(p_array_id);
    
        IF v_value.type != 'A' THEN
            -- Value is not an array!
            error$.raise('JDC-00012');
        END IF;
        
        IF p_from_index = 0 THEN
            v_name := v_value_child_ids.NEXT(p_array_id || '-');
        ELSE
            v_name := v_value_child_ids.NEXT(p_array_id || '-' || LPAD(p_from_index - 1, 12, '0'));
        END IF;
        
        v_pattern := p_array_id || '-%';
        
        WHILE v_name LIKE v_pattern LOOP
                
            v_value := v_values(v_value_child_ids(v_name));
            
            IF v_value.type = p_type
               AND (NVL(p_value, v_value.value) IS NULL
                    OR p_value = v_value.value) 
            THEN
                RETURN v_value.name;
            END IF;
                        
            v_name := v_value_child_ids.NEXT(v_name);
                        
        END LOOP;
        
        RETURN -1;
    
    END;
    
    -- JSON creation, modification and deletion methods
    
    FUNCTION create_json (
        p_parent_id IN NUMBER,
        p_parent_type IN CHAR,
        p_name IN VARCHAR2,
        p_content_parse_events IN t_varchars
    ) 
    RETURN NUMBER IS
    
        v_event_i PLS_INTEGER;
        v_event json_core.STRING;
        v_event_name CHAR;
        v_event_value VARCHAR2(4000);
    
        PROCEDURE decompose_event IS
        BEGIN
            v_event := p_content_parse_events(v_event_i);
            v_event_name := SUBSTR(v_event, 1, 1);
            v_event_value := SUBSTR(v_event, 2);
        END;
    
        FUNCTION create_value (
            p_parent_id IN NUMBER,
            p_parent_type IN CHAR,
            p_name IN VARCHAR2
        ) 
        RETURN NUMBER IS
        
            v_id NUMBER;
            v_value json_core.t_json_value;
            
            v_name VARCHAR2(4000);
            
            v_child_id NUMBER;
            
        BEGIN
        
            v_id := allocate_value;
            v_value.id := v_id;
            
            IF p_parent_id IS NOT NULL THEN
                
                v_value.name := p_name;
                v_value.parent_id := p_parent_id;
                
                IF p_parent_type = 'A' THEN
                    v_value_child_ids(p_parent_id || '-' || LPAD(p_name, 12, '0')) := v_id;
                ELSE
                    v_value_child_ids(p_parent_id || '-' || p_name) := v_id;
                END IF;    
                
            END IF;
            
            decompose_event;
            
            CASE v_event_name
            
                WHEN 'S' THEN
            
                    v_value.type := 'S';
                    v_value.value := v_event_value; 
            
                WHEN 'N' THEN
                
                    v_value.type := 'N';
                    v_value.value := v_event_value;
                    
                WHEN 'B' THEN
                
                    v_value.type := 'B';
                    v_value.value := v_event_value;
                    
                WHEN 'E' THEN
                
                    v_value.type := 'E';
                    
                ELSE
                
                    v_value.type := 
                        CASE v_event_name
                            WHEN '{' THEN 'O'
                            WHEN '[' THEN 'A'
                        END;
                        
                    v_event_i := v_event_i + 1;
                    
                    decompose_event;
                    
                    WHILE v_event_name NOT IN ('}', ']') LOOP
                    
                        v_name := v_event_value;
                        v_event_i := v_event_i + 1;
                        
                        v_child_id := create_value(v_id, v_value.type, v_name);
                        
                        decompose_event;
                    
                    END LOOP;
                     
            END CASE;
            
            v_values(v_id) := v_value;
            v_event_i := v_event_i + 1;
            
            RETURN v_id;
        
        END;
    
    BEGIN
        v_event_i := 1;
        RETURN create_value(p_parent_id, p_parent_type, p_name);
    END;
    
    FUNCTION create_json (
        p_content_parse_events IN t_varchars
    )
    RETURN NUMBER IS
    BEGIN
        RETURN create_json(NULL, NULL, NULL, p_content_parse_events);
    END;

    PROCEDURE delete_value (
        p_id IN NUMBER
    ) IS
        v_value json_core.t_json_value;
        v_name VARCHAR2(4000);
    BEGIN
    
        v_value := get_value(p_id);
        
        IF v_value.type = 'R' THEN
            -- Root can''t be deleted!
            error$.raise('JDC-00035');
        ELSIF v_value.locked = 'T' THEN
            -- Value :1 is locked!
            error$.raise('JDC-00024', '#' || p_id);
        END IF;
        
        dispose_value(p_id);
        
        IF v_value.parent_id IS NOT NULL THEN
        
            IF v_values(v_value.parent_id).type = 'A' THEN
                v_name := v_value.parent_id || '-' || LPAD(v_value.name, 12, '0');
            ELSE
                v_name := v_value.parent_id || '-' || v_value.name;
            END IF;
            
            v_value_child_ids.DELETE(v_name);
            
        END IF;
    
    END;
    
    FUNCTION set_property (
        p_anchor_id IN NUMBER,
        p_path IN VARCHAR2,
        p_bind IN bind,
        p_content_parse_events IN t_varchars
    )
    RETURN NUMBER IS

        v_property t_property;

        v_parent_id NUMBER;
        
        v_index NUMBER;
        v_length NUMBER;
        v_gap_values t_json_values;

    BEGIN

        v_property := request_property(p_anchor_id, p_path, p_bind);
        
        IF v_property.property_locked = 'T' THEN
            -- Value :1 is locked!
            error$.raise('JDC-00024', p_path);
        ELSIF v_property.parent_type NOT IN ('R', 'O', 'A') THEN
            -- Scalar values and null can't have properties!
            error$.raise('JDC-00008');
        END IF;

        IF v_property.property_id IS NOT NULL THEN
            delete_value(v_property.property_id);
        END IF;

        IF v_property.parent_type = 'A' THEN
                
            v_index := to_index(v_property.property_name);
        
            IF v_index IS NULL THEN
                -- Invalid array element index :1!
                error$.raise('JDC-00013', v_property.property_name);
            END IF;
            
        END IF;

        RETURN create_json (
            v_property.parent_id,
            v_property.parent_type,
            v_property.property_name,
            p_content_parse_events
        );

    END;
    
    -- Value locking/unlocking methods
    
    PROCEDURE pin_value (
        p_id IN NUMBER,
        p_pin_tree IN BOOLEAN
    ) IS
    
        v_value json_core.t_json_value;
        
        PROCEDURE pin_children (
            p_parent_id IN NUMBER
        ) IS
        
            v_name VARCHAR2(4000);
            v_pattern VARCHAR2(4000);
        
        BEGIN
        
            v_name := v_value_child_ids.NEXT(p_parent_id || '-');
            v_pattern := p_parent_id || '-%';
            
            WHILE v_name LIKE v_pattern LOOP
                
                v_value := v_values(v_value_child_ids(v_name));
                
                IF v_value.locked IS NULL THEN
                    v_value.locked := 'T';
                    v_values(v_value.id) := v_value;
                END IF;
                
                pin_children(v_value.id);
                
                v_name := v_value_child_ids.NEXT(v_name);
                
            END LOOP;
        
        END;
        
    BEGIN
    
        v_value := get_value(p_id);
        
        WHILE v_value.locked IS NULL LOOP
        
            v_value.locked := 'T';
            v_values(v_value.id) := v_value;

            EXIT WHEN v_value.parent_id IS NULL;
            
            v_value := v_values(v_value.parent_id);

        END LOOP;
        
        IF p_pin_tree THEN
            pin_children(p_id);
        END IF;
        
    END;
    
    PROCEDURE unpin_value (
        p_id IN NUMBER,
        p_unpin_tree IN BOOLEAN
    ) IS
    
        v_value json_core.t_json_value;
        
        FUNCTION pinned_child_exists (
            p_parent_id IN NUMBER 
        ) 
        RETURN BOOLEAN IS
        
            v_name VARCHAR2(4000);
            v_pattern VARCHAR2(4000);
            
            v_child json_core.t_json_value;
        
        BEGIN
        
            v_name := v_value_child_ids.NEXT(p_parent_id || '-');
            v_pattern := p_parent_id || '-%';
        
            WHILE v_name LIKE v_pattern LOOP
                
                v_child := v_values(v_value_child_ids(v_name));
                
                IF v_child.locked = 'T' THEN
                    RETURN TRUE;
                END IF;
                
                v_name := v_value_child_ids.NEXT(v_name);
                
            END LOOP;
            
            RETURN FALSE;
        
        END;
        
        PROCEDURE unpin_children (
            p_parent_id IN NUMBER
        ) IS
        
            v_name VARCHAR2(4000);
            v_pattern VARCHAR2(4000);
        
        BEGIN
        
            v_name := v_value_child_ids.NEXT(p_parent_id || '-');
            v_pattern := p_parent_id || '-%';
            
            WHILE v_name LIKE v_pattern LOOP
                
                v_value := v_values(v_value_child_ids(v_name));
                
                IF v_value.locked = 'T' THEN
                    v_value.locked := NULL;
                    v_values(v_value.id) := v_value;
                END IF;
                
                unpin_children(v_value.id);
                
                v_name := v_value_child_ids.NEXT(v_name);
                
            END LOOP;
        
        END;
        
    BEGIN
    
        v_value := get_value(p_id);
        
        IF v_value.type = 'R' THEN
            -- Root can''t be unlocked!
            error$.raise('JDC-00034');
        ELSIF v_value.locked IS NULL THEN
            RETURN;
        END IF;
        
        IF p_unpin_tree THEN
        
            v_value.locked := NULL;
            v_values(p_id) := v_value;
            
            unpin_children(p_id);
            
        ELSE
        
            IF pinned_child_exists(p_id) THEN
                -- Value has locked children!
                error$.raise('JDC-00033');
            END IF;
            
            v_value.locked := NULL;
            v_values(p_id) := v_value;
        
        END IF;
    
    END;
    
    -- Table query execution
    
    PROCEDURE execute_table_query (
        p_anchor_id IN NUMBER,
        p_query IN VARCHAR2,
        p_bind IN bind,
        p_values OUT t_varchars,
        p_column_count OUT PLS_INTEGER 
    ) IS
    
        v_query_element_i PLS_INTEGER;
        
        v_value_count PLS_INTEGER;
        v_row t_varchars;
        
        v_parent_value_id_stack t_numbers;
        v_parent_value_id_stack_size PLS_INTEGER;
        
        v_parent_value_id_tail t_numbers;
        v_parent_value_id_tail_size PLS_INTEGER;
        
        FUNCTION peek_parent_value_id
        RETURN NUMBER IS
        BEGIN
            RETURN v_parent_value_id_stack(v_parent_value_id_stack_size);
        END;
        
        PROCEDURE pop_parent_value_id IS
        BEGIN
            v_parent_value_id_stack_size := v_parent_value_id_stack_size - 1;
        END;
        
        PROCEDURE push_parent_value_id (
            p_id IN NUMBER
        ) IS
        BEGIN
        
            IF v_parent_value_id_stack_size = v_parent_value_id_stack.COUNT THEN
                v_parent_value_id_stack.EXTEND(1);
            END IF;
            
            v_parent_value_id_stack_size := v_parent_value_id_stack_size + 1;
            v_parent_value_id_stack(v_parent_value_id_stack_size) := p_id;
            
        END;
        
        PROCEDURE tail IS
        BEGIN
            
            IF v_parent_value_id_tail_size = v_parent_value_id_tail.COUNT THEN
                v_parent_value_id_tail.EXTEND(1);
            END IF;
        
            v_parent_value_id_tail_size := v_parent_value_id_tail_size + 1;
            v_parent_value_id_tail(v_parent_value_id_tail_size) := peek_parent_value_id;
            
            pop_parent_value_id;
        
        END;
        
        PROCEDURE untail IS
        BEGIN
            push_parent_value_id(v_parent_value_id_tail(v_parent_value_id_tail_size));
            v_parent_value_id_tail_size := v_parent_value_id_tail_size - 1;
        END;
                
        FUNCTION get_bind_value (
            p_bind_i IN PLS_INTEGER
        )
        RETURN VARCHAR2 IS
        BEGIN
        
            IF p_bind IS NULL
               OR p_bind_i > p_bind.COUNT 
            THEN
                -- Not all variables bound!
                error$.raise('JDC-00040');
            END IF;
            
            RETURN p_bind(p_bind_i);
        
        END;
        
        PROCEDURE visit_element (
            p_i IN PLS_INTEGER,
            p_column_number IN PLS_INTEGER
        ) IS
        
            v_element json_core.t_query_element;
            
            v_wildcard_elements_found BOOLEAN;
            
            v_name VARCHAR2(4000);
            v_pattern VARCHAR2(31);
            
            v_parent_value_id NUMBER;
            v_value_id NUMBER;
            v_value json_core.t_json_value;
            
            PROCEDURE visit_next IS
            
                v_parent_value_id NUMBER;
                
                v_next_sibling_element_i PLS_INTEGER;
                v_next_sibling_element json_core.t_query_element;
                
                v_tail_size PLS_INTEGER;
                
            BEGIN
                
                IF v_element.first_child_i IS NOT NULL THEN
                
                    push_parent_value_id(v_value.id);
                    
                    visit_element(
                        v_element.first_child_i, 
                        p_column_number
                    );
                    
                    pop_parent_value_id;
                    
                ELSE
                    
                    IF v_value.id <= 0 THEN
                        v_row(p_column_number) := NULL;
                    ELSIF v_element.value = 'id' THEN
                        v_row(p_column_number) := v_value.id;
                    ELSIF v_element.value = 'key' THEN
                        v_row(p_column_number) := v_value.name;
                    ELSIF v_element.value = 'type' THEN
                        v_row(p_column_number) := v_value.type;
                    ELSIF v_element.value = 'value' THEN
                        v_row(p_column_number) := v_value.value;
                    ELSE
                        v_row(p_column_number) := v_value.value;
                    END IF;
                        
                    v_next_sibling_element_i := p_i;
                    v_tail_size := 0;
                    
                    WHILE v_next_sibling_element_i IS NOT NULL LOOP
                    
                        v_next_sibling_element := json_core.v_query_elements(v_next_sibling_element_i);
                        
                        IF v_next_sibling_element.next_sibling_i IS NOT NULL THEN
                        
                            visit_element(
                                v_next_sibling_element.next_sibling_i, 
                                p_column_number + 1
                            );
                            
                            FOR v_i IN 1..v_tail_size LOOP
                                untail;
                            END LOOP;
                            
                            RETURN;
                            
                        ELSE
                        
                            v_next_sibling_element_i := v_next_sibling_element.parent_i;
                            
                            tail;
                            v_tail_size := v_tail_size + 1;
                            
                        END IF;
                    
                    END LOOP;
                    
                    FOR v_i IN 1..v_tail_size LOOP
                        untail;
                    END LOOP;
                                        
                    FOR v_i IN 1..p_column_count LOOP
                    
                        v_value_count := v_value_count + 1;
                        
                        p_values.EXTEND(1);
                        p_values(v_value_count) := v_row(v_i);
                        
                    END LOOP;
                    
                END IF;
            
            END;
    
        BEGIN
        
            v_parent_value_id := peek_parent_value_id;
            v_element := json_core.v_query_elements(p_i);
            
            IF v_parent_value_id IS NULL AND v_element.type IN ('N', ':', 'W') THEN
            
                IF v_element.type = 'N' THEN
                    v_name := v_element.value;
                ELSIF v_element.type = ':' THEN
                    v_name := get_bind_value(v_element.bind_number);
                END IF;
                
                FOR v_i IN 1..v_values.COUNT LOOP
                
                    v_value := v_values(v_i);
                    
                    IF v_value.type IS NOT NULL
                       AND (v_name IS NULL
                            OR v_value.name = v_name)
                    THEN
                        visit_next;
                    END IF;
                    
                END LOOP;
            
            ELSIF v_element.type = 'W' THEN
            
                v_wildcard_elements_found := FALSE;
            
                v_name := v_value_child_ids.NEXT(v_parent_value_id || '-');
                v_pattern := v_parent_value_id || '-%';
                
                WHILE v_name LIKE v_pattern LOOP
                
                    v_wildcard_elements_found := TRUE;
                    v_value := v_values(v_value_child_ids(v_name));
                    visit_next;
                    
                    v_name := v_value_child_ids.NEXT(v_name);
                    
                END LOOP;
                
                IF NOT v_wildcard_elements_found AND v_element.optional THEN
                
                    v_value := NULL;
                    v_value.id := -1;
                    
                    visit_next;
                
                END IF;
                
            ELSIF v_element.type IN ('N', ':') THEN
            
                IF v_element.type = 'N' THEN
                    v_name := v_element.value;
                ELSE
                    v_name := get_bind_value(v_element.bind_number);
                END IF;
                
                v_name := v_parent_value_id || '-' || v_name;
                
                IF v_value_child_ids.EXISTS(v_name) THEN
                    v_value := v_values(v_value_child_ids(v_name));
                    visit_next;
                ELSIF v_element.optional THEN
                
                    v_value := NULL;
                    v_value.id := -1;
                    
                    visit_next;
                    
                END IF;
                            
            ELSIF v_element.type IN ('A', 'I', '#') THEN
            
                IF v_element.type = 'A' THEN
                    v_value_id := p_anchor_id;
                ELSIF v_element.type = 'I' THEN
                    v_value_id := v_element.value;
                ELSE
                    v_value_id := get_bind_value(v_element.bind_number);
                END IF;
                
                IF v_values.EXISTS(v_value_id) THEN
                
                    v_value := v_values(v_value_id);
                    
                    IF v_value.type IS NOT NULL
                       AND NVL(v_value.parent_id, 0) = NVL(peek_parent_value_id, 0) 
                    THEN
                    
                        visit_next;
                        
                    ELSIF v_element.optional THEN
                        
                        v_value := NULL;
                        v_value.id := -1;
                        
                        visit_next;
                     
                    END IF;
                    
                ELSIF v_element.optional THEN
                    
                    v_value := NULL;
                    v_value.id := -1;
                    
                    visit_next;
                    
                END IF;
                
            ELSIF v_element.type = 'F' THEN
            
                IF v_parent_value_id > 0 THEN
                    v_value := v_values(v_parent_value_id);
                ELSE
                    v_value := NULL;
                    v_value.id := -1;
                END IF;
                
                visit_next;
            
            END IF;
        
        END;
    
    BEGIN
    
        v_query_element_i := json_core.parse_query(p_query, p_anchor_id IS NOT NULL);
        p_column_count := json_core.get_query_column_count(v_query_element_i);
        
        p_values := t_varchars();
        v_value_count := 0;
        
        v_row := t_varchars();
        v_row.EXTEND(p_column_count);
        
        v_parent_value_id_stack := t_numbers(NULL);
        v_parent_value_id_stack_size := 1;
        
        v_parent_value_id_tail := t_numbers();
        v_parent_value_id_tail_size := 0;
        
        visit_element(v_query_element_i, 1);
    
    END;
    
BEGIN    
    init;
END;
