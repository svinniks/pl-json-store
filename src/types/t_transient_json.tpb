CREATE OR REPLACE TYPE BODY t_transient_json IS

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
        
        RETURN t_transient_json(
            transient_json_store.create_json(
                json_core.string_events(p_value)
            )
        );
    
    END;
    
    STATIC FUNCTION create_number (
        p_value IN NUMBER
    )
    RETURN t_json IS
    BEGIN
        
        RETURN t_transient_json(
            transient_json_store.create_json(
                json_core.number_events(p_value)
            )
        );
    
    END;
    
    STATIC FUNCTION create_date (
        p_value IN DATE
    )
    RETURN t_json IS
    BEGIN
        
        RETURN t_transient_json(
            transient_json_store.create_json(
                json_core.date_events(p_value)
            )
        );
    
    END;
    
    STATIC FUNCTION create_boolean (
        p_value IN BOOLEAN
    )
    RETURN t_json IS
    BEGIN
        
        RETURN t_transient_json(
            transient_json_store.create_json(
                json_core.boolean_events(p_value)
            )
        );
    
    END;
    
    STATIC FUNCTION create_null
    RETURN t_json IS
    BEGIN
        
        RETURN t_transient_json(
            transient_json_store.create_json(
                json_core.null_events
            )
        );
    
    END;
    
    STATIC FUNCTION create_object
    RETURN t_json IS
    BEGIN
        
        RETURN t_transient_json(
            transient_json_store.create_json(
                json_core.object_events
            )
        );
    
    END;
    
    STATIC FUNCTION create_array
    RETURN t_json IS
    BEGIN
        
        RETURN t_transient_json(
            transient_json_store.create_json(
                json_core.array_events
            )
        );
    
    END;
    
    STATIC FUNCTION create_json (
        p_value IN t_json
    )
    RETURN t_json IS
    BEGIN
    
        RETURN t_transient_json(
            transient_json_store.create_json(p_value.get_parse_events(TRUE))
        );
        
    END;
    
    STATIC FUNCTION create_json (
        p_content VARCHAR2
    )
    RETURN t_json IS
    BEGIN
        
        RETURN t_transient_json(
            transient_json_store.create_json(
                json_parser.parse(p_content)
            )
        );
    
    END;
    
    STATIC FUNCTION create_json (
        p_content CLOB
    )
    RETURN t_json IS
    BEGIN
        
        RETURN t_transient_json(
            transient_json_store.create_json(
                json_parser.parse(p_content)
            )
        );
    
    END;
    
    STATIC FUNCTION create_json (
        p_builder t_json_builder
    )
    RETURN t_json IS
    BEGIN
        
        RETURN t_transient_json(
            transient_json_store.create_json(
                p_builder.build_parse_events
            )
        );
    
    END;
    
    CONSTRUCTOR FUNCTION t_transient_json (
        id NUMBER
    )
    RETURN self AS RESULT IS
    BEGIN
    
        json_core.touch;
        self.id := id;
        
        RETURN;
        
    END;
    
    CONSTRUCTOR FUNCTION t_transient_json (
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    )
    RETURN self AS RESULT IS
    BEGIN
    
        id := transient_json_store.request_value(NULL, p_path, p_bind, TRUE);
    
        RETURN;
    
    END;

    OVERRIDING MEMBER PROCEDURE dump (
        self IN t_transient_json,
        p_parent_id OUT NUMBER,
        p_type OUT CHAR,
        p_value OUT VARCHAR2
    ) IS
        v_value json_core.t_json_value;
    BEGIN
    
        v_value := transient_json_store.get_value(id);
        
        p_parent_id := v_value.parent_id;
        p_type := v_value.type;
        p_value := v_value.value;
    
    END;
    
    OVERRIDING MEMBER FUNCTION get_parse_events (
        p_serialize_nulls IN BOOLEAN
    )
    RETURN t_varchars IS
    BEGIN
        RETURN transient_json_store.get_parse_events(id, p_serialize_nulls);
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
            RETURN t_transient_json(v_parent_id);
        END IF;
    
    END;
    
    OVERRIDING MEMBER FUNCTION get (
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    )
    RETURN t_json IS
        v_value_id NUMBER;
    BEGIN
    
        v_value_id := transient_json_store.request_value(id, p_path, p_bind, FALSE);
        
        IF v_value_id IS NULL THEN
            RETURN NULL;
        ELSE
            RETURN t_transient_json(v_value_id);
        END IF; 
    
    END;
    
    OVERRIDING MEMBER FUNCTION get_keys
    RETURN t_varchars IS
    BEGIN
        RETURN transient_json_store.get_keys(id);
    END;
    
    OVERRIDING MEMBER FUNCTION get_length
    RETURN NUMBER IS
    BEGIN
        RETURN transient_json_store.get_length(id);
    END;
         
    OVERRIDING MEMBER FUNCTION index_of (
        p_type IN CHAR 
       ,p_value IN VARCHAR2
       ,p_from_index IN NATURALN
    )
    RETURN NUMBER IS
    BEGIN
        RETURN transient_json_store.index_of(id, p_type, p_value, p_from_index);
    END;
    
    OVERRIDING MEMBER FUNCTION set_json (
        p_path IN VARCHAR2,
        p_content_parse_events IN t_varchars,
        p_bind IN bind
    ) 
    RETURN t_json IS
    BEGIN
    
        RETURN t_transient_json(
            transient_json_store.set_property(
                id,
                p_path,
                p_bind,
                p_content_parse_events
            )
        );
    
    END;
    
    OVERRIDING MEMBER PROCEDURE remove IS
    BEGIN
        transient_json_store.delete_value(id);
        id := NULL;
    END;
    
    OVERRIDING MEMBER PROCEDURE pin (
        self IN t_transient_json,
        p_pin_tree IN BOOLEAN := FALSE
    ) IS
    BEGIN
        transient_json_store.pin_value(id, p_pin_tree);
    END;
    
    OVERRIDING MEMBER PROCEDURE unpin (
        self IN t_transient_json,
        p_unpin_tree IN BOOLEAN := FALSE
    ) IS
    BEGIN
        transient_json_store.unpin_value(id, p_unpin_tree);
    END;
    
    OVERRIDING MEMBER FUNCTION get_table_5 (
        p_query IN VARCHAR2,
        p_bind IN bind := NULL
    )
    RETURN t_5_value_table PIPELINED IS
    
        v_columns transient_json_store.t_t_varchars;
        
        v_column_count PLS_INTEGER;
        v_row_count PLS_INTEGER;
        
        FUNCTION get_value (
            p_row IN PLS_INTEGER,
            p_column IN PLS_INTEGER
        ) 
        RETURN VARCHAR2 IS
        BEGIN
            IF p_column > v_column_count THEN
                RETURN NULL;
            ELSE
                RETURN v_columns(p_column)(p_row);
            END IF;
        END;
    
    BEGIN
    
        v_columns := transient_json_store.get_table(id, p_query, p_bind);
        
        v_column_count := v_columns.COUNT;
        v_row_count := v_columns(1).COUNT;
        
        FOR v_i IN 1..v_row_count LOOP
        
            PIPE ROW (t_5_value_row(
                get_value(v_i, 1),
                get_value(v_i, 2),
                get_value(v_i, 3),
                get_value(v_i, 4),
                get_value(v_i, 5)
            ));
            
        END LOOP;
        
        RETURN;
        
    END;
    
END;