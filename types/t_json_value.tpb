CREATE OR REPLACE TYPE BODY t_json_value IS 
    
    STATIC FUNCTION create_string (
        p_value IN VARCHAR2
    )
    RETURN t_json_value IS
    BEGIN
    
        RETURN json_core.create_json(NULL, NULL, json_core.string_events(p_value));
    
    END;
    
    STATIC FUNCTION create_number (
        p_value IN NUMBER
    )
    RETURN t_json_value IS
    BEGIN
    
        RETURN json_core.create_json(NULL, NULL, json_core.number_events(p_value));
    
    END;
    
    STATIC FUNCTION create_boolean (
        p_value IN BOOLEAN
    )
    RETURN t_json_value IS
    BEGIN
    
        RETURN json_core.create_json(NULL, NULL, json_core.boolean_events(p_value));
    
    END;

    STATIC FUNCTION create_object
    RETURN t_json_value IS
    BEGIN
    
        RETURN json_core.create_json(NULL, NULL, json_core.object_events);
    
    END;
    
    STATIC FUNCTION create_array
    RETURN t_json_value IS
    BEGIN
    
        RETURN json_core.create_json(NULL, NULL, json_core.array_events);
    
    END;
    
    STATIC FUNCTION create_null
    RETURN t_json_value IS
    BEGIN
    
        RETURN json_core.create_json(NULL, NULL, json_core.null_events);
    
    END;
    
    STATIC FUNCTION create_json (
        p_content IN VARCHAR2
    )
    RETURN t_json_value IS
    
        v_parse_events json_parser.t_parse_events;
    
    BEGIN
    
        json_parser.parse(p_content, v_parse_events);
        
        RETURN json_core.create_json(NULL, NULL, v_parse_events);
    
    END;
    
    STATIC FUNCTION create_json (
        p_content IN CLOB
    )
    RETURN t_json_value IS
    
        v_parse_events json_parser.t_parse_events;
    
    BEGIN
    
        json_parser.parse(p_content, v_parse_events);
        
        RETURN json_core.create_json(NULL, NULL, v_parse_events);
    
    END;

    STATIC FUNCTION request_value (
        p_anchor_value_id IN NUMBER,
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    ) RETURN t_json_value IS
    
        c_values SYS_REFCURSOR;
    
        v_id NUMBER;
        v_parent_id NUMBER;
        v_type CHAR;
        v_value VARCHAR2(4000);
        
        v_result t_json_value;
    
    BEGIN
    
        c_values := json_core.get_value_cursor(p_anchor_value_id, p_path, p_bind);
    
        LOOP
    
            FETCH c_values
            INTO v_id, v_parent_id, v_type, v_value;
        
            EXIT WHEN c_values%NOTFOUND;
        
            v_result := t_json_value(v_id, v_parent_id, v_type, v_value);
        
            IF c_values%ROWCOUNT > 1 THEN
            
                CLOSE c_values;
            
                -- Multiple values found at the path :1!
                error$.raise('JDOC-00004', p_path);
                
            END IF;
        
        END LOOP;
    
        CLOSE c_values;
    
        RETURN v_result;
    
    END;

    CONSTRUCTOR FUNCTION t_json_value (
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    ) RETURN self AS RESULT IS
    BEGIN
    
        self := t_json_value(NULL, p_path, p_bind);
    
        RETURN;
    
    END;
    
    CONSTRUCTOR FUNCTION t_json_value (
        p_anchor_value_id IN NUMBER,
        p_path IN VARCHAR2,
        p_bind IN bind
    ) RETURN self AS RESULT IS
    
        v_value t_json_value;
    
    BEGIN
    
        v_value := t_json_value.request_value(p_anchor_value_id, p_path, p_bind);
        
        IF v_value IS NULL THEN
            -- Value :1 does not exist!
            error$.raise('JDOC-00009', p_path);
        END IF;
        
        self := v_value;        
        
        RETURN;
    
    END;
    
    CONSTRUCTOR FUNCTION t_json_value (
        p_id IN NUMBER
    ) RETURN self AS RESULT IS
    BEGIN
    
        SELECT id,
               parent_id,
               type,
               value
        INTO self.id,
             self.parent_id,
             self.type,
             self.value
        FROM json_values
        WHERE id = p_id;
        
        RETURN;
        
    EXCEPTION
        WHEN OTHERS THEN
            -- Value :1 does not exist!
            error$.raise('JDOC-00009', '#' || p_id);
    END;
    
    MEMBER FUNCTION as_string
    RETURN VARCHAR2 IS
    BEGIN
    
        IF type IN ('S', 'N', 'E') THEN
            RETURN value;
        ELSE
            -- Type conversion error!
            error$.raise('JDOC-00010');
        END IF;
    
    END;
    
    MEMBER FUNCTION as_number
    RETURN NUMBER IS
    BEGIN
    
        IF type IN ('N', 'E') THEN
          
            RETURN value;
            
        ELSIF type = 'S' THEN
          
            BEGIN
                RETURN value;
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
    
    MEMBER FUNCTION as_boolean
    RETURN BOOLEAN IS
    BEGIN
    
        IF type IN ('B', 'E') THEN
            RETURN value = 'true';
        ELSE
            -- Type conversion error!
            error$.raise('JDOC-00010');
        END IF;
    
    END;
    
    MEMBER FUNCTION get_parent
    RETURN t_json_value IS
    BEGIN
    
        RETURN t_json_value(parent_id);
    
    END;
    
    MEMBER FUNCTION get_keys
    RETURN t_varchars IS
    
        v_keys t_varchars;
    
    BEGIN
     
        IF type NOT IN ('O', 'R') THEN
            -- Value is not an object!
            error$.raise('JDOC-00021');
        END IF;
        
        SELECT name
        BULK COLLECT INTO v_keys
        FROM json_values
        WHERE parent_id = self.id;
        
        RETURN v_keys;
    
    END;
    
    MEMBER FUNCTION get_length (
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    )
    RETURN PLS_INTEGER IS
    BEGIN
    
        RETURN t_json_value.request_value(id, p_path, p_bind).get_length;
    
    END;
    
    MEMBER FUNCTION get_length
    RETURN PLS_INTEGER IS
    
        v_length NUMBER;
    
    BEGIN
    
        IF type != 'A' THEN
            -- Value is not an array!
            error$.raise('JDOC-00012');
        END IF;
        
        SELECT NVL(MAX(to_index(name)), -1)
        INTO v_length
        FROM json_values 
        WHERE parent_id = self.id;
        
        RETURN v_length + 1;
    
    END;
    
    MEMBER FUNCTION is_object
    RETURN BOOLEAN IS
    BEGIN
    
        RETURN type IN ('O', 'R');
    
    END;
    
    MEMBER FUNCTION is_array
    RETURN BOOLEAN IS
    BEGIN
    
        RETURN type = 'A';
    
    END;
    
    MEMBER FUNCTION has (
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    ) 
    RETURN BOOLEAN IS
    BEGIN
    
        RETURN get(p_path, p_bind) IS NOT NULL;
    
    END;
    
    MEMBER FUNCTION get (
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    )
    RETURN t_json_value IS
        v t_json_value;
    BEGIN
    
        v := t_json_value.request_value(id, p_path, p_bind);
        
        
    
        RETURN v;
    
    END;
    
    MEMBER FUNCTION get_string (
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    )
    RETURN VARCHAR2 IS
    
        v_property t_json_value;
    
    BEGIN
    
        v_property := get(p_path, p_bind);
        
        IF v_property IS NULL THEN
            RETURN NULL;
        ELSE 
            RETURN v_property.as_string;
        END IF;
    
    END;
    
    MEMBER FUNCTION get_number (
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    )
    RETURN NUMBER IS
    
        v_property t_json_value;
    
    BEGIN
    
        v_property := get(p_path, p_bind);
        
        IF v_property IS NULL THEN
            RETURN NULL;
        ELSE 
            RETURN v_property.as_number;
        END IF;
    
    END;
    
    MEMBER FUNCTION get_boolean (
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    )
    RETURN BOOLEAN IS
    
        v_property t_json_value;
    
    BEGIN
    
        v_property := get(p_path, p_bind);
        
        IF v_property IS NULL THEN
            RETURN NULL;
        ELSE 
            RETURN v_property.as_boolean;
        END IF;
    
    END;
    
    MEMBER FUNCTION set_string (
        p_path IN VARCHAR2,
        p_value IN VARCHAR2,
        p_bind IN bind := NULL
    ) RETURN t_json_value IS
    BEGIN
    
        RETURN json_core.set_property(
            p_anchor_value_id => id,
            p_path => p_path,
            p_bind => p_bind,
            p_content_parse_events => json_core.string_events(p_value)
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
    
    MEMBER FUNCTION set_number (
        p_path IN VARCHAR2,
        p_value IN NUMBER,
        p_bind IN bind := NULL
    ) RETURN t_json_value IS
    BEGIN
    
        RETURN json_core.set_property(
            p_anchor_value_id => id,
            p_path => p_path,
            p_bind => p_bind,
            p_content_parse_events => json_core.number_events(p_value)
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
    
        RETURN json_core.set_property(
            p_anchor_value_id => id,
            p_path => p_path,
            p_bind => p_bind,
            p_content_parse_events => json_core.boolean_events(p_value)
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
    
    MEMBER FUNCTION set_object (
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    ) RETURN t_json_value IS
    BEGIN
    
        RETURN json_core.set_property(
            p_anchor_value_id => id,
            p_path => p_path,
            p_bind => p_bind,
            p_content_parse_events => json_core.object_events
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
    
        RETURN json_core.set_property(
            p_anchor_value_id => id,
            p_path => p_path,
            p_bind => p_bind,
            p_content_parse_events => json_core.array_events
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
    
    MEMBER FUNCTION set_null (
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    ) RETURN t_json_value IS
    BEGIN
    
        RETURN json_core.set_property(
            p_anchor_value_id => id,
            p_path => p_path,
            p_bind => p_bind,
            p_content_parse_events => json_core.null_events
        );
    
    END;
    
    MEMBER FUNCTION set_json (
        p_path IN VARCHAR2,
        p_content IN VARCHAR2,
        p_bind IN bind := NULL
    ) RETURN t_json_value IS
    
        v_parse_events json_parser.t_parse_events;
    
    BEGIN
    
        json_parser.parse(p_content, v_parse_events);
    
        RETURN json_core.set_property(
            p_anchor_value_id => id,
            p_path => p_path,
            p_bind => p_bind,
            p_content_parse_events => v_parse_events
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
    
        RETURN json_core.set_property(
            p_anchor_value_id => id,
            p_path => p_path,
            p_bind => p_bind,
            p_content_parse_events => v_parse_events
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
    
    MEMBER PROCEDURE set_null (
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    ) IS
    
        v_dummy t_json_value;
    
    BEGIN
    
        v_dummy := set_null(p_path, p_bind);
        
    END;
    
    MEMBER FUNCTION push_string (
        p_path IN VARCHAR2,
        p_value IN VARCHAR2,
        p_bind IN bind := NULL
    ) 
    RETURN t_json_value IS
    BEGIN
    
        RETURN t_json_value.request_value(id, p_path, p_bind).push_string(p_value);
    
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
    
        IF type != 'A' THEN
            -- Value is not an array!
            error$.raise('JDOC-00012');
        END IF;
        
        RETURN json_core.create_json(
                id
               ,get_length
               ,json_core.string_events(p_value)
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
    
        RETURN t_json_value.request_value(id, p_path, p_bind).push_number(p_value);
    
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
    
        IF type != 'A' THEN
            -- Value is not an array!
            error$.raise('JDOC-00012');
        END IF;
        
        RETURN json_core.create_json(
            id
           ,get_length
           ,json_core.number_events(p_value)
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
    
        RETURN t_json_value.request_value(id, p_path, p_bind).push_boolean(p_value);
    
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
    
        IF type != 'A' THEN
            -- Value is not an array!
            error$.raise('JDOC-00012');
        END IF;
        
        RETURN json_core.create_json(
            id
           ,get_length
           ,json_core.boolean_events(p_value)
        );
    
    END;
    
    MEMBER PROCEDURE push_boolean (
        p_value IN BOOLEAN
    ) IS
    
        v_dummy t_json_value;
    
    BEGIN
    
        v_dummy := push_boolean(p_value);
    
    END;
    
    MEMBER FUNCTION push_object (
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    ) 
    RETURN t_json_value IS
    BEGIN
    
        RETURN t_json_value.request_value(id, p_path, p_bind).push_object;
    
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
    
        IF type != 'A' THEN
            -- Value is not an array!
            error$.raise('JDOC-00012');
        END IF;
        
        RETURN json_core.create_json(
            id
           ,get_length
           ,json_core.object_events
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
    
        RETURN t_json_value.request_value(id, p_path, p_bind).push_array;
    
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
    
        IF type != 'A' THEN
            -- Value is not an array!
            error$.raise('JDOC-00012');
        END IF;
        
        RETURN json_core.create_json(
            id
           ,get_length
           ,json_core.array_events
        );
    
    END;
    
    MEMBER PROCEDURE push_array IS
    
        v_dummy t_json_value;
    
    BEGIN
    
        v_dummy := push_array;
    
    END;
    
    MEMBER FUNCTION push_null (
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    ) 
    RETURN t_json_value IS
    BEGIN
    
        RETURN t_json_value.request_value(id, p_path, p_bind).push_null;
    
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
    
        IF type != 'A' THEN
            -- Value is not an array!
            error$.raise('JDOC-00012');
        END IF;
        
        RETURN json_core.create_json(
            id
           ,get_length
           ,json_core.null_events
        );
    
    END;
    
    MEMBER PROCEDURE push_null IS
    
        v_dummy t_json_value;
    
    BEGIN
    
        v_dummy := push_null;
    
    END;

    MEMBER FUNCTION push_json (
        p_path IN VARCHAR2,
        p_content IN VARCHAR2,
        p_bind IN bind := NULL
    ) 
    RETURN t_json_value IS
    BEGIN
    
        RETURN t_json_value.request_value(id, p_path, p_bind).push_json(p_content);
    
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
    
        IF type != 'A' THEN
            -- Value is not an array!
            error$.raise('JDOC-00012');
        END IF;
        
        json_parser.parse(p_content, v_parse_events);
        
        RETURN json_core.create_json(
            id
           ,get_length
           ,v_parse_events
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
    BEGIN
    
        RETURN t_json_value.request_value(id, p_path, p_bind).push_json(p_content);
    
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
    
        IF type != 'A' THEN
            -- Value is not an array!
            error$.raise('JDOC-00012');
        END IF;
        
        json_parser.parse(p_content, v_parse_events);
        
        RETURN json_core.create_json(
            id
           ,get_length
           ,v_parse_events
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