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

        RETURN json_core.create_json(
            json_core.string_events(p_value)
        );

    END;
    
    FUNCTION create_date (
        p_value IN DATE
    )
    RETURN NUMBER IS
    BEGIN

        RETURN json_core.create_json(
            json_core.date_events(p_value)
        );

    END;

    FUNCTION create_number (
        p_value IN NUMBER
    )
    RETURN NUMBER IS
    BEGIN

        RETURN json_core.create_json(
            json_core.number_events(p_value)
        );

    END;

    FUNCTION create_boolean (
        p_value IN BOOLEAN
    )
    RETURN NUMBER IS
    BEGIN

        RETURN json_core.create_json(
            json_core.boolean_events(p_value)
        );

    END;

    FUNCTION create_null
    RETURN NUMBER IS
    BEGIN

        RETURN json_core.create_json(
            json_core.null_events
        );

    END;

    FUNCTION create_object
    RETURN NUMBER IS
    BEGIN

        RETURN json_core.create_json(
            json_core.object_events
        );

    END;

    FUNCTION create_array
    RETURN NUMBER IS
    BEGIN

        RETURN json_core.create_json(
            json_core.array_events
        );

    END;
    
    FUNCTION create_json (
        p_content IN VARCHAR2
    )
    RETURN NUMBER IS
    
        v_parse_events json_parser.t_parse_events;
    
    BEGIN
    
        json_parser.parse(p_content, v_parse_events);
    
        RETURN json_core.create_json(v_parse_events);
        
    END;
    
    FUNCTION create_json (
        p_content IN CLOB
    )
    RETURN NUMBER IS
    
        v_parse_events json_parser.t_parse_events;
    
    BEGIN
    
        json_parser.parse(p_content, v_parse_events);
    
        RETURN json_core.create_json(v_parse_events);
        
    END;
    
    FUNCTION create_copy (
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    )
    RETURN NUMBER IS
        
        v_parse_events json_parser.t_parse_events;
    
    BEGIN
    
        json_core.get_parse_events(
            json_core.request_value(p_path, p_bind, TRUE), 
            v_parse_events
        );
    
        RETURN json_core.create_json(v_parse_events);
    
    END;

    /* Named property modification API */

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

        RETURN json_core.set_property(
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

        RETURN json_core.set_property(
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

        RETURN json_core.set_property(
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

        RETURN json_core.set_property(
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

        RETURN json_core.set_property(
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
    
        v_dummy := json_core.set_property(
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

        RETURN json_core.set_property(
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
    
        v_dummy := json_core.set_property(
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
    
        v_parse_events json_parser.t_parse_events;
        
    BEGIN
    
        json_parser.parse(p_content, v_parse_events);
    
        RETURN json_core.set_property(
            p_path, 
            p_bind,
            v_parse_events
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
    
        v_parse_events json_parser.t_parse_events;
        
    BEGIN
    
        json_parser.parse(p_content, v_parse_events);
    
        RETURN json_core.set_property(
            p_path, 
            p_bind,
            v_parse_events
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
    
        v_parse_events json_parser.t_parse_events;
    
    BEGIN
    
        json_core.get_parse_events(
            json_core.request_value(p_source_path, p_source_bind), 
            v_parse_events
        );
    
        RETURN json_core.set_property(
            p_path, 
            p_bind, 
            v_parse_events
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

        RETURN json_core.get_string(
            json_core.request_value( p_path, p_bind)
        );

    END;
    
    FUNCTION get_date (
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    )
    RETURN DATE IS
    BEGIN

        RETURN json_core.get_date(
            json_core.request_value( p_path, p_bind)
        );

    END;
    
    FUNCTION get_number (
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    )
    RETURN NUMBER IS
    BEGIN

        RETURN json_core.get_number(
            json_core.request_value(p_path, p_bind)
        );

    END;
    
    FUNCTION get_boolean (
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    )
    RETURN BOOLEAN IS
    BEGIN

        RETURN json_core.get_boolean(
            json_core.request_value(p_path, p_bind)
        );

    END;
    
    FUNCTION get_json (
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    )
    RETURN VARCHAR2 IS
    BEGIN
      
        RETURN json_core.get_json(
            json_core.request_value(p_path, p_bind),
            TRUE
        );
    
    END;
    
    FUNCTION get_json (
        p_path IN VARCHAR2,
        p_serialize_nulls IN json_core.BOOLEANN,
        p_bind IN bind := NULL
    )
    RETURN VARCHAR2 IS
    BEGIN
      
        RETURN json_core.get_json(
            json_core.request_value(p_path, p_bind),
            p_serialize_nulls
        );
    
    END;
    
    FUNCTION get_json_clob (
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    )
    RETURN CLOB IS
    BEGIN
      
        RETURN json_core.get_json_clob(
            json_core.request_value(p_path, p_bind),
            TRUE
        );
    
    END;
    
    FUNCTION get_json_clob (
        p_path IN VARCHAR2,
        p_serialize_nulls IN json_core.BOOLEANN,
        p_bind IN bind := NULL
    )
    RETURN CLOB IS
    BEGIN
      
        RETURN json_core.get_json_clob(
            json_core.request_value(p_path, p_bind),
            p_serialize_nulls
        );
    
    END;
    
    FUNCTION apply_string (
        p_path IN VARCHAR2,
        p_value IN VARCHAR2,
        p_bind IN bind := NULL
    )
    RETURN NUMBER IS
    BEGIN
    
        RETURN json_core.apply_json (
            json_core.request_value(p_path, p_bind, TRUE),
            json_core.string_events(p_value),
            TRUE
        );
    
    END;
    
    PROCEDURE apply_string (
        p_path IN VARCHAR2,
        p_value IN VARCHAR2,
        p_bind IN bind := NULL
    ) IS
      
        v_dummy NUMBER;
       
    BEGIN
    
        v_dummy := apply_string(p_path, p_value, p_bind);
    
    END;
    
    FUNCTION apply_date (
        p_path IN VARCHAR2,
        p_value IN DATE,
        p_bind IN bind := NULL
    )
    RETURN NUMBER IS
    BEGIN
    
        RETURN json_core.apply_json (
            json_core.request_value(p_path, p_bind, TRUE),
            json_core.date_events(p_value),
            TRUE
        );
    
    END;
    
    PROCEDURE apply_date (
        p_path IN VARCHAR2,
        p_value IN DATE,
        p_bind IN bind := NULL
    ) IS
      
        v_dummy NUMBER;
       
    BEGIN
    
        v_dummy := apply_date(p_path, p_value, p_bind);
    
    END;
    
    FUNCTION apply_number (
        p_path IN VARCHAR2,
        p_value IN NUMBER,
        p_bind IN bind := NULL
    )
    RETURN NUMBER IS
    BEGIN
    
        RETURN json_core.apply_json (
            json_core.request_value(p_path, p_bind, TRUE),
            json_core.number_events(p_value),
            TRUE
        );
    
    END;
    
    PROCEDURE apply_number (
        p_path IN VARCHAR2,
        p_value IN NUMBER,
        p_bind IN bind := NULL
    ) IS
      
        v_dummy NUMBER;
       
    BEGIN
    
        v_dummy := apply_number(p_path, p_value, p_bind);
    
    END;
    
    FUNCTION apply_boolean (
        p_path IN VARCHAR2,
        p_value IN BOOLEAN,
        p_bind IN bind := NULL
    )
    RETURN NUMBER IS
    BEGIN
    
        RETURN json_core.apply_json (
            json_core.request_value(p_path, p_bind, TRUE),
            json_core.boolean_events(p_value),
            TRUE
        );
    
    END;
    
    PROCEDURE apply_boolean (
        p_path IN VARCHAR2,
        p_value IN BOOLEAN,
        p_bind IN bind := NULL
    ) IS
      
        v_dummy NUMBER;
       
    BEGIN
    
        v_dummy := apply_boolean(p_path, p_value, p_bind);
    
    END;
    
    FUNCTION apply_json (
        p_path IN VARCHAR2,
        -- @json
        p_content IN VARCHAR2,
        p_bind IN bind := NULL
    )
    RETURN NUMBER IS
    BEGIN
    
        RETURN apply_json(p_path, p_content, FALSE, p_bind);
    
    END;
    
    PROCEDURE apply_json (
        p_path IN VARCHAR2,
        -- @json
        p_content IN VARCHAR2,
        p_bind IN bind := NULL
    ) IS
    
        v_dummy NUMBER;
        
    BEGIN
    
        v_dummy := apply_json(p_path, p_content, p_bind);
    
    END;
    
    FUNCTION apply_json (
        p_path IN VARCHAR2,
        -- @json
        p_content IN VARCHAR2,
        p_check_types IN BOOLEAN,
        p_bind IN bind := NULL
    )
    RETURN NUMBER IS
    
        v_parse_events json_parser.t_parse_events;
    
    BEGIN
    
        json_parser.parse(p_content, v_parse_events);
        
        RETURN json_core.apply_json(
            json_core.request_value(p_path, p_bind, TRUE),
            v_parse_events,
            p_check_types
        );
    
    END;
    
    PROCEDURE apply_json (
        p_path IN VARCHAR2,
        -- @json
        p_content IN VARCHAR2,
        p_check_types IN BOOLEAN,
        p_bind IN bind := NULL
    ) IS
    
        v_dummy NUMBER;
        
    BEGIN
    
        v_dummy := apply_json(p_path, p_content, p_check_types, p_bind);
    
    END;
    
    FUNCTION apply_json (
        p_path IN VARCHAR2,
        -- @json
        p_content IN CLOB,
        p_bind IN bind := NULL
    )
    RETURN NUMBER IS
    BEGIN
    
        RETURN apply_json(p_path, p_content, FALSE, p_bind);
    
    END;
    
    PROCEDURE apply_json (
        p_path IN VARCHAR2,
        -- @json
        p_content IN CLOB,
        p_bind IN bind := NULL
    ) IS
    
        v_dummy NUMBER;
        
    BEGIN
    
        v_dummy := apply_json(p_path, p_content, p_bind);
    
    END;
    
    FUNCTION apply_json (
        p_path IN VARCHAR2,
        -- @json
        p_content IN CLOB,
        p_check_types IN BOOLEAN,
        p_bind IN bind := NULL
    )
    RETURN NUMBER IS
    
        v_parse_events json_parser.t_parse_events;
    
    BEGIN
    
        json_parser.parse(p_content, v_parse_events);
        
        RETURN json_core.apply_json(
            json_core.request_value(p_path, p_bind, TRUE),
            v_parse_events,
            p_check_types
        );
    
    END;
    
    PROCEDURE apply_json (
        p_path IN VARCHAR2,
        -- @json
        p_content IN CLOB,
        p_check_types IN BOOLEAN,
        p_bind IN bind := NULL
    ) IS
    
        v_dummy NUMBER;
        
    BEGIN
    
        v_dummy := apply_json(p_path, p_content, p_check_types, p_bind);
    
    END;
    
    /*
    
    FUNCTION apply_json (
        p_path IN VARCHAR2,
        p_builder IN t_json_builder,
        p_bind IN bind := NULL
    )
    RETURN NUMBER IS
    BEGIN
    
        RETURN apply_json(p_path, p_builder, FALSE, p_bind);
    
    END;
    
    PROCEDURE apply_json (
        p_path IN VARCHAR2,
        p_builder IN t_json_builder,
        p_bind IN bind := NULL
    ) IS
    
        v_dummy NUMBER;
        
    BEGIN
    
        v_dummy := apply_json(p_path, p_builder, p_bind);
    
    END;
    
    FUNCTION apply_json (
        p_path IN VARCHAR2,
        p_builder IN t_json_builder,
        p_check_types IN BOOLEAN,
        p_bind IN bind := NULL
    )
    RETURN NUMBER IS
    
        v_parse_events json_parser.t_parse_events;
    
    BEGIN
    
        v_parse_events := json_builder.build_parse_events(p_builder.id);
        
        RETURN json_core.apply_json(
            json_core.request_value(p_path, p_bind, TRUE),
            v_parse_events,
            p_check_types
        );
    
    END;
    
    PROCEDURE apply_json (
        p_path IN VARCHAR2,
        p_builder IN t_json_builder,
        p_check_types IN BOOLEAN,
        p_bind IN bind := NULL
    ) IS
    
        v_dummy NUMBER;
        
    BEGIN
    
        v_dummy := apply_json(p_path, p_builder, p_check_types, p_bind);
    
    END;
    
    */
    
    FUNCTION get_keys (
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    )
    RETURN t_varchars IS
    BEGIN
    
        RETURN json_core.get_keys(
            json_core.request_value(p_path, p_bind,TRUE)
        ); 
    
    END;
        
    
    FUNCTION get_length (
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    )
    RETURN NUMBER IS
    BEGIN
    
        RETURN json_core.get_length(
            json_core.request_value(p_path, p_bind,TRUE)
        );
    
    END;
    
    FUNCTION index_of (
        p_path IN VARCHAR2,
        p_value IN VARCHAR2,
        p_bind IN bind := NULL
    )
    RETURN NUMBER IS
    BEGIN
    
        RETURN json_core.index_of(
            json_core.request_value(p_path, p_bind, TRUE),
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
    
        RETURN json_core.index_of(
            json_core.request_value(p_path, p_bind, TRUE),
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
    
        RETURN json_core.index_of(
            json_core.request_value(p_path, p_bind, TRUE),
            p_value,
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
    
        RETURN json_core.index_of(
            json_core.request_value(p_path, p_bind, TRUE),
            p_value,
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
    
        RETURN json_core.index_of(
            json_core.request_value(p_path, p_bind, TRUE),
            p_value,
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
    
        RETURN json_core.index_of(
            json_core.request_value(p_path, p_bind, TRUE),
            p_value,
            p_from_index
        );
    
    END;
    
    FUNCTION push_string (
        p_path IN VARCHAR2,
        p_value IN BOOLEAN,
        p_bind IN bind := NULL
    )
    RETURN NUMBER IS
    BEGIN
    
        RETURN json_core.index_of(
            json_core.request_value(p_path, p_bind, TRUE),
            p_value,
            0
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
    
        RETURN json_core.index_of(
            json_core.request_value(p_path, p_bind, TRUE),
            p_value,
            p_from_index
        );
    
    END;
    
    FUNCTION index_of_null (
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    )
    RETURN NUMBER IS
    BEGIN
    
        RETURN json_core.index_of_null(
            json_core.request_value(p_path, p_bind, TRUE),
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
    
        RETURN json_core.index_of_null(
            json_core.request_value(p_path, p_bind, TRUE),
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

        RETURN json_core.push_json(
            json_core.request_value(p_path, p_bind, TRUE),
            json_core.string_events(p_value)
        );

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

        RETURN json_core.push_json(
            json_core.request_value(p_path, p_bind, TRUE),
            json_core.number_events(p_value)
        );


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

        RETURN json_core.push_json(
            json_core.request_value(p_path, p_bind, TRUE),
            json_core.boolean_events(p_value)
        );


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

        RETURN json_core.push_json(
            json_core.request_value(p_path, p_bind, TRUE),
            json_core.null_events
        );

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

        RETURN json_core.push_json(
            json_core.request_value(p_path, p_bind, TRUE),
            json_core.object_events
        );

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

        RETURN json_core.push_json(
            json_core.request_value(p_path, p_bind, TRUE),
            json_core.array_events
        );

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
    
        RETURN json_core.push_json(
            json_core.request_value(p_path, p_bind, TRUE),
            v_parse_events
        );
        
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
    
        v_parse_events json_parser.t_parse_events;
    
    BEGIN
    
        json_parser.parse(p_content, v_parse_events);
    
        RETURN json_core.push_json(
            json_core.request_value(p_path, p_bind, TRUE),
            v_parse_events
        );
        
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
    
        json_core.delete_value(
            json_core.request_value(p_path, p_bind, TRUE)
        );
    
    END;
    
    PROCEDURE pin (
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    ) IS
    BEGIN
    
        json_core.pin(
            json_core.request_value(p_path, p_bind, TRUE),
            FALSE
        );
    
    END;
    
    PROCEDURE pin (
        p_path IN VARCHAR2,
        p_pin_tree IN BOOLEAN,
        p_bind IN bind := NULL
    ) IS
    BEGIN
    
        json_core.pin(
            json_core.request_value(p_path, p_bind, TRUE),
            p_pin_tree
        );
    
    END;
    
    PROCEDURE unpin (
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    ) IS
    BEGIN
        
        json_core.unpin(
            json_core.request_value(p_path, p_bind, TRUE),
            FALSE
        );
    
    END;
    
    PROCEDURE unpin (
        p_path IN VARCHAR2,
        p_unpin_tree IN BOOLEAN,
        p_bind IN bind := NULL
    ) IS
    BEGIN
        
        json_core.unpin(
            json_core.request_value(p_path, p_bind, TRUE),
            p_unpin_tree
        );
    
    END;
    
END;

