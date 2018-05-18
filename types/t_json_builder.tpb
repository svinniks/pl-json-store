CREATE OR REPLACE TYPE BODY t_json_builder IS
    
    CONSTRUCTOR FUNCTION t_json_builder
    RETURN self AS RESULT IS
    BEGIN
    
        id := json_builder.create_builder;
    
        RETURN;
    
    END;
    
    MEMBER FUNCTION value (
        p_value IN VARCHAR2
    )
    RETURN t_json_builder IS
    BEGIN
    
        json_builder.value(id, p_value);
        
        RETURN self;
    
    END;
    
    MEMBER PROCEDURE value (
        self IN t_json_builder,
        p_value IN VARCHAR2
    ) IS
    BEGIN
    
        json_builder.value(id, p_value);
    
    END;
    
    MEMBER FUNCTION value (
        p_value IN DATE
    )
    RETURN t_json_builder IS
    BEGIN
    
        json_builder.value(id, p_value);
        
        RETURN self;
    
    END;
    
    MEMBER PROCEDURE value (
        self IN t_json_builder,
        p_value IN DATE
    ) IS
    BEGIN
    
        json_builder.value(id, p_value);
    
    END;
    
    MEMBER FUNCTION value (
        p_value IN NUMBER
    )
    RETURN t_json_builder IS
    BEGIN
    
        json_builder.value(id, p_value);
        
        RETURN self;
    
    END;
    
    MEMBER PROCEDURE value (
        self IN t_json_builder,
        p_value IN NUMBER
    ) IS
    BEGIN
    
        json_builder.value(id, p_value);
        
    END;
    
    MEMBER FUNCTION value (
        p_value IN BOOLEAN
    )
    RETURN t_json_builder IS
    BEGIN
    
        json_builder.value(id, p_value);
        
        RETURN self;
    
    END;
    
    MEMBER PROCEDURE value (
        self IN t_json_builder,
        p_value IN BOOLEAN
    ) IS
    BEGIN
    
        json_builder.value(id, p_value);
    
    END;
    
    MEMBER FUNCTION null_value
    RETURN t_json_builder IS
    BEGIN
    
        json_builder.null_value(id);
        
        RETURN self;
    
    END;
    
    MEMBER PROCEDURE null_value (
        self IN t_json_builder
    ) IS
    BEGIN
    
        json_builder.null_value(id);
        
    END;
    
    MEMBER FUNCTION object
    RETURN t_json_builder IS
    BEGIN
    
        json_builder.object(id);
        
        RETURN self;
    
    END;
    
    MEMBER PROCEDURE object (
        self IN t_json_builder
    ) IS
    BEGIN
    
        json_builder.object(id);
    
    END;
    
    MEMBER FUNCTION name (
        p_name IN VARCHAR2
    )
    RETURN t_json_builder IS
    BEGIN
    
        json_builder.name(id, p_name);
        
        RETURN self;
    
    END;
    
    MEMBER PROCEDURE name (
        self IN t_json_builder,
        p_name IN VARCHAR2
    ) IS
    BEGIN
    
        json_builder.name(id, p_name);
    
    END;
    
    MEMBER FUNCTION array
    RETURN t_json_builder IS
    BEGIN
    
        json_builder.array(id);
        
        RETURN self;
    
    END;
    
    MEMBER PROCEDURE array (
        self IN t_json_builder
    ) IS    
    BEGIN
    
        json_builder.array(id);
    
    END;

    
    MEMBER FUNCTION close
    RETURN t_json_builder IS
    BEGIN
    
        json_builder.close(id);
        
        RETURN self;
    
    END;
    
    MEMBER PROCEDURE close (
        self IN t_json_builder
    ) IS
    BEGIN
    
        json_builder.close(id);
    
    END;
    
    MEMBER FUNCTION build_json
    RETURN VARCHAR2 IS
    BEGIN
    
        RETURN json_builder.build_json(id);
    
    END;
    
    MEMBER FUNCTION build_json_clob
    RETURN CLOB IS
    BEGIN
    
        RETURN json_builder.build_json_clob(id);
    
    END;
    
END;