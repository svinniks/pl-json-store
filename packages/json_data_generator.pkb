CREATE OR REPLACE PACKAGE BODY json_data_generator IS

    c_type_register_path CONSTANT VARCHAR2(4000) := '$._jsonDataGeneratedTypes';
    
    CURSOR c_registered_types IS
        SELECT *
        FROM json_data_registered_types;
        
    TYPE t_registered_types IS
        TABLE OF c_registered_types%ROWTYPE;

    TYPE t_attribute IS 
        RECORD (
            name VARCHAR2(30),
            pls_type VARCHAR2(30),
            type_name VARCHAR2(4000)
        );
        
    TYPE t_attributes IS
        TABLE OF t_attribute;
        
    TYPE t_type IS
        RECORD (
            data_type VARCHAR2(30),
            index_type VARCHAR2(100),
            attributes t_attributes
        );
        
    TYPE t_types IS
        TABLE OF t_type
        INDEX BY VARCHAR2(4000);

    PROCEDURE register_messages IS
    BEGIN
        default_message_resolver.register_message('JGEN-00001', 'Data type could not be resolved (:1)!');
        default_message_resolver.register_message('JGEN-00002', 'Scalar data type specified!');
        default_message_resolver.register_message('JGEN-00003', 'Object types not supported!');
        default_message_resolver.register_message('JGEN-00004', '%ROWTYPE not supported!');
        default_message_resolver.register_message('JGEN-00005', 'Unsupported data type :1!');
    END;

    FUNCTION to_sql_identifier (
        p_identifier IN VARCHAR2
    )
    RETURN VARCHAR2 IS
    BEGIN
        IF REGEXP_LIKE(p_identifier, '^[A-Z][A-Z0-9_\$\#]*$') THEN
            RETURN LOWER(p_identifier);
        ELSE
            RETURN '"' || p_identifier || '"';
        END IF;
    END;

    FUNCTION resolve_data_type (
        p_data_type_name IN VARCHAR
    )
    RETURN VARCHAR2 IS
    
        v_sql VARCHAR2(32000);
        
        v_schema VARCHAR2(30);
        v_part_1 VARCHAR2(30);
        v_part_2 VARCHAR2(30);
        
        v_db_link VARCHAR2(4000);
        v_part1_type NUMBER;
        v_object_number NUMBER;
        
        v_resolved_name VARCHAR2(4000);
        
        CURSOR c_arguments IS
            SELECT *
            FROM user_arguments
            WHERE object_name = 'JODUS_RESOLVE_DATA_TYPE';
            
        e_incompatible_flag EXCEPTION;
        PRAGMA EXCEPTION_INIT(e_incompatible_flag, -4047);
    
    BEGIN
    
        BEGIN
        
            DBMS_UTILITY.NAME_RESOLVE(
                p_data_type_name,
                1,
                v_schema, 
                v_part_1,
                v_part_2,
                v_db_link,
                v_part1_type,
                v_object_number
            );
        
        EXCEPTION
            WHEN e_incompatible_flag THEN
            
                BEGIN
                
                    DBMS_UTILITY.NAME_RESOLVE(
                        p_data_type_name,
                        7,
                        v_schema, 
                        v_part_1,
                        v_part_2,
                        v_db_link,
                        v_part1_type,
                        v_object_number
                    );
                    
                 EXCEPTION
                     WHEN OTHERS THEN
                         -- Data type could not be resolved (:1)!
                         error$.raise('JGEN-00001', SUBSTR(SQLERRM, 1, 128));
                 END;
                    
            WHEN OTHERS THEN
                -- Data type could not be resolved (:1)!
                error$.raise('JGEN-00001', SUBSTR(SQLERRM, 1, 128));
        END;
    
        v_resolved_name := to_sql_identifier(v_schema) || '.' || to_sql_identifier(v_part_1);
        
        IF v_part_2 IS NOT NULL THEN
            v_resolved_name := v_resolved_name || '.' || to_sql_identifier(v_part_2);
        END IF;
    
        v_sql := 
'CREATE OR REPLACE 
PROCEDURE jodus_resolve_data_type (
    p_argument IN ' || v_resolved_name || '
) IS
BEGIN
    NULL;
END;';

        BEGIN
        
            EXECUTE IMMEDIATE v_sql;
            
        EXCEPTION
            WHEN OTHERS THEN
                 -- Data type could not be resolved (:1)!
                error$.raise('JGEN-00001', SUBSTR(SQLERRM, 1, 128));       
        END;
        
        FOR v_argument IN c_arguments LOOP
        
            IF v_argument.data_level = 0 THEN
                
                IF v_argument.type_owner IS NULL THEN
                    -- Scalar data type specified!
                    error$.raise('JGEN-00002');
                END IF;
                
                v_resolved_name := to_sql_identifier(v_argument.type_owner) || '.' || to_sql_identifier(v_argument.type_name);
                
                IF v_argument.type_subname IS NOT NULL THEN
                    v_resolved_name := v_resolved_name || '.' || to_sql_identifier(v_argument.type_subname);
                END IF;
            
            END IF; 
            
            IF v_argument.data_type = 'OBJECT' THEN
                -- Object types not supported!
                error$.raise('JGEN-00003');
            ELSIF v_argument.data_type = 'PL/SQL RECORD' AND v_argument.type_owner IS NULL THEN
                -- %ROWTYPE not supported!
                error$.raise('JGEN-00004');
            END IF;
        
        END LOOP;
        
        BEGIN
            EXECUTE IMMEDIATE 'DROP PROCEDURE jodus_resolve_data_type';
        EXCEPTION 
            WHEN OTHERS THEN
                NULL; 
        END; 
        
        RETURN v_resolved_name;
    
    END;
    
    FUNCTION get_type_register_path
    RETURN VARCHAR2 DETERMINISTIC IS
    BEGIN
        RETURN c_type_register_path;
    END;
    
    PROCEDURE init_data_type_register IS
    BEGIN
        json_store.set_object(c_type_register_path);
    END;
    
    FUNCTION register_data_type (
        p_data_type_name IN VARCHAR2,
        p_ignore_unknown IN BOOLEAN := FALSE
    )
    RETURN VARCHAR2 IS
    
        v_resolved_type_name VARCHAR2(4000);
        v_escaped_type_name VARCHAR2(4000);
        
        v_dummy NUMBER;
        
    BEGIN
    
        v_resolved_type_name := resolve_data_type(p_data_type_name);
        v_escaped_type_name := REPLACE(v_resolved_type_name, '"', '\"');
        
        BEGIN
            
            SELECT value_1 
            INTO v_dummy
            FROM TABLE(json_table_5(c_type_register_path));
        
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                init_data_type_register;
        END;
        
        json_store.set_object(c_type_register_path || '["' || v_resolved_type_name || '"]');
        json_store.set_string(c_type_register_path || '["' || v_resolved_type_name || '"].name', v_resolved_type_name);
        json_store.set_boolean(c_type_register_path || '["' || v_resolved_type_name || '"].ignoreUnknown', p_ignore_unknown);
        
        RETURN v_resolved_type_name;
    
    END;
    
    PROCEDURE register_data_type (
        p_data_type_name IN VARCHAR2,
        p_ignore_unknown IN BOOLEAN := FALSE
    ) IS
        v_dummy VARCHAR2(4000);
    BEGIN
        v_dummy := register_data_type(p_data_type_name, p_ignore_unknown);
    END;
    
    PROCEDURE generate_specification (
        p_types IN t_registered_types
    ) IS
     
        v_line VARCHAR2(32000);
        v_sql CLOB;
        
        PROCEDURE add_line (
            p_line IN VARCHAR2 := NULL
        ) IS
        BEGIN
        
            v_line := v_line || p_line || CHR(10);
            
            IF LENGTH(v_line) > 25000 THEN
                DBMS_LOB.APPEND(v_sql, v_line);
                v_line := NULL;
            END IF;
          
        END;
    
    BEGIN
        
        DBMS_LOB.CREATETEMPORARY(v_sql, TRUE);
        
        add_line('CREATE OR REPLACE PACKAGE json_data IS');

        FOR v_i IN 1..p_types.COUNT LOOP
            
            add_line;
            add_line('    PROCEDURE parse (');
            add_line('        p_json IN VARCHAR2,');
            add_line('        p_data OUT ' || p_types(v_i).name);
            add_line('    );');
            
            add_line;
            add_line('    PROCEDURE parse (');
            add_line('        p_json IN CLOB,');
            add_line('        p_data OUT ' || p_types(v_i).name);
            add_line('    );');  
            
            add_line;
            add_line('    PROCEDURE stringify (');
            add_line('        p_data IN ' || p_types(v_i).name || ',');
            add_line('        p_json OUT VARCHAR2,');
            add_line('        p_json_clob OUT CLOB');
            add_line('    );');
            
            add_line;
            add_line('    PROCEDURE save (');
            add_line('        p_path IN VARCHAR2,');
            add_line('        p_data IN ' || p_types(v_i).name);
            add_line('    );');
            
            add_line;
            add_line('    PROCEDURE load (');
            add_line('        p_path IN VARCHAR2,');
            add_line('        p_data OUT ' || p_types(v_i).name);
            add_line('    );');
        
        END LOOP;

        add_line;
        add_line('END;');
        
        IF v_line IS NOT NULL THEN
            DBMS_LOB.APPEND(v_sql, v_line);
        END IF;
        
        EXECUTE IMMEDIATE v_sql;
        
        DBMS_LOB.FREETEMPORARY(v_sql);
    
    END;
    
    FUNCTION get_index_type (
        p_type_name IN VARCHAR2
    )
    RETURN VARCHAR2 IS
    BEGIN
    
        EXECUTE IMMEDIATE '
DECLARE
    v ' || p_type_name  || ';
BEGIN
    IF v.EXISTS(''A'') THEN
        NULL;
    END IF;
END;';

        RETURN 'VARCHAR2(32000)';

    EXCEPTION
        WHEN OTHERS THEN
            RETURN 'PLS_INTEGER';
    END;
    
    FUNCTION get_types
    RETURN t_types IS
    
        v_types t_types;
        
        CURSOR c_arguments IS
            SELECT argument_name,
                   data_level,
                   data_type,
                   type_owner,
                   type_name,
                   type_subname,
                   pls_type
            FROM user_arguments
            WHERE package_name = 'JSON_DATA'
                  AND NOT (data_level = 0
                           AND pls_type IS NOT NULL)
            ORDER BY subprogram_id, 
                     sequence;
            
        TYPE t_arguments IS
            TABLE OF c_arguments%ROWTYPE;
            
        v_arguments t_arguments;
        
        v_i PLS_INTEGER;
        v_type_name VARCHAR2(4000);
        
        FUNCTION get_type (
            p_level IN PLS_INTEGER
        )
        RETURN VARCHAR2 IS

            v_attribute_name VARCHAR2(30);        
            v_type_name VARCHAR2(4000);
            v_type t_type;
        
        BEGIN
        
            v_type_name := to_sql_identifier(v_arguments(v_i).type_owner) || '.' || to_sql_identifier(v_arguments(v_i).type_name);
            
            IF v_arguments(v_i).type_subname IS NOT NULL THEN
                v_type_name := v_type_name || '.' || to_sql_identifier(v_arguments(v_i).type_subname);
            END IF;
            
            IF NOT v_types.EXISTS(v_type_name) THEN
            
                v_type.data_type := v_arguments(v_i).data_type;
                v_type.attributes := t_attributes();
                
                IF v_type.data_type = 'PL/SQL TABLE' THEN
                    v_type.index_type := get_index_type(v_type_name);
                END IF;
                
                v_i := v_i + 1;
                
                WHILE v_i <= v_arguments.COUNT LOOP
                
                    IF v_arguments(v_i).data_level = p_level + 1 THEN
                    
                        v_type.attributes.EXTEND(1);
                        v_type.attributes(v_type.attributes.COUNT).name := to_sql_identifier(v_arguments(v_i).argument_name); 
                                            
                        IF v_arguments(v_i).pls_type IS NOT NULL THEN
                            v_type.attributes(v_type.attributes.COUNT).pls_type := v_arguments(v_i).pls_type;
                            v_i := v_i + 1;
                        ELSE 
                            v_type.attributes(v_type.attributes.COUNT).type_name := get_type(p_level + 1);
                        END IF;
                    
                    ELSE
                        EXIT;
                    END IF;
                
                END LOOP;
                
                v_types(v_type_name) := v_type;
                
            ELSE
            
                v_i := v_i + 1;
                
                WHILE v_i <= v_arguments.COUNT LOOP
                    EXIT WHEN v_arguments(v_i).data_level <= p_level;
                    v_i := v_i + 1;
                END LOOP;
            
            END IF;
            
            RETURN v_type_name;
        
        END;
        
        
    BEGIN
    
        OPEN c_arguments;
        
        FETCH c_arguments
        BULK COLLECT INTO v_arguments;
        
        CLOSE c_arguments;
        
        v_i := 1;
        
        WHILE v_i <= v_arguments.COUNT LOOP
            v_type_name := get_type(0);
        END LOOP;
    
        RETURN v_types;
    
    END;
    
    PROCEDURE generate_body (
        p_types IN t_registered_types
    ) IS
    
        v_line VARCHAR2(32000);
        v_sql CLOB;
        
        v_types t_types;
        v_type_name VARCHAR2(4000);
        
        PROCEDURE add_line (
            p_line IN VARCHAR2 := NULL
        ) IS
        BEGIN
        
            v_line := v_line || p_line || CHR(10);
            
            IF LENGTH(v_line) > 25000 THEN
                DBMS_LOB.APPEND(v_sql, v_line);
                v_line := NULL;
            END IF;
          
        END;
    
    BEGIN
        
        DBMS_LOB.CREATETEMPORARY(v_sql, TRUE);
        
        add_line('CREATE OR REPLACE PACKAGE BODY json_data IS
        
    PROCEDURE register_messages IS
    BEGIN
        default_message_resolver.register_message(''JDAT-00001'', '':1 expected, but :2 found!'');
        default_message_resolver.register_message(''JDAT-00002'', ''Unknown property :1!'');
    END;    
        
    PROCEDURE add_event (
        p_parse_events IN OUT NOCOPY json_parser.t_parse_events,
        p_name IN VARCHAR2,
        p_value IN VARCHAR2 := NULL
    ) IS
    BEGIN
        p_parse_events.EXTEND(1);
        p_parse_events(p_parse_events.COUNT).name := p_name;
        p_parse_events(p_parse_events.COUNT).value := p_value;
    END;
    
    PROCEDURE serialize (
        p_data IN VARCHAR2,
        p_parse_events IN OUT NOCOPY json_parser.t_parse_events
    ) IS
    BEGIN
        IF p_data IS NULL THEN
            add_event(p_parse_events, ''NULL'');
        ELSE
            add_event(p_parse_events, ''STRING'', p_data);
        END IF; 
    END;
    
    PROCEDURE serialize (
        p_data IN NUMBER,
        p_parse_events IN OUT NOCOPY json_parser.t_parse_events
    ) IS
    BEGIN
        IF p_data IS NULL THEN
            add_event(p_parse_events, ''NULL'');
        ELSE
            add_event(p_parse_events, ''NUMBER'', p_data);
        END IF; 
    END;
    
    PROCEDURE serialize (
        p_data IN BOOLEAN,
        p_parse_events IN OUT NOCOPY json_parser.t_parse_events
    ) IS
    BEGIN
        IF p_data IS NULL THEN
            add_event(p_parse_events, ''NULL'');
        ELSE
            add_event(p_parse_events, ''BOOLEAN'', CASE WHEN p_data THEN ''true'' ELSE ''false'' END);
        END IF;
    END;
    
    PROCEDURE deserialize (
        p_parse_events IN json_parser.t_parse_events,
        p_event_i IN OUT NOCOPY PLS_INTEGER,
        p_data OUT NOCOPY VARCHAR2
    ) IS
    BEGIN
        
        IF p_parse_events(p_event_i).name IN (''STRING'', ''NULL'') THEN
            p_data := p_parse_events(p_event_i).value;
        ELSE
            error$.raise(''JDAT-00001'', ''STRING'', p_parse_events(p_event_i).name);
        END IF;
        
        p_event_i := p_event_i + 1;
    
    END;
    
    PROCEDURE deserialize (
        p_parse_events IN json_parser.t_parse_events,
        p_event_i IN OUT NOCOPY PLS_INTEGER,
        p_data OUT NOCOPY NUMBER
    ) IS
    BEGIN
        
        IF p_parse_events(p_event_i).name IN (''NUMBER'', ''NULL'') THEN
            p_data := p_parse_events(p_event_i).value;
        ELSE
            error$.raise(''JDAT-00001'', ''NUMBER'', p_parse_events(p_event_i).name);
        END IF;
        
        p_event_i := p_event_i + 1;
    
    END;
    
    PROCEDURE deserialize (
        p_parse_events IN json_parser.t_parse_events,
        p_event_i IN OUT NOCOPY PLS_INTEGER,
        p_data OUT NOCOPY BOOLEAN
    ) IS
    BEGIN
        
        IF p_parse_events(p_event_i).name IN (''BOOLEAN'', ''NULL'') THEN
            p_data := p_parse_events(p_event_i).value = ''true'';
        ELSE
            error$.raise(''JDAT-00001'', ''STRING'', p_parse_events(p_event_i).name);
        END IF;
        
        p_event_i := p_event_i + 1;
    
    END;');

        v_types := get_types;
        v_type_name := v_types.FIRST;
        
        WHILE v_type_name IS NOT NULL LOOP
        
            add_line;
            add_line('    PROCEDURE serialize (');
            add_line('        p_data IN ' || v_type_name || ',');
            add_line('        p_parse_events IN OUT NOCOPY json_parser.t_parse_events');
            add_line('    );');
            add_line;
            add_line('    PROCEDURE deserialize (');
            add_line('        p_parse_events IN json_parser.t_parse_events,');
            add_line('        p_event_i IN OUT NOCOPY PLS_INTEGER,');
            add_line('        p_data OUT ' || v_type_name);
            add_line('    );');
        
            v_type_name := v_types.NEXT(v_type_name);
        
        END LOOP;
        
        v_type_name := v_types.FIRST;
        
        WHILE v_type_name IS NOT NULL LOOP
        
            add_line;
            add_line('    PROCEDURE serialize (');
            add_line('        p_data IN ' || v_type_name || ',');
            add_line('        p_parse_events IN OUT NOCOPY json_parser.t_parse_events');
            add_line('    ) IS');
            
            IF v_types(v_type_name).index_type IS NOT NULL THEN
                add_line('        v_i ' || v_types(v_type_name).index_type || ';');
            END IF;
            
            add_line('    BEGIN');
            
            IF v_types(v_type_name).data_type = 'PL/SQL RECORD' THEN
                
                add_line;
                add_line('        add_event(p_parse_events, ''START_OBJECT'');'); 
            
                FOR v_i IN 1..v_types(v_type_name).attributes.COUNT LOOP
                
                    add_line;
                    add_line('        add_event(p_parse_events, ''NAME'', ''' || v_types(v_type_name).attributes(v_i).name || ''');');
                
                    IF v_types(v_type_name).attributes(v_i).pls_type IS NOT NULL
                       AND v_types(v_type_name).attributes(v_i).pls_type NOT IN ('VARCHAR2', 'NUMBER', 'PLS_INTEGER', 'BOOLEAN') THEN
                       
                        -- Unsupported data type :1!
                        error$.raise('JGEN-00005', v_types(v_type_name).attributes(v_i).pls_type);
                        
                    END IF;
                        
                    add_line('        serialize(p_data.' || v_types(v_type_name).attributes(v_i).name || ', p_parse_events);');
                
                END LOOP;
                
                add_line;
                add_line('        add_event(p_parse_events, ''END_OBJECT'');');
                
            ELSIF v_types(v_type_name).data_type = 'TABLE' THEN
            
                add_line;
                add_line('        IF p_data IS NULL THEN');
                add_line('            add_event(p_parse_events, ''NULL'');');
                add_line('        ELSE');
                add_line;
                add_line('            add_event(p_parse_events, ''START_ARRAY'');');
                add_line;
                add_line('            FOR v_i IN 1..p_data.COUNT LOOP');
                
                IF v_types(v_type_name).attributes(1).pls_type IS NOT NULL
                   AND v_types(v_type_name).attributes(1).pls_type NOT IN ('VARCHAR2', 'NUMBER', 'PLS_INTEGER', 'BOOLEAN') THEN
                       
                    -- Unsupported data type :1!
                    error$.raise('JGEN-00005', v_types(v_type_name).attributes(1).pls_type);
                        
                END IF;
                
                add_line('                serialize(p_data(v_i), p_parse_events);');
                add_line('            END LOOP;');            
                add_line;
                add_line('            add_event(p_parse_events, ''END_ARRAY'');');
                add_line;
                add_line('        END IF;');
                add_line;    
                
            ELSIF v_types(v_type_name).data_type = 'PL/SQL TABLE' THEN
                
                add_line;
                add_line('        add_event(p_parse_events, ''START_OBJECT'');');
                add_line('        v_i := p_data.FIRST;');
                add_line;
                add_line('        WHILE v_i IS NOT NULL LOOP');
                add_line;
                add_line('            add_event(p_parse_events, ''NAME'', v_i);');

                IF v_types(v_type_name).attributes(1).pls_type IS NOT NULL
                   AND v_types(v_type_name).attributes(1).pls_type NOT IN ('VARCHAR2', 'NUMBER', 'PLS_INTEGER', 'BOOLEAN') THEN
                       
                    -- Unsupported data type :1!
                    error$.raise('JGEN-00005', v_types(v_type_name).attributes(1).pls_type);
                        
                END IF;
                
                add_line('            serialize(p_data(v_i), p_parse_events);');
                add_line;
                add_line('            v_i := p_data.NEXT(v_i);');
                add_line;
                add_line('        END LOOP;');
                add_line;
                add_line('        add_event(p_parse_events, ''END_OBJECT'');');
                
            
            ELSE
            
                -- Unsupported data type :1!
                error$.raise('JGEN-00005', v_types(v_type_name).data_type);
            
            END IF;
            
            add_line;
            add_line('    END;');
            add_line;
            add_line('    PROCEDURE deserialize (');
            add_line('        p_parse_events IN json_parser.t_parse_events,');
            add_line('        p_event_i IN OUT NOCOPY PLS_INTEGER,');
            add_line('        p_data OUT NOCOPY ' || v_type_name);
            add_line('    ) IS');
            
            IF v_types(v_type_name).data_type = 'PL/SQL TABLE' THEN
                add_line('        v_i ' || get_index_type(v_type_name) || ';');
            END IF;
            
            add_line('    BEGIN');
            
            IF v_types(v_type_name).data_type = 'PL/SQL RECORD' THEN
            
                add_line;
                add_line('        IF p_parse_events(p_event_i).name != ''START_OBJECT'' THEN');
                add_line('            error$.raise(''JDAT-00001'', ''START_OBJECT'', p_parse_events(p_event_i).name);');
                add_line('        END IF;');
                add_line;
                add_line('        p_event_i := p_event_i + 1;');
                add_line;
                add_line('        WHILE p_parse_events(p_event_i).name != ''END_OBJECT'' LOOP');
                add_line;
                
                FOR v_i IN 1..v_types(v_type_name).attributes.COUNT LOOP
                
                    add_line('            ' || CASE WHEN v_i = 1 THEN 'IF' ELSE 'ELSIF' END || ' p_parse_events(p_event_i).value = ''' || v_types(v_type_name).attributes(v_i).name || ''' THEN');
                    add_line('                p_event_i := p_event_i + 1;');
                    add_line('                deserialize(p_parse_events, p_event_i, p_data.' || v_types(v_type_name).attributes(v_i).name || ');');
                
                END LOOP;
                
                add_line('            ELSE');
                add_line('                error$.raise(''JDAT-00002'', p_parse_events(p_event_i).value);');
                add_line('            END IF;');
                add_line;
                add_line('        END LOOP;');    
                
            ELSIF v_types(v_type_name).data_type = 'TABLE' THEN
            
                add_line;
                add_line('        IF p_parse_events(p_event_i).name != ''START_ARRAY'' THEN');
                add_line('            error$.raise(''JDAT-00001'', ''START_ARRAY'', p_parse_events(p_event_i).name);');
                add_line('        END IF;'); 
                add_line;
                add_line('        p_data := ' || v_type_name || '();');
                add_line('        p_event_i := p_event_i + 1;');
                add_line;
                add_line('        WHILE p_parse_events(p_event_i).name != ''END_ARRAY'' LOOP');
                add_line('            p_data.EXTEND(1);');
                add_line('            deserialize(p_parse_events, p_event_i, p_data(p_data.COUNT));');
                add_line('        END LOOP;');
                
            ELSIF v_types(v_type_name).data_type = 'PL/SQL TABLE' THEN
            
                add_line;
                add_line('        IF p_parse_events(p_event_i).name != ''START_OBJECT'' THEN');
                add_line('            error$.raise(''JDAT-00001'', ''START_OBJECT'', p_parse_events(p_event_i).name);');
                add_line('        END IF;'); 
                add_line;
                add_line('        p_event_i := p_event_i + 1;');
                add_line;
                add_line('        WHILE p_parse_events(p_event_i).name != ''END_OBJECT'' LOOP');
                add_line('            v_i := p_parse_events(p_event_i).value;');
                add_line('            p_event_i := p_event_i + 1;'); 
                add_line('            deserialize(p_parse_events, p_event_i, p_data(v_i));');
                add_line('        END LOOP;'); 
            
            END IF;
            
            add_line;
            add_line('        p_event_i := p_event_i + 1;');
            add_line;
            add_line('    END;');
        
            v_type_name := v_types.NEXT(v_type_name);
        
        END LOOP;
        
        FOR v_i IN 1..p_types.COUNT LOOP
            
            add_line;
            add_line('    PROCEDURE parse (');
            add_line('        p_json IN VARCHAR2,');
            add_line('        p_data OUT ' || p_types(v_i).name);
            add_line('    ) IS');
            add_line('        v_parse_events json_parser.t_parse_events;');
            add_line('        v_event_i PLS_INTEGER;');
            add_line('    BEGIN');
            add_line('        json_parser.parse(p_json, v_parse_events);');
            add_line('        v_event_i := 1;');
            add_line('        deserialize(v_parse_events, v_event_i, p_data);');
            add_line('    END;');
            
            add_line;
            add_line('    PROCEDURE parse (');
            add_line('        p_json IN CLOB,');
            add_line('        p_data OUT ' || p_types(v_i).name);
            add_line('    ) IS');
            add_line('        v_parse_events json_parser.t_parse_events;');
            add_line('        v_event_i PLS_INTEGER;');
            add_line('    BEGIN');
            add_line('        json_parser.parse(p_json, v_parse_events);');
            add_line('        v_event_i := 1;');
            add_line('        deserialize(v_parse_events, v_event_i, p_data);');
            add_line('    END;');  
            
            add_line;
            add_line('    PROCEDURE stringify (');
            add_line('        p_data IN ' || p_types(v_i).name || ',');
            add_line('        p_json OUT VARCHAR2,');
            add_line('        p_json_clob OUT CLOB');
            add_line('    ) IS');
            add_line('        v_parse_events json_parser.t_parse_events;');
            add_line('    BEGIN');
            add_line('        v_parse_events := json_parser.t_parse_events();');
            add_line('        serialize(p_data, v_parse_events);');
            add_line('        json_core.serialize_value(v_parse_events, p_json, p_json_clob);');
            add_line('    END;');
        
            add_line;
            add_line('    PROCEDURE save (');
            add_line('        p_path IN VARCHAR2,');
            add_line('        p_data IN ' || p_types(v_i).name);
            add_line('    ) IS');
            add_line('        v_parse_events json_parser.t_parse_events;');
            add_line('        v_dummy NUMBER;');
            add_line('    BEGIN');
            add_line('        v_parse_events := json_parser.t_parse_events();');
            add_line('        serialize(p_data, v_parse_events);');
            add_line('        v_dummy := json_core.set_property(p_path, NULL, v_parse_events)(1);');
            add_line('    END;');
            
            add_line;
            add_line('    PROCEDURE load (');
            add_line('        p_path IN VARCHAR2,');
            add_line('        p_data OUT ' || p_types(v_i).name);
            add_line('    ) IS');
            add_line('        v_parse_events json_parser.t_parse_events;');
            add_line('        v_event_i PLS_INTEGER;');
            add_line('    BEGIN');
            add_line('        json_core.get_parse_events(p_path, v_parse_events);');
            add_line('        v_event_i := 1;');
            add_line('        deserialize(v_parse_events, v_event_i, p_data);');
            add_line('    END;');
        
        END LOOP;
        
        add_line;
        add_line('BEGIN
    register_messages;
END;');
        
        IF v_line IS NOT NULL THEN
            DBMS_LOB.APPEND(v_sql, v_line);
        END IF;
        
        EXECUTE IMMEDIATE v_sql;
        
        DBMS_LOB.FREETEMPORARY(v_sql);
    
    END;
    
    PROCEDURE generate IS
    
        v_types t_registered_types;
    
    BEGIN
    
        OPEN c_registered_types;
        
        FETCH c_registered_types
        BULK COLLECT INTO v_types;
        
        CLOSE c_registered_types;
        
        generate_specification(v_types);
        generate_body(v_types);
    
    END;
    
BEGIN
    register_messages;    
END;
