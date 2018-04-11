suite("Parse event serialization to JSON", function() {

    test("Single string serialization", function() {
    
        let original = JSON.stringify("Hello, World!");

        let events = database.call("json_parser.parse", {
            p_content: original
        }).p_parse_events;
    
        let serialized = database.call("json_core.serialize_value", {
            p_parse_events: events,
            p_json: null,
            p_json_clob: null
        });

        expect(serialized).to.eql({
            p_json: original,
            p_json_clob: null
        });

    });

    test("Single string serialization, escape special characters", function() {
    
        let original = JSON.stringify("Hello,\n World!");

        let events = database.call("json_parser.parse", {
            p_content: original
        }).p_parse_events;
    
        let serialized = database.call("json_core.serialize_value", {
            p_parse_events: events,
            p_json: null,
            p_json_clob: null
        });

        expect(serialized).to.eql({
            p_json: original,
            p_json_clob: null
        });

    });
    
    test("Single number serialization", function() {
    
        let original = JSON.stringify(123.456);

        let events = database.call("json_parser.parse", {
            p_content: original
        }).p_parse_events;
    
        let serialized = database.call("json_core.serialize_value", {
            p_parse_events: events,
            p_json: null,
            p_json_clob: null
        });

        expect(serialized).to.eql({
            p_json: original,
            p_json_clob: null
        });

    });

    test("Single boolean serialization", function() {
    
        let original = JSON.stringify(true);

        let events = database.call("json_parser.parse", {
            p_content: original
        }).p_parse_events;
    
        let serialized = database.call("json_core.serialize_value", {
            p_parse_events: events,
            p_json: null,
            p_json_clob: null
        });

        expect(serialized).to.eql({
            p_json: original,
            p_json_clob: null
        });

    });

    test("Single null serialization", function() {
    
        let original = JSON.stringify(null);

        let events = database.call("json_parser.parse", {
            p_content: original
        }).p_parse_events;
    
        let serialized = database.call("json_core.serialize_value", {
            p_parse_events: events,
            p_json: null,
            p_json_clob: null
        });

        expect(serialized).to.eql({
            p_json: original,
            p_json_clob: null
        });

    });

    test("Empty object serialization", function() {
    
        let original = JSON.stringify({});

        let events = database.call("json_parser.parse", {
            p_content: original
        }).p_parse_events;
    
        let serialized = database.call("json_core.serialize_value", {
            p_parse_events: events,
            p_json: null,
            p_json_clob: null
        });

        expect(serialized).to.eql({
            p_json: original,
            p_json_clob: null
        });

    });

    test("Object with one property serialization", function() {
    
        let original = JSON.stringify({
            name: "Sergejs"
        });

        let events = database.call("json_parser.parse", {
            p_content: original
        }).p_parse_events;
    
        let serialized = database.call("json_core.serialize_value", {
            p_parse_events: events,
            p_json: null,
            p_json_clob: null
        });

        expect(serialized).to.eql({
            p_json: original,
            p_json_clob: null
        });

    });

    test("Object with one property serialization, escaped special characters in the property name", function() {
    
        let original = JSON.stringify({
            "first\nname": "Sergejs"
        });

        let events = database.call("json_parser.parse", {
            p_content: original
        }).p_parse_events;
    
        let serialized = database.call("json_core.serialize_value", {
            p_parse_events: events,
            p_json: null,
            p_json_clob: null
        });

        expect(serialized).to.eql({
            p_json: original,
            p_json_clob: null
        });

    });

    test("Object with multiple properties", function() {
    
        let original = JSON.stringify({
            name: "Sergejs",
            surname: "Vinniks",
            city: "Riga"
        });

        let events = database.call("json_parser.parse", {
            p_content: original
        }).p_parse_events;
    
        let serialized = database.call("json_core.serialize_value", {
            p_parse_events: events,
            p_json: null,
            p_json_clob: null
        });

        expect(serialized).to.eql({
            p_json: original,
            p_json_clob: null
        });

    });

    test("Empty array serialization", function() {
    
        let original = JSON.stringify([]);

        let events = database.call("json_parser.parse", {
            p_content: original
        }).p_parse_events;
    
        let serialized = database.call("json_core.serialize_value", {
            p_parse_events: events,
            p_json: null,
            p_json_clob: null
        });

        expect(serialized).to.eql({
            p_json: original,
            p_json_clob: null
        });

    });

    test("Array with one element serialization", function() {
    
        let original = JSON.stringify(["Hello"]);

        let events = database.call("json_parser.parse", {
            p_content: original
        }).p_parse_events;
    
        let serialized = database.call("json_core.serialize_value", {
            p_parse_events: events,
            p_json: null,
            p_json_clob: null
        });

        expect(serialized).to.eql({
            p_json: original,
            p_json_clob: null
        });

    });

    test("Array with multiple elements serialization", function() {
    
        let original = JSON.stringify(["Hello", "World", 123, true]);

        let events = database.call("json_parser.parse", {
            p_content: original
        }).p_parse_events;
    
        let serialized = database.call("json_core.serialize_value", {
            p_parse_events: events,
            p_json: null,
            p_json_clob: null
        });

        expect(serialized).to.eql({
            p_json: original,
            p_json_clob: null
        });

    });

    test("Complex object serialization", function() {
    
        let original = JSON.stringify({
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
                }
            ],
            married: true
        });

        let events = database.call("json_parser.parse", {
            p_content: original
        }).p_parse_events;
    
        let serialized = database.call("json_core.serialize_value", {
            p_parse_events: events,
            p_json: null,
            p_json_clob: null
        });

        expect(serialized).to.eql({
            p_json: original,
            p_json_clob: null
        });

    });

    test("Complex object serialization into a CLOB", function() {
    
        let original = JSON.stringify({
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
                }
            ],
            married: true
        });

        let events = database.call("json_parser.parse", {
            p_content: original
        }).p_parse_events;
    
        let serialized = database.call("json_core.serialize_value", {
            p_parse_events: events,
            p_json: null,
            p_json_clob: ""
        });

        expect(serialized).to.eql({
            p_json: null,
            p_json_clob: original
        });

    });

});