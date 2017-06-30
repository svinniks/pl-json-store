CREATE OR REPLACE PACKAGE json_parser IS

    TYPE t_parse_event IS RECORD 
        (name VARCHAR2(30)
        ,value VARCHAR2(4000));
       
    TYPE t_parse_events IS TABLE OF t_parse_event;
    
    FUNCTION parse
        (p_content IN VARCHAR2)
    RETURN t_parse_events;
    
    FUNCTION parse
        (p_content IN CLOB)
    RETURN t_parse_events;
    
END;
