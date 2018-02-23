CREATE OR REPLACE TYPE t_json_query AUTHID CURRENT_USER AS OBJECT (
    
    row_type ANYTYPE
   ,column_count NUMBER
   ,cursor_id INTEGER
   ,row_buffer t_varchars
   ,fetched_row_count NUMBER
   ,piped_row_count NUMBER

   ,CONSTRUCTOR FUNCTION t_json_query (
        p_row_type ANYTYPE
    ) RETURN SELF AS RESULT
    
   ,STATIC FUNCTION odcitablestart (
        p_context IN OUT t_json_query
       ,p_query IN VARCHAR2
       ,p_variable_1 IN VARCHAR2 := NULL
       ,p_variable_2 IN VARCHAR2 := NULL
       ,p_variable_3 IN VARCHAR2 := NULL                                        
    ) RETURN PLS_INTEGER
    
   ,STATIC FUNCTION odcitableprepare (
        p_context OUT t_json_query
       ,p_table_function_info IN sys.odcitabfuncinfo
       ,p_query IN VARCHAR2
       ,p_variable_1 IN VARCHAR2 := NULL
       ,p_variable_2 IN VARCHAR2 := NULL
       ,p_variable_3 IN VARCHAR2 := NULL
    ) RETURN PLS_INTEGER
    
   ,STATIC FUNCTION odcitabledescribe (
        p_return_type OUT ANYTYPE
       ,p_query IN VARCHAR2
       ,p_variable_1 IN VARCHAR2 := NULL
       ,p_variable_2 IN VARCHAR2 := NULL
       ,p_variable_3 IN VARCHAR2 := NULL
    ) RETURN PLS_INTEGER
             
   ,MEMBER FUNCTION fetch_row (
        self IN OUT NOCOPY t_json_query
       ,p_row IN OUT NOCOPY t_varchars
    ) RETURN BOOLEAN 
    
   ,MEMBER FUNCTION odcitablefetch (
        self IN OUT NOCOPY t_json_query,
        p_row_count IN NUMBER,
        p_dataset OUT ANYDATASET
    ) RETURN PLS_INTEGER
    
   ,MEMBER FUNCTION odcitableclose(
        self IN t_json_query
    ) RETURN PLS_INTEGER
    
)    
/