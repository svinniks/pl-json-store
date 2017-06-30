CREATE OR REPLACE PACKAGE BODY json_documents IS

    TYPE t_json_values IS TABLE OF json_values%ROWTYPE;
    
    TYPE t_integer_indexed_numbers IS TABLE OF NUMBER INDEX BY PLS_INTEGER;

    PROCEDURE register_messages IS
    BEGIN
        log$.register_message('JDOC-00001', 'Unexpected character ":1"!');
        log$.register_message('JDOC-00002', 'Unexpected end of the input!');
        log$.register_message('JDOC-00003', 'Root can''t be modified!');
        log$.register_message('JDOC-00004', 'Multiple values found at the path :1!');
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
                error$.raise('JDOC-00001', v_char);
                
            END IF;
        
        END;
    
        PROCEDURE lfRoot IS
        BEGIN
        
            IF v_char = '$' THEN
            
                add_element(c_root);
                v_state := 'lfDot';
            
            ELSIF v_char = '[' THEN
                
                v_state := 'lfArrayElement';
                
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
                error$.raise('JDOC-00001', v_char);
            
            END IF;
        
        END;
        
        PROCEDURE lfId IS
        BEGIN
        
            IF INSTR('1234567890', v_char) > 0 THEN
            
                v_value := v_char;
                v_state := 'rId';
                
            ELSE
            
                -- Unexpected character ":1"!
                error$.raise('JDOC-00001', v_char);
            
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
                error$.raise('JDOC-00001', v_char);
            
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
                error$.raise('JDOC-00001', v_char);
            
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
                error$.raise('JDOC-00001', v_char);
            
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
                error$.raise('JDOC-00001', v_char);
            
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
                error$.raise('JDOC-00001', v_char);
            
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
            error$.raise('JDOC-00002');
        
        END IF;
    
        RETURN v_path;
    
    END;
    
    FUNCTION create_json
        (p_parents IN t_numbers
        ,p_name IN VARCHAR2
        ,p_content IN VARCHAR2) 
    RETURN t_numbers IS
    
        v_parse_events json_parser.t_parse_events;    
        v_json_values t_json_values;
        
        v_event_i PLS_INTEGER;
        v_id NUMBER;
        
        v_id_map t_integer_indexed_numbers;
        
        v_created_ids t_numbers;
        
        FUNCTION next_id
        RETURN NUMBER IS
        BEGIN
            v_id := v_id - 1;
            RETURN v_id;
        END;
        
        PROCEDURE flush_values IS
            
            v_ids t_numbers;
            v_id_count NUMBER;
            
        BEGIN
        
            v_id_count := NVL(v_id_map.FIRST, 0) - v_id;
        
            SELECT jsvl_id.NEXTVAL
            BULK COLLECT INTO v_ids
            FROM dual
            CONNECT BY LEVEL <= v_id_count;
            
            FOR v_i IN 1..v_ids.COUNT LOOP
                v_id_map(NVL(v_id_map.FIRST, 0) - 1) := v_ids(v_i);
            END LOOP;
            
            FOR v_i IN 1..v_json_values.COUNT LOOP
            
                IF v_id_map.EXISTS(v_json_values(v_i).id) THEN
                    v_json_values(v_i).id := v_id_map(v_json_values(v_i).id);
                END IF;
                
                IF v_id_map.EXISTS(v_json_values(v_i).parent_id) THEN
                    v_json_values(v_i).parent_id := v_id_map(v_json_values(v_i).parent_id);
                END IF;
            
            END LOOP;
            
            FORALL v_i IN 1..v_json_values.COUNT
                INSERT INTO json_values
                VALUES v_json_values(v_i);
        
            v_json_values := t_json_values();
        
        END;
        
        PROCEDURE insert_value
            (p_value json_values%ROWTYPE) IS
            
            c_flush_amount CONSTANT PLS_INTEGER := 200;
            
        BEGIN
        
            v_json_values.EXTEND(1);
            v_json_values(v_json_values.COUNT) := p_value;
            
            IF v_json_values.COUNT = c_flush_amount THEN
                flush_values;
            END IF;
            
        END;
        
        FUNCTION create_value
            (p_parent_id IN NUMBER
            ,p_name IN VARCHAR2) 
        RETURN NUMBER IS
            
            v_value json_values%ROWTYPE;
            v_child_id NUMBER;
            
            v_name VARCHAR2(4000);
            v_i PLS_INTEGER;
            
        BEGIN
        
            v_value.id := next_id;
            v_value.parent_id := p_parent_id;
            v_value.name := p_name;
            
            IF v_parse_events(v_event_i).name = 'STRING' THEN
            
                v_value.type := 'S';
                v_value.value := v_parse_events(v_event_i).value;
                
                insert_value(v_value);
                
            ELSIF v_parse_events(v_event_i).name = 'NUMBER' THEN
            
                v_value.type := 'N';
                v_value.value := v_parse_events(v_event_i).value;
                
                insert_value(v_value);
                
            ELSIF v_parse_events(v_event_i).name = 'BOOLEAN' THEN
            
                v_value.type := 'B';
                v_value.value := v_parse_events(v_event_i).value;
                
                insert_value(v_value);
                
            ELSIF v_parse_events(v_event_i).name = 'NULL' THEN
            
                v_value.type := 'E';
                v_value.value := NULL;
                
                insert_value(v_value);
                
            ELSIF v_parse_events(v_event_i).name = 'START_OBJECT' THEN
            
                v_value.type := 'O';
                v_value.value := NULL;
                
                insert_value(v_value);
                
                v_event_i := v_event_i + 1;
                
                WHILE v_parse_events(v_event_i).name != 'END_OBJECT' LOOP
                
                    v_name := v_parse_events(v_event_i).value;
                    v_event_i := v_event_i + 1;
                    
                    v_child_id := create_value(v_value.id, v_name);
                    v_event_i := v_event_i + 1;
                
                END LOOP;
            
            ELSIF v_parse_events(v_event_i).name = 'START_ARRAY' THEN
            
                v_value.type := 'A';
                v_value.value := NULL;
                
                insert_value(v_value);
                
                v_i := 1;
                v_event_i := v_event_i + 1;
                
                WHILE v_parse_events(v_event_i).name != 'END_ARRAY' LOOP
                
                    v_child_id := create_value(v_value.id, v_i);
                    
                    v_event_i := v_event_i + 1;
                    v_i := v_i + 1;
                
                END LOOP;
            
            END IF;
            
            RETURN v_value.id;
        
        END;
    
    BEGIN
    
        v_parse_events := json_parser.parse(p_content);
        v_json_values := t_json_values();
        v_id := 0;
    
        v_created_ids := t_numbers();
    
        FOR v_i IN 1..p_parents.COUNT LOOP
        
            v_event_i := 1;
            
            v_created_ids.EXTEND(1);
            v_created_ids(v_created_ids.COUNT) := create_value(p_parents(v_i), p_name);
            
        END LOOP;
        
        flush_values;
        
        FOR v_i IN 1..v_created_ids.COUNT LOOP
            IF v_id_map.EXISTS(v_created_ids(v_i)) THEN
                v_created_ids(v_i) := v_id_map(v_created_ids(v_i));
            END IF;
        END LOOP;
        
        RETURN v_created_ids;
    
    END;
    
    FUNCTION set_json
        (p_path IN VARCHAR2
        ,p_content IN VARCHAR2)
    RETURN NUMBER IS
    
        v_path t_path;
        
        v_parent_ids t_numbers;
        v_name VARCHAR2(4000);
    
    BEGIN
    
        v_path := parse_path(p_path);
        
        -- If path is empty, then an anonymous JSON value creation has been requested
        IF v_path.COUNT = 0 THEN
        
            v_parent_ids := t_numbers(NULL);
            v_name := NULL;
            
        -- Root can't be modified
        ELSIF v_path(v_path.COUNT).type = c_root THEN

            -- Root can''t be modified!        
            error$.raise('JDOC-00003');
        
        ELSE
        
            error$.raise('Named value creation is not yet implemented!');
        
        END IF;
    
        IF v_parent_ids.COUNT > 1 THEN
            -- Multiple values found at the path :1!
            error$.raise('JDOC-00004', p_path);
        END IF;
    
        RETURN create_json(v_parent_ids, v_name, p_content)(1);
    
    END;
    
    FUNCTION set_json
        (p_content IN VARCHAR2)
    RETURN NUMBER IS
    BEGIN
    
        RETURN set_json(NULL, p_content);
    
    END;
    
BEGIN    
    register_messages;
END;
