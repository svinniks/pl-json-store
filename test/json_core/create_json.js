suite("Anonymous value creation", function() {

    test("Create a string", function() {
    
        let valueId = database.call("json_core.create_json", {
            p_content_parse_events: [
                {
                    name: "STRING",
                    value: "Hello, World!"
                }
            ]
        });

        let value = database.selectObject(`
                 *
            FROM json_values
            WHERE id = ${valueId}
        `);

        expect(value).to.eql({
            id: valueId,
            parent_id: null,
            type: "S",
            name: null, 
            value: "Hello, World!",
            locked: null
        });
    
    });

    test("Create a number", function() {
    
        let valueId = database.call("json_core.create_json", {
            p_content_parse_events: [
                {
                    name: "NUMBER",
                    value: "123.456"
                }
            ]
        });

        let value = database.selectObject(`
                 *
            FROM json_values
            WHERE id = ${valueId}
        `);

        expect(value).to.eql({
            id: valueId,
            parent_id: null,
            type: "N",
            name: null, 
            value: 123.456,
            locked: null
        });
    
    });
    
    test("Create a boolean", function() {
    
        let valueId = database.call("json_core.create_json", {
            p_content_parse_events: [
                {
                    name: "BOOLEAN",
                    value: "true"
                }
            ]
        });

        let value = database.selectObject(`
                 *
            FROM json_values
            WHERE id = ${valueId}
        `);

        expect(value).to.eql({
            id: valueId,
            parent_id: null,
            type: "B",
            name: null, 
            value: "true",
            locked: null
        });
    
    });

    test("Create a null", function() {
    
        let valueId = database.call("json_core.create_json", {
            p_content_parse_events: [
                {
                    name: "NULL",
                    value: null
                }
            ]
        });

        let value = database.selectObject(`
                 *
            FROM json_values
            WHERE id = ${valueId}
        `);

        expect(value).to.eql({
            id: valueId,
            parent_id: null,
            type: "E",
            name: null, 
            value: null,
            locked: null
        });
    
    });

    test("Create an empty object", function() {
    
        let valueId = database.call("json_core.create_json", {
            p_content_parse_events: [
                {
                    name: "START_OBJECT",
                    value: null
                },
                {
                    name: "END_OBJECT",
                    value: null
                }
            ]
        });

        let value = database.selectObject(`
                 *
            FROM json_values
            WHERE id = ${valueId}
        `);

        expect(value).to.eql({
            id: valueId,
            parent_id: null,
            type: "O",
            name: null, 
            value: null,
            locked: null
        });
    
    });

    test("Create an empty array", function() {
    
        let valueId = database.call("json_core.create_json", {
            p_content_parse_events: [
                {
                    name: "START_ARRAY",
                    value: null
                },
                {
                    name: "END_ARRAY",
                    value: null
                }
            ]
        });

        let value = database.selectObject(`
                 *
            FROM json_values
            WHERE id = ${valueId}
        `);

        expect(value).to.eql({
            id: valueId,
            parent_id: null,
            type: "A",
            name: null, 
            value: null,
            locked: null
        });
    
    });

    test("Create an object with one property", function() {
    
        let value = {
            name: "Sergejs"
        };

        let events = database.call("json_parser.parse", {
            p_content: JSON.stringify(value)
        }).p_parse_events;
    
        let valueId = database.call("json_core.create_json", {
            p_content_parse_events: events
        });

        let retrieved = database.call("json_core.get_parse_events", {
            p_value_id: valueId
        }).p_parse_events;

        expect(events).to.eql(retrieved);

    });

    test("Create an object with two properties", function() {
    
        let value = {
            name: "Sergejs",
            surname: "Vinniks"
        };

        let events = database.call("json_parser.parse", {
            p_content: JSON.stringify(value)
        }).p_parse_events;
    
        let valueId = database.call("json_core.create_json", {
            p_content_parse_events: events
        });

        let retrieved = database.call("json_core.get_parse_events", {
            p_value_id: valueId
        }).p_parse_events;

        expect(events).to.eql(retrieved);

    });

    test("Create an array with one element", function() {
    
        let value = [
            "Sergejs"
        ];

        let events = database.call("json_parser.parse", {
            p_content: JSON.stringify(value)
        }).p_parse_events;
    
        let valueId = database.call("json_core.create_json", {
            p_content_parse_events: events
        });

        let retrieved = database.call("json_core.get_parse_events", {
            p_value_id: valueId
        }).p_parse_events;

        expect(events).to.eql(retrieved);

    });

    test("Create an array with two elements", function() {
    
        let value = [
            "Sergejs",
            "Vinniks"
        ];

        let events = database.call("json_parser.parse", {
            p_content: JSON.stringify(value)
        }).p_parse_events;
    
        let valueId = database.call("json_core.create_json", {
            p_content_parse_events: events
        });

        let retrieved = database.call("json_core.get_parse_events", {
            p_value_id: valueId
        }).p_parse_events;

        expect(events).to.eql(retrieved);

    });

    test("Create a complex JSON object", function() {
    
        let value = {
            name: "Sergejs",
            surname: "Vinniks",
            addresses: {
                home: {
                    street: "Raunas iela",
                    city: "Riga"
                }
            },
            phones: [
                {
                    type: "mobile",
                    number: "1234567"
                },
                {
                    type: "fixed",
                    number: "7654321"
                }
            ],
            married: true
        };

        let events = database.call("json_parser.parse", {
            p_content: JSON.stringify(value)
        }).p_parse_events;
    
        let valueId = database.call("json_core.create_json", {
            p_content_parse_events: events
        });

        let retrieved = database.call("json_core.get_parse_events", {
            p_value_id: valueId
        }).p_parse_events;

        expect(retrieved).to.eql([
            {
                name: "START_OBJECT",
                value: null
            },
            {
                "name": "NAME",
                "value": "addresses"
            },
            {
                "name": "START_OBJECT",
                value: null
            },
            {
                "name": "NAME",
                "value": "home"
            },
            {
                "name": "START_OBJECT",
                value: null
            },
            {
                "name": "NAME",
                "value": "city"
            },
            {
                "name": "STRING",
                "value": "Riga"
            },
            {
                "name": "NAME",
                "value": "street"
            },
            {
                "name": "STRING",
                "value": "Raunas iela"
            },
            {
                "name": "END_OBJECT",
                value: null
            },
            {
                "name": "END_OBJECT",
                value: null
            },
            {
                "name": "NAME",
                "value": "married"
            },
            {
                "name": "BOOLEAN",
                "value": "true"
            },
            {
                "name": "NAME",
                "value": "name"
            },
            {
                "name": "STRING",
                "value": "Sergejs"
            },
            {
                "name": "NAME",
                "value": "phones"
            },
            {
                "name": "START_ARRAY",
                value: null
            },
            {
                "name": "START_OBJECT",
                value: null
            },
            {
                "name": "NAME",
                "value": "number"
            },
            {
                "name": "STRING",
                "value": "1234567"
            },
            {
                "name": "NAME",
                "value": "type"
            },
            {
                "name": "STRING",
                "value": "mobile"
            },
            {
                "name": "END_OBJECT",
                value: null
            },
            {
                "name": "START_OBJECT",
                value: null
            },
            {
                "name": "NAME",
                "value": "number"
            },
            {
                "name": "STRING",
                "value": "7654321"
            },
            {
                "name": "NAME",
                "value": "type"
            },
            {
                "name": "STRING",
                "value": "fixed"
            },
            {
                "name": "END_OBJECT",
                value: null
            },
            {
                "name": "END_ARRAY",
                value: null
            },
            {
                "name": "NAME",
                "value": "surname"
            },
            {
                "name": "STRING",
                "value": "Vinniks"
            },
            {
                "name": "END_OBJECT",
                value: null
            }
        ]);

    });

    test("Create an array with more elements than the record flush limit (200)", function() {
    
        let value = [];

        for (let i = 1; i <= 300; i++) {
            value.push(i);
        }

        let events = database.call("json_parser.parse", {
            p_content: JSON.stringify(value)
        }).p_parse_events;
    
        let valueId = database.call("json_core.create_json", {
            p_content_parse_events: events
        });

        let retrieved = database.call("json_core.get_parse_events", {
            p_value_id: valueId
        }).p_parse_events;

        expect(events).to.eql(retrieved);

    });

});