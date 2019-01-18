CREATE OR REPLACE PACKAGE BODY persistent_json_store IS

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
    
    v_value_cache_capacity PLS_INTEGER := c_VALUE_CACHE_DEFAULT_CAPACITY;
    
    v_json_value_cache t_json_value_cache;
    
    v_value_cache_entries t_value_cache_entries;
    v_value_cache_head_id VARCHAR2(30);
    v_value_cache_tail_id VARCHAR2(30);
    
    TYPE t_query_statement_cache IS
        TABLE OF t_query_statement
        INDEX BY VARCHAR2(32000);
        
    v_query_statement_cache t_query_statement_cache;
    
    -- Value cache management methods
    
    PROCEDURE reset_value_cache IS
    BEGIN
    
        v_json_value_cache.DELETE;
        v_value_cache_entries.DELETE;

        v_value_cache_head_id := NULL;
        v_value_cache_tail_id := NULL;
        
    END;
    
    FUNCTION get_cached_values
    RETURN json_core.t_json_values PIPELINED IS
    
        v_id VARCHAR2(30);
        
    BEGIN
    
        v_id := v_value_cache_head_id;
        
        WHILE v_id IS NOT NULL LOOP
            PIPE ROW(v_json_value_cache(v_id));
            v_id := v_value_cache_entries(v_id).next_entry_id;
        END LOOP;
    
        RETURN;
    
    END;
    
    PROCEDURE unlink_value_cache_entry (
        p_id IN VARCHAR2,
        p_delete_entry IN BOOLEAN := TRUE
    ) IS

        v_entry_id VARCHAR2(30);    
        v_prev_entry_id VARCHAR2(30);
        v_next_entry_id VARCHAR2(30);
    
    BEGIN

        v_entry_id := p_id;    
        v_prev_entry_id := v_value_cache_entries(v_entry_id).prev_entry_id;
        v_next_entry_id := v_value_cache_entries(v_entry_id).next_entry_id;
    
        IF v_prev_entry_id IS NOT NULL THEN
            v_value_cache_entries(v_prev_entry_id).next_entry_id := v_next_entry_id;
        ELSE
            v_value_cache_head_id := v_next_entry_id;
        END IF;
        
        IF v_next_entry_id IS NOT NULL THEN
            v_value_cache_entries(v_next_entry_id).prev_entry_id := v_prev_entry_id;
        ELSE
            v_value_cache_tail_id := v_prev_entry_id;
        END IF;
        
        IF p_delete_entry THEN
            v_value_cache_entries.DELETE(v_entry_id);
        END IF;
    
    END;
    
    PROCEDURE set_value_cache_capacity (
        p_capacity IN PLS_INTEGER
    ) IS
    BEGIN
    
        IF p_capacity IS NULL OR p_capacity < 1 THEN
            -- Invalid cache capacity :1!
            error$.raise('JDC-00032', NVL(TO_CHAR(p_capacity), 'NULL'));
        END IF;
        
        FOR v_i IN p_capacity + 1..v_json_value_cache.COUNT LOOP
            v_json_value_cache.DELETE(v_value_cache_tail_id);
            unlink_value_cache_entry(v_value_cache_tail_id);
        END LOOP;
        
        v_value_cache_capacity := p_capacity;
    
    END;
    
    PROCEDURE link_value_cache_entry (
        p_id IN VARCHAR2
    ) IS
    BEGIN
    
        v_value_cache_entries(p_id).prev_entry_id := NULL;
        v_value_cache_entries(p_id).next_entry_id := v_value_cache_head_id;
        
        IF v_value_cache_head_id IS NOT NULL THEN
            v_value_cache_entries(v_value_cache_head_id).prev_entry_id := p_id;
        END IF;
        
        v_value_cache_head_id := p_id;
        
        IF v_value_cache_tail_id IS NULL THEN
            v_value_cache_tail_id := p_id;
        END IF;
    
    END;
    
    PROCEDURE cache_value (
        p_value IN json_core.t_json_value
    ) IS 
    
        v_entry_id VARCHAR2(30);
    
    BEGIN
    
        v_entry_id := p_value.id;
        
        IF v_json_value_cache.EXISTS(v_entry_id) THEN
        
            IF v_entry_id != v_value_cache_head_id THEN
                unlink_value_cache_entry(v_entry_id, FALSE);
                link_value_cache_entry(v_entry_id);
            END IF;
            
        ELSE
        
            v_json_value_cache(v_entry_id) := p_value;
            
            IF v_json_value_cache.COUNT > v_value_cache_capacity THEN
                v_json_value_cache.DELETE(v_value_cache_tail_id);
                unlink_value_cache_entry(v_value_cache_tail_id);
            END IF;
                
            link_value_cache_entry(v_entry_id);
            
        END IF;
    
    END;
    
    FUNCTION get_value (
        p_id IN NUMBER
    )
    RETURN json_core.t_json_value IS
    
        v_entry_id VARCHAR2(30);
        v_value json_core.t_json_value;
        
    BEGIN
    
        IF p_id IS NULL THEN
            -- Value ID not specified!
            error$.raise('JDC-00031');
        END IF;
    
        v_entry_id := p_id;
    
        IF v_json_value_cache.EXISTS(v_entry_id) THEN
        
            IF v_entry_id != v_value_cache_head_id THEN
                unlink_value_cache_entry(v_entry_id, FALSE);
                link_value_cache_entry(v_entry_id);
            END IF;
            
            RETURN v_json_value_cache(v_entry_id);
        
        ELSE
        
            BEGIN
            
                SELECT *
                INTO v_value
                FROM json_values
                WHERE id = p_id;
            
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    -- Value :1 does not exist!
                    error$.raise('JDC-00009', '#' || v_entry_id);
            END;
        
            v_json_value_cache(v_entry_id) := v_value;
        
            IF v_json_value_cache.COUNT > v_value_cache_capacity THEN
                v_json_value_cache.DELETE(v_value_cache_tail_id);
                unlink_value_cache_entry(v_value_cache_tail_id);
            END IF;
                
            link_value_cache_entry(v_entry_id);
            
            RETURN v_value;
        
        END IF;
    
    END;
    
    FUNCTION dump_value (
        p_id IN NUMBER
    )
    RETURN json_core.t_json_values IS
    
        CURSOR c_values IS
            WITH parent_jsvl(id, parent_id, type, name, value, locked, ord) AS
                (SELECT id
                       ,parent_id
                       ,type
                       ,name
                       ,value
                       ,locked
                       ,name
                 FROM json_values
                 WHERE id = p_id
                 UNION ALL
                 SELECT /*+ ORDERED USE_NL(jsvl) */
                        jsvl.id
                       ,jsvl.parent_id
                       ,jsvl.type
                       ,jsvl.name
                       ,jsvl.value
                       ,jsvl.locked
                       ,CASE parent_jsvl.type
                            WHEN 'A' THEN
                                LPAD(jsvl.name, 12, '0')
                            ELSE
                                jsvl.name
                        END
                 FROM parent_jsvl
                     ,json_values jsvl
                 WHERE jsvl.parent_id = parent_jsvl.id
                 ORDER BY 6)
            SEARCH DEPTH FIRST BY ord SET dummy
            SELECT id
                  ,parent_id
                  ,type
                  ,name
                  ,value
                  ,locked
            FROM parent_jsvl;
        
        v_result json_core.t_json_values;
        
    BEGIN
        
        OPEN c_values;
        
        FETCH c_values
        BULK COLLECT INTO v_result;
        
        CLOSE c_values;
        
        RETURN v_result;
    
    END;
    
    PROCEDURE pin_cached_value (
        p_value_id IN NUMBER
    ) IS
    
        v_entry_id VARCHAR2(30);
    
    BEGIN
    
        v_entry_id := p_value_id;
    
        IF v_json_value_cache.EXISTS(v_entry_id) THEN
            v_json_value_cache(v_entry_id).locked := 'T';
        END IF;
    
    END;
    
    PROCEDURE unpin_cached_value (
        p_value_id IN NUMBER
    ) IS
    
        v_entry_id VARCHAR2(30);
    
    BEGIN
    
        v_entry_id := p_value_id;
    
        IF v_json_value_cache.EXISTS(v_entry_id) THEN
            v_json_value_cache(v_entry_id).locked := NULL;
        END IF;
    
    END;
    
    -- JSON query API methods
    
    FUNCTION get_query_signature (
        p_query_element_i IN PLS_INTEGER
    )
    RETURN VARCHAR2 IS
    
        v_signature VARCHAR2(4000);
        
        PROCEDURE visit_element (
            p_i IN PLS_INTEGER
        ) IS
            v_element json_core.t_query_element;
        BEGIN
        
            v_element := json_core.v_query_elements(p_i);
        
            IF v_element.type = 'F' THEN
                v_signature := v_signature || SUBSTR(v_element.value, 1, 1); 
            ELSE
                v_signature := v_signature || v_element.type || CASE WHEN v_element.optional THEN '?' END;
            END IF;
        
            IF v_element.first_child_i IS NOT NULL THEN
                v_signature := v_signature || '(';
                visit_element(v_element.first_child_i);
                v_signature := v_signature || ')';
            END IF;
            
            IF v_element.next_sibling_i IS NOT NULL THEN
                visit_element(v_element.next_sibling_i);
            END IF;
        
        END;
    
    BEGIN
    
        v_signature := '(';
        visit_element(p_query_element_i);
        v_signature := v_signature || ')';
        
        RETURN v_signature;
    
    END;
    
    FUNCTION get_query_statement (
        p_query_element_i IN PLS_INTEGER,
        p_query_type IN CHAR
    )
    RETURN t_query_statement IS
    
        v_cache_key VARCHAR2(32000);
    
        v_line VARCHAR2(32000);
        
        v_table_instance_counter PLS_INTEGER;
        v_comma CHAR;
        v_and VARCHAR2(10);
        v_column_count PLS_INTEGER;
        
        TYPE t_variable_numbers IS 
            TABLE OF PLS_INTEGER
            INDEX BY VARCHAR2(30);
        
        v_statement t_query_statement;
    
        PROCEDURE add_text (
            p_text IN VARCHAR2,
            p_parent_instance IN PLS_INTEGER := NULL
        ) IS
        BEGIN
            
            IF LENGTH(v_line) + LENGTH(p_text) > 32000 THEN
            
                IF v_statement.statement_clob IS NULL THEN
                    DBMS_LOB.CREATETEMPORARY(v_statement.statement_clob, TRUE);
                END IF;
            
                DBMS_LOB.APPEND(v_statement.statement_clob, v_line);
            
                v_line := NULL;
                
            END IF;
            
            v_line := v_line || p_text;
        
        END;
    
        PROCEDURE select_list_visit (
            p_i PLS_INTEGER,
            p_parent_table_instance IN PLS_INTEGER
        ) IS
            
            v_element json_core.t_query_element;
            v_table_instance PLS_INTEGER;
            
        BEGIN
        
            v_element := json_core.v_query_elements(p_i);
            
            IF v_element.type = 'F' THEN
                v_table_instance := p_parent_table_instance;
            ELSE
                v_table_instance_counter := v_table_instance_counter + 1;
                v_table_instance := v_table_instance_counter;
            END IF;
                    
            IF v_element.first_child_i IS NOT NULL THEN
            
                select_list_visit(v_element.first_child_i, v_table_instance);
                
            ELSE
            
                v_column_count := v_column_count + 1;
            
                IF p_query_type = c_TABLE_QUERY THEN
                
                    IF v_element.type = 'F' THEN
                    
                        add_text(
                            CASE v_element.value
                                WHEN 'type' THEN 
                                    v_comma || 'j' || v_table_instance || '.type' 
                                WHEN 'key' THEN 
                                    v_comma || 'j' || v_table_instance || '.name' 
                                WHEN 'path' THEN
                                    v_comma || 'NULL'
                                ELSE 
                                    v_comma || 'j' || v_table_instance || '.' || v_element.value 
                            END
                        );
                        
                    ELSE
                    
                        add_text(v_comma || 'j' || v_table_instance || '.value');
                        
                    END IF;
                    
                ELSIF p_query_type = c_VALUE_QUERY THEN
                
                    add_text(v_comma || 'j' || v_table_instance || '.*');
                    
                ELSIF p_query_type = c_PROPERTY_QUERY THEN
                
                    add_text(v_comma || 'j' || p_parent_table_instance || '.id,j' || p_parent_table_instance || '.type,j' || v_table_instance || '.id,j' || v_table_instance || '.type,:');
                    
                    IF v_element.type = 'N' THEN
                        add_text('const' || v_element.bind_number);
                    ELSE
                        add_text('var' || v_element.bind_number);
                    END IF;
                    
                    add_text(' AS name,j' || v_table_instance || '.locked');
                    
                END IF;    
                
                v_comma := ',';
                
            END IF;
            
            IF v_element.next_sibling_i IS NOT NULL THEN
                select_list_visit(v_element.next_sibling_i, p_parent_table_instance);
            END IF;
        
        END;
        
        PROCEDURE from_list_visit (
            p_i PLS_INTEGER
        ) IS
            
            v_element json_core.t_query_element;
            v_table_instance PLS_INTEGER;
            
        BEGIN
        
            v_element := json_core.v_query_elements(p_i);
        
            IF v_element.type != 'F'  THEN
            
                v_table_instance_counter := v_table_instance_counter + 1;
                v_table_instance := v_table_instance_counter;
                
                add_text(v_comma || 'json_values j' || v_table_instance);
                        
                v_comma := ',';
                
            END IF;
        
            IF v_element.first_child_i IS NOT NULL THEN
                from_list_visit(v_element.first_child_i);
            END IF;
            
            IF v_element.next_sibling_i IS NOT NULL THEN
                from_list_visit(v_element.next_sibling_i);
            END IF;
        
        END;
        
        PROCEDURE where_list_visit (
            p_i PLS_INTEGER,
            p_parent_table_instance IN PLS_INTEGER
        ) IS
            
            v_element json_core.t_query_element;
            v_table_instance PLS_INTEGER;
            
        BEGIN
        
            v_element := json_core.v_query_elements(p_i);
        
            IF v_element.type = 'F' THEN
            
                v_table_instance := p_parent_table_instance;
                
            ELSE
            
                v_table_instance_counter := v_table_instance_counter + 1;
                v_table_instance := v_table_instance_counter;
            
                IF p_parent_table_instance IS NOT NULL THEN
                
                    add_text(v_and || 'j' || v_table_instance || '.parent_id');
                    
                    IF v_element.optional 
                       OR (p_query_type = c_PROPERTY_QUERY AND v_element.first_child_i IS NULL) THEN
                        add_text('(+)');
                    END IF;
                    
                    add_text('=j' || p_parent_table_instance || '.id');
                    
                    v_and := ' AND ';
                    
                END IF;
                
                IF v_element.type = 'N' THEN
                
                    add_text(v_and || 'j' || v_table_instance || '.name');
                    
                    IF v_element.optional 
                       OR (p_query_type = c_PROPERTY_QUERY AND v_element.first_child_i IS NULL) THEN
                        add_text('(+)');
                    END IF;
                    
                    add_text('=:const' || v_element.bind_number);
                    
                    v_and := ' AND ';
                    
                ELSIF v_element.type IN ('R', 'I') THEN
                
                    add_text(v_and || 'j' || v_table_instance || '.id');
                    
                    IF v_element.optional THEN
                        add_text('(+)');
                    END IF;
                    
                    add_text('=TO_NUMBER(:const' || v_element.bind_number || ')');
                    
                    v_and := ' AND ';
                    
                ELSIF v_element.type = ':' THEN
                
                    add_text(v_and || 'j' || v_table_instance || '.name');
                    
                    IF v_element.optional 
                       OR (p_query_type = c_PROPERTY_QUERY AND v_element.first_child_i IS NULL) THEN
                        add_text('(+)');
                    END IF;
                            
                    add_text('=:var' || v_element.bind_number);
                    
                    v_and := ' AND ';
                    
                ELSIF v_element.type = '#' THEN
                
                    add_text(v_and || 'j' || v_table_instance || '.id');
                    
                    IF v_element.optional THEN
                        add_text('(+)');
                    END IF;
                     
                    add_text('=TO_NUMBER(:var' || v_element.bind_number || ')');
                    
                    v_and := ' AND ';
                    
                ELSIF v_element.type = 'A' THEN
                
                    add_text(v_and || 'j' || v_table_instance || '.id=TO_NUMBER(:anchor)');
                    
                    v_and := ' AND ';
                    
                END IF;
                
            END IF;
        
            IF v_element.first_child_i IS NOT NULL THEN
                where_list_visit(v_element.first_child_i, v_table_instance);
            END IF;
            
            IF v_element.next_sibling_i IS NOT NULL THEN
                where_list_visit(v_element.next_sibling_i, p_parent_table_instance);
            END IF;
                
        END;
    
    BEGIN
    
        v_cache_key := p_query_type || get_query_signature(p_query_element_i);
        
        IF v_query_statement_cache.EXISTS(v_cache_key) THEN
            RETURN v_query_statement_cache(v_cache_key);
        END IF;    
    
        v_table_instance_counter := 0;
        v_column_count := 0;
        v_comma := NULL;
         
        add_text('SELECT /*+ FIRST_ROWS ORDERED */ ');
        select_list_visit(p_query_element_i, NULL);
        
        v_table_instance_counter := 0;
        v_comma := NULL; 
        add_text(' FROM ');
        from_list_visit(p_query_element_i);
        
        v_table_instance_counter := 0;
        v_and := ' WHERE '; 
        where_list_visit(p_query_element_i, NULL);
        
        IF v_line IS NOT NULL AND v_statement.statement_clob IS NOT NULL THEN
            DBMS_LOB.APPEND(v_statement.statement_clob, v_line);
        END IF;
        
        IF v_statement.statement_clob IS NULL THEN
            v_statement.statement := v_line;
        END IF;
        
        v_query_statement_cache(v_cache_key) := v_statement;
        
        RETURN v_statement;
    
    END;
    
    FUNCTION prepare_query (
        p_anchor_id IN NUMBER,
        p_query_element_i IN PLS_INTEGER,
        p_query_statement IN t_query_statement,
        p_bind IN bind
    )
    RETURN INTEGER IS
    
        v_constants t_varchars;
        v_cursor_id INTEGER;
        
        v_max_bind_number PLS_INTEGER;
        
        PROCEDURE bind_values (
            p_query_element_i IN PLS_INTEGER
        ) IS
            v_element json_core.t_query_element;
        BEGIN
        
            v_element := json_core.v_query_elements(p_query_element_i);
            
            IF v_element.type IN (':', '#') THEN
            
                IF v_element.bind_number > v_max_bind_number THEN    
                
                    IF p_bind IS NULL
                       OR v_element.bind_number > p_bind.COUNT
                    THEN
                        -- Not all variables bound!
                        error$.raise('JDC-00040');
                    END IF;
                    
                    DBMS_SQL.BIND_VARIABLE(
                        v_cursor_id, 
                        ':var' || v_element.bind_number, 
                        p_bind(v_element.bind_number)
                     );
                     
                     v_max_bind_number := v_element.bind_number;
                     
                 END IF;
                
            ELSIF v_element.type = 'A' THEN
            
                DBMS_SQL.BIND_VARIABLE(
                    v_cursor_id, 
                    ':anchor', 
                    p_anchor_id
                );
            
            ELSIF v_element.type IN ('N', 'I', 'R') THEN
            
                DBMS_SQL.BIND_VARIABLE(
                    v_cursor_id, 
                    ':const' || v_element.bind_number, 
                    NVL(v_element.value, '0')
                );
            
            END IF;    
            
            IF v_element.first_child_i IS NOT NULL THEN
                bind_values(v_element.first_child_i);
            END IF;
            
            IF v_element.next_sibling_i IS NOT NULL THEN
                bind_values(v_element.next_sibling_i);
            END IF;
        
        END;
    
    BEGIN
        
        v_cursor_id := DBMS_SQL.OPEN_CURSOR();
        
        IF p_query_statement.statement_clob IS NOT NULL THEN
            DBMS_SQL.PARSE(v_cursor_id, p_query_statement.statement_clob, DBMS_SQL.NATIVE);
        ELSE
            DBMS_SQL.PARSE(v_cursor_id, p_query_statement.statement, DBMS_SQL.NATIVE);
        END IF;
        
        v_max_bind_number := 0;
        bind_values(p_query_element_i);
        
        RETURN v_cursor_id;
    
    END;
    
    FUNCTION to_refcursor (
        p_cursor_id IN INTEGER
    )
    RETURN SYS_REFCURSOR IS
    
        v_cursor_id INTEGER;
    
    BEGIN
    
        v_cursor_id := p_cursor_id;
        
        RETURN DBMS_SQL.TO_REFCURSOR(v_cursor_id);
    
    END;
    
    -- Methods for value querying
    
    FUNCTION request_value (
        p_anchor_id IN PLS_INTEGER,
        p_path_element_i IN PLS_INTEGER,
        p_bind IN bind
    ) 
    RETURN NUMBER IS
        
        v_path_statement t_query_statement;
        
        v_cursor_id INTEGER;
        v_result INTEGER;
        v_fetched_row_count INTEGER;
        
        v_number NUMBER;
        v_string VARCHAR2(4000);
        v_char CHAR;
        
        v_value json_core.t_json_value;
    
    BEGIN

        v_path_statement := get_query_statement(p_path_element_i, c_VALUE_QUERY);
        v_cursor_id := prepare_query(p_anchor_id, p_path_element_i, v_path_statement, p_bind);
        
        DBMS_SQL.DEFINE_COLUMN(v_cursor_id, 1, v_number);
        DBMS_SQL.DEFINE_COLUMN(v_cursor_id, 2, v_number);
        DBMS_SQL.DEFINE_COLUMN_CHAR(v_cursor_id, 3, v_char, 1);
        DBMS_SQL.DEFINE_COLUMN(v_cursor_id, 4, v_string, 4000);
        DBMS_SQL.DEFINE_COLUMN(v_cursor_id, 5, v_string, 4000);
        DBMS_SQL.DEFINE_COLUMN_CHAR(v_cursor_id, 6, v_char, 1);
        
        BEGIN
        
            v_fetched_row_count := DBMS_SQL.EXECUTE_AND_FETCH(v_cursor_id, TRUE);
            
        EXCEPTION
            WHEN NO_DATA_FOUND OR TOO_MANY_ROWS THEN
                DBMS_SQL.CLOSE_CURSOR(v_cursor_id);
                RAISE;
        END;
        
        DBMS_SQL.COLUMN_VALUE(v_cursor_id, 1, v_value.id);
        DBMS_SQL.COLUMN_VALUE(v_cursor_id, 2, v_value.parent_id);
        DBMS_SQL.COLUMN_VALUE_CHAR(v_cursor_id, 3, v_value.type);
        DBMS_SQL.COLUMN_VALUE(v_cursor_id, 4, v_value.name);
        DBMS_SQL.COLUMN_VALUE(v_cursor_id, 5, v_value.value);
        DBMS_SQL.COLUMN_VALUE_CHAR(v_cursor_id, 6, v_value.locked);
        
        DBMS_SQL.CLOSE_CURSOR(v_cursor_id);
        
        cache_value(v_value);
        
        RETURN v_value.id;
        
    END;
    
    FUNCTION request_value (
        p_anchor_id IN NUMBER,
        p_path IN VARCHAR2,
        p_bind IN bind,
        p_raise_not_found IN BOOLEAN := FALSE
    ) 
    RETURN NUMBER IS
    
        v_parent_value json_core.t_json_value;
        v_path_element_i PLS_INTEGER;    
    
        v_bind bind;
    
    BEGIN
    
        v_path_element_i := json_core.parse_path(p_path, p_anchor_id IS NOT NULL);
    
        BEGIN
        
            RETURN request_value(p_anchor_id, v_path_element_i, p_bind);
            
        EXCEPTION
        
            WHEN NO_DATA_FOUND THEN
            
                IF p_raise_not_found THEN
                    -- Value :1 does not exist!
                    error$.raise('JDC-00009', p_path);
                ELSE
                    RETURN NULL;
                END IF;
                
            WHEN TOO_MANY_ROWS THEN
            
                -- Multiple values found at the path :1!
                error$.raise('JDC-00004', p_path);
                
        END; 
        
    END;
    
    FUNCTION request_property_value (
        p_parent_id IN NUMBER,
        p_name IN VARCHAR2
    )
    RETURN NUMBER IS
    
        CURSOR c_property IS
            SELECT *
            FROM json_values
            WHERE parent_id = p_parent_id
                  AND name = p_name;
    
    BEGIN
    
        FOR v_property IN c_property LOOP
            cache_value(v_property);
            RETURN v_property.id;
        END LOOP;
        
        RETURN NULL;
    
    END;
    
    FUNCTION request_property (
        p_anchor_id IN NUMBER,
        p_path IN VARCHAR2,
        p_bind IN bind
    ) 
    RETURN t_property IS
    
        v_path_element_i PLS_INTEGER;
        v_path_length PLS_INTEGER;
        v_property_element json_core.t_query_element;
    
        v_parent_value json_core.t_json_value;
        
        v_path_statement t_query_statement;
    
        v_cursor_id INTEGER;
        v_fetched_row_count INTEGER;
        
        v_number NUMBER;
        v_char CHAR;
        v_string VARCHAR2(4000);
        
        v_property t_property;
            
    BEGIN
    
        v_path_element_i := json_core.parse_path(p_path, p_anchor_id IS NOT NULL);
        
        v_property_element := json_core.v_query_elements(v_path_element_i);
        v_path_length := 1;
        
        WHILE v_property_element.first_child_i IS NOT NULL LOOP
        
            v_property_element := json_core.v_query_elements(v_property_element.first_child_i);
            v_path_length := v_path_length + 1;
            
        END LOOP;
        
        IF v_path_length < 2 THEN
            -- Property name missing!
            error$.raise('JDC-00041');
        ELSIF v_property_element.type NOT IN ('N', ':') THEN
            -- Invalid property name!
            error$.raise('JDC-00022');
        END IF;
        
        v_path_statement := get_query_statement(v_path_element_i, c_PROPERTY_QUERY);
        v_cursor_id := prepare_query(p_anchor_id, v_path_element_i, v_path_statement, p_bind);
        
        DBMS_SQL.DEFINE_COLUMN(v_cursor_id, 1, v_number);
        DBMS_SQL.DEFINE_COLUMN_CHAR(v_cursor_id, 2, v_char, 1);
        DBMS_SQL.DEFINE_COLUMN(v_cursor_id, 3, v_number);
        DBMS_SQL.DEFINE_COLUMN_CHAR(v_cursor_id, 4, v_char, 1);
        DBMS_SQL.DEFINE_COLUMN(v_cursor_id, 5, v_string, 4000);
        DBMS_SQL.DEFINE_COLUMN_CHAR(v_cursor_id, 6, v_char, 1);
        
        BEGIN
        
            v_fetched_row_count := DBMS_SQL.EXECUTE_AND_FETCH(v_cursor_id, TRUE);
            
        EXCEPTION
        
            WHEN NO_DATA_FOUND THEN
            
                DBMS_SQL.CLOSE_CURSOR(v_cursor_id);
        
                -- No container for property at path :1 could be found!
                error$.raise('JDC-00007', p_path);
            
            WHEN TOO_MANY_ROWS THEN
            
                DBMS_SQL.CLOSE_CURSOR(v_cursor_id);
        
                -- Multiple values found at the path :1!
                error$.raise('JDC-00004', p_path);
                
        END;
        
        DBMS_SQL.COLUMN_VALUE(v_cursor_id, 1, v_property.parent_id);
        DBMS_SQL.COLUMN_VALUE_CHAR(v_cursor_id, 2, v_property.parent_type);
        DBMS_SQL.COLUMN_VALUE(v_cursor_id, 3, v_property.property_id);
        DBMS_SQL.COLUMN_VALUE_CHAR(v_cursor_id, 4, v_property.property_type);
        DBMS_SQL.COLUMN_VALUE(v_cursor_id, 5, v_property.property_name);
        DBMS_SQL.COLUMN_VALUE_CHAR(v_cursor_id, 6, v_property.property_locked);
        
        DBMS_SQL.CLOSE_CURSOR(v_cursor_id);
        
        RETURN v_property;
        
    END;
    
    FUNCTION get_parse_events (
        p_value_id IN NUMBER,
        p_serialize_nulls IN BOOLEAN
    ) 
    RETURN t_varchars IS
            
        v_value json_core.t_json_value;
    
        v_json_stack t_varchars;
        v_json_stack_height PLS_INTEGER;
        
        v_last_lvl PLS_INTEGER;
    
        CURSOR c_event_values (p_root_id IN NUMBER) IS
            WITH parent_jsvl(id, parent_id, type, name, value, lvl, ord) AS
                (SELECT id
                       ,parent_id
                       ,type
                       ,name
                       ,value
                       ,1 AS lvl
                       ,name
                 FROM json_values
                 WHERE id = p_root_id
                 UNION ALL
                 SELECT /*+ ORDERED USE_NL(jsvl) */
                        jsvl.id
                       ,jsvl.parent_id
                       ,jsvl.type
                       ,jsvl.name
                       ,jsvl.value
                       ,parent_jsvl.lvl + 1
                       ,CASE parent_jsvl.type
                            WHEN 'A' THEN
                                LPAD(jsvl.name, 12, '0')
                            ELSE
                                jsvl.name
                        END
                 FROM parent_jsvl
                     ,json_values jsvl
                 WHERE jsvl.parent_id = parent_jsvl.id
                 ORDER BY 6)
            SEARCH DEPTH FIRST BY ord SET dummy
            SELECT id
                  ,parent_id
                  ,type
                  ,name
                  ,value
                  ,lvl
            FROM parent_jsvl;
            
        TYPE t_event_values IS
            TABLE OF c_event_values%ROWTYPE;
            
        v_event_values t_event_values; 
        v_event_value c_event_values%ROWTYPE;
            
        v_name VARCHAR2(4000);
        v_parse_events t_varchars;    
            
        PROCEDURE add_event (
            p_name IN CHAR,
            p_value IN VARCHAR2 := NULL
        ) IS
        BEGIN
            v_parse_events.EXTEND(1);
            v_parse_events(v_parse_events.COUNT) := p_name || p_value;
        END;
                
    BEGIN
        
        v_value := get_value(p_value_id);
    
        v_parse_events := t_varchars();
        
        v_json_stack := t_varchars();
        v_json_stack_height := 0;
        v_last_lvl := 0;
    
        OPEN c_event_values(p_value_id);
        
        FETCH c_event_values
        BULK COLLECT INTO v_event_values;
        
        CLOSE c_event_values;
    
        FOR v_i IN 1..v_event_values.COUNT LOOP
        
            v_event_value := v_event_values(v_i);
            
            FOR v_i IN v_event_value.lvl..v_last_lvl LOOP
                  
                IF v_json_stack(v_json_stack_height) IN ('O', 'R') THEN
                    add_event('}');                        
                ELSIF v_json_stack(v_json_stack_height) = 'A' THEN
                    add_event(']');
                END IF;
                    
                v_json_stack_height := v_json_stack_height - 1; 
                    
            END LOOP;
            
            IF v_event_value.name IS NOT NULL 
               AND v_json_stack_height > 0
               AND (v_event_value.type != 'E'
                    OR NVL(p_serialize_nulls, FALSE)) 
            THEN
                add_event(':', v_event_value.name);
            END IF;
            
            CASE v_event_value.type
                  
                WHEN 'S' THEN
                    add_event('S', v_event_value.value);  
                WHEN 'N' THEN
                    add_event('N', v_event_value.value);  
                WHEN 'B' THEN
                    add_event('B', v_event_value.value);
                WHEN 'E' THEN
                    IF NVL(p_serialize_nulls, FALSE) 
                       OR v_event_value.id = p_value_id 
                    THEN
                        add_event('E');
                    END IF;
                WHEN 'O' THEN
                    add_event('{');
                WHEN 'R' THEN
                    add_event('{');
                WHEN 'A' THEN
                    add_event('[');
                
            END CASE;
            
            v_json_stack_height := v_json_stack_height + 1;
            
            IF v_json_stack.COUNT < v_json_stack_height THEN
                v_json_stack.EXTEND(1);
            END IF;
            
            v_json_stack(v_json_stack_height) := v_event_value.type;
                
            v_last_lvl := v_event_value.lvl;
        
        END LOOP;
       
    
        FOR v_i IN REVERSE 1..v_json_stack_height LOOP
          
             IF v_json_stack(v_i) IN ('O', 'R') THEN
                 add_event('}');    
             ELSIF v_json_stack(v_i) = 'A' THEN
                 add_event(']');
             END IF;
        
        END LOOP;
        
        RETURN v_parse_events;
    
    END;
    
    -- Special object methods
    
    FUNCTION get_keys (
        p_object_id IN NUMBER
    )
    RETURN t_varchars IS
    
        v_value json_core.t_json_value;
        v_keys t_varchars;
    
    BEGIN
    
        v_value := get_value(p_object_id);
     
        IF v_value.type NOT IN ('O', 'R', 'A') THEN
            -- Value is not an object!
            error$.raise('JDC-00021');
        END IF;
        
        IF v_value.type = 'A' THEN
        
            SELECT name
            BULK COLLECT INTO v_keys
            FROM json_values
            WHERE parent_id = p_object_id
            ORDER BY TO_INDEX(name);
            
        ELSE
        
            SELECT name
            BULK COLLECT INTO v_keys
            FROM json_values
            WHERE parent_id = p_object_id
            ORDER BY name;
            
        END IF;
        
        RETURN v_keys;
    
    END;
    
    -- Special array methods
    
    FUNCTION get_length (
        p_array_id IN NUMBER
    )
    RETURN NUMBER IS 
    
        v_value json_core.t_json_value;
        v_length NUMBER;
    
    BEGIN
    
        v_value := get_value(p_array_id);
    
        IF v_value.type != 'A' THEN
            -- Value is not an array!
            error$.raise('JDC-00012');
        END IF;
        
        SELECT NVL(MAX(to_index(name)) + 1, 0)
        INTO v_length
        FROM json_values 
        WHERE parent_id = p_array_id;
        
        RETURN v_length;
    
    END;
    
    FUNCTION get_raw_values (
        p_array_id IN NUMBER,
        p_type IN CHAR
    )
    RETURN t_varchars IS
    
        v_array json_core.t_json_value;
        v_raw_values t_varchars;
        
        v_values json_core.t_json_values;
        v_value json_core.t_json_value;
        
        v_element_i PLS_INTEGER;
        v_last_element_i PLS_INTEGER;
        
    BEGIN
    
        v_array := get_value(p_array_id);
        
        IF v_array.type != 'A' THEN
            --Value is not an array!
            error$.raise('JDC-00012');
        END IF;
        
        SELECT *
        BULK COLLECT INTO v_values
        FROM json_values
        WHERE parent_id = p_array_id
        ORDER BY to_index(name); 
        
        v_raw_values := t_varchars();
        v_last_element_i := 0;
        
        FOR v_i IN 1..v_values.COUNT LOOP
        
            v_value := v_values(v_i);
            
            IF v_value.type NOT IN (p_type, 'E') THEN
                -- Type conversion error!
                error$.raise('JDC-00010');
            END IF;
            
            v_element_i := v_value.name;
            
            FOR v_i IN v_last_element_i..v_element_i LOOP
                v_raw_values.EXTEND(1);
            END LOOP;
            
            v_raw_values(v_element_i + 1) := v_value.value;
            
            v_last_element_i := v_element_i + 1;
        
        END LOOP;
        
        RETURN v_raw_values;
    
    END;
    
    FUNCTION index_of (
        p_array_id IN NUMBER,
        p_type IN VARCHAR2,
        p_value IN VARCHAR2,
        p_from_index IN NUMBER
    )
    RETURN NUMBER IS
    
        v_value json_core.t_json_value;
        v_name VARCHAR2(4000);
    
    BEGIN
    
        v_value := get_value(p_array_id);
    
        IF v_value.type != 'A' THEN
            -- Value is not an array!
            error$.raise('JDC-00012');
        END IF;
        
        BEGIN
        
            SELECT name
            INTO v_name
            FROM json_values
            WHERE parent_id = p_array_id
                  AND type = p_type
                  AND to_index(name) >= NVL(p_from_index, 0)
                  AND (NVL(value, p_value) IS NULL
                       OR value = p_value)
            ORDER BY to_index(name)
            FETCH FIRST 1 ROW ONLY;
            
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                v_name := '-1';
        END;
        
        RETURN v_name;
    
    END;
    
    -- JSON creation, modification and deletion methods
    
    FUNCTION create_json (
        p_parent_id IN NUMBER,
        p_name IN VARCHAR2,
        p_content_parse_events IN t_varchars,
        p_event_i IN PLS_INTEGER := 1
    ) 
    RETURN NUMBER IS
    BEGIN
    
        RETURN persistent_json_writer.write_json(p_parent_id, p_name, p_content_parse_events, p_event_i);
        
    END;
    
    FUNCTION create_json (
        p_content_parse_events IN t_varchars
    )
    RETURN NUMBER IS
    BEGIN
    
        RETURN create_json(NULL, NULL, p_content_parse_events);
        
    END;
    
    FUNCTION set_property (
        p_anchor_id IN NUMBER,
        p_path IN VARCHAR2,
        p_bind IN bind,
        p_content_parse_events IN t_varchars
    )
    RETURN NUMBER IS

        v_property t_property;
        v_index NUMBER;

    BEGIN

        v_property := request_property(p_anchor_id, p_path, p_bind);
        
        IF v_property.property_locked = 'T' THEN
            -- Value :1 is locked!
            error$.raise('JDC-00024', p_path);
        ELSIF v_property.parent_type NOT IN ('R', 'O', 'A') THEN
            -- Scalar values and null can't have properties!
            error$.raise('JDC-00008');
        END IF;

        IF v_property.property_id IS NOT NULL THEN
            
            DELETE FROM json_values
            WHERE id = v_property.property_id;
            
        END IF;

        IF v_property.parent_type = 'A' THEN
                
            v_index := to_index(v_property.property_name);
        
            IF v_index IS NULL THEN
                -- Invalid array element index :1!
                error$.raise('JDC-00013', v_property.property_name);
            END IF;
            
        END IF;

        RETURN create_json (
            v_property.parent_id
           ,v_property.property_name
           ,p_content_parse_events
        );

    END;
    
    PROCEDURE delete_value (
        p_value_id IN NUMBER
    ) IS
        v_value json_core.t_json_value;
    BEGIN
    
        v_value := get_value(p_value_id);
        
        IF v_value.type = 'R' THEN
            -- Root can''t be deleted!
            error$.raise('JDC-00035');
        ELSIF v_value.locked = 'T' THEN
            -- Value :1 is locked!
            error$.raise('JDC-00024', '#' || p_value_id);
        END IF;
        
        DELETE FROM json_values
        WHERE id = p_value_id;
        
        unlink_value_cache_entry(p_value_id);
        v_json_value_cache.DELETE(p_value_id);
        
    END;
    
    -- Value locking/unlocking methods
    
    PROCEDURE pin_value (
        p_id IN NUMBER,
        p_pin_tree IN BOOLEAN
    ) IS
    
        v_value json_core.t_json_value;
        
        v_parent_ids t_numbers;
        v_child_ids t_numbers;
        v_ids_to_pin t_numbers;
    
    BEGIN
    
        v_value := get_value(p_id);
        
        SELECT id
        BULK COLLECT INTO v_parent_ids
        FROM json_values
        START WITH id = p_id
        CONNECT BY PRIOR parent_id = id
                   AND locked IS NULL
        FOR UPDATE;
        
        IF p_pin_tree THEN
        
            SELECT id
            BULK COLLECT INTO v_child_ids
            FROM json_values
            WHERE locked IS NULL
            START WITH parent_id = p_id
            CONNECT BY PRIOR id = parent_id
            FOR UPDATE;
            
        ELSE
        
            v_child_ids := t_numbers();
        
        END IF;
        
        v_ids_to_pin := v_parent_ids MULTISET UNION v_child_ids;
        
        FORALL v_i IN 1..v_ids_to_pin.COUNT
            UPDATE json_values
            SET locked = 'T'
            WHERE id = v_ids_to_pin(v_i);
            
        FOR v_i IN 1..v_ids_to_pin.COUNT LOOP
            pin_cached_value(v_ids_to_pin(v_i));
        END LOOP;
    
    END;
    
    PROCEDURE unpin_value (
        p_id IN NUMBER,
        p_unpin_tree IN BOOLEAN
    ) IS
    
        v_value json_core.t_json_value;
        
        CURSOR c_pinned_child (
            p_parent_id IN NUMBER
        ) IS
        SELECT 1
        FROM json_values
        WHERE parent_id = p_parent_id
              AND locked = 'T';
        
        v_dummy NUMBER;
        
        v_ids_to_unpin t_numbers;
    
    BEGIN
    
        v_value := get_value(p_id);
        
        IF v_value.type = 'R' THEN
            -- Root can''t be unlocked!
            error$.raise('JDC-00034');
        END IF;
        
        IF v_value.locked IS NULL THEN
            RETURN;
        END IF;
        
        IF p_unpin_tree THEN
        
            SELECT id
            BULK COLLECT INTO v_ids_to_unpin
            FROM json_values
            START WITH id = p_id
            CONNECT BY PRIOR id = parent_id
                       AND locked = 'T'
            FOR UPDATE;
            
        ELSE
        
            OPEN c_pinned_child(p_id);
        
            FETCH c_pinned_child
            INTO v_dummy;
            
            IF c_pinned_child%FOUND THEN
                -- Value has locked children!
                error$.raise('JDC-00033');
            END IF;  
            
            v_ids_to_unpin := t_numbers(p_id);
            
        END IF;
        
        FORALL v_i IN 1..v_ids_to_unpin.COUNT
            UPDATE json_values
            SET locked = NULL
            WHERE id = v_ids_to_unpin(v_i);
            
        FOR v_i IN 1..v_ids_to_unpin.COUNT LOOP
            unpin_cached_value(v_ids_to_unpin(v_i));
        END LOOP;
    
    END;
    
    -- Bulk fetching from a JSON table cursor
    
    PROCEDURE prepare_table_query (
        p_anchor_id IN NUMBER,
        p_query IN VARCHAR2,
        p_bind IN bind,
        p_cursor_id OUT NUMBER,
        p_column_count OUT NUMBER
    ) IS
        v_query_element_i PLS_INTEGER;
        v_query_statement t_query_statement;
        v_result INTEGER;
    BEGIN
    
        v_query_element_i := json_core.parse_query(p_query, p_anchor_id IS NOT NULL);
        
        v_query_statement := get_query_statement(
            v_query_element_i, 
            c_TABLE_QUERY
        );
    
        p_cursor_id := prepare_query(
            p_anchor_id,
            v_query_element_i,
            v_query_statement, 
            p_bind
        );
        
        v_result := DBMS_SQL.EXECUTE(p_cursor_id);
        
        p_column_count := json_core.get_query_column_count(v_query_element_i);
    
    END;
    
    PROCEDURE fetch_table_rows (
        p_cursor_id IN NUMBER,
        p_column_count IN PLS_INTEGER,
        p_fetched_row_count OUT PLS_INTEGER,
        p_row_buffer IN OUT NOCOPY t_varchars
    ) IS
        v_buffer_size PLS_INTEGER;
        v_column_values DBMS_SQL.VARCHAR2_TABLE;
    BEGIN
    
        v_buffer_size := p_row_buffer.COUNT / p_column_count;
    
        FOR v_i IN 1..p_column_count LOOP
            DBMS_SQL.DEFINE_ARRAY(p_cursor_id, v_i, v_column_values, v_buffer_size, 1);
        END LOOP;
        
        p_fetched_row_count := DBMS_SQL.FETCH_ROWS(p_cursor_id);
                
        IF p_fetched_row_count > 0 THEN
                
            FOR v_i IN 1..p_column_count LOOP
                    
                DBMS_SQL.COLUMN_VALUE(p_cursor_id, v_i, v_column_values);
                        
                FOR v_j IN 1..p_fetched_row_count LOOP
                    p_row_buffer((v_i - 1) * v_buffer_size + v_j) := v_column_values(v_j);
                END LOOP;
                        
            END LOOP;   
        
        END IF;
    
    END;
    
BEGIN
    json_core.touch;
END;