CREATE OR REPLACE TYPE BODY t_json_value IS 
    
    /* Anonymous JSON value creation static methods */

    STATIC FUNCTION create_string (
        p_value IN VARCHAR2
    )
    RETURN t_json_value IS
    BEGIN
    
        RETURN t_json_value(
            json_core.create_json(json_core.string_events(p_value))
        );
    
    END;
    
    STATIC FUNCTION create_date (
        p_value IN DATE
    )
    RETURN t_json_value IS
    BEGIN
    
        RETURN t_json_value(
            json_core.create_json(json_core.date_events(p_value))
        );
    
    END;
    
    STATIC FUNCTION create_number (
        p_value IN NUMBER
    )
    RETURN t_json_value IS
    BEGIN
    
        RETURN t_json_value(
            json_core.create_json(json_core.number_events(p_value))
        );
    
    END;
    
    STATIC FUNCTION create_boolean (
        p_value IN BOOLEAN
    )
    RETURN t_json_value IS
    BEGIN
    
        RETURN t_json_value(
            json_core.create_json(json_core.boolean_events(p_value))
        );
    
    END;

    STATIC FUNCTION create_null
    RETURN t_json_value IS
    BEGIN
    
        RETURN t_json_value(
            json_core.create_json(json_core.null_events)
        );
    
    END;

    STATIC FUNCTION create_object
    RETURN t_json_value IS
    BEGIN
    
        RETURN t_json_value(
            json_core.create_json(json_core.object_events)
        );
    
    END;
    
    STATIC FUNCTION create_array
    RETURN t_json_value IS
    BEGIN
    
        RETURN t_json_value(
            json_core.create_json(json_core.array_events)
        );
    
    END;
    
    STATIC FUNCTION create_json (
        p_content IN VARCHAR2
    )
    RETURN t_json_value IS
    
        v_parse_events json_parser.t_parse_events;
    
    BEGIN
    
        json_parser.parse(p_content, v_parse_events);
        
        RETURN t_json_value(
            json_core.create_json(v_parse_events)
        );
    
    END;
    
    STATIC FUNCTION create_json (
        p_content IN CLOB
    )
    RETURN t_json_value IS
    
        v_parse_events json_parser.t_parse_events;
    
    BEGIN
    
        json_parser.parse(p_content, v_parse_events);
        
        RETURN t_json_value(
            json_core.create_json(v_parse_events)
        );
    
    END;
    
    STATIC FUNCTION create_copy (
        p_value IN t_json_value
    )
    RETURN t_json_value IS
    
        v_parse_events json_parser.t_parse_events;
    
    BEGIN
    
        json_core.get_parse_events(p_value.id, v_parse_events);
        
        RETURN t_json_value(
            json_core.create_json(v_parse_events)
        );
    
    END;

    /* Constructors for retrieving JSON values by path */

    CONSTRUCTOR FUNCTION t_json_value (
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    ) 
    RETURN self AS RESULT IS
    BEGIN
    
        self.id := json_core.request_value(p_path, p_bind);
    
        RETURN;
    
    END;
    
    /* Self casting to the scalar types and JSON */
        
    MEMBER FUNCTION as_string
    RETURN VARCHAR2 IS
    BEGIN
    
        RETURN json_core.get_string(id);
    
    END;
    
    MEMBER FUNCTION as_date
    RETURN DATE IS
    BEGIN
    
        RETURN json_core.get_date(id);
    
    END;
    
    MEMBER FUNCTION as_number
    RETURN NUMBER IS
    BEGIN
    
        RETURN json_core.get_number(id);
    
    END;
    
    MEMBER FUNCTION as_boolean
    RETURN BOOLEAN IS
    BEGIN
    
        RETURN json_core.get_boolean(id);
    
    END;
    
    MEMBER FUNCTION as_json
    RETURN VARCHAR2 IS
    BEGIN
    
        RETURN json_core.get_json(id);
    
    END;
    
    MEMBER FUNCTION as_json_clob
    RETURN CLOB IS
    BEGIN
    
        RETURN json_core.get_json_clob(id);
    
    END;
    
    /* Some usefull generic methods */
    
    MEMBER FUNCTION get_parent
    RETURN t_json_value IS
    
        v_value json_values%ROWTYPE;
    
    BEGIN
    
        v_value := json_core.get_value(id);
    
        IF v_value.parent_id IS NULL THEN
            RETURN NULL;
        ELSE
            RETURN t_json_value(v_value.parent_id);
        END IF;
    
    END;
    
    MEMBER FUNCTION is_string
    RETURN BOOLEAN IS
    BEGIN
    
        RETURN json_core.is_string(id);
    
    END;
    
    MEMBER FUNCTION is_date
    RETURN BOOLEAN IS
    BEGIN
    
        RETURN json_core.is_date(id);
    
    END;
    
    MEMBER FUNCTION is_number
    RETURN BOOLEAN IS
    BEGIN
    
        RETURN json_core.is_number(id);
    
    END;
    
    MEMBER FUNCTION is_boolean
    RETURN BOOLEAN IS
    BEGIN
    
        RETURN json_core.is_boolean(id);
    
    END;
    
    MEMBER FUNCTION is_null
    RETURN BOOLEAN IS
    BEGIN
    
        RETURN json_core.is_null(id);
    
    END;
    
    MEMBER FUNCTION is_object
    RETURN BOOLEAN IS
    BEGIN
    
        RETURN json_core.is_object(id);
    
    END;
    
    MEMBER FUNCTION is_array
    RETURN BOOLEAN IS
    BEGIN
    
        RETURN json_core.is_array(id);
    
    END;
    
    /* Special object methods */
    
    MEMBER FUNCTION get_keys
    RETURN t_varchars IS
    BEGIN
    
        RETURN json_core.get_keys(id);
    
    END;
    
    MEMBER FUNCTION has (
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    ) 
    RETURN BOOLEAN IS
    BEGIN
    
        RETURN json_core.request_value(id, p_path, p_bind) IS NOT NULL;
    
    END;
    
    MEMBER FUNCTION get_length
    RETURN PLS_INTEGER IS
    BEGIN
    
        RETURN json_core.get_length(id);
    
    END;
    
    /* Child value retrieval methods */
    
    MEMBER FUNCTION get (
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    )
    RETURN t_json_value IS
    
        v_value_id NUMBER;
    
    BEGIN
    
        v_value_id := json_core.request_value(id, p_path, p_bind);
    
        IF v_value_id IS NULL THEN
            RETURN NULL;
        ELSE
            RETURN t_json_value(v_value_id);
        END IF;
    
    END;
    
    MEMBER FUNCTION get_string (
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    )
    RETURN VARCHAR2 IS
    BEGIN
    
        RETURN json_core.get_string (
            json_core.request_value(id, p_path, p_bind)
        );
    
    END;
    
    MEMBER FUNCTION get_date (
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    )
    RETURN DATE IS
    BEGIN
    
        RETURN json_core.get_date (
            json_core.request_value(id, p_path, p_bind)
        );
    
    END;
    
    MEMBER FUNCTION get_number (
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    )
    RETURN NUMBER IS
    BEGIN
    
        RETURN json_core.get_number(
            json_core.request_value(id, p_path, p_bind)
        );
    
    END;
    
    MEMBER FUNCTION get_boolean (
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    )
    RETURN BOOLEAN IS
    BEGIN
    
        RETURN json_core.get_boolean(
            json_core.request_value(id, p_path, p_bind)
        );
    
    END;
    
    MEMBER FUNCTION get_json (
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    )
    RETURN VARCHAR2 IS
    BEGIN
    
        RETURN json_core.get_json(
            json_core.request_value(id, p_path, p_bind)
        );
    
    END;
    
    MEMBER FUNCTION get_json_clob (
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    )
    RETURN VARCHAR2 IS
    BEGIN
    
        RETURN json_core.get_json_clob(
            json_core.request_value(id, p_path, p_bind)
        );
    
    END;
    
    /* Property modification methods */
    
    MEMBER FUNCTION set_string (
        p_path IN VARCHAR2,
        p_value IN VARCHAR2,
        p_bind IN bind := NULL
    ) RETURN t_json_value IS
    BEGIN
    
        RETURN t_json_value(
            json_core.set_property(
                id,
                p_path,
                p_bind,
                json_core.string_events(p_value)
            )
        );
    
    END;
    
    MEMBER PROCEDURE set_string (
        p_path IN VARCHAR2,
        p_value IN VARCHAR2,
        p_bind IN bind := NULL
    ) IS 
    
        v_dummy t_json_value;
    
    BEGIN
    
        v_dummy  := set_string(p_path, p_value, p_bind);

    END;
    
    MEMBER FUNCTION set_date (
        p_path IN VARCHAR2,
        p_value IN DATE,
        p_bind IN bind := NULL
    ) RETURN t_json_value IS
    BEGIN
    
        RETURN t_json_value(
            json_core.set_property(
                id,
                p_path,
                p_bind,
                json_core.date_events(p_value)
            )
        );
    
    END;
    
    MEMBER PROCEDURE set_date (
        p_path IN VARCHAR2,
        p_value IN DATE,
        p_bind IN bind := NULL
    ) IS 
    
        v_dummy t_json_value;
    
    BEGIN
    
        v_dummy  := set_date(p_path, p_value, p_bind);

    END;
    
    MEMBER FUNCTION set_number (
        p_path IN VARCHAR2,
        p_value IN NUMBER,
        p_bind IN bind := NULL
    ) RETURN t_json_value IS
    BEGIN
    
        RETURN t_json_value(
            json_core.set_property(
                id,
                p_path,
                p_bind,
                json_core.number_events(p_value)
            )
        );
    
    END;
    
    MEMBER PROCEDURE set_number (
        p_path IN VARCHAR2,
        p_value IN NUMBER,
        p_bind IN bind := NULL
    ) IS
    
        v_dummy t_json_value;
    
    BEGIN
    
        v_dummy := set_number(p_path, p_value, p_bind);
    
    END;
    
    MEMBER FUNCTION set_boolean (
        p_path IN VARCHAR2,
        p_value IN BOOLEAN,
        p_bind IN bind := NULL
    ) RETURN t_json_value IS
    BEGIN
    
        RETURN t_json_value(
            json_core.set_property(
                id,
                p_path,
                p_bind,
                json_core.boolean_events(p_value)
            )
        );
    
    END;
    
    MEMBER PROCEDURE set_boolean (
        p_path IN VARCHAR2,
        p_value IN BOOLEAN,
        p_bind IN bind := NULL
    ) IS
    
        v_dummy t_json_value;
    
    BEGIN
    
        v_dummy := set_boolean(p_path, p_value, p_bind);
    
    END;
    
    MEMBER FUNCTION set_null (
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    ) RETURN t_json_value IS
    BEGIN
    
        RETURN t_json_value(
            json_core.set_property(
                id,
                p_path,
                p_bind,
                json_core.null_events
            )
        );
    
    END;
    
    MEMBER PROCEDURE set_null (
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    ) IS
    
        v_dummy t_json_value;
    
    BEGIN
    
        v_dummy := set_null(p_path, p_bind);
        
    END;
    
    MEMBER FUNCTION set_object (
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    ) RETURN t_json_value IS
    BEGIN
    
        RETURN t_json_value(
            json_core.set_property(
                id,
                p_path,
                p_bind,
                json_core.object_events
            )
        );
    
    END;
    
    MEMBER PROCEDURE set_object (
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    ) IS
    
        v_dummy t_json_value;
    
    BEGIN
    
        v_dummy := set_object(p_path, p_bind);
    
    END;
    
    MEMBER FUNCTION set_array (
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    ) RETURN t_json_value IS
    BEGIN
    
        RETURN t_json_value(
            json_core.set_property(
                id,
                p_path,
                p_bind,
                json_core.array_events
            )
        );
        
    END;
    
    MEMBER PROCEDURE set_array (
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    ) IS
    
        v_dummy t_json_value;
    
    BEGIN
    
        v_dummy := set_array(p_path, p_bind);
        
    END;
    
    MEMBER FUNCTION set_json (
        p_path IN VARCHAR2,
        p_content IN VARCHAR2,
        p_bind IN bind := NULL
    ) RETURN t_json_value IS
    
        v_parse_events json_parser.t_parse_events;
    
    BEGIN
    
        json_parser.parse(p_content, v_parse_events);
    
        RETURN t_json_value(
            json_core.set_property(
                id,
                p_path,
                p_bind,
                v_parse_events
            )
        );
    
    END;
    
    MEMBER PROCEDURE set_json (
        p_path IN VARCHAR2,
        p_content IN VARCHAR2,
        p_bind IN bind := NULL
    ) IS 
    
        v_dummy t_json_value;
    
    BEGIN
    
        v_dummy  := set_json(p_path, p_content, p_bind);

    END;
    
    MEMBER FUNCTION set_json (
        p_path IN VARCHAR2,
        p_content IN CLOB,
        p_bind IN bind := NULL
    ) RETURN t_json_value IS
    
        v_parse_events json_parser.t_parse_events;
    
    BEGIN
    
        json_parser.parse(p_content, v_parse_events);
    
        RETURN t_json_value(
            json_core.set_property(
                id,
                p_path,
                p_bind,
                v_parse_events
            )
        );
    
    END;
    
    MEMBER PROCEDURE set_json (
        p_path IN VARCHAR2,
        p_content IN CLOB,
        p_bind IN bind := NULL
    ) IS 
    
        v_dummy t_json_value;
    
    BEGIN
    
        v_dummy  := set_json(p_path, p_content, p_bind);

    END;
    
    MEMBER FUNCTION set_copy (
        p_path IN VARCHAR2,
        p_value IN t_json_value,
        p_bind IN bind := NULL
    ) 
    RETURN t_json_value IS
    
        v_parse_events json_parser.t_parse_events;
    
    BEGIN
    
        json_core.get_parse_events(p_value.id, v_parse_events);
        
        RETURN t_json_value(
            json_core.set_property(
                id,
                p_path,
                p_bind,
                v_parse_events
            )
        );
    
    END;
    
    MEMBER PROCEDURE set_copy (
        p_path IN VARCHAR2,
        p_value IN t_json_value,
        p_bind IN bind := NULL
    ) IS
    
        v_dummy t_json_value;
    
    BEGIN
    
        v_dummy := set_copy(p_path, p_value, p_bind);
    
    END;
    
    /* Array push methods */
    
    MEMBER FUNCTION push_string (
        p_path IN VARCHAR2,
        p_value IN VARCHAR2,
        p_bind IN bind := NULL
    ) 
    RETURN t_json_value IS
    BEGIN
    
        RETURN t_json_value(
            json_core.push_json(
                json_core.request_value(id, p_path, p_bind, TRUE), 
                json_core.string_events(p_value)
            )
        );
    
    END;
    
    MEMBER PROCEDURE push_string (
        p_path IN VARCHAR2,
        p_value IN VARCHAR2,
        p_bind IN bind := NULL
    ) IS
    
        v_dummy t_json_value;
    
    BEGIN
    
        v_dummy := push_string(p_path, p_value, p_bind);
    
    END;
    
    MEMBER FUNCTION push_string (
        p_value IN VARCHAR2
    ) 
    RETURN t_json_value IS
    BEGIN
    
        RETURN t_json_value(
            json_core.push_json(id, json_core.string_events(p_value))
        );
    
    END;
    
    MEMBER PROCEDURE push_string (
        p_value IN VARCHAR2
    ) IS
    
        v_dummy t_json_value;
    
    BEGIN
    
        v_dummy := push_string(p_value);
    
    END;
    
    MEMBER FUNCTION push_number (
        p_path IN VARCHAR2,
        p_value IN NUMBER,
        p_bind IN bind := NULL
    ) 
    RETURN t_json_value IS
    BEGIN
    
        RETURN t_json_value(
            json_core.push_json(    
                json_core.request_value(id, p_path, p_bind, TRUE), 
                json_core.number_events(p_value)
            )
        );
    
    END;
    
    MEMBER PROCEDURE push_number (
        p_path IN VARCHAR2,
        p_value IN NUMBER,
        p_bind IN bind := NULL
    ) IS
    
        v_dummy t_json_value;
    
    BEGIN
    
        v_dummy := push_number(p_path, p_value, p_bind);
    
    END;
    
    MEMBER FUNCTION push_number (
        p_value IN NUMBER
    ) 
    RETURN t_json_value IS
    BEGIN
    
        RETURN t_json_value(
            json_core.push_json(id, json_core.number_events(p_value))
        );
    
    END;
    
    MEMBER PROCEDURE push_number (
        p_value IN NUMBER
    ) IS
    
        v_dummy t_json_value;
    
    BEGIN
    
        v_dummy := push_number(p_value);
    
    END;
    
    MEMBER FUNCTION push_boolean (
        p_path IN VARCHAR2,
        p_value IN BOOLEAN,
        p_bind IN bind := NULL
    ) 
    RETURN t_json_value IS
    BEGIN
    
        RETURN t_json_value(
            json_core.push_json(
                json_core.request_value(id, p_path, p_bind, TRUE), 
                json_core.boolean_events(p_value)
            )
        );
    
    END;
    
    MEMBER PROCEDURE push_boolean (
        p_path IN VARCHAR2,
        p_value IN BOOLEAN,
        p_bind IN bind := NULL
    ) IS
    
        v_dummy t_json_value;
    
    BEGIN
    
        v_dummy := push_boolean(p_path, p_value, p_bind);
    
    END;
    
    MEMBER FUNCTION push_boolean (
        p_value IN BOOLEAN
    ) 
    RETURN t_json_value IS
    BEGIN
    
        RETURN t_json_value(
            json_core.push_json(id, json_core.boolean_events(p_value))
        );
    
    END;
    
    MEMBER PROCEDURE push_boolean (
        p_value IN BOOLEAN
    ) IS
    
        v_dummy t_json_value;
    
    BEGIN
    
        v_dummy := push_boolean(p_value);
    
    END;
    
    MEMBER FUNCTION push_null (
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    ) 
    RETURN t_json_value IS
    BEGIN
    
        RETURN t_json_value(
            json_core.push_json(
                json_core.request_value(id, p_path, p_bind, TRUE), 
                json_core.null_events
            )
        );
    
    END;
    
    MEMBER PROCEDURE push_null (
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    ) IS
    
        v_dummy t_json_value;
    
    BEGIN
    
        v_dummy := push_null(p_path, p_bind);
    
    END;
    
    MEMBER FUNCTION push_null
    RETURN t_json_value IS
    BEGIN
    
        RETURN t_json_value(
            json_core.push_json(id, json_core.null_events)
        );
    
    END;
    
    MEMBER PROCEDURE push_null IS
    
        v_dummy t_json_value;
    
    BEGIN
    
        v_dummy := push_null;
    
    END;
    
    MEMBER FUNCTION push_object (
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    ) 
    RETURN t_json_value IS
    BEGIN
    
        RETURN t_json_value(
            json_core.push_json(
                json_core.request_value(id, p_path, p_bind, TRUE), 
                json_core.object_events
            )
        );
    
    END;
    
    MEMBER PROCEDURE push_object (
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    ) IS
    
        v_dummy t_json_value;
    
    BEGIN
    
        v_dummy := push_object(p_path, p_bind);
    
    END;
    
    MEMBER FUNCTION push_object
    RETURN t_json_value IS
    BEGIN
    
        RETURN t_json_value(
            json_core.push_json(id, json_core.object_events)
        );
    
    END;
    
    MEMBER PROCEDURE push_object IS
    
        v_dummy t_json_value;
    
    BEGIN
    
        v_dummy := push_object;
    
    END;
    
    MEMBER FUNCTION push_array (
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    ) 
    RETURN t_json_value IS
    BEGIN
    
        RETURN t_json_value(
            json_core.push_json(
                json_core.request_value(id, p_path, p_bind, TRUE), 
                json_core.array_events
            )
        );
    
    END;
    
    MEMBER PROCEDURE push_array (
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    ) IS
    
        v_dummy t_json_value;
    
    BEGIN
    
        v_dummy := push_array(p_path, p_bind);
    
    END;
    
    MEMBER FUNCTION push_array
    RETURN t_json_value IS
    BEGIN
    
        RETURN t_json_value(
            json_core.push_json(id, json_core.array_events)
        );
    
    END;
    
    MEMBER PROCEDURE push_array IS
    
        v_dummy t_json_value;
    
    BEGIN
    
        v_dummy := push_array;
    
    END;
    
    MEMBER FUNCTION push_json (
        p_path IN VARCHAR2,
        p_content IN VARCHAR2,
        p_bind IN bind := NULL
    ) 
    RETURN t_json_value IS
    
        v_parse_events json_parser.t_parse_events;
    
    BEGIN
    
        json_parser.parse(p_content, v_parse_events);
        
        RETURN t_json_value(
            json_core.push_json(
                json_core.request_value(id, p_path, p_bind, TRUE), 
                v_parse_events
            )
        );
    
    END;
    
    MEMBER PROCEDURE push_json (
        p_path IN VARCHAR2,
        p_content IN VARCHAR2,
        p_bind IN bind := NULL
    ) IS
    
        v_dummy t_json_value;
    
    BEGIN
    
        v_dummy := push_json(p_path, p_content, p_bind);
    
    END;
    
    MEMBER FUNCTION push_json (
        p_content IN VARCHAR2
    ) 
    RETURN t_json_value IS
      
        v_parse_events json_parser.t_parse_events;
    
    BEGIN
    
        json_parser.parse(p_content, v_parse_events);
        
        RETURN t_json_value(
            json_core.push_json(id, v_parse_events)
        );
    
    END;
    
    MEMBER PROCEDURE push_json (
        p_content IN VARCHAR2
    ) IS
    
        v_dummy t_json_value;
    
    BEGIN
    
        v_dummy := push_json(p_content);
    
    END;
    
    MEMBER FUNCTION push_json (
        p_path IN VARCHAR2,
        p_content IN CLOB,
        p_bind IN bind := NULL
    ) 
    RETURN t_json_value IS
    
        v_parse_events json_parser.t_parse_events;
    
    BEGIN
    
        json_parser.parse(p_content, v_parse_events);
        
        RETURN t_json_value(
            json_core.push_json(
                json_core.request_value(id, p_path, p_bind, TRUE), 
                v_parse_events
            )
        );
    
    END;
    
    MEMBER PROCEDURE push_json (
        p_path IN VARCHAR2,
        p_content IN CLOB,
        p_bind IN bind := NULL
    ) IS
    
        v_dummy t_json_value;
    
    BEGIN
    
        v_dummy := push_json(p_path, p_content, p_bind);
    
    END;
    
    MEMBER FUNCTION push_json (
        p_content IN CLOB
    ) 
    RETURN t_json_value IS
      
        v_parse_events json_parser.t_parse_events;
    
    BEGIN
    
        json_parser.parse(p_content, v_parse_events);
        
        RETURN t_json_value(
            json_core.push_json(id, v_parse_events)
        );
    
    END;
    
    MEMBER PROCEDURE push_json (
        p_content IN CLOB
    ) IS
    
        v_dummy t_json_value;
    
    BEGIN
    
        v_dummy := push_json(p_content);
    
    END;

END;