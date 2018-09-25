CREATE OR REPLACE PACKAGE BODY json_builders IS

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
    
    TYPE t_integers IS
        TABLE OF PLS_INTEGER;
    
    TYPE t_composite_stack_element IS
        RECORD (
            type CHAR,
            next_element_i PLS_INTEGER
        );
        
    TYPE t_composite_stack IS
        TABLE OF t_composite_stack_element;
        
    TYPE t_object_property_name_stack IS
        TABLE OF CHAR
        INDEX BY VARCHAR2(32000);
        
    v_composite_stack t_composite_stack := t_composite_stack();
    v_released_composite_stack_is t_integers := t_integers();
    v_object_property_name_stack t_object_property_name_stack;    
        
    TYPE t_parse_event IS
        RECORD (
            name VARCHAR2(4000),
            value VARCHAR2(4000),
            next_event_i PLS_INTEGER
        );
        
    TYPE t_parse_events IS
        TABLE OF t_parse_event;
        
    v_parse_events t_parse_events := t_parse_events();
    v_released_parse_event_is t_integers := t_integers();
        
    TYPE t_json_builder IS
        RECORD (
            id PLS_INTEGER,
            serialize_nulls json_core.BOOLEANN := TRUE,
            nulls_as_empty_strings json_core.BOOLEANN := FALSE,
            state VARCHAR2(30),
            object_level PLS_INTEGER,
            composite_stack_top_i PLS_INTEGER,
            first_parse_event_i PLS_INTEGER,
            last_parse_event_i PLS_INTEGER
        );
        
    TYPE t_json_builders IS
        TABLE OF t_json_builder
        INDEX BY PLS_INTEGER;
    
    v_builders t_json_builders;
    v_released_builder_ids t_integers := t_integers();
    
    PROCEDURE register_messages IS
    BEGIN
        default_message_resolver.register_message('JBR-00001', 'JSON builder ID not specified!');
        default_message_resolver.register_message('JBR-00002', 'Invalid JSON builder!');
        default_message_resolver.register_message('JBR-00003', 'Unexpected value!');
        default_message_resolver.register_message('JBR-00004', 'JSON builder is in an incomplete state!');
        default_message_resolver.register_message('JBR-00005', 'Unexpected start of array!');
        default_message_resolver.register_message('JBR-00006', 'Unexpected end of composite!');
        default_message_resolver.register_message('JBR-00007', 'Unexpected start of object!');
        default_message_resolver.register_message('JBR-00008', 'Property name can''t be NULL!');
        default_message_resolver.register_message('JBR-00009', 'Unexpected property name!');
        default_message_resolver.register_message('JBR-00010', 'Unexpected end of object!');
        default_message_resolver.register_message('JBR-00011', 'Duplicate property :1!');
    END;
    
    FUNCTION create_builder (
        p_serialize_nulls IN json_core.BOOLEANN := TRUE,
        p_nulls_as_empty_strings IN json_core.BOOLEANN := TRUE
    )
    RETURN PLS_INTEGER IS
    
        v_id PLS_INTEGER;
    
    BEGIN
    
        IF v_released_builder_ids.COUNT = 0 THEN
        
            v_id := v_builders.COUNT + 1;
            
        ELSE
        
            v_id := v_released_builder_ids(v_released_builder_ids.COUNT);
            v_released_builder_ids.TRIM(1);
        
        END IF;
        
        v_builders(v_id) := NULL;
        v_builders(v_id).id := v_id;
        v_builders(v_id).serialize_nulls := p_serialize_nulls;
        v_builders(v_id).nulls_as_empty_strings := p_nulls_as_empty_strings;
        v_builders(v_id).object_level := 0;
        v_builders(v_id).state := 'wf_value';
        
        RETURN v_id;
    
    END;
    
    PROCEDURE destroy_builder (
        p_builder IN OUT NOCOPY t_json_builder
    ) IS
    
        v_composite_stack_i PLS_INTEGER;
        v_parse_event_i PLS_INTEGER;
    
    BEGIN
    
        v_composite_stack_i := p_builder.composite_stack_top_i;
        
        WHILE v_composite_stack_i IS NOT NULL LOOP
        
            v_released_composite_stack_is.EXTEND(1);
            v_released_composite_stack_is(v_released_composite_stack_is.COUNT) := v_composite_stack_i;
            
            v_composite_stack_i := v_composite_stack(v_composite_stack_i).next_element_i;
        
        END LOOP;
        
        v_parse_event_i := p_builder.first_parse_event_i;
        
        WHILE v_parse_event_i IS NOT NULL LOOP
        
            v_released_parse_event_is.EXTEND(1);
            v_released_parse_event_is(v_released_parse_event_is.COUNT) := v_parse_event_i;
            
            v_parse_event_i := v_parse_events(v_parse_event_i).next_event_i;
        
        END LOOP;
    
        v_released_builder_ids.EXTEND(1);
        v_released_builder_ids(v_released_builder_ids.COUNT) := p_builder.id;
        
        v_builders.DELETE(p_builder.id);
    
    END;
    
    FUNCTION get_builder (
        p_id IN PLS_INTEGER
    ) 
    RETURN t_json_builder IS
    BEGIN
    
        IF p_id IS NULL THEN
            -- JSON builder ID not specified!
            error$.raise('JBR-00001');
        ELSIF NOT v_builders.EXISTS(p_id) THEN
            -- Invalid JSON builder!
            error$.raise('JBR-00002');
        END IF;
        
        RETURN v_builders(p_id);
    
    END; 
    
    PROCEDURE destroy_builder (
        p_id IN PLS_INTEGER
    ) IS
    
        v_builder t_json_builder;
    
    BEGIN
    
        v_builder := get_builder(p_id);
    
        destroy_builder(v_builder);
    
    END;
    
    FUNCTION build_parse_events (
        p_builder_id IN PLS_INTEGER,
        p_serialize_nulls IN BOOLEAN := NULL
    )
    RETURN json_parser.t_parse_events IS
    
        v_builder t_json_builder;
        
        v_event json_parser.t_parse_event;
        v_result json_parser.t_parse_events;
        v_event_i PLS_INTEGER;
        
        v_name VARCHAR2(4000);
        v_serialize_nulls BOOLEAN;
        
    BEGIN
    
        v_builder := get_builder(p_builder_id);
    
        IF v_builder.state != 'wf_eof' THEN
            -- JSON builder is in an incomplete state!
            error$.raise('JBR-00004');
        END IF;
    
        v_serialize_nulls := NVL(p_serialize_nulls, v_builder.serialize_nulls);
        
        v_result := json_parser.t_parse_events();
        v_event_i := v_builder.first_parse_event_i;
        
        WHILE v_event_i IS NOT NULL LOOP
        
            IF v_parse_events(v_event_i).name = 'NAME' THEN
            
                v_name := v_parse_events(v_event_i).value;
                
            ELSE        
                
                v_event.name := v_parse_events(v_event_i).name;
                v_event.value := v_parse_events(v_event_i).value;
                
                IF v_name IS NULL 
                   OR v_serialize_nulls 
                   OR v_event.name != 'NULL'
                THEN
        
                    IF v_name IS NOT NULL THEN
                        v_result.EXTEND(1);
                        v_result(v_result.COUNT).name := 'NAME';
                        v_result(v_result.COUNT).value := v_name;
                    END IF;
        
                    v_result.EXTEND(1);
                    v_result(v_result.COUNT) := v_event;
                
                END IF;
                    
                v_name := NULL;
                
            END IF;
        
            v_event_i := v_parse_events(v_event_i).next_event_i;
        
        END LOOP;
        
        destroy_builder(v_builder);
        
        RETURN v_result;
    
    END;
    
    PROCEDURE add_parse_event (
         p_builder IN OUT NOCOPY t_json_builder,
         p_name IN VARCHAR2,
         p_value IN VARCHAR2 := NULL
    ) IS
    
        v_new_event_i PLS_INTEGER;
    
    BEGIN
    
        IF v_released_parse_event_is.COUNT > 0 THEN
            v_new_event_i := v_released_parse_event_is(v_released_parse_event_is.COUNT);
            v_released_parse_event_is.TRIM(1);
        ELSE
            v_parse_events.EXTEND(1);
            v_new_event_i := v_parse_events.COUNT;
        END IF;
        
        v_parse_events(v_new_event_i).name := p_name;
        v_parse_events(v_new_event_i).value := p_value;
        v_parse_events(v_new_event_i).next_event_i := NULL;
        
        IF p_builder.first_parse_event_i IS NULL THEN
            p_builder.first_parse_event_i := v_new_event_i;
        END IF;
        
        IF p_builder.last_parse_event_i IS NOT NULL THEN
            v_parse_events(p_builder.last_parse_event_i).next_event_i := v_new_event_i;
        END IF;
        
        p_builder.last_parse_event_i := v_new_event_i;
        
    END;
    
    
    PROCEDURE value (
        p_builder_id IN PLS_INTEGER,
        p_type IN VARCHAR2,
        p_value IN VARCHAR2
    ) IS
    
        v_builder t_json_builder;
    
    BEGIN
    
        v_builder := get_builder(p_builder_id);
    
        IF v_builder.state != 'wf_value' THEN
            -- Unexpected value!
            error$.raise('JBR-00003');
        END IF;
        
        add_parse_event(v_builder, p_type, p_value);
        
        IF v_builder.composite_stack_top_i IS NULL THEN
            v_builder.state := 'wf_eof';
        ELSIF v_composite_stack(v_builder.composite_stack_top_i).type = 'A' THEN
            v_builder.state := 'wf_value';
        ELSE
            v_builder.state := 'wf_name';
        END IF;
        
        v_builders(p_builder_id) := v_builder;
    
    END;
    
    PROCEDURE value (
        p_builder_id IN PLS_INTEGER,
        p_value IN VARCHAR2,
        p_null_as_empty_string IN BOOLEAN := NULL
    ) IS
    
        v_builder t_json_builder;
    
    BEGIN
    
        v_builder := get_builder(p_builder_id);
    
        IF NVL(p_null_as_empty_string, v_builder.nulls_as_empty_strings)
           OR p_value IS NOT NULL 
        THEN
            value(p_builder_id, 'STRING', p_value);
        ELSE
            value(p_builder_id, 'NULL', CAST(NULL AS VARCHAR2));
        END IF;
    
    END;
    
    PROCEDURE value (
        p_builder_id IN PLS_INTEGER,
        p_value IN DATE
    ) IS
    BEGIN
    
        IF p_value IS NULL THEN
            value(p_builder_id, 'NULL', CAST(NULL AS VARCHAR2));
        ELSE
            value(p_builder_id, 'STRING', TO_CHAR(p_value, 'yyyy-mm-dd'));
        END IF;
    
    END;
    
    PROCEDURE value (
        p_builder_id IN PLS_INTEGER,
        p_value IN NUMBER
    ) IS
    
        v_value_string VARCHAR2(4000);
    
    BEGIN
    
        IF p_value IS NULL THEN
            value(p_builder_id, 'NULL', CAST(NULL AS VARCHAR2));
        ELSE
    
            v_value_string := TO_CHAR(p_value, 'TM', 'NLS_NUMERIC_CHARACTERS=''.,''');
            
            IF v_value_string LIKE '.%' THEN
                v_value_string := '0' || v_value_string;
            END IF;
        
            value(p_builder_id, 'NUMBER', v_value_string);
            
        END IF;
    
    END;
    
    PROCEDURE value (
        p_builder_id IN PLS_INTEGER,
        p_value IN BOOLEAN
    ) IS
    BEGIN
    
        IF p_value IS NULL THEN
            value(p_builder_id, 'NULL', CAST(NULL AS VARCHAR2));
        ELSE
    
            value(
                p_builder_id, 
                'BOOLEAN', 
                CASE
                    WHEN p_value IS NULL THEN
                        NULL
                    WHEN p_value THEN
                        'true'
                    ELSE
                        'false'
                END
            );
            
        END IF;
    
    END;
    
    PROCEDURE null_value (
        p_builder_id IN PLS_INTEGER
    ) IS
    BEGIN
    
        value(p_builder_id, 'NULL', CAST(NULL AS VARCHAR2));
    
    END;
    
    PROCEDURE json (
        p_builder_id IN PLS_INTEGER,
        p_content_parse_events IN json_parser.t_parse_events
    ) IS
    
        v_builder t_json_builder;
    
    BEGIN
    
        v_builder := get_builder(p_builder_id);
    
        IF v_builder.state != 'wf_value' THEN
            -- Unexpected value!
            error$.raise('JBR-00003');
        END IF;
        
        FOR v_i IN 1..p_content_parse_events.COUNT LOOP
            add_parse_event(v_builder, p_content_parse_events(v_i).name, p_content_parse_events(v_i).value);
        END LOOP;
        
        IF v_builder.composite_stack_top_i IS NULL THEN
            v_builder.state := 'wf_eof';
        ELSIF v_composite_stack(v_builder.composite_stack_top_i).type = 'A' THEN
            v_builder.state := 'wf_value';
        ELSE
            v_builder.state := 'wf_name';
        END IF;
        
        v_builders(p_builder_id) := v_builder;
    
    END;
    
    PROCEDURE json (
        p_builder_id IN PLS_INTEGER,
        p_content IN VARCHAR2
    ) IS
    
        v_parse_events json_parser.t_parse_events;
    
    BEGIN
    
        json_parser.parse(p_content, v_parse_events);
    
        json(p_builder_id, v_parse_events);
    
    END;
    
    PROCEDURE json (
        p_builder_id IN PLS_INTEGER,
        p_content IN CLOB
    ) IS
    
        v_parse_events json_parser.t_parse_events;
    
    BEGIN
    
        json_parser.parse(p_content, v_parse_events);
    
        json(p_builder_id, v_parse_events);
    
    END;
    
    PROCEDURE json (
        p_builder_id IN PLS_INTEGER,
        p_content_builder_id IN PLS_INTEGER
    ) IS
    BEGIN
     
        json(p_builder_id, build_parse_events(p_content_builder_id));   
    
    END;
    
    PROCEDURE push_composite (
        p_builder IN OUT NOCOPY t_json_builder,
        p_type IN CHAR
    ) IS
    
        v_new_element_i PLS_INTEGER;
    
    BEGIN
    
        IF v_released_composite_stack_is.COUNT > 0 THEN
            v_new_element_i := v_released_composite_stack_is(v_released_composite_stack_is.COUNT);
            v_released_composite_stack_is.TRIM(1);
        ELSE
            v_composite_stack.EXTEND(1);
            v_new_element_i := v_composite_stack.COUNT;
        END IF;
        
        v_composite_stack(v_new_element_i).type := p_type;
        v_composite_stack(v_new_element_i).next_element_i := p_builder.composite_stack_top_i;
        
        p_builder.composite_stack_top_i := v_new_element_i;
    
    END;
    
    PROCEDURE array(
        p_builder_id IN PLS_INTEGER
    ) IS
    
        v_builder t_json_builder;
    
    BEGIN
    
        v_builder := get_builder(p_builder_id);
    
        IF v_builder.state != 'wf_value' THEN
            -- Unexpected start of array!
            error$.raise('JBR-00005');
        END IF;
    
        push_composite(v_builder, 'A');
        add_parse_event(v_builder, 'START_ARRAY');
        
        v_builders(p_builder_id) := v_builder;
    
    END;
    
    PROCEDURE object (
        p_builder_id IN PLS_INTEGER
    ) IS
    
        v_builder t_json_builder;
    
    BEGIN
    
        v_builder := get_builder(p_builder_id);
    
        IF v_builder.state != 'wf_value' THEN
            -- Unexpected start of object!
            error$.raise('JBR-00007');
        END IF;
        
        push_composite(v_builder, 'O');
        add_parse_event(v_builder, 'START_OBJECT');
        v_builder.object_level := v_builder.object_level + 1;
        v_builder.state := 'wf_name';
        
        v_builders(p_builder_id) := v_builder;
    
    END;
    
    PROCEDURE name (
        p_builder_id IN PLS_INTEGER,
        p_name IN VARCHAR2
    ) IS
    
        v_builder t_json_builder;
        
        v_property_name VARCHAR2(32000);
    
    BEGIN
    
        v_builder := get_builder(p_builder_id);
    
        IF p_name IS NULL THEN
            -- Property name can't be NULL!
            error$.raise('JBR-00008');
        ELSIF v_builder.state != 'wf_name' THEN
            -- Unexpected property name!
            error$.raise('JBR-00009');
        END IF;
        
        v_property_name := v_builder.id || '_' || v_builder.object_level || '.' || p_name;
        
        IF v_object_property_name_stack.EXISTS(v_property_name) THEN
            -- Duplicate property :1!
            error$.raise('JBR-00011', p_name);
        END IF;
        
        v_object_property_name_stack(v_property_name) := NULL;
        
        add_parse_event(v_builder, 'NAME', p_name);
        v_builder.state := 'wf_value';
        
        v_builders(p_builder_id) := v_builder;
    
    END;
    
    PROCEDURE close (
        p_builder_id IN PLS_INTEGER
    ) IS
    
        v_builder t_json_builder;
        
        v_object_name VARCHAR2(32000);
        v_property_name VARCHAR2(32000);
    
    BEGIN
    
        v_builder := get_builder(p_builder_id);
    
        IF v_builder.composite_stack_top_i IS NULL THEN
            -- Unexpected end of composite!
            error$.raise('JBR-00006');
        END IF;
        
        CASE v_composite_stack(v_builder.composite_stack_top_i).type
        
            WHEN 'A' THEN
                
                add_parse_event(v_builder, 'END_ARRAY');
                
            WHEN 'O' THEN 
              
                IF v_builder.state != 'wf_name' THEN
                    -- Unexpected end of object!
                    error$.raise('JBR-00010');
                END IF;
                
                v_object_name := p_builder_id || '_' || v_builder.object_level;
                v_property_name := v_object_property_name_stack.NEXT(v_object_name);
                
                WHILE v_property_name IS NOT NULL AND v_property_name LIKE v_object_name || '%' LOOP
                
                    v_object_property_name_stack.DELETE(v_property_name);
                
                    v_property_name := v_object_property_name_stack.NEXT(v_property_name);
                
                END LOOP;
                
                add_parse_event(v_builder, 'END_OBJECT');
                v_builder.object_level := v_builder.object_level - 1;
                
                
        END CASE;

        v_released_composite_stack_is.EXTEND(1);
        v_released_composite_stack_is(v_released_composite_stack_is.COUNT) := v_builder.composite_stack_top_i;
        
        v_builder.composite_stack_top_i := v_composite_stack(v_builder.composite_stack_top_i).next_element_i;
        
        IF v_builder.composite_stack_top_i IS NULL THEN
            v_builder.state := 'wf_eof';
        ELSIF v_composite_stack(v_builder.composite_stack_top_i).type = 'A' THEN
            v_builder.state := 'wf_value';
        ELSE
            v_builder.state := 'wf_name';
        END IF;
    
        v_builders(p_builder_id) := v_builder;
    
    END;
    
    FUNCTION build_json (
        p_builder_id IN PLS_INTEGER,
        p_serialize_nulls IN json_core.BOOLEANN := TRUE
    ) 
    RETURN VARCHAR2 IS
     
        v_json VARCHAR2(32000);
        v_json_clob CLOB;
    
    BEGIN
    
        json_core.serialize_value(
            build_parse_events(p_builder_id),
            p_serialize_nulls,
            v_json, 
            v_json_clob
        );
        
        RETURN v_json;
    
    END; 
    
    FUNCTION build_json_clob (
        p_builder_id IN PLS_INTEGER,
        p_serialize_nulls IN json_core.BOOLEANN := TRUE
    ) 
    RETURN CLOB IS
     
        v_json VARCHAR2(32000);
        v_json_clob CLOB;
    
    BEGIN
    
        DBMS_LOB.CREATETEMPORARY(v_json_clob, TRUE);
        
        json_core.serialize_value(
            build_parse_events(p_builder_id),
            p_serialize_nulls,
            v_json, 
            v_json_clob
        );
        
        RETURN v_json_clob;
    
    END; 
    
BEGIN
    register_messages;    
END;