CREATE OR REPLACE PACKAGE json_parser IS

    TYPE rt_parse_event IS RECORD 
        (name VARCHAR2(30)
        ,value VARCHAR2(4000));
       
    TYPE tt_parse_events IS TABLE OF rt_parse_event;
    
    FUNCTION parse
        (p_content IN VARCHAR2)
    RETURN tt_parse_events PIPELINED;
    
    FUNCTION parse
        (p_content IN CLOB)
    RETURN tt_parse_events PIPELINED;

END;
/
