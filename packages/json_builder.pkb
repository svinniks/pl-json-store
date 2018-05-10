CREATE OR REPLACE PACKAGE BODY json_builder IS

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
    
    v_builders t_json_builders;
    
    TYPE t_integers IS
        TABLE OF PLS_INTEGER;
    
    v_released_builder_ids t_integers := t_integers();
    
    PROCEDURE register_messages IS
    BEGIN
        default_message_resolver.register_message('JBLR-00001', 'JSON builder ID not specified!');
        default_message_resolver.register_message('JBLR-00002', 'Invalid JSON builder!');
        default_message_resolver.register_message('JBLR-00003', 'Unexpected value!');
        default_message_resolver.register_message('JBLR-00004', 'JSON builder is in an incomplete state!');
        default_message_resolver.register_message('JBLR-00005', 'Unexpected start of array!');
        default_message_resolver.register_message('JBLR-00006', 'Unexpected end of composite!');
        default_message_resolver.register_message('JBLR-00007', 'Unexpected start of object!');
        default_message_resolver.register_message('JBLR-00008', 'Property name can''t be NULL!');
        default_message_resolver.register_message('JBLR-00009', 'Unexpected propoerty name!');
        default_message_resolver.register_message('JBLR-00010', 'Unexpected end of object!');
        default_message_resolver.register_message('JBLR-00011', 'Duplicate property :1!');
    END;
    
    FUNCTION create_builder
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
        v_builders(v_id).state := 'wf_value';
        v_builders(v_id).composite_stack := t_varchars();
        v_builders(v_id).object_property_stack := t_object_property_stack();
        v_builders(v_id).parse_events := json_parser.t_parse_events();
        
        RETURN v_id;
    
    END;
    
    PROCEDURE do_destroy_builder (
        p_id IN PLS_INTEGER
    ) IS
    BEGIN
    
        v_released_builder_ids.EXTEND(1);
        v_released_builder_ids(v_released_builder_ids.COUNT) := p_id;
        
        v_builders.DELETE(p_id);
    
    END;
    
    PROCEDURE destroy_builder (
        p_id IN PLS_INTEGER
    ) IS
    BEGIN
    
        IF p_id IS NULL THEN
            -- JSON builder ID not specified!
            error$.raise('JBLR-00001');
        ELSIF NOT v_builders.EXISTS(p_id) THEN
            -- Invalid JSON builder!
            error$.raise('JBLR-00002');
        END IF;
        
        do_destroy_builder(p_id);
    
    END;
    
    FUNCTION build_parse_events (
        p_builder_id IN PLS_INTEGER
    )
    RETURN json_parser.t_parse_events IS
    
        v_parse_events json_parser.t_parse_events;
    
    BEGIN
    
        IF p_builder_id IS NULL THEN
            -- JSON builder ID not specified!
            error$.raise('JBLR-00001');
        ELSIF NOT v_builders.EXISTS(p_builder_id) THEN
            -- Invalid JSON builder!
            error$.raise('JBLR-00002');
        ELSIF v_builders(p_builder_id).state != 'wf_eof' THEN
            -- JSON builder is in an incomplete state!
            error$.raise('JBLR-00004');
        END IF;
    
        v_parse_events := v_builders(p_builder_id).parse_events;
        do_destroy_builder(p_builder_id);
        
        RETURN v_parse_events;
    
    END;
    
    PROCEDURE value (
        p_builder_id IN PLS_INTEGER,
        p_type IN VARCHAR2,
        p_value IN VARCHAR2
    ) IS
    BEGIN
    
        IF p_builder_id IS NULL THEN
            -- JSON builder ID not specified!
            error$.raise('JBLR-00001');
        ELSIF NOT v_builders.EXISTS(p_builder_id) THEN
            -- Invalid JSON builder!
            error$.raise('JBLR-00002');
        ELSIF v_builders(p_builder_id).state != 'wf_value' THEN
            -- Unexpected value!
            error$.raise('JBLR-00003');
        END IF;
        
        v_builders(p_builder_id).parse_events.EXTEND(1);
        
        IF p_value IS NULL THEN
            v_builders(p_builder_id).parse_events(v_builders(p_builder_id).parse_events.COUNT).name := 'NULL';
        ELSE
            v_builders(p_builder_id).parse_events(v_builders(p_builder_id).parse_events.COUNT).name := p_type;
            v_builders(p_builder_id).parse_events(v_builders(p_builder_id).parse_events.COUNT).value := p_value;
        END IF;
        
        IF v_builders(p_builder_id).composite_stack.COUNT = 0 THEN
            v_builders(p_builder_id).state := 'wf_eof';
        ELSIF v_builders(p_builder_id).composite_stack(v_builders(p_builder_id).composite_stack.COUNT) = 'A' THEN
            v_builders(p_builder_id).state := 'wf_value';
        ELSE
            v_builders(p_builder_id).state := 'wf_name';
        END IF;
    
    END;
    
    PROCEDURE value (
        p_builder_id IN PLS_INTEGER,
        p_value IN VARCHAR2
    ) IS
    BEGIN
    
        value(p_builder_id, 'STRING', p_value);
    
    END;
    
    PROCEDURE value (
        p_builder_id IN PLS_INTEGER,
        p_value IN DATE
    ) IS
    BEGIN
    
        value(p_builder_id, 'STRING', TO_CHAR(p_value, 'yyyy-mm-dd'));
    
    END;
    
    PROCEDURE value (
        p_builder_id IN PLS_INTEGER,
        p_value IN NUMBER
    ) IS
    
        v_value_string VARCHAR2(4000);
    
    BEGIN
    
        v_value_string := TO_CHAR(p_value, 'TM', 'NLS_NUMERIC_CHARACTERS=''.,''');
        
        IF v_value_string LIKE '.%' THEN
            v_value_string := '0' || v_value_string;
        END IF;
    
        value(p_builder_id, 'NUMBER', v_value_string);
    
    END;
    
    PROCEDURE value (
        p_builder_id IN PLS_INTEGER,
        p_value IN BOOLEAN
    ) IS
    BEGIN
    
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
    
    END;
    
    PROCEDURE array(
        p_builder_id IN PLS_INTEGER
    ) IS
    BEGIN
    
        IF p_builder_id IS NULL THEN
            -- JSON builder ID not specified!
            error$.raise('JBLR-00001');
        ELSIF NOT v_builders.EXISTS(p_builder_id) THEN
            -- Invalid JSON builder!
            error$.raise('JBLR-00002');
        ELSIF v_builders(p_builder_id).state != 'wf_value' THEN
            -- Unexpected start of array!
            error$.raise('JBLR-00005');
        END IF;
    
        v_builders(p_builder_id).composite_stack.EXTEND(1);
        v_builders(p_builder_id).composite_stack(v_builders(p_builder_id).composite_stack.COUNT) := 'A';
        
        v_builders(p_builder_id).parse_events.EXTEND(1);
        v_builders(p_builder_id).parse_events(v_builders(p_builder_id).parse_events.COUNT).name := 'START_ARRAY';
    
    END;
    
    PROCEDURE object (
        p_builder_id IN PLS_INTEGER
    ) IS
    BEGIN
    
        IF p_builder_id IS NULL THEN
            -- JSON builder ID not specified!
            error$.raise('JBLR-00001');
        ELSIF NOT v_builders.EXISTS(p_builder_id) THEN
            -- Invalid JSON builder!
            error$.raise('JBLR-00002');
        ELSIF v_builders(p_builder_id).state != 'wf_value' THEN
            -- Unexpected start of object!
            error$.raise('JBLR-00007');
        END IF;
        
        v_builders(p_builder_id).composite_stack.EXTEND(1);
        v_builders(p_builder_id).composite_stack(v_builders(p_builder_id).composite_stack.COUNT) := 'O';
        
        v_builders(p_builder_id).parse_events.EXTEND(1);
        v_builders(p_builder_id).parse_events(v_builders(p_builder_id).parse_events.COUNT).name := 'START_OBJECT';
        
        v_builders(p_builder_id).object_property_stack.EXTEND(1);
        
        v_builders(p_builder_id).state := 'wf_name';
    
    END;
    
    PROCEDURE name (
        p_builder_id IN PLS_INTEGER,
        p_name IN VARCHAR2
    ) IS
    BEGIN
    
        IF p_builder_id IS NULL THEN
            -- JSON builder ID not specified!
            error$.raise('JBLR-00001');
        ELSIF NOT v_builders.EXISTS(p_builder_id) THEN
            -- Invalid JSON builder!
            error$.raise('JBLR-00002');
        ELSIF p_name IS NULL THEN
            -- Property name can't be NULL!
            error$.raise('JBLR-00008');
        ELSIF v_builders(p_builder_id).state != 'wf_name' THEN
            -- Unexpected property name!
            error$.raise('JBLR-00009');
        ELSIF v_builders(p_builder_id).object_property_stack(v_builders(p_builder_id).object_property_stack.COUNT).EXISTS(p_name) THEN
            -- Duplicate property :1!
            error$.raise('JBLR-00011', p_name);
        END IF;
        
        v_builders(p_builder_id).parse_events.EXTEND(1);
        v_builders(p_builder_id).parse_events(v_builders(p_builder_id).parse_events.COUNT).name := 'NAME';    
        v_builders(p_builder_id).parse_events(v_builders(p_builder_id).parse_events.COUNT).value := p_name;
        
        v_builders(p_builder_id).object_property_stack(v_builders(p_builder_id).object_property_stack.COUNT)(p_name) := NULL;
        
        v_builders(p_builder_id).state := 'wf_value';
    
    END;
    
    PROCEDURE close (
        p_builder_id IN PLS_INTEGER
    ) IS
    BEGIN
    
        IF p_builder_id IS NULL THEN
            -- JSON builder ID not specified!
            error$.raise('JBLR-00001');
        ELSIF NOT v_builders.EXISTS(p_builder_id) THEN
            -- Invalid JSON builder!
            error$.raise('JBLR-00002');
        ELSIF v_builders(p_builder_id).composite_stack.COUNT = 0 THEN
            -- Unexpected end of composite!
            error$.raise('JBLR-00006');
        END IF;
        
        CASE v_builders(p_builder_id).composite_stack(v_builders(p_builder_id).composite_stack.COUNT)
        
            WHEN 'A' THEN
                
                v_builders(p_builder_id).parse_events.EXTEND(1);
                v_builders(p_builder_id).parse_events(v_builders(p_builder_id).parse_events.COUNT).name := 'END_ARRAY';
                
            WHEN 'O' THEN 
              
                IF v_builders(p_builder_id).state != 'wf_name' THEN
                    -- Unexpected end of object!
                    error$.raise('JBLR-00010');
                END IF;
                
                v_builders(p_builder_id).parse_events.EXTEND(1);
                v_builders(p_builder_id).parse_events(v_builders(p_builder_id).parse_events.COUNT).name := 'END_OBJECT';
                
                v_builders(p_builder_id).object_property_stack.TRIM(1);
                
        END CASE;

        v_builders(p_builder_id).composite_stack.TRIM(1);
        
        IF v_builders(p_builder_id).composite_stack.COUNT = 0 THEN
            v_builders(p_builder_id).state := 'wf_eof';
        ELSIF v_builders(p_builder_id).composite_stack(v_builders(p_builder_id).composite_stack.COUNT) = 'A' THEN
            v_builders(p_builder_id).state := 'wf_value';
        ELSE
            v_builders(p_builder_id).state := 'wf_name';
        END IF;
    
    END;
    
    FUNCTION build_json (
        p_builder_id IN PLS_INTEGER
    ) 
    RETURN VARCHAR2 IS
     
        v_json VARCHAR2(32000);
        v_json_clob CLOB;
    
    BEGIN
    
        json_core.serialize_value(
            build_parse_events(p_builder_id),
            v_json, 
            v_json_clob
        );
        
        RETURN v_json;
    
    END; 
    
    FUNCTION build_json_clob (
        p_builder_id IN PLS_INTEGER
    ) 
    RETURN CLOB IS
     
        v_json VARCHAR2(32000);
        v_json_clob CLOB;
    
    BEGIN
    
        DBMS_LOB.CREATETEMPORARY(v_json_clob, TRUE);
        
        json_core.serialize_value(
            build_parse_events(p_builder_id),
            v_json, 
            v_json_clob
        );
        
        RETURN v_json_clob;
    
    END; 
    
BEGIN
    register_messages;    
END;