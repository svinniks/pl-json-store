CREATE OR REPLACE PACKAGE json_store IS

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

    /* Anonymous value creation API */

    FUNCTION create_json (
        -- @json
        p_content IN VARCHAR2
    ) 
    RETURN NUMBER;
    
    FUNCTION create_json (
        -- @json
        p_content IN CLOB
    ) 
    RETURN NUMBER;
    
    FUNCTION create_string (
        p_value IN VARCHAR2
    ) 
    RETURN NUMBER;
    
    FUNCTION create_date (
        p_value IN DATE
    ) 
    RETURN NUMBER;
    
    FUNCTION create_number (
        p_value IN NUMBER
    ) 
    RETURN NUMBER;
    
    FUNCTION create_boolean (
        p_value IN BOOLEAN
    ) 
    RETURN NUMBER;
    
    FUNCTION create_null
    RETURN NUMBER;

    FUNCTION create_object
    RETURN NUMBER;
    
    FUNCTION create_array
    RETURN NUMBER;
    
    FUNCTION create_copy (
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    )
    RETURN NUMBER;
    
    /* Named property modification API */
    
    FUNCTION set_string (
        p_path IN VARCHAR2,
        p_value IN VARCHAR2,
        p_bind IN bind := NULL
    ) 
    RETURN NUMBER;
    
    PROCEDURE set_string (
        p_path IN VARCHAR2,
        p_value IN VARCHAR2,
        p_bind IN bind := NULL
    );
    
    FUNCTION set_date (
        p_path IN VARCHAR2,
        p_value IN DATE,
        p_bind IN bind := NULL
    ) 
    RETURN NUMBER;
    
    PROCEDURE set_date (
        p_path IN VARCHAR2,
        p_value IN DATE,
        p_bind IN bind := NULL
    );
    
    FUNCTION set_number (
        p_path IN VARCHAR2,
        p_value IN NUMBER,
        p_bind IN bind := NULL
    ) 
    RETURN NUMBER;
    
    PROCEDURE set_number (
        p_path IN VARCHAR2,
        p_value IN NUMBER,
        p_bind IN bind := NULL
    );
    
    FUNCTION set_boolean (
        p_path IN VARCHAR2,
        p_value IN BOOLEAN,
        p_bind IN bind := NULL
    ) 
    RETURN NUMBER;
    
    PROCEDURE set_boolean (
        p_path IN VARCHAR2,
        p_value IN BOOLEAN,
        p_bind IN bind := NULL
    );
    
    FUNCTION set_null (
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    ) 
    RETURN NUMBER;
    
    PROCEDURE set_null (
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    );
    
    FUNCTION set_object (
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    ) 
    RETURN NUMBER;
    
    PROCEDURE set_object (
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    );
    
    FUNCTION set_array (
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    ) 
    RETURN NUMBER;
    
    PROCEDURE set_array (
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    );
    
    FUNCTION set_json (
        p_path IN VARCHAR2,
        -- @json
        p_content IN VARCHAR2,
        p_bind IN bind := NULL
    ) 
    RETURN NUMBER;
    
    PROCEDURE set_json (
        p_path IN VARCHAR2,
        -- @json
        p_content IN VARCHAR2,
        p_bind IN bind := NULL
    );
    
    FUNCTION set_json (
        p_path IN VARCHAR2,
        -- @json
        p_content IN CLOB,
        p_bind IN bind := NULL
    )
    RETURN NUMBER;
    
    PROCEDURE set_json (
        p_path IN VARCHAR2,
        -- @json
        p_content IN CLOB,
        p_bind IN bind := NULL
    );
    
    FUNCTION set_copy (
        p_path IN VARCHAR2,
        p_source_path IN VARCHAR2,
        p_source_bind IN bind := NULL
    )
    RETURN NUMBER;
    
    FUNCTION set_copy (
        p_path IN VARCHAR2,
        p_bind IN bind,
        p_source_path IN VARCHAR2,
        p_source_bind IN bind := NULL
    )
    RETURN NUMBER;
    
    PROCEDURE set_copy (
        p_path IN VARCHAR2,
        p_source_path IN VARCHAR2,
        p_source_bind IN bind := NULL
    );
    
    PROCEDURE set_copy (
        p_path IN VARCHAR2,
        p_bind IN bind,
        p_source_path IN VARCHAR2,
        p_source_bind IN bind := NULL
    );

    FUNCTION get_string (
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    ) 
    RETURN VARCHAR2;
    
    FUNCTION get_date (
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    ) 
    RETURN DATE;
    
    FUNCTION get_number (
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    ) 
    RETURN NUMBER;
    
    FUNCTION get_boolean (
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    ) 
    RETURN BOOLEAN;

    FUNCTION get_json (
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    ) 
    -- @json
    RETURN VARCHAR2;
    
    FUNCTION get_json (
        p_path IN VARCHAR2,
        p_serialize_nulls IN json_core.BOOLEANN,
        p_bind IN bind := NULL
    ) 
    -- @json
    RETURN VARCHAR2;
    
    FUNCTION get_json_clob (
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    )
    -- @json
    RETURN CLOB;
    
    FUNCTION get_json_clob (
        p_path IN VARCHAR2,
        p_serialize_nulls IN json_core.BOOLEANN,
        p_bind IN bind := NULL
    )
    -- @json
    RETURN CLOB;
    
    /* Applying methods */
    
    FUNCTION apply_string (
        p_path IN VARCHAR2,
        p_value IN VARCHAR2,
        p_bind IN bind := NULL
    )
    RETURN NUMBER;
    
    PROCEDURE apply_string (
        p_path IN VARCHAR2,
        p_value IN VARCHAR2,
        p_bind IN bind := NULL
    );
    
    FUNCTION apply_date (
        p_path IN VARCHAR2,
        p_value IN DATE,
        p_bind IN bind := NULL
    )
    RETURN NUMBER;
    
    PROCEDURE apply_date (
        p_path IN VARCHAR2,
        p_value IN DATE,
        p_bind IN bind := NULL
    );
    
    FUNCTION apply_number (
        p_path IN VARCHAR2,
        p_value IN NUMBER,
        p_bind IN bind := NULL
    )
    RETURN NUMBER;
    
    PROCEDURE apply_number (
        p_path IN VARCHAR2,
        p_value IN NUMBER,
        p_bind IN bind := NULL
    );
    
    FUNCTION apply_boolean (
        p_path IN VARCHAR2,
        p_value IN BOOLEAN,
        p_bind IN bind := NULL
    )
    RETURN NUMBER;
    
    PROCEDURE apply_boolean (
        p_path IN VARCHAR2,
        p_value IN BOOLEAN,
        p_bind IN bind := NULL
    );
    
    FUNCTION apply_json (
        p_path IN VARCHAR2,
        -- @json
        p_content IN VARCHAR2,
        p_bind IN bind := NULL
    )
    RETURN NUMBER;
    
    PROCEDURE apply_json (
        p_path IN VARCHAR2,
        -- @json
        p_content IN VARCHAR2,
        p_bind IN bind := NULL
    );
    
    FUNCTION apply_json (
        p_path IN VARCHAR2,
        -- @json
        p_content IN VARCHAR2,
        p_check_types IN BOOLEAN,
        p_bind IN bind := NULL
    )
    RETURN NUMBER;
    
    PROCEDURE apply_json (
        p_path IN VARCHAR2,
        -- @json
        p_content IN VARCHAR2,
        p_check_types IN BOOLEAN,
        p_bind IN bind := NULL
    );
    
    FUNCTION apply_json (
        p_path IN VARCHAR2,
        -- @json
        p_content IN CLOB,
        p_bind IN bind := NULL
    )
    RETURN NUMBER;
    
    PROCEDURE apply_json (
        p_path IN VARCHAR2,
        -- @json
        p_content IN CLOB,
        p_bind IN bind := NULL
    );
    
    FUNCTION apply_json (
        p_path IN VARCHAR2,
        -- @json
        p_content IN CLOB,
        p_check_types IN BOOLEAN,
        p_bind IN bind := NULL
    )
    RETURN NUMBER;
    
    PROCEDURE apply_json (
        p_path IN VARCHAR2,
        -- @json
        p_content IN CLOB,
        p_check_types IN BOOLEAN,
        p_bind IN bind := NULL
    );
    
    /*
    
    FUNCTION apply_json (
        p_path IN VARCHAR2,
        p_builder IN t_json_builder,
        p_bind IN bind := NULL
    )
    RETURN NUMBER;
    
    PROCEDURE apply_json (
        p_path IN VARCHAR2,
        p_builder IN t_json_builder,
        p_bind IN bind := NULL
    );
    
    FUNCTION apply_json (
        p_path IN VARCHAR2,
        p_builder IN t_json_builder,
        p_check_types IN BOOLEAN,
        p_bind IN bind := NULL
    )
    RETURN NUMBER;
    
    PROCEDURE apply_json (
        p_path IN VARCHAR2,
        p_builder IN t_json_builder,
        p_check_types IN BOOLEAN,
        p_bind IN bind := NULL
    );
   
    */
 
    FUNCTION get_keys (
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    )
    RETURN t_varchars;
        
    FUNCTION get_length (
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    )
    RETURN NUMBER;
    
    FUNCTION index_of (
        p_path IN VARCHAR2,
        p_value IN VARCHAR2,
        p_bind IN bind := NULL
    )
    RETURN NUMBER;
    
    FUNCTION index_of (
        p_path IN VARCHAR2,
        p_value IN VARCHAR2,
        p_from_index IN NUMBER,
        p_bind IN bind := NULL
    )
    RETURN NUMBER;
    
    FUNCTION index_of (
        p_path IN VARCHAR2,
        p_value IN DATE,
        p_bind IN bind := NULL
    )
    RETURN NUMBER;
    
    FUNCTION index_of (
        p_path IN VARCHAR2,
        p_value IN DATE,
        p_from_index IN NUMBER,
        p_bind IN bind := NULL
    )
    RETURN NUMBER;
    
    FUNCTION index_of (
        p_path IN VARCHAR2,
        p_value IN NUMBER,
        p_bind IN bind := NULL
    )
    RETURN NUMBER;
    
    FUNCTION index_of (
        p_path IN VARCHAR2,
        p_value IN NUMBER,
        p_from_index IN NUMBER,
        p_bind IN bind := NULL
    )
    RETURN NUMBER;
    
    FUNCTION index_of (
        p_path IN VARCHAR2,
        p_value IN BOOLEAN,
        p_from_index IN NUMBER,
        p_bind IN bind := NULL
    )
    RETURN NUMBER;
    
    FUNCTION index_of_null (
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    )
    RETURN NUMBER;
    
    FUNCTION index_of_null (
        p_path IN VARCHAR2,
        p_from_index IN NUMBER,
        p_bind IN bind := NULL
    )
    RETURN NUMBER;
    
    FUNCTION push_string (
        p_path IN VARCHAR2,
        p_value IN VARCHAR2,
        p_bind IN bind := NULL
    )
    RETURN NUMBER;
    
    PROCEDURE push_string (
        p_path IN VARCHAR2,
        p_value IN VARCHAR2,
        p_bind IN bind := NULL
    );
   
    FUNCTION push_number (
        p_path IN VARCHAR2,
        p_value IN NUMBER,
        p_bind IN bind := NULL
    )
    RETURN NUMBER;
    
    PROCEDURE push_number (
        p_path IN VARCHAR2,
        p_value IN NUMBER,
        p_bind IN bind := NULL
    );
    
    FUNCTION push_boolean (
        p_path IN VARCHAR2,
        p_value IN BOOLEAN,
        p_bind IN bind := NULL
    ) 
    RETURN NUMBER;
    
    PROCEDURE push_boolean (
        p_path IN VARCHAR2,
        p_value IN BOOLEAN,
        p_bind IN bind := NULL
    );
    
    FUNCTION push_null (
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    )
    RETURN NUMBER;
        
    PROCEDURE push_null (
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    );
        
    FUNCTION push_object (
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    )
    RETURN NUMBER;
        
    PROCEDURE push_object (
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    );
        
    FUNCTION push_array (
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    )
    RETURN NUMBER;
        
    PROCEDURE push_array (
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    );
        
    FUNCTION push_json (
        p_path IN VARCHAR2,
        -- @json
        p_content IN VARCHAR2,
        p_bind IN bind := NULL
    )
    RETURN NUMBER;
        
    PROCEDURE push_json (
        p_path IN VARCHAR2,
        -- @json
        p_content IN VARCHAR2,
        p_bind IN bind := NULL
    );
        
    FUNCTION push_json (
        p_path IN VARCHAR2,
        -- @json
        p_content IN CLOB,
        p_bind IN bind := NULL
    )
    RETURN NUMBER;
        
    PROCEDURE push_json (
        p_path IN VARCHAR2,
        -- @json
        p_content IN CLOB,
        p_bind IN bind := NULL
    );
         
    PROCEDURE delete_value (
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    );
    
    /* Value pinning */
    
    PROCEDURE pin (
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    );
    
    PROCEDURE pin (
        p_path IN VARCHAR2,
        p_pin_tree IN BOOLEAN,
        p_bind IN bind := NULL
    );
    
    PROCEDURE unpin (
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    );
    
    PROCEDURE unpin (
        p_path IN VARCHAR2,
        p_unpin_tree IN BOOLEAN,
        p_bind IN bind := NULL
    );
    
END;
