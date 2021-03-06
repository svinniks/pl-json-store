CREATE OR REPLACE PACKAGE BODY persistent_json_writer IS

    /* 
        Copyright 2018 Sergejs Vinniks

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

    v_tmp_id NUMBER := 0;
    
    v_released_tmp_ids t_numbers := t_numbers();
    v_released_tmp_ids_size PLS_INTEGER := 0;

    TYPE t_id_map IS
        TABLE OF NUMBER
        INDEX BY PLS_INTEGER;
        
    v_id_map t_id_map;
    v_unmapped_tmp_ids t_numbers := t_numbers();
    
    TYPE t_id_release_map IS
        TABLE OF NUMBER
        INDEX BY PLS_INTEGER;
        
    v_self_id_release_map t_id_release_map;
    v_parent_id_release_map t_id_release_map;
    
    TYPE t_value_buffer IS
        TABLE OF json_values%ROWTYPE;
        
    v_value_buffer t_value_buffer := t_value_buffer();
    c_flush_amount CONSTANT PLS_INTEGER := 200;
    
    v_recent_value_id NUMBER;
    
    FUNCTION next_tmp_id
    RETURN NUMBER IS
    
        v_new_tmp_id NUMBER;
    
    BEGIN
    
        IF v_released_tmp_ids_size > 0 THEN
        
            v_new_tmp_id := v_released_tmp_ids(v_released_tmp_ids_size);
            v_released_tmp_ids_size := v_released_tmp_ids_size - 1;
            
        ELSE
        
            v_tmp_id := v_tmp_id - 1;
            v_new_tmp_id := v_tmp_id;
            
        END IF;
        
        v_unmapped_tmp_ids.EXTEND(1);
        v_unmapped_tmp_ids(v_unmapped_tmp_ids.COUNT) := v_new_tmp_id;
        
        RETURN v_new_tmp_id;
    
    END;
    
    PROCEDURE release_tmp_id (
        p_tmp_id IN NUMBER
    ) IS
    BEGIN
    
        v_released_tmp_ids_size := v_released_tmp_ids_size + 1;
                
        IF v_released_tmp_ids.COUNT < v_released_tmp_ids_size THEN
            v_released_tmp_ids.EXTEND(1);
        END IF;
                
        v_released_tmp_ids(v_released_tmp_ids_size) := p_tmp_id; 
        v_id_map.DELETE(p_tmp_id);
    
    END;
    
    PROCEDURE insert_value (
        p_value IN OUT NOCOPY json_values%ROWTYPE
    ) IS
    BEGIN

        v_value_buffer.EXTEND(1);
        v_value_buffer(v_value_buffer.COUNT) := p_value;

        IF v_value_buffer.COUNT = c_flush_amount THEN
            flush;
        END IF;

    END;

    FUNCTION write_value (
        p_parent_id IN NUMBER,
        p_name IN VARCHAR2,
        p_content_parse_events IN t_varchars,
        p_event_i IN OUT NOCOPY PLS_INTEGER
    )
    RETURN NUMBER IS

        v_value json_values%ROWTYPE;
        v_child_id NUMBER;

        v_event json_core.STRING;
        v_event_name CHAR;
        v_event_value VARCHAR2(32766);

        v_name VARCHAR2(4000);
        v_i PLS_INTEGER;
        
        PROCEDURE extract_event IS
        BEGIN
            v_event := p_content_parse_events(p_event_i);
            v_event_name := SUBSTR(v_event, 1, 1);
            v_event_value := SUBSTR(v_event, 2);
        END;

    BEGIN

        v_value.id := next_tmp_id;
        v_value.parent_id := p_parent_id;
        v_value.name := p_name;

        IF v_recent_value_id IS NULL THEN
            v_recent_value_id := v_value.id;
        END IF;

        extract_event;

        IF v_event_name IN ('S', 'N', 'B', 'E') THEN

            v_value.type := v_event_name;
            v_value.value := v_event_value;

            insert_value(v_value);

        ELSIF v_event_name IN ('{', '[') THEN

            v_value.type := 
                CASE v_event_name
                    WHEN '{' THEN 'O'
                    WHEN '[' THEN 'A'
                END;
            v_value.value := NULL;

            insert_value(v_value);

            p_event_i := p_event_i + 1;
            
            extract_event;

            WHILE v_event_name NOT IN ('}', ']') LOOP

                v_name := v_event_value;
                p_event_i := p_event_i + 1;

                v_child_id := write_value(v_value.id, v_name, p_content_parse_events, p_event_i);
                
                extract_event;

            END LOOP;

        END IF;
        
        IF v_child_id IS NULL THEN
            v_self_id_release_map(v_value.id) := v_value.id;
        ELSE
            v_parent_id_release_map(v_child_id) := v_value.id;        
        END IF;
        
        p_event_i := p_event_i + 1;

        RETURN v_value.id;

    END;
    
    PROCEDURE write_json (
        p_parent_id IN NUMBER,
        p_name IN VARCHAR2,
        p_content_parse_events IN t_varchars,
        p_first_event_i IN PLS_INTEGER
    ) IS
    
        v_event_i PLS_INTEGER;
        v_value_id NUMBER;
    
    BEGIN
    
        v_recent_value_id := NULL;
        v_event_i := p_first_event_i;
        
        v_value_id := write_value(p_parent_id, p_name, p_content_parse_events, v_event_i);
    
    END;

    FUNCTION write_json (
        p_parent_id IN NUMBER,
        p_name IN VARCHAR2,
        p_content_parse_events IN t_varchars,
        p_first_event_i IN PLS_INTEGER
    ) 
    RETURN NUMBER IS
    BEGIN
    
        write_json(p_parent_id, p_name, p_content_parse_events, p_first_event_i);
        flush;
        
        RETURN v_recent_value_id;
    
    END;
    
    PROCEDURE flush IS
    
        v_ids t_numbers;
        v_id_count NUMBER;
        
        v_tmp_id NUMBER;
        v_parent_tmp_id NUMBER;
        
        CURSOR c_unmapped_ids IS
            SELECT column_value AS tmp_id
                  ,jsvl_id.NEXTVAL AS id
            FROM TABLE(v_unmapped_tmp_ids);

    BEGIN

        FOR v_unmapped_id IN c_unmapped_ids LOOP
        
            v_id_map(v_unmapped_id.tmp_id) := v_unmapped_id.id;
            
            IF v_unmapped_id.tmp_id = v_recent_value_id THEN
                v_recent_value_id := v_unmapped_id.id;
            END IF;
            
        END LOOP;
        
        v_unmapped_tmp_ids := t_numbers();

        FOR v_i IN 1..v_value_buffer.COUNT LOOP

            v_tmp_id := v_value_buffer(v_i).id;

            IF v_id_map.EXISTS(v_tmp_id) THEN
                v_value_buffer(v_i).id := v_id_map(v_tmp_id);
            END IF;

            IF v_id_map.EXISTS(v_value_buffer(v_i).parent_id) THEN
                v_value_buffer(v_i).parent_id := v_id_map(v_value_buffer(v_i).parent_id);
            END IF;
            
            IF v_self_id_release_map.EXISTS(v_tmp_id) THEN
                release_tmp_id(v_tmp_id);
                v_self_id_release_map.DELETE(v_tmp_id);
            END IF;
            
            WHILE v_parent_id_release_map.EXISTS(v_tmp_id) LOOP
            
                v_parent_tmp_id := v_parent_id_release_map(v_tmp_id);
                release_tmp_id(v_parent_tmp_id);
                v_parent_id_release_map.DELETE(v_tmp_id);
                
                v_tmp_id := v_parent_tmp_id;
            
            END LOOP;

        END LOOP;

        FORALL v_i IN 1..v_value_buffer.COUNT
            INSERT INTO json_values
            VALUES v_value_buffer(v_i);

        v_value_buffer := t_value_buffer();
    
    END;
    
    FUNCTION recent_value_id
    RETURN NUMBER IS
    BEGIN
    
        RETURN v_recent_value_id;
    
    END;

END;