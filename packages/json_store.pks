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

    TYPE t_5_value_row IS 
        RECORD (
            value_1 VARCHAR2(4000),
            value_2 VARCHAR2(4000),
            value_3 VARCHAR2(4000),
            value_4 VARCHAR2(4000),
            value_5 VARCHAR2(4000)
        );
    
    TYPE t_5_value_table IS 
        TABLE OF t_5_value_row;
    
    TYPE t_10_value_row IS 
        RECORD (
            value_1 VARCHAR2(4000),
            value_2 VARCHAR2(4000),
            value_3 VARCHAR2(4000),
            value_4 VARCHAR2(4000),
            value_5 VARCHAR2(4000),
            value_6 VARCHAR2(4000),
            value_7 VARCHAR2(4000),
            value_8 VARCHAR2(4000),
            value_9 VARCHAR2(4000),
            value_10 VARCHAR2(4000)
        );
    
    TYPE t_10_value_table IS 
        TABLE OF t_10_value_row;
    
    TYPE t_15_value_row IS 
        RECORD (
            value_1 VARCHAR2(4000),
            value_2 VARCHAR2(4000),
            value_3 VARCHAR2(4000),
            value_4 VARCHAR2(4000),
            value_5 VARCHAR2(4000),
            value_6 VARCHAR2(4000),
            value_7 VARCHAR2(4000),
            value_8 VARCHAR2(4000),
            value_9 VARCHAR2(4000),
            value_10 VARCHAR2(4000),
            value_11 VARCHAR2(4000),
            value_12 VARCHAR2(4000),
            value_13 VARCHAR2(4000),
            value_14 VARCHAR2(4000),
            value_15 VARCHAR2(4000)
        );
    
    TYPE t_15_value_table IS 
        TABLE OF t_15_value_row;
    
    TYPE t_20_value_row IS 
        RECORD (
            value_1 VARCHAR2(4000),
            value_2 VARCHAR2(4000),
            value_3 VARCHAR2(4000),
            value_4 VARCHAR2(4000),
            value_5 VARCHAR2(4000),
            value_6 VARCHAR2(4000),
            value_7 VARCHAR2(4000),
            value_8 VARCHAR2(4000),
            value_9 VARCHAR2(4000),
            value_10 VARCHAR2(4000),
            value_11 VARCHAR2(4000),
            value_12 VARCHAR2(4000),
            value_13 VARCHAR2(4000),
            value_14 VARCHAR2(4000),
            value_15 VARCHAR2(4000),
            value_16 VARCHAR2(4000),
            value_17 VARCHAR2(4000),
            value_18 VARCHAR2(4000),
            value_19 VARCHAR2(4000),
            value_20 VARCHAR2(4000)
        );
    
    TYPE t_20_value_table IS 
        TABLE OF t_20_value_row;

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
    
    FUNCTION get_json_clob (
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    )
    -- @json
    RETURN CLOB;
    
    PROCEDURE apply_json (
        p_path IN VARCHAR2,
        -- @json
        p_content IN VARCHAR2,
        p_bind IN bind := NULL,
        p_check_types IN BOOLEAN := FALSE
    );
        
    PROCEDURE apply_json_clob (
        p_path IN VARCHAR2,
        -- @json
        p_content IN CLOB,
        p_bind IN bind := NULL,
        p_check_types IN BOOLEAN := FALSE
    );    
    
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
    
    PROCEDURE lock_value (
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    );
    
    PROCEDURE unlock_value (
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    );

    FUNCTION get_5_value_table (
        p_query IN VARCHAR2,
        p_bind IN bind := NULL
    )
    RETURN t_5_value_table PIPELINED;
    
    FUNCTION get_10_value_table (
        p_query IN VARCHAR2,
        p_bind IN bind := NULL
    )
    RETURN t_10_value_table PIPELINED;
    
    FUNCTION get_15_value_table (
        p_query IN VARCHAR2,
        p_bind IN bind := NULL
    )
    RETURN t_15_value_table PIPELINED;
    
    FUNCTION get_20_value_table (
        p_query IN VARCHAR2,
        p_bind IN bind := NULL
    )
    RETURN t_20_value_table PIPELINED;
    
    FUNCTION get_value_table (
        p_query IN VARCHAR2,
        p_bind IN bind := NULL
    )
    RETURN ANYDATASET PIPELINED 
    USING t_value_table_query;
    
    FUNCTION get_value_table_cursor (
        p_query IN VARCHAR2,
        p_bind IN bind := NULL
    )
    RETURN SYS_REFCURSOR;
    
END;
