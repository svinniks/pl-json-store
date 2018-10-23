CREATE OR REPLACE TYPE t_json_builder IS OBJECT (

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
    
    CONSTRUCTOR FUNCTION t_json_builder (
        p_serialize_nulls IN BOOLEAN := TRUE,
        p_nulls_as_empty_strings IN BOOLEAN := FALSE
    )
    RETURN self AS RESULT,
    
    MEMBER FUNCTION value (
        p_value IN VARCHAR2,
        p_null_as_empty_string IN BOOLEAN := NULL
    )
    RETURN t_json_builder,
    
    MEMBER PROCEDURE value (
        self IN t_json_builder,
        p_value IN VARCHAR2,
        p_null_as_empty_string IN BOOLEAN := NULL
    ),
    
    MEMBER FUNCTION value (
        p_value IN DATE
    )
    RETURN t_json_builder,
    
    MEMBER PROCEDURE value (
        self IN t_json_builder,
        p_value IN DATE
    ),
    
    MEMBER FUNCTION value (
        p_value IN NUMBER
    )
    RETURN t_json_builder,
    
    MEMBER PROCEDURE value (
        self IN t_json_builder,
        p_value IN NUMBER
    ),
    
    MEMBER FUNCTION value (
        p_value IN BOOLEAN
    )
    RETURN t_json_builder,
    
    MEMBER PROCEDURE value (
        self IN t_json_builder,
        p_value IN BOOLEAN
    ),
    
    MEMBER FUNCTION null_value
    RETURN t_json_builder,
    
    MEMBER PROCEDURE null_value (
        self IN t_json_builder
    ),
    
    MEMBER FUNCTION json (
        p_content IN VARCHAR2
    )
    RETURN t_json_builder,
    
    MEMBER PROCEDURE json (
        self IN t_json_builder,
        p_content IN VARCHAR2
    ),
    
    MEMBER FUNCTION json (
        p_content IN CLOB
    )
    RETURN t_json_builder,
    
    MEMBER PROCEDURE json (
        self IN t_json_builder,
        p_content IN CLOB
    ),
    
    MEMBER FUNCTION json (
        p_builder IN t_json_builder
    )
    RETURN t_json_builder,
    
    MEMBER PROCEDURE json (
        self IN t_json_builder,
        p_builder IN t_json_builder
    ),
    
    MEMBER FUNCTION object
    RETURN t_json_builder,
    
    MEMBER PROCEDURE object (
        self IN t_json_builder
    ),
    
    MEMBER FUNCTION name (
        p_name IN VARCHAR2
    )
    RETURN t_json_builder,
    
    MEMBER PROCEDURE name (
        self IN t_json_builder,
        p_name IN VARCHAR2
    ),
    
    MEMBER FUNCTION array
    RETURN t_json_builder,
    
    MEMBER PROCEDURE array (
        self IN t_json_builder
    ), 
    
    MEMBER FUNCTION close
    RETURN t_json_builder,
    
    MEMBER PROCEDURE close (
        self IN t_json_builder
    ),
    
    MEMBER FUNCTION build_parse_events
    RETURN t_varchars,
    
    MEMBER FUNCTION build_json (
        p_serialize_nulls IN BOOLEAN := TRUE
    )
    RETURN VARCHAR2,
    
    MEMBER FUNCTION build_json_clob (
        p_serialize_nulls IN BOOLEAN := TRUE
    )
    RETURN CLOB
    
);