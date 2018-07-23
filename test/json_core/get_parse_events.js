suite("Retrieving JSON parse events from stored values", function() {
    
    test("String value", function() {
    
        var id = database.call("json_store.create_string", {
            p_value: "Hello, World!"
        });

        var result = database.call("json_core.get_parse_events", {
            p_value_id: id
        });

        expect(result.p_parse_events).to.eql([
            {
                name: "STRING",
                value: "Hello, World!"
            }
        ]);
    
    });

    test("Number value", function() {
    
        var id = database.call("json_store.create_number", {
            p_value: 123
        });

        var result = database.call("json_core.get_parse_events", {
            p_value_id: id
        });

        expect(result.p_parse_events).to.eql([
            {
                name: "NUMBER",
                value: "123"
            }
        ]);
    
    });

    test("Boolean value", function() {
    
        var id = database.call("json_store.create_boolean", {
            p_value: true
        });

        var result = database.call("json_core.get_parse_events", {
            p_value_id: id
        });

        expect(result.p_parse_events).to.eql([
            {
                name: "BOOLEAN",
                value: "true"
            }
        ]);
    
    });

    test("Null value", function() {
    
        var id = database.call("json_store.create_null");

        var result = database.call("json_core.get_parse_events", {
            p_value_id: id
        });

        expect(result.p_parse_events).to.eql([
            {
                name: "NULL",
                value: null
            }
        ]);
    
    });
    
    test("Empty object value", function() {
    
        var id = database.call("json_store.create_object");

        var result = database.call("json_core.get_parse_events", {
            p_value_id: id
        });

        expect(result.p_parse_events).to.eql([
            {
                name: "START_OBJECT",
                value: null
            },
            {
                name: "END_OBJECT",
                value: null
            }
        ]);
    
    });

    test("Empty array value", function() {
    
        var id = database.call("json_store.create_array");

        var result = database.call("json_core.get_parse_events", {
            p_value_id: id
        });

        expect(result.p_parse_events).to.eql([
            {
                name: "START_ARRAY",
                value: null
            },
            {
                name: "END_ARRAY",
                value: null
            }
        ]);
    
    });

    test("Simple object value", function() {
    
        var id = database.call("json_store.create_json", {
            p_content: {
                name: "Sergejs",
                surname: "Vinniks",
                phone: 1234567
            }
        });

        var result = database.call("json_core.get_parse_events", {
            p_value_id: id
        });

        expect(result.p_parse_events).to.eql([
            {
                name: "START_OBJECT",
                value: null
            },
            {
                name: "NAME",
                value: "name"
            },
            {
                name: "STRING",
                value: "Sergejs"
            },
            {
                name: "NAME",
                value: "phone"
            },
            {
                name: "NUMBER",
                value: "1234567"
            },
            {
                name: "NAME",
                value: "surname"
            },
            {
                name: "STRING",
                value: "Vinniks"
            },
            {
                name: "END_OBJECT",
                value: null
            }
        ]);
    
    });

    test("Simple array value", function() {
    
        var id = database.call("json_store.create_json", {
            p_content: [
                123, "Hello", true, null
            ]
        });

        var result = database.call("json_core.get_parse_events", {
            p_value_id: id
        });

        expect(result.p_parse_events).to.eql([
            {
                name: "START_ARRAY",
                value: null
            },
            {
                name: "NUMBER",
                value: "123"
            },
            {
                name: "STRING",
                value: "Hello"
            },
            {
                name: "BOOLEAN",
                value: "true"
            },
            {
                name: "NULL",
                value: null
            },
            {
                name: "END_ARRAY",
                value: null
            }
        ]);
    
    });

});