CREATE OR REPLACE TYPE BODY t_json_query IS
    
    STATIC FUNCTION odcitablestart 
        (p_context IN OUT t_json_query
        ,p_query IN VARCHAR2) RETURN PLS_INTEGER IS
    BEGIN
    
        RETURN odciconst.success;
    
    END;
    
    STATIC FUNCTION odcitableprepare 
        (p_context OUT t_json_query
        ,p_table_function_info IN sys.odcitabfuncinfo
        ,p_query IN VARCHAR2) RETURN PLS_INTEGER IS
        
        v_query_elements json_store.t_query_elements;
        v_column_names t_varchars;
        v_lines DBMS_SQL.VARCHAR2A;
        
        v_cursor_id INTEGER;
        v_result INTEGER;
        
        v_precision PLS_INTEGER;
        v_scale PLS_INTEGER;
        v_length PLS_INTEGER;
        v_cs_id PLS_INTEGER;
        v_cs_frm PLS_INTEGER;
        v_row_type ANYTYPE;    
        v_name VARCHAR2(30);
        
        v_column_value VARCHAR2(4000);
        
    BEGIN
    
        v_query_elements := json_store.parse_query(p_query);
        v_column_names := json_store.get_query_column_names(v_query_elements);
        v_lines := json_store.generate_query_statement(v_query_elements);
        
        v_cursor_id := DBMS_SQL.OPEN_CURSOR();
        DBMS_SQL.PARSE(v_cursor_id, v_lines, 1, v_lines.COUNT, FALSE, DBMS_SQL.NATIVE);
        
        FOR v_i IN 1..v_column_names.COUNT LOOP
            DBMS_SQL.DEFINE_COLUMN(v_cursor_id, v_i, v_column_value, 4000);
        END LOOP;
        
        v_result := DBMS_SQL.EXECUTE(v_cursor_id);
    
        v_result := p_table_function_info.rettype.getattreleminfo(
            1
           ,v_precision
           ,v_scale
           ,v_length
           ,v_cs_id
           ,v_cs_frm
           ,v_row_type
           ,v_name
        );
    
        p_context := t_json_query(v_row_type, v_column_names.COUNT, v_cursor_id);
        
        RETURN odciconst.success; 
    
    END;
    
    STATIC FUNCTION odcitabledescribe
        (p_return_type OUT ANYTYPE
        ,p_query IN VARCHAR2) RETURN PLS_INTEGER IS
        
        v_row_type anytype;
        
        v_query_elements json_store.t_query_elements;
        v_column_names t_varchars;
        
    BEGIN
    
        v_query_elements := json_store.parse_query(p_query);
        v_column_names := json_store.get_query_column_names(v_query_elements);
    
        anytype.begincreate(DBMS_TYPES.TYPECODE_OBJECT, v_row_type);
        
        FOR v_i IN 1..v_column_names.COUNT LOOP
            v_row_type.addattr(v_column_names(v_i), DBMS_TYPES.TYPECODE_VARCHAR2, NULL, NULL, 4000, NULL, NULL);
        END LOOP;
        
        v_row_type.endcreate;
        
        anytype.begincreate(DBMS_TYPES.TYPECODE_NAMEDCOLLECTION, p_return_type);
        p_return_type.setinfo(NULL, NULL, NULL, NULL, NULL, v_row_type, DBMS_TYPES.TYPECODE_OBJECT, 0);
        p_return_type.endcreate;
    
        RETURN odciconst.success;
    
    END;
             
    MEMBER FUNCTION odcitablefetch
        (self IN OUT t_json_query
        ,p_row_count IN NUMBER
        ,p_dataset OUT ANYDATASET) RETURN PLS_INTEGER IS
        
        v_column_value VARCHAR2(4000);
        
    BEGIN
    
        IF DBMS_SQL.FETCH_ROWS(cursor_id) > 0 THEN
        
            ANYDATASET.begincreate(DBMS_TYPES.TYPECODE_OBJECt, row_type, p_dataset); 
            
            p_dataset.addinstance;          
            p_dataset.piecewise;
            
            FOR v_i IN 1..column_count LOOP
                DBMS_SQL.COLUMN_VALUE(cursor_id, v_i, v_column_value);
                p_dataset.setvarchar2(v_column_value, v_i = column_count);
            END LOOP;
            
            p_dataset.endcreate;
        
        END IF;
    
        RETURN odciconst.success;
    
    END;
    
    MEMBER FUNCTION odcitableclose
        (self IN t_json_query) RETURN PLS_INTEGER IS
        
        v_cursor_id INTEGER;
        
    BEGIN
    
        v_cursor_id := cursor_id;
--        DBMS_SQL.CLOSE_CURSOR(v_cursor_id);
    
        RETURN odciconst.success;
    
    END;
    

END;
