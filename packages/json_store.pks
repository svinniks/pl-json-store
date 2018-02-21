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

    TYPE t_path_element IS RECORD (
        type CHAR
       ,value VARCHAR2(4000)
    );
        
    TYPE t_path_elements IS TABLE OF t_path_element;
    
    TYPE t_query_element IS RECORD (
        type CHAR
       ,value VARCHAR2(4000)
       ,optional BOOLEAN
       ,alias VARCHAR2(4000)
       ,first_child_i PLS_INTEGER
       ,next_sibling_i PLS_INTEGER
    );
        
    TYPE t_query_elements IS TABLE OF t_query_element;
    
    TYPE t_property IS RECORD (
        parent_id NUMBER
       ,parent_type CHAR
       ,property_id NUMBER
       ,property_type CHAR
       ,property_name VARCHAR2(4000)
    );
       
    TYPE t_properties IS TABLE OF t_property;
    
    TYPE t_value IS RECORD (
        id NUMBER
       ,type CHAR
       ,value VARCHAR2(4000)
    );
        
    TYPE t_values IS TABLE OF t_value;
    
    TYPE t_t_varchars IS TABLE OF t_varchars;
    
    TYPE t_json_table_row_2 IS RECORD (
        column_1_value VARCHAR2(4000)
       ,column_2_value VARCHAR2(4000)
    );
    
    TYPE t_json_table_2 IS TABLE OF t_json_table_row_2;
    
    TYPE t_json_table_row_3 IS RECORD (
        column_1_value VARCHAR2(4000)
       ,column_2_value VARCHAR2(4000)
       ,column_3_value VARCHAR2(4000)
    );
    
    TYPE t_json_table_3 IS TABLE OF t_json_table_row_3;
   
    TYPE t_json_table_row_4 IS RECORD (
        column_1_value VARCHAR2(4000)
       ,column_2_value VARCHAR2(4000)
       ,column_3_value VARCHAR2(4000)
       ,column_4_value VARCHAR2(4000)
    );
    
    TYPE t_json_table_4 IS TABLE OF t_json_table_row_4;
    
    TYPE t_json_table_row_5 IS RECORD (
        column_1_value VARCHAR2(4000)
       ,column_2_value VARCHAR2(4000)
       ,column_3_value VARCHAR2(4000)
       ,column_4_value VARCHAR2(4000)
       ,column_5_value VARCHAR2(4000)
    );
    
    TYPE t_json_table_5 IS TABLE OF t_json_table_row_5;
    
    TYPE t_json_table_row_6 IS RECORD (
        column_1_value VARCHAR2(4000)
       ,column_2_value VARCHAR2(4000)
       ,column_3_value VARCHAR2(4000)
       ,column_4_value VARCHAR2(4000)
       ,column_5_value VARCHAR2(4000)
       ,column_6_value VARCHAR2(4000)
    );
    
    TYPE t_json_table_6 IS TABLE OF t_json_table_row_6;
    
    TYPE t_json_table_row_7 IS RECORD (
        column_1_value VARCHAR2(4000)
       ,column_2_value VARCHAR2(4000)
       ,column_3_value VARCHAR2(4000)
       ,column_4_value VARCHAR2(4000)
       ,column_5_value VARCHAR2(4000)
       ,column_6_value VARCHAR2(4000)
       ,column_7_value VARCHAR2(4000)
    );
    
    TYPE t_json_table_7 IS TABLE OF t_json_table_row_7;
    
    TYPE t_json_table_row_8 IS RECORD (
        column_1_value VARCHAR2(4000)
       ,column_2_value VARCHAR2(4000)
       ,column_3_value VARCHAR2(4000)
       ,column_4_value VARCHAR2(4000)
       ,column_5_value VARCHAR2(4000)
       ,column_6_value VARCHAR2(4000)
       ,column_7_value VARCHAR2(4000)
       ,column_8_value VARCHAR2(4000)
    );
    
    TYPE t_json_table_8 IS TABLE OF t_json_table_row_8;
    
    TYPE t_json_table_row_9 IS RECORD (
        column_1_value VARCHAR2(4000)
       ,column_2_value VARCHAR2(4000)
       ,column_3_value VARCHAR2(4000)
       ,column_4_value VARCHAR2(4000)
       ,column_5_value VARCHAR2(4000)
       ,column_6_value VARCHAR2(4000)
       ,column_7_value VARCHAR2(4000)
       ,column_8_value VARCHAR2(4000)
       ,column_9_value VARCHAR2(4000)
    );
    
    TYPE t_json_table_9 IS TABLE OF t_json_table_row_9;
    
    TYPE t_json_table_row_10 IS RECORD (
        column_1_value VARCHAR2(4000)
       ,column_2_value VARCHAR2(4000)
       ,column_3_value VARCHAR2(4000)
       ,column_4_value VARCHAR2(4000)
       ,column_5_value VARCHAR2(4000)
       ,column_6_value VARCHAR2(4000)
       ,column_7_value VARCHAR2(4000)
       ,column_8_value VARCHAR2(4000)
       ,column_9_value VARCHAR2(4000)
       ,column_10_value VARCHAR2(4000)
    );
    
    TYPE t_json_table_10 IS TABLE OF t_json_table_row_10;

    FUNCTION parse_path
        (p_path IN VARCHAR2)
    RETURN t_path_elements;
    
    FUNCTION parse_query
        (p_query IN VARCHAR2)
    RETURN t_query_elements;
    
    PROCEDURE request_properties
        (p_path IN VARCHAR2
        ,p_properties OUT SYS_REFCURSOR);
        
    FUNCTION request_properties
        (p_path IN VARCHAR2)
    RETURN t_properties PIPELINED;
    
    FUNCTION create_json
        (-- @json
         p_content IN VARCHAR2)
    RETURN NUMBER;
    
    FUNCTION create_json_clob
        (-- @json
         p_content IN CLOB)
    RETURN NUMBER;
    
    FUNCTION create_string
        (p_value IN VARCHAR2)
    RETURN NUMBER;
    
    FUNCTION create_number
        (p_value IN NUMBER)
    RETURN NUMBER;
    
    FUNCTION create_boolean
        (p_value IN BOOLEAN)
    RETURN NUMBER;
    
    FUNCTION create_null
    RETURN NUMBER;

    FUNCTION create_object
    RETURN NUMBER;
    
    FUNCTION create_array
    RETURN NUMBER;
    
    FUNCTION set_json
        (p_path IN VARCHAR2
        ,-- @json
         p_content IN VARCHAR2)
    RETURN NUMBER;
    
    PROCEDURE set_json
        (p_path IN VARCHAR2
        ,-- @json
         p_content IN VARCHAR2);
    
    FUNCTION set_json_clob
        (p_path IN VARCHAR2
        ,-- @json
         p_content IN CLOB)
    RETURN NUMBER;
    
    PROCEDURE set_json_clob
        (p_path IN VARCHAR2
        ,-- @json
         p_content IN CLOB);
    
    FUNCTION set_string
        (p_path IN VARCHAR2
        ,p_value IN VARCHAR2)
    RETURN NUMBER;
    
    PROCEDURE set_string
        (p_path IN VARCHAR2
        ,p_value IN VARCHAR2);
    
    FUNCTION set_number
        (p_path IN VARCHAR2
        ,p_value IN NUMBER)
    RETURN NUMBER;
    
    PROCEDURE set_number
        (p_path IN VARCHAR2
        ,p_value IN NUMBER);
    
    FUNCTION set_boolean
        (p_path IN VARCHAR2
        ,p_value IN BOOLEAN)
    RETURN NUMBER;
    
    PROCEDURE set_boolean
        (p_path IN VARCHAR2
        ,p_value IN BOOLEAN);
    
    FUNCTION set_null
        (p_path IN VARCHAR2)
    RETURN NUMBER;
    
    PROCEDURE set_null
        (p_path IN VARCHAR2);
    
    FUNCTION set_object
        (p_path IN VARCHAR2)
    RETURN NUMBER;
    
    PROCEDURE set_object
        (p_path IN VARCHAR2);
    
    FUNCTION set_array
        (p_path IN VARCHAR2)
    RETURN NUMBER;
    
    PROCEDURE set_array
        (p_path IN VARCHAR2);

    PROCEDURE request_values
        (p_path IN VARCHAR2
        ,p_values OUT SYS_REFCURSOR);
        
    FUNCTION request_values
        (p_path IN VARCHAR2)
    RETURN t_values PIPELINED;
    
    FUNCTION get_string
        (p_path IN VARCHAR2)
    RETURN VARCHAR2;
    
    FUNCTION get_number
        (p_path IN VARCHAR2)
    RETURN NUMBER;
    
    FUNCTION get_boolean
        (p_path IN VARCHAR2)
    RETURN BOOLEAN;

    FUNCTION get_json
        (p_path IN VARCHAR2)
    -- @json
    RETURN VARCHAR2;
    
    FUNCTION get_json_clob
        (p_path IN VARCHAR2)
    -- @json
    RETURN CLOB;
    
    PROCEDURE apply_json
        (p_path IN VARCHAR2,
         -- @json
         p_content IN VARCHAR2
        ,p_check_types IN BOOLEAN := FALSE);
        
    PROCEDURE apply_json_clob
        (p_path IN VARCHAR2,
         -- @json
         p_content IN VARCHAR2
        ,p_check_types IN BOOLEAN := FALSE);    
        
    FUNCTION get_length
        (p_path IN VARCHAR2)
    RETURN NUMBER;
    
    FUNCTION push_string
        (p_path IN VARCHAR2
        ,p_value IN VARCHAR2)
    RETURN NUMBER;
    
    PROCEDURE push_string
        (p_path IN VARCHAR2
        ,p_value IN VARCHAR2);
   
    FUNCTION push_number
        (p_path IN VARCHAR2
        ,p_value IN NUMBER)
    RETURN NUMBER;
    
    PROCEDURE push_number
        (p_path IN VARCHAR2
        ,p_value IN NUMBER);
    
    FUNCTION push_boolean
        (p_path IN VARCHAR2
        ,p_value IN BOOLEAN)
    RETURN NUMBER;
    
    PROCEDURE push_boolean
        (p_path IN VARCHAR2
        ,p_value IN BOOLEAN);
    
    FUNCTION push_null
        (p_path IN VARCHAR2)
    RETURN NUMBER;
        
    PROCEDURE push_null
        (p_path IN VARCHAR2);
        
    FUNCTION push_object
        (p_path IN VARCHAR2)
    RETURN NUMBER;
        
    PROCEDURE push_object
        (p_path IN VARCHAR2);
        
    FUNCTION push_array
        (p_path IN VARCHAR2)
    RETURN NUMBER;
        
    PROCEDURE push_array
        (p_path IN VARCHAR2);
        
    FUNCTION push_json
        (p_path IN VARCHAR2,
        -- @json
        p_content IN VARCHAR2)
    RETURN NUMBER;
        
    PROCEDURE push_json
        (p_path IN VARCHAR2,
         -- @json
         p_content IN VARCHAR2);
        
    FUNCTION push_json_clob
        (p_path IN VARCHAR2,
         -- @json
        p_content IN CLOB)
    RETURN NUMBER;
        
    PROCEDURE push_json_clob
        (p_path IN VARCHAR2,
         -- @json
         p_content IN CLOB);
         
    PROCEDURE delete_value
        (p_path IN VARCHAR2);

    FUNCTION get_parse_events
        (p_path IN VARCHAR2)
    RETURN json_parser.t_parse_events;
    
    PROCEDURE get_json_table
        (p_paths IN t_varchars
        ,p_rows IN OUT NOCOPY t_t_varchars);
    
    FUNCTION get_json_table
        (p_paths IN t_varchars)
    RETURN t_t_varchars PIPELINED;     

    FUNCTION get_json_table
        (p_path IN VARCHAR2)
    RETURN t_varchars PIPELINED;
    
    FUNCTION get_json_table
        (p_path_1 IN VARCHAR2
        ,p_path_2 IN VARCHAR2)
    RETURN t_json_table_2 PIPELINED;
    
    FUNCTION get_json_table
        (p_path_1 IN VARCHAR2
        ,p_path_2 IN VARCHAR2
        ,p_path_3 IN VARCHAR2)
    RETURN t_json_table_3 PIPELINED;
    
    FUNCTION get_json_table
        (p_path_1 IN VARCHAR2
        ,p_path_2 IN VARCHAR2
        ,p_path_3 IN VARCHAR2
        ,p_path_4 IN VARCHAR2)
    RETURN t_json_table_4 PIPELINED;
    
    FUNCTION get_json_table
        (p_path_1 IN VARCHAR2
        ,p_path_2 IN VARCHAR2
        ,p_path_3 IN VARCHAR2
        ,p_path_4 IN VARCHAR2
        ,p_path_5 IN VARCHAR2)
    RETURN t_json_table_5 PIPELINED;
    
    FUNCTION get_json_table
        (p_path_1 IN VARCHAR2
        ,p_path_2 IN VARCHAR2
        ,p_path_3 IN VARCHAR2
        ,p_path_4 IN VARCHAR2
        ,p_path_5 IN VARCHAR2
        ,p_path_6 IN VARCHAR2)
    RETURN t_json_table_6 PIPELINED;
    
    FUNCTION get_json_table
        (p_path_1 IN VARCHAR2
        ,p_path_2 IN VARCHAR2
        ,p_path_3 IN VARCHAR2
        ,p_path_4 IN VARCHAR2
        ,p_path_5 IN VARCHAR2
        ,p_path_6 IN VARCHAR2
        ,p_path_7 IN VARCHAR2)
    RETURN t_json_table_7 PIPELINED;
    
    FUNCTION get_json_table
        (p_path_1 IN VARCHAR2
        ,p_path_2 IN VARCHAR2
        ,p_path_3 IN VARCHAR2
        ,p_path_4 IN VARCHAR2
        ,p_path_5 IN VARCHAR2
        ,p_path_6 IN VARCHAR2
        ,p_path_7 IN VARCHAR2
        ,p_path_8 IN VARCHAR2)
    RETURN t_json_table_8 PIPELINED;
    
    FUNCTION get_json_table
        (p_path_1 IN VARCHAR2
        ,p_path_2 IN VARCHAR2
        ,p_path_3 IN VARCHAR2
        ,p_path_4 IN VARCHAR2
        ,p_path_5 IN VARCHAR2
        ,p_path_6 IN VARCHAR2
        ,p_path_7 IN VARCHAR2
        ,p_path_8 IN VARCHAR2
        ,p_path_9 IN VARCHAR2)
    RETURN t_json_table_9 PIPELINED;
    
    FUNCTION get_json_table
        (p_path_1 IN VARCHAR2
        ,p_path_2 IN VARCHAR2
        ,p_path_3 IN VARCHAR2
        ,p_path_4 IN VARCHAR2
        ,p_path_5 IN VARCHAR2
        ,p_path_6 IN VARCHAR2
        ,p_path_7 IN VARCHAR2
        ,p_path_8 IN VARCHAR2
        ,p_path_9 IN VARCHAR2
        ,p_path_10 IN VARCHAR2)
    RETURN t_json_table_10 PIPELINED;
    
END;
