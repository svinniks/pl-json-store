CREATE OR REPLACE TYPE t_json IS OBJECT (

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

    id NUMBER,
    
    /* Core abstract methods */
    
    NOT INSTANTIABLE MEMBER PROCEDURE dump (
        self IN t_json,
        p_parent_id OUT NUMBER,
        p_type OUT CHAR,
        p_value OUT VARCHAR2
    ),
    
    NOT INSTANTIABLE MEMBER FUNCTION get_parse_events (
        p_serialize_nulls IN BOOLEAN
    )
    RETURN t_varchars,
    
    NOT INSTANTIABLE MEMBER FUNCTION get_parent
    RETURN t_json,
    
    NOT INSTANTIABLE MEMBER FUNCTION get (
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    )
    RETURN t_json,
    
    NOT INSTANTIABLE MEMBER FUNCTION get_keys
    RETURN t_varchars,
    
    NOT INSTANTIABLE MEMBER FUNCTION get_length
    RETURN NUMBER,
    
    NOT INSTANTIABLE MEMBER FUNCTION index_of (
        p_type IN CHAR 
       ,p_value IN VARCHAR2
       ,p_from_index IN NATURALN
    )
    RETURN NUMBER,
    
    NOT INSTANTIABLE MEMBER FUNCTION set_json (
        p_path IN VARCHAR2,
        p_content_parse_events IN t_varchars,
        p_bind IN bind
    ) 
    RETURN t_json,
    
    NOT INSTANTIABLE MEMBER PROCEDURE remove,
    
    NOT INSTANTIABLE MEMBER PROCEDURE pin (
        self IN t_json,
        p_pin_tree IN BOOLEAN := FALSE
    ),
    
    NOT INSTANTIABLE MEMBER PROCEDURE unpin (
        self IN t_json,
        p_unpin_tree IN BOOLEAN := FALSE
    ),
    
    /* Implemented methods */
    
    -- Value type check methods
    
    MEMBER FUNCTION is_string
    RETURN BOOLEAN,
    
    MEMBER FUNCTION is_number
    RETURN BOOLEAN,
    
    MEMBER FUNCTION is_date
    RETURN BOOLEAN,
    
    MEMBER FUNCTION is_boolean
    RETURN BOOLEAN,
    
    MEMBER FUNCTION is_null
    RETURN BOOLEAN,
    
    MEMBER FUNCTION is_object
    RETURN BOOLEAN,
    
    MEMBER FUNCTION is_array
    RETURN BOOLEAN,
    
    -- Self serialization methods
    
    MEMBER FUNCTION as_string
    RETURN VARCHAR2,
    
    MEMBER FUNCTION as_number
    RETURN NUMBER,
    
    MEMBER FUNCTION as_date
    RETURN DATE,
    
    MEMBER FUNCTION as_boolean
    RETURN BOOLEAN,
    
    MEMBER FUNCTION as_json (
        p_serialize_nulls IN BOOLEAN := TRUE
    )
    RETURN VARCHAR2,
    
    MEMBER FUNCTION as_json_clob (
        p_serialize_nulls IN BOOLEAN := TRUE
    )
    RETURN CLOB,
    
    -- Special object methods
    
    MEMBER FUNCTION contains (
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    )
    RETURN BOOLEAN,
    
    MEMBER FUNCTION has (
        p_key IN VARCHAR2
    )
    RETURN BOOLEAN,
    
    -- Special array methods
    
    MEMBER FUNCTION index_of (
        p_value IN VARCHAR2
       ,p_from_index IN NATURALN := 0
    )
    RETURN NUMBER,
    
    MEMBER FUNCTION index_of (
        p_value IN DATE
       ,p_from_index IN NATURALN := 0
    )
    RETURN NUMBER,
    
    MEMBER FUNCTION index_of (
        p_value IN NUMBER
       ,p_from_index IN NATURALN := 0
    )
    RETURN NUMBER,
    
    MEMBER FUNCTION index_of (
        p_value IN BOOLEAN
       ,p_from_index IN NATURALN := 0
    )
    RETURN NUMBER,
    
    MEMBER FUNCTION index_of_null (
        p_from_index IN NATURALN := 0
    )
    RETURN NUMBER,
    
    -- Child element retrieval methods
    
    MEMBER FUNCTION get (
        p_index IN NUMBER
    )
    RETURN t_json,
    
    MEMBER FUNCTION get_string (
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    )
    RETURN VARCHAR2,
    
    MEMBER FUNCTION get_string (
        p_index IN NUMBER
    )
    RETURN VARCHAR2,
    
    MEMBER FUNCTION get_date (
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    )
    RETURN DATE,
    
    MEMBER FUNCTION get_date (
        p_index IN NUMBER
    )
    RETURN DATE,
    
    MEMBER FUNCTION get_number (
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    )
    RETURN NUMBER,
    
    MEMBER FUNCTION get_number (
        p_index IN NUMBER
    )
    RETURN NUMBER,
    
    MEMBER FUNCTION get_boolean (
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    )
    RETURN BOOLEAN,
    
    MEMBER FUNCTION get_boolean (
        p_index IN NUMBER
    )
    RETURN BOOLEAN,
    
    MEMBER FUNCTION get_json (
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    )
    RETURN VARCHAR2,
    
    MEMBER FUNCTION get_json (
        p_path IN VARCHAR2,
        p_serialize_nulls IN BOOLEAN,
        p_bind IN bind := NULL
    )
    RETURN VARCHAR2,
    
    MEMBER FUNCTION get_json (
        p_index IN NUMBER,
        p_serialize_nulls IN BOOLEAN := TRUE
    )
    RETURN VARCHAR2,
    
    MEMBER FUNCTION get_json_clob (
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    )
    RETURN CLOB,
    
    MEMBER FUNCTION get_json_clob (
        p_path IN VARCHAR2,
        p_serialize_nulls IN BOOLEAN,
        p_bind IN bind := NULL
    )
    RETURN CLOB,
    
    MEMBER FUNCTION get_json_clob (
        p_index IN NUMBER,
        p_serialize_nulls IN BOOLEAN := TRUE
    )
    RETURN CLOB,
    
    -- Property modification methods
    
    MEMBER FUNCTION set_string (
        p_path IN VARCHAR2,
        p_value IN VARCHAR2,
        p_bind IN bind := NULL
    ) 
    RETURN t_json,
    
    MEMBER PROCEDURE set_string (
        self IN t_json,
        p_path IN VARCHAR2,
        p_value IN VARCHAR2,
        p_bind IN bind := NULL
    ),
    
    MEMBER FUNCTION set_string (
        p_index IN NUMBER,
        p_value IN VARCHAR2
    ) 
    RETURN t_json,
    
    MEMBER PROCEDURE set_string (
        self IN t_json,
        p_index IN NUMBER,
        p_value IN VARCHAR2
    ),
    
    MEMBER FUNCTION set_date (
        p_path IN VARCHAR2,
        p_value IN DATE,
        p_bind IN bind := NULL
    ) 
    RETURN t_json,
    
    MEMBER PROCEDURE set_date (
        self IN t_json,
        p_path IN VARCHAR2,
        p_value IN DATE,
        p_bind IN bind := NULL
    ),
    
    MEMBER FUNCTION set_date (
        p_index IN NUMBER,
        p_value IN DATE
    ) 
    RETURN t_json,
    
    MEMBER PROCEDURE set_date (
        self IN t_json,
        p_index IN NUMBER,
        p_value IN DATE
    ),
    
    MEMBER FUNCTION set_number (
        p_path IN VARCHAR2,
        p_value IN NUMBER,
        p_bind IN bind := NULL
    ) 
    RETURN t_json,
    
    MEMBER PROCEDURE set_number (
        self IN t_json,
        p_path IN VARCHAR2,
        p_value IN NUMBER,
        p_bind IN bind := NULL
    ),
    
    MEMBER FUNCTION set_number (
        p_index IN NUMBER,
        p_value IN NUMBER
    ) 
    RETURN t_json,
    
    MEMBER PROCEDURE set_number (
        self IN t_json,
        p_index IN NUMBER,
        p_value IN NUMBER
    ),
    
    MEMBER FUNCTION set_boolean (
        p_path IN VARCHAR2,
        p_value IN BOOLEAN,
        p_bind IN bind := NULL
    ) 
    RETURN t_json,
    
    MEMBER PROCEDURE set_boolean (
        self IN t_json,
        p_path IN VARCHAR2,
        p_value IN BOOLEAN,
        p_bind IN bind := NULL
    ),
    
    MEMBER FUNCTION set_boolean (
        p_index IN NUMBER,
        p_value IN BOOLEAN
    ) 
    RETURN t_json,
    
    MEMBER PROCEDURE set_boolean (
        self IN t_json,
        p_index IN NUMBER,
        p_value IN BOOLEAN
    ),
    
    MEMBER FUNCTION set_null (
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    ) 
    RETURN t_json,
    
    MEMBER PROCEDURE set_null (
        self IN t_json,
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    ),
    
    MEMBER FUNCTION set_null (
        p_index IN NUMBER
    ) 
    RETURN t_json,
    
    MEMBER PROCEDURE set_null (
        self IN t_json,
        p_index IN NUMBER
    ),
    
    MEMBER FUNCTION set_object (
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    ) 
    RETURN t_json,
    
    MEMBER PROCEDURE set_object (
        self IN t_json,
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    ),
    
    MEMBER FUNCTION set_object (
        p_index IN NUMBER
    ) 
    RETURN t_json,
    
    MEMBER PROCEDURE set_object (
        self IN t_json,
        p_index IN NUMBER
    ),
    
    MEMBER FUNCTION set_array (
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    ) 
    RETURN t_json,
    
    MEMBER PROCEDURE set_array (
        self IN t_json,
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    ),
    
    MEMBER FUNCTION set_array (
        p_index IN NUMBER
    ) 
    RETURN t_json,
    
    MEMBER PROCEDURE set_array (
        self IN t_json,
        p_index IN NUMBER
    ),
    
    MEMBER FUNCTION set_json (
        p_path IN VARCHAR2,
        p_content IN VARCHAR2,
        p_bind IN bind := NULL
    ) 
    RETURN t_json,
    
    MEMBER PROCEDURE set_json (
        self IN t_json,
        p_path IN VARCHAR2,
        p_content IN VARCHAR2,
        p_bind IN bind := NULL
    ),
    
    MEMBER FUNCTION set_json (
        p_index IN NUMBER,
        p_content IN VARCHAR2
    ) 
    RETURN t_json,
    
    MEMBER PROCEDURE set_json (
        self IN t_json,
        p_index IN NUMBER,
        p_content IN VARCHAR2
    ),
    
    MEMBER FUNCTION set_json (
        p_path IN VARCHAR2,
        p_content IN CLOB,
        p_bind IN bind := NULL
    ) 
    RETURN t_json,
    
    MEMBER PROCEDURE set_json (
        self IN t_json,
        p_path IN VARCHAR2,
        p_content IN CLOB,
        p_bind IN bind := NULL
    ),
    
    MEMBER FUNCTION set_json (
        p_index IN NUMBER,
        p_content IN CLOB
    ) 
    RETURN t_json,
    
    MEMBER PROCEDURE set_json (
        self IN t_json,
        p_index IN NUMBER,
        p_content IN CLOB
    ),
    
    MEMBER FUNCTION set_json (
        p_path IN VARCHAR2,
        p_builder IN t_json_builder,
        p_bind IN bind := NULL
    ) 
    RETURN t_json,
    
    MEMBER PROCEDURE set_json (
        self IN t_json,
        p_path IN VARCHAR2,
        p_builder IN t_json_builder,
        p_bind IN bind := NULL
    ),
    
    MEMBER FUNCTION set_json (
        p_index IN NUMBER,
        p_builder IN t_json_builder
    ) 
    RETURN t_json,
    
    MEMBER PROCEDURE set_json (
        self IN t_json,
        p_index IN NUMBER,
        p_builder IN t_json_builder
    ),
    
    MEMBER FUNCTION set_json (
        p_path IN VARCHAR2,
        p_value IN t_json,
        p_bind IN bind := NULL
    ) 
    RETURN t_json,
    
    MEMBER PROCEDURE set_json (
        self IN t_json,
        p_path IN VARCHAR2,
        p_value IN t_json,
        p_bind IN bind := NULL
    ),
    
    MEMBER FUNCTION set_json (
        p_index IN NUMBER,
        p_value IN t_json
    ) 
    RETURN t_json,
    
    MEMBER PROCEDURE set_json (
        self IN t_json,
        p_index IN NUMBER,
        p_value IN t_json
    ),
    
    -- Array push methods
    
    MEMBER FUNCTION push_string (
        p_value IN VARCHAR2
    ) 
    RETURN t_json,
    
    MEMBER PROCEDURE push_string (
        self IN t_json,
        p_value IN VARCHAR2
    ),
    
    MEMBER FUNCTION push_number (
        p_value IN NUMBER
    ) 
    RETURN t_json,
    
    MEMBER PROCEDURE push_number (
        self IN t_json,
        p_value IN NUMBER
    ),
    
    MEMBER FUNCTION push_date (
        p_value IN DATE
    ) 
    RETURN t_json,
    
    MEMBER PROCEDURE push_date (
        self IN t_json,
        p_value IN DATE
    ),
    
    MEMBER FUNCTION push_boolean (
        p_value IN BOOLEAN
    ) 
    RETURN t_json,
    
    MEMBER PROCEDURE push_boolean (
        self IN t_json,
        p_value IN BOOLEAN
    ),
    
    MEMBER FUNCTION push_null
    RETURN t_json,
    
    MEMBER PROCEDURE push_null (
        self IN t_json
    ),
    
    MEMBER FUNCTION push_object
    RETURN t_json,
    
    MEMBER PROCEDURE push_object (
        self IN t_json
    ),
    
    MEMBER FUNCTION push_array
    RETURN t_json,
    
    MEMBER PROCEDURE push_array (
        self IN t_json
    ),
    
    MEMBER FUNCTION push_json (
        p_content IN VARCHAR2
    )
    RETURN t_json,
    
    MEMBER PROCEDURE push_json (
        self IN t_json,
        p_content IN VARCHAR2
    ),
    
    MEMBER FUNCTION push_json (
        p_content IN CLOB
    )
    RETURN t_json,
    
    MEMBER PROCEDURE push_json (
        self IN t_json,
        p_content IN CLOB
    ),
    
    MEMBER FUNCTION push_json (
        p_builder IN t_json_builder
    )
    RETURN t_json,
    
    MEMBER PROCEDURE push_json (
        self IN t_json,
        p_builder IN t_json_builder
    ),
    
    MEMBER FUNCTION push_json (
        p_value IN t_json
    )
    RETURN t_json,
    
    MEMBER PROCEDURE push_json (
        self IN t_json,
        p_value IN t_json
    ),
    
    -- Value deletion methods
    
    MEMBER PROCEDURE remove (
        self IN t_json,
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    ),
    
    MEMBER PROCEDURE remove (
        self IN t_json,
        p_index IN NUMBER
    ),
    
    -- Value locking methods
    
    MEMBER PROCEDURE pin (
        self IN t_json,
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    ),
    
    MEMBER PROCEDURE pin (
        self IN t_json,
        p_path IN VARCHAR2,
        p_pin_tree IN BOOLEAN,
        p_bind IN bind := NULL
    ),
    
    MEMBER PROCEDURE pin (
        self IN t_json,
        p_index IN NUMBER,
        p_pin_tree IN BOOLEAN := FALSE
    ),
    
    MEMBER PROCEDURE unpin (
        self IN t_json,
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    ),
    
    MEMBER PROCEDURE unpin (
        self IN t_json,
        p_path IN VARCHAR2,
        p_unpin_tree IN BOOLEAN,
        p_bind IN bind := NULL
    ),
    
    MEMBER PROCEDURE unpin (
        self IN t_json,
        p_index IN NUMBER,
        p_unpin_tree IN BOOLEAN := FALSE
    )
    
)
NOT FINAL
NOT INSTANTIABLE