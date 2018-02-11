CREATE OR REPLACE PACKAGE BODY json_parser IS

    /* 
        Copyright 2017 Sergejs Vinniks

        Licensed under the Apache License, Version 2.0 (the "License");
        you may not use this file except in compliance with the License.
        You may obtain a copy of the License at
     
          http://www.apache.org/licenses/LICENSE-2.0

        Unless required by applicable law or agreed to in writing, software
        distributed under the License is distributed on an "AS IS" BASIS,
        WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
        See the License for the specific language governing permissions and
        limitations under the License.
    */

    TYPE t_chars IS TABLE OF CHAR;

    PROCEDURE register_messages IS
    BEGIN
        default_message_resolver.register_message('JSON-00001', 'Unexpected character ":1"!');
        default_message_resolver.register_message('JSON-00002', 'Unexpected end of the input!');
    END;

    FUNCTION parse
        (p_content IN t_varchars)
    RETURN t_parse_events IS
        
        v_state VARCHAR2(30);
        v_value VARCHAR2(4000);
        v_name BOOLEAN;
        v_character_code VARCHAR2(4);
        v_context_stack t_chars;
        
        v_string VARCHAR2(32000);
        v_char CHAR;
        
        v_events t_parse_events;
        
        PROCEDURE push_context
            (p_value IN CHAR) IS
        BEGIN
            v_context_stack.EXTEND(1);
            v_context_stack(v_context_stack.LAST) := p_value;
        END;
        
        FUNCTION peek_context
        RETURN CHAR IS
        BEGIN
        
            IF v_context_stack.COUNT = 0 THEN
                RETURN NULL;
            ELSE
                RETURN v_context_stack(v_context_stack.COUNT);
            END IF;
        
        END;
        
        PROCEDURE pop_context IS
        BEGIN
            v_context_stack.TRIM(1);
        END;
        
        PROCEDURE add_event
            (p_name IN VARCHAR2
            ,p_value IN VARCHAR2) IS
        BEGIN
            v_events.EXTEND(1);
            v_events(v_events.COUNT).name := p_name;
            v_events(v_events.COUNT).value := p_value;
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
                    v_state := 'lfEnd';
                ELSE
                    v_state := 'lfComma';
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
                    v_state := 'lfEnd';
                ELSE
                    v_state := 'lfComma';
                END IF;
                
            ELSE
            
                -- Unexpected character ":1"!
                error$.raise('JSON-00001', v_char);
                
            END IF;
        
        END;
        
        PROCEDURE lfValue IS
        BEGIN
        
            IF v_char = '"' THEN
            
                v_state := 'rString';
                v_value := NULL;
                v_name := FALSE;
                
            ELSIF INSTR('123456789', v_char) > 0 THEN
            
                v_state := 'rInteger';
                v_value := v_char;
                
            ELSIF v_char = '0' THEN
            
                v_state := 'lfDecimalDot';
                v_value := '0';
                
            ELSIF v_char = '-' THEN
            
                v_state := 'lfInteger';
                v_value := '-';
                
            ELSIF v_char IN ('t', 'f', 'n') THEN
            
                v_state := 'rSpecialValue';
                v_value := v_char;
                
            ELSIF v_char = '{' THEN
            
                push_context('O');
                add_event('START_OBJECT', NULL);
                
                v_state := 'lfFirstProperty';
                
            ELSIF v_char = '[' THEN
            
                push_context('A');
                add_event('START_ARRAY', NULL);
                
                v_state := 'lfFirstValue';    
                
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
            
                IF v_name THEN
                
                    add_event('NAME', v_value);
                    v_state := 'lfColon';
                    
                ELSE
                
                    add_event('STRING', v_value);
                    
                    IF peek_context IS NOT NULL THEN
                        v_state := 'lfComma';
                    ELSE
                        v_state := 'lfEnd';
                    END IF;
                    
                END IF;
            
            ELSIF v_char = '\' THEN
            
                v_state := 'rEscaped';
                
            ELSE
            
                v_value := v_value || v_char;
                
            END IF;
        
        END;
        
        PROCEDURE rEscaped IS
        BEGIN
        
            CASE v_char
                WHEN 'n' THEN
                    v_value := v_value || CHR(10);
                WHEN 'f' THEN
                    v_value := v_value || CHR(12);
                WHEN 't' THEN
                    v_value := v_value || CHR(9);
                WHEN 'r' THEN
                    v_value := v_value || CHR(13);
                WHEN 't' THEN
                    v_value := v_value || CHR(9);
                WHEN 'b' THEN
                    v_value := v_value || CHR(8);
                WHEN 'u' THEN
                
                    v_character_code := NULL;
                    v_state := 'rUnicode';
                    
                    RETURN;
                    
                ELSE
                    v_value := v_value || v_char;
            END CASE;
        
            v_state := 'rString';
        
        END;
        
        PROCEDURE lfInteger IS
        BEGIN
        
            IF INSTR('123456789', v_char) > 0 THEN
            
                v_state := 'rInteger';
                v_value := v_value || v_char;
                
            ELSIF v_char = '0' THEN
            
                v_state := 'lfDecimalDot';
                v_value := v_value || '0';
                
            ELSIF NOT space THEN
            
                -- Unexpected character ":1"!
                error$.raise('JSON-00001', v_char);
            
            END IF;
        
        END;
        
        PROCEDURE rUnicode IS
        BEGIN
        
            IF INSTR('1234567890ABCDEF', UPPER(v_char)) > 0 THEN
            
                v_character_code := v_character_code || v_char;
                
                IF LENGTH(v_character_code) = 4 THEN
                    v_value := v_value || CHR(TO_NUMBER(v_character_code, 'xxxx'));
                    v_state := 'rString';
                END IF;
                
            ELSE
            
                -- Unexpected character ":1"!
                error$.raise('JSON-00001', v_char);
                
            END IF;
        
        END;
        
        PROCEDURE rInteger IS
        BEGIN
        
            IF INSTR('1234567890', v_char) > 0 THEN
            
                v_value := v_value || v_char;
                
            ELSIF v_char = '.' THEN
            
                v_value := v_value || '.';
                v_state := 'lfDecimal';
            
            ELSIF v_char = ',' THEN
            
                IF peek_context IS NOT NULL THEN
                
                    add_event('NUMBER', v_value);
                
                    IF peek_context = 'O' THEN
                        v_state := 'lfNextProperty';
                    ELSE
                        v_state := 'lfValue';
                    END IF;
                    
                ELSE
                
                    -- Unexpected character ":1"!
                    error$.raise('JSON-00001', v_char);
                    
                END IF;
                
            ELSIF space THEN
            
                add_event('NUMBER', v_value);
                
                IF peek_context IS NOT NULL THEN
                    v_state := 'lfComma';
                ELSE
                    v_state := 'lfEnd';
                END IF;
                
            ELSIF v_char = '}' THEN
            
                add_event('NUMBER', v_value);
                
                end_object;
                
            ELSIF v_char = ']' THEN
            
                add_event('NUMBER', v_value);
                
                end_array;
                
            ELSE
            
                -- Unexpected character ":1"!
                error$.raise('JSON-00001', v_char);
                
            END IF;
        
        END;
        
        PROCEDURE lfDecimalDot IS
        BEGIN
        
            IF v_char = '.' THEN
            
                v_value := v_value || '.';
                v_state := 'lfDecimal';
            
            ELSIF v_char = ',' THEN
            
                IF peek_context IS NOT NULL THEN
                
                    add_event('NUMBER', v_value);
                
                    IF peek_context = 'O' THEN
                        v_state := 'lfNextProperty';
                    ELSE
                        v_state := 'lfValue';
                    END IF;
                    
                ELSE
                
                    -- Unexpected character ":1"!
                    error$.raise('JSON-00001', v_char);
                    
                END IF;
                
            ELSIF v_char = '}' THEN
            
                add_event('NUMBER', v_value);
                
                end_object;
                
            ELSIF v_char = ']' THEN
            
                add_event('NUMBER', v_value);
                
                end_array;
                            
            ELSIF space THEN
            
                add_event('NUMBER', v_value);
                
                IF peek_context IS NOT NULL THEN
                    v_state := 'lfComma';
                ELSE
                    v_state := 'lfEnd';
                END IF;
                
            ELSE
            
                -- Unexpected character ":1"!
                error$.raise('JSON-00001', v_char);
            
            END IF;
        
        END;
        
        PROCEDURE lfDecimal IS
        BEGIN
        
            IF INSTR('1234567890', v_char) > 0 THEN
            
                v_value := v_value || v_char;
                v_state := 'rDecimal';
                
            ELSE
            
                -- Unexpected character ":1"!
                error$.raise('JSON-00001', v_char);
            
            END IF;
        
        END;
        
        PROCEDURE rDecimal IS
        BEGIN
        
            IF INSTR('1234567890', v_char) > 0 THEN
            
                v_value := v_value || v_char;
                
            ELSIF v_char = ',' THEN
            
                IF peek_context IS NOT NULL THEN
                
                    add_event('NUMBER', v_value);
                
                    IF peek_context = 'O' THEN
                        v_state := 'lfNextProperty';
                    ELSE
                        v_state := 'lfValue';
                    END IF;
                    
                ELSE
                
                    -- Unexpected character ":1"!
                    error$.raise('JSON-00001', v_char);
                    
                END IF;    
                
            ELSIF space THEN
            
                add_event('NUMBER', v_value);
                
                IF peek_context IS NOT NULL THEN
                    v_state := 'lfComma';
                ELSE
                    v_state := 'lfEnd';
                END IF;
            
            ELSIF v_char = '}' THEN
            
                add_event('NUMBER', v_value);
                
                end_object;
                
            ELSIF v_char = ']' THEN
            
                add_event('NUMBER', v_value);
                
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
        
            v_value := v_value || v_char;
            
            IF v_value = 'true' THEN
            
                add_event('BOOLEAN', 'true');
                
                IF peek_context IS NOT NULL THEN
                    v_state := 'lfComma';
                ELSE
                    v_state := 'lfEnd';
                END IF;
                
            ELSIF v_value = 'false' THEN
            
                add_event('BOOLEAN', 'false');
                
                IF peek_context IS NOT NULL THEN
                    v_state := 'lfComma';
                ELSE
                    v_state := 'lfEnd';
                END IF;
                
            ELSIF v_value = 'null' THEN
            
                add_event('NULL', NULL);
                
                IF peek_context IS NOT NULL THEN
                    v_state := 'lfComma';
                ELSE
                    v_state := 'lfEnd';
                END IF;
                
            ELSIF 'true' NOT LIKE v_value || '%'
                  AND 'false' NOT LIKE v_value || '%'
                  AND 'null' NOT LIKE v_value || '%' THEN
                  
                -- Unexpected character ":1"!
                error$.raise('JSON-00001', v_char);
                  
            END IF;
        
        END;
        
        PROCEDURE lfFirstProperty IS
        BEGIN
        
            IF v_char = '}' THEN
            
                end_object;
                
            ELSIF v_char = '"' THEN
            
                v_value := NULL;
                v_state := 'rString';
                v_name := TRUE;
                
            ELSIF NOT space THEN
            
                -- Unexpected character ":1"!
                error$.raise('JSON-00001', v_char);
            
            END IF;
        
        END;
        
        PROCEDURE lfNextProperty IS
        BEGIN
        
            IF v_char = '"' THEN
            
                v_value := NULL;
                v_state := 'rString';
                v_name := TRUE;
                
            ELSIF NOT space THEN
            
                -- Unexpected character ":1"!
                error$.raise('JSON-00001', v_char);
            
            END IF;
        
        END;
        
        PROCEDURE lfColon IS
        BEGIN
        
            IF v_char = ':' THEN
            
                v_state := 'lfValue';
                
            ELSIF NOT space THEN
            
                -- Unexpected character ":1"!
                error$.raise('JSON-00001', v_char);
            
            END IF;
        
        END;
        
        PROCEDURE lfComma IS
        BEGIN
        
            IF v_char = ',' THEN
            
                IF peek_context = 'O' THEN
                    v_state := 'lfNextProperty';
                ELSE
                    v_state := 'lfValue';
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
    
        v_state := 'lfContent';
        v_context_stack := t_chars();
        v_events := t_parse_events();
        
        FOR v_i IN 1..p_content.COUNT LOOP
        
            v_string := p_content(v_i);
        
            FOR v_j IN 1..NVL(LENGTH(v_string), 0) LOOP
                
                v_char := SUBSTR(v_string, v_j, 1);
                
                CASE v_state
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
        
        END LOOP;
        
        CASE v_state
        
            WHEN 'rInteger' THEN
                add_event('NUMBER', v_value);
            WHEN 'rDecimal' THEN
                add_event('NUMBER', v_value);
            WHEN 'lfDecimalDot' THEN
                add_event('NUMBER', v_value);
            WHEN 'lfEnd' THEN
                NULL;
            WHEN 'lfContent' THEN
                NULL;
            ELSE
                -- Unexpected end of the input!
                error$.raise('JSON-00002');
        
        END CASE;
        
        IF v_context_stack.COUNT > 0 THEN
            -- Unexpected end of the input!
            error$.raise('JSON-00002');
        END IF;
        
        RETURN v_events;
    
    END;

    FUNCTION parse
        (p_content IN VARCHAR2)
    RETURN t_parse_events IS
    BEGIN
    
        RETURN parse(t_varchars(p_content));
    
    END;
    
    FUNCTION parse
        (p_content IN CLOB)
    RETURN t_parse_events IS
    
        v_content t_varchars;
    
        v_offset INTEGER;
        v_amount INTEGER;
        v_buffer VARCHAR2(32000);
    
    BEGIN
    
        IF p_content IS NULL THEN
          
            v_content := t_varchars(NULL);
            
        ELSE
          
            v_offset := 1;
            v_amount := 32000;
            v_content := t_varchars();
            
            WHILE v_amount = 32000 LOOP
              
                dbms_lob.read(p_content, v_amount, v_offset, v_buffer);
                
                v_content.EXTEND(1);
                v_content(v_content.COUNT) := v_buffer;
                
                v_offset := v_offset + v_amount;
            
            END LOOP;
            
        END IF;
        
        RETURN parse(v_content);
    
    END;
    
BEGIN
    register_messages;
END;
