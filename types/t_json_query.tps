CREATE OR REPLACE TYPE t_json_query AUTHID CURRENT_USER AS OBJECT (
    
    row_type ANYTYPE,
    column_count NUMBER,
    cursor_id INTEGER

   ,STATIC FUNCTION odcitablestart (
        p_context IN OUT t_json_query
       ,p_query IN VARCHAR2                                        
    ) RETURN PLS_INTEGER
    
   ,STATIC FUNCTION odcitableprepare (
        p_context OUT t_json_query
       ,p_table_function_info IN sys.odcitabfuncinfo
       ,p_query IN VARCHAR2
    ) RETURN PLS_INTEGER
    
   ,STATIC FUNCTION odcitabledescribe(
        p_return_type OUT ANYTYPE
       ,p_query IN VARCHAR2
    ) RETURN PLS_INTEGER
             
   ,MEMBER FUNCTION odcitablefetch (
        self IN OUT t_json_query,
        p_row_count IN NUMBER,
        p_dataset OUT ANYDATASET
    ) RETURN PLS_INTEGER
    
   ,MEMBER FUNCTION odcitableclose(
        self IN t_json_query
    ) RETURN PLS_INTEGER
    
)    
/