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
    
    e_no_more_rows_needed EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_no_more_rows_needed, -6548);
    
    PROCEDURE register_messages IS
    BEGIN
        default_message_resolver.register_message('JDOC-00004', 'Multiple values found at path :1!');
        default_message_resolver.register_message('JDOC-00008', 'Scalar values and null can''t have properties!');
        default_message_resolver.register_message('JDOC-00009', 'Value :1 does not exist!');
        default_message_resolver.register_message('JDOC-00010', 'Type conversion error!');
        default_message_resolver.register_message('JDOC-00012', ':1 is not an array!');
        default_message_resolver.register_message('JDOC-00024', 'Value :1 is locked!');
        default_message_resolver.register_message('JDOC-00025', 'Value :1 has locked children!');
        default_message_resolver.register_message('JDOC-00026', 'Root can''t be unlocked!');
    END;
    
    FUNCTION create_json (
        p_content IN VARCHAR2
    )
    RETURN NUMBER IS
    
        v_parse_events json_parser.t_parse_events;
        v_created_ids t_numbers;
        
    BEGIN
    
        json_parser.parse(p_content, v_parse_events);
        
        RETURN json_core.create_json(t_numbers(NULL), NULL, v_parse_events)(1);
        
    END;
    
    FUNCTION create_json_clob (
        p_content IN CLOB
    )
    RETURN NUMBER IS
    
        v_parse_events json_parser.t_parse_events;
        
    BEGIN
    
        json_parser.parse(p_content, v_parse_events);
        
        RETURN json_core.create_json(t_numbers(NULL), NULL, v_parse_events)(1);
        
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

        RETURN json_core.create_json(t_numbers(NULL), NULL, string_events(p_value))(1);

    END;

    FUNCTION create_number (
        p_value IN NUMBER
    )
    RETURN NUMBER IS
    BEGIN

        RETURN json_core.create_json(t_numbers(NULL), NULL, number_events(p_value))(1);

    END;

    FUNCTION create_boolean (
        p_value IN BOOLEAN
    )
    RETURN NUMBER IS
    BEGIN

        RETURN json_core.create_json(t_numbers(NULL), NULL, boolean_events(p_value))(1);

    END;

    FUNCTION create_null
    RETURN NUMBER IS
    BEGIN

        RETURN json_core.create_json(t_numbers(NULL), NULL, null_events)(1);

    END;

    FUNCTION create_object
    RETURN NUMBER IS
    BEGIN

        RETURN json_core.create_json(t_numbers(NULL), NULL, object_events)(1);

    END;

    FUNCTION create_array
    RETURN NUMBER IS
    BEGIN

        RETURN json_core.create_json(t_numbers(NULL), NULL, array_events)(1);

    END;

    FUNCTION set_json (
        p_path IN VARCHAR2,
        p_content IN VARCHAR2,
        p_bind IN bind := NULL
    )
    RETURN NUMBER IS
    
        v_parse_events json_parser.t_parse_events;
        
    BEGIN
    
        json_parser.parse(p_content, v_parse_events);
    
        RETURN json_core.set_property(
            p_path, 
            p_bind,
            v_parse_events
        )(1);
        
    END;
    
    PROCEDURE set_json (
        p_path IN VARCHAR2,
        p_content IN VARCHAR2,
        p_bind IN bind := NULL
    ) IS
        
        v_dummy NUMBER;
        
    BEGIN
    
        v_dummy := set_json(
            p_path,
            p_content,
            p_bind
        );
    
    END;
    
    FUNCTION set_json_clob (
        p_path IN VARCHAR2,
        p_content IN CLOB,
        p_bind IN bind := NULL
    )
    RETURN NUMBER IS
    
        v_parse_events json_parser.t_parse_events;
        
    BEGIN
    
        json_parser.parse(p_content, v_parse_events);
    
        RETURN json_core.set_property(
            p_path, 
            p_bind,
            v_parse_events
        )(1);
        
    END;

    PROCEDURE set_json_clob (
        p_path IN VARCHAR2,
        p_content IN CLOB,
        p_bind IN bind := NULL
    ) IS
        
        v_dummy NUMBER;
        
    BEGIN
    
        v_dummy := set_json_clob(
            p_path, 
            p_content,
            p_bind
        ); 
    
    END;

    FUNCTION set_string (
        p_path IN VARCHAR2,
        p_value IN VARCHAR2,
        p_bind IN bind := NULL
    )
    RETURN NUMBER IS
    BEGIN

        RETURN json_core.set_property(
            p_path, 
            p_bind,
            string_events(p_value)
        )(1);

    END;
    
    PROCEDURE set_string (
        p_path IN VARCHAR2,
        p_value IN VARCHAR2,
        p_bind IN bind := NULL
    ) IS
        
        v_dummy NUMBER;
        
    BEGIN

        v_dummy := set_string(
            p_path, 
            p_value,
            p_bind
        );

    END;

    FUNCTION set_number (
        p_path IN VARCHAR2,
        p_value IN NUMBER,
        p_bind IN bind := NULL
    )
    RETURN NUMBER IS
    BEGIN

        RETURN json_core.set_property(
            p_path, 
            p_bind,
            number_events(p_value)
        )(1);

    END;
    
    PROCEDURE set_number (
        p_path IN VARCHAR2,
        p_value IN NUMBER,
        p_bind IN bind := NULL
    ) IS
        
        v_dummy NUMBER;
        
    BEGIN

        v_dummy := set_number(
            p_path, 
            p_value,
            p_bind
        );

    END;

    FUNCTION set_boolean (
        p_path IN VARCHAR2,
        p_value IN BOOLEAN,
        p_bind IN bind := NULL
    )
    RETURN NUMBER IS
    BEGIN

        RETURN json_core.set_property(
            p_path, 
            p_bind,
            boolean_events(p_value)
        )(1);

    END;
    
    PROCEDURE set_boolean (
        p_path IN VARCHAR2,
        p_value IN BOOLEAN,
        p_bind IN bind := NULL
    ) IS
        
        v_dummy NUMBER;
        
    BEGIN

        v_dummy := set_boolean(
            p_path, 
            p_value, 
            p_bind
        );

    END;

    FUNCTION set_null (
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    )
    RETURN NUMBER IS
    BEGIN

        RETURN json_core.set_property(
            p_path, 
            p_bind,
            null_events
        )(1);

    END;
    
    PROCEDURE set_null (
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    ) IS
    
        v_dummy NUMBER;
        
    BEGIN
    
        v_dummy := set_null(
            p_path,
            p_bind
        );
        
    END;

    FUNCTION set_object (
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    )
    RETURN NUMBER IS
    BEGIN

        RETURN json_core.set_property(
            p_path, 
            p_bind,
            object_events
        )(1);

    END;
    
    PROCEDURE set_object (
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    ) IS
        
        v_dummy NUMBER;
        
    BEGIN
    
        v_dummy := json_core.set_property(
            p_path, 
            p_bind,
            object_events
        )(1);
        
    END;

    FUNCTION set_array (
        p_path IN VARCHAR2,
        p_bind IN bind := NULL        
    )
    RETURN NUMBER IS
    BEGIN

        RETURN json_core.set_property(
            p_path, 
            p_bind, 
            array_events
        )(1);

    END;
    
    PROCEDURE set_array (
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    ) IS
        
        v_dummy NUMBER;
        
    BEGIN
    
        v_dummy := json_core.set_property(
            p_path,
            p_bind,
            array_events
        )(1);
        
    END;
    
    FUNCTION get_string (
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    )
    RETURN VARCHAR2 IS

        v_value json_core.t_value;
    
    BEGIN

        v_value := json_core.request_value(p_path, p_bind);
        
        IF v_value.type IN ('S', 'N', 'E') THEN
            RETURN v_value.value;
        ELSE
            -- Type conversion error!
            error$.raise('JDOC-00010');
        END IF;

    END;
    
    FUNCTION get_number (
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    )
    RETURN NUMBER IS
    
        v_value json_core.t_value;
    
    BEGIN

        v_value := json_core.request_value(p_path, p_bind);
        
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
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    )
    RETURN BOOLEAN IS
    
        v_value json_core.t_value;
    
    BEGIN

        v_value := json_core.request_value(p_path, p_bind);

        IF v_value.type IN ('B', 'E') THEN
            RETURN v_value.value = 'true';
        ELSE
            -- Type conversion error!
            error$.raise('JDOC-00010');
        END IF;

    END;
    
    FUNCTION get_json (
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    )
    RETURN VARCHAR2 IS
    
        v_parse_events json_parser.t_parse_events;
    
        v_json VARCHAR2(32000);
        v_json_clob CLOB;
    
    BEGIN
      
        json_core.get_parse_events(p_path, v_parse_events, p_bind);
        json_core.serialize_value(v_parse_events, v_json, v_json_clob);
        
        RETURN v_json;
    
    END;
    
    FUNCTION get_json_clob (
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    )
    RETURN CLOB IS
        
        v_parse_events json_parser.t_parse_events;
    
        v_json VARCHAR2(32000);
        v_json_clob CLOB;
    
    BEGIN
      
        
        DBMS_LOB.CREATETEMPORARY(v_json_clob, TRUE);
        
        json_core.get_parse_events(p_path, v_parse_events, p_bind);
        json_core.serialize_value(v_parse_events, v_json, v_json_clob);
        
        RETURN v_json_clob;
    
    END;
    
    PROCEDURE apply_json (
        p_path IN VARCHAR2,
        -- @json
        p_content IN VARCHAR2,
        p_bind IN bind := NULL,
        p_check_types IN BOOLEAN := FALSE
    ) IS
        v_parse_events json_parser.t_parse_events;
    BEGIN
    
        json_parser.parse(p_content, v_parse_events);
        json_core.apply_json(p_path, v_parse_events, p_bind, p_check_types);
        
    END;
        
    PROCEDURE apply_json_clob (
        p_path IN VARCHAR2,
        -- @json
        p_content IN CLOB,
        p_bind IN bind := NULL,
        p_check_types IN BOOLEAN := FALSE
    ) IS
    
        v_parse_events json_parser.t_parse_events;
        
    BEGIN
    
        json_parser.parse(p_content, v_parse_events);
        json_core.apply_json(p_path, v_parse_events, p_bind, p_check_types);
        
    END;
    
    FUNCTION get_length (
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    )
    RETURN NUMBER IS
    
        v_array json_core.t_value;
                
    BEGIN
    
        v_array := json_core.request_value(p_path, p_bind);
        
        IF v_array.type != 'A' THEN
            -- :1 is not an array!
            error$.raise('JDOC-00012', p_path);
        END IF;
        
        RETURN json_core.get_length(v_array.id);
    
    END;
    
    FUNCTION push_string (
        p_path IN VARCHAR2,
        p_value IN VARCHAR2,
        p_bind IN bind := NULL
    )
    RETURN NUMBER IS
    BEGIN

        RETURN json_core.push_property(p_path, p_bind, string_events(p_value))(1);

    END;
    
    PROCEDURE push_string (
        p_path IN VARCHAR2,
        p_value IN VARCHAR2,
        p_bind IN bind := NULL
    ) IS
        
        v_dummy NUMBER;
        
    BEGIN
    
        v_dummy := push_string(p_path, p_value, p_bind);
        
    END;
   
    FUNCTION push_number (
        p_path IN VARCHAR2,
        p_value IN NUMBER,
        p_bind IN bind := NULL
    )
    RETURN NUMBER IS
    BEGIN

        RETURN json_core.push_property(p_path, p_bind, number_events(p_value))(1);

    END;
    
    PROCEDURE push_number (
        p_path IN VARCHAR2,
        p_value IN NUMBER,
        p_bind IN bind := NULL
    ) IS
        
        v_dummy NUMBER;
        
    BEGIN
    
        v_dummy := push_number(p_path, p_value, p_bind);
        
    END;
    
    FUNCTION push_boolean (
        p_path IN VARCHAR2,
        p_value IN BOOLEAN,
        p_bind IN bind := NULL
    )
    RETURN NUMBER IS
    BEGIN

        RETURN json_core.push_property(p_path, p_bind, boolean_events(p_value))(1);

    END;
    
    PROCEDURE push_boolean (
        p_path IN VARCHAR2,
        p_value IN BOOLEAN,
        p_bind IN bind := NULL
    ) IS
        
        v_dummy NUMBER;
        
    BEGIN
    
        v_dummy := push_boolean(p_path, p_value, p_bind);
        
    END;
    
    FUNCTION push_null (
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    )
    RETURN NUMBER IS
    BEGIN

        RETURN json_core.push_property(p_path, p_bind, null_events)(1);

    END;
        
    PROCEDURE push_null (
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    ) IS
        
        v_dummy NUMBER;
        
    BEGIN
        v_dummy := push_null(p_path, p_bind);
    END;
    
    FUNCTION push_object (
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    )
    RETURN NUMBER IS
    BEGIN

        RETURN json_core.push_property(p_path, p_bind, object_events)(1);

    END;
        
    PROCEDURE push_object (
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    ) IS
        
        v_dummy NUMBER;
        
    BEGIN
        v_dummy := push_object(p_path, p_bind);
    END;
        
    FUNCTION push_array (
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    )
    RETURN NUMBER IS
    BEGIN

        RETURN json_core.push_property(p_path, p_bind, array_events)(1);

    END;
        
    PROCEDURE push_array (
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    ) IS
        
        v_dummy NUMBER;
        
    BEGIN
    
        v_dummy := push_array(p_path, p_bind);
        
    END;
        
    FUNCTION push_json (
        p_path IN VARCHAR2,
        p_content IN VARCHAR2,
        p_bind IN bind := NULL
    )
    RETURN NUMBER IS
    
        v_parse_events json_parser.t_parse_events;
        
    BEGIN
    
        json_parser.parse(p_content, v_parse_events);
        RETURN json_core.push_property(p_path, p_bind, v_parse_events)(1);
        
    END;
        
    PROCEDURE push_json (
        p_path IN VARCHAR2,
        p_content IN VARCHAR2,
        p_bind IN bind := NULL
    ) IS
        
        v_dummy NUMBER;
        
    BEGIN
    
        v_dummy := push_json(p_path, p_content, p_bind);
        
    END;
        
    FUNCTION push_json_clob (
        p_path IN VARCHAR2,
        p_content IN CLOB,
        p_bind IN bind := NULL
    )
    RETURN NUMBER IS
    
        v_parse_events json_parser.t_parse_events;
        
    BEGIN
    
        json_parser.parse(p_content, v_parse_events); 
        RETURN json_core.push_property(p_path, p_bind, v_parse_events)(1);
        
    END;
        
    PROCEDURE push_json_clob (
        p_path IN VARCHAR2,
        p_content IN CLOB,
        p_bind IN bind := NULL
    ) IS
        
        v_dummy NUMBER;
        
    BEGIN
    
        v_dummy := push_json(p_path, p_content, p_bind);
        
    END;
    
    PROCEDURE delete_value (
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    ) IS
        
        c_properties SYS_REFCURSOR;
        v_properties json_core.t_properties;
        
        v_value json_core.t_value;
        
    BEGIN
    
        json_core.request_properties(p_path, p_bind, c_properties);
        
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
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    ) IS
    
        v_value json_core.t_value;
        t_ids_to_lock t_numbers;
    
    BEGIN
    
        v_value := json_core.request_value(p_path, p_bind);
    
        IF v_value.type = 'R' THEN
            RETURN;
        END IF;
    
        SELECT id
        BULK COLLECT INTO t_ids_to_lock
        FROM json_values
        START WITH id = v_value.id
        CONNECT BY PRIOR parent_id = id
                         AND id != 0
        FOR UPDATE;
        
        FORALL v_i IN 1..t_ids_to_lock.COUNT
            UPDATE json_values
            SET locked = 'T'
            WHERE id = t_ids_to_lock(v_i);
    
    END;
    
    PROCEDURE unlock_value (
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    ) IS
    
        v_value json_core.t_value;
        v_dummy NUMBER;
        
        CURSOR c_locked_child (
            p_parent_id IN NUMBER
        ) IS
        SELECT 1
        FROM json_values
        WHERE parent_id = p_parent_id
              AND locked = 'T';
    
    BEGIN
        
        v_value := json_core.request_value(p_path, p_bind);
        
        IF v_value.type = 'R' THEN
            -- Root can''t be unlocked!
            error$.raise('JDOC-00026');
        END IF;
        
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
    
    FUNCTION get_5_value_table (
        p_query IN VARCHAR2,
        p_bind IN bind := NULL
    )
    RETURN t_5_value_table PIPELINED IS
    
        v_query_elements json_core.t_query_elements;
        v_query_statement json_core.t_query_statement;
    
        v_cursor_id INTEGER;
        c_rows SYS_REFCURSOR;
    
        v_row_buffer t_5_value_table;
        c_fetch_limit CONSTANT PLS_INTEGER := 1000;
    
    BEGIN
    
        v_query_elements := json_core.parse_query(p_query, json_core.c_X_VALUE_TABLE_QUERY);
        v_query_statement := json_core.get_query_statement(v_query_elements, json_core.c_X_VALUE_TABLE_QUERY, 5);
    
        v_cursor_id := json_core.prepare_query (
            v_query_elements,
            v_query_statement,
            p_bind
        );
    
        c_rows := DBMS_SQL.TO_REFCURSOR(v_cursor_id);
        
        LOOP
        
            FETCH c_rows
            BULK COLLECT INTO v_row_buffer
            LIMIT c_fetch_limit;
            
            FOR v_i IN 1..v_row_buffer.COUNT LOOP
                PIPE ROW(v_row_buffer(v_i));
            END LOOP;
            
            EXIT WHEN v_row_buffer.COUNT < c_fetch_limit;
        
        END LOOP;
        
        CLOSE c_rows;
    
        RETURN;
        
    EXCEPTION
        WHEN e_no_more_rows_needed THEN
            CLOSE c_rows;
    
    END;
    
    FUNCTION get_10_value_table (
        p_query IN VARCHAR2,
        p_bind IN bind := NULL
    )
    RETURN t_10_value_table PIPELINED IS
    
        v_query_elements json_core.t_query_elements;
        v_query_statement json_core.t_query_statement;
    
        v_cursor_id INTEGER;
        c_rows SYS_REFCURSOR;
    
        v_row_buffer t_10_value_table;
        c_fetch_limit CONSTANT PLS_INTEGER := 1000;
    
    BEGIN
    
        v_query_elements := json_core.parse_query(p_query, json_core.c_X_VALUE_TABLE_QUERY);
        v_query_statement := json_core.get_query_statement(v_query_elements, json_core.c_X_VALUE_TABLE_QUERY, 10);
    
        v_cursor_id := json_core.prepare_query (
            v_query_elements,
            v_query_statement,
            p_bind
        );
    
        c_rows := DBMS_SQL.TO_REFCURSOR(v_cursor_id);
        
        LOOP
        
            FETCH c_rows
            BULK COLLECT INTO v_row_buffer
            LIMIT c_fetch_limit;
            
            FOR v_i IN 1..v_row_buffer.COUNT LOOP
                PIPE ROW(v_row_buffer(v_i));
            END LOOP;
            
            EXIT WHEN v_row_buffer.COUNT < c_fetch_limit;
        
        END LOOP;
        
        CLOSE c_rows;
    
        RETURN;
        
    EXCEPTION
        WHEN e_no_more_rows_needed THEN
            CLOSE c_rows;
    
    END;
    
    FUNCTION get_15_value_table (
        p_query IN VARCHAR2,
        p_bind IN bind := NULL
    )
    RETURN t_15_value_table PIPELINED IS
    
        v_query_elements json_core.t_query_elements;
        v_query_statement json_core.t_query_statement;
    
        v_cursor_id INTEGER;
        c_rows SYS_REFCURSOR;
    
        v_row_buffer t_15_value_table;
        c_fetch_limit CONSTANT PLS_INTEGER := 1000;
    
    BEGIN
    
        v_query_elements := json_core.parse_query(p_query, json_core.c_X_VALUE_TABLE_QUERY);
        v_query_statement := json_core.get_query_statement(v_query_elements, json_core.c_X_VALUE_TABLE_QUERY, 15);
    
        v_cursor_id := json_core.prepare_query (
            v_query_elements,
            v_query_statement,
            p_bind
        );
    
        c_rows := DBMS_SQL.TO_REFCURSOR(v_cursor_id);
        
        LOOP
        
            FETCH c_rows
            BULK COLLECT INTO v_row_buffer
            LIMIT c_fetch_limit;
            
            FOR v_i IN 1..v_row_buffer.COUNT LOOP
                PIPE ROW(v_row_buffer(v_i));
            END LOOP;
            
            EXIT WHEN v_row_buffer.COUNT < c_fetch_limit;
        
        END LOOP;
        
        CLOSE c_rows;
    
        RETURN;
        
    EXCEPTION
        WHEN e_no_more_rows_needed THEN
            CLOSE c_rows;
    
    END;
    
    FUNCTION get_20_value_table (
        p_query IN VARCHAR2,
        p_bind IN bind := NULL
    )
    RETURN t_20_value_table PIPELINED IS
    
        v_query_elements json_core.t_query_elements;
        v_query_statement json_core.t_query_statement;
    
        v_cursor_id INTEGER;
        c_rows SYS_REFCURSOR;
    
        v_row_buffer t_20_value_table;
        c_fetch_limit CONSTANT PLS_INTEGER := 1000;
    
    BEGIN
    
        v_query_elements := json_core.parse_query(p_query, json_core.c_X_VALUE_TABLE_QUERY);
        v_query_statement := json_core.get_query_statement(v_query_elements, json_core.c_X_VALUE_TABLE_QUERY, 20);
    
        v_cursor_id := json_core.prepare_query (
            v_query_elements,
            v_query_statement,
            p_bind
        );
    
        c_rows := DBMS_SQL.TO_REFCURSOR(v_cursor_id);
        
        LOOP
        
            FETCH c_rows
            BULK COLLECT INTO v_row_buffer
            LIMIT c_fetch_limit;
            
            FOR v_i IN 1..v_row_buffer.COUNT LOOP
                PIPE ROW(v_row_buffer(v_i));
            END LOOP;
            
            EXIT WHEN v_row_buffer.COUNT < c_fetch_limit;
        
        END LOOP;
        
        CLOSE c_rows;
    
        RETURN;
        
    EXCEPTION
        WHEN e_no_more_rows_needed THEN
            CLOSE c_rows;
    
    END;
    
    -- TODO
    FUNCTION get_value_table_cursor (
        p_query IN VARCHAR2,
        p_bind IN bind := NULL
    )
    RETURN SYS_REFCURSOR IS 
    
        v_cursor SYS_REFCURSOR;
    
    BEGIN
    
        RETURN v_cursor;
        
    END;

BEGIN
    register_messages;
END;

