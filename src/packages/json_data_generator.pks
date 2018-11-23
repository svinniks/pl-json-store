CREATE OR REPLACE PACKAGE json_data_generator IS
     
    FUNCTION resolve_data_type (
        p_data_type_name IN VARCHAR
    )
    RETURN VARCHAR2;

    FUNCTION get_type_register_path
    RETURN VARCHAR2 DETERMINISTIC;
    
    PROCEDURE init_data_type_register;
    
    FUNCTION register_data_type (
        p_data_type_name IN VARCHAR2,
        p_ignore_unknown IN BOOLEAN := FALSE
    )
    RETURN VARCHAR2;
    
    PROCEDURE register_data_type (
        p_data_type_name IN VARCHAR2,
        p_ignore_unknown IN BOOLEAN := FALSE
    );
    
    PROCEDURE generate;

END;