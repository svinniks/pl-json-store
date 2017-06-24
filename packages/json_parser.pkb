CREATE OR REPLACE PACKAGE BODY json_parser IS

    TYPE rt_parse_context IS RECORD
        (state VARCHAR2(30)
        ,value VARCHAR2(4000));

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
                p_context.value := NULL;
                
            ELSIF INSTR('123456789', v_char) > 0 THEN
            
                p_context.state := 'rInteger';
                p_context.value := v_char;
                
            ELSIF v_char = '0' THEN
            
                p_context.state := 'lfDecimalDot';
                p_context.value := '0';
                
            ELSIF v_char = '-' THEN
            
                p_context.state := 'lfInteger';
                p_context.value := '-';
                
            ELSIF NOT space THEN
            
                raise_error('Unexpected character ' || v_char || '!');
                
            END IF;
        
        END;
        
        PROCEDURE rString IS
        BEGIN
        
            IF v_char = '"' THEN
            
                add_event('STRING', p_context.value);
                p_context.state := 'lfEnd';
            
            ELSIF v_char = '\' THEN
            
                p_context.state := 'rEscaped';
                
            ELSE
            
                p_context.value := p_context.value || v_char;
                
            END IF;
        
        END;
        
        PROCEDURE rEscaped IS
        BEGIN
        
            CASE v_char
                WHEN 'n' THEN
                    p_context.value := p_context.value || CHR(10);
                WHEN 'f' THEN
                    p_context.value := p_context.value || CHR(12);
                WHEN 't' THEN
                    p_context.value := p_context.value || CHR(9);
                WHEN 'r' THEN
                    p_context.value := p_context.value || CHR(13);
                WHEN 't' THEN
                    p_context.value := p_context.value || CHR(9);
                WHEN 'b' THEN
                    p_context.value := p_context.value || CHR(8);
                ELSE
                    p_context.value := p_context.value || v_char;
            END CASE;
        
            p_context.state := 'rString';
        
        END;
        
        PROCEDURE lfInteger IS
        BEGIN
        
            IF INSTR('123456789', v_char) > 0 THEN
            
                p_context.state := 'rInteger';
                p_context.value := p_context.value || v_char;
                
            ELSIF v_char = '0' THEN
            
                p_context.state := 'lfDecimalDot';
                p_context.value := p_context.value || '0';
                
            ELSIF NOT space THEN
            
                raise_error('Unexpected character ' || v_char || '!');
            
            END IF;
        
        END;
        
        PROCEDURE rInteger IS
        BEGIN
        
            IF INSTR('1234567890', v_char) > 0 THEN
            
                p_context.value := p_context.value || v_char;
                
            ELSIF v_char = '.' THEN
            
                p_context.value := p_context.value || '.';
                p_context.state := 'lfDecimal';
                
            ELSIF space THEN
            
                add_event('NUMBER', p_context.value);
                p_context.state := 'lfEnd';
                
            ELSE
            
                raise_error('Unexpected character ' || v_char || '!');
                
            END IF;
        
        END;
        
        PROCEDURE lfDecimalDot IS
        BEGIN
        
            IF v_char = '.' THEN
            
                p_context.value := p_context.value || '.';
                p_context.state := 'lfDecimal';
                
            ELSIF space THEN
            
                add_event('NUMBER', p_context.value);
                p_context.state := 'lfEnd';
                
            ELSE
            
                raise_error('Unexpected character ' || v_char || '!');
            
            END IF;
        
        END;
        
        PROCEDURE lfDecimal IS
        BEGIN
        
            IF INSTR('1234567890', v_char) > 0 THEN
            
                p_context.value := p_context.value || v_char;
                p_context.state := 'rDecimal';
                
            ELSE
            
                raise_error('Unexpected characted ' || v_char || '!');
            
            END IF;
        
        END;
        
        PROCEDURE rDecimal IS
        BEGIN
        
            IF INSTR('1234567890', v_char) > 0 THEN
            
                p_context.value := p_context.value || v_char;
                
            ELSIF space THEN
            
                add_event('NUMBER', p_context.value);
                p_context.state := 'lfEnd';
                
            ELSE
            
                raise_error('Unexpected characted ' || v_char || '!');
            
            END IF;
        
        END;
        
        PROCEDURE lfEnd IS
        BEGIN
        
            IF NOT space THEN
                raise_error('Unexpected character ' || v_char || '!');
            END IF;
        
        END;
        
    BEGIN
    
        p_events := tt_parse_events();
        
        FOR v_i IN 1..NVL(LENGTH(p_buffer), 0) LOOP
            
            v_char := SUBSTR(p_buffer, v_i, 1);
            
            CASE p_context.state
                WHEN 'lfValue' THEN lfValue;
                WHEN 'rString' THEN rString;
                WHEN 'rEscaped' THEN rEscaped;
                WHEN 'lfInteger' THEN lfInteger;
                WHEN 'rInteger' THEN rInteger;
                WHEN 'lfDecimalDot' THEN lfDecimalDot;
                WHEN 'lfDecimal' THEN lfDecimal;
                WHEN 'rDecimal' THEN rDecimal;
                WHEN 'lfEnd' THEN lfEnd;
            END CASE;
            
        END LOOP;
    
    END;

    PROCEDURE check_end
        (p_context IN OUT NOCOPY rt_parse_context
        ,p_events IN OUT NOCOPY tt_parse_events) IS
        
        PROCEDURE add_event
            (p_name IN VARCHAR2
            ,p_value IN VARCHAR2) IS
        BEGIN
            p_events.EXTEND(1);
            p_events(p_events.COUNT).name := p_name;
            p_events(p_events.COUNT).value := p_value;
        END;
        
    BEGIN
    
        CASE p_context.state
        
            WHEN 'rInteger' THEN
                add_event('NUMBER', p_context.value);
            WHEN 'rDecimal' THEN
                add_event('NUMBER', p_context.value);
            WHEN 'lfDecimalDot' THEN
                add_event('NUMBER', p_context.value);
            WHEN 'lfEnd' THEN
                NULL;
            ELSE
                raise_error('Unexpected end of the input!');
        
        END CASE;
    
    END;

    FUNCTION parse
        (p_content IN VARCHAR2)
    RETURN tt_parse_events PIPELINED IS
    
        r_context rt_parse_context;
        t_events tt_parse_events;
    
    BEGIN
    
        r_context.state := 'lfValue';
       
        parse(p_content, r_context, t_events);
        check_end(r_context, t_events);
        
        FOR v_i IN 1..t_events.COUNT LOOP
            PIPE ROW(t_events(v_i));
        END LOOP;
    
        RETURN;
    
    END;
    
    FUNCTION parse
        (p_content IN CLOB)
    RETURN tt_parse_events PIPELINED IS
    BEGIN
    
        RETURN;
    
    END;

END;
/
