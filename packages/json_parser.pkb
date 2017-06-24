CREATE OR REPLACE PACKAGE BODY json_parser IS

    FUNCTION parse
        (p_content IN CLOB)
    RETURN tt_parse_events PIPELINED IS
    BEGIN
    
        RETURN;
    
    END;
    
    FUNCTION parse
        (p_content IN VARCHAR2)
    RETURN tt_parse_events PIPELINED IS
    BEGIN
    
        RETURN;
    
    END;

END;
/
