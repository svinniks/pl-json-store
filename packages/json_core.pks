CREATE OR REPLACE PACKAGE json_core IS

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
    
    FUNCTION get_query_variable_count (
        p_query_elements IN t_query_elements
    )
    RETURN PLS_INTEGER;
    
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
        p_query_elements IN t_query_elements,
        p_query_statement IN t_query_statement,
        p_bind IN bind
    )
    RETURN INTEGER;
    
    FUNCTION prepare_query (
        p_query IN VARCHAR2,
        p_bind IN bind,
        p_query_type IN PLS_INTEGER
    )
    RETURN INTEGER;
    
    FUNCTION get_length (
        p_array_id IN NUMBER
    )
    RETURN NUMBER;
    
    PROCEDURE request_properties (
        p_path IN VARCHAR2,
        p_bind IN bind,
        p_properties OUT SYS_REFCURSOR
    );
   
    PROCEDURE get_parse_events (
        p_path IN VARCHAR2,
        p_parse_events OUT json_parser.t_parse_events,
        p_bind IN bind := NULL
    ); 
    
    FUNCTION create_json (
        p_parent_ids IN t_numbers,
        p_name IN VARCHAR2,
        p_content_parse_events IN json_parser.t_parse_events,
        p_id IN NUMBER := NULL
    ) 
    RETURN t_numbers;
    
    FUNCTION set_property (
        p_path IN VARCHAR2,
        p_bind IN bind,
        p_content_parse_events IN json_parser.t_parse_events,
        p_exact IN BOOLEAN := TRUE
    )
    RETURN t_numbers;
    
    FUNCTION request_value (
        p_path IN VARCHAR2,
        p_bind IN bind
    ) 
    RETURN t_value;
    
    PROCEDURE apply_json (
        p_path IN VARCHAR2,
        p_content_parse_events json_parser.t_parse_events,
        p_bind IN bind,
        p_check_types IN BOOLEAN
    );
    
    FUNCTION push_property (
        p_path IN VARCHAR2,
        p_bind IN bind,
        p_content_parse_events IN json_parser.t_parse_events,
        p_exact IN BOOLEAN := TRUE
    )
    RETURN t_numbers;
    
    PROCEDURE serialize_value (
        p_parse_events IN json_parser.t_parse_events,
        p_json IN OUT NOCOPY VARCHAR2,
        p_json_clob IN OUT NOCOPY CLOB
    );

END;
