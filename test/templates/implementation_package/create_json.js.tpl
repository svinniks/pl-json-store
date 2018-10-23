suite("Anonymous value creation", function() {

    function runTest(value) {

        let events = database.call("json_parser.parse", {
            p_content: JSON.stringify(value)
        });
    
        let valueId = database.call(`${implementationPackage}.create_json`, {
            p_content_parse_events: events
        });

        events = database.call(`${implementationPackage}.get_parse_events`, {
            p_value_id: valueId,
            p_serialize_nulls: true
        });

        let storedValue = JSON.parse(database.call("json_core.serialize_value", {
            p_content_parse_events: events,
            p_json: null,
            p_json_clob: null
        }).p_json);

        expect(storedValue).to.eql(value);

    }

    test("Create a string", function() {
    
        runTest("Hello, World!");

    });

    test("Create a number", function() {
    
        runTest(123.456);
    
    });
    
    test("Create a boolean", function() {
    
        runTest(true);
    
    });

    test("Create a null", function() {
    
        runTest(null);

    });

    test("Create an empty object", function() {
    
        runTest({});

    });

    test("Create an empty array", function() {
    
        runTest([]);
    
    });

    test("Create an object with one property", function() {
    
        runTest({
            name: "Sergejs"
        });

    });

    test("Create an object with two properties", function() {
    
        runTest({
            name: "Sergejs",
            surname: "Vinniks"
        });

    });

    test("Create an array with one element", function() {
    
        runTest([
            "Sergejs"
        ]);

    });

    test("Create an array with two elements", function() {
    
        runTest([
            "Sergejs",
            "Vinniks"
        ]);

    });

    test("Create a complex JSON object", function() {
    
        runTest({
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
        });

    });

    test("Create an array with more elements than the record flush limit (200)", function() {
    
        let value = [];

        for (let i = 1; i <= 300; i++) {
            value.push(i);
        }

        runTest(value);

    });

    test("Don't serialize a single NULL", function() {
    
        let valueId = database.call(`${implementationPackage}.create_json`, {
            p_content_parse_events: [
                "E"
            ]
        });

        events = database.call(`${implementationPackage}.get_parse_events`, {
            p_value_id: valueId,
            p_serialize_nulls: false
        });

        expect(events).to.eql([
            "E" 
        ]);
    
    });

    test("Don't serialize a NULL property", function() {
    
        let valueId = database.call(`${implementationPackage}.create_json`, {
            p_content_parse_events: [
                "{",
                "}"
            ]
        });

        let propertyId = database.call(`${implementationPackage}.set_property`, {
            p_anchor_id: valueId,
            p_path: "hello",
            p_bind: null,
            p_content_parse_events: [
                "E"
            ]
        });

        events = database.call(`${implementationPackage}.get_parse_events`, {
            p_value_id: propertyId,
            p_serialize_nulls: false
        });

        expect(events).to.eql([
            "E" 
        ]);
    
    });

    test("Don't serialize NULL properties of an object", function() {
    
        let valueId = database.call(`${implementationPackage}.create_json`, {
            p_content_parse_events: [
                "{",
                ":name",
                "SSergejs",
                ":surname",
                "E",
                ":hello",
                "E",
                "}"
            ]
        });

        events = database.call(`${implementationPackage}.get_parse_events`, {
            p_value_id: valueId,
            p_serialize_nulls: false
        });

        expect(events).to.eql([
            "{",
            ":name",
            "SSergejs",
            "}" 
        ]);
    
    });
    
    test("Don't serialize elements of an array", function() {
    
        let valueId = database.call(`${implementationPackage}.create_json`, {
            p_content_parse_events: [
                "[",
                ":0",
                "SSergejs",
                ":1",
                "E",
                ":2",
                "SHello, World!",
                "]"
            ]
        });

        events = database.call(`${implementationPackage}.get_parse_events`, {
            p_value_id: valueId,
            p_serialize_nulls: false
        });

        expect(events).to.eql([
            "[",
            ":0",
            "SSergejs",
            ":2",
            "SHello, World!",
            "]" 
        ]);
    
    });

    test("Don't serialize elements of an array property", function() {
    
        let valueId = database.call(`${implementationPackage}.create_json`, {
            p_content_parse_events: [
                "{",
                ":array",
                "[",
                ":0",
                "SSergejs",
                ":1",
                "E",
                ":2",
                "SHello, World!",
                "]",
                "}"
            ]
        });

        events = database.call(`${implementationPackage}.get_parse_events`, {
            p_value_id: valueId,
            p_serialize_nulls: false
        });

        expect(events).to.eql([
            "{",
            ":array",
            "[",
            ":0",
            "SSergejs",
            ":2",
            "SHello, World!",
            "]",
            "}" 
        ]);
    
    });

});