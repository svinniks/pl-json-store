CREATE OR REPLACE PACKAGE json_writer IS

    PROCEDURE write_json (
        p_parent_id IN NUMBER,
        p_name IN VARCHAR2,
        p_content_parse_events IN json_parser.t_parse_events,
        p_first_event_i IN PLS_INTEGER
    );

    FUNCTION write_json (
        p_parent_id IN NUMBER,
        p_name IN VARCHAR2,
        p_content_parse_events IN json_parser.t_parse_events,
        p_first_event_i IN PLS_INTEGER
    ) 
    RETURN NUMBER;
    
    PROCEDURE flush;

END;