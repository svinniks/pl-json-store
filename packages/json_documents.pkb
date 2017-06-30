CREATE OR REPLACE PACKAGE BODY json_documents IS

    PROCEDURE register_messages IS
    BEGIN
        log$.register_message('JPTH-00001', 'Unexpected character ":1"!');
        log$.register_message('JPTH-00002', 'Unexpected end of the input!');
    END;

    FUNCTION parse_path
        (p_path_string IN VARCHAR2)
    RETURN t_path IS
    
        v_state VARCHAR2(30);
        v_char CHAR;
        v_value VARCHAR2(4000);
        
        v_path t_path;
    
        PROCEDURE add_element
            (p_type IN PLS_INTEGER
            ,p_value IN VARCHAR2 := NULL) IS
        BEGIN
            v_path.EXTEND(1);
            v_path(v_path.COUNT).type := p_type;
            v_path(v_path.COUNT).value := p_value;
        END;
    
        FUNCTION space
        RETURN BOOLEAN IS
        BEGIN
        
            RETURN v_char IN (' ', CHR(10), CHR(13), CHR(9));
        
        END;
    
        PROCEDURE lfElement IS
        BEGIN
        
            IF INSTR('qwertyuioplkjhgfdsazxcvbnm', LOWER(v_char)) > 0 THEN
            
                v_value := v_char;
                v_state := 'rName';
                
            ELSIF v_char = '#' THEN
            
                v_value := NULL;
                v_state := 'lfId';
            
            ELSIF v_char = '"' THEN
            
                v_value := NULL;
                v_state := 'rQuotedName';
                
            ELSIF NOT space THEN
            
                -- Unexpected character ":1"!
                error$.raise('JPTH-00001', v_char);
                
            END IF;
        
        END;
    
        PROCEDURE lfRoot IS
        BEGIN
        
            IF v_char = '$' THEN
            
                add_element(c_root);
                v_state := 'lfDot';
                
            ELSE
            
                lfElement;
            
            END IF;
        
        END;
        
        PROCEDURE rName IS
        BEGIN
        
            IF INSTR('qwertyuioplkjhgfdsazxcvbnm1234567890_$', LOWER(v_char)) > 0 THEN
            
                v_value := v_value || v_char;
                
            ELSIF v_char = '.' THEN
            
                add_element(c_name, v_value);
                v_state := 'lfElement';    
            
            ELSIF v_char = '[' THEN
              
                add_element(c_name, v_value);
                v_state := 'lfArrayElement';
                
            ELSIF space THEN
            
                add_element(c_name, v_value);
                v_state := 'lfDot';
                
            ELSE
            
                -- Unexpected character ":1"!
                error$.raise('JPTH-00001', v_char);
            
            END IF;
        
        END;
        
        PROCEDURE lfId IS
        BEGIN
        
            IF INSTR('1234567890', v_char) > 0 THEN
            
                v_value := v_char;
                v_state := 'rId';
                
            ELSE
            
                -- Unexpected character ":1"!
                error$.raise('JPTH-00001', v_char);
            
            END IF;
        
        END;
        
        PROCEDURE rId IS
        BEGIN
        
            IF INSTR('1234567890', v_char) > 0 THEN
            
                v_value := v_value || v_char;
                
            ELSIF v_char = '.' THEN
            
                add_element(c_id, v_value);
                v_state := 'lfElement';
                
            ELSIF v_char = '[' THEN
              
                add_element(c_id, v_value);
                v_state := 'lfArrayElement';    
                
            ELSIF space THEN
            
                add_element(c_id, v_value);
                v_state := 'lfDot';    
            
            ELSE
            
                -- Unexpected character ":1"!
                error$.raise('JPTH-00001', v_char);
            
            END IF;
        
        END;
        
        PROCEDURE lfDot IS
        BEGIN
        
            IF v_char = '.' THEN
            
                v_state := 'lfElement';
            
            ELSIF v_char = '[' THEN
              
                v_state := 'lfArrayElement';
                
            ELSIF NOT space THEN
            
                -- Unexpected character ":1"!
                error$.raise('JPTH-00001', v_char);
            
            END IF;
        
        END;
        
        PROCEDURE rQuotedName IS
        BEGIN
        
            IF v_char = '"' THEN
            
                add_element(c_name, v_value);
                v_state := 'lfDot';
                
            ELSIF v_char = '\' THEN
            
                v_state := 'rEscaped';
                
            ELSE
            
                v_value := v_value || v_char;
            
            END IF;
        
        END;
        
        PROCEDURE rEscaped IS
        BEGIN
        
            v_value := v_value || v_char;
            v_state := 'rQuotedName';
        
        END;
        
        PROCEDURE lfArrayElement IS
        BEGIN
        
            IF INSTR('1234567890', v_char) > 0 THEN
            
                v_value := v_char;
                v_state := 'rArrayElement';
            
            ELSIF v_char = '"' THEN
            
                v_value := NULL;
                v_state := 'rQuotedArrayElement';
                
            ELSIF NOT space THEN
            
                -- Unexpected character ":1"!
                error$.raise('JPTH-00001', v_char);
            
            END IF;
        
        END;
        
        PROCEDURE rArrayElement IS
        BEGIN
        
            IF INSTR('1234567890', v_char) > 0 THEN
            
                v_value := v_value || v_char;
                
            ELSIF v_char = ']' THEN
            
                add_element(c_name, v_value);
                v_state := 'lfDot';
                
            ELSIF space THEN
            
                add_element(c_name, v_value);
                v_state := 'lfClosingBracket';
                
            ELSE
            
                -- Unexpected character ":1"!
                error$.raise('JPTH-00001', v_char);
            
            END IF;
        
        END;
        
        PROCEDURE rQuotedArrayElement IS
        BEGIN
        
            IF v_char = '"' THEN
            
                add_element(c_name, v_value);
                v_state := 'lfClosingBracket';
                
            ELSIF v_char = '\' THEN
            
                v_state := 'rEscapedA';
                
            ELSE
            
                v_value := v_value || v_char;
            
            END IF;
        
        END;
        
        PROCEDURE rEscapedA IS
        BEGIN
        
            v_value := v_value || v_char;
            v_state := 'rQuotedArrayElement';
        
        END;
        
        PROCEDURE lfClosingBracket IS
        BEGIN
        
            IF v_char = ']' THEN
            
                v_state := 'lfDot';
                
            ELSIF NOT space THEN
            
                -- Unexpected character ":1"!
                error$.raise('JPTH-00001', v_char);
            
            END IF;
        
        END;
    
    BEGIN
    
        v_path := t_path();
        v_state := 'lfRoot';
        
        FOR v_i IN 1..NVL(LENGTH(p_path_string), 0) LOOP
        
            v_char := SUBSTR(p_path_string, v_i, 1);
            
            CASE v_state
                WHEN 'lfRoot' THEN lfRoot;
                WHEN 'rName' THEN rName;
                WHEN 'lfId' THEN lfId;
                WHEN 'rId' THEN rId;
                WHEN 'lfDot' THEN lfDot;
                WHEN 'lfElement' THEN lfElement;
                WHEN 'rQuotedName' THEN rQuotedName;
                WHEN 'rEscaped' THEN rEscaped;
                WHEN 'lfArrayElement' THEN lfArrayElement;
                WHEN 'rArrayElement' THEN rArrayElement;
                WHEN 'rQuotedArrayElement' THEN rQuotedArrayElement;
                WHEN 'lfClosingBracket' THEN lfClosingBracket;
                WHEN 'rEscapedA' THEN rEscapedA;
            END CASE;
        
        END LOOP;
        
        IF v_state = 'rName' THEN
        
            add_element(c_name, v_value);
            
        ELSIF v_state = 'rId' THEN
        
            add_element(c_id, v_value);
            
        ELSIF v_state NOT IN ('lfDot', 'lfRoot') THEN
        
            -- Unexpected end of the input!
            error$.raise('JPTH-00002');
        
        END IF;
    
        RETURN v_path;
    
    END;
    
BEGIN    
    register_messages;
END;
