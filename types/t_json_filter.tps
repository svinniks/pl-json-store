CREATE OR REPLACE TYPE t_json_filter IS OBJECT (

    id NUMBER,
    
    CONSTRUCTOR FUNCTION t_json_filter (
        p_base_value_id IN NUMBER
    )
    RETURN self AS RESULT,
   
    MEMBER FUNCTION path (
        p_path IN VARCHAR2
    )
    RETURN t_json_filter,
    
    MEMBER PROCEDURE path (
        self IN t_json_filter,
        p_path IN VARCHAR2
    ),
    
    MEMBER FUNCTION value (
        p_value IN VARCHAR2
    )
    RETURN t_json_filter,
    
    MEMBER PROCEDURE value (
        self IN t_json_filter,
        p_value IN VARCHAR2
    ),
    
    MEMBER FUNCTION execute
    RETURN t_json_properties
    
)