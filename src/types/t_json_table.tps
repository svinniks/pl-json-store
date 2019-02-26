CREATE OR REPLACE TYPE t_json_table FORCE IS OBJECT (

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
    
    STATIC FUNCTION odcitabledescribe (
        p_return_type OUT ANYTYPE,
        p_query IN VARCHAR2,
        p_bind IN bind := NULL
    ) 
    RETURN PLS_INTEGER,

    STATIC FUNCTION get_row_type (
        p_table_function_info IN sys.odcitabfuncinfo
    )
    RETURN ANYTYPE,
             
    NOT INSTANTIABLE MEMBER FUNCTION odcitablefetch (
        self IN OUT NOCOPY t_json_table,
        p_row_count IN NUMBER,
        p_dataset OUT ANYDATASET
    ) 
    RETURN PLS_INTEGER,
    
    NOT INSTANTIABLE MEMBER FUNCTION odcitableclose (
        self IN t_json_table
    ) 
    RETURN PLS_INTEGER
    
)
NOT FINAL
NOT INSTANTIABLE    
