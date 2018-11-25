function createValue(value) {

    let events = database.call("json_parser.parse", {
        p_content: JSON.stringify(value)
    });

    return database.call(`${implementationPackage}.create_json`, {
        p_content_parse_events: events
    });

}

suite("GET_RAW_VALUES tests", function() {

    test("Try to get raw values for a NULL ID value", function() {
    
        expect(function() {
        
            database.call(`${implementationPackage}.get_raw_values`, {
                p_array_id: null,
                p_type: "S"
            });
        
        }).to.throw(/JDC-00031/);
    
    });
    
    test("Try to get raw values for a non-existing value", function() {
    
        expect(function() {
        
            database.call(`${implementationPackage}.get_raw_values`, {
                p_array_id: -1,
                p_type: "S"
            });
        
        }).to.throw(/JDC-00009/);
    
    });

    test("Try to get raw values for a value which is not an array", function() {
    
        let valueId = createValue("Hello, World!");

        expect(function() {
        
            database.call(`${implementationPackage}.get_raw_values`, {
                p_array_id: valueId,
                p_type: "S"
            });
        
        }).to.throw(/JDC-00012/);
    
    });

    test("Get raw string values of an empty array", function() {
    
        let valueId = createValue([]);

        let values = database.call(`${implementationPackage}.get_raw_values`, {
            p_array_id: valueId,
            p_type: "S"
        });
    
        expect(values).to.eql([]);

    });
    
    test("Get raw string values of an array with multiple strings", function() {
    
        let valueId = createValue([
            "Hello, World!",
            "Good bye, World!",
            "Sveiki, Pasaule!"
        ]);

        let values = database.call(`${implementationPackage}.get_raw_values`, {
            p_array_id: valueId,
            p_type: "S"
        });
    
        expect(values).to.eql([
            "Hello, World!",
            "Good bye, World!",
            "Sveiki, Pasaule!"
        ]);

    });

    test("Get raw string values of an array with multiple strings and nulls", function() {
    
        let valueId = createValue([
            "Hello, World!",
            null,
            "Good bye, World!",
            "Sveiki, Pasaule!",
            null
        ]);

        let values = database.call(`${implementationPackage}.get_raw_values`, {
            p_array_id: valueId,
            p_type: "S"
        });
    
        expect(values).to.eql([
            "Hello, World!",
            null,
            "Good bye, World!",
            "Sveiki, Pasaule!",
            null
        ]);

    });

    test("Get raw string values of a sparse array", function() {
    
        let valueId = createValue([]);

        database.run(`
            DECLARE
                v_dummy NUMBER;
            BEGIN
                v_dummy := ${implementationPackage}.set_property(${valueId}, '[2]', NULL, t_varchars('SHello, World!'));
                v_dummy := ${implementationPackage}.set_property(${valueId}, '[5]', NULL, t_varchars('SGood bye, World!'));
            END;
        `);

        let values = database.call(`${implementationPackage}.get_raw_values`, {
            p_array_id: valueId,
            p_type: "S"
        });
    
        expect(values).to.eql([
            null,
            null,
            "Hello, World!",
            null,
            null,
            "Good bye, World!"
        ]);

    });

    test("Try to get raw string values for an array containing a non-string", function() {
    
        let valueId = createValue([
            "Hello, World!",
            123.456
        ]);

        expect(function() {
        
            database.call(`${implementationPackage}.get_raw_values`, {
                p_array_id: valueId,
                p_type: "S"
            });            
        
        }).to.throw(/JDC-00010/);

    });

});