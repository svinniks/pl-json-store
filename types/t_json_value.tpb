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
    
    STATIC FUNCTION create_json (
        p_builder IN t_json_builder
    )
    RETURN t_json_value IS
    BEGIN
    
        RETURN t_json_value(
            json_core.create_json(
                json_builders.build_parse_events(p_builder.id)
            )
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
    
    MEMBER FUNCTION as_json (
        p_serialize_nulls IN BOOLEAN := TRUE
    )
    RETURN VARCHAR2 IS
    BEGIN
    
        RETURN json_core.get_json(id, NVL(p_serialize_nulls, FALSE));
    
    END;
    
    MEMBER FUNCTION as_json_clob (
        p_serialize_nulls IN BOOLEAN := TRUE
    )
    RETURN CLOB IS
    BEGIN
    
        RETURN json_core.get_json_clob(id, NVL(p_serialize_nulls, FALSE));
    
    END;
    
    MEMBER FUNCTION as_strings
    RETURN t_varchars IS
    BEGIN
    
        RETURN json_core.get_strings(id);
        
    END;
    
    MEMBER FUNCTION as_numbers
    RETURN t_numbers IS
    BEGIN
    
        RETURN json_core.get_numbers(id);
        
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
    
    MEMBER FUNCTION index_of (
        p_value IN VARCHAR2
       ,p_from_index IN NUMBER := 0
    )
    RETURN NUMBER IS
    BEGIN
    
        RETURN json_core.index_of(id, p_value, p_from_index);
    
    END;
    
    MEMBER FUNCTION index_of (
        p_value IN DATE
       ,p_from_index IN NUMBER := 0
    )
    RETURN NUMBER IS
    BEGIN
    
        RETURN json_core.index_of(id, p_value, p_from_index);
    
    END;
    
    MEMBER FUNCTION index_of (
        p_value IN NUMBER
       ,p_from_index IN NUMBER := 0
    )
    RETURN NUMBER IS
    BEGIN
    
        RETURN json_core.index_of(id, p_value, p_from_index);
    
    END;
    
    MEMBER FUNCTION index_of (
        p_value IN BOOLEAN
       ,p_from_index IN NUMBER := 0
    )
    RETURN NUMBER IS
    BEGIN
    
        RETURN json_core.index_of(id, p_value, p_from_index);
    
    END;
    
    MEMBER FUNCTION index_of_null (
        p_from_index IN NUMBER := 0
    )
    RETURN NUMBER IS
    BEGIN
    
        RETURN json_core.index_of_null(id, p_from_index);
    
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
    
    MEMBER FUNCTION get (
        p_index IN NUMBER
    )
    RETURN t_json_value IS
    BEGIN
    
        RETURN get(':i', bind(p_index));
    
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
    
    MEMBER FUNCTION get_string (
        p_index IN NUMBER
    )
    RETURN VARCHAR2 IS
    BEGIN
    
        RETURN get_string(':i', bind(p_index));
    
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
    
    MEMBER FUNCTION get_date (
        p_index IN NUMBER
    )
    RETURN DATE IS
    BEGIN
    
        RETURN get_date(':i', bind(p_index));
    
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
    
    MEMBER FUNCTION get_number (
        p_index IN NUMBER
    )
    RETURN NUMBER IS
    BEGIN
    
        RETURN get_number(':i', bind(p_index));
    
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
    
    MEMBER FUNCTION get_boolean (
        p_index IN NUMBER
    )
    RETURN BOOLEAN IS
    BEGIN
    
        RETURN get_boolean(':i', bind(p_index));
    
    END;
    
    MEMBER FUNCTION get_json (
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    )
    RETURN VARCHAR2 IS
    BEGIN
    
        RETURN json_core.get_json(
            json_core.request_value(id, p_path, p_bind),
            TRUE
        );
    
    END;
    
    MEMBER FUNCTION get_json (
        p_path IN VARCHAR2,
        p_serialize_nulls IN BOOLEAN,
        p_bind IN bind := NULL
    )
    RETURN VARCHAR2 IS
    BEGIN
    
        RETURN json_core.get_json(
            json_core.request_value(id, p_path, p_bind),
            p_serialize_nulls
        );
    
    END;
    
    MEMBER FUNCTION get_json (
        p_index IN NUMBER,
        p_serialize_nulls IN BOOLEAN := TRUE
    )
    RETURN VARCHAR2 IS
    BEGIN
    
        RETURN get_json(':i', p_serialize_nulls, bind(p_index));
    
    END;
    
    MEMBER FUNCTION get_json_clob (
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    )
    RETURN CLOB IS
    BEGIN
    
        RETURN json_core.get_json_clob(
            json_core.request_value(id, p_path, p_bind),
            TRUE
        );
    
    END;
    
    MEMBER FUNCTION get_json_clob (
        p_path IN VARCHAR2,
        p_serialize_nulls IN BOOLEAN,
        p_bind IN bind := NULL
    )
    RETURN CLOB IS
    BEGIN
    
        RETURN json_core.get_json_clob(
            json_core.request_value(id, p_path, p_bind),
            p_serialize_nulls
        );
    
    END;
    
    MEMBER FUNCTION get_json_clob (
        p_index IN NUMBER,
        p_serialize_nulls IN BOOLEAN := TRUE
    )
    RETURN CLOB IS
    BEGIN
    
        RETURN get_json_clob(':i', p_serialize_nulls, bind(p_index));
    
    END;
    
    MEMBER FUNCTION get_strings (
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    )
    RETURN t_varchars IS
    BEGIN
        
        RETURN json_core.get_strings(
            json_core.request_value(id, p_path, p_bind)
        );
    
    END;
    
    MEMBER FUNCTION get_strings (
        p_index IN NUMBER
    )
    RETURN t_varchars IS
    BEGIN
        
        RETURN get_strings(':i', bind(p_index));
    
    END;
    
    MEMBER FUNCTION get_numbers (
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    )
    RETURN t_numbers IS
    BEGIN

        RETURN json_core.get_numbers(
            json_core.request_value(id, p_path, p_bind)
        );
        
    END;
    
    MEMBER FUNCTION get_numbers (
        p_index IN NUMBER
    )
    RETURN t_numbers IS
    BEGIN
        
        RETURN get_numbers(':i', bind(p_index));
    
    END;
    
    
    /* Property modification methods */
    
    MEMBER FUNCTION set_string (
        p_path IN VARCHAR2,
        p_value IN VARCHAR2,
        p_bind IN bind := NULL
    ) 
    RETURN t_json_value IS
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
        self IN t_json_value,
        p_path IN VARCHAR2,
        p_value IN VARCHAR2,
        p_bind IN bind := NULL
    ) IS 
    
        v_dummy t_json_value;
    
    BEGIN
    
        v_dummy  := set_string(p_path, p_value, p_bind);

    END;
    
    MEMBER FUNCTION set_string (
        p_index IN NUMBER,
        p_value IN VARCHAR2
    ) 
    RETURN t_json_value IS
    BEGIN
    
        RETURN set_string(':i', p_value, bind(p_index));
    
    END;
    
    MEMBER PROCEDURE set_string (
        self IN t_json_value,
        p_index IN NUMBER,
        p_value IN VARCHAR2
    ) IS
    BEGIN
    
        set_string(':i', p_value, bind(p_index));
    
    END;
    
    MEMBER FUNCTION set_date (
        p_path IN VARCHAR2,
        p_value IN DATE,
        p_bind IN bind := NULL
    ) 
    RETURN t_json_value IS
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
        self IN t_json_value,
        p_path IN VARCHAR2,
        p_value IN DATE,
        p_bind IN bind := NULL
    ) IS 
    
        v_dummy t_json_value;
    
    BEGIN
    
        v_dummy  := set_date(p_path, p_value, p_bind);

    END;
    
    MEMBER FUNCTION set_date (
        p_index IN NUMBER,
        p_value IN DATE
    ) 
    RETURN t_json_value IS
    BEGIN
    
        RETURN set_date(':i', p_value, bind(p_index));
    
    END;
    
    MEMBER PROCEDURE set_date (
        self IN t_json_value,
        p_index IN NUMBER,
        p_value IN DATE
    ) IS
    BEGIN
    
        set_date(':i', p_value, bind(p_index));
    
    END;
    
    MEMBER FUNCTION set_number (
        p_path IN VARCHAR2,
        p_value IN NUMBER,
        p_bind IN bind := NULL
    ) 
    RETURN t_json_value IS
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
        self IN t_json_value,
        p_path IN VARCHAR2,
        p_value IN NUMBER,
        p_bind IN bind := NULL
    ) IS
    
        v_dummy t_json_value;
    
    BEGIN
    
        v_dummy := set_number(p_path, p_value, p_bind);
    
    END;
    
    MEMBER FUNCTION set_number (
        p_index IN NUMBER,
        p_value IN NUMBER
    ) 
    RETURN t_json_value IS
    BEGIN
    
        RETURN set_number(':i', p_value, bind(p_index));
    
    END;
    
    MEMBER PROCEDURE set_number (
        self IN t_json_value,
        p_index IN NUMBER,
        p_value IN NUMBER
    ) IS
    BEGIN
    
        set_number(':i', p_value, bind(p_index));
    
    END;
    
    MEMBER FUNCTION set_boolean (
        p_path IN VARCHAR2,
        p_value IN BOOLEAN,
        p_bind IN bind := NULL
    ) 
    RETURN t_json_value IS
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
        self IN t_json_value,
        p_path IN VARCHAR2,
        p_value IN BOOLEAN,
        p_bind IN bind := NULL
    ) IS
    
        v_dummy t_json_value;
    
    BEGIN
    
        v_dummy := set_boolean(p_path, p_value, p_bind);
    
    END;
    
    MEMBER FUNCTION set_boolean (
        p_index IN NUMBER,
        p_value IN BOOLEAN
    ) 
    RETURN t_json_value IS
    BEGIN
    
        RETURN set_boolean(':i', p_value, bind(p_index));
    
    END;
    
    MEMBER PROCEDURE set_boolean (
        self IN t_json_value,
        p_index IN NUMBER,
        p_value IN BOOLEAN
    ) IS
    BEGIN
    
        set_boolean(':i', p_value, bind(p_index));
    
    END;
    
    MEMBER FUNCTION set_null (
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    ) 
    RETURN t_json_value IS
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
        self IN t_json_value,
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    ) IS
    
        v_dummy t_json_value;
    
    BEGIN
    
        v_dummy := set_null(p_path, p_bind);
        
    END;
    
    MEMBER FUNCTION set_null (
        p_index IN NUMBER
    ) 
    RETURN t_json_value IS
    BEGIN
    
        RETURN set_null(':i', bind(p_index));
    
    END;
    
    MEMBER PROCEDURE set_null (
        self IN t_json_value,
        p_index IN NUMBER
    ) IS
    BEGIN
    
        set_null(':i', bind(p_index));
    
    END;
    
    MEMBER FUNCTION set_object (
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    ) 
    RETURN t_json_value IS
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
        self IN t_json_value,
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    ) IS
    
        v_dummy t_json_value;
    
    BEGIN
    
        v_dummy := set_object(p_path, p_bind);
    
    END;
    
    MEMBER FUNCTION set_object (
        p_index IN NUMBER
    ) 
    RETURN t_json_value IS
    BEGIN
    
        RETURN set_object(':i', bind(p_index));
    
    END;
    
    MEMBER PROCEDURE set_object (
        self IN t_json_value,
        p_index IN NUMBER
    ) IS
    BEGIN
    
        set_object(':i', bind(p_index));
    
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
        self IN t_json_value,
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    ) IS
    
        v_dummy t_json_value;
    
    BEGIN
    
        v_dummy := set_array(p_path, p_bind);
        
    END;
    
    MEMBER FUNCTION set_array (
        p_index IN NUMBER
    ) 
    RETURN t_json_value IS
    BEGIN
    
        RETURN set_array(':i', bind(p_index));
    
    END;
    
    MEMBER PROCEDURE set_array (
        self IN t_json_value,
        p_index IN NUMBER
    ) IS
    BEGIN
    
        set_array(':i', bind(p_index));
    
    END;
    
    MEMBER FUNCTION set_json (
        p_path IN VARCHAR2,
        p_content IN VARCHAR2,
        p_bind IN bind := NULL
    ) 
    RETURN t_json_value IS
    
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
        self IN t_json_value,
        p_path IN VARCHAR2,
        p_content IN VARCHAR2,
        p_bind IN bind := NULL
    ) IS 
    
        v_dummy t_json_value;
    
    BEGIN
    
        v_dummy  := set_json(p_path, p_content, p_bind);

    END;
    
    MEMBER FUNCTION set_json (
        p_index IN NUMBER,
        p_content IN VARCHAR2
    ) 
    RETURN t_json_value IS
    BEGIN
    
        RETURN set_json(':i', p_content, bind(p_index));
    
    END;
    
    MEMBER PROCEDURE set_json (
        self IN t_json_value,
        p_index IN NUMBER,
        p_content IN VARCHAR2
    ) IS
    BEGIN
    
        set_json(':i', p_content, bind(p_index));
    
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
        self IN t_json_value,
        p_path IN VARCHAR2,
        p_content IN CLOB,
        p_bind IN bind := NULL
    ) IS 
    
        v_dummy t_json_value;
    
    BEGIN
    
        v_dummy  := set_json(p_path, p_content, p_bind);

    END;
    
    MEMBER FUNCTION set_json (
        p_index IN NUMBER,
        p_content IN CLOB
    ) 
    RETURN t_json_value IS
    BEGIN
    
        RETURN set_json(':i', p_content, bind(p_index));
    
    END;
    
    MEMBER PROCEDURE set_json (
        self IN t_json_value,
        p_index IN NUMBER,
        p_content IN CLOB
    ) IS
    BEGIN
    
        set_json(':i', p_content, bind(p_index));
    
    END;
    
    MEMBER FUNCTION set_json (
        p_path IN VARCHAR2,
        p_builder IN t_json_builder,
        p_bind IN bind := NULL
    ) 
    RETURN t_json_value IS
    BEGIN
    
        RETURN t_json_value(
            json_core.set_property(
                id,
                p_path,
                p_bind,
                json_builders.build_parse_events(p_builder.id)
            )
        );
    
    END;
    
    MEMBER PROCEDURE set_json (
        self IN t_json_value,
        p_path IN VARCHAR2,
        p_builder IN t_json_builder,
        p_bind IN bind := NULL
    ) IS
    
        v_dummy t_json_value;
    
    BEGIN
    
        v_dummy := set_json(p_path, p_builder, p_bind);
    
    END;
    
    MEMBER FUNCTION set_json (
        p_index IN NUMBER,
        p_builder IN t_json_builder
    ) 
    RETURN t_json_value IS
    BEGIN
    
        RETURN set_json(':i', p_builder, bind(p_index));
    
    END;
    
    MEMBER PROCEDURE set_json (
        self IN t_json_value,
        p_index IN NUMBER,
        p_builder IN t_json_builder
    ) IS
    BEGIN
    
        set_json(':i', p_builder, bind(p_index));
    
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
        self IN t_json_value,
        p_path IN VARCHAR2,
        p_value IN t_json_value,
        p_bind IN bind := NULL
    ) IS
    
        v_dummy t_json_value;
    
    BEGIN
    
        v_dummy := set_copy(p_path, p_value, p_bind);
    
    END;
    
    MEMBER FUNCTION set_copy (
        p_index IN NUMBER,
        p_value IN t_json_value
    ) 
    RETURN t_json_value IS
    BEGIN
    
        RETURN set_copy(':i', p_value, bind(p_index));
    
    END;
    
    MEMBER PROCEDURE set_copy (
        self IN t_json_value,
        p_index IN NUMBER,
        p_value IN t_json_value
    ) IS
    BEGIN
    
        set_copy(':i', p_value, bind(p_index));
    
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
        self IN t_json_value,
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
        self IN t_json_value,
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
        self IN t_json_value,
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
        self IN t_json_value,
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
        self IN t_json_value,
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
        self IN t_json_value,
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
        self IN t_json_value,
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
    
    MEMBER PROCEDURE push_null (
        self IN t_json_value
    ) IS
    
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
        self IN t_json_value,
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
    
    MEMBER PROCEDURE push_object (
        self IN t_json_value
    ) IS
    
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
        self IN t_json_value,
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
    
    MEMBER PROCEDURE push_array (
        self IN t_json_value
    ) IS
    
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
        self IN t_json_value,
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
        self IN t_json_value,
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
        self IN t_json_value,
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
        self IN t_json_value,
        p_content IN CLOB
    ) IS
    
        v_dummy t_json_value;
    
    BEGIN
    
        v_dummy := push_json(p_content);
    
    END;
    
    MEMBER FUNCTION push_json (
        p_builder IN t_json_builder
    )
    RETURN t_json_value IS
    BEGIN
    
        RETURN t_json_value(
            json_core.push_json(
                id,
                json_builders.build_parse_events(p_builder.id)
            )
        );
    
    END;
    
    MEMBER PROCEDURE push_json (
        self IN t_json_value,
        p_builder IN t_json_builder
    ) IS
    
        v_dummy t_json_value;
    
    BEGIN
    
        v_dummy := push_json(p_builder);
     
    END;
    
    /* JSON applying methods */
    
    MEMBER FUNCTION apply_string (
        p_path IN VARCHAR2,
        p_value IN VARCHAR2,
        p_bind IN bind := NULL
    )
    RETURN t_json_value IS
    BEGIN
    
        RETURN t_json_value(
            json_core.apply_json(
                json_core.request_value(id, p_path, p_bind, TRUE),
                json_core.string_events(p_value),
                TRUE
            )
        );
    
    END;
    
    MEMBER PROCEDURE apply_string (
        self IN t_json_value,
        p_path IN VARCHAR2,
        p_value IN VARCHAR2,
        p_bind IN bind := NULL
    ) IS
    
        v_dummy t_json_value;
    
    BEGIN
    
        v_dummy := apply_string(p_path, p_value, p_bind);
    
    END;
    
    MEMBER FUNCTION apply_date (
        p_path IN VARCHAR2,
        p_value IN DATE,
        p_bind IN bind := NULL
    )
    RETURN t_json_value IS
    BEGIN
    
        RETURN t_json_value(
            json_core.apply_json(
                json_core.request_value(id, p_path, p_bind, TRUE),
                json_core.date_events(p_value),
                TRUE
            )
        );
    
    END;
    
    MEMBER PROCEDURE apply_date (
        self IN t_json_value,
        p_path IN VARCHAR2,
        p_value IN DATE,
        p_bind IN bind := NULL
    ) IS
    
        v_dummy t_json_value;
    
    BEGIN
    
        v_dummy := apply_date(p_path, p_value, p_bind);
    
    END;
    
    MEMBER FUNCTION apply_number (
        p_path IN VARCHAR2,
        p_value IN NUMBER,
        p_bind IN bind := NULL
    )
    RETURN t_json_value IS
    BEGIN
    
        RETURN t_json_value(
            json_core.apply_json(
                json_core.request_value(id, p_path, p_bind, TRUE),
                json_core.number_events(p_value),
                TRUE
            )
        );
    
    END;
    
    MEMBER PROCEDURE apply_number (
        self IN t_json_value,
        p_path IN VARCHAR2,
        p_value IN NUMBER,
        p_bind IN bind := NULL
    ) IS
    
        v_dummy t_json_value;
    
    BEGIN
    
        v_dummy := apply_number(p_path, p_value, p_bind);
    
    END;
    
    MEMBER FUNCTION apply_boolean (
        p_path IN VARCHAR2,
        p_value IN BOOLEAN,
        p_bind IN bind := NULL
    )
    RETURN t_json_value IS
    BEGIN
    
        RETURN t_json_value(
            json_core.apply_json(
                json_core.request_value(id, p_path, p_bind, TRUE),
                json_core.boolean_events(p_value),
                TRUE
            )
        );
    
    END;
    
    MEMBER PROCEDURE apply_boolean (
        self IN t_json_value,
        p_path IN VARCHAR2,
        p_value IN BOOLEAN,
        p_bind IN bind := NULL
    ) IS
    
        v_dummy t_json_value;
    
    BEGIN
    
        v_dummy := apply_boolean(p_path, p_value, p_bind);
    
    END;
    
    MEMBER FUNCTION apply_object (
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    )
    RETURN t_json_value IS
    BEGIN
    
        RETURN t_json_value(
            json_core.apply_json(
                json_core.request_value(id, p_path, p_bind, TRUE),
                json_core.object_events(),
                TRUE
            )
        );
    
    END;
    
    MEMBER PROCEDURE apply_object (
        self IN t_json_value,
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    ) IS
    
        v_dummy t_json_value;
    
    BEGIN
    
        v_dummy := apply_object(p_path, p_bind);
    
    END;
    
    MEMBER FUNCTION apply_array (
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    )
    RETURN  t_json_value IS
    BEGIN
    
        RETURN t_json_value(
            json_core.apply_json(
                json_core.request_value(id, p_path, p_bind, TRUE),
                json_core.array_events(),
                TRUE
            )
        );
    
    END;
    
    MEMBER PROCEDURE apply_array (
        self IN t_json_value,
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    ) IS
    
        v_dummy t_json_value;
    
    BEGIN
    
        v_dummy := apply_array(p_path, p_bind);
    
    END;
    
    MEMBER FUNCTION apply_json (
        p_path IN VARCHAR2,
        p_content IN VARCHAR2,
        p_bind IN bind := NULL
    )
    RETURN t_json_value IS
    BEGIN
    
        RETURN apply_json(p_path, p_content, FALSE, p_bind);
    
    END;
    
    MEMBER FUNCTION apply_json (
        p_path IN VARCHAR2,
        p_content IN VARCHAR2,
        p_check_types IN BOOLEAN,
        p_bind IN bind := NULL
    )
    RETURN t_json_value IS
    
        v_parse_events json_parser.t_parse_events;
    
    BEGIN
    
        json_parser.parse(p_content, v_parse_events);
    
        RETURN t_json_value(
            json_core.apply_json(
                json_core.request_value(id, p_path, p_bind, TRUE),
                v_parse_events,
                p_check_types
            )
        );
    
    END;
    
    MEMBER PROCEDURE apply_json (
        self IN t_json_value,
        p_path IN VARCHAR2,
        p_content IN VARCHAR2,
        p_bind IN bind := NULL
    ) IS
    
        v_dummy t_json_value;
    
    BEGIN
    
        v_dummy := apply_json(p_path, p_content, p_bind);
    
    END;
    
    MEMBER PROCEDURE apply_json (
        self IN t_json_value,
        p_path IN VARCHAR2,
        p_content IN VARCHAR2,
        p_check_types IN BOOLEAN,
        p_bind IN bind := NULL
    ) IS
    
        v_dummy t_json_value;
    
    BEGIN
    
        v_dummy := apply_json(p_path, p_content, p_check_types, p_bind);
    
    END;
    
    MEMBER FUNCTION apply_json (
        p_path IN VARCHAR2,
        p_content IN CLOB,
        p_bind IN bind := NULL
    )
    RETURN t_json_value IS
    BEGIN
    
        RETURN apply_json(p_path, p_content, FALSE, p_bind);
    
    END;
    
    MEMBER FUNCTION apply_json (
        p_path IN VARCHAR2,
        p_content IN CLOB,
        p_check_types IN BOOLEAN,
        p_bind IN bind := NULL
    )
    RETURN t_json_value IS
    
        v_parse_events json_parser.t_parse_events;
    
    BEGIN
    
        json_parser.parse(p_content, v_parse_events);
    
        RETURN t_json_value(
            json_core.apply_json(
                json_core.request_value(id, p_path, p_bind, TRUE),
                v_parse_events,
                p_check_types
            )
        );
    
    END;
    
    MEMBER PROCEDURE apply_json (
        self IN t_json_value,
        p_path IN VARCHAR2,
        p_content IN CLOB,
        p_bind IN bind := NULL
    ) IS
    
        v_dummy t_json_value;
    
    BEGIN
    
        v_dummy := apply_json(p_path, p_content, p_bind);
    
    END;
    
    MEMBER PROCEDURE apply_json (
        self IN t_json_value,
        p_path IN VARCHAR2,
        p_content IN CLOB,
        p_check_types IN BOOLEAN,
        p_bind IN bind := NULL
    ) IS
    
        v_dummy t_json_value;
    
    BEGIN
    
        v_dummy := apply_json(p_path, p_content, p_check_types, p_bind);
    
    END;
    
    MEMBER FUNCTION apply_json (
        p_path IN VARCHAR2,
        p_builder IN t_json_builder,
        p_bind IN bind := NULL
    )
    RETURN t_json_value IS
    BEGIN
    
        RETURN apply_json(p_path, p_builder, FALSE, p_bind);
    
    END;
    
    MEMBER FUNCTION apply_json (
        p_path IN VARCHAR2,
        p_builder IN t_json_builder,
        p_check_types IN BOOLEAN,
        p_bind IN bind := NULL
    )
    RETURN t_json_value IS
    BEGIN
    
        RETURN t_json_value(
            json_core.apply_json(
                json_core.request_value(id, p_path, p_bind, TRUE),
                json_builders.build_parse_events(p_builder.id),
                p_check_types
            )
        );
    
    END;
    
    MEMBER PROCEDURE apply_json (
        self IN t_json_value,
        p_path IN VARCHAR2,
        p_builder IN t_json_builder,
        p_bind IN bind := NULL
    ) IS
    
        v_dummy t_json_value;
    
    BEGIN
    
        v_dummy := apply_json(p_path, p_builder, p_bind);
    
    END;
    
    MEMBER PROCEDURE apply_json (
        self IN t_json_value,
        p_path IN VARCHAR2,
        p_builder IN t_json_builder,
        p_check_types IN BOOLEAN,
        p_bind IN bind := NULL
    ) IS
    
        v_dummy t_json_value;
    
    BEGIN
    
        v_dummy := apply_json(p_path, p_builder, p_check_types, p_bind);
    
    END;
    
    MEMBER PROCEDURE apply_json (
        self IN t_json_value,        
        p_content IN VARCHAR2
    ) IS
    BEGIN
    
        apply_json(p_content, FALSE);
    
    END;
    
    MEMBER PROCEDURE apply_json (
        self IN t_json_value,
        p_content IN VARCHAR2,
        p_check_types IN BOOLEAN
    ) IS
    
        v_parse_events json_parser.t_parse_events;
        v_dummy NUMBER;
    
    BEGIN
    
        json_parser.parse(p_content, v_parse_events);
        
        IF NOT (v_parse_events(1).name = 'START_OBJECT' AND is_object
                OR v_parse_events(1).name = 'START_ARRAY' AND is_array) THEN
               
            -- Applying which alters value ID is not allowed!
            error$.raise('JDC-00045'); 
                
        END IF;
        
        v_dummy := json_core.apply_json(
            id,
            v_parse_events,
            p_check_types
        );
    
    END;
    
    MEMBER PROCEDURE apply_json (
        self IN t_json_value,
        p_content IN CLOB
    ) IS
    BEGIN
    
        apply_json(p_content, FALSE);
    
    END;
    
    MEMBER PROCEDURE apply_json (
        self IN t_json_value,
        p_content IN CLOB,
        p_check_types IN BOOLEAN
    ) IS
    
        v_parse_events json_parser.t_parse_events;
        v_dummy NUMBER;
    
    BEGIN
    
        json_parser.parse(p_content, v_parse_events);
        
        IF NOT (v_parse_events(1).name = 'START_OBJECT' AND is_object
                OR v_parse_events(1).name = 'START_ARRAY' AND is_array) THEN
               
            -- Applying which alters value ID is not allowed!
            error$.raise('JDC-00045'); 
                
        END IF;
        
        v_dummy := json_core.apply_json(
            id,
            v_parse_events,
            p_check_types
        );
    
    END;
    
    MEMBER PROCEDURE apply_json (
        self IN t_json_value,
        p_builder IN t_json_builder
    ) IS
    BEGIN
    
        apply_json(p_builder, FALSE);
    
    END;
    
    MEMBER PROCEDURE apply_json (
        self IN t_json_value,
        p_builder IN t_json_builder,
        p_check_types IN BOOLEAN
    ) IS
    
        v_parse_events json_parser.t_parse_events;
        v_dummy NUMBER;
    
    BEGIN
    
        v_parse_events := json_builders.build_parse_events(p_builder.id);
        
        IF NOT (v_parse_events(1).name = 'START_OBJECT' AND is_object
                OR v_parse_events(1).name = 'START_ARRAY' AND is_array) THEN
               
            -- Applying which alters value ID is not allowed!
            error$.raise('JDC-00045'); 
                
        END IF;
        
        v_dummy := json_core.apply_json(
            id,
            v_parse_events,
            p_check_types
        );
    
    END;
    
    /* Property deletion */
    
    MEMBER PROCEDURE remove (
        self IN t_json_value,
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    ) IS
    
        v_value_id NUMBER;
    
    BEGIN
    
        v_value_id := json_core.request_value(id, p_path, p_bind);
    
        IF v_value_id IS NOT NULL THEN
            json_core.delete_value(v_value_id);
        END IF;
    
    END;
    
    /* Value pinning */
    
    MEMBER PROCEDURE pin (
        self IN t_json_value,
        p_pin_tree IN BOOLEAN := FALSE
    ) IS
    BEGIN
    
        json_core.pin(id, p_pin_tree);
    
    END;
    
    MEMBER PROCEDURE pin (
        self IN t_json_value,
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    ) IS
    
        v_value_id NUMBER;
    
    BEGIN
    
        v_value_id := json_core.request_value(id, p_path, p_bind);
        
        IF v_value_id IS NOT NULL THEN
            json_core.pin(v_value_id, FALSE);
        END IF;
        
    END; 
    
    MEMBER PROCEDURE pin (
        self IN t_json_value,
        p_path IN VARCHAR2,
        p_pin_tree IN BOOLEAN,
        p_bind IN bind := NULL
    ) IS
    
        v_value_id NUMBER;
    
    BEGIN
    
        v_value_id := json_core.request_value(id, p_path, p_bind);
        
        IF v_value_id IS NOT NULL THEN
            json_core.pin(v_value_id, p_pin_tree);
        END IF;
        
    END;    
    
    MEMBER PROCEDURE unpin (
        self IN t_json_value,
        p_unpin_tree IN BOOLEAN := FALSE
    ) IS
    BEGIN
    
        json_core.unpin(id, p_unpin_tree);
    
    END;
    
    MEMBER PROCEDURE unpin (
        self IN t_json_value,
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    ) IS
    
        v_value_id NUMBER;
    
    BEGIN
    
        v_value_id := json_core.request_value(id, p_path, p_bind);
        
        IF v_value_id IS NOT NULL THEN
            json_core.unpin(v_value_id, FALSE);
        END IF;
        
    END; 
    
    MEMBER PROCEDURE unpin (
        self IN t_json_value,
        p_path IN VARCHAR2,
        p_unpin_tree IN BOOLEAN,
        p_bind IN bind := NULL
    ) IS
    
        v_value_id NUMBER;
    
    BEGIN
    
        v_value_id := json_core.request_value(id, p_path, p_bind);
        
        IF v_value_id IS NOT NULL THEN
            json_core.unpin(v_value_id, p_unpin_tree);
        END IF;
        
    END;
    
    /* JSON builder instantiation methods */
  
    STATIC FUNCTION value (
        p_value IN VARCHAR2
    )
    RETURN t_json_builder IS
    BEGIN
    
        RETURN t_json_builder().value(p_value);
    
    END;
    
    STATIC FUNCTION value (
        p_value IN DATE
    )
    RETURN t_json_builder IS
    BEGIN
    
        RETURN t_json_builder().value(p_value);
    
    END;
    
    STATIC FUNCTION value (
        p_value IN NUMBER
    )
    RETURN t_json_builder IS
    BEGIN
    
        RETURN t_json_builder().value(p_value);
    
    END;
    
    STATIC FUNCTION value (
        p_value IN BOOLEAN
    )
    RETURN t_json_builder IS
    BEGIN
    
        RETURN t_json_builder().value(p_value);
    
    END;
    
    STATIC FUNCTION object
    RETURN t_json_builder IS
    BEGIN
    
        RETURN t_json_builder().object;
    
    END;
    
    STATIC FUNCTION array
    RETURN t_json_builder IS
    BEGIN
    
        RETURN t_json_builder().array;
    
    END;
    
    /* JSON filter instantiation method */
    
    MEMBER FUNCTION filter
    RETURN t_json_filter IS
    BEGIN
        RETURN t_json_filter(p_base_value_id => id);
    END;
    
END;