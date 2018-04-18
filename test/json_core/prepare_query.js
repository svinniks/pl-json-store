const VALUE_QUERY = 'V';

test("Prepare small query", function() {

    let elements = database.call("json_core.parse_query", {
        p_query: "$.person.name"
    });

    let statement = database.call("json_core.get_query_statement", {
        p_query_elements: elements,
        p_query_type: VALUE_QUERY
    });

    let cursorId = database.call("json_core.prepare_query", {
        p_query_elements: elements,
        p_query_statement: statement,
        p_bind: null
    });

    expect(cursorId).to.not.be(null);
});

test("Prepare query with a CLOB statement", function() {

    let elements = database.call("json_core.parse_query", {
        p_query: "$.person.name"
    });

    let statement = database.call("json_core.get_query_statement", {
        p_query_elements: elements,
        p_query_type: VALUE_QUERY
    });

    statement.statement_clob = statement.statement;
    statement.statement = null;

    let cursorId = database.call("json_core.prepare_query", {
        p_query_elements: elements,
        p_query_statement: statement,
        p_bind: null
    });

    expect(cursorId).to.not.be(null);
});

test("NULL bind values when there are bind variables", function() {

    let elements = database.call("json_core.parse_query", {
        p_query: "#person_id.address.:property"
    });

    let statement = database.call("json_core.get_query_statement", {
        p_query_elements: elements,
        p_query_type: VALUE_QUERY
    });

    expect(function() {
    
        database.call("json_core.prepare_query", {
            p_query_elements: elements,
            p_query_statement: statement,
            p_bind: null
        });
    
    }).to.throw(/JDOC-00040/);

});

test("Less bind values than variables", function() {

    let elements = database.call("json_core.parse_query", {
        p_query: "#person_id.address.:property"
    });

    let statement = database.call("json_core.get_query_statement", {
        p_query_elements: elements,
        p_query_type: VALUE_QUERY
    });

    expect(function() {
    
        database.call("json_core.prepare_query", {
            p_query_elements: elements,
            p_query_statement: statement,
            p_bind: ["123"]
        });
    
    }).to.throw(/JDOC-00040/);

});

test("Equal number of bind variables and values", function() {

    let elements = database.call("json_core.parse_query", {
        p_query: "#person_id.address.:property"
    });

    let statement = database.call("json_core.get_query_statement", {
        p_query_elements: elements,
        p_query_type: VALUE_QUERY
    });

    let cursorId = database.call("json_core.prepare_query", {
        p_query_elements: elements,
        p_query_statement: statement,
        p_bind: ["123", "city"]
    });

    expect(cursorId).to.not.be(null);
    
});

test("More bind values than variables", function() {

    let elements = database.call("json_core.parse_query", {
        p_query: "#person_id.address.:property"
    });

    let statement = database.call("json_core.get_query_statement", {
        p_query_elements: elements,
        p_query_type: VALUE_QUERY
    });

    let cursorId = database.call("json_core.prepare_query", {
        p_query_elements: elements,
        p_query_statement: statement,
        p_bind: ["123", "city", "property"]
    });

    expect(cursorId).to.not.be(null);
    
});

test("Data fetching from a query without bind variables", function() {

    let valueId = database.call("json_store.create_json", {
        p_content: {
            name: "Sergejs",
            address: {
                city: "Riga"
            }
        }
    });

    let elements = database.call("json_core.parse_query", {
        p_query: `#${valueId}.address.city`
    });

    let statement = database.call("json_core.get_query_statement", {
        p_query_elements: elements,
        p_query_type: VALUE_QUERY
    });

    let cursorId = database.call("json_core.prepare_query", {
        p_query_elements: elements,
        p_query_statement: statement,
        p_bind: null
    });

    expect(cursorId).to.not.be(null);
    
    database.run(`
        DECLARE
            v_result INTEGER;
        BEGIN
            v_result := DBMS_SQL.EXECUTE(${cursorId});
        END;
    `);

    let objects = database.selectValue(`
        json_core.to_refcursor(${cursorId}) AS "VALUES"
    FROM dual`);

    expect(objects).to.eql([
        {
            id: valueId + 3,
            parent_id: valueId + 2,
            type: "S",
            name: "city",
            value: "Riga",
            locked: null
        }
    ])

});

test("Data fetching from a query with bind variables", function() {

    let valueId = database.call("json_store.create_json", {
        p_content: {
            name: "Sergejs",
            address: {
                city: "Riga"
            }
        }
    });

    let elements = database.call("json_core.parse_query", {
        p_query: `#id.address.:property`
    });

    let statement = database.call("json_core.get_query_statement", {
        p_query_elements: elements,
        p_query_type: VALUE_QUERY
    });

    let cursorId = database.call("json_core.prepare_query", {
        p_query_elements: elements,
        p_query_statement: statement,
        p_bind: [valueId, "city"]
    });

    expect(cursorId).to.not.be(null);

    database.run(`
        DECLARE
            v_result INTEGER;
        BEGIN
            v_result := DBMS_SQL.EXECUTE(${cursorId});
        END;
    `);
    
    let objects = database.selectValue(`
        json_core.to_refcursor(${cursorId}) AS "VALUES"
    FROM dual`);

    expect(objects).to.eql([
        {
            id: valueId + 3,
            parent_id: valueId + 2,
            type: "S",
            name: "city",
            value: "Riga",
            locked: null
        }
    ])

});

test("Pass non-number into ID bind variable", function() {

    let valueId = database.call("json_store.create_json", {
        p_content: {
            name: "Sergejs",
            address: {
                city: "Riga"
            }
        }
    });

    let elements = database.call("json_core.parse_query", {
        p_query: `#id.address.:property`
    });

    let statement = database.call("json_core.get_query_statement", {
        p_query_elements: elements,
        p_query_type: VALUE_QUERY
    });

    expect(function() {
    
        let cursorId = database.call("json_core.prepare_query", {
            p_query_elements: elements,
            p_query_statement: statement,
            p_bind: ["abc", "city"]
        });    
        
        database.run(`
            DECLARE
                v_result INTEGER;
            BEGIN
                v_result := DBMS_SQL.EXECUTE(${cursorId});
            END;
        `);
    
    }).to.throw(/ORA-01722/);

});