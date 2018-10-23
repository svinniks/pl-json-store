CREATE OR REPLACE TYPE t_json_filter IS OBJECT (

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
    
    CONSTRUCTOR FUNCTION t_json_filter (
        p_base_value_id IN NUMBER
    )
    RETURN self AS RESULT,
   
    MEMBER FUNCTION path (
        p_path IN VARCHAR2
    )
    RETURN t_json_filter,
    
    MEMBER PROCEDURE path (
        self IN t_json_filter,
        p_path IN VARCHAR2
    ),
    
    MEMBER FUNCTION value (
        p_value IN VARCHAR2
    )
    RETURN t_json_filter,
    
    MEMBER PROCEDURE value (
        self IN t_json_filter,
        p_value IN VARCHAR2
    ),
    
    MEMBER FUNCTION value (
        p_value IN NUMBER
    )
    RETURN t_json_filter,
    
    MEMBER PROCEDURE value (
        self IN t_json_filter,
        p_value IN NUMBER
    ),
    
    MEMBER FUNCTION value (
        p_value IN DATE
    )
    RETURN t_json_filter,
    
    MEMBER PROCEDURE value (
        self IN t_json_filter,
        p_value IN DATE
    ),
    
    MEMBER FUNCTION value (
        p_value IN BOOLEAN
    )
    RETURN t_json_filter,
    
    MEMBER PROCEDURE value (
        self IN t_json_filter,
        p_value IN BOOLEAN
    ),
    
    MEMBER FUNCTION execute
    RETURN t_json_properties
    
)