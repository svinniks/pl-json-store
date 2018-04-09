suite("STRING_EVENTS", function() {

    test("NULL string", function() {

        let events = database.call("json_core.string_events", {
            p_value: null
        });

        expect(events).to.eql([
            {
                name: "STRING",
                value: null
            }
        ]);

    });

    test("Not NULL string", function() {

        let events = database.call("json_core.string_events", {
            p_value: "Hello, World!"
        });

        expect(events).to.eql([
            {
                name: "STRING",
                value: "Hello, World!"
            }
        ]);

    });

});

suite("NUMBER_EVENTS", function() {

    test("NULL number", function() {

        let events = database.call("json_core.number_events", {
            p_value: null
        });

        expect(events).to.eql([
            {
                name: "NULL",
                value: null
            }
        ]);

    });

    test("Not NULL number", function() {

        let events = database.call("json_core.number_events", {
            p_value: 123.456
        });

        expect(events).to.eql([
            {
                name: "NUMBER",
                value: "123.456"
            }
        ]);

    });

});

suite("BOOLEAN_EVENTS", function() {

    test("NULL boolean", function() {

        let events = database.call("json_core.boolean_events", {
            p_value: null
        });

        expect(events).to.eql([
            {
                name: "NULL",
                value: null
            }
        ]);

    });

    test("Not NULL number", function() {

        let events = database.call("json_core.boolean_events", {
            p_value: true
        });

        expect(events).to.eql([
            {
                name: "BOOLEAN",
                value: "true"
            }
        ]);

    });

});

test("NULL_EVENTS", function() {

    let events = database.call("json_core.null_events");

    expect(events).to.eql([
        {
            name: "NULL",
            value: null
        }
    ]);

});

test("OBJECT_EVENTS", function() {

    let events = database.call("json_core.object_events");

    expect(events).to.eql([
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

test("ARRAY_EVENTS", function() {

    let events = database.call("json_core.array_events");

    expect(events).to.eql([
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

