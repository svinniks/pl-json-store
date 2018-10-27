CREATE OR REPLACE TYPE BODY t_persistent_json IS

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
    
    STATIC FUNCTION create_string (
        p_value IN VARCHAR2
    )
    RETURN t_json IS
    BEGIN
        
        RETURN t_persistent_json(
            persistent_json_store.create_json(
                json_core.string_events(p_value)
            )
        );
    
    END;
    
    STATIC FUNCTION create_number (
        p_value IN NUMBER
    )
    RETURN t_json IS
    BEGIN
        
        RETURN t_persistent_json(
            persistent_json_store.create_json(
                json_core.number_events(p_value)
            )
        );
    
    END;
    
    STATIC FUNCTION create_date (
        p_value IN DATE
    )
    RETURN t_json IS
    BEGIN
        
        RETURN t_persistent_json(
            persistent_json_store.create_json(
                json_core.date_events(p_value)
            )
        );
    
    END;
    
    STATIC FUNCTION create_boolean (
        p_value IN BOOLEAN
    )
    RETURN t_json IS
    BEGIN
        
        RETURN t_persistent_json(
            persistent_json_store.create_json(
                json_core.boolean_events(p_value)
            )
        );
    
    END;
    
    STATIC FUNCTION create_null
    RETURN t_json IS
    BEGIN
        
        RETURN t_persistent_json(
            persistent_json_store.create_json(
                json_core.null_events
            )
        );
    
    END;
    
    STATIC FUNCTION create_object
    RETURN t_json IS
    BEGIN
        
        RETURN t_persistent_json(
            persistent_json_store.create_json(
                json_core.object_events
            )
        );
    
    END;
    
    STATIC FUNCTION create_array
    RETURN t_json IS
    BEGIN
        
        RETURN t_persistent_json(
            persistent_json_store.create_json(
                json_core.array_events
            )
        );
    
    END;
    
    STATIC FUNCTION create_json (
        p_value IN t_json
    )
    RETURN t_json IS
    BEGIN
    
        RETURN t_persistent_json(
            persistent_json_store.create_json(p_value.get_parse_events(TRUE))
        );
        
    END;
    
    STATIC FUNCTION create_json (
        p_content VARCHAR2
    )
    RETURN t_json IS
    BEGIN
        
        RETURN t_persistent_json(
            persistent_json_store.create_json(
                json_parser.parse(p_content)
            )
        );
    
    END;
    
    STATIC FUNCTION create_json (
        p_content CLOB
    )
    RETURN t_json IS
    BEGIN
        
        RETURN t_persistent_json(
            persistent_json_store.create_json(
                json_parser.parse(p_content)
            )
        );
    
    END;
    
    STATIC FUNCTION create_json (
        p_builder t_json_builder
    )
    RETURN t_json IS
    BEGIN
        
        RETURN t_persistent_json(
            persistent_json_store.create_json(
                p_builder.build_parse_events
            )
        );
    
    END;
    
    CONSTRUCTOR FUNCTION t_persistent_json (
        id NUMBER
    )
    RETURN self AS RESULT IS
    BEGIN
    
        json_core.touch;
        self.id := id;
        
        RETURN;
        
    END;
    
    CONSTRUCTOR FUNCTION t_persistent_json (
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    )
    RETURN self AS RESULT IS
    BEGIN
    
        id := persistent_json_store.request_value(NULL, p_path, p_bind, TRUE);
    
        RETURN;
    
    END;

    OVERRIDING MEMBER PROCEDURE dump (
        self IN t_persistent_json,
        p_parent_id OUT NUMBER,
        p_type OUT CHAR,
        p_value OUT VARCHAR2
    ) IS
        v_value json_core.t_json_value;
    BEGIN
    
        v_value := persistent_json_store.get_value(id);
        
        p_parent_id := v_value.parent_id;
        p_type := v_value.type;
        p_value := v_value.value;
    
    END;
    
    OVERRIDING MEMBER FUNCTION get_parse_events (
        p_serialize_nulls IN BOOLEAN
    )
    RETURN t_varchars IS
    BEGIN
        RETURN persistent_json_store.get_parse_events(id, p_serialize_nulls);
    END;
    
    OVERRIDING MEMBER FUNCTION get_parent
    RETURN t_json IS
    
        v_parent_id NUMBER;
        v_type CHAR;
        v_value VARCHAR2(4000);
    
    BEGIN
    
        dump(v_parent_id, v_type, v_value);
    
        IF v_parent_id IS NULL THEN 
            RETURN NULL;
        ELSE
            RETURN t_persistent_json(v_parent_id);
        END IF;
    
    END;
    
    OVERRIDING MEMBER FUNCTION get (
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    )
    RETURN t_json IS
        v_value_id NUMBER;
    BEGIN
    
        v_value_id := persistent_json_store.request_value(id, p_path, p_bind, FALSE);
        
        IF v_value_id IS NULL THEN
            RETURN NULL;
        ELSE
            RETURN t_persistent_json(v_value_id);
        END IF; 
    
    END;
    
    OVERRIDING MEMBER FUNCTION get_keys
    RETURN t_varchars IS
    BEGIN
        RETURN persistent_json_store.get_keys(id);
    END;
    
    OVERRIDING MEMBER FUNCTION get_length
    RETURN NUMBER IS
    BEGIN
        RETURN persistent_json_store.get_length(id);
    END;
         
    OVERRIDING MEMBER FUNCTION index_of (
        p_type IN CHAR 
       ,p_value IN VARCHAR2
       ,p_from_index IN NATURALN
    )
    RETURN NUMBER IS
    BEGIN
        RETURN persistent_json_store.index_of(id, p_type, p_value, p_from_index);
    END;
    
    OVERRIDING MEMBER FUNCTION set_json (
        p_path IN VARCHAR2,
        p_content_parse_events IN t_varchars,
        p_bind IN bind
    ) 
    RETURN t_json IS
    BEGIN
    
        RETURN t_persistent_json(
            persistent_json_store.set_property(
                id,
                p_path,
                p_bind,
                p_content_parse_events
            )
        );
    
    END;
    
    OVERRIDING MEMBER PROCEDURE remove IS
    BEGIN
        persistent_json_store.delete_value(id);
        id := NULL;
    END;
    
    OVERRIDING MEMBER PROCEDURE pin (
        self IN t_persistent_json,
        p_pin_tree IN BOOLEAN := FALSE
    ) IS
    BEGIN
        persistent_json_store.pin_value(id, p_pin_tree);
    END;
    
    OVERRIDING MEMBER PROCEDURE unpin (
        self IN t_persistent_json,
        p_unpin_tree IN BOOLEAN := FALSE
    ) IS
    BEGIN
        persistent_json_store.unpin_value(id, p_unpin_tree);
    END;
    
    OVERRIDING MEMBER FUNCTION get_table_5 (
        p_query IN VARCHAR2,
        p_bind IN bind := NULL
    )
    RETURN t_5_value_table PIPELINED IS
    
        e_no_more_rows_needed EXCEPTION;
        PRAGMA EXCEPTION_INIT(e_no_more_rows_needed, -6548);

        v_cursor_id NUMBER;
        v_column_count PLS_INTEGER;
        
        v_row_buffer t_varchars;
        v_fetched_row_count PLS_INTEGER;
        
        v_row t_5_value_row;
        
        FUNCTION get_value (
            p_row_i IN PLS_INTEGER,
            p_column_i IN PLS_INTEGER
        )
        RETURN VARCHAR2 IS
        BEGIN
            IF p_column_i > v_column_count THEN
                RETURN NULL;
            ELSE
                RETURN v_row_buffer((p_column_i - 1) * persistent_json_store.c_ROW_BUFFER_SIZE + p_row_i); 
            END IF;
        END;
        
    BEGIN
        
        persistent_json_store.prepare_table_query(
            id,
            p_query,
            p_bind,
            v_cursor_id,
            v_column_count
        );
        
        v_row_buffer := t_varchars();
        v_row_buffer.EXTEND(v_column_count * persistent_json_store.c_ROW_BUFFER_SIZE);
    
        v_row := t_5_value_row(NULL, NULL, NULL, NULL, NULL);
    
        LOOP
        
            persistent_json_store.fetch_table_rows (
                v_cursor_id,
                v_column_count,
                v_fetched_row_count,
                v_row_buffer
            );
            
            FOR v_row_i IN 1..v_fetched_row_count LOOP
            
                v_row.value_1 := get_value(v_row_i, 1);
                v_row.value_2 := get_value(v_row_i, 2);
                v_row.value_3 := get_value(v_row_i, 3);
                v_row.value_4 := get_value(v_row_i, 4);
                v_row.value_5 := get_value(v_row_i, 5);
                
                PIPE ROW(v_row);
                
            END LOOP;
            
            EXIT WHEN v_fetched_row_count < persistent_json_store.c_ROW_BUFFER_SIZE;
        
        END LOOP;
    
        DBMS_SQL.CLOSE_CURSOR(v_cursor_id);
        
        RETURN;
            
    EXCEPTION
        WHEN e_no_more_rows_needed THEN
            DBMS_SQL.CLOSE_CURSOR(v_cursor_id);
    END;
    
    OVERRIDING MEMBER FUNCTION get_table_10 (
        p_query IN VARCHAR2,
        p_bind IN bind := NULL
    )
    RETURN t_10_value_table PIPELINED IS
    
        e_no_more_rows_needed EXCEPTION;
        PRAGMA EXCEPTION_INIT(e_no_more_rows_needed, -6548);

        v_cursor_id NUMBER;
        v_column_count PLS_INTEGER;
        
        v_row_buffer t_varchars;
        v_fetched_row_count PLS_INTEGER;
        
        v_row t_10_value_row;
        
        FUNCTION get_value (
            p_row_i IN PLS_INTEGER,
            p_column_i IN PLS_INTEGER
        )
        RETURN VARCHAR2 IS
        BEGIN
            IF p_column_i > v_column_count THEN
                RETURN NULL;
            ELSE
                RETURN v_row_buffer((p_column_i - 1) * persistent_json_store.c_ROW_BUFFER_SIZE + p_row_i); 
            END IF;
        END;
        
    BEGIN
        
        persistent_json_store.prepare_table_query(
            id,
            p_query,
            p_bind,
            v_cursor_id,
            v_column_count
        );
        
        v_row_buffer := t_varchars();
        v_row_buffer.EXTEND(v_column_count * persistent_json_store.c_ROW_BUFFER_SIZE);
    
        v_row := t_10_value_row(NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
    
        LOOP
        
            persistent_json_store.fetch_table_rows (
                v_cursor_id,
                v_column_count,
                v_fetched_row_count,
                v_row_buffer
            );
            
            FOR v_row_i IN 1..v_fetched_row_count LOOP
            
                v_row.value_1 := get_value(v_row_i, 1);
                v_row.value_2 := get_value(v_row_i, 2);
                v_row.value_3 := get_value(v_row_i, 3);
                v_row.value_4 := get_value(v_row_i, 4);
                v_row.value_5 := get_value(v_row_i, 5);
                v_row.value_6 := get_value(v_row_i, 6);
                v_row.value_7 := get_value(v_row_i, 7);
                v_row.value_8 := get_value(v_row_i, 8);
                v_row.value_9 := get_value(v_row_i, 9);
                v_row.value_10 := get_value(v_row_i, 10);
                
                PIPE ROW(v_row);
                
            END LOOP;
            
            EXIT WHEN v_fetched_row_count < persistent_json_store.c_ROW_BUFFER_SIZE;
        
        END LOOP;
    
        DBMS_SQL.CLOSE_CURSOR(v_cursor_id);
        
        RETURN;
            
    EXCEPTION
        WHEN e_no_more_rows_needed THEN
            DBMS_SQL.CLOSE_CURSOR(v_cursor_id);
    END;
    
    OVERRIDING MEMBER FUNCTION get_table_15 (
        p_query IN VARCHAR2,
        p_bind IN bind := NULL
    )
    RETURN t_15_value_table PIPELINED IS
    
        e_no_more_rows_needed EXCEPTION;
        PRAGMA EXCEPTION_INIT(e_no_more_rows_needed, -6548);

        v_cursor_id NUMBER;
        v_column_count PLS_INTEGER;
        
        v_row_buffer t_varchars;
        v_fetched_row_count PLS_INTEGER;
        
        v_row t_15_value_row;
        
        FUNCTION get_value (
            p_row_i IN PLS_INTEGER,
            p_column_i IN PLS_INTEGER
        )
        RETURN VARCHAR2 IS
        BEGIN
            IF p_column_i > v_column_count THEN
                RETURN NULL;
            ELSE
                RETURN v_row_buffer((p_column_i - 1) * persistent_json_store.c_ROW_BUFFER_SIZE + p_row_i); 
            END IF;
        END;
        
    BEGIN
        
        persistent_json_store.prepare_table_query(
            id,
            p_query,
            p_bind,
            v_cursor_id,
            v_column_count
        );
        
        v_row_buffer := t_varchars();
        v_row_buffer.EXTEND(v_column_count * persistent_json_store.c_ROW_BUFFER_SIZE);
    
        v_row := t_15_value_row(NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
    
        LOOP
        
            persistent_json_store.fetch_table_rows (
                v_cursor_id,
                v_column_count,
                v_fetched_row_count,
                v_row_buffer
            );
            
            FOR v_row_i IN 1..v_fetched_row_count LOOP
            
                v_row.value_1 := get_value(v_row_i, 1);
                v_row.value_2 := get_value(v_row_i, 2);
                v_row.value_3 := get_value(v_row_i, 3);
                v_row.value_4 := get_value(v_row_i, 4);
                v_row.value_5 := get_value(v_row_i, 5);
                v_row.value_6 := get_value(v_row_i, 6);
                v_row.value_7 := get_value(v_row_i, 7);
                v_row.value_8 := get_value(v_row_i, 8);
                v_row.value_9 := get_value(v_row_i, 9);
                v_row.value_10 := get_value(v_row_i, 10);
                v_row.value_11 := get_value(v_row_i, 11);
                v_row.value_12 := get_value(v_row_i, 12);
                v_row.value_13 := get_value(v_row_i, 13);
                v_row.value_14 := get_value(v_row_i, 14);
                v_row.value_15 := get_value(v_row_i, 15);
                
                PIPE ROW(v_row);
                
            END LOOP;
            
            EXIT WHEN v_fetched_row_count < persistent_json_store.c_ROW_BUFFER_SIZE;
        
        END LOOP;
    
        DBMS_SQL.CLOSE_CURSOR(v_cursor_id);
        
        RETURN;
            
    EXCEPTION
        WHEN e_no_more_rows_needed THEN
            DBMS_SQL.CLOSE_CURSOR(v_cursor_id);
    END;

    OVERRIDING MEMBER FUNCTION get_table_20 (
        p_query IN VARCHAR2,
        p_bind IN bind := NULL
    )
    RETURN t_20_value_table PIPELINED IS
    
        e_no_more_rows_needed EXCEPTION;
        PRAGMA EXCEPTION_INIT(e_no_more_rows_needed, -6548);

        v_cursor_id NUMBER;
        v_column_count PLS_INTEGER;
        
        v_row_buffer t_varchars;
        v_fetched_row_count PLS_INTEGER;
        
        v_row t_20_value_row;
        
        FUNCTION get_value (
            p_row_i IN PLS_INTEGER,
            p_column_i IN PLS_INTEGER
        )
        RETURN VARCHAR2 IS
        BEGIN
            IF p_column_i > v_column_count THEN
                RETURN NULL;
            ELSE
                RETURN v_row_buffer((p_column_i - 1) * persistent_json_store.c_ROW_BUFFER_SIZE + p_row_i); 
            END IF;
        END;
        
    BEGIN
        
        persistent_json_store.prepare_table_query(
            id,
            p_query,
            p_bind,
            v_cursor_id,
            v_column_count
        );
        
        v_row_buffer := t_varchars();
        v_row_buffer.EXTEND(v_column_count * persistent_json_store.c_ROW_BUFFER_SIZE);
    
        v_row := t_20_value_row(NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
    
        LOOP
        
            persistent_json_store.fetch_table_rows (
                v_cursor_id,
                v_column_count,
                v_fetched_row_count,
                v_row_buffer
            );
            
            FOR v_row_i IN 1..v_fetched_row_count LOOP
            
                v_row.value_1 := get_value(v_row_i, 1);
                v_row.value_2 := get_value(v_row_i, 2);
                v_row.value_3 := get_value(v_row_i, 3);
                v_row.value_4 := get_value(v_row_i, 4);
                v_row.value_5 := get_value(v_row_i, 5);
                v_row.value_6 := get_value(v_row_i, 6);
                v_row.value_7 := get_value(v_row_i, 7);
                v_row.value_8 := get_value(v_row_i, 8);
                v_row.value_9 := get_value(v_row_i, 9);
                v_row.value_10 := get_value(v_row_i, 10);
                v_row.value_11 := get_value(v_row_i, 11);
                v_row.value_12 := get_value(v_row_i, 12);
                v_row.value_13 := get_value(v_row_i, 13);
                v_row.value_14 := get_value(v_row_i, 14);
                v_row.value_15 := get_value(v_row_i, 15);
                v_row.value_16 := get_value(v_row_i, 16);
                v_row.value_17 := get_value(v_row_i, 17);
                v_row.value_18 := get_value(v_row_i, 18);
                v_row.value_19 := get_value(v_row_i, 19);
                v_row.value_20 := get_value(v_row_i, 20);
                
                PIPE ROW(v_row);
                
            END LOOP;
            
            EXIT WHEN v_fetched_row_count < persistent_json_store.c_ROW_BUFFER_SIZE;
        
        END LOOP;
    
        DBMS_SQL.CLOSE_CURSOR(v_cursor_id);
        
        RETURN;
            
    EXCEPTION
        WHEN e_no_more_rows_needed THEN
            DBMS_SQL.CLOSE_CURSOR(v_cursor_id);
    END;
        
    -- JSON filter instantiation method 
    
    MEMBER FUNCTION filter
    RETURN t_json_filter IS
    BEGIN
        RETURN t_json_filter(p_base_value_id => id);
    END;

END;