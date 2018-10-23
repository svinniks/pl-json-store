const VALUE_QUERY = 'V';

test("Prepare small query", function() {

    let elementI = database.call("json_core.parse_query", {
        p_query: "$.person.name"
    });

    let statement = database.call("persistent_json_store.get_query_statement", {
        p_query_element_i: elementI,
        p_query_type: VALUE_QUERY
    });

    let cursorId = database.call("persistent_json_store.prepare_query", {
        p_anchor_id: null,
        p_query_element_i: elementI,
        p_query_statement: statement,
        p_bind: null
    });

    expect(cursorId).to.not.be(null);
});

test("Prepare query with a CLOB statement", function() {

    let elementI = database.call("json_core.parse_query", {
        p_query: "$.person.name"
    });

    let statement = database.call("persistent_json_store.get_query_statement", {
        p_query_element_i: elementI,
        p_query_type: VALUE_QUERY
    });

    statement.statement_clob = statement.statement;
    statement.statement = null;

    let cursorId = database.call("persistent_json_store.prepare_query", {
        p_anchor_id: null,
        p_query_element_i: elementI,
        p_query_statement: statement,
        p_bind: null
    });

    expect(cursorId).to.not.be(null);
});

test("NULL bind values when there are bind variables", function() {

    let elementI = database.call("json_core.parse_query", {
        p_query: "#person_id.address.:property"
    });

    let statement = database.call("persistent_json_store.get_query_statement", {
        p_query_element_i: elementI,
        p_query_type: VALUE_QUERY
    });

    expect(function() {
    
        database.call("persistent_json_store.prepare_query", {
            p_anchor_id: null,
            p_query_element_i: elementI,
            p_query_statement: statement,
            p_bind: null
        });
    
    }).to.throw(/JDC-00040/);

});

test("Less bind values than variables", function() {

    let elementI = database.call("json_core.parse_query", {
        p_query: "#person_id.address.:property"
    });

    let statement = database.call("persistent_json_store.get_query_statement", {
        p_query_element_i: elementI,
        p_query_type: VALUE_QUERY
    });

    expect(function() {
    
        database.call("persistent_json_store.prepare_query", {
            p_anchor_id: null,
            p_query_element_i: elementI,
            p_query_statement: statement,
            p_bind: ["123"]
        });
    
    }).to.throw(/JDC-00040/);

});

test("Equal number of bind variables and values", function() {

    let elementI = database.call("json_core.parse_query", {
        p_query: "#person_id.address.:property"
    });

    let statement = database.call("persistent_json_store.get_query_statement", {
        p_query_element_i: elementI,
        p_query_type: VALUE_QUERY
    });

    let cursorId = database.call("persistent_json_store.prepare_query", {
        p_anchor_id: null,
        p_query_element_i: elementI,
        p_query_statement: statement,
        p_bind: ["123", "city"]
    });

    expect(cursorId).to.not.be(null);
    
});

test("More bind values than variables", function() {

    let elementI = database.call("json_core.parse_query", {
        p_query: "#person_id.address.:property"
    });

    let statement = database.call("persistent_json_store.get_query_statement", {
        p_query_element_i: elementI,
        p_query_type: VALUE_QUERY
    });

    let cursorId = database.call("persistent_json_store.prepare_query", {
        p_anchor_id: null,
        p_query_element_i: elementI,
        p_query_statement: statement,
        p_bind: ["123", "city", "property"]
    });

    expect(cursorId).to.not.be(null);
    
});

test("Data fetching from a query without bind variables", function() {

    let value = {
        name: "Sergejs",
        address: {
            city: "Riga"
        }
    };

    let valueId = database.call("persistent_json_store.create_json", {
        p_content_parse_events: database.call("json_parser.parse", {
            p_content: JSON.stringify(value)
        })
    });

    let elementI = database.call("json_core.parse_query", {
        p_query: `#${valueId}.address.city`
    });

    let statement = database.call("persistent_json_store.get_query_statement", {
        p_query_element_i: elementI,
        p_query_type: VALUE_QUERY
    });

    let cursorId = database.call("persistent_json_store.prepare_query", {
        p_anchor_id: null,
        p_query_element_i: elementI,
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
        persistent_json_store.to_refcursor(${cursorId}) AS "VALUES"
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

    let value = {
        name: "Sergejs",
        address: {
            city: "Riga"
        }
    };

    let valueId = database.call("persistent_json_store.create_json", {
        p_content_parse_events: database.call("json_parser.parse", {
            p_content: JSON.stringify(value)
        })
    });

    let elementI = database.call("json_core.parse_query", {
        p_query: `#id.address.:property`
    });

    let statement = database.call("persistent_json_store.get_query_statement", {
        p_query_element_i: elementI,
        p_query_type: VALUE_QUERY
    });

    let cursorId = database.call("persistent_json_store.prepare_query", {
        p_anchor_id: null,
        p_query_element_i: elementI,
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
        persistent_json_store.to_refcursor(${cursorId}) AS "VALUES"
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

test("Data fetching from an anchored query with bind variables", function() {

    let value = {
        name: "Sergejs",
        address: {
            city: "Riga"
        }
    };

    let valueId = database.call("persistent_json_store.create_json", {
        p_content_parse_events: database.call("json_parser.parse", {
            p_content: JSON.stringify(value)
        })
    });

    let elementI = database.call("json_core.parse_query", {
        p_query: `address.:property`,
        p_anchored: true
    });

    let statement = database.call("persistent_json_store.get_query_statement", {
        p_query_element_i: elementI,
        p_query_type: VALUE_QUERY
    });

    let cursorId = database.call("persistent_json_store.prepare_query", {
        p_anchor_id: valueId,
        p_query_element_i: elementI,
        p_query_statement: statement,
        p_bind: ["city"]
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
        persistent_json_store.to_refcursor(${cursorId}) AS "VALUES"
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

    let value = {
        name: "Sergejs",
        address: {
            city: "Riga"
        }
    }

    let valueId = database.call("persistent_json_store.create_json", {
        p_content_parse_events: database.call("json_parser.parse", {
            p_content: JSON.stringify(value)
        })
    });

    let elementI = database.call("json_core.parse_query", {
        p_query: `#id.address.:property`
    });

    let statement = database.call("persistent_json_store.get_query_statement", {
        p_query_element_i: elementI,
        p_query_type: VALUE_QUERY
    });

    expect(function() {
    
        let cursorId = database.call("persistent_json_store.prepare_query", {
            p_anchor_id: null,
            p_query_element_i: elementI,
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