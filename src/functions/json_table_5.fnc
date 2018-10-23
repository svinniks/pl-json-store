CREATE OR REPLACE FUNCTION json_table_5 (
    p_query IN VARCHAR2,
    p_bind IN bind := NULL
)
RETURN json_core.t_5_value_table PIPELINED IS
 
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
   
    e_no_more_rows_needed EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_no_more_rows_needed, -6548);

    v_query_element_i PLS_INTEGER;
    v_query_statement persistent_json_store.t_query_statement;
    
    v_cursor_id INTEGER;
    v_result INTEGER;
    c_rows SYS_REFCURSOR;
    
    v_row_buffer json_core.t_5_value_table;
    c_fetch_limit CONSTANT PLS_INTEGER := 1000;
    
BEGIN
    
    v_query_element_i := json_core.parse_query(p_query);
    
    v_query_statement := persistent_json_store.get_query_statement(
        v_query_element_i, 
        persistent_json_store.c_TABLE_QUERY, 
        5
    );
    
    v_cursor_id := persistent_json_store.prepare_query(
        NULL,
        v_query_element_i, 
        v_query_statement, 
        p_bind
    );
    
    v_result := DBMS_SQL.EXECUTE(v_cursor_id);
    c_rows := DBMS_SQL.TO_REFCURSOR(v_cursor_id);
        
    LOOP
        
        FETCH c_rows
        BULK COLLECT INTO v_row_buffer
        LIMIT c_fetch_limit;
            
        FOR v_i IN 1..v_row_buffer.COUNT LOOP
            PIPE ROW(v_row_buffer(v_i));
        END LOOP;
            
        EXIT WHEN v_row_buffer.COUNT < c_fetch_limit;
        
    END LOOP;
        
    CLOSE c_rows;
    
    RETURN;
        
EXCEPTION
    WHEN e_no_more_rows_needed THEN
        CLOSE c_rows;
    
END;