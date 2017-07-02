CREATE OR REPLACE PACKAGE json_documents IS

    TYPE t_path_element IS RECORD
        (type CHAR
        ,value VARCHAR2(4000));
        
    TYPE t_path IS TABLE OF t_path_element;
    
    TYPE t_property IS RECORD
        (parent_id NUMBER
        ,parent_type CHAR
        ,property_id NUMBER
        ,property_type CHAR);
        
    TYPE t_properties IS TABLE OF t_property;

    FUNCTION parse_path
        (p_path IN VARCHAR2)
    RETURN t_path;
    
    PROCEDURE request_properties
        (p_path IN VARCHAR2
        ,p_properties OUT SYS_REFCURSOR);
        
    FUNCTION request_properties
        (p_path IN VARCHAR2)
    RETURN t_properties PIPELINED;
    
    FUNCTION set_json
        (p_path IN VARCHAR2
        ,p_content IN VARCHAR2)
    RETURN NUMBER;
    
    FUNCTION set_json
        (p_content IN VARCHAR2)
    RETURN NUMBER;

END;
