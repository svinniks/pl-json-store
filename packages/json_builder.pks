CREATE OR REPLACE PACKAGE json_builder IS

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
    
    TYPE t_object_properties IS
        TABLE OF CHAR
        INDEX BY VARCHAR2(4000);
        
    TYPE t_object_property_stack IS
        TABLE OF t_object_properties;
        
    TYPE t_json_builder IS
        RECORD (
            state VARCHAR2(30),
            composite_stack t_varchars,
            object_property_stack t_object_property_stack,
            parse_events json_parser.t_parse_events
        );
        
    TYPE t_json_builders IS
        TABLE OF t_json_builder
        INDEX BY PLS_INTEGER;
        
    FUNCTION create_builder
    RETURN PLS_INTEGER;
    
    PROCEDURE destroy_builder (
        p_id IN PLS_INTEGER
    );

    FUNCTION build_parse_events (
        p_builder_id IN PLS_INTEGER
    )
    RETURN json_parser.t_parse_events;
    
    PROCEDURE value (
        p_builder_id IN PLS_INTEGER,
        p_value IN VARCHAR2
    );
    
    PROCEDURE value (
        p_builder_id IN PLS_INTEGER,
        p_value IN DATE
    );
    
    PROCEDURE value (
        p_builder_id IN PLS_INTEGER,
        p_value IN NUMBER
    );
    
    PROCEDURE value (
        p_builder_id IN PLS_INTEGER,
        p_value IN BOOLEAN
    );
    
    PROCEDURE array (
        p_builder_id IN PLS_INTEGER
    );
    
    PROCEDURE object (
        p_builder_id IN PLS_INTEGER
    );
    
    PROCEDURE name (
        p_builder_id IN PLS_INTEGER,
        p_name IN VARCHAR2
    );
    
    PROCEDURE close (
        p_builder_id IN PLS_INTEGER
    );
    
    FUNCTION build_json (
        p_builder_id IN PLS_INTEGER
    ) 
    -- @json
    RETURN VARCHAR2; 
    
    FUNCTION build_json_clob (
        p_builder_id IN PLS_INTEGER
    )
    -- @json 
    RETURN CLOB;
      
END;