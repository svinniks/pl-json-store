CREATE OR REPLACE TYPE BODY t_json_builder IS
    
    CONSTRUCTOR FUNCTION t_json_builder (
        p_serialize_nulls IN BOOLEAN := TRUE
    )
    RETURN self AS RESULT IS
    BEGIN
    
        id := json_builders.create_builder(
            NVL(p_serialize_nulls, FALSE)
        );
    
        RETURN;
    
    END;
    
    MEMBER FUNCTION value (
        p_value IN VARCHAR2
    )
    RETURN t_json_builder IS
    BEGIN
    
        json_builders.value(id, p_value);
        
        RETURN self;
    
    END;
    
    MEMBER PROCEDURE value (
        self IN t_json_builder,
        p_value IN VARCHAR2
    ) IS
    BEGIN
    
        json_builders.value(id, p_value);
    
    END;
    
    MEMBER FUNCTION value (
        p_value IN DATE
    )
    RETURN t_json_builder IS
    BEGIN
    
        json_builders.value(id, p_value);
        
        RETURN self;
    
    END;
    
    MEMBER PROCEDURE value (
        self IN t_json_builder,
        p_value IN DATE
    ) IS
    BEGIN
    
        json_builders.value(id, p_value);
    
    END;
    
    MEMBER FUNCTION value (
        p_value IN NUMBER
    )
    RETURN t_json_builder IS
    BEGIN
    
        json_builders.value(id, p_value);
        
        RETURN self;
    
    END;
    
    MEMBER PROCEDURE value (
        self IN t_json_builder,
        p_value IN NUMBER
    ) IS
    BEGIN
    
        json_builders.value(id, p_value);
        
    END;
    
    MEMBER FUNCTION value (
        p_value IN BOOLEAN
    )
    RETURN t_json_builder IS
    BEGIN
    
        json_builders.value(id, p_value);
        
        RETURN self;
    
    END;
    
    MEMBER PROCEDURE value (
        self IN t_json_builder,
        p_value IN BOOLEAN
    ) IS
    BEGIN
    
        json_builders.value(id, p_value);
    
    END;
    
    MEMBER FUNCTION null_value
    RETURN t_json_builder IS
    BEGIN
    
        json_builders.null_value(id);
        
        RETURN self;
    
    END;
    
    MEMBER PROCEDURE null_value (
        self IN t_json_builder
    ) IS
    BEGIN
    
        json_builders.null_value(id);
        
    END;
    
    MEMBER FUNCTION json (
        p_content IN VARCHAR2
    )
    RETURN t_json_builder IS
    BEGIN
    
        json_builders.json(id, p_content);
    
        RETURN self;
    
    END;
    
    MEMBER PROCEDURE json (
        self IN t_json_builder,
        p_content IN VARCHAR2
    ) IS
    BEGIN
    
        json_builders.json(id, p_content);
    
    END;
    
    MEMBER FUNCTION json (
        p_content IN CLOB
    )
    RETURN t_json_builder IS
    BEGIN
    
        json_builders.json(id, p_content);
    
        RETURN self;
    
    END;
    
    MEMBER PROCEDURE json (
        self IN t_json_builder,
        p_content IN CLOB
    ) IS
    BEGIN
    
        json_builders.json(id, p_content);
    
    END;
    
    MEMBER FUNCTION json (
        p_builder IN t_json_builder
    )
    RETURN t_json_builder IS
    BEGIN
    
        json_builders.json(id, p_builder.id);
    
        RETURN self;
    
    END;
    
    MEMBER PROCEDURE json (
        self IN t_json_builder,
        p_builder IN t_json_builder
    ) IS
    BEGIN
    
        json_builders.json(id, p_builder.id);
    
    END;
    
    MEMBER FUNCTION object
    RETURN t_json_builder IS
    BEGIN
    
        json_builders.object(id);
        
        RETURN self;
    
    END;
    
    MEMBER PROCEDURE object (
        self IN t_json_builder
    ) IS
    BEGIN
    
        json_builders.object(id);
    
    END;
    
    MEMBER FUNCTION name (
        p_name IN VARCHAR2
    )
    RETURN t_json_builder IS
    BEGIN
    
        json_builders.name(id, p_name);
        
        RETURN self;
    
    END;
    
    MEMBER PROCEDURE name (
        self IN t_json_builder,
        p_name IN VARCHAR2
    ) IS
    BEGIN
    
        json_builders.name(id, p_name);
    
    END;
    
    MEMBER FUNCTION array
    RETURN t_json_builder IS
    BEGIN
    
        json_builders.array(id);
        
        RETURN self;
    
    END;
    
    MEMBER PROCEDURE array (
        self IN t_json_builder
    ) IS    
    BEGIN
    
        json_builders.array(id);
    
    END;

    
    MEMBER FUNCTION close
    RETURN t_json_builder IS
    BEGIN
    
        json_builders.close(id);
        
        RETURN self;
    
    END;
    
    MEMBER PROCEDURE close (
        self IN t_json_builder
    ) IS
    BEGIN
    
        json_builders.close(id);
    
    END;
    
    MEMBER FUNCTION build_json (
        p_serialize_nulls IN BOOLEAN := TRUE
    )
    RETURN VARCHAR2 IS
    BEGIN
    
        RETURN json_builders.build_json(id, NVL(p_serialize_nulls, FALSE));
    
    END;
    
    MEMBER FUNCTION build_json_clob (
        p_serialize_nulls IN BOOLEAN := TRUE
    )
    RETURN CLOB IS
    BEGIN
    
        RETURN json_builders.build_json_clob(id, NVL(p_serialize_nulls, FALSE));
    
    END;
    
END;