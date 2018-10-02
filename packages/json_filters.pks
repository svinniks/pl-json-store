CREATE OR REPLACE PACKAGE json_filters IS

    SUBTYPE STRING IS
        VARCHAR2(32767);

    TYPE t_filter_criteria IS
        RECORD (
            path STRING,
            depth NUMBER,
            value VARCHAR2(4000)
        );
        
    TYPE t_filter_criterias IS
        TABLE OF t_filter_criteria;
        
    TYPE t_json_filter IS
        RECORD (
            base_value_id NUMBER,
            criterias t_filter_criterias,
            state VARCHAR2(100)
        );
        
    TYPE t_json_filters IS
        TABLE OF t_json_filter
        INDEX BY PLS_INTEGER;
        
    TYPE t_integers IS
        TABLE OF PLS_INTEGER;    
    
    FUNCTION create_filter (
        p_base_value_id IN NUMBER
    )
    RETURN PLS_INTEGER;
    
    PROCEDURE path (
        p_filter_id IN PLS_INTEGER,
        p_path IN VARCHAR2
    );
    
    PROCEDURE value (
        p_filter_id IN PLS_INTEGER,
        p_value IN VARCHAR2
    );
    
    FUNCTION criterias (
        p_filter_id IN PLS_INTEGER
    )
    RETURN t_filter_criterias PIPELINED;
    
    FUNCTION execute (
        p_filter_id IN PLS_INTEGER
    )
    RETURN t_json_properties;
    
END;
