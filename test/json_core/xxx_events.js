suite("STRING_EVENTS", function() {

    test("NULL string", function() {

        let events = database.call("json_core.string_events", {
            p_value: null
        });

        expect(events).to.eql([
            "S"
        ]);

    });

    test("Not NULL string", function() {

        let events = database.call("json_core.string_events", {
            p_value: "Hello, World!"
        });

        expect(events).to.eql([
            "SHello, World!"
        ]);

    });

});

suite("DATE_EVENTS", function() {

    test("NULL date", function() {

        let events = database.call("json_core.date_events", {
            p_value: null
        });

        expect(events).to.eql([
            "E"
        ]);

    });

    test("Not NULL date", function() {

        let events = database.call("json_core.date_events", {
            p_value: "1982-08-06"
        });

        expect(events).to.eql([
            "S1982-08-06"
        ]);

    });

});

suite("NUMBER_EVENTS", function() {

    test("NULL number", function() {

        let events = database.call("json_core.number_events", {
            p_value: null
        });

        expect(events).to.eql([
            "E"
        ]);

    });

    test("Not NULL number", function() {

        let events = database.call("json_core.number_events", {
            p_value: 123.456
        });

        expect(events).to.eql([
            "N123.456"
        ]);

    });

    test("Negative decimal with zero integer part", function() {

        let events = database.call("json_core.number_events", {
            p_value: -0.123
        });

        expect(events).to.eql([
            "N-0.123"
        ]);

    });

});

suite("BOOLEAN_EVENTS", function() {

    test("NULL boolean", function() {

        let events = database.call("json_core.boolean_events", {
            p_value: null
        });

        expect(events).to.eql([
            "E"
        ]);

    });

    test("Not NULL number", function() {

        let events = database.call("json_core.boolean_events", {
            p_value: true
        });

        expect(events).to.eql([
            "Btrue"
        ]);

    });

});

test("NULL_EVENTS", function() {

    let events = database.call("json_core.null_events");

    expect(events).to.eql([
        "E"
    ]);

});

test("OBJECT_EVENTS", function() {

    let events = database.call("json_core.object_events");

    expect(events).to.eql([
        "{",
        "}"
    ]);

});

test("ARRAY_EVENTS", function() {

    let events = database.call("json_core.array_events");

    expect(events).to.eql([
        "[",
        "]"
    ]);

});

