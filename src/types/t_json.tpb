CREATE OR REPLACE TYPE BODY t_json IS 

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

    -- Value type check methods
    
    MEMBER FUNCTION is_string
    RETURN BOOLEAN IS
    
        v_parent_id NUMBER;
        v_type CHAR;
        v_name VARCHAR2(4000);
        v_value VARCHAR2(4000);
        
    BEGIN
    
        dump(v_parent_id, v_type, v_name, v_value);
        
        RETURN v_type = 'S';
    
    END;
    
    MEMBER FUNCTION is_number
    RETURN BOOLEAN IS
    
        v_parent_id NUMBER;
        v_type CHAR;
        v_name VARCHAR2(4000);
        v_value VARCHAR2(4000);
        
    BEGIN
    
        dump(v_parent_id, v_type, v_name, v_value);
        
        RETURN v_type = 'N';
    
    END;
    
    MEMBER FUNCTION is_date
    RETURN BOOLEAN IS
    
        v_parent_id NUMBER;
        v_type CHAR;
        v_name VARCHAR2(4000);
        v_value VARCHAR2(4000);
        
        v_dummy DATE;
        
    BEGIN
    
        dump(v_parent_id, v_type, v_name, v_value);
        
        IF v_type != 'S' THEN
            RETURN FALSE;
        ELSE
        
            BEGIN
            
                v_dummy := TO_DATE(v_value, json_core.c_DATE_FORMAT);
                
                RETURN TRUE;
                
            EXCEPTION
                WHEN OTHERS THEN
                    RETURN FALSE;
            END;
        
        END IF;
    
    END;
    
    MEMBER FUNCTION is_boolean
    RETURN BOOLEAN IS
    
        v_parent_id NUMBER;
        v_type CHAR;
        v_name VARCHAR2(4000);
        v_value VARCHAR2(4000);
        
    BEGIN
    
        dump(v_parent_id, v_type, v_name, v_value);
        
        RETURN v_type = 'B';
    
    END;
    
    MEMBER FUNCTION is_null
    RETURN BOOLEAN IS
    
        v_parent_id NUMBER;
        v_type CHAR;
        v_name VARCHAR2(4000);
        v_value VARCHAR2(4000);
        
    BEGIN
    
        dump(v_parent_id, v_type, v_name, v_value);
        
        RETURN v_type = 'E';
    
    END;
    
    MEMBER FUNCTION is_object
    RETURN BOOLEAN IS
    
        v_parent_id NUMBER;
        v_type CHAR;
        v_name VARCHAR2(4000);
        v_value VARCHAR2(4000);
        
    BEGIN
    
        dump(v_parent_id, v_type, v_name, v_value);
        
        RETURN v_type IN ('R', 'O');
    
    END;
    
    MEMBER FUNCTION is_array
    RETURN BOOLEAN IS
    
        v_parent_id NUMBER;
        v_type CHAR;
        v_name VARCHAR2(4000);
        v_value VARCHAR2(4000);
        
    BEGIN
    
        dump(v_parent_id, v_type, v_name, v_value);
        
        RETURN v_type = 'A';
    
    END;

    -- Self serialization methods
    
    MEMBER FUNCTION as_string
    RETURN VARCHAR2 IS
    
        v_parent_id NUMBER;
        v_type CHAR;
        v_name VARCHAR2(4000);
        v_value VARCHAR2(4000);
        
    BEGIN
    
        dump(v_parent_id, v_type, v_name, v_value);
        
        IF v_type IN ('S', 'N', 'E') THEN
            RETURN v_value;
        ELSE
            -- Type conversion error!
            error$.raise('JDC-00010');
        END IF;
    
    END;
    
    MEMBER FUNCTION as_number
    RETURN NUMBER IS
    
        v_parent_id NUMBER;
        v_type CHAR;
        v_name VARCHAR2(4000);
        v_value VARCHAR2(4000);
        
    BEGIN
    
        dump(v_parent_id, v_type, v_name, v_value);
        
        IF v_type IN ('N', 'E') THEN
            RETURN v_value;
        ELSIF v_type = 'S' THEN
          
            BEGIN
                RETURN v_value;
            EXCEPTION
                WHEN OTHERS THEN
                    -- Type conversion error!
                    error$.raise('JDC-00010');
            END;
            
        ELSE
            -- Type conversion error!
            error$.raise('JDC-00010');
        END IF;
    
    END;
    
    MEMBER FUNCTION as_date
    RETURN DATE IS
    
        v_string_value VARCHAR2(4000);
    
    BEGIN
    
        v_string_value := as_string;
        
        IF v_string_value IS NULL THEN
            RETURN NULL;
        ELSE
            BEGIN
                RETURN TO_DATE(v_string_value, json_core.c_DATE_FORMAT);
            EXCEPTION
                WHEN OTHERS THEN
                    -- Type conversion error!
                    error$.raise('JDC-00010');
            END;
        END IF;
    
    END;
    
    MEMBER FUNCTION as_boolean
    RETURN BOOLEAN IS
    
        v_parent_id NUMBER;
        v_type CHAR;
        v_name VARCHAR2(4000);
        v_value VARCHAR2(4000);
        
    BEGIN
    
        dump(v_parent_id, v_type, v_name, v_value);
        
        IF v_type IN ('B', 'E') THEN
            RETURN v_value = 'true';
        ELSE
            -- Type conversion error!
            error$.raise('JDC-00010');
        END IF;
    
    END;
    
    MEMBER FUNCTION as_json (
        p_serialize_nulls IN BOOLEAN := TRUE
    )
    RETURN VARCHAR2 IS
    
        v_json VARCHAR2(32767);
        v_json_clob CLOB;
    
    BEGIN
    
        json_core.serialize_value(
            get_parse_events(p_serialize_nulls),
            v_json,
            v_json_clob
        );
        
        RETURN v_json;
    
    END;
    
    MEMBER FUNCTION as_json_clob (
        p_serialize_nulls IN BOOLEAN := TRUE
    )
    RETURN CLOB IS
    
        v_json VARCHAR2(32767);
        v_json_clob CLOB;
    
    BEGIN
    
        dbms_lob.createtemporary(v_json_clob, TRUE);
    
        json_core.serialize_value(
            get_parse_events(p_serialize_nulls),
            v_json,
            v_json_clob
        );
        
        RETURN v_json_clob;
    
    END;
    
    -- Special object methods
    
    MEMBER FUNCTION contains (
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    )
    RETURN BOOLEAN IS
    BEGIN
        RETURN get(p_path, p_bind) IS NOT NULL;
    END;
    
    MEMBER FUNCTION has (
        p_key IN VARCHAR2
    )
    RETURN BOOLEAN IS
    BEGIN
        RETURN get(':key', bind(p_key)) IS NOT NULL;
    END;
    
    -- Special array methods
    
    MEMBER FUNCTION index_of (
        p_value IN VARCHAR2
       ,p_from_index IN NATURALN := 0
    )
    RETURN NUMBER IS
    BEGIN
    
        RETURN index_of(
            'S', 
            p_value,
            p_from_index
        );
        
    END;
    
    MEMBER FUNCTION index_of (
        p_value IN NUMBER
       ,p_from_index IN NATURALN := 0
    )
    RETURN NUMBER IS
    BEGIN
    
        RETURN index_of(
            'N', 
            json_core.to_json_char(p_value),
            p_from_index
        );
        
    END;
    
    MEMBER FUNCTION index_of (
        p_value IN DATE
       ,p_from_index IN NATURALN := 0
    )
    RETURN NUMBER IS
    BEGIN
    
        RETURN index_of(
            'S', 
            json_core.to_json_char(p_value),
            p_from_index
        );
        
    END;
    
    MEMBER FUNCTION index_of (
        p_value IN BOOLEAN
       ,p_from_index IN NATURALN := 0
    )
    RETURN NUMBER IS
    BEGIN
    
        RETURN index_of(
            'B', 
            json_core.to_json_char(p_value),
            p_from_index
        );
        
    END;
    
    MEMBER FUNCTION index_of_null (
        p_from_index IN NATURALN := 0
    )
    RETURN NUMBER IS
    BEGIN
    
        RETURN index_of(
            'E', 
            NULL,
            p_from_index
        );
        
    END;
    
    -- Child element retrieval methods
    
    MEMBER FUNCTION get (
        p_index IN NUMBER
    )
    RETURN t_json IS
    BEGIN
        RETURN get(':key', bind(p_index));
    END;
    
    MEMBER FUNCTION get_string (
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    )
    RETURN VARCHAR2 IS
        v_child t_json;
    BEGIN
    
        v_child := get(p_path, p_bind);
        
        IF v_child IS NULL THEN
            RETURN NULL;
        ELSE
            RETURN v_child.as_string;
        END IF;
    
    END;
    
    MEMBER FUNCTION get_string (
        p_index IN NUMBER
    )
    RETURN VARCHAR2 IS
        v_child t_json;
    BEGIN
    
        v_child := get(p_index);
        
        IF v_child IS NULL THEN
            RETURN NULL;
        ELSE
            RETURN v_child.as_string;
        END IF;
    
    END;
    
    MEMBER FUNCTION get_date (
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    )
    RETURN DATE IS
        v_child t_json;
    BEGIN
    
        v_child := get(p_path, p_bind);
        
        IF v_child IS NULL THEN
            RETURN NULL;
        ELSE
            RETURN v_child.as_date;
        END IF;
    
    END;
    
    MEMBER FUNCTION get_date (
        p_index IN NUMBER
    )
    RETURN DATE IS
        v_child t_json;
    BEGIN
    
        v_child := get(p_index);
        
        IF v_child IS NULL THEN
            RETURN NULL;
        ELSE
            RETURN v_child.as_date;
        END IF;
    
    END;
    
    MEMBER FUNCTION get_number (
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    )
    RETURN NUMBER IS
        v_child t_json;
    BEGIN
    
        v_child := get(p_path, p_bind);
        
        IF v_child IS NULL THEN
            RETURN NULL;
        ELSE
            RETURN v_child.as_number;
        END IF;
    
    END;
    
    MEMBER FUNCTION get_number (
        p_index IN NUMBER
    )
    RETURN NUMBER IS
        v_child t_json;
    BEGIN
    
        v_child := get(p_index);
        
        IF v_child IS NULL THEN
            RETURN NULL;
        ELSE
            RETURN v_child.as_number;
        END IF;
    
    END;
    
    MEMBER FUNCTION get_boolean (
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    )
    RETURN BOOLEAN IS
        v_child t_json;
    BEGIN
    
        v_child := get(p_path, p_bind);
        
        IF v_child IS NULL THEN
            RETURN NULL;
        ELSE
            RETURN v_child.as_boolean;
        END IF;
    
    END;
    
    MEMBER FUNCTION get_boolean (
        p_index IN NUMBER
    )
    RETURN BOOLEAN IS
        v_child t_json;
    BEGIN
    
        v_child := get(p_index);
        
        IF v_child IS NULL THEN
            RETURN NULL;
        ELSE
            RETURN v_child.as_boolean;
        END IF;
    
    END;
    
    MEMBER FUNCTION get_json (
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    )
    RETURN VARCHAR2 IS
        v_child t_json;
    BEGIN
    
        v_child := get(p_path, p_bind);
        
        IF v_child IS NULL THEN
            RETURN NULL;
        ELSE
            RETURN v_child.as_json;
        END IF;
    
    END;
    
    MEMBER FUNCTION get_json (
        p_path IN VARCHAR2,
        p_serialize_nulls IN BOOLEAN,
        p_bind IN bind := NULL
    )
    RETURN VARCHAR2 IS
        v_child t_json;
    BEGIN
    
        v_child := get(p_path, p_bind);
        
        IF v_child IS NULL THEN
            RETURN NULL;
        ELSE
            RETURN v_child.as_json(p_serialize_nulls);
        END IF;
    
    END;
    
    MEMBER FUNCTION get_json (
        p_index IN NUMBER,
        p_serialize_nulls IN BOOLEAN := TRUE
    )
    RETURN VARCHAR2 IS
        v_child t_json;
    BEGIN
    
        v_child := get(p_index);
        
        IF v_child IS NULL THEN
            RETURN NULL;
        ELSE
            RETURN v_child.as_json(p_serialize_nulls);
        END IF;
    
    END;
    
    MEMBER FUNCTION get_json_clob (
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    )
    RETURN CLOB IS
        v_child t_json;
    BEGIN
    
        v_child := get(p_path, p_bind);
        
        IF v_child IS NULL THEN
            RETURN NULL;
        ELSE
            RETURN v_child.as_json_clob;
        END IF;
    
    END;
    
    MEMBER FUNCTION get_json_clob (
        p_path IN VARCHAR2,
        p_serialize_nulls IN BOOLEAN,
        p_bind IN bind := NULL
    )
    RETURN CLOB IS
        v_child t_json;
    BEGIN
    
        v_child := get(p_path, p_bind);
        
        IF v_child IS NULL THEN
            RETURN NULL;
        ELSE
            RETURN v_child.as_json_clob(p_serialize_nulls);
        END IF;
    
    END;
    
    MEMBER FUNCTION get_json_clob (
        p_index IN NUMBER,
        p_serialize_nulls IN BOOLEAN := TRUE
    )
    RETURN CLOB IS
        v_child t_json;
    BEGIN
    
        v_child := get(p_index);
        
        IF v_child IS NULL THEN
            RETURN NULL;
        ELSE
            RETURN v_child.as_json_clob(p_serialize_nulls);
        END IF;
    
    END;
    
    MEMBER FUNCTION get_strings
    RETURN t_varchars IS
    BEGIN
        json_core.allow_private_call;
        RETURN get_raw_values('S');
    END;
    
    MEMBER FUNCTION get_numbers
    RETURN t_numbers IS
    
        v_raw_values t_varchars;
        v_numbers t_numbers;
        
    BEGIN
        
        json_core.allow_private_call;
        v_raw_values := get_raw_values('N');
        
        v_numbers := t_numbers();
        v_numbers.EXTEND(v_raw_values.COUNT);
        
        FOR v_i IN 1..v_raw_values.COUNT LOOP
            v_numbers(v_i) := v_raw_values(v_i);
        END LOOP;
        
        RETURN v_numbers;
    
    END;
    
    MEMBER FUNCTION get_dates
    RETURN t_dates IS
    
        v_raw_values t_varchars;
        v_dates t_dates;
        
    BEGIN
        
        json_core.allow_private_call;
        v_raw_values := get_raw_values('S');
        
        v_dates := t_dates();
        v_dates.EXTEND(v_raw_values.COUNT);
        
        FOR v_i IN 1..v_raw_values.COUNT LOOP
        
            BEGIN
                v_dates(v_i) := TO_DATE(v_raw_values(v_i), 'YYYY-MM-DD');
            EXCEPTION
                WHEN OTHERS THEN
                    -- Type conversion error!
                    error$.raise('JDC-00010');
            END;
            
        END LOOP;
        
        RETURN v_dates;
    
    END;
    
    -- Property modification methods
    
    MEMBER FUNCTION set_string (
        p_path IN VARCHAR2,
        p_value IN VARCHAR2,
        p_bind IN bind := NULL
    ) 
    RETURN t_json IS
    BEGIN
    
        json_core.allow_private_call;
    
        RETURN set_json(
            p_path,
            json_core.string_events(p_value),
            p_bind
        );
    
    END;
    
    MEMBER PROCEDURE set_string (
        self IN t_json,
        p_path IN VARCHAR2,
        p_value IN VARCHAR2,
        p_bind IN bind := NULL
    ) IS
        v_dummy t_json;
    BEGIN
    
        v_dummy := set_string(
            p_path,
            p_value,
            p_bind
        );
    
    END;
    
    MEMBER FUNCTION set_string (
        p_index IN NUMBER,
        p_value IN VARCHAR2
    ) 
    RETURN t_json IS
    BEGIN
    
        RETURN set_string(
            ':key',
            p_value,
            bind(p_index)
        );
    
    END;
    
    MEMBER PROCEDURE set_string (
        self IN t_json,
        p_index IN NUMBER,
        p_value IN VARCHAR2
    ) IS
    BEGIN
    
        set_string(
            ':key',
            p_value,
            bind(p_index)
        );
    
    END;
    
    MEMBER FUNCTION set_number (
        p_path IN VARCHAR2,
        p_value IN NUMBER,
        p_bind IN bind := NULL
    ) 
    RETURN t_json IS
    BEGIN
    
        json_core.allow_private_call;
    
        RETURN set_json(
            p_path,
            json_core.number_events(p_value),
            p_bind
        );
    
    END;
    
    MEMBER PROCEDURE set_number (
        self IN t_json,
        p_path IN VARCHAR2,
        p_value IN NUMBER,
        p_bind IN bind := NULL
    ) IS
        v_dummy t_json;
    BEGIN
    
        v_dummy := set_number(
            p_path,
            p_value,
            p_bind
        );
    
    END;
    
    MEMBER FUNCTION set_number (
        p_index IN NUMBER,
        p_value IN NUMBER
    ) 
    RETURN t_json IS
    BEGIN
    
        RETURN set_number(
            ':key',
            p_value,
            bind(p_index)
        );
    
    END;
    
    MEMBER PROCEDURE set_number (
        self IN t_json,
        p_index IN NUMBER,
        p_value IN NUMBER
    ) IS
    BEGIN
    
        set_number(
            ':key',
            p_value,
            bind(p_index)
        );
    
    END;
    
    MEMBER FUNCTION set_date (
        p_path IN VARCHAR2,
        p_value IN DATE,
        p_bind IN bind := NULL
    ) 
    RETURN t_json IS
    BEGIN
    
        json_core.allow_private_call;
    
        RETURN set_json(
            p_path,
            json_core.date_events(p_value),
            p_bind
        );
    
    END;
    
    MEMBER PROCEDURE set_date (
        self IN t_json,
        p_path IN VARCHAR2,
        p_value IN DATE,
        p_bind IN bind := NULL
    ) IS
        v_dummy t_json;
    BEGIN
    
        v_dummy := set_date(
            p_path,
            p_value,
            p_bind
        );
    
    END;
    
    MEMBER FUNCTION set_date (
        p_index IN NUMBER,
        p_value IN DATE
    ) 
    RETURN t_json IS
    BEGIN
    
        RETURN set_date(
            ':key',
            p_value,
            bind(p_index)
        );
    
    END;
    
    MEMBER PROCEDURE set_date (
        self IN t_json,
        p_index IN NUMBER,
        p_value IN DATE
    ) IS
    BEGIN
    
        set_date(
            ':key',
            p_value,
            bind(p_index)
        );
    
    END;
    
    MEMBER FUNCTION set_boolean (
        p_path IN VARCHAR2,
        p_value IN BOOLEAN,
        p_bind IN bind := NULL
    ) 
    RETURN t_json IS
    BEGIN
    
        json_core.allow_private_call;
    
        RETURN set_json(
            p_path,
            json_core.boolean_events(p_value),
            p_bind
        );
    
    END;
    
    MEMBER PROCEDURE set_boolean (
        self IN t_json,
        p_path IN VARCHAR2,
        p_value IN BOOLEAN,
        p_bind IN bind := NULL
    ) IS
        v_dummy t_json;
    BEGIN
    
        v_dummy := set_boolean(
            p_path,
            p_value,
            p_bind
        );
    
    END;
    
    MEMBER FUNCTION set_boolean (
        p_index IN NUMBER,
        p_value IN BOOLEAN
    ) 
    RETURN t_json IS
    BEGIN
    
        RETURN set_boolean(
            ':key',
            p_value,
            bind(p_index)
        );
    
    END;
    
    MEMBER PROCEDURE set_boolean (
        self IN t_json,
        p_index IN NUMBER,
        p_value IN BOOLEAN
    ) IS
    BEGIN
    
        set_boolean(
            ':key',
            p_value,
            bind(p_index)
        );
    
    END;
    
    MEMBER FUNCTION set_null (
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    ) 
    RETURN t_json IS
    BEGIN
    
        json_core.allow_private_call;
    
        RETURN set_json(
            p_path,
            json_core.null_events,
            p_bind
        );
    
    END;
    
    MEMBER PROCEDURE set_null (
        self IN t_json,
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    ) IS
        v_dummy t_json;
    BEGIN
    
        v_dummy := set_null(
            p_path,
            p_bind
        );
    
    END;
    
    MEMBER FUNCTION set_null (
        p_index IN NUMBER
    ) 
    RETURN t_json IS
    BEGIN
    
        RETURN set_null(
            ':key',
            bind(p_index)
        );
    
    END;
    
    MEMBER PROCEDURE set_null (
        self IN t_json,
        p_index IN NUMBER
    ) IS
    BEGIN
    
        set_null(
            ':key',
            bind(p_index)
        );
    
    END;
    
    MEMBER FUNCTION set_object (
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    ) 
    RETURN t_json IS
    BEGIN
    
        json_core.allow_private_call;
    
        RETURN set_json(
            p_path,
            json_core.object_events,
            p_bind
        );
    
    END;
    
    MEMBER PROCEDURE set_object (
        self IN t_json,
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    ) IS
        v_dummy t_json;
    BEGIN
    
        v_dummy := set_object(
            p_path,
            p_bind
        );
    
    END;
    
    MEMBER FUNCTION set_object (
        p_index IN NUMBER
    ) 
    RETURN t_json IS
    BEGIN
    
        RETURN set_object(
            ':key',
            bind(p_index)
        );
    
    END;
    
    MEMBER PROCEDURE set_object (
        self IN t_json,
        p_index IN NUMBER
    ) IS
    BEGIN
    
        set_object(
            ':key',
            bind(p_index)
        );
    
    END;
    
    MEMBER FUNCTION set_array (
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    ) 
    RETURN t_json IS
    BEGIN
    
        json_core.allow_private_call;
    
        RETURN set_json(
            p_path,
            json_core.array_events,
            p_bind
        );
    
    END;
    
    MEMBER PROCEDURE set_array (
        self IN t_json,
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    ) IS
        v_dummy t_json;
    BEGIN
    
        v_dummy := set_array(
            p_path,
            p_bind
        );
    
    END;
    
    MEMBER FUNCTION set_array (
        p_index IN NUMBER
    ) 
    RETURN t_json IS
    BEGIN
    
        RETURN set_array(
            ':key',
            bind(p_index)
        );
    
    END;
    
    MEMBER PROCEDURE set_array (
        self IN t_json,
        p_index IN NUMBER
    ) IS
    BEGIN
    
        set_array(
            ':key',
            bind(p_index)
        );
    
    END;
    
    MEMBER FUNCTION set_json (
        p_path IN VARCHAR2,
        p_content IN VARCHAR2,
        p_bind IN bind := NULL
    ) 
    RETURN t_json IS
    BEGIN
    
        json_core.allow_private_call;
    
        RETURN set_json(
            p_path,
            json_parser.parse(p_content),
            p_bind
        );
    
    END;
    
    MEMBER PROCEDURE set_json (
        self IN t_json,
        p_path IN VARCHAR2,
        p_content IN VARCHAR2,
        p_bind IN bind := NULL
    ) IS
        v_dummy t_json;
    BEGIN
    
        v_dummy := set_json(
            p_path,
            p_content,
            p_bind
        );
    
    END;
    
    MEMBER FUNCTION set_json (
        p_index IN NUMBER,
        p_content IN VARCHAR2
    ) 
    RETURN t_json IS
    BEGIN
    
        RETURN set_json(
            ':key',
            p_content,
            bind(p_index)
        );
    
    END;
    
    MEMBER PROCEDURE set_json (
        self IN t_json,
        p_index IN NUMBER,
        p_content IN VARCHAR2
    ) IS
    BEGIN
    
        set_json(
            ':key',
            p_content,
            bind(p_index)
        );
    
    END;
    
    MEMBER FUNCTION set_json (
        p_path IN VARCHAR2,
        p_content IN CLOB,
        p_bind IN bind := NULL
    ) 
    RETURN t_json IS
    BEGIN
    
        json_core.allow_private_call;
    
        RETURN set_json(
            p_path,
            json_parser.parse(p_content),
            p_bind
        );
    
    END;
    
    MEMBER PROCEDURE set_json (
        self IN t_json,
        p_path IN VARCHAR2,
        p_content IN CLOB,
        p_bind IN bind := NULL
    ) IS
        v_dummy t_json;
    BEGIN
    
        v_dummy := set_json(
            p_path,
            p_content,
            p_bind
        );
    
    END;
    
    MEMBER FUNCTION set_json (
        p_index IN NUMBER,
        p_content IN CLOB
    ) 
    RETURN t_json IS
    BEGIN
    
        RETURN set_json(
            ':key',
            p_content,
            bind(p_index)
        );
    
    END;
    
    MEMBER PROCEDURE set_json (
        self IN t_json,
        p_index IN NUMBER,
        p_content IN CLOB
    ) IS
    BEGIN
    
        set_json(
            ':key',
            p_content,
            bind(p_index)
        );
    
    END;
    
    MEMBER FUNCTION set_json (
        p_path IN VARCHAR2,
        p_builder IN t_json_builder,
        p_bind IN bind := NULL
    ) 
    RETURN t_json IS
    BEGIN
    
        IF p_builder IS NULL THEN
            -- Builder not specified!
            error$.raise('JDC-00048');  
        END IF;
    
        json_core.allow_private_call;
    
        RETURN set_json(
            p_path,
            p_builder.build_parse_events,
            p_bind
        );
    
    END;
    
    MEMBER PROCEDURE set_json (
        self IN t_json,
        p_path IN VARCHAR2,
        p_builder IN t_json_builder,
        p_bind IN bind := NULL
    ) IS
        v_dummy t_json;
    BEGIN
    
        v_dummy := set_json(
            p_path,
            p_builder,
            p_bind
        );
    
    END;
    
    MEMBER FUNCTION set_json (
        p_index IN NUMBER,
        p_builder IN t_json_builder
    ) 
    RETURN t_json IS
    BEGIN
    
        RETURN set_json(
            ':key',
            p_builder,
            bind(p_index)
        );
    
    END;
    
    MEMBER PROCEDURE set_json (
        self IN t_json,
        p_index IN NUMBER,
        p_builder IN t_json_builder
    ) IS
    BEGIN
    
        set_json(
            ':key',
            p_builder,
            bind(p_index)
        );
    
    END;
    
    MEMBER FUNCTION set_json (
        p_path IN VARCHAR2,
        p_value IN t_json,
        p_bind IN bind := NULL
    ) 
    RETURN t_json IS
    BEGIN
    
        IF p_value IS NULL THEN
            -- Property value not specified!
            error$.raise('JDC-00049');
        END IF;
    
        json_core.allow_private_call;
    
        RETURN set_json(
            p_path,
            p_value.get_parse_events(TRUE),
            p_bind
        );
    
    END;
    
    MEMBER PROCEDURE set_json (
        self IN t_json,
        p_path IN VARCHAR2,
        p_value IN t_json,
        p_bind IN bind := NULL
    ) IS
        v_dummy t_json;
    BEGIN
    
        v_dummy := set_json(
            p_path,
            p_value,
            p_bind
        );
    
    END;
    
    MEMBER FUNCTION set_json (
        p_index IN NUMBER,
        p_value IN t_json
    ) 
    RETURN t_json IS
    BEGIN
    
        RETURN set_json(
            ':key',
            p_value,
            bind(p_index)
        );
    
    END;
    
    MEMBER PROCEDURE set_json (
        self IN t_json,
        p_index IN NUMBER,
        p_value IN t_json
    ) IS
    BEGIN
    
        set_json(
            ':key',
            p_value,
            bind(p_index)
        );
    
    END;
    
    -- Array push methods
    
    MEMBER FUNCTION push_string (
        p_value IN VARCHAR2
    ) 
    RETURN t_json IS
    BEGIN
    
        json_core.allow_private_call;
        
        RETURN set_json(
            ':i',
            json_core.string_events(p_value),
            bind(get_length)
        );
    
    END;
    
    MEMBER PROCEDURE push_string (
        self IN t_json,
        p_value IN VARCHAR2
    ) IS
        v_dummy t_json;
    BEGIN
        v_dummy := push_string(p_value);
    END;
    
    MEMBER FUNCTION push_number (
        p_value IN NUMBER
    ) 
    RETURN t_json IS
    BEGIN
    
        json_core.allow_private_call;
        
        RETURN set_json(
            ':i',
            json_core.number_events(p_value),
            bind(get_length)
        );
    
    END;
    
    MEMBER PROCEDURE push_number (
        self IN t_json,
        p_value IN NUMBER
    ) IS
        v_dummy t_json;
    BEGIN
        v_dummy := push_number(p_value);
    END;
    
    MEMBER FUNCTION push_date (
        p_value IN DATE
    ) 
    RETURN t_json IS
    BEGIN
    
        json_core.allow_private_call;
    
        RETURN set_json(
            ':i',
            json_core.date_events(p_value),
            bind(get_length)
        );
        
    END;
    
    MEMBER PROCEDURE push_date (
        self IN t_json,
        p_value IN DATE
    ) IS
        v_dummy t_json;
    BEGIN
        v_dummy := push_date(p_value);
    END;
    
    MEMBER FUNCTION push_boolean (
        p_value IN BOOLEAN
    ) 
    RETURN t_json IS
    BEGIN
    
        json_core.allow_private_call;
    
        RETURN set_json(
            ':i',
            json_core.boolean_events(p_value),
            bind(get_length)
        );
        
    END;
    
    MEMBER PROCEDURE push_boolean (
        self IN t_json,
        p_value IN BOOLEAN
    ) IS
        v_dummy t_json;
    BEGIN
        v_dummy := push_boolean(p_value);
    END;
    
    MEMBER FUNCTION push_null
    RETURN t_json IS
    BEGIN
    
        json_core.allow_private_call;
    
        RETURN set_json(
            ':i',
            json_core.null_events,
            bind(get_length)
        );
        
    END;
    
    MEMBER PROCEDURE push_null (
        self IN t_json
    ) IS
        v_dummy t_json;
    BEGIN
        v_dummy := push_null;
    END;
    
    MEMBER FUNCTION push_object
    RETURN t_json IS
    BEGIN
    
        json_core.allow_private_call;
    
        RETURN set_json(
            ':i',
            json_core.object_events,
            bind(get_length)
        );
        
    END;
    
    MEMBER PROCEDURE push_object (
        self IN t_json
    ) IS
        v_dummy t_json;
    BEGIN
        v_dummy := push_object;
    END;
    
    MEMBER FUNCTION push_array
    RETURN t_json IS
    BEGIN
    
        json_core.allow_private_call;
    
        RETURN set_json(
            ':i',
            json_core.array_events,
            bind(get_length)
        );
        
    END;
    
    MEMBER PROCEDURE push_array (
        self IN t_json
    ) IS
        v_dummy t_json;
    BEGIN
        v_dummy := push_array;
    END;
    
    MEMBER FUNCTION push_json (
        p_content IN VARCHAR2
    )
    RETURN t_json IS
    BEGIN
    
        json_core.allow_private_call;
        
        RETURN set_json(
            ':i',
            json_parser.parse(p_content),
            bind(get_length)
        );
    
    END;
    
    MEMBER PROCEDURE push_json (
        self IN t_json,
        p_content IN VARCHAR2
    ) IS
        v_dummy t_json;
    BEGIN
        v_dummy := push_json(p_content);
    END;
    
    MEMBER FUNCTION push_json (
        p_content IN CLOB
    )
    RETURN t_json IS
    BEGIN
    
        json_core.allow_private_call;
        
        RETURN set_json(
            ':i',
            json_parser.parse(p_content),
            bind(get_length)
        );
    
    END; 
    
    MEMBER PROCEDURE push_json (
        self IN t_json,
        p_content IN CLOB
    ) IS
        v_dummy t_json;
    BEGIN
        v_dummy := push_json(p_content);
    END; 
    
    MEMBER FUNCTION push_json (
        p_builder IN t_json_builder
    )
    RETURN t_json IS
    BEGIN
        
        IF p_builder IS NULL THEN
            -- Builder not specified!
            error$.raise('JDC-00048');  
        END IF;
    
        json_core.allow_private_call;
        
        RETURN set_json(
            ':i',
            p_builder.build_parse_events,
            bind(get_length)
        );
    
    END;
    
    MEMBER PROCEDURE push_json (
        self IN t_json,
        p_builder IN t_json_builder
    ) IS
        v_dummy t_json;
    BEGIN
        v_dummy := push_json(p_builder);
    END;
    
    MEMBER FUNCTION push_json (
        p_value IN t_json
    )
    RETURN t_json IS
    BEGIN
    
        IF p_value IS NULL THEN
            -- Property value not specified!
            error$.raise('JDC-00049');
        END IF;
    
        json_core.allow_private_call;
    
        RETURN set_json(
            ':i',
            p_value.get_parse_events(TRUE),
            bind(get_length)
        );
        
    END;
    
    MEMBER PROCEDURE push_json (
        self IN t_json,
        p_value IN t_json
    ) IS
        v_dummy t_json;
    BEGIN
        v_dummy := push_json(p_value);
    END;
    
    -- Apply methods
    
    MEMBER PROCEDURE apply_json (
        p_content_parse_events IN t_varchars
    ) IS
        
        v_event_i PLS_INTEGER;
        v_event_name CHAR;
        v_event_value VARCHAR2(4000);
        
        PROCEDURE decompose_event IS
            v_event json_core.STRING;
        BEGIN
            v_event := p_content_parse_events(v_event_i);
            v_event_name := SUBSTR(v_event, 1, 1);
            v_event_value := SUBSTR(v_event, 2);
        END;
        
        PROCEDURE skip_events IS
            v_depth PLS_INTEGER;
            v_event json_core.STRING;
        BEGIN
        
            v_depth := 0;
        
            LOOP
            
                v_event := p_content_parse_events(v_event_i);
                
                IF v_event IN ('{', '[') THEN
                    v_depth := v_depth + 1;
                ELSIF v_event IN ('}', ']') THEN
                    v_depth := v_depth - 1;
                END IF;
                
                v_event_i := v_event_i + 1;
                
                EXIT WHEN v_depth = 0; 
            
            END LOOP;
        
        END;
        
        PROCEDURE visit_value (
            p_value IN OUT NOCOPY t_json
        ) IS
        
            v_parent_id NUMBER;
            v_type CHAR;
            v_name VARCHAR2(4000);
            v_value VARCHAR2(4000);
            
            v_child_value t_json;
            v_dummy NUMBER;
        
        BEGIN
        
            decompose_event;
            p_value.dump(v_parent_id, v_type, v_name, v_value);
            
            IF v_event_name IN ('S', 'N', 'B') THEN
            
                IF v_event_name != v_type OR v_event_value != v_value THEN
                
                    p_value.remove;
                    
                    json_core.allow_private_call;
                    p_value.id := create_json(v_parent_id, v_name, p_content_parse_events, v_event_i);
                    
                END IF;
                
                skip_events;
                
            ELSIF v_event_name = 'E' THEN
            
                IF v_event_name != v_type THEN
                
                    p_value.remove;
                    
                    json_core.allow_private_call;
                    p_value.id := create_json(v_parent_id, v_name, p_content_parse_events, v_event_i);
                    
                END IF;
                
                skip_events;
                
            ELSIF v_event_name IN ('{', '[') THEN
            
                IF TRANSLATE(v_event_name, '{[', 'OA') != v_type THEN
                
                    p_value.remove;
                    
                    json_core.allow_private_call;
                    p_value.id := create_json(v_parent_id, v_name, p_content_parse_events, v_event_i);
                    
                    skip_events;
                    
                ELSE
                
                    v_event_i := v_event_i + 1;
                    decompose_event;
                    
                    WHILE v_event_name NOT IN ('}', ']') LOOP
                    
                        v_child_value := p_value.get_property(v_event_value);
                        v_event_i := v_event_i + 1;
                        
                        IF v_child_value IS NULL THEN
                        
                            json_core.allow_private_call;
                            v_dummy := create_json(p_value.id, v_event_value, p_content_parse_events, v_event_i);
                            
                            skip_events;
                            
                        ELSE
                            visit_value(v_child_value);
                        END IF;
                        
                        decompose_event;
                    
                    END LOOP;
                
                END IF;
                
            END IF;
        
        END;
        
    BEGIN

        json_core.private_call;

        v_event_i := 1;
        visit_value(self);        
    
    END;
    
    MEMBER PROCEDURE apply_json (
        p_content IN VARCHAR2
    ) IS
    BEGIN
        json_core.allow_private_call;
        apply_json(json_parser.parse(p_content));
    END;
    
    MEMBER PROCEDURE apply_json (
        p_content IN CLOB
    ) IS
    BEGIN
        json_core.allow_private_call;
        apply_json(json_parser.parse(p_content));
    END;
    
    MEMBER PROCEDURE apply_json (
        p_content IN t_json
    ) IS
    BEGIN
        json_core.allow_private_call;
        apply_json(p_content.get_parse_events(TRUE));
    END;
    
    -- Value deletion methods
    
    MEMBER PROCEDURE remove (
        self IN t_json,
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    ) IS
        v_property t_json;
    BEGIN
    
        v_property := get(p_path, p_bind);
        
        IF v_property IS NOT NULL THEN
            v_property.remove;
        END IF;
    
    END;
    
    MEMBER PROCEDURE remove (
        self IN t_json,
        p_index IN NUMBER
    ) IS
    BEGIN
        remove(':i', bind(p_index));
    END;
    
    -- Value locking methods
    
    MEMBER PROCEDURE pin (
        self IN t_json,
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    ) IS
    BEGIN
        pin(p_path, FALSE, p_bind);
    END;
    
    MEMBER PROCEDURE pin (
        self IN t_json,
        p_path IN VARCHAR2,
        p_pin_tree IN BOOLEAN,
        p_bind IN bind := NULL
    ) IS
        v_property t_json;
    BEGIN
        
        v_property := get(p_path, p_bind);
        
        IF v_property IS NOT NULL THEN
            v_property.pin(p_pin_tree);
        END IF;
    
    END;
    
    MEMBER PROCEDURE pin (
        self IN t_json,
        p_index IN NUMBER,
        p_pin_tree IN BOOLEAN := FALSE
    ) IS
    BEGIN
        pin(':i', p_pin_tree, bind(p_index));
    END;
    
    MEMBER PROCEDURE unpin (
        self IN t_json,
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    ) IS
    BEGIN
        unpin(p_path, FALSE, p_bind);
    END;
    
    MEMBER PROCEDURE unpin (
        self IN t_json,
        p_path IN VARCHAR2,
        p_unpin_tree IN BOOLEAN,
        p_bind IN bind := NULL
    ) IS
        v_property t_json;
    BEGIN
        
        v_property := get(p_path, p_bind);
        
        IF v_property IS NOT NULL THEN
            v_property.unpin(p_unpin_tree);
        END IF;
    
    END;
    
    MEMBER PROCEDURE unpin (
        self IN t_json,
        p_index IN NUMBER,
        p_unpin_tree IN BOOLEAN := FALSE
    ) IS
    BEGIN
        unpin(':i', p_unpin_tree, bind(p_index));
    END;
    
    -- Value comparison 
    
    MEMBER FUNCTION compare_to (
        p_value IN t_json
    )
    RETURN t_json_mismatches IS
    
        v_path t_varchars;
        v_mismatches t_json_mismatches;
        
        PROCEDURE add_mismatch (
            p_code IN VARCHAR2
        ) IS
        BEGIN
            v_mismatches.EXTEND(1);
            v_mismatches(v_mismatches.COUNT) := t_json_mismatch(v_path, p_code);
        END;
        
        PROCEDURE push_name (
            p_name IN VARCHAR2
        ) IS
        BEGIN
            v_path.EXTEND(1);
            v_path(v_path.COUNT) := p_name;
        END;
        
        PROCEDURE pop_name IS
        BEGIN
            v_path.TRIM(1);
        END;
        
        PROCEDURE visit_value (
            p_left IN t_json,
            p_right IN t_json
        ) IS
        
            v_left_type CHAR;
            v_left_value VARCHAR2(4000);
            
            v_right_type CHAR;
            v_right_value VARCHAR2(4000);
            
            v_parent_id NUMBER;
            v_name VARCHAR2(4000);
            
            v_left_keys t_varchars;
            v_right_keys t_varchars;
            
            v_left_i PLS_INTEGER;
            v_right_i PLS_INTEGER;
            
            v_left_key VARCHAR2(4000);
            v_right_key VARCHAR2(4000);
            
            v_compare PLS_INTEGER;
            
            PROCEDURE missing_left IS
            BEGIN
            
                push_name(v_right_key);
                add_mismatch('ML');
                pop_name;
                        
                v_right_i := v_right_i + 1;
                
            END;
            
            PROCEDURE missing_right IS
            BEGIN
            
                push_name(v_left_key);
                add_mismatch('MR');
                pop_name;
                        
                v_left_i := v_left_i + 1;
            
            END;
            
            PROCEDURE compare_keys IS
            BEGIN
            
                IF v_left_key = v_right_key THEN
                    v_compare := 0;
                ELSIF v_left_type = 'A' THEN
                    IF LPAD(v_left_key, 12, '0') > LPAD(v_right_key, 12, '0') THEN
                        v_compare := 1;
                    ELSE
                        v_compare := -1;
                    END IF;
                ELSE
                    IF v_left_key > v_right_key THEN
                        v_compare := 1;
                    ELSE
                        v_compare := -1;
                    END IF;
                END IF;
            
            END;
            
        BEGIN
        
            p_left.dump(v_parent_id, v_left_type, v_name, v_left_value);
            p_right.dump(v_parent_id, v_right_type, v_name, v_right_value);
        
            IF v_left_type != v_right_type THEN
            
                add_mismatch('TM');
                
            ELSIF v_left_type IN ('S', 'N', 'B') THEN
            
                IF v_left_value != v_right_value THEN
                    add_mismatch('VM');
                END IF;
                
            ELSIF v_left_type != 'E' THEN
            
                v_left_keys := p_left.get_keys; 
                v_right_keys := p_right.get_keys;
                
                v_left_i := 1;
                v_right_i := 1;
                
                WHILE v_left_i <= v_left_keys.COUNT 
                      OR v_right_i <= v_right_keys.COUNT 
                LOOP
                
                    IF v_left_i > v_left_keys.COUNT THEN
                    
                        v_right_key := v_right_keys(v_right_i);
                        missing_left;
                        
                    ELSIF v_right_i > v_right_keys.COUNT THEN
                        
                        v_left_key := v_left_keys(v_left_i);
                        missing_right;
                            
                    ELSE
                    
                        v_left_key := v_left_keys(v_left_i);
                        v_right_key := v_right_keys(v_right_i);
                        compare_keys;
                        
                        IF v_compare = -1 THEN
                        
                            missing_right;
                            
                        ELSIF v_compare = 1 THEN
                        
                            missing_left;
                        
                        ELSE
                        
                            push_name(v_left_key);
                            
                            visit_value(
                                p_left.get(':name', bind(v_left_key)), 
                                p_right.get(':name', bind(v_right_key))
                            );
                            
                            pop_name;
                            
                            v_left_i := v_left_i + 1;
                            v_right_i := v_right_i + 1;
                        
                        END IF;    
                        
                    END IF;
                
                END LOOP;
                
            END IF;
            
        END;
        
    BEGIN
    
        IF p_value IS NULL THEN
            -- Right value not specified!
            error$.raise('JDC-00051');
        END IF;
    
        v_path := t_varchars();
        v_mismatches := t_json_mismatches();
        
        visit_value(self, p_value);
    
        RETURN v_mismatches;
    
    END;
    
END;
