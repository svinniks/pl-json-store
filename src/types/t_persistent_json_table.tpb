CREATE OR REPLACE TYPE BODY t_persistent_json_table IS

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
    
    CONSTRUCTOR FUNCTION t_persistent_json_table (
        p_row_type ANYTYPE
    ) 
    RETURN SELF AS RESULT IS
    BEGIN
    
        row_type := p_row_type;
        
        RETURN;
    
    END;
    
    STATIC FUNCTION odcitablestart ( 
        p_context IN OUT t_persistent_json_table,
        p_query IN VARCHAR2,
        p_bind IN bind := NULL
    ) 
    RETURN PLS_INTEGER IS
    BEGIN
        
        persistent_json_store.prepare_table_query (
            NULL,
            p_query,
            p_bind,
            p_context.cursor_id,
            p_context.column_count
        );
        
        p_context.fetched_row_count := NULL;
        p_context.piped_row_count := 0;
        
        p_context.row_buffer := t_varchars();
        p_context.row_buffer.EXTEND(p_context.column_count * persistent_json_store.c_ROW_BUFFER_SIZE);
        
        RETURN odciconst.success;
    
    END;
    
    STATIC FUNCTION odcitableprepare (
        p_context OUT t_persistent_json_table,
        p_table_function_info IN sys.odcitabfuncinfo,
        p_query IN VARCHAR2,
        p_bind IN bind := NULL
    ) 
    RETURN PLS_INTEGER IS
    BEGIN
    
        p_context := t_persistent_json_table(t_json_table.get_row_type(p_table_function_info));
    
        RETURN odciconst.success;
    
    END;
             
    MEMBER FUNCTION fetch_row(
        self IN OUT NOCOPY t_persistent_json_table,
        p_row IN OUT NOCOPY t_varchars
    ) 
    RETURN BOOLEAN IS
        
        v_column_values DBMS_SQL.VARCHAR2_TABLE;
        
    BEGIN
    
        IF fetched_row_count IS NULL OR fetched_row_count = piped_row_count THEN
            
            IF fetched_row_count IS NOT NULL 
               AND piped_row_count < persistent_json_store.c_ROW_BUFFER_SIZE 
            THEN
                RETURN FALSE;
            END IF;
            
            piped_row_count := 0;
            
            persistent_json_store.fetch_table_rows(cursor_id, column_count, fetched_row_count, row_buffer);
                
            IF fetched_row_count = 0 THEN
                RETURN FALSE;
            END IF;
                
        END IF;
        
        piped_row_count := piped_row_count + 1;
        
        FOR v_i IN 1..LEAST(column_count, p_row.COUNT) LOOP
            p_row(v_i) := row_buffer((v_i - 1) * persistent_json_store.c_ROW_BUFFER_SIZE + piped_row_count);
        END LOOP;
        
        RETURN TRUE;
    
    END;
    
    OVERRIDING MEMBER FUNCTION odcitablefetch (
        self IN OUT NOCOPY t_persistent_json_table,
        p_row_count IN NUMBER,
        p_dataset OUT ANYDATASET
    ) 
    RETURN PLS_INTEGER IS
        
        v_row t_varchars;
        
    BEGIN
    
        v_row := t_varchars();
        v_row.extend(column_count);
        
        FOR v_i IN 1..p_row_count LOOP
        
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
    
    OVERRIDING MEMBER FUNCTION odcitableclose (
        self IN t_persistent_json_table
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
