function createValue(value) {

    let events = database.call("json_parser.parse", {
        p_content: JSON.stringify(value)
    });

    return database.call(`${implementationPackage}.create_json`, {
        p_content_parse_events: events
    });

}

suite("Value and property deletion tests", function() {

    test("Remove a non-existing property", function() {
    
        let valueId = createValue({
            name: "Sergejs"
        });

        database.run(`
            BEGIN
                ${implementationType}(${valueId}).remove('surname');
            END;
        `);

        let events = database.call(`${implementationPackage}.get_parse_events`, {
            p_value_id: valueId,
            p_serialize_nulls: true
        });

        expect(events).to.eql([
            "{",
            ":name",
            "SSergejs",
            "}"
        ]);
    
    });
    
    test("Remove a property, no bind", function() {
    
        let valueId = createValue({
            name: "Sergejs",
            surname: "Vinniks"
        });

        database.run(`
            BEGIN
                ${implementationType}(${valueId}).remove('surname');
            END;
        `);

        let events = database.call(`${implementationPackage}.get_parse_events`, {
            p_value_id: valueId,
            p_serialize_nulls: true
        });

        expect(events).to.eql([
            "{",
            ":name",
            "SSergejs",
            "}"
        ]);
    
    });

    test("Remove a property, bind", function() {
    
        let valueId = createValue({
            name: "Sergejs",
            surname: "Vinniks"
        });

        database.run(`
            BEGIN
                ${implementationType}(${valueId}).remove(':name', bind('surname'));
            END;
        `);

        let events = database.call(`${implementationPackage}.get_parse_events`, {
            p_value_id: valueId,
            p_serialize_nulls: true
        });

        expect(events).to.eql([
            "{",
            ":name",
            "SSergejs",
            "}"
        ]);
    
    });

    test("Remove an array element", function() {
    
        let valueId = createValue([
            "Sergejs",
            "Vinniks"
        ]);

        database.run(`
            BEGIN
                ${implementationType}(${valueId}).remove(1);
            END;
        `);

        let events = database.call(`${implementationPackage}.get_parse_events`, {
            p_value_id: valueId,
            p_serialize_nulls: true
        });

        expect(events).to.eql([
            "[",
            ":0",
            "SSergejs",
            "]"
        ]);
    
    });

});