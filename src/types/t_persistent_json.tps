CREATE OR REPLACE TYPE t_persistent_json UNDER t_json (

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
    RETURN t_json,
    
    STATIC FUNCTION create_number (
        p_value IN NUMBER
    )
    RETURN t_json,
    
    STATIC FUNCTION create_date (
        p_value IN DATE
    )
    RETURN t_json,
    
    STATIC FUNCTION create_boolean (
        p_value IN BOOLEAN
    )
    RETURN t_json,
    
    STATIC FUNCTION create_null
    RETURN t_json,
    
    STATIC FUNCTION create_object
    RETURN t_json,
    
    STATIC FUNCTION create_array
    RETURN t_json,
    
    STATIC FUNCTION create_json (
        p_value IN t_json
    )
    RETURN t_json,
    
    STATIC FUNCTION create_json (
        p_content VARCHAR2
    )
    RETURN t_json, 
    
    STATIC FUNCTION create_json (
        p_content CLOB
    )
    RETURN t_json,
    
    STATIC FUNCTION create_json (
        p_builder t_json_builder
    )
    RETURN t_json,

    CONSTRUCTOR FUNCTION t_persistent_json (
        id NUMBER
    )
    RETURN self AS RESULT,

    CONSTRUCTOR FUNCTION t_persistent_json (
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    )
    RETURN self AS RESULT,

    OVERRIDING MEMBER PROCEDURE dump (
        self IN t_persistent_json,
        p_parent_id OUT NUMBER,
        p_type OUT CHAR,
        p_value OUT VARCHAR2
    ),
    
    OVERRIDING MEMBER FUNCTION get_parse_events (
        p_serialize_nulls IN BOOLEAN
    )
    RETURN t_varchars,
    
    OVERRIDING MEMBER FUNCTION get_parent
    RETURN t_json,
    
    OVERRIDING MEMBER FUNCTION get (
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    )
    RETURN t_json,
    
    OVERRIDING MEMBER FUNCTION get_keys
    RETURN t_varchars,
    
    OVERRIDING MEMBER FUNCTION get_length
    RETURN NUMBER,
    
    OVERRIDING MEMBER FUNCTION index_of (
        p_type IN CHAR 
       ,p_value IN VARCHAR2
       ,p_from_index IN NATURALN
    )
    RETURN NUMBER,
    
    OVERRIDING MEMBER FUNCTION set_json (
        p_path IN VARCHAR2,
        p_content_parse_events IN t_varchars,
        p_bind IN bind
    ) 
    RETURN t_json,
    
    OVERRIDING MEMBER PROCEDURE remove,
    
    OVERRIDING MEMBER PROCEDURE pin (
        self IN t_persistent_json,
        p_pin_tree IN BOOLEAN := FALSE
    ),
    
    OVERRIDING MEMBER PROCEDURE unpin (
        self IN t_persistent_json,
        p_unpin_tree IN BOOLEAN := FALSE
    ),
    
    -- JSON filter instantiation method 
    
    MEMBER FUNCTION filter
    RETURN t_json_filter 

)