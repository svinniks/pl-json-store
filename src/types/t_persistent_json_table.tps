CREATE OR REPLACE TYPE t_persistent_json_table UNDER t_json_table (

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
    
    column_count NUMBER,
    cursor_id INTEGER,
    row_buffer t_varchars,
    fetched_row_count NUMBER,
    piped_row_count NUMBER,

    CONSTRUCTOR FUNCTION t_persistent_json_table (
        p_row_type ANYTYPE
    ) RETURN SELF AS RESULT,
    
    STATIC FUNCTION odcitablestart (
        p_context IN OUT t_persistent_json_table,
        p_query IN VARCHAR2,
        p_bind IN bind := NULL
    )                                       
    RETURN PLS_INTEGER,
    
    STATIC FUNCTION odcitableprepare (
        p_context OUT t_persistent_json_table,
        p_table_function_info IN sys.odcitabfuncinfo,
        p_query IN VARCHAR2,
        p_bind IN bind := NULL
    ) RETURN PLS_INTEGER,
             
    MEMBER FUNCTION fetch_row (
        self IN OUT NOCOPY t_persistent_json_table,
        p_row IN OUT NOCOPY t_varchars
    ) RETURN BOOLEAN, 
    
    OVERRIDING MEMBER FUNCTION odcitablefetch (
        self IN OUT NOCOPY t_persistent_json_table,
        p_row_count IN NUMBER,
        p_dataset OUT ANYDATASET
    ) RETURN PLS_INTEGER,
    
    OVERRIDING MEMBER FUNCTION odcitableclose(
        self IN t_persistent_json_table
    ) RETURN PLS_INTEGER
    
)    
/