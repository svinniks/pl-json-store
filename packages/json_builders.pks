CREATE OR REPLACE PACKAGE json_builders IS

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
        
    FUNCTION create_builder (
        p_serialize_nulls IN json_core.BOOLEANN := TRUE,
        p_nulls_as_empty_strings IN json_core.BOOLEANN := TRUE
    )
    RETURN PLS_INTEGER;
    
    PROCEDURE destroy_builder (
        p_id IN PLS_INTEGER
    );

    FUNCTION build_parse_events (
        p_builder_id IN PLS_INTEGER,
        p_serialize_nulls IN BOOLEAN := NULL
    )
    RETURN json_parser.t_parse_events;
    
    PROCEDURE value (
        p_builder_id IN PLS_INTEGER,
        p_value IN VARCHAR2,
        p_null_as_empty_string IN BOOLEAN := NULL
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
    
    PROCEDURE null_value (
        p_builder_id IN PLS_INTEGER
    );
    
    PROCEDURE json (
        p_builder_id IN PLS_INTEGER,
        -- @json
        p_content IN VARCHAR2
    );
    
    PROCEDURE json (
        p_builder_id IN PLS_INTEGER,
        -- @json
        p_content IN CLOB
    );
    
    PROCEDURE json (
        p_builder_id IN PLS_INTEGER,
        p_content_builder_id IN PLS_INTEGER
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
        p_builder_id IN PLS_INTEGER,
        p_serialize_nulls IN json_core.BOOLEANN := TRUE
    ) 
    -- @json
    RETURN VARCHAR2; 
    
    FUNCTION build_json_clob (
        p_builder_id IN PLS_INTEGER,
        p_serialize_nulls IN json_core.BOOLEANN := TRUE
    )
    -- @json 
    RETURN CLOB;
      
END;