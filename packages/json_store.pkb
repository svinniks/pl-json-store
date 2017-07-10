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
        log$.register_message('JDOC-00001', 'Unexpected character ":1"!');
        log$.register_message('JDOC-00002', 'Unexpected end of the input!');
        log$.register_message('JDOC-00003', 'Root can''t be modified!');
        log$.register_message('JDOC-00004', 'Multiple values found at the path :1!');
        log$.register_message('JDOC-00005', 'Empty path specified!');
        log$.register_message('JDOC-00006', 'Root requested as a property!');
        log$.register_message('JDOC-00007', 'No container for property at path :1 could be found!');
        log$.register_message('JDOC-00008', 'Scalar values and null can''t have properties!');
        log$.register_message('JDOC-00009', 'Value :1 does not exist!');
        log$.register_message('JDOC-00010', 'Type conversion error!');
    END;

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

    FUNCTION create_json
        (p_parent_ids IN t_numbers
        ,p_name IN VARCHAR2
        ,p_content_parse_events IN json_parser.t_parse_events
        ,p_id IN NUMBER := NULL)
    RETURN t_numbers IS

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

        v_created_ids := t_numbers();

        FOR v_i IN 1..p_parent_ids.COUNT LOOP

            v_event_i := 1;

            v_created_ids.EXTEND(1);
            v_created_ids(v_created_ids.COUNT) := create_value(p_parent_ids(v_i), p_name, p_id);

        END LOOP;

        flush_values;

        FOR v_i IN 1..v_created_ids.COUNT LOOP
            IF v_id_map.EXISTS(v_created_ids(v_i)) THEN
                v_created_ids(v_i) := v_id_map(v_created_ids(v_i));
            END IF;
        END LOOP;

        RETURN v_created_ids;

    END;

    FUNCTION create_json
        (p_content IN VARCHAR2)
    RETURN NUMBER IS
    BEGIN
        RETURN create_json(t_numbers(NULL), NULL, json_parser.parse(p_content))(1);
    END;
    
    FUNCTION create_json_clob
        (p_content IN CLOB)
    RETURN NUMBER IS
    BEGIN
        RETURN create_json(t_numbers(NULL), NULL, json_parser.parse(p_content))(1);
    END;

    FUNCTION create_string
        (p_value IN VARCHAR2)
    RETURN NUMBER IS

        v_parse_event json_parser.t_parse_event;

    BEGIN

        v_parse_event.name := CASE WHEN p_value IS NULL THEN 'NULL' ELSE 'STRING' END;
        v_parse_event.value := p_value;

        RETURN create_json(t_numbers(NULL), NULL, json_parser.t_parse_events(v_parse_event))(1);

    END;

    FUNCTION create_number
        (p_value IN NUMBER)
    RETURN NUMBER IS

        v_parse_event json_parser.t_parse_event;

    BEGIN

        v_parse_event.name := CASE WHEN p_value IS NULL THEN 'NULL' ELSE 'NUMBER' END;
        v_parse_event.value := p_value;

        RETURN create_json(t_numbers(NULL), NULL, json_parser.t_parse_events(v_parse_event))(1);

    END;

    FUNCTION create_boolean
        (p_value IN BOOLEAN)
    RETURN NUMBER IS

        v_parse_event json_parser.t_parse_event;

    BEGIN

        v_parse_event.name := CASE WHEN p_value IS NULL THEN 'NULL' ELSE 'BOOLEAN' END;
        v_parse_event.value := CASE WHEN p_value THEN 'true' ELSE 'false' END;

        RETURN create_json(t_numbers(NULL), NULL, json_parser.t_parse_events(v_parse_event))(1);

    END;

    FUNCTION create_null
    RETURN NUMBER IS

        v_parse_event json_parser.t_parse_event;

    BEGIN

        v_parse_event.name := 'NULL';

        RETURN create_json(t_numbers(NULL), NULL, json_parser.t_parse_events(v_parse_event))(1);

    END;

    FUNCTION create_object
    RETURN NUMBER IS

        v_start_event json_parser.t_parse_event;
        v_end_event json_parser.t_parse_event;

    BEGIN

        v_start_event.name := 'START_OBJECT';
        v_end_event.name := 'END_OBJECT';

        RETURN create_json(t_numbers(NULL), NULL, json_parser.t_parse_events(v_start_event, v_end_event))(1);

    END;

    FUNCTION create_array
    RETURN NUMBER IS

        v_start_event json_parser.t_parse_event;
        v_end_event json_parser.t_parse_event;

    BEGIN

        v_start_event.name := 'START_ARRAY';
        v_end_event.name := 'END_ARRAY';

        RETURN create_json(t_numbers(NULL), NULL, json_parser.t_parse_events(v_start_event, v_end_event))(1);

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

        v_existing_ids := t_numbers();
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

        END LOOP;

        IF v_existing_ids.COUNT > 0 THEN

            FORALL v_i IN 1..v_existing_ids.COUNT
                DELETE FROM json_values
                WHERE id = v_existing_ids(v_i);

        END IF;

        IF v_path_elements(v_path_elements.COUNT).type = 'N' THEN
          
            RETURN create_json(v_parent_ids, v_path_elements(v_path_elements.COUNT).value, p_content_parse_events);
            
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
    
    FUNCTION set_json_clob
        (p_path IN VARCHAR2
        ,p_content IN CLOB)
    RETURN NUMBER IS
    BEGIN
        RETURN set_property(p_path, json_parser.parse(p_content))(1);
    END;

    FUNCTION set_string
        (p_path IN VARCHAR2
        ,p_value IN VARCHAR2)
    RETURN NUMBER IS

        v_parse_event json_parser.t_parse_event;

    BEGIN

        v_parse_event.name := 'STRING';
        v_parse_event.value := p_value;

        RETURN set_property(p_path, json_parser.t_parse_events(v_parse_event))(1);

    END;

    FUNCTION set_number
        (p_path IN VARCHAR2
        ,p_value IN NUMBER)
    RETURN NUMBER IS

        v_parse_event json_parser.t_parse_event;

    BEGIN

        v_parse_event.name := 'NUMBER';
        v_parse_event.value := p_value;

        RETURN set_property(p_path, json_parser.t_parse_events(v_parse_event))(1);

    END;

    FUNCTION set_boolean
        (p_path IN VARCHAR2
        ,p_value IN BOOLEAN)
    RETURN NUMBER IS

        v_parse_event json_parser.t_parse_event;

    BEGIN

        v_parse_event.name := 'BOOLEAN';
        v_parse_event.value := CASE WHEN p_value THEN 'true' ELSE 'false' END;

        RETURN set_property(p_path, json_parser.t_parse_events(v_parse_event))(1);

    END;

    FUNCTION set_null
        (p_path IN VARCHAR2)
    RETURN NUMBER IS

        v_parse_event json_parser.t_parse_event;

    BEGIN

        v_parse_event.name := 'NULL';

        RETURN set_property(p_path, json_parser.t_parse_events(v_parse_event))(1);

    END;

    FUNCTION set_object
        (p_path IN VARCHAR2)
    RETURN NUMBER IS

        v_start_event json_parser.t_parse_event;
        v_end_event json_parser.t_parse_event;

    BEGIN

        v_start_event.name := 'START_OBJECT';
        v_end_event.name := 'END_OBJECT';

        RETURN set_property(p_path, json_parser.t_parse_events(v_start_event, v_end_event))(1);

    END;

    FUNCTION set_array
        (p_path IN VARCHAR2)
    RETURN NUMBER IS

        v_start_event json_parser.t_parse_event;
        v_end_event json_parser.t_parse_event;

    BEGIN

        v_start_event.name := 'START_ARRAY';
        v_end_event.name := 'END_ARRAY';

        RETURN set_property(p_path, json_parser.t_parse_events(v_start_event, v_end_event))(1);

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
        (p_id IN NUMBER
        ,p_json IN OUT NOCOPY VARCHAR2
        ,p_json_clob IN OUT NOCOPY CLOB) IS
        
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
            SELECT *
            FROM parent_jsvl;

        v_value VARCHAR2(4000);
        v_length PLS_INTEGER;

        TYPE t_values IS TABLE OF c_values%ROWTYPE;
        v_values t_values;
        c_fetch_limit CONSTANT PLS_INTEGER := 1000;
        
        TYPE t_chars IS TABLE OF CHAR;
        v_json_stack t_chars;
        v_element_count_stack t_numbers;
        
        v_last_lvl PLS_INTEGER;
        
    BEGIN
      
        v_json_stack := t_chars();
        v_element_count_stack := t_numbers(1);
        v_last_lvl := 0;
        v_length := 0;
    
        OPEN c_values(p_id);
      
        LOOP
        
            v_values := t_values();
            
            FETCH c_values
            BULK COLLECT INTO v_values
            LIMIT c_fetch_limit;
            
            FOR v_i IN 1..v_values.COUNT LOOP
                
                FOR v_j IN v_values(v_i).lvl..v_last_lvl LOOP
                  
                    IF v_json_stack(v_json_stack.COUNT) = 'O' THEN
                        p_json := p_json || '}';
                        v_length := v_length + 1;    
                    ELSIF v_json_stack(v_json_stack.COUNT) = 'A' THEN
                        p_json := p_json || ']';
                        v_length := v_length + 1;
                    END IF;
                    
                    v_json_stack.TRIM(1);   
                    v_element_count_stack.TRIM(1);   
                    
                END LOOP;
            
                IF v_element_count_stack(v_element_count_stack.COUNT) > 1 THEN
                    p_json := p_json || ',';
                    v_length := v_length + 1;
                END IF;
            
                IF v_values(v_i).name IS NOT NULL 
                   AND v_json_stack.COUNT > 0
                   AND v_json_stack(v_json_stack.COUNT) = 'O' THEN
                   
                    IF REGEXP_LIKE(LOWER(v_values(v_i).name), '^[a-z][a-z0-9_\&]*$') THEN
                    
                        p_json := p_json || '"' || v_values(v_i).name || '":';
                        v_length := v_length + 3 + LENGTH(v_values(v_i).name);
                        
                    ELSE
                    
                        v_value := escape_string(v_values(v_i).name);
                        
                        p_json := p_json || '"' || v_value || '":';
                        v_length := v_length + LENGTH(v_value);
                        
                    END IF;
                    
                END IF;
            
                CASE v_values(v_i).type
                  
                    WHEN 'S' THEN
                      
                        v_value := escape_string(v_values(v_i).value);
                        
                        p_json := p_json || '"' || v_value || '"';
                        v_length := v_length + 2 + LENGTH(v_value);
                        
                    WHEN 'N' THEN
                      
                        p_json := p_json || v_values(v_i).value;
                        v_length := v_length + 2 + LENGTH(v_values(v_i).value);
                        
                    WHEN 'B' THEN
                      
                        p_json := p_json || v_values(v_i).value;
                        v_length := v_length + 2 + LENGTH(v_values(v_i).value);
                        
                    WHEN 'E' THEN
                      
                        p_json := p_json || 'null';  
                        v_length := v_length + 4;
                        
                    WHEN 'O' THEN
                      
                        p_json := p_json || '{';
                        v_length := v_length + 1;
                        
                    WHEN 'A' THEN
                      
                        p_json := p_json || '[';
                        v_length := v_length + 1;
                
                END CASE;
                
                v_element_count_stack(v_element_count_stack.COUNT) := v_element_count_stack(v_element_count_stack.COUNT) + 1;
                
                v_json_stack.EXTEND(1);
                v_json_stack(v_json_stack.COUNT) := v_values(v_i).type;
                
                v_element_count_stack.EXTEND(1);
                v_element_count_stack(v_element_count_stack.COUNT) := 1;
                
                v_last_lvl := v_values(v_i).lvl;
                
                IF p_json_clob IS NOT NULL AND v_length >= 25000 THEN
                
                    dbms_lob.append(p_json_clob, p_json);
                    
                    p_json := NULL;
                    v_length := 0;
                    
                END IF;
            
            END LOOP;
            
            EXIT WHEN v_values.COUNT < c_fetch_limit;  
        
        END LOOP;
        
        CLOSE c_values;
        
        FOR v_i IN REVERSE 1..v_json_stack.COUNT LOOP
          
             IF v_json_stack(v_i) = 'O' THEN
                 p_json := p_json || '}';    
             ELSIF v_json_stack(v_i) = 'A' THEN
                 p_json := p_json || ']';
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
    
        v_value t_value;
        
        v_json VARCHAR2(32000);
        v_json_clob CLOB;
    
    BEGIN
      
        v_value := request_value(p_path);
        
        serialize_value(v_value.id, v_json, v_json_clob);
        
        RETURN v_json;
    
    END;
    
    FUNCTION get_json_clob
        (p_path IN VARCHAR2)
    RETURN CLOB IS
    
        v_value t_value;
        v_json VARCHAR2(32000);
        v_json_clob CLOB;
    
    BEGIN
      
        v_value := request_value(p_path);
        
        dbms_lob.createtemporary(v_json_clob, TRUE);
        serialize_value(v_value.id, v_json, v_json_clob);
        
        RETURN v_json_clob;
    
    END;

BEGIN
    register_messages;
END;
/
