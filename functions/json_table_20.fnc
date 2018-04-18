CREATE OR REPLACE FUNCTION json_table_20 (
    p_query IN VARCHAR2,
    p_bind IN bind := NULL
)
RETURN json_core.t_20_value_table PIPELINED IS
    
    e_no_more_rows_needed EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_no_more_rows_needed, -6548);

    v_query_elements json_core.t_query_elements;
    v_query_statement json_core.t_query_statement;
    
    v_cursor_id INTEGER;
    v_result INTEGER;
    c_rows SYS_REFCURSOR;
    
    v_row_buffer json_core.t_20_value_table;
    c_fetch_limit CONSTANT PLS_INTEGER := 1000;
    
BEGIN
    
    v_query_elements := json_core.parse_query(p_query);
    v_query_statement := json_core.get_query_statement(v_query_elements, json_core.c_TABLE_QUERY, 20);
    
    v_cursor_id := json_core.prepare_query(v_query_elements, v_query_statement, p_bind);
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