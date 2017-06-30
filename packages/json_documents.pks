CREATE OR REPLACE PACKAGE json_documents IS

    c_root CONSTANT PLS_INTEGER := 1;
    c_id CONSTANT PLS_INTEGER := 2;
    c_name CONSTANT PLS_INTEGER := 3;

    TYPE t_path_element IS RECORD
        (type PLS_INTEGER
        ,value VARCHAR2(4000));
        
    TYPE t_path IS TABLE OF t_path_element;

    FUNCTION parse_path
        (p_path_string IN VARCHAR2)
    RETURN t_path;
    
    FUNCTION set_json
        (p_path IN VARCHAR2
        ,p_content IN VARCHAR2)
    RETURN NUMBER;
    
    FUNCTION set_json
        (p_content IN VARCHAR2)
    RETURN NUMBER;

END;
