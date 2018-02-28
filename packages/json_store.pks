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

    /**
        Methods for maintaining the store of JSON values.
        
        The whole store is one big JSON object named $ (or "root").
       
        
    */
    
    TYPE t_query_element IS 
        RECORD (
            type CHAR,
            value VARCHAR2(4000),
            optional BOOLEAN,
            alias VARCHAR2(4000),
            first_child_i PLS_INTEGER,
            next_sibling_i PLS_INTEGER
        );
        
    TYPE t_query_elements IS 
        TABLE OF t_query_element;
    
    c_query_row_buffer_size CONSTANT PLS_INTEGER := 100;
    
    TYPE t_property IS 
        RECORD (
            parent_id NUMBER,
            parent_type CHAR,
            property_id NUMBER,
            property_type CHAR,
            property_name VARCHAR2(4000),
            property_locked CHAR
        );
       
    TYPE t_properties IS TABLE OF t_property;
    
    TYPE t_value IS 
        RECORD (
            id NUMBER,
            type CHAR,
            value VARCHAR2(4000)
        );
        
    TYPE t_values IS TABLE OF t_value;
    
    c_VALUE_QUERY CONSTANT PLS_INTEGER := 1;
    c_PROPERTY_QUERY CONSTANT PLS_INTEGER := 2;
    c_VALUE_TABLE_QUERY CONSTANT PLS_INTEGER := 3;
    c_X_VALUE_TABLE_QUERY CONSTANT PLS_INTEGER := 4;
    
    TYPE t_query_statement IS
        RECORD (
            statement VARCHAR2(32000),
            statement_clob CLOB
        );
    
    TYPE t_t_varchars IS 
        TABLE OF t_varchars;
    
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

    FUNCTION parse_query (
        p_query IN VARCHAR2,
        p_query_type IN PLS_INTEGER := c_VALUE_TABLE_QUERY
    ) 
    RETURN t_query_elements;
    
    FUNCTION get_query_signature (
        p_query_elements IN t_query_elements
    )
    RETURN VARCHAR2;
    
    FUNCTION get_query_column_names (
        p_query_elements IN t_query_elements
    )
    RETURN t_varchars;
    
    FUNCTION get_query_variable_names (
        p_query_elements IN t_query_elements
    )
    RETURN t_varchars;
    
    FUNCTION get_query_values (
        p_query_elements IN t_query_elements
    )
    RETURN t_varchars;
    
    FUNCTION get_query_statement (
        p_query_elements IN t_query_elements,
        p_query_type IN PLS_INTEGER,
        p_column_count IN PLS_INTEGER := NULL
    )
    RETURN t_query_statement;  
    
    FUNCTION prepare_query (
        p_query IN VARCHAR2,
        p_query_type IN PLS_INTEGER,
        p_variable_1 IN VARCHAR2 := NULL,
        p_variable_2 IN VARCHAR2 := NULL,
        p_variable_3 IN VARCHAR2 := NULL,
        p_variable_4 IN VARCHAR2 := NULL,
        p_variable_5 IN VARCHAR2 := NULL,
        p_variable_6 IN VARCHAR2 := NULL,
        p_variable_7 IN VARCHAR2 := NULL,
        p_variable_8 IN VARCHAR2 := NULL,
        p_variable_9 IN VARCHAR2 := NULL,
        p_variable_10 IN VARCHAR2 := NULL,
        p_variable_11 IN VARCHAR2 := NULL,
        p_variable_12 IN VARCHAR2 := NULL,
        p_variable_13 IN VARCHAR2 := NULL,
        p_variable_14 IN VARCHAR2 := NULL,
        p_variable_15 IN VARCHAR2 := NULL,
        p_variable_16 IN VARCHAR2 := NULL,
        p_variable_17 IN VARCHAR2 := NULL,
        p_variable_18 IN VARCHAR2 := NULL,
        p_variable_19 IN VARCHAR2 := NULL,
        p_variable_20 IN VARCHAR2 := NULL,
        p_column_count IN PLS_INTEGER := NULL
    )
    RETURN INTEGER;
    
    PROCEDURE request_properties (
        p_path IN VARCHAR2,
        p_properties OUT SYS_REFCURSOR
    );
        
    FUNCTION request_properties (
        p_path IN VARCHAR2
    ) 
    RETURN t_properties PIPELINED;
    
    FUNCTION create_json (
        -- @json
        p_content IN VARCHAR2
    ) 
    RETURN NUMBER;
    
    FUNCTION create_json_clob (
        -- @json
        p_content IN CLOB
    ) 
    RETURN NUMBER;
    
    FUNCTION create_string (
        p_value IN VARCHAR2
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
    
    FUNCTION set_json (
        p_path IN VARCHAR2,
        -- @json
        p_content IN VARCHAR2
    ) 
    RETURN NUMBER;
    
    PROCEDURE set_json (
        p_path IN VARCHAR2,
        -- @json
        p_content IN VARCHAR2
    );
    
    FUNCTION set_json_clob (
        p_path IN VARCHAR2,
        -- @json
        p_content IN CLOB
    )
    RETURN NUMBER;
    
    PROCEDURE set_json_clob (
        p_path IN VARCHAR2,
        -- @json
        p_content IN CLOB
    );
    
    FUNCTION set_string (
        p_path IN VARCHAR2,
        p_value IN VARCHAR2
    ) 
    RETURN NUMBER;
    
    PROCEDURE set_string (
        p_path IN VARCHAR2,
        p_value IN VARCHAR2
    );
    
    FUNCTION set_number (
        p_path IN VARCHAR2,
        p_value IN NUMBER
    ) 
    RETURN NUMBER;
    
    PROCEDURE set_number (
        p_path IN VARCHAR2,
        p_value IN NUMBER
    );
    
    FUNCTION set_boolean (
        p_path IN VARCHAR2,
        p_value IN BOOLEAN
    ) 
    RETURN NUMBER;
    
    PROCEDURE set_boolean (
        p_path IN VARCHAR2,
        p_value IN BOOLEAN
    );
    
    FUNCTION set_null (
        p_path IN VARCHAR2
    ) 
    RETURN NUMBER;
    
    PROCEDURE set_null (
        p_path IN VARCHAR2
    );
    
    FUNCTION set_object (
        p_path IN VARCHAR2
    ) 
    RETURN NUMBER;
    
    PROCEDURE set_object (
        p_path IN VARCHAR2
    );
    
    FUNCTION set_array (
        p_path IN VARCHAR2
    ) 
    RETURN NUMBER;
    
    PROCEDURE set_array (
        p_path IN VARCHAR2
    );

    PROCEDURE request_values (
        p_path IN VARCHAR2,
        p_values OUT SYS_REFCURSOR
    );
        
    FUNCTION request_values (
        p_path IN VARCHAR2
    ) 
    RETURN t_values PIPELINED;
    
    FUNCTION get_string (
        p_path IN VARCHAR2
    ) 
    RETURN VARCHAR2;
    
    FUNCTION get_number (
        p_path IN VARCHAR2
    ) 
    RETURN NUMBER;
    
    FUNCTION get_boolean (
        p_path IN VARCHAR2
    ) 
    RETURN BOOLEAN;

    FUNCTION get_json (
        p_path IN VARCHAR2
    ) 
    -- @json
    RETURN VARCHAR2;
    
    FUNCTION get_json_clob
        (p_path IN VARCHAR2)
    -- @json
    RETURN CLOB;
    
    PROCEDURE apply_json (
        p_path IN VARCHAR2,
        -- @json
        p_content IN VARCHAR2,
        p_check_types IN BOOLEAN := FALSE
    );
        
    PROCEDURE apply_json_clob (
        p_path IN VARCHAR2,
        -- @json
        p_content IN VARCHAR2,
        p_check_types IN BOOLEAN := FALSE
    );    
        
    FUNCTION get_length (
        p_path IN VARCHAR2
    )
    RETURN NUMBER;
    
    FUNCTION push_string (
        p_path IN VARCHAR2,
        p_value IN VARCHAR2
    )
    RETURN NUMBER;
    
    PROCEDURE push_string (
        p_path IN VARCHAR2,
        p_value IN VARCHAR2
    );
   
    FUNCTION push_number (
        p_path IN VARCHAR2,
        p_value IN NUMBER
    )
    RETURN NUMBER;
    
    PROCEDURE push_number (
        p_path IN VARCHAR2,
        p_value IN NUMBER
    );
    
    FUNCTION push_boolean (
        p_path IN VARCHAR2,
        p_value IN BOOLEAN
    ) 
    RETURN NUMBER;
    
    PROCEDURE push_boolean (
        p_path IN VARCHAR2,
        p_value IN BOOLEAN
    );
    
    FUNCTION push_null (
        p_path IN VARCHAR2
    )
    RETURN NUMBER;
        
    PROCEDURE push_null (
        p_path IN VARCHAR2
    );
        
    FUNCTION push_object (
        p_path IN VARCHAR2
    )
    RETURN NUMBER;
        
    PROCEDURE push_object (
        p_path IN VARCHAR2
    );
        
    FUNCTION push_array (
        p_path IN VARCHAR2
    )
    RETURN NUMBER;
        
    PROCEDURE push_array (
        p_path IN VARCHAR2
    );
        
    FUNCTION push_json (
        p_path IN VARCHAR2,
        -- @json
        p_content IN VARCHAR2
    )
    RETURN NUMBER;
        
    PROCEDURE push_json (
        p_path IN VARCHAR2,
        -- @json
        p_content IN VARCHAR2
    );
        
    FUNCTION push_json_clob (
        p_path IN VARCHAR2,
        -- @json
        p_content IN CLOB
    )
    RETURN NUMBER;
        
    PROCEDURE push_json_clob (
        p_path IN VARCHAR2,
        -- @json
        p_content IN CLOB
    );
         
    PROCEDURE delete_value (
        p_path IN VARCHAR2
    );
    
    PROCEDURE lock_value (
        p_path IN VARCHAR2
    );
    
    PROCEDURE unlock_value (
        p_path IN VARCHAR2
    );

    FUNCTION get_parse_events (
        p_path IN VARCHAR2
    )
    RETURN json_parser.t_parse_events;
    
    FUNCTION get_5_value_table (
        p_query IN VARCHAR2,
        p_variable_1 IN VARCHAR2 := NULL,
        p_variable_2 IN VARCHAR2 := NULL,
        p_variable_3 IN VARCHAR2 := NULL,
        p_variable_4 IN VARCHAR2 := NULL,
        p_variable_5 IN VARCHAR2 := NULL,
        p_variable_6 IN VARCHAR2 := NULL,
        p_variable_7 IN VARCHAR2 := NULL,
        p_variable_8 IN VARCHAR2 := NULL,
        p_variable_9 IN VARCHAR2 := NULL,
        p_variable_10 IN VARCHAR2 := NULL,
        p_variable_11 IN VARCHAR2 := NULL,
        p_variable_12 IN VARCHAR2 := NULL,
        p_variable_13 IN VARCHAR2 := NULL,
        p_variable_14 IN VARCHAR2 := NULL,
        p_variable_15 IN VARCHAR2 := NULL,
        p_variable_16 IN VARCHAR2 := NULL,
        p_variable_17 IN VARCHAR2 := NULL,
        p_variable_18 IN VARCHAR2 := NULL,
        p_variable_19 IN VARCHAR2 := NULL,
        p_variable_20 IN VARCHAR2 := NULL
    )
    RETURN t_5_value_table PIPELINED;
    
    FUNCTION get_10_value_table (
        p_query IN VARCHAR2,
        p_variable_1 IN VARCHAR2 := NULL,
        p_variable_2 IN VARCHAR2 := NULL,
        p_variable_3 IN VARCHAR2 := NULL,
        p_variable_4 IN VARCHAR2 := NULL,
        p_variable_5 IN VARCHAR2 := NULL,
        p_variable_6 IN VARCHAR2 := NULL,
        p_variable_7 IN VARCHAR2 := NULL,
        p_variable_8 IN VARCHAR2 := NULL,
        p_variable_9 IN VARCHAR2 := NULL,
        p_variable_10 IN VARCHAR2 := NULL,
        p_variable_11 IN VARCHAR2 := NULL,
        p_variable_12 IN VARCHAR2 := NULL,
        p_variable_13 IN VARCHAR2 := NULL,
        p_variable_14 IN VARCHAR2 := NULL,
        p_variable_15 IN VARCHAR2 := NULL,
        p_variable_16 IN VARCHAR2 := NULL,
        p_variable_17 IN VARCHAR2 := NULL,
        p_variable_18 IN VARCHAR2 := NULL,
        p_variable_19 IN VARCHAR2 := NULL,
        p_variable_20 IN VARCHAR2 := NULL
    )
    RETURN t_10_value_table PIPELINED;
    
    FUNCTION get_15_value_table (
        p_query IN VARCHAR2,
        p_variable_1 IN VARCHAR2 := NULL,
        p_variable_2 IN VARCHAR2 := NULL,
        p_variable_3 IN VARCHAR2 := NULL,
        p_variable_4 IN VARCHAR2 := NULL,
        p_variable_5 IN VARCHAR2 := NULL,
        p_variable_6 IN VARCHAR2 := NULL,
        p_variable_7 IN VARCHAR2 := NULL,
        p_variable_8 IN VARCHAR2 := NULL,
        p_variable_9 IN VARCHAR2 := NULL,
        p_variable_10 IN VARCHAR2 := NULL,
        p_variable_11 IN VARCHAR2 := NULL,
        p_variable_12 IN VARCHAR2 := NULL,
        p_variable_13 IN VARCHAR2 := NULL,
        p_variable_14 IN VARCHAR2 := NULL,
        p_variable_15 IN VARCHAR2 := NULL,
        p_variable_16 IN VARCHAR2 := NULL,
        p_variable_17 IN VARCHAR2 := NULL,
        p_variable_18 IN VARCHAR2 := NULL,
        p_variable_19 IN VARCHAR2 := NULL,
        p_variable_20 IN VARCHAR2 := NULL
    )
    RETURN t_15_value_table PIPELINED;
    
    FUNCTION get_20_value_table (
        p_query IN VARCHAR2,
        p_variable_1 IN VARCHAR2 := NULL,
        p_variable_2 IN VARCHAR2 := NULL,
        p_variable_3 IN VARCHAR2 := NULL,
        p_variable_4 IN VARCHAR2 := NULL,
        p_variable_5 IN VARCHAR2 := NULL,
        p_variable_6 IN VARCHAR2 := NULL,
        p_variable_7 IN VARCHAR2 := NULL,
        p_variable_8 IN VARCHAR2 := NULL,
        p_variable_9 IN VARCHAR2 := NULL,
        p_variable_10 IN VARCHAR2 := NULL,
        p_variable_11 IN VARCHAR2 := NULL,
        p_variable_12 IN VARCHAR2 := NULL,
        p_variable_13 IN VARCHAR2 := NULL,
        p_variable_14 IN VARCHAR2 := NULL,
        p_variable_15 IN VARCHAR2 := NULL,
        p_variable_16 IN VARCHAR2 := NULL,
        p_variable_17 IN VARCHAR2 := NULL,
        p_variable_18 IN VARCHAR2 := NULL,
        p_variable_19 IN VARCHAR2 := NULL,
        p_variable_20 IN VARCHAR2 := NULL
    )
    RETURN t_20_value_table PIPELINED;
    
    FUNCTION get_value_table (
        p_query IN VARCHAR2,
        p_variable_1 IN VARCHAR2 := NULL,
        p_variable_2 IN VARCHAR2 := NULL,
        p_variable_3 IN VARCHAR2 := NULL,
        p_variable_4 IN VARCHAR2 := NULL,
        p_variable_5 IN VARCHAR2 := NULL,
        p_variable_6 IN VARCHAR2 := NULL,
        p_variable_7 IN VARCHAR2 := NULL,
        p_variable_8 IN VARCHAR2 := NULL,
        p_variable_9 IN VARCHAR2 := NULL,
        p_variable_10 IN VARCHAR2 := NULL,
        p_variable_11 IN VARCHAR2 := NULL,
        p_variable_12 IN VARCHAR2 := NULL,
        p_variable_13 IN VARCHAR2 := NULL,
        p_variable_14 IN VARCHAR2 := NULL,
        p_variable_15 IN VARCHAR2 := NULL,
        p_variable_16 IN VARCHAR2 := NULL,
        p_variable_17 IN VARCHAR2 := NULL,
        p_variable_18 IN VARCHAR2 := NULL,
        p_variable_19 IN VARCHAR2 := NULL,
        p_variable_20 IN VARCHAR2 := NULL
    )
    RETURN ANYDATASET PIPELINED 
    USING t_json_query;
    
    FUNCTION get_value_table_cursor (
        p_query IN VARCHAR2
    )
    RETURN SYS_REFCURSOR;
    
END;
