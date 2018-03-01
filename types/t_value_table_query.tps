CREATE OR REPLACE TYPE t_value_table_query AUTHID CURRENT_USER AS OBJECT (

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
    
    row_type ANYTYPE,
    column_count NUMBER,
    cursor_id INTEGER,
    row_buffer t_varchars,
    fetched_row_count NUMBER,
    piped_row_count NUMBER,

    CONSTRUCTOR FUNCTION t_value_table_query (
        p_row_type ANYTYPE
    ) RETURN SELF AS RESULT,
    
    STATIC FUNCTION odcitablestart (
        p_context IN OUT t_value_table_query,
        p_query IN VARCHAR2,
        p_bind IN bind
    )                                       
    RETURN PLS_INTEGER,
    
    STATIC FUNCTION odcitableprepare (
        p_context OUT t_value_table_query,
        p_table_function_info IN sys.odcitabfuncinfo,
        p_query IN VARCHAR2,
        p_bind IN bind
    ) RETURN PLS_INTEGER,
    
    STATIC FUNCTION odcitabledescribe (
        p_return_type OUT ANYTYPE,
        p_query IN VARCHAR2,
        p_bind IN bind
    ) RETURN PLS_INTEGER,
             
    MEMBER FUNCTION fetch_row (
        self IN OUT NOCOPY t_value_table_query,
        p_row IN OUT NOCOPY t_varchars
    ) RETURN BOOLEAN, 
    
    MEMBER FUNCTION odcitablefetch (
        self IN OUT NOCOPY t_value_table_query,
        p_row_count IN NUMBER,
        p_dataset OUT ANYDATASET
    ) RETURN PLS_INTEGER,
    
    MEMBER FUNCTION odcitableclose(
        self IN t_value_table_query
    ) RETURN PLS_INTEGER
    
)    
/