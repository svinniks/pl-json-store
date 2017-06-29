CREATE OR REPLACE PACKAGE BODY json_parser IS

    TYPE tt_chars IS TABLE OF CHAR;

    TYPE rt_parse_context IS RECORD
        (state VARCHAR2(30)
        ,value VARCHAR2(4000)
        ,name BOOLEAN
        ,character_code VARCHAR2(4)
        ,context_stack tt_chars);

    PROCEDURE register_messages IS
    BEGIN
        log$.register_message('JSON-00001', 'Unexpected character ":1"!');
        log$.register_message('JSON-00002', 'Unexpected end of the input!');
    END;

    PROCEDURE parse
        (p_buffer IN VARCHAR2
        ,p_context IN OUT NOCOPY rt_parse_context
        ,p_events IN OUT NOCOPY tt_parse_events) IS
        
        v_char CHAR;
        
        PROCEDURE push_context
            (p_value IN CHAR) IS
        BEGIN
            p_context.context_stack.EXTEND(1);
            p_context.context_stack(p_context.context_stack.LAST) := p_value;
        END;
        
        FUNCTION peek_context
        RETURN CHAR IS
        BEGIN
        
            IF p_context.context_stack.COUNT = 0 THEN
                RETURN NULL;
            ELSE
                RETURN p_context.context_stack(p_context.context_stack.COUNT);
            END IF;
        
        END;
        
        PROCEDURE pop_context IS
        BEGIN
            p_context.context_stack.TRIM(1);
        END;
        
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
        
        PROCEDURE end_object IS
        BEGIN
        
            IF peek_context = 'O' THEN
            
                add_event('END_OBJECT', NULL);
                pop_context;
                
                IF peek_context IS NULL THEN
                    p_context.state := 'lfEnd';
                ELSE
                    p_context.state := 'lfComma';
                END IF;
                
            ELSE
            
                -- Unexpected character ":1"!
                error$.raise('JSON-00001', v_char);
                
            END IF;
        
        END;
        
        PROCEDURE end_array IS
        BEGIN
        
            IF peek_context = 'A' THEN
            
                add_event('END_ARRAY', NULL);
                pop_context;
                
                IF peek_context IS NULL THEN
                    p_context.state := 'lfEnd';
                ELSE
                    p_context.state := 'lfComma';
                END IF;
                
            ELSE
            
                -- Unexpected character ":1"!
                error$.raise('JSON-00001', v_char);
                
            END IF;
        
        END;
        
        PROCEDURE lfValue IS
        BEGIN
        
            IF v_char = '"' THEN
            
                p_context.state := 'rString';
                p_context.value := NULL;
                p_context.name := FALSE;
                
            ELSIF INSTR('123456789', v_char) > 0 THEN
            
                p_context.state := 'rInteger';
                p_context.value := v_char;
                
            ELSIF v_char = '0' THEN
            
                p_context.state := 'lfDecimalDot';
                p_context.value := '0';
                
            ELSIF v_char = '-' THEN
            
                p_context.state := 'lfInteger';
                p_context.value := '-';
                
            ELSIF v_char IN ('t', 'f', 'n') THEN
            
                p_context.state := 'rSpecialValue';
                p_context.value := v_char;
                
            ELSIF v_char = '{' THEN
            
                push_context('O');
                add_event('START_OBJECT', NULL);
                
                p_context.state := 'lfFirstProperty';
                
            ELSIF v_char = '[' THEN
            
                push_context('A');
                add_event('START_ARRAY', NULL);
                
                p_context.state := 'lfFirstValue';    
                
            ELSIF NOT space THEN
            
                -- Unexpected character ":1"!
                error$.raise('JSON-00001', v_char);
                
            END IF;
        
        END;
        
        PROCEDURE lfFirstValue IS
        BEGIN
        
            IF v_char = ']' THEN
                end_array;
            ELSE
                lfValue;
            END IF;
        
        END;
        
        PROCEDURE rString IS
        BEGIN
        
            IF v_char = '"' THEN
            
                IF p_context.name THEN
                
                    add_event('NAME', p_context.value);
                    p_context.state := 'lfColon';
                    
                ELSE
                
                    add_event('STRING', p_context.value);
                    
                    IF peek_context IS NOT NULL THEN
                        p_context.state := 'lfComma';
                    ELSE
                        p_context.state := 'lfEnd';
                    END IF;
                    
                END IF;
            
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
                WHEN 'u' THEN
                
                    p_context.character_code := NULL;
                    p_context.state := 'rUnicode';
                    
                    RETURN;
                    
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
            
                -- Unexpected character ":1"!
                error$.raise('JSON-00001', v_char);
            
            END IF;
        
        END;
        
        PROCEDURE rUnicode IS
        BEGIN
        
            IF INSTR('1234567890ABCDEF', UPPER(v_char)) > 0 THEN
            
                p_context.character_code := p_context.character_code || v_char;
                
                IF LENGTH(p_context.character_code) = 4 THEN
                    p_context.value := p_context.value || CHR(TO_NUMBER(p_context.character_code, 'xxxx'));
                    p_context.state := 'rString';
                END IF;
                
            ELSE
            
                -- Unexpected character ":1"!
                error$.raise('JSON-00001', v_char);
                
            END IF;
        
        END;
        
        PROCEDURE rInteger IS
        BEGIN
        
            IF INSTR('1234567890', v_char) > 0 THEN
            
                p_context.value := p_context.value || v_char;
                
            ELSIF v_char = '.' THEN
            
                p_context.value := p_context.value || '.';
                p_context.state := 'lfDecimal';
            
            ELSIF v_char = ',' THEN
            
                IF peek_context IS NOT NULL THEN
                
                    add_event('NUMBER', p_context.value);
                
                    IF peek_context = 'O' THEN
                        p_context.state := 'lfNextProperty';
                    ELSE
                        p_context.state := 'lfValue';
                    END IF;
                    
                ELSE
                
                    -- Unexpected character ":1"!
                    error$.raise('JSON-00001', v_char);
                    
                END IF;
                
            ELSIF space THEN
            
                add_event('NUMBER', p_context.value);
                
                IF peek_context IS NOT NULL THEN
                    p_context.state := 'lfComma';
                ELSE
                    p_context.state := 'lfEnd';
                END IF;
                
            ELSIF v_char = '}' THEN
            
                add_event('NUMBER', p_context.value);
                
                end_object;
                
            ELSIF v_char = ']' THEN
            
                add_event('NUMBER', p_context.value);
                
                end_array;
                
            ELSE
            
                -- Unexpected character ":1"!
                error$.raise('JSON-00001', v_char);
                
            END IF;
        
        END;
        
        PROCEDURE lfDecimalDot IS
        BEGIN
        
            IF v_char = '.' THEN
            
                p_context.value := p_context.value || '.';
                p_context.state := 'lfDecimal';
            
            ELSIF v_char = ',' THEN
            
                IF peek_context IS NOT NULL THEN
                
                    add_event('NUMBER', p_context.value);
                
                    IF peek_context = 'O' THEN
                        p_context.state := 'lfNextProperty';
                    ELSE
                        p_context.state := 'lfValue';
                    END IF;
                    
                ELSE
                
                    -- Unexpected character ":1"!
                    error$.raise('JSON-00001', v_char);
                    
                END IF;
                
            ELSIF v_char = '}' THEN
            
                add_event('NUMBER', p_context.value);
                
                end_object;
                
            ELSIF v_char = ']' THEN
            
                add_event('NUMBER', p_context.value);
                
                end_array;
                            
            ELSIF space THEN
            
                add_event('NUMBER', p_context.value);
                
                IF peek_context IS NOT NULL THEN
                    p_context.state := 'lfComma';
                ELSE
                    p_context.state := 'lfEnd';
                END IF;
                
            ELSE
            
                -- Unexpected character ":1"!
                error$.raise('JSON-00001', v_char);
            
            END IF;
        
        END;
        
        PROCEDURE lfDecimal IS
        BEGIN
        
            IF INSTR('1234567890', v_char) > 0 THEN
            
                p_context.value := p_context.value || v_char;
                p_context.state := 'rDecimal';
                
            ELSE
            
                -- Unexpected character ":1"!
                error$.raise('JSON-00001', v_char);
            
            END IF;
        
        END;
        
        PROCEDURE rDecimal IS
        BEGIN
        
            IF INSTR('1234567890', v_char) > 0 THEN
            
                p_context.value := p_context.value || v_char;
                
            ELSIF v_char = ',' THEN
            
                IF peek_context IS NOT NULL THEN
                
                    add_event('NUMBER', p_context.value);
                
                    IF peek_context = 'O' THEN
                        p_context.state := 'lfNextProperty';
                    ELSE
                        p_context.state := 'lfValue';
                    END IF;
                    
                ELSE
                
                    -- Unexpected character ":1"!
                    error$.raise('JSON-00001', v_char);
                    
                END IF;    
                
            ELSIF space THEN
            
                add_event('NUMBER', p_context.value);
                
                IF peek_context IS NOT NULL THEN
                    p_context.state := 'lfComma';
                ELSE
                    p_context.state := 'lfEnd';
                END IF;
            
            ELSIF v_char = '}' THEN
            
                add_event('NUMBER', p_context.value);
                
                end_object;
                
            ELSIF v_char = ']' THEN
            
                add_event('NUMBER', p_context.value);
                
                end_array;
                
            ELSE
            
                -- Unexpected character ":1"!
                error$.raise('JSON-00001', v_char);
            
            END IF;
        
        END;
        
        PROCEDURE lfEnd IS
        BEGIN
        
            IF NOT space THEN
                -- Unexpected character ":1"!
                error$.raise('JSON-00001', v_char);
            END IF;
        
        END;
        
        PROCEDURE rSpecialValue IS
        BEGIN
        
            p_context.value := p_context.value || v_char;
            
            IF p_context.value = 'true' THEN
            
                add_event('BOOLEAN', 'true');
                
                IF peek_context IS NOT NULL THEN
                    p_context.state := 'lfComma';
                ELSE
                    p_context.state := 'lfEnd';
                END IF;
                
            ELSIF p_context.value = 'false' THEN
            
                add_event('BOOLEAN', 'false');
                
                IF peek_context IS NOT NULL THEN
                    p_context.state := 'lfComma';
                ELSE
                    p_context.state := 'lfEnd';
                END IF;
                
            ELSIF p_context.value = 'null' THEN
            
                add_event('NULL', NULL);
                
                IF peek_context IS NOT NULL THEN
                    p_context.state := 'lfComma';
                ELSE
                    p_context.state := 'lfEnd';
                END IF;
                
            ELSIF 'true' NOT LIKE p_context.value || '%'
                  AND 'false' NOT LIKE p_context.value || '%'
                  AND 'null' NOT LIKE p_context.value || '%' THEN
                  
                -- Unexpected character ":1"!
                error$.raise('JSON-00001', v_char);
                  
            END IF;
        
        END;
        
        PROCEDURE lfFirstProperty IS
        BEGIN
        
            IF v_char = '}' THEN
            
                end_object;
                
            ELSIF v_char = '"' THEN
            
                p_context.value := NULL;
                p_context.state := 'rString';
                p_context.name := TRUE;
                
            ELSIF NOT space THEN
            
                -- Unexpected character ":1"!
                error$.raise('JSON-00001', v_char);
            
            END IF;
        
        END;
        
        PROCEDURE lfNextProperty IS
        BEGIN
        
            IF v_char = '"' THEN
            
                p_context.value := NULL;
                p_context.state := 'rString';
                p_context.name := TRUE;
                
            ELSIF NOT space THEN
            
                -- Unexpected character ":1"!
                error$.raise('JSON-00001', v_char);
            
            END IF;
        
        END;
        
        PROCEDURE lfColon IS
        BEGIN
        
            IF v_char = ':' THEN
            
                p_context.state := 'lfValue';
                
            ELSIF NOT space THEN
            
                -- Unexpected character ":1"!
                error$.raise('JSON-00001', v_char);
            
            END IF;
        
        END;
        
        PROCEDURE lfComma IS
        BEGIN
        
            IF v_char = ',' THEN
            
                IF peek_context = 'O' THEN
                    p_context.state := 'lfNextProperty';
                ELSE
                    p_context.state := 'lfValue';
                END IF;
                
            ELSIF v_char = '}' THEN
            
                end_object;
                
            ELSIF v_char = ']' THEN
            
                end_array;
                
            ELSIF NOT space THEN
            
                -- Unexpected character ":1"!
                error$.raise('JSON-00001', v_char);
            
            END IF;
                
        
        END;
        
    BEGIN
    
        p_events := tt_parse_events();
        
        FOR v_i IN 1..NVL(LENGTH(p_buffer), 0) LOOP
            
            v_char := SUBSTR(p_buffer, v_i, 1);
            
            CASE p_context.state
                WHEN 'lfContent' THEN lfValue;
                WHEN 'lfValue' THEN lfValue;
                WHEN 'rString' THEN rString;
                WHEN 'rEscaped' THEN rEscaped;
                WHEN 'rUnicode' THEN rUnicode;
                WHEN 'lfInteger' THEN lfInteger;
                WHEN 'rInteger' THEN rInteger;
                WHEN 'lfDecimalDot' THEN lfDecimalDot;
                WHEN 'lfDecimal' THEN lfDecimal;
                WHEN 'rDecimal' THEN rDecimal;
                WHEN 'lfEnd' THEN lfEnd;
                WHEN 'rSpecialValue' THEN rSpecialValue;
                WHEN 'lfFirstProperty' THEN lfFirstProperty;
                WHEN 'lfColon' THEN lfColon;
                WHEN 'lfComma' THEN lfComma;
                WHEN 'lfNextProperty' THEN lfNextProperty;
                WHEN 'lfFirstValue' THEN lfFirstValue;
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
            WHEN 'lfContent' THEN
                NULL;
            ELSE
                -- Unexpected end of the input!
                error$.raise('JSON-00002');
        
        END CASE;
        
        IF p_context.context_stack.COUNT > 0 THEN
            -- Unexpected end of the input!
            error$.raise('JSON-00002');
        END IF;
    
    END;

    FUNCTION parse
        (p_content IN VARCHAR2)
    RETURN tt_parse_events PIPELINED IS
    
        r_context rt_parse_context;
        t_events tt_parse_events;
    
    BEGIN
    
        r_context.state := 'lfContent';
        r_context.context_stack := tt_chars();
       
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
    
BEGIN
    register_messages;
END;
/
