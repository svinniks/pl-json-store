CREATE OR REPLACE PACKAGE BODY json_store IS

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

    TYPE t_json_values IS TABLE OF json_values%ROWTYPE;

    TYPE t_integer_indexed_numbers IS TABLE OF NUMBER INDEX BY PLS_INTEGER;
    TYPE t_varchar_indexed_varchars IS TABLE OF VARCHAR2(32000) INDEX BY VARCHAR2(32000);

    v_property_request_sqls t_varchar_indexed_varchars;
    v_value_request_sqls t_varchar_indexed_varchars;
    
    PROCEDURE register_messages IS
    BEGIN
        default_message_resolver.register_message('JDOC-00001', 'Unexpected character ":1"!');
        default_message_resolver.register_message('JDOC-00002', 'Unexpected end of the input!');
        default_message_resolver.register_message('JDOC-00003', 'Root can''t be modified!');
        default_message_resolver.register_message('JDOC-00004', 'Multiple values found at the path :1!');
        default_message_resolver.register_message('JDOC-00005', 'Empty path specified!');
        default_message_resolver.register_message('JDOC-00006', 'Root requested as a property!');
        default_message_resolver.register_message('JDOC-00007', 'No container for property at path :1 could be found!');
        default_message_resolver.register_message('JDOC-00008', 'Scalar values and null can''t have properties!');
        default_message_resolver.register_message('JDOC-00009', 'Value :1 does not exist!');
        default_message_resolver.register_message('JDOC-00010', 'Type conversion error!');
        default_message_resolver.register_message('JDOC-00011', 'Property :1 type mismatch!');
        default_message_resolver.register_message('JDOC-00012', ':1 is not an array!');
        default_message_resolver.register_message('JDOC-00013', 'Invalid array element index :1!');
        default_message_resolver.register_message('JDOC-00014', 'Requested target is not an array!');
    END;
    
    FUNCTION get_length
        (p_array_id IN NUMBER)
    RETURN NUMBER;

    FUNCTION parse_path
        (p_path IN VARCHAR2)
    RETURN t_path_elements IS

        v_state VARCHAR2(30);
        v_char CHAR;
        v_value VARCHAR2(4000);

        p_path_elements t_path_elements;

        PROCEDURE add_element
            (p_type IN CHAR
            ,p_value IN VARCHAR2 := NULL) IS
        BEGIN
            p_path_elements.EXTEND(1);
            p_path_elements(p_path_elements.COUNT).type := p_type;
            p_path_elements(p_path_elements.COUNT).value := p_value;
        END;

        FUNCTION space
        RETURN BOOLEAN IS
        BEGIN

            RETURN v_char IN (' ', CHR(10), CHR(13), CHR(9));

        END;

        PROCEDURE lfElement IS
        BEGIN

            IF INSTR('qwertyuioplkjhgfdsazxcvbnm$_', LOWER(v_char)) > 0 THEN

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

                add_element('R');
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

                add_element('N', v_value);
                v_state := 'lfElement';

            ELSIF v_char = '[' THEN

                add_element('N', v_value);
                v_state := 'lfArrayElement';

            ELSIF space THEN

                add_element('N', v_value);
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

                add_element('I', v_value);
                v_state := 'lfElement';

            ELSIF v_char = '[' THEN

                add_element('I', v_value);
                v_state := 'lfArrayElement';

            ELSIF space THEN

                add_element('I', v_value);
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

                add_element('N', v_value);
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

                add_element('N', v_value);
                v_state := 'lfDot';

            ELSIF space THEN

                add_element('N', v_value);
                v_state := 'lfClosingBracket';

            ELSE

                -- Unexpected character ":1"!
                error$.raise('JDOC-00001', v_char);

            END IF;

        END;

        PROCEDURE rQuotedArrayElement IS
        BEGIN

            IF v_char = '"' THEN

                add_element('N', v_value);
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

        p_path_elements := t_path_elements();
        v_state := 'lfRoot';

        FOR v_i IN 1..NVL(LENGTH(p_path), 0) LOOP

            v_char := SUBSTR(p_path, v_i, 1);

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

            add_element('N', v_value);

        ELSIF v_state = 'rId' THEN

            add_element('I', v_value);

        ELSIF v_state NOT IN ('lfDot', 'lfRoot') THEN

            -- Unexpected end of the input!
            error$.raise('JDOC-00002');

        END IF;

        RETURN p_path_elements;

    END;

    PROCEDURE request_properties
        (p_path_elements IN t_path_elements
        ,p_properties OUT SYS_REFCURSOR) IS

        v_path_signature VARCHAR2(4000);

        v_start_level PLS_INTEGER;
        v_sql VARCHAR2(32000);

        v_path_values t_varchars;

        FUNCTION field
            (p_i IN PLS_INTEGER)
        RETURN VARCHAR2 IS
        BEGIN
            RETURN CASE p_path_elements(p_i).type
                       WHEN 'I' THEN 'id'
                       ELSE 'name'
                   END;
        END;

    BEGIN

        IF p_path_elements.COUNT = 0 THEN
            -- Empty path specified!
            error$.raise('JDOC-00005');
        ELSIF p_path_elements(p_path_elements.COUNT).type = 'R' THEN
            -- Root requested as a property!
            error$.raise('JDOC-00006');
        END IF;

        FOR v_i IN 1..p_path_elements.COUNT LOOP
            v_path_signature := v_path_signature || p_path_elements(v_i).type;
        END LOOP;

        IF v_property_request_sqls.EXISTS(v_path_signature) THEN

            v_sql := v_property_request_sqls(v_path_signature);

        ELSE

            v_sql := 'WITH path_values AS
    (SELECT column_value AS value, ROWNUM AS rn
     FROM TABLE(:path_values))
';

            IF p_path_elements.COUNT = 1 THEN

                v_sql := v_sql || 'SELECT parent.id, parent.type, property.id, property.type, property.name
FROM json_values property
    ,json_values parent
WHERE property.' || field(1) || ' = :property_value
      AND parent.id(+) = property.parent_id';

            ELSIF p_path_elements.COUNT = 2 AND p_path_elements(1).type = 'R' THEN

                v_sql := v_sql || 'SELECT NULL, NULL, jsvl.id, jsvl.type, jsvl.name
FROM (SELECT jsvl.*, 0 AS nvl_parent_id
      FROM json_values jsvl
      WHERE ' || field(2) || ' = :property_value
            AND parent_id IS NULL) jsvl
    ,(SELECT 0 AS id
      FROM dual) root
WHERE jsvl.nvl_parent_id(+) = root.id';

            ELSE

                v_start_level := CASE p_path_elements(1).type WHEN 'R' THEN 2 ELSE 1 END;

                v_sql := v_sql || 'SELECT l' || (p_path_elements.COUNT - 1) || '.id, l' || (p_path_elements.COUNT - 1) || '.type, property.id, property.type, property.name
FROM ';

                FOR v_i IN v_start_level..p_path_elements.COUNT - 1 LOOP
                    v_sql := v_sql || 'json_values l' || v_i || ', ';
                END LOOP;

                v_sql := v_sql || 'json_values property
WHERE 1=1';

                IF p_path_elements(1).type = 'R' THEN
                    v_sql := v_sql || '
      AND l2.parent_id IS NULL';
                END IF;

                FOR v_i IN v_start_level..p_path_elements.COUNT - 1 LOOP

                    v_sql := v_sql || '
      AND l' || v_i || '.' || field(v_i) || ' = (SELECT value FROM path_values WHERE rn = ' || v_i || ')';

                    IF v_i > v_start_level THEN
                        v_sql := v_sql || '
      AND l' || v_i || '.parent_id = l' || (v_i - 1) || '.id';
                    END IF;

                END LOOP;

                IF p_path_elements(p_path_elements.COUNT).type = 'I' THEN

                    v_sql := v_sql || '
      AND property.parent_id = l' || (p_path_elements.COUNT - 1) || '.id
      AND property.id = :property_value';

                ELSE

                    v_sql := v_sql || '
      AND property.parent_id(+) = l' || (p_path_elements.COUNT - 1) || '.id
      AND property.name(+) = :property_value';

                END IF;

            END IF;

            v_property_request_sqls(v_path_signature) := v_sql;

        END IF;

        v_path_values := t_varchars();
        v_path_values.EXTEND(p_path_elements.COUNT - 1);

        FOR v_i IN 1..p_path_elements.COUNT - 1 LOOP
            v_path_values(v_i) := p_path_elements(v_i).value;
        END LOOP;

        OPEN p_properties
        FOR v_sql
        USING IN v_path_values, p_path_elements(p_path_elements.COUNT).value;

    END;

    PROCEDURE request_properties
        (p_path IN VARCHAR2
        ,p_properties OUT SYS_REFCURSOR) IS
    BEGIN
        request_properties(parse_path(p_path), p_properties);
    END;

    FUNCTION request_properties
        (p_path IN VARCHAR2)
    RETURN t_properties PIPELINED IS

        c_properties SYS_REFCURSOR;
        v_properties t_properties;

        c_fetch_limit CONSTANT PLS_INTEGER := 100;

    BEGIN

        request_properties(p_path, c_properties);

        LOOP

            v_properties := t_properties();

            FETCH c_properties
            BULK COLLECT INTO v_properties
            LIMIT c_fetch_limit;

            FOR v_i IN 1..v_properties.COUNT LOOP
                PIPE ROW(v_properties(v_i));
            END LOOP;

            EXIT WHEN v_properties.COUNT < c_fetch_limit;

        END LOOP;

        CLOSE c_properties;

        RETURN;

    END;

    PROCEDURE create_json
        (p_parent_ids IN t_numbers
        ,p_name IN VARCHAR2
        ,p_content_parse_events IN json_parser.t_parse_events
        ,p_event_i IN OUT NOCOPY PLS_INTEGER
        ,p_created_ids IN OUT NOCOPY t_numbers
        ,p_id IN NUMBER := NULL) IS

        v_json_values t_json_values;

        v_event_i PLS_INTEGER;
        v_id NUMBER;

        v_id_map t_integer_indexed_numbers;

        FUNCTION next_id
        RETURN NUMBER IS
        BEGIN
            -- Local "artifitial" identifiers must be negative to not overlap with the existing ones!
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
            ,p_name IN VARCHAR2
            ,p_id IN NUMBER := NULL)
        RETURN NUMBER IS

            v_value json_values%ROWTYPE;
            v_child_id NUMBER;

            v_name VARCHAR2(4000);
            v_i PLS_INTEGER;

        BEGIN

            v_value.id := CASE WHEN p_id IS NULL THEN next_id ELSE p_id END;
            v_value.parent_id := p_parent_id;
            v_value.name := p_name;

            IF p_content_parse_events(v_event_i).name = 'STRING' THEN

                v_value.type := 'S';
                v_value.value := p_content_parse_events(v_event_i).value;

                insert_value(v_value);

            ELSIF p_content_parse_events(v_event_i).name = 'NUMBER' THEN

                v_value.type := 'N';
                v_value.value := p_content_parse_events(v_event_i).value;

                insert_value(v_value);

            ELSIF p_content_parse_events(v_event_i).name = 'BOOLEAN' THEN

                v_value.type := 'B';
                v_value.value := p_content_parse_events(v_event_i).value;

                insert_value(v_value);

            ELSIF p_content_parse_events(v_event_i).name = 'NULL' THEN

                v_value.type := 'E';
                v_value.value := NULL;

                insert_value(v_value);

            ELSIF p_content_parse_events(v_event_i).name = 'START_OBJECT' THEN

                v_value.type := 'O';
                v_value.value := NULL;

                insert_value(v_value);

                v_event_i := v_event_i + 1;

                WHILE p_content_parse_events(v_event_i).name != 'END_OBJECT' LOOP

                    v_name := p_content_parse_events(v_event_i).value;
                    v_event_i := v_event_i + 1;

                    v_child_id := create_value(v_value.id, v_name);
                    v_event_i := v_event_i + 1;

                END LOOP;

            ELSIF p_content_parse_events(v_event_i).name = 'START_ARRAY' THEN

                v_value.type := 'A';
                v_value.value := NULL;

                insert_value(v_value);

                v_i := 0;
                v_event_i := v_event_i + 1;

                WHILE p_content_parse_events(v_event_i).name != 'END_ARRAY' LOOP

                    v_child_id := create_value(v_value.id, v_i);

                    v_event_i := v_event_i + 1;
                    v_i := v_i + 1;

                END LOOP;

            END IF;

            RETURN v_value.id;

        END;

    BEGIN

        v_json_values := t_json_values();
        v_id := 0;

        p_created_ids := t_numbers();

        FOR v_i IN 1..p_parent_ids.COUNT LOOP

            v_event_i := p_event_i;

            p_created_ids.EXTEND(1);
            p_created_ids(p_created_ids.COUNT) := create_value(p_parent_ids(v_i), p_name, p_id);

        END LOOP;

        flush_values;

        p_event_i := v_event_i;

        FOR v_i IN 1..p_created_ids.COUNT LOOP
            IF v_id_map.EXISTS(p_created_ids(v_i)) THEN
                p_created_ids(v_i) := v_id_map(p_created_ids(v_i));
            END IF;
        END LOOP;

    END;

    FUNCTION create_json
        (p_parent_ids IN t_numbers
        ,p_name IN VARCHAR2
        ,p_content_parse_events IN json_parser.t_parse_events
        ,p_id IN NUMBER := NULL) 
    RETURN t_numbers IS
    
        v_event_i PLS_INTEGER;
        v_created_ids t_numbers;
    
    BEGIN
    
        v_event_i := 1;
        create_json(p_parent_ids, p_name, p_content_parse_events, v_event_i, v_created_ids, p_id);
        
        RETURN v_created_ids;
    
    END;

    FUNCTION create_json
        (p_content IN VARCHAR2)
    RETURN NUMBER IS
        v_created_ids t_numbers;
    BEGIN
        RETURN create_json(t_numbers(NULL), NULL, json_parser.parse(p_content))(1);
    END;
    
    FUNCTION create_json_clob
        (p_content IN CLOB)
    RETURN NUMBER IS
    BEGIN
        RETURN create_json(t_numbers(NULL), NULL, json_parser.parse(p_content))(1);
    END;

    FUNCTION string_events
        (p_value IN VARCHAR2)
    RETURN json_parser.t_parse_events IS
    
        v_parse_event json_parser.t_parse_event;
    
    BEGIN
    
        IF p_value IS NULL THEN
            v_parse_event.name := 'NULL';
        ELSE
            v_parse_event.name := 'STRING';
            v_parse_event.value := p_value;
        END IF;
        
        RETURN json_parser.t_parse_events(v_parse_event);
    
    END;
    
    FUNCTION number_events
        (p_value IN NUMBER)
    RETURN json_parser.t_parse_events IS
    
        v_parse_event json_parser.t_parse_event;
    
    BEGIN
    
        IF p_value IS NULL THEN
            v_parse_event.name := 'NULL';
        ELSE
            v_parse_event.name := 'NUMBER';
            v_parse_event.value := p_value;
        END IF;
        
        RETURN json_parser.t_parse_events(v_parse_event);
    
    END;
    
    FUNCTION boolean_events
        (p_value IN BOOLEAN)
    RETURN json_parser.t_parse_events IS
    
        v_parse_event json_parser.t_parse_event;
    
    BEGIN
    
        IF p_value IS NULL THEN
            v_parse_event.name := 'NULL';
        ELSE
            v_parse_event.name := 'BOOLEAN';
            v_parse_event.value := CASE WHEN p_value THEN 'true' ELSE 'false' END;
        END IF;
        
        RETURN json_parser.t_parse_events(v_parse_event);
    
    END;
    
    FUNCTION null_events
    RETURN json_parser.t_parse_events IS
    
        v_parse_event json_parser.t_parse_event;
    
    BEGIN
    
        v_parse_event.name := 'NULL';
                
        RETURN json_parser.t_parse_events(v_parse_event);
    
    END;
    
    FUNCTION object_events
    RETURN json_parser.t_parse_events IS
    
        v_start_event json_parser.t_parse_event;
        v_end_event json_parser.t_parse_event;

    BEGIN

        v_start_event.name := 'START_OBJECT';
        v_end_event.name := 'END_OBJECT';
        
        RETURN json_parser.t_parse_events(v_start_event, v_end_event);
        
    END;
    
    FUNCTION array_events
    RETURN json_parser.t_parse_events IS
    
        v_start_event json_parser.t_parse_event;
        v_end_event json_parser.t_parse_event;

    BEGIN

        v_start_event.name := 'START_ARRAY';
        v_end_event.name := 'END_ARRAY';
        
        RETURN json_parser.t_parse_events(v_start_event, v_end_event);
        
    END;

    FUNCTION create_string
        (p_value IN VARCHAR2)
    RETURN NUMBER IS
    BEGIN

        RETURN create_json(t_numbers(NULL), NULL, string_events(p_value))(1);

    END;

    FUNCTION create_number
        (p_value IN NUMBER)
    RETURN NUMBER IS
    BEGIN

        RETURN create_json(t_numbers(NULL), NULL, number_events(p_value))(1);

    END;

    FUNCTION create_boolean
        (p_value IN BOOLEAN)
    RETURN NUMBER IS
    BEGIN

        RETURN create_json(t_numbers(NULL), NULL, boolean_events(p_value))(1);

    END;

    FUNCTION create_null
    RETURN NUMBER IS
    BEGIN

        RETURN create_json(t_numbers(NULL), NULL, null_events)(1);

    END;

    FUNCTION create_object
    RETURN NUMBER IS
    BEGIN

        RETURN create_json(t_numbers(NULL), NULL, object_events)(1);

    END;

    FUNCTION create_array
    RETURN NUMBER IS
    BEGIN

        RETURN create_json(t_numbers(NULL), NULL, array_events)(1);

    END;

    FUNCTION set_property
        (p_path IN VARCHAR2
        ,p_content_parse_events IN json_parser.t_parse_events
        ,p_exact IN BOOLEAN := TRUE)
    RETURN t_numbers IS

        v_path_elements t_path_elements;

        c_properties SYS_REFCURSOR;
        v_properties t_properties;

        v_existing_ids t_numbers;
        v_parent_ids t_numbers;
        
        v_index NUMBER;
        v_length NUMBER;
        v_gap_values t_json_values;

    BEGIN

        v_path_elements := parse_path(p_path);
        request_properties(v_path_elements, c_properties);

        FETCH c_properties
        BULK COLLECT INTO v_properties;

        CLOSE c_properties;

        IF p_exact AND v_properties.COUNT > 1 THEN
            -- Multiple values found at the path :1!
            error$.raise('JDOC-00004', p_path);
        ELSIF v_properties.COUNT = 0 THEN
            -- No container for property at path :1 could be found!
            error$.raise('JDOC-00007', p_path);
        END IF;

        v_index := to_index(v_path_elements(v_path_elements.COUNT).value);
        
        v_existing_ids := t_numbers();
        v_gap_values := t_json_values();
        
        v_parent_ids := t_numbers();

        FOR v_i IN 1..v_properties.COUNT LOOP

            IF NVL(v_properties(v_i).parent_type, 'R') NOT IN ('R', 'O', 'A') THEN
                -- Scalar values and null can't have properties!
                error$.raise('JDOC-00008');
            END IF;

            IF v_properties(v_i).property_id IS NOT NULL THEN
                v_existing_ids.EXTEND(1);
                v_existing_ids(v_existing_ids.COUNT) := v_properties(v_i).property_id;
            END IF;

            v_parent_ids.EXTEND(1);
            v_parent_ids(v_parent_ids.COUNT) := v_properties(v_i).parent_id;
            
            IF v_properties(v_i).parent_type = 'A' THEN
                
                IF v_index IS NULL THEN
                    -- Array element index must be a non-negative integer!
                    error$.raise('JDOC-00013', v_path_elements(v_path_elements.COUNT).value);
                END IF;
                
                v_length := get_length(v_properties(v_i).parent_id);
                
                IF v_index > v_length THEN
                    
                    FOR v_j IN v_length..v_index - 1 LOOP
                    
                        v_gap_values.EXTEND(1);
                        
                        v_gap_values(v_gap_values.COUNT).parent_id := v_properties(v_i).parent_id;
                        v_gap_values(v_gap_values.COUNT).type := 'E';
                        v_gap_values(v_gap_values.COUNT).name := v_j;
                    
                    END LOOP;
                
                END IF;
            
            END IF;

        END LOOP;

        IF v_existing_ids.COUNT > 0 THEN

            FORALL v_i IN 1..v_existing_ids.COUNT
                DELETE FROM json_values
                WHERE id = v_existing_ids(v_i);

        END IF;
        
        IF v_gap_values.COUNT > 0 THEN
        
            FORALL v_i IN 1..v_gap_values.COUNT
                INSERT INTO json_values(id, parent_id, type, name)
                VALUES(jsvl_id.NEXTVAL, v_gap_values(v_i).parent_id, 'E', v_gap_values(v_i).name);
        
        END IF;

        IF v_path_elements(v_path_elements.COUNT).type = 'N' THEN
          
            RETURN create_json
                (v_parent_ids
                ,v_path_elements(v_path_elements.COUNT).value
                ,p_content_parse_events);
            
        ELSE
          
            RETURN create_json
                (v_parent_ids
                ,v_properties(1).property_name
                ,p_content_parse_events
                ,v_path_elements(v_path_elements.COUNT).value);
                
        END IF;

    END;

    FUNCTION set_json
        (p_path IN VARCHAR2
        ,p_content IN VARCHAR2)
    RETURN NUMBER IS
    BEGIN
        RETURN set_property(p_path, json_parser.parse(p_content))(1);
    END;
    
    PROCEDURE set_json
        (p_path IN VARCHAR2
        ,p_content IN VARCHAR2) IS
        
        v_dummy NUMBER;
        
    BEGIN
    
        v_dummy := set_json(p_path, p_content);
    
    END;
    
    FUNCTION set_json_clob
        (p_path IN VARCHAR2
        ,p_content IN CLOB)
    RETURN NUMBER IS
    BEGIN
        RETURN set_property(p_path, json_parser.parse(p_content))(1);
    END;

    PROCEDURE set_json_clob
        (p_path IN VARCHAR2
        ,p_content IN CLOB) IS
        
        v_dummy NUMBER;
        
    BEGIN
    
        v_dummy := set_json_clob(p_path, p_content); 
    
    END;

    FUNCTION set_string
        (p_path IN VARCHAR2
        ,p_value IN VARCHAR2)
    RETURN NUMBER IS
    BEGIN

        RETURN set_property(p_path, string_events(p_value))(1);

    END;
    
    PROCEDURE set_string
        (p_path IN VARCHAR2
        ,p_value IN VARCHAR2) IS
        
        v_dummy NUMBER;
        
    BEGIN

        v_dummy := set_string(p_path, p_value);

    END;

    FUNCTION set_number
        (p_path IN VARCHAR2
        ,p_value IN NUMBER)
    RETURN NUMBER IS
    BEGIN

        RETURN set_property(p_path, number_events(p_value))(1);

    END;
    
    PROCEDURE set_number
        (p_path IN VARCHAR2
        ,p_value IN NUMBER) IS
        
        v_dummy NUMBER;
        
    BEGIN

        v_dummy := set_number(p_path, p_value);

    END;

    FUNCTION set_boolean
        (p_path IN VARCHAR2
        ,p_value IN BOOLEAN)
    RETURN NUMBER IS
    BEGIN

        RETURN set_property(p_path, boolean_events(p_value))(1);

    END;
    
    PROCEDURE set_boolean
        (p_path IN VARCHAR2
        ,p_value IN BOOLEAN) IS
        
        v_dummy NUMBER;
        
    BEGIN

        v_dummy := set_boolean(p_path, p_value);

    END;

    FUNCTION set_null
        (p_path IN VARCHAR2)
    RETURN NUMBER IS
    BEGIN

        RETURN set_property(p_path, null_events)(1);

    END;
    
    PROCEDURE set_null
        (p_path IN VARCHAR2) IS
    
        v_dummy NUMBER;
        
    BEGIN
        v_dummy := set_null(p_path);
    END;

    FUNCTION set_object
        (p_path IN VARCHAR2)
    RETURN NUMBER IS
    BEGIN

        RETURN set_property(p_path, object_events)(1);

    END;
    
    PROCEDURE set_object
        (p_path IN VARCHAR2) IS
        
        v_dummy NUMBER;
        
    BEGIN
        v_dummy := set_property(p_path, object_events)(1);
    END;

    FUNCTION set_array
        (p_path IN VARCHAR2)
    RETURN NUMBER IS
    BEGIN

        RETURN set_property(p_path, array_events)(1);

    END;
    
    PROCEDURE set_array
        (p_path IN VARCHAR2) IS
        
        v_dummy NUMBER;
        
    BEGIN
        v_dummy := set_property(p_path, array_events)(1);
    END;
    
    PROCEDURE request_values
        (p_path_elements IN t_path_elements
        ,p_values OUT SYS_REFCURSOR) IS
        
        v_path_signature VARCHAR2(4000);

        v_start_level PLS_INTEGER;
        v_comma VARCHAR2(10);
        v_sql VARCHAR2(32000);

        v_path_values t_varchars;

        FUNCTION field
            (p_i IN PLS_INTEGER)
        RETURN VARCHAR2 IS
        BEGIN
            RETURN CASE p_path_elements(p_i).type
                       WHEN 'I' THEN 'id'
                       ELSE 'name'
                   END;
        END;

    BEGIN

        IF p_path_elements.COUNT = 0 THEN
            -- Empty path specified!
            error$.raise('JDOC-00005');
        END IF;

        FOR v_i IN 1..p_path_elements.COUNT LOOP
            v_path_signature := v_path_signature || p_path_elements(v_i).type;
        END LOOP;

        IF v_value_request_sqls.EXISTS(v_path_signature) THEN

            v_sql := v_value_request_sqls(v_path_signature);

        ELSE

            v_sql := 'WITH path_values AS
    (SELECT column_value AS value, ROWNUM AS rn
     FROM TABLE(:path_values))
';

            IF p_path_elements.COUNT = 1 AND p_path_elements(1).type = 'R' THEN

                v_sql := v_sql || 'SELECT NULL, ''R'', NULL
FROM dual';

            ELSE

                v_start_level := CASE p_path_elements(1).type WHEN 'R' THEN 2 ELSE 1 END;

                v_sql := v_sql || 'SELECT l' || p_path_elements.COUNT || '.id, l' || p_path_elements.COUNT || '.type, l' || p_path_elements.COUNT || '.value
FROM ';

                FOR v_i IN v_start_level..p_path_elements.COUNT LOOP
                  
                    v_sql := v_sql || v_comma || 'json_values l' || v_i;
                    
                    v_comma := '
    ,';
    
                END LOOP;

                v_sql := v_sql || '
WHERE 1=1';

                IF p_path_elements(1).type = 'R' THEN
                    v_sql := v_sql || '
      AND l2.parent_id IS NULL';
                END IF;

                FOR v_i IN v_start_level..p_path_elements.COUNT LOOP

                    v_sql := v_sql || '
      AND l' || v_i || '.' || field(v_i) || ' = (SELECT value FROM path_values WHERE rn = ' || v_i || ')';

                    IF v_i > v_start_level THEN
                        v_sql := v_sql || '
      AND l' || v_i || '.parent_id = l' || (v_i - 1) || '.id';
                    END IF;

                END LOOP;

            END IF;

            v_value_request_sqls(v_path_signature) := v_sql;

        END IF;

        v_path_values := t_varchars();
        v_path_values.EXTEND(p_path_elements.COUNT);

        FOR v_i IN 1..p_path_elements.COUNT LOOP
            v_path_values(v_i) := p_path_elements(v_i).value;
        END LOOP;

        OPEN p_values
        FOR v_sql
        USING IN v_path_values;

    END;
    
    PROCEDURE request_values
        (p_path IN VARCHAR2
        ,p_values OUT SYS_REFCURSOR) IS
    BEGIN
        request_values(parse_path(p_path), p_values);
    END;
        
    FUNCTION request_values
        (p_path IN VARCHAR2)
    RETURN t_values PIPELINED IS
    
        c_values SYS_REFCURSOR;
        
        v_values t_values;
        c_fetch_limit CONSTANT PLS_INTEGER := 1000;
    
    BEGIN

        request_values(p_path, c_values);
        
        LOOP
        
            v_values := t_values();
            
            FETCH c_values 
            BULK COLLECT INTO v_values
            LIMIT c_fetch_limit;
            
            FOR v_i IN 1..v_values.COUNT LOOP
                PIPE ROW(v_values(v_i));
            END LOOP;
            
            EXIT WHEN v_values.COUNT < c_fetch_limit;
        
        END LOOP;
        
        CLOSE c_values;

    END;
    
    FUNCTION request_value
        (p_path IN VARCHAR2)
    RETURN t_value IS
    
        c_values SYS_REFCURSOR;
        v_values t_values;
    
    BEGIN

        request_values(p_path, c_values);
        
        FETCH c_values
        BULK COLLECT INTO v_values;
        
        CLOSE c_values;
        
        IF v_values.COUNT = 0 THEN
            -- Value :1 does not exist!
            error$.raise('JDOC-00009', p_path);
        ELSIF v_values.COUNT > 1 THEN
            -- Multiple values found at the path :1!
            error$.raise('JDOC-00004', p_path);
        END IF;
        
        RETURN v_values(1);

    END;
    
    FUNCTION get_string
        (p_path IN VARCHAR2)
    RETURN VARCHAR2 IS

        v_value t_value;
    
    BEGIN

        v_value := request_value(p_path);
        
        IF v_value.type IN ('S', 'N', 'E') THEN
            RETURN v_value.value;
        ELSE
            -- Type conversion error!
            error$.raise('JDOC-00010');
        END IF;

    END;
    
    FUNCTION get_number
        (p_path IN VARCHAR2)
    RETURN NUMBER IS
    
        v_value t_value;
    
    BEGIN

        v_value := request_value(p_path);
        
        IF v_value.type IN ('N', 'E') THEN
          
            RETURN v_value.value;
            
        ELSIF v_value.type = 'S' THEN
          
            BEGIN
                RETURN v_value.value;
            EXCEPTION
                WHEN OTHERS THEN
                    -- Type conversion error!
                    error$.raise('JDOC-00010');
            END;
            
        ELSE
          
            -- Type conversion error!
            error$.raise('JDOC-00010');
            
        END IF;

    END;
    
    FUNCTION get_boolean
        (p_path IN VARCHAR2)
    RETURN BOOLEAN IS
    
        v_value t_value;
    
    BEGIN

        v_value := request_value(p_path);

        IF v_value.type IN ('B', 'E') THEN
            RETURN v_value.value = 'true';
        ELSE
            -- Type conversion error!
            error$.raise('JDOC-00010');
        END IF;

    END;
    
    FUNCTION escape_string
        (p_string IN VARCHAR2)
    RETURN VARCHAR2 IS

        v_result VARCHAR2(4000);

    BEGIN

        v_result := REPLACE(p_string, '\', '\\');
        v_result := REPLACE(v_result, '"', '\"');
        v_result := REPLACE(v_result, '/', '\/');
        v_result := REPLACE(v_result, CHR(8), '\b');
        v_result := REPLACE(v_result, CHR(12), '\f');
        v_result := REPLACE(v_result, CHR(10), '\n');
        v_result := REPLACE(v_result, CHR(13), '\r');
        v_result := REPLACE(v_result, CHR(9), '\t');

        RETURN v_result;

    END;
    
    PROCEDURE serialize_value
        (p_parse_events IN json_parser.t_parse_events
        ,p_json IN OUT NOCOPY VARCHAR2
        ,p_json_clob IN OUT NOCOPY CLOB) IS
        
        v_value VARCHAR2(4000);
        v_length PLS_INTEGER;

        TYPE t_booleans IS TABLE OF BOOLEAN;
        v_comma_stack t_booleans;
                
    BEGIN
      
        v_comma_stack := t_booleans(FALSE);
        v_length := 0;

        FOR v_i IN 1..p_parse_events.COUNT LOOP
        
            IF p_parse_events(v_i).name IN ('END_OBJECT', 'END_ARRAY') THEN
               
                p_json := p_json || CASE p_parse_events(v_i).name WHEN 'END_OBJECT' THEN '}' ELSE ']' END;
                
                v_length := v_length + 1;
                v_comma_stack.TRIM(1);
                
            ELSE
            
                IF v_comma_stack(v_comma_stack.COUNT) THEN
                    p_json := p_json || ',';
                    v_length := v_length + 1;
                END IF;
                
                v_comma_stack(v_comma_stack.COUNT) := TRUE;
            
                IF p_parse_events(v_i).name IN ('START_OBJECT', 'START_ARRAY') THEN
                
                    p_json:= p_json || CASE p_parse_events(v_i).name WHEN 'START_OBJECT' THEN '{' ELSE '[' END;
                
                    v_length := v_length + 1;
                                        
                    v_comma_stack.EXTEND(1);
                    v_comma_stack(v_comma_stack.COUNT) := FALSE;
                
                ELSE
                
                    CASE p_parse_events(v_i).name
                    
                        WHEN 'NAME' THEN
                        
                            v_value := escape_string(p_parse_events(v_i).value);
                        
                            p_json := p_json || '"' || v_value || '":';
                            v_length := v_length + 3 + LENGTH(v_value);
                            
                            v_comma_stack(v_comma_stack.COUNT) := FALSE;
                            
                        WHEN 'STRING' THEN
                      
                            v_value := escape_string(p_parse_events(v_i).value);
                                
                            p_json := p_json || '"' || v_value || '"';
                            v_length := v_length + 2 + LENGTH(v_value);
                                
                        WHEN 'NUMBER' THEN
                              
                            p_json := p_json || p_parse_events(v_i).value;
                            v_length := v_length + 2 + LENGTH(p_parse_events(v_i).value);
                                
                        WHEN 'BOOLEAN' THEN
                              
                            p_json := p_json || p_parse_events(v_i).value;
                            v_length := v_length + LENGTH(p_parse_events(v_i).value);
                                
                        WHEN 'NULL' THEN
                              
                            p_json := p_json || 'null';  
                            v_length := v_length + 4;
                    
                    END CASE;
                
                END IF;
                
            END IF;
            
            
            IF p_json_clob IS NOT NULL AND v_length >= 25000 THEN
                
                dbms_lob.append(p_json_clob, p_json);
                    
                p_json := NULL;
                v_length := 0;
                    
            END IF;
            
        
        END LOOP;
        
        IF p_json_clob IS NOT NULL AND p_json IS NOT NULL THEN
            dbms_lob.append(p_json_clob, p_json);
            p_json := NULL;
        END IF;
    
    END;
    
    FUNCTION get_json
        (p_path IN VARCHAR2)
    RETURN VARCHAR2 IS
    
        v_json VARCHAR2(32000);
        v_json_clob CLOB;
    
    BEGIN
      
        serialize_value(get_parse_events(p_path), v_json, v_json_clob);
        
        RETURN v_json;
    
    END;
    
    FUNCTION get_json_clob
        (p_path IN VARCHAR2)
    RETURN CLOB IS
        
        v_json VARCHAR2(32000);
        v_json_clob CLOB;
    
    BEGIN
      
        
        dbms_lob.createtemporary(v_json_clob, TRUE);
        serialize_value(get_parse_events(p_path), v_json, v_json_clob);
        
        RETURN v_json_clob;
    
    END;
    
    PROCEDURE apply_value
        (p_value_row IN json_values%ROWTYPE
        ,p_content_parse_events IN json_parser.t_parse_events
        ,p_event_i IN OUT NOCOPY PLS_INTEGER
        ,p_check_types IN BOOLEAN) IS
        
        v_event json_parser.t_parse_event;
        v_created_ids t_numbers;
        
        v_child_value_name VARCHAR2(4000);
        v_child_value_row json_values%ROWTYPE;
        
        v_item_i PLS_INTEGER;
        
    BEGIN
    
        v_event := p_content_parse_events(p_event_i);
        
        IF p_value_row.type = 'R' AND v_event.name != 'START_OBJECT' THEN
        
            -- Property :1 type mismatch!
            error$.raise('JDOC-00011', p_value_row.name);
        
        ELSIF (p_value_row.type = 'S' AND v_event.name != 'STRING')
           OR (p_value_row.type = 'N' AND v_event.name != 'NUMBER')
           OR (p_value_row.type = 'B' AND v_event.name != 'BOOLEAN')
           OR (p_value_row.type = 'E' AND v_event.name != 'NULL')
           OR (p_value_row.type = 'O' AND v_event.name != 'START_OBJECT')
           OR (p_value_row.type = 'A' AND v_event.name != 'START_ARRAY') THEN
           
           IF p_check_types AND p_value_row.type != 'E' AND v_event.name != 'NULL' THEN
               -- Property :1 type mismatch!
               error$.raise('JDOC-00011', p_value_row.name);
           END IF;
           
           DELETE FROM json_values
           WHERE id = p_value_row.id;
        
           create_json(t_numbers(p_value_row.parent_id), p_value_row.name, p_content_parse_events, p_event_i, v_created_ids);
        
        ELSIF p_value_row.type IN ('S', 'N', 'B') AND p_value_row.value != v_event.value THEN
            
            UPDATE json_values
            SET value = v_event.value
            WHERE id = p_value_row.id;
        
        ELSIF p_value_row.type = 'R' THEN
        
            p_event_i := p_event_i + 1;
            
            WHILE p_content_parse_events(p_event_i).name != 'END_OBJECT' LOOP
            
                v_child_value_name := p_content_parse_events(p_event_i).value;
            
                BEGIN
                
                    SELECT *
                    INTO v_child_value_row
                    FROM json_values
                    WHERE parent_id IS NULL
                          AND name = v_child_value_name;
                
                    p_event_i := p_event_i + 1;
                    
                    apply_value(v_child_value_row, p_content_parse_events, p_event_i, p_check_types);               
                
                EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                    
                        p_event_i := p_event_i + 1;
                        
                        create_json(t_numbers(NULL), v_child_value_name, p_content_parse_events, p_event_i, v_created_ids);
                
                END;
            
                p_event_i := p_event_i + 1;
            
            END LOOP;
        
        ELSIF p_value_row.type = 'O' THEN
        
            p_event_i := p_event_i + 1;
            
            WHILE p_content_parse_events(p_event_i).name != 'END_OBJECT' LOOP
            
                v_child_value_name := p_content_parse_events(p_event_i).value;
            
                BEGIN
                
                    SELECT *
                    INTO v_child_value_row
                    FROM json_values
                    WHERE parent_id = p_value_row.id
                          AND name = v_child_value_name;
                
                    p_event_i := p_event_i + 1;
                    
                    apply_value(v_child_value_row, p_content_parse_events, p_event_i, p_check_types);               
                
                EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                    
                        p_event_i := p_event_i + 1;
                        
                        create_json(t_numbers(p_value_row.id), v_child_value_name, p_content_parse_events, p_event_i, v_created_ids);
                
                END;
            
                p_event_i := p_event_i + 1;
            
            END LOOP;
        
        ELSIF p_value_row.type = 'A' THEN
       
            v_item_i := 0;
            p_event_i := p_event_i + 1;
            
            WHILE p_content_parse_events(p_event_i).name != 'END_ARRAY' LOOP
            
                BEGIN
                
                    SELECT *
                    INTO v_child_value_row
                    FROM json_values
                    WHERE parent_id = p_value_row.id
                          AND name = v_item_i;
                    
                    apply_value(v_child_value_row, p_content_parse_events, p_event_i, p_check_types);               
                
                EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                    
                        create_json(t_numbers(p_value_row.id), v_item_i, p_content_parse_events, p_event_i, v_created_ids);
                
                END;
            
                p_event_i := p_event_i + 1;
                v_item_i := v_item_i + 1;
            
            END LOOP;
    
        END IF;
        
    
    END;
    
    PROCEDURE apply_json
        (p_path IN VARCHAR2
        ,p_content_parse_events json_parser.t_parse_events
        ,p_check_types IN BOOLEAN) IS
        
        c_values SYS_REFCURSOR;
        v_values t_values;
        
        v_value_row json_values%ROWTYPE;
        
        v_event_i PLS_INTEGER;
    
    BEGIN

        request_values(p_path, c_values);
        
        FETCH c_values
        BULK COLLECT INTO v_values;
        
        CLOSE c_values;
        
        IF v_values.COUNT = 0 THEN
            -- Value :1 does not exist!
            error$.raise('JDOC-00009', p_path);
        END IF;
        
        FOR v_i IN 1..v_values.COUNT LOOP
        
            IF v_values(v_i).type = 'R' THEN
            
                v_value_row := NULL;
                v_value_row.type := 'R';
                v_value_row.name := '$';
                
            ELSE
            
                SELECT *
                INTO v_value_row
                FROM json_values
                WHERE id = v_values(v_i).id;
                
            END IF;
            
            v_event_i := 1;
        
            apply_value(v_value_row, p_content_parse_events, v_event_i, p_check_types);
            
        END LOOP;
    
    END;
    
    PROCEDURE apply_json
        (p_path IN VARCHAR2,
         -- @json
         p_content IN VARCHAR2
        ,p_check_types IN BOOLEAN := FALSE) IS
    BEGIN
        apply_json(p_path, json_parser.parse(p_content), p_check_types);
    END;
        
    PROCEDURE apply_json_clob
        (p_path IN VARCHAR2,
         -- @json
         p_content IN VARCHAR2
        ,p_check_types IN BOOLEAN := FALSE) IS
    BEGIN
        apply_json(p_path, json_parser.parse(p_content), p_check_types);
    END;
    
    FUNCTION get_length
        (p_array_id IN NUMBER)
    RETURN NUMBER IS
    
        v_length NUMBER;
    
    BEGIN
    
        SELECT MAX(to_index(name))
        INTO v_length
        FROM json_values
        WHERE parent_id = p_array_id;
        
        RETURN v_length + 1;
    
    END; 
        
    
    FUNCTION get_length
        (p_path IN VARCHAR2)
    RETURN NUMBER IS
    
        v_array t_value;
                
    BEGIN
    
        v_array := request_value(p_path);
        
        IF v_array.type != 'A' THEN
            -- :1 is not an array!
            error$.raise('JDOC-00012', p_path);
        END IF;
        
        RETURN get_length(v_array.id);
    
    END;
    
    
    FUNCTION push_property
        (p_path IN VARCHAR2
        ,p_content_parse_events IN json_parser.t_parse_events
        ,p_exact IN BOOLEAN := TRUE)
    RETURN t_numbers IS
    
        c_values SYS_REFCURSOR;
        v_values t_values;
        
        v_ids t_numbers;
        v_all_ids t_numbers;
    
    BEGIN
    
        request_values(p_path, c_values);
    
        FETCH c_values
        BULK COLLECT INTO v_values;
        
        CLOSE c_values;
        
        IF p_exact AND v_values.COUNT > 1 THEN
            -- Multiple values found at the path :1!
            error$.raise('JDOC-00004', p_path);
        ELSIF v_values.COUNT = 0 THEN
            -- Value :1 does not exist
            error$.raise('JDOC-00009', p_path);
        END IF;
    
        v_all_ids := t_numbers();
        
        FOR v_i IN 1..v_values.COUNT LOOP
            
            IF v_values(v_i).type != 'A' THEN
                -- Requested target is not an array!
                error$.raise('JDOC-00014');
            END IF;
            
            v_ids := create_json(
                t_numbers(v_values(v_i).id)
               ,get_length(v_values(v_i).id) 
               ,p_content_parse_events);
            
            FOR v_i IN 1..v_ids.COUNT LOOP
                v_all_ids.EXTEND(1);
                v_all_ids(v_all_ids.COUNT) := v_ids(v_i);
            END LOOP;
        
        END LOOP;
    
        RETURN v_all_ids;
        
    END;
    
    FUNCTION push_string
        (p_path IN VARCHAR2
        ,p_value IN VARCHAR2)
    RETURN NUMBER IS
    BEGIN

        RETURN push_property(p_path, string_events(p_value))(1);

    END;
    
    PROCEDURE push_string
        (p_path IN VARCHAR2
        ,p_value IN VARCHAR2) IS
        
        v_dummy NUMBER;
        
    BEGIN
        v_dummy := push_string(p_path, p_value);
    END;
   
    FUNCTION push_number
        (p_path IN VARCHAR2
        ,p_value IN NUMBER)
    RETURN NUMBER IS
    BEGIN

        RETURN push_property(p_path, number_events(p_value))(1);

    END;
    
    PROCEDURE push_number
        (p_path IN VARCHAR2
        ,p_value IN NUMBER) IS
        
        v_dummy NUMBER;
        
    BEGIN
        v_dummy := push_number(p_path, p_value);
    END;
    
    FUNCTION push_boolean
        (p_path IN VARCHAR2
        ,p_value IN BOOLEAN)
    RETURN NUMBER IS
    BEGIN

        RETURN push_property(p_path, boolean_events(p_value))(1);

    END;
    
    PROCEDURE push_boolean
        (p_path IN VARCHAR2
        ,p_value IN BOOLEAN) IS
        
        v_dummy NUMBER;
        
    BEGIN
        v_dummy := push_boolean(p_path, p_value);
    END;
    
    FUNCTION push_null
        (p_path IN VARCHAR2)
    RETURN NUMBER IS
    BEGIN

        RETURN push_property(p_path, null_events)(1);

    END;
        
    PROCEDURE push_null
        (p_path IN VARCHAR2) IS
        
        v_dummy NUMBER;
        
    BEGIN
        v_dummy := push_null(p_path);
    END;
    
    FUNCTION push_object
        (p_path IN VARCHAR2)
    RETURN NUMBER IS
    BEGIN

        RETURN push_property(p_path, object_events)(1);

    END;
        
    PROCEDURE push_object
        (p_path IN VARCHAR2) IS
        
        v_dummy NUMBER;
        
    BEGIN
        v_dummy := push_object(p_path);
    END;
        
    FUNCTION push_array
        (p_path IN VARCHAR2)
    RETURN NUMBER IS
    BEGIN

        RETURN push_property(p_path, array_events)(1);

    END;
        
    PROCEDURE push_array
        (p_path IN VARCHAR2) IS
        
        v_dummy NUMBER;
        
    BEGIN
        v_dummy := push_array(p_path);
    END;
        
    FUNCTION push_json
        (p_path IN VARCHAR2
        ,p_content IN VARCHAR2)
    RETURN NUMBER IS
    BEGIN
    
        RETURN push_property(p_path, json_parser.parse(p_content))(1);
    
    END;
        
    PROCEDURE push_json
        (p_path IN VARCHAR2
        ,p_content IN VARCHAR2) IS
        
        v_dummy NUMBER;
        
    BEGIN
        v_dummy := push_json(p_path, p_content);
    END;
        
    FUNCTION push_json_clob
        (p_path IN VARCHAR2
        ,p_content IN CLOB)
    RETURN NUMBER IS
    BEGIN
    
        RETURN push_property(p_path, json_parser.parse(p_content))(1);
    
    END;
        
    PROCEDURE push_json_clob
        (p_path IN VARCHAR2
        ,p_content IN CLOB) IS
        
        v_dummy NUMBER;
        
    BEGIN
        v_dummy := push_json(p_path, p_content);
    END;
    
    PROCEDURE delete_value
        (p_path IN VARCHAR2) IS
        
        c_properties SYS_REFCURSOR;
        v_properties t_properties;
        
        v_value t_value;
        
    BEGIN
    
        request_properties(p_path, c_properties);
        
        FETCH c_properties
        BULK COLLECT INTO v_properties;
        
        CLOSE c_properties;
        
        IF v_properties.COUNT > 1 THEN
            -- Multiple values found at the path :1!
            error$.raise('JDOC-00004', p_path);
        ELSIF v_properties.COUNT = 0 OR v_properties(v_properties.COUNT).property_id IS NULL THEN
            -- Value :1 does not exist!
            error$.raise('JDOC-00009', p_path);
        END IF;
        
        FOR v_i IN 1..v_properties.COUNT LOOP
            
            DELETE FROM json_values
            WHERE id = v_properties(v_i).property_id;
        
            IF v_properties(v_i).parent_type = 'A' THEN
            
                INSERT INTO json_values(id, parent_id, type, name)
                VALUES(jsvl_id.NEXTVAL, v_properties(v_i).parent_id, 'E', v_properties(v_i).property_name);
            
            END IF;
        
        END LOOP;

    
    END;
    
    FUNCTION get_parse_events
        (p_path IN VARCHAR2)
    RETURN json_parser.t_parse_events IS
    
        v_path_value t_value;
        
        TYPE t_chars IS TABLE OF CHAR;
        v_json_stack t_chars;
        
        v_last_lvl PLS_INTEGER;
        
        v_events json_parser.t_parse_events;
    
        CURSOR c_values (p_root_id IN NUMBER) IS
            WITH parent_jsvl(id, type, name, value, lvl, ord) AS
                (SELECT id
                       ,type
                       ,name
                       ,value
                       ,1 AS lvl
                       ,0
                 FROM json_values
                 WHERE id = p_root_id
                 UNION ALL
                 SELECT jsvl.id
                       ,jsvl.type
                       ,jsvl.name
                       ,jsvl.value
                       ,parent_jsvl.lvl + 1
                       ,CASE parent_jsvl.type
                            WHEN 'A' THEN
                                TO_NUMBER(jsvl.name)
                            ELSE
                                jsvl.id
                        END
                 FROM parent_jsvl
                     ,json_values jsvl
                 WHERE jsvl.parent_id = parent_jsvl.id
                 ORDER BY 6)
            SEARCH DEPTH FIRST BY ord SET dummy
            SELECT type
                  ,name
                  ,value
                  ,lvl
            FROM parent_jsvl;
            
        PROCEDURE add_event
            (p_name IN VARCHAR2
            ,p_value IN VARCHAR2 := NULL) IS
        BEGIN
        
            v_events.EXTEND(1);
            
            v_events(v_events.COUNT).name := p_name;
            v_events(v_events.COUNT).value := p_value;        
        END;
                
    BEGIN
        
        v_path_value := request_value(p_path);
    
        v_events := json_parser.t_parse_events();
        v_json_stack := t_chars();
        v_last_lvl := 0;
    
        FOR v_value IN c_values(v_path_value.id) LOOP
        
            FOR v_i IN v_value.lvl..v_last_lvl LOOP
                  
                IF v_json_stack(v_json_stack.COUNT) = 'O' THEN
                    add_event('END_OBJECT');                        
                ELSIF v_json_stack(v_json_stack.COUNT) = 'A' THEN
                    add_event('END_ARRAY');
                END IF;
                    
                v_json_stack.TRIM(1);   
                    
            END LOOP;
            
            IF v_value.name IS NOT NULL 
               AND v_json_stack.COUNT > 0
               AND v_json_stack(v_json_stack.COUNT) = 'O' THEN

                add_event('NAME', v_value.name);
                   
            END IF;
            
            CASE v_value.type
                  
                WHEN 'S' THEN
                    add_event('STRING', v_value.value);  
                WHEN 'N' THEN
                    add_event('NUMBER', v_value.value);  
                WHEN 'B' THEN
                    add_event('BOOLEAN', v_value.value);
                WHEN 'E' THEN
                    add_event('NULL');
                WHEN 'O' THEN
                    add_event('START_OBJECT');
                WHEN 'A' THEN
                    add_event('START_ARRAY');
                
            END CASE;
            
            v_json_stack.EXTEND(1);
            v_json_stack(v_json_stack.COUNT) := v_value.type;
                
            v_last_lvl := v_value.lvl;
        
        END LOOP;
        
        FOR v_i IN REVERSE 1..v_json_stack.COUNT LOOP
          
             IF v_json_stack(v_i) = 'O' THEN
                 add_event('END_OBJECT');    
             ELSIF v_json_stack(v_i) = 'A' THEN
                 add_event('END_ARRAY');
             END IF;
        
        END LOOP;
    
        RETURN v_events;
    
    END;
    
    PROCEDURE get_json_table
        (p_paths IN t_varchars
        ,p_rows IN OUT NOCOPY t_t_varchars) IS
    BEGIN
    
        p_rows := t_t_varchars();
    
    END;
    
    FUNCTION get_json_table
        (p_paths IN t_varchars)
    RETURN t_t_varchars PIPELINED IS
    
        v_rows t_t_varchars;
    
    BEGIN
    
        get_json_table(p_paths, v_rows);
    
        FOR v_i IN 1..v_rows.COUNT LOOP
            PIPE ROW(v_rows(v_i));
        END LOOP;
        
        RETURN;
    
    END;     

    FUNCTION get_json_table
        (p_path IN VARCHAR2)
    RETURN t_varchars PIPELINED IS
    
        v_rows t_t_varchars;
    
    BEGIN
    
        get_json_table(t_varchars(p_path), v_rows);
        
        FOR v_i IN 1..v_rows.COUNT LOOP
            PIPE ROW(v_rows(v_i)(1));
        END LOOP;
        
        RETURN;
    
    END;
    
    FUNCTION get_json_table
        (p_path_1 IN VARCHAR2
        ,p_path_2 IN VARCHAR2)
    RETURN t_json_table_2 PIPELINED IS
    
        v_rows t_t_varchars;
        v_row t_json_table_row_2;
    
    BEGIN
    
        get_json_table(
            t_varchars(
                p_path_1
               ,p_path_2
            )
           ,v_rows
        );
        
        FOR v_i IN 1..v_rows.COUNT LOOP
        
            v_row.column_1_value := v_rows(v_i)(1); 
            v_row.column_2_value := v_rows(v_i)(2);
        
            PIPE ROW(v_row);
            
        END LOOP;
        
        RETURN;
    
    END;
    
    FUNCTION get_json_table
        (p_path_1 IN VARCHAR2
        ,p_path_2 IN VARCHAR2
        ,p_path_3 IN VARCHAR2)
    RETURN t_json_table_3 PIPELINED IS
    
        v_rows t_t_varchars;
        v_row t_json_table_row_3;
    
    BEGIN
    
        get_json_table(
            t_varchars(
                p_path_1
               ,p_path_2
               ,p_path_3
            )
           ,v_rows
        );
        
        FOR v_i IN 1..v_rows.COUNT LOOP
        
            v_row.column_1_value := v_rows(v_i)(1); 
            v_row.column_2_value := v_rows(v_i)(2);
            v_row.column_3_value := v_rows(v_i)(3);
        
            PIPE ROW(v_row);
            
        END LOOP;
        
        RETURN;
    
    END;
    
    FUNCTION get_json_table
        (p_path_1 IN VARCHAR2
        ,p_path_2 IN VARCHAR2
        ,p_path_3 IN VARCHAR2
        ,p_path_4 IN VARCHAR2)
    RETURN t_json_table_4 PIPELINED IS
    
        v_rows t_t_varchars;
        v_row t_json_table_row_4;
    
    BEGIN
    
        get_json_table(
            t_varchars(
                p_path_1
               ,p_path_2
               ,p_path_3
               ,p_path_4
            )
           ,v_rows
        );
        
        FOR v_i IN 1..v_rows.COUNT LOOP
        
            v_row.column_1_value := v_rows(v_i)(1); 
            v_row.column_2_value := v_rows(v_i)(2);
            v_row.column_3_value := v_rows(v_i)(3);
            v_row.column_4_value := v_rows(v_i)(4);
        
            PIPE ROW(v_row);
            
        END LOOP;
        
        RETURN;
    
    END;
    
    FUNCTION get_json_table
        (p_path_1 IN VARCHAR2
        ,p_path_2 IN VARCHAR2
        ,p_path_3 IN VARCHAR2
        ,p_path_4 IN VARCHAR2
        ,p_path_5 IN VARCHAR2)
    RETURN t_json_table_5 PIPELINED IS
    
        v_rows t_t_varchars;
        v_row t_json_table_row_5;
    
    BEGIN
    
        get_json_table(
            t_varchars(
                p_path_1
               ,p_path_2
               ,p_path_3
               ,p_path_4
               ,p_path_5
            )
           ,v_rows
        );
        
        FOR v_i IN 1..v_rows.COUNT LOOP
        
            v_row.column_1_value := v_rows(v_i)(1); 
            v_row.column_2_value := v_rows(v_i)(2);
            v_row.column_3_value := v_rows(v_i)(3);
            v_row.column_4_value := v_rows(v_i)(4);
            v_row.column_5_value := v_rows(v_i)(5);
        
            PIPE ROW(v_row);
            
        END LOOP;
        
        RETURN;
    
    END;
    
    FUNCTION get_json_table
        (p_path_1 IN VARCHAR2
        ,p_path_2 IN VARCHAR2
        ,p_path_3 IN VARCHAR2
        ,p_path_4 IN VARCHAR2
        ,p_path_5 IN VARCHAR2
        ,p_path_6 IN VARCHAR2)
    RETURN t_json_table_6 PIPELINED IS
    
        v_rows t_t_varchars;
        v_row t_json_table_row_6;
    
    BEGIN
    
        get_json_table(
            t_varchars(
                p_path_1
               ,p_path_2
               ,p_path_3
               ,p_path_4
               ,p_path_5
               ,p_path_6
            )
           ,v_rows
        );
        
        FOR v_i IN 1..v_rows.COUNT LOOP
        
            v_row.column_1_value := v_rows(v_i)(1); 
            v_row.column_2_value := v_rows(v_i)(2);
            v_row.column_3_value := v_rows(v_i)(3);
            v_row.column_4_value := v_rows(v_i)(4);
            v_row.column_5_value := v_rows(v_i)(5);
            v_row.column_6_value := v_rows(v_i)(6);
        
            PIPE ROW(v_row);
            
        END LOOP;
        
        RETURN;
    
    END;
    
    FUNCTION get_json_table
        (p_path_1 IN VARCHAR2
        ,p_path_2 IN VARCHAR2
        ,p_path_3 IN VARCHAR2
        ,p_path_4 IN VARCHAR2
        ,p_path_5 IN VARCHAR2
        ,p_path_6 IN VARCHAR2
        ,p_path_7 IN VARCHAR2)
    RETURN t_json_table_7 PIPELINED IS
    
        v_rows t_t_varchars;
        v_row t_json_table_row_7;
    
    BEGIN
    
        get_json_table(
            t_varchars(
                p_path_1
               ,p_path_2
               ,p_path_3
               ,p_path_4
               ,p_path_5
               ,p_path_6
               ,p_path_7
            )
           ,v_rows
        );
        
        FOR v_i IN 1..v_rows.COUNT LOOP
        
            v_row.column_1_value := v_rows(v_i)(1); 
            v_row.column_2_value := v_rows(v_i)(2);
            v_row.column_3_value := v_rows(v_i)(3);
            v_row.column_4_value := v_rows(v_i)(4);
            v_row.column_5_value := v_rows(v_i)(5);
            v_row.column_6_value := v_rows(v_i)(6);
            v_row.column_7_value := v_rows(v_i)(7);
        
            PIPE ROW(v_row);
            
        END LOOP;
        
        RETURN;
        
    END;
    
    FUNCTION get_json_table
        (p_path_1 IN VARCHAR2
        ,p_path_2 IN VARCHAR2
        ,p_path_3 IN VARCHAR2
        ,p_path_4 IN VARCHAR2
        ,p_path_5 IN VARCHAR2
        ,p_path_6 IN VARCHAR2
        ,p_path_7 IN VARCHAR2
        ,p_path_8 IN VARCHAR2)
    RETURN t_json_table_8 PIPELINED IS
    
        v_rows t_t_varchars;
        v_row t_json_table_row_8;
    
    BEGIN
    
        get_json_table(
            t_varchars(
                p_path_1
               ,p_path_2
               ,p_path_3
               ,p_path_4
               ,p_path_5
               ,p_path_6
               ,p_path_7
               ,p_path_8
            )
           ,v_rows
        );
        
        FOR v_i IN 1..v_rows.COUNT LOOP
        
            v_row.column_1_value := v_rows(v_i)(1); 
            v_row.column_2_value := v_rows(v_i)(2);
            v_row.column_3_value := v_rows(v_i)(3);
            v_row.column_4_value := v_rows(v_i)(4);
            v_row.column_5_value := v_rows(v_i)(5);
            v_row.column_6_value := v_rows(v_i)(6);
            v_row.column_7_value := v_rows(v_i)(7);
            v_row.column_8_value := v_rows(v_i)(8);
        
            PIPE ROW(v_row);
            
        END LOOP;
        
        RETURN;
        
    END;
    
    FUNCTION get_json_table
        (p_path_1 IN VARCHAR2
        ,p_path_2 IN VARCHAR2
        ,p_path_3 IN VARCHAR2
        ,p_path_4 IN VARCHAR2
        ,p_path_5 IN VARCHAR2
        ,p_path_6 IN VARCHAR2
        ,p_path_7 IN VARCHAR2
        ,p_path_8 IN VARCHAR2
        ,p_path_9 IN VARCHAR2)
    RETURN t_json_table_9 PIPELINED IS
    
        v_rows t_t_varchars;
        v_row t_json_table_row_9;
    
    BEGIN
    
        get_json_table(
            t_varchars(
                p_path_1
               ,p_path_2
               ,p_path_3
               ,p_path_4
               ,p_path_5
               ,p_path_6
               ,p_path_7
               ,p_path_8
               ,p_path_9
            )
           ,v_rows
        );
        
        FOR v_i IN 1..v_rows.COUNT LOOP
        
            v_row.column_1_value := v_rows(v_i)(1); 
            v_row.column_2_value := v_rows(v_i)(2);
            v_row.column_3_value := v_rows(v_i)(3);
            v_row.column_4_value := v_rows(v_i)(4);
            v_row.column_5_value := v_rows(v_i)(5);
            v_row.column_6_value := v_rows(v_i)(6);
            v_row.column_7_value := v_rows(v_i)(7);
            v_row.column_8_value := v_rows(v_i)(8);
            v_row.column_9_value := v_rows(v_i)(9);
        
            PIPE ROW(v_row);
            
        END LOOP;
        
        RETURN;
        
    END;
    
    FUNCTION get_json_table
        (p_path_1 IN VARCHAR2
        ,p_path_2 IN VARCHAR2
        ,p_path_3 IN VARCHAR2
        ,p_path_4 IN VARCHAR2
        ,p_path_5 IN VARCHAR2
        ,p_path_6 IN VARCHAR2
        ,p_path_7 IN VARCHAR2
        ,p_path_8 IN VARCHAR2
        ,p_path_9 IN VARCHAR2
        ,p_path_10 IN VARCHAR2)
    RETURN t_json_table_10 PIPELINED IS
    
        v_rows t_t_varchars;
        v_row t_json_table_row_10;
    
    BEGIN
    
        get_json_table(
            t_varchars(
                p_path_1
               ,p_path_2
               ,p_path_3
               ,p_path_4
               ,p_path_5
               ,p_path_6
               ,p_path_7
               ,p_path_8
               ,p_path_9
               ,p_path_10
            )
           ,v_rows
        );
        
        FOR v_i IN 1..v_rows.COUNT LOOP
        
            v_row.column_1_value := v_rows(v_i)(1); 
            v_row.column_2_value := v_rows(v_i)(2);
            v_row.column_3_value := v_rows(v_i)(3);
            v_row.column_4_value := v_rows(v_i)(4);
            v_row.column_5_value := v_rows(v_i)(5);
            v_row.column_6_value := v_rows(v_i)(6);
            v_row.column_7_value := v_rows(v_i)(7);
            v_row.column_8_value := v_rows(v_i)(8);
            v_row.column_9_value := v_rows(v_i)(9);
            v_row.column_10_value := v_rows(v_i)(10);
        
            PIPE ROW(v_row);
            
        END LOOP;
        
        RETURN;
        
    END;

BEGIN
    register_messages;
END;

