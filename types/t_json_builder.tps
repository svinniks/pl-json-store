CREATE OR REPLACE TYPE t_json_builder IS OBJECT (

    id NUMBER,
    
    CONSTRUCTOR FUNCTION t_json_builder
    RETURN self AS RESULT,
    
    MEMBER FUNCTION value (
        p_value IN VARCHAR2
    )
    RETURN t_json_builder,
    
    MEMBER FUNCTION value (
        p_value IN DATE
    )
    RETURN t_json_builder,
    
    MEMBER FUNCTION value (
        p_value IN NUMBER
    )
    RETURN t_json_builder,
    
    MEMBER FUNCTION value (
        p_value IN BOOLEAN
    )
    RETURN t_json_builder,
    
    MEMBER FUNCTION object
    RETURN t_json_builder,
    
    MEMBER FUNCTION name (
        p_name IN VARCHAR2
    )
    RETURN t_json_builder,
    
    MEMBER FUNCTION array
    RETURN t_json_builder,
    
    MEMBER FUNCTION close
    RETURN t_json_builder,
    
    MEMBER FUNCTION build_json
    RETURN VARCHAR2,
    
    MEMBER FUNCTION build_json_clob
    RETURN CLOB
    
);