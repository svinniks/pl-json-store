suite("Parse event serialization to JSON", function() {

    test("Single string serialization", function() {
    
        let original = JSON.stringify("Hello, World!");

        let events = database.call("json_parser.parse", {
            p_content: original
        });
    
        let serialized = database.call("json_core.serialize_value", {
            p_content_parse_events: events,
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
        });
    
        let serialized = database.call("json_core.serialize_value", {
            p_content_parse_events: events,
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
        });
    
        let serialized = database.call("json_core.serialize_value", {
            p_content_parse_events: events,
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
        });
    
        let serialized = database.call("json_core.serialize_value", {
            p_content_parse_events: events,
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
        });
    
        let serialized = database.call("json_core.serialize_value", {
            p_content_parse_events: events,
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
        });
    
        let serialized = database.call("json_core.serialize_value", {
            p_content_parse_events: events,
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
        });
    
        let serialized = database.call("json_core.serialize_value", {
            p_content_parse_events: events,
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
        });
    
        let serialized = database.call("json_core.serialize_value", {
            p_content_parse_events: events,
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
        });
    
        let serialized = database.call("json_core.serialize_value", {
            p_content_parse_events: events,
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
        });
    
        let serialized = database.call("json_core.serialize_value", {
            p_content_parse_events: events,
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
        });
    
        let serialized = database.call("json_core.serialize_value", {
            p_content_parse_events: events,
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
        });
    
        let serialized = database.call("json_core.serialize_value", {
            p_content_parse_events: events,
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
        });
    
        let serialized = database.call("json_core.serialize_value", {
            p_content_parse_events: events,
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
        });
    
        let serialized = database.call("json_core.serialize_value", {
            p_content_parse_events: events,
            p_json: null,
            p_json_clob: ""
        });

        expect(serialized).to.eql({
            p_json: null,
            p_json_clob: original
        });

    });

    test("Array with nulls", function() {
    
        let original = JSON.stringify([
            null,
            "Hello, World!",
            null,
            123.456,
            null
        ]);

        let events = database.call("json_parser.parse", {
            p_content: original
        });
    
        let serialized = database.call("json_core.serialize_value", {
            p_content_parse_events: events,
            p_json: null,
            p_json_clob: ""
        });

        expect(serialized).to.eql({
            p_json: null,
            p_json_clob: original
        });
    
    });
    
    test("Array with missing elements in the beginning", function() {
    
        let serialized = database.call("json_core.serialize_value", {
            p_content_parse_events: [
                "[",
                ":3",
                "SHello, World!",
                ":4",
                "N123",
                "]",
            ],
            p_json: null,
            p_json_clob: ""
        });

        expect(serialized).to.eql({
            p_json: null,
            p_json_clob: "[null,null,null,\"Hello, World!\",123]"
        });
    
    });

    test("Array with missing elements in the middle", function() {
    
        let serialized = database.call("json_core.serialize_value", {
            p_content_parse_events: [
                "[",
                ":0",
                "SHello, World!",
                ":1",
                "N123",
                ":4",
                "SGood bye, World!",
                "]",
            ],
            p_json: null,
            p_json_clob: ""
        });

        expect(serialized).to.eql({
            p_json: null,
            p_json_clob: "[\"Hello, World!\",123,null,null,\"Good bye, World!\"]"
        });
    
    });

    test("Array with multiple element gaps", function() {
    
        let serialized = database.call("json_core.serialize_value", {
            p_content_parse_events: [
                "[",
                ":2",
                "N2",
                ":3",
                "N3",
                ":6",
                "N6",
                ":10",
                "N10",
                ":11",
                "N11",
                "]",
            ],
            p_json: null,
            p_json_clob: ""
        });

        expect(serialized).to.eql({
            p_json: null,
            p_json_clob: "[null,null,2,3,null,null,6,null,null,null,10,11]"
        });
    
    });

});