CREATE OR REPLACE PACKAGE BODY json_parser IS

    TYPE rt_parse_context IS RECORD
        (state VARCHAR2(30));

    PROCEDURE raise_error
        (p_message IN VARCHAR2) IS
    BEGIN
        raise_application_error(-20000, p_message);
    END;

    PROCEDURE parse
        (p_buffer IN VARCHAR2
        ,p_context IN OUT NOCOPY rt_parse_context
        ,p_events IN OUT NOCOPY tt_parse_events) IS
        
        v_char CHAR;
        
        PROCEDURE add_event
            (p_name IN VARCHAR2
            ,p_value IN VARCHAR2) IS
        BEGIN
            p_events.EXTEND(1);
            p_events(p_events.COUNT).name := p_name;
            p_events(p_events.COUNT).value := p_value;
        END;
        
        FUNCTION space
        RETURN BOOLEAN IS
        BEGIN
            RETURN v_char IN (' ', CHR(10), CHR(13));
        END;
        
        PROCEDURE lfValue IS
        BEGIN
        
            IF v_char = '"' THEN
            
                p_context.state := 'rString';
                
            ELSIF v_char = '{' THEN
                
                add_event('START_OBJECT');
                p_context.state := 'lfProperty';
                
            ELSIF v_char = '[' THEN
            
                add_event('START_ARRAY');
                
            ELSIF NOT space THEN
            
                raise_error('Unexpected character ' || v_char || '!');
                
            END IF;
        
        END;
        
        PROCEDURE rString IS
        BEGIN
        END;
        
    BEGIN
    
        p_events := tt_parse_events();
        
        FOR v_i IN 1..NVL(LENGTH(p_buffer), 0) LOOP
            
            v_char := SUBSTR(p_buffer, v_i, 1);
            
            CASE p_context.state
                WHEN 'lfValue' THEN lfValue;
                WHEN 'rString' THEN rString;
                WHEN 'lfProperty' THEN lfProperty;
            END CASE;
            
        END LOOP;
    
    END;

    FUNCTION parse
        (p_content IN CLOB)
    RETURN tt_parse_events PIPELINED IS
    BEGIN
    
        RETURN;
    
    END;
    
    FUNCTION parse
        (p_content IN VARCHAR2)
    RETURN tt_parse_events PIPELINED IS
    
        r_context rt_parse_context;
        t_events tt_parse_events;
    
    BEGIN
    
        r_context.state := 'lfValue';
        parse(p_content, r_context, t_events);
        
        FOR v_i IN 1..t_events.COUNT LOOP
            PIPE ROW(t_events(v_i));
        END LOOP;
    
        RETURN;
    
    END;

END;
/
