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
    
    /* Anonymous value creation API */
    
    FUNCTION create_string (
        p_value IN VARCHAR2
    )
    RETURN NUMBER IS
    BEGIN

        RETURN persistent_json_store.create_json(
            json_core.string_events(p_value)
        );

    END;
    
    FUNCTION create_date (
        p_value IN DATE
    )
    RETURN NUMBER IS
    BEGIN

        RETURN persistent_json_store.create_json(
            json_core.date_events(p_value)
        );

    END;

    FUNCTION create_number (
        p_value IN NUMBER
    )
    RETURN NUMBER IS
    BEGIN

        RETURN persistent_json_store.create_json(
            json_core.number_events(p_value)
        );

    END;

    FUNCTION create_boolean (
        p_value IN BOOLEAN
    )
    RETURN NUMBER IS
    BEGIN

        RETURN persistent_json_store.create_json(
            json_core.boolean_events(p_value)
        );

    END;

    FUNCTION create_null
    RETURN NUMBER IS
    BEGIN

        RETURN persistent_json_store.create_json(
            json_core.null_events
        );

    END;

    FUNCTION create_object
    RETURN NUMBER IS
    BEGIN

        RETURN persistent_json_store.create_json(
            json_core.object_events
        );

    END;

    FUNCTION create_array
    RETURN NUMBER IS
    BEGIN

        RETURN persistent_json_store.create_json(
            json_core.array_events
        );

    END;
    
    FUNCTION create_json (
        p_content IN VARCHAR2
    )
    RETURN NUMBER IS
    BEGIN
    
        RETURN persistent_json_store.create_json(json_parser.parse(p_content));
        
    END;
    
    FUNCTION create_json (
        p_content IN CLOB
    )
    RETURN NUMBER IS
    BEGIN
    
        RETURN persistent_json_store.create_json(json_parser.parse(p_content));
        
    END;
    
    FUNCTION create_copy (
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    )
    RETURN NUMBER IS
    BEGIN
    
        RETURN persistent_json_store.create_json(
            persistent_json_store.get_parse_events(
                persistent_json_store.request_value(NULL, p_path, p_bind),
                TRUE
            )
        );
    
    END;

    /* Named property modification API */

    FUNCTION set_string (
        p_path IN VARCHAR2,
        p_value IN VARCHAR2,
        p_bind IN bind := NULL
    )
    RETURN NUMBER IS
    BEGIN

        RETURN persistent_json_store.set_property(
            NULL,
            p_path, 
            p_bind,
            json_core.string_events(p_value)
        );

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
    
    FUNCTION set_date (
        p_path IN VARCHAR2,
        p_value IN DATE,
        p_bind IN bind := NULL
    )
    RETURN NUMBER IS
    BEGIN

        RETURN persistent_json_store.set_property(
            NULL,
            p_path, 
            p_bind,
            json_core.date_events(p_value)
        );

    END;
    
    PROCEDURE set_date(
        p_path IN VARCHAR2,
        p_value IN DATE,
        p_bind IN bind := NULL
    ) IS
        
        v_dummy NUMBER;
        
    BEGIN

        v_dummy := set_date(
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

        RETURN persistent_json_store.set_property(
            NULL,
            p_path, 
            p_bind,
            json_core.number_events(p_value)
        );

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

        RETURN persistent_json_store.set_property(
            NULL,
            p_path, 
            p_bind,
            json_core.boolean_events(p_value)
        );

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

        RETURN persistent_json_store.set_property(
            NULL,
            p_path, 
            p_bind,
            json_core.null_events
        );

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

        RETURN persistent_json_store.set_property(
            NULL,
            p_path, 
            p_bind,
            json_core.object_events
        );

    END;
    
    PROCEDURE set_object (
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    ) IS
        
        v_dummy NUMBER;
        
    BEGIN
    
        v_dummy := persistent_json_store.set_property(
            NULL,
            p_path, 
            p_bind,
            json_core.object_events
        );
        
    END;

    FUNCTION set_array (
        p_path IN VARCHAR2,
        p_bind IN bind := NULL        
    )
    RETURN NUMBER IS
    BEGIN

        RETURN persistent_json_store.set_property(
            NULL,
            p_path, 
            p_bind, 
            json_core.array_events
        );

    END;
    
    PROCEDURE set_array (
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    ) IS
        
        v_dummy NUMBER;
        
    BEGIN
    
        v_dummy := persistent_json_store.set_property(
            NULL,
            p_path,
            p_bind,
            json_core.array_events
        );
        
    END;
    
    FUNCTION set_json (
        p_path IN VARCHAR2,
        p_content IN VARCHAR2,
        p_bind IN bind := NULL
    )
    RETURN NUMBER IS
    BEGIN
    
        RETURN persistent_json_store.set_property(
            NULL,
            p_path, 
            p_bind,
            json_parser.parse(p_content)
        );
        
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
    
    FUNCTION set_json (
        p_path IN VARCHAR2,
        p_content IN CLOB,
        p_bind IN bind := NULL
    )
    RETURN NUMBER IS
    BEGIN
    
        RETURN persistent_json_store.set_property(
            NULL,
            p_path, 
            p_bind,
            json_parser.parse(p_content)
        );
        
    END;

    PROCEDURE set_json (
        p_path IN VARCHAR2,
        p_content IN CLOB,
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
    
    FUNCTION set_copy (
        p_path IN VARCHAR2,
        p_source_path IN VARCHAR2,
        p_source_bind IN bind := NULL
    )
    RETURN NUMBER IS
    BEGIN
    
        RETURN set_copy(p_path, NULL, p_source_path, p_source_bind);
    
    END;
    
    FUNCTION set_copy (
        p_path IN VARCHAR2,
        p_bind IN bind,
        p_source_path IN VARCHAR2,
        p_source_bind IN bind := NULL
    )
    RETURN NUMBER IS
    BEGIN
    
        RETURN persistent_json_store.set_property(
            NULL,
            p_path, 
            p_bind, 
            persistent_json_store.get_parse_events(
                persistent_json_store.request_value(
                    NULL,
                    p_source_path,
                    p_source_bind
                ),
                TRUE
            )
        );
    
    END;
    
    PROCEDURE set_copy (
        p_path IN VARCHAR2,
        p_source_path IN VARCHAR2,
        p_source_bind IN bind := NULL
    ) IS
    BEGIN
    
        set_copy(p_path, NULL, p_source_path, p_source_bind);
    
    END;
    
    PROCEDURE set_copy (
        p_path IN VARCHAR2,
        p_bind IN bind,
        p_source_path IN VARCHAR2,
        p_source_bind IN bind := NULL
    ) IS
    
        v_dummy NUMBER;
    
    BEGIN
    
        v_dummy := set_copy(p_path, p_bind, p_source_path, p_source_bind);
    
    END;
    
    FUNCTION get_string (
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    )
    RETURN VARCHAR2 IS
    BEGIN

        RETURN t_persistent_json(p_path, p_bind).as_string;

    END;
    
    FUNCTION get_date (
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    )
    RETURN DATE IS
    BEGIN

        RETURN t_persistent_json(p_path, p_bind).as_date;

    END;
    
    FUNCTION get_number (
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    )
    RETURN NUMBER IS
    BEGIN

        RETURN t_persistent_json(p_path, p_bind).as_number;

    END;
    
    FUNCTION get_boolean (
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    )
    RETURN BOOLEAN IS
    BEGIN

        RETURN t_persistent_json(p_path, p_bind).as_boolean;

    END;
    
    FUNCTION get_json (
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    )
    RETURN VARCHAR2 IS
    BEGIN
      
        RETURN t_persistent_json(p_path, p_bind).as_json;
    
    END;
    
    FUNCTION get_json (
        p_path IN VARCHAR2,
        p_serialize_nulls IN BOOLEAN,
        p_bind IN bind := NULL
    )
    RETURN VARCHAR2 IS
    BEGIN
      
        RETURN t_persistent_json(p_path, p_bind).as_json(p_serialize_nulls);
    
    END;
    
    FUNCTION get_json_clob (
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    )
    RETURN CLOB IS
    BEGIN
      
        RETURN t_persistent_json(p_path, p_bind).as_json_clob;
    
    END;
    
    FUNCTION get_json_clob (
        p_path IN VARCHAR2,
        p_serialize_nulls IN BOOLEAN,
        p_bind IN bind := NULL
    )
    RETURN CLOB IS
    BEGIN
      
        RETURN t_persistent_json(p_path, p_bind).as_json_clob(p_serialize_nulls);
    
    END;
    
    FUNCTION get_keys (
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    )
    RETURN t_varchars IS
    BEGIN
    
        RETURN persistent_json_store.get_keys(
            persistent_json_store.request_value(NULL, p_path, p_bind, TRUE)
        ); 
    
    END;
        
    
    FUNCTION get_length (
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    )
    RETURN NUMBER IS
    BEGIN
    
        RETURN persistent_json_store.get_length(
            persistent_json_store.request_value(NULL, p_path, p_bind, TRUE)
        );
    
    END;
    
    FUNCTION index_of (
        p_path IN VARCHAR2,
        p_value IN VARCHAR2,
        p_bind IN bind := NULL
    )
    RETURN NUMBER IS
    BEGIN
    
        RETURN persistent_json_store.index_of(
            persistent_json_store.request_value(NULL, p_path, p_bind, TRUE),
            'S',
            p_value,
            0
        );
    
    END;
    
    FUNCTION index_of (
        p_path IN VARCHAR2,
        p_value IN VARCHAR2,
        p_from_index IN NUMBER,
        p_bind IN bind := NULL
    )
    RETURN NUMBER IS
    BEGIN
    
        RETURN persistent_json_store.index_of(
            persistent_json_store.request_value(NULL, p_path, p_bind, TRUE),
            'S',
            p_value,
            p_from_index
        );
    
    END;
    
    FUNCTION index_of (
        p_path IN VARCHAR2,
        p_value IN DATE,
        p_bind IN bind := NULL
    )
    RETURN NUMBER IS
    BEGIN
    
        RETURN persistent_json_store.index_of(
            persistent_json_store.request_value(NULL, p_path, p_bind, TRUE),
            'S',
            json_core.to_json_char(p_value),
            0
        );
    
    END;
    
    FUNCTION index_of (
        p_path IN VARCHAR2,
        p_value IN DATE,
        p_from_index IN NUMBER,
        p_bind IN bind := NULL
    )
    RETURN NUMBER IS
    BEGIN
    
        RETURN persistent_json_store.index_of(
            persistent_json_store.request_value(NULL, p_path, p_bind, TRUE),
            'S',
            json_core.to_json_char(p_value),
            p_from_index
        );
    
    END;
    
    FUNCTION index_of (
        p_path IN VARCHAR2,
        p_value IN NUMBER,
        p_bind IN bind := NULL
    )
    RETURN NUMBER IS
    BEGIN
    
        RETURN persistent_json_store.index_of(
            persistent_json_store.request_value(NULL, p_path, p_bind, TRUE),
            'N',
            json_core.to_json_char(p_value),
            0
        );
    
    END;
    
    FUNCTION index_of (
        p_path IN VARCHAR2,
        p_value IN NUMBER,
        p_from_index IN NUMBER,
        p_bind IN bind := NULL
    )
    RETURN NUMBER IS
    BEGIN
    
        RETURN persistent_json_store.index_of(
            persistent_json_store.request_value(NULL, p_path, p_bind, TRUE),
            'N',
            json_core.to_json_char(p_value),
            p_from_index
        );
    
    END;
    
    FUNCTION index_of (
        p_path IN VARCHAR2,
        p_value IN BOOLEAN,
        p_from_index IN NUMBER,
        p_bind IN bind := NULL
    )
    RETURN NUMBER IS
    BEGIN
    
        RETURN persistent_json_store.index_of(
            persistent_json_store.request_value(NULL, p_path, p_bind, TRUE),
            'B',
            json_core.to_json_char(p_value),
            p_from_index
        );
    
    END;
    
    FUNCTION index_of_null (
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    )
    RETURN NUMBER IS
    BEGIN
    
        RETURN persistent_json_store.index_of(
            persistent_json_store.request_value(NULL, p_path, p_bind, TRUE),
            'E',
            NULL,
            0
        );
    
    END;
    
    FUNCTION index_of_null (
        p_path IN VARCHAR2,
        p_from_index IN NUMBER,
        p_bind IN bind := NULL
    )
    RETURN NUMBER IS
    BEGIN
    
        RETURN persistent_json_store.index_of(
            persistent_json_store.request_value(NULL, p_path, p_bind, TRUE),
            'E',
            NULL,
            p_from_index
        );
    
    END;
    
    FUNCTION push_string (
        p_path IN VARCHAR2,
        p_value IN VARCHAR2,
        p_bind IN bind := NULL
    )
    RETURN NUMBER IS
    BEGIN

        RETURN t_persistent_json(p_path, p_bind).push_string(p_value).id;

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

        RETURN t_persistent_json(p_path, p_bind).push_number(p_value).id;

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

        RETURN t_persistent_json(p_path, p_bind).push_boolean(p_value).id;

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

        RETURN t_persistent_json(p_path, p_bind).push_null().id;

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

        RETURN t_persistent_json(p_path, p_bind).push_object().id;

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

        RETURN t_persistent_json(p_path, p_bind).push_array().id;
        
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
    BEGIN
    
        RETURN t_persistent_json(p_path, p_bind).push_json(p_content).id;
        
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
        
    FUNCTION push_json (
        p_path IN VARCHAR2,
        p_content IN CLOB,
        p_bind IN bind := NULL
    )
    RETURN NUMBER IS
    BEGIN
    
        RETURN t_persistent_json(p_path, p_bind).push_json(p_content).id;
        
    END;
        
    PROCEDURE push_json (
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
    BEGIN
    
        persistent_json_store.delete_value(
            persistent_json_store.request_value(NULL, p_path, p_bind, TRUE)
        );
    
    END;
    
    PROCEDURE pin (
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    ) IS
    BEGIN
    
        persistent_json_store.pin_value(
            persistent_json_store.request_value(NULL, p_path, p_bind, TRUE),
            FALSE
        );
    
    END;
    
    PROCEDURE pin (
        p_path IN VARCHAR2,
        p_pin_tree IN BOOLEAN,
        p_bind IN bind := NULL
    ) IS
    BEGIN
    
        persistent_json_store.pin_value(
            persistent_json_store.request_value(NULL, p_path, p_bind, TRUE),
            p_pin_tree
        );
    
    END;
    
    PROCEDURE unpin (
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    ) IS
    BEGIN
        
        persistent_json_store.unpin_value(
            persistent_json_store.request_value(NULL, p_path, p_bind, TRUE),
            FALSE
        );
    
    END;
    
    PROCEDURE unpin (
        p_path IN VARCHAR2,
        p_unpin_tree IN BOOLEAN,
        p_bind IN bind := NULL
    ) IS
    BEGIN
        
        persistent_json_store.unpin_value(
            persistent_json_store.request_value(NULL, p_path, p_bind, TRUE),
            p_unpin_tree
        );
    
    END;
    
END;

