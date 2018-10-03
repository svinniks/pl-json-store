CREATE OR REPLACE TYPE BODY t_json_filter IS 

    CONSTRUCTOR FUNCTION t_json_filter (
        p_base_value_id IN NUMBER
    )
    RETURN self AS RESULT IS
    BEGIN
        id := json_filters.create_filter(p_base_value_id);
        RETURN;
    END;
   
    MEMBER FUNCTION path (
        p_path IN VARCHAR2
    )
    RETURN t_json_filter IS
    BEGIN
        json_filters.path(id, p_path);
        RETURN self;
    END;
    
    MEMBER PROCEDURE path (
        self IN t_json_filter,
        p_path IN VARCHAR2
    ) IS
    BEGIN
        json_filters.path(id, p_path);
    END;
    
    MEMBER FUNCTION value (
        p_value IN VARCHAR2
    )
    RETURN t_json_filter IS
    BEGIN
        json_filters.value(id, p_value);
        RETURN self;
    END;
    
    MEMBER PROCEDURE value (
        self IN t_json_filter,
        p_value IN VARCHAR2
    ) IS
    BEGIN
        json_filters.value(id, p_value);
    END;
    
    MEMBER FUNCTION value (
        p_value IN NUMBER
    )
    RETURN t_json_filter IS
    BEGIN
        json_filters.value(id, p_value);
        RETURN self;
    END;
    
    MEMBER PROCEDURE value (
        self IN t_json_filter,
        p_value IN NUMBER
    ) IS
    BEGIN
        json_filters.value(id, p_value);
    END;
    
    MEMBER FUNCTION value (
        p_value IN DATE
    )
    RETURN t_json_filter IS
    BEGIN
        json_filters.value(id, p_value);
        RETURN self;
    END;
    
    MEMBER PROCEDURE value (
        self IN t_json_filter,
        p_value IN DATE
    ) IS
    BEGIN
        json_filters.value(id, p_value);
    END;
    
    MEMBER FUNCTION value (
        p_value IN BOOLEAN
    )
    RETURN t_json_filter IS
    BEGIN
        json_filters.value(id, p_value);
        RETURN self;
    END;
    
    MEMBER PROCEDURE value (
        self IN t_json_filter,
        p_value IN BOOLEAN
    ) IS
    BEGIN
        json_filters.value(id, p_value);
    END;
    
    MEMBER FUNCTION execute
    RETURN t_json_properties IS
    BEGIN
        RETURN json_filters.execute(id);
    END;
    
END;