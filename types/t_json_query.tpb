CREATE OR REPLACE TYPE BODY t_json_query IS

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
    
    CONSTRUCTOR FUNCTION t_json_query (
        p_row_type ANYTYPE
    ) RETURN SELF AS RESULT IS
    BEGIN
    
        row_type := p_row_type;
        RETURN;
    
    END;

    STATIC FUNCTION odcitablestart ( 
        p_context IN OUT t_json_query,
        p_query IN VARCHAR2,
        p_variable_1 IN VARCHAR2 := NULL,
        p_variable_2 IN VARCHAR2 := NULL,
        p_variable_3 IN VARCHAR2 := NULL,
        p_variable_4 IN VARCHAR2 := NULL,
        p_variable_5 IN VARCHAR2 := NULL,
        p_variable_6 IN VARCHAR2 := NULL,
        p_variable_7 IN VARCHAR2 := NULL,
        p_variable_8 IN VARCHAR2 := NULL,
        p_variable_9 IN VARCHAR2 := NULL,
        p_variable_10 IN VARCHAR2 := NULL,
        p_variable_11 IN VARCHAR2 := NULL,
        p_variable_12 IN VARCHAR2 := NULL,
        p_variable_13 IN VARCHAR2 := NULL,
        p_variable_14 IN VARCHAR2 := NULL,
        p_variable_15 IN VARCHAR2 := NULL,
        p_variable_16 IN VARCHAR2 := NULL,
        p_variable_17 IN VARCHAR2 := NULL,
        p_variable_18 IN VARCHAR2 := NULL,
        p_variable_19 IN VARCHAR2 := NULL,
        p_variable_20 IN VARCHAR2 := NULL
    ) RETURN PLS_INTEGER IS
        
        v_prepared_query json_store.t_prepared_query;
        v_cursor_id INTEGER;
        
        v_dummy DBMS_SQL.VARCHAR2_TABLE;
        v_result INTEGER;
        
        v_variable_values t_varchars;
        v_variable NUMBER;
        
    BEGIN
    
        v_prepared_query := json_store.prepare_query(p_query);
    
        v_cursor_id := DBMS_SQL.OPEN_CURSOR();
        
        IF v_prepared_query.statement_clob IS NOT NULL THEN
            DBMS_SQL.PARSE(v_cursor_id, v_prepared_query.statement_clob, DBMS_SQL.NATIVE);
        ELSE
            DBMS_SQL.PARSE(v_cursor_id, v_prepared_query.statement, DBMS_SQL.NATIVE);
        END IF;
        
        v_variable_values := t_varchars (
            p_variable_1,
            p_variable_2,
            p_variable_3,
            p_variable_4,
            p_variable_5,
            p_variable_6,
            p_variable_7,
            p_variable_8,
            p_variable_9,
            p_variable_10,
            p_variable_11,
            p_variable_12,
            p_variable_13,
            p_variable_14,
            p_variable_15,
            p_variable_16,
            p_variable_17,
            p_variable_18,
            p_variable_19,
            p_variable_20
        );
                
        FOR v_i IN 1..v_prepared_query.variable_names.COUNT LOOP
        
            v_variable := v_prepared_query.variable_names(v_i);
                    
            IF v_variable_values(v_variable) IS NOT NULL THEN
                DBMS_SQL.BIND_VARIABLE(v_cursor_id, ':' || v_variable, v_variable_values(v_variable));
            END IF;
            
        END LOOP;
        
        v_result := DBMS_SQL.EXECUTE(v_cursor_id);
        
        p_context.cursor_id := v_cursor_id;
        p_context.column_count := v_prepared_query.column_names.COUNT;
        p_context.fetched_row_count := NULL;
        p_context.piped_row_count := 0;
        
        p_context.row_buffer := t_varchars();
        p_context.row_buffer.EXTEND(p_context.column_count * json_store.c_query_row_buffer_size);
        
        RETURN odciconst.success;
    
    END;
    
    STATIC FUNCTION odcitabledescribe (
        p_return_type OUT ANYTYPE,
        p_query IN VARCHAR2,
        p_variable_1 IN VARCHAR2 := NULL,
        p_variable_2 IN VARCHAR2 := NULL,
        p_variable_3 IN VARCHAR2 := NULL,
        p_variable_4 IN VARCHAR2 := NULL,
        p_variable_5 IN VARCHAR2 := NULL,
        p_variable_6 IN VARCHAR2 := NULL,
        p_variable_7 IN VARCHAR2 := NULL,
        p_variable_8 IN VARCHAR2 := NULL,
        p_variable_9 IN VARCHAR2 := NULL,
        p_variable_10 IN VARCHAR2 := NULL,
        p_variable_11 IN VARCHAR2 := NULL,
        p_variable_12 IN VARCHAR2 := NULL,
        p_variable_13 IN VARCHAR2 := NULL,
        p_variable_14 IN VARCHAR2 := NULL,
        p_variable_15 IN VARCHAR2 := NULL,
        p_variable_16 IN VARCHAR2 := NULL,
        p_variable_17 IN VARCHAR2 := NULL,
        p_variable_18 IN VARCHAR2 := NULL,
        p_variable_19 IN VARCHAR2 := NULL,
        p_variable_20 IN VARCHAR2 := NULL
    ) RETURN PLS_INTEGER IS
        
        v_prepared_query json_store.t_prepared_query;
        
        v_row_type ANYTYPE;
        
    BEGIN
        
        v_prepared_query := json_store.prepare_query(p_query);
        
        ANYTYPE.begincreate(DBMS_TYPES.TYPECODE_OBJECT, v_row_type);
        
        FOR v_i IN 1..v_prepared_query.column_names.COUNT LOOP
            v_row_type.addattr(v_prepared_query.column_names(v_i), DBMS_TYPES.TYPECODE_VARCHAR2, NULL, NULL, 4000, NULL, NULL);
        END LOOP;
            
        v_row_type.endcreate;
            
        ANYTYPE.begincreate(DBMS_TYPES.TYPECODE_NAMEDCOLLECTION, p_return_type);
        p_return_type.setinfo(NULL, NULL, NULL, NULL, NULL, v_row_type, DBMS_TYPES.TYPECODE_OBJECT, 0);
        p_return_type.endcreate;
    
        RETURN odciconst.success;
    
    END;
    
    STATIC FUNCTION odcitableprepare (
        p_context OUT t_json_query,
        p_table_function_info IN sys.odcitabfuncinfo,
        p_query IN VARCHAR2,
        p_variable_1 IN VARCHAR2 := NULL,
        p_variable_2 IN VARCHAR2 := NULL,
        p_variable_3 IN VARCHAR2 := NULL,
        p_variable_4 IN VARCHAR2 := NULL,
        p_variable_5 IN VARCHAR2 := NULL,
        p_variable_6 IN VARCHAR2 := NULL,
        p_variable_7 IN VARCHAR2 := NULL,
        p_variable_8 IN VARCHAR2 := NULL,
        p_variable_9 IN VARCHAR2 := NULL,
        p_variable_10 IN VARCHAR2 := NULL,
        p_variable_11 IN VARCHAR2 := NULL,
        p_variable_12 IN VARCHAR2 := NULL,
        p_variable_13 IN VARCHAR2 := NULL,
        p_variable_14 IN VARCHAR2 := NULL,
        p_variable_15 IN VARCHAR2 := NULL,
        p_variable_16 IN VARCHAR2 := NULL,
        p_variable_17 IN VARCHAR2 := NULL,
        p_variable_18 IN VARCHAR2 := NULL,
        p_variable_19 IN VARCHAR2 := NULL,
        p_variable_20 IN VARCHAR2 := NULL
    ) RETURN PLS_INTEGER IS
    
        v_return NUMBER;
        v_precision PLS_INTEGER;
        v_scale PLS_INTEGER;
        v_length PLS_INTEGER;
        v_cs_id PLS_INTEGER;
        v_cs_frm PLS_INTEGER;
        v_row_type ANYTYPE;    
        v_name VARCHAR2(30);
    
    BEGIN
    
        v_return := p_table_function_info.rettype.getattreleminfo(
            1
           ,v_precision
           ,v_scale
           ,v_length
           ,v_cs_id
           ,v_cs_frm
           ,v_row_type
           ,v_name
        );
    
        p_context := t_json_query(v_row_type);
    
        RETURN odciconst.success;
    
    END;
             
    MEMBER FUNCTION fetch_row(
        self IN OUT NOCOPY t_json_query,
        p_row IN OUT NOCOPY t_varchars
    ) RETURN BOOLEAN IS
        
        v_column_values DBMS_SQL.VARCHAR2_TABLE;
        
    BEGIN
    
        IF fetched_row_count IS NULL OR fetched_row_count = piped_row_count THEN
            
            IF fetched_row_count IS NOT NULL AND piped_row_count < json_store.c_query_row_buffer_size THEN
                RETURN FALSE;
            END IF;
            
            FOR v_i IN 1..column_count LOOP
                DBMS_SQL.DEFINE_ARRAY(cursor_id, v_i, v_column_values, json_store.c_query_row_buffer_size, 1);
            END LOOP;
            
            piped_row_count := 0;
            fetched_row_count := DBMS_SQL.FETCH_ROWS(cursor_id);
                
            IF fetched_row_count = 0 THEN
                RETURN FALSE;
            END IF;
                
            FOR v_i IN 1..column_count LOOP
                
                DBMS_SQL.COLUMN_VALUE(cursor_id, v_i, v_column_values);
                    
                FOR v_j IN 1..fetched_row_count LOOP
                    row_buffer((v_i - 1) * json_store.c_query_row_buffer_size + v_j) := v_column_values(v_j);
                END LOOP;
                    
            END LOOP;   
                
        END IF;
        
        piped_row_count := piped_row_count + 1;
        
        FOR v_i IN 1..LEAST(column_count, p_row.COUNT) LOOP
            p_row(v_i) := row_buffer((v_i - 1) * json_store.c_query_row_buffer_size + piped_row_count);
        END LOOP;
        
        
        
        RETURN TRUE;
    
    END;
    
    
    MEMBER FUNCTION odcitablefetch (
        self IN OUT NOCOPY t_json_query,
        p_row_count IN NUMBER,
        p_dataset OUT ANYDATASET
    ) RETURN PLS_INTEGER IS
        
        v_row t_varchars;
        
    BEGIN
    
        --v_row := t_varchars('Sergejs', 'Vinniks');
        v_row := t_varchars();
        v_row.extend(column_count);
        
        FOR v_i IN 1..p_row_count LOOP
        
           /* if a = 0 then
                exit;
            end if;
            
        IF p_dataset IS NULL THEN
                    ANYDATASET.begincreate(DBMS_TYPES.TYPECODE_OBJECT, row_type, p_dataset);
                END IF;         
            
                p_dataset.addinstance;          
                p_dataset.piecewise;
                
                FOR v_i IN 1..column_count LOOP
                    p_dataset.setvarchar2(v_row(v_i), v_i = column_count);
                END LOOP;
                
            a := a -1;*/
        
        
            IF fetch_row(v_row) THEN
            
                IF p_dataset IS NULL THEN
                    ANYDATASET.begincreate(DBMS_TYPES.TYPECODE_OBJECT, row_type, p_dataset);
                END IF;         
            
                p_dataset.addinstance;          
                p_dataset.piecewise;
                
                FOR v_i IN 1..column_count LOOP
                    p_dataset.setvarchar2(v_row(v_i), v_i = column_count);
                END LOOP;
            
            ELSE
            
                EXIT;
            
            END IF;
        
        END LOOP;
        
        IF p_dataset IS NOT NULL THEN
        
            p_dataset.endcreate;
            
        ELSE 
        
            DBMS_SQL.CLOSE_CURSOR(cursor_id);
            
        END IF;
        
        RETURN odciconst.success;
    
    END;
    
    MEMBER FUNCTION odcitableclose (
        self IN t_json_query
    ) 
    RETURN PLS_INTEGER IS
    
        v_cursor_id INTEGER;
    
    BEGIN

        IF cursor_id IS NOT NULL THEN
            v_cursor_id := cursor_id;
            DBMS_SQL.CLOSE_CURSOR(v_cursor_id);
        END IF;

        RETURN odciconst.success;
    
    END;
    

END;
