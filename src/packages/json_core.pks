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

    SUBTYPE STRING IS
        VARCHAR2(32767);

    c_DATE_FORMAT CONSTANT VARCHAR2(12) := 'FXYYYY-MM-DD';
    
    SUBTYPE t_json_value IS
        json_values%ROWTYPE;
        
    TYPE t_json_values IS
        TABLE OF t_json_value;
        
    TYPE t_query_element IS 
        RECORD (
            type CHAR,
            value VARCHAR2(4000),
            optional BOOLEAN,
            alias VARCHAR2(4000),
            bind_number PLS_INTEGER,
            first_child_i PLS_INTEGER,
            next_sibling_i PLS_INTEGER,
            parent_i PLS_INTEGER
        );
        
    TYPE t_query_elements IS 
        TABLE OF t_query_element;
    
    v_query_elements t_query_elements := t_query_elements();
        
    -- Do-nothing procedure to initialize error messages from another packages
    
    PROCEDURE touch;
    
    -- Generic functions
    
    FUNCTION to_json_char (
        p_value IN NUMBER
    )
    RETURN VARCHAR2;
    
    FUNCTION to_json_char (
        p_value IN DATE
    )
    RETURN VARCHAR2;
    
    FUNCTION to_json_char (
        p_value IN BOOLEAN
    )
    RETURN VARCHAR2;    
        
    -- Simple JSON value parse event generators
    
    FUNCTION string_events (
        p_value IN VARCHAR2
    )
    RETURN t_varchars;
    
    FUNCTION number_events (
        p_value IN NUMBER
    )
    RETURN t_varchars;
    
    FUNCTION date_events (
        p_value IN DATE
    )
    RETURN t_varchars;
    
    FUNCTION boolean_events (
        p_value IN BOOLEAN
    )
    RETURN t_varchars;
    
    FUNCTION null_events
    RETURN t_varchars;
    
    FUNCTION object_events
    RETURN t_varchars;
    
    FUNCTION array_events
    RETURN t_varchars;
    
    -- Serializatio/deserializationn methods    
        
    FUNCTION escape_string (
        p_string IN VARCHAR2
    )
    RETURN VARCHAR2;    
        
    PROCEDURE serialize_value (
        p_content_parse_events IN t_varchars,
        p_json IN OUT NOCOPY VARCHAR2,
        p_json_clob IN OUT NOCOPY CLOB
    );
    
    -- JSON query API methods
    
    PROCEDURE dump (
        p_query_elements OUT t_query_elements
    );
    
    FUNCTION parse_query (
        p_query IN VARCHAR2,
        p_anchored IN BOOLEAN := FALSE
    ) 
    RETURN PLS_INTEGER;
    
    FUNCTION parse_path (
        p_path IN VARCHAR2,
        p_anchored IN BOOLEAN := FALSE
    ) 
    RETURN PLS_INTEGER;
    
    FUNCTION get_query_column_names (
        p_query_element_i IN PLS_INTEGER
    )
    RETURN t_varchars;
    
    FUNCTION get_query_column_count (
        p_query_element_i IN PLS_INTEGER
    )
    RETURN PLS_INTEGER;
    
END;