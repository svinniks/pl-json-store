function createValue(value) {

    let events = database.call("json_parser.parse", {
        p_content: JSON.stringify(value)
    });

    return database.call(`${implementationPackage}.create_json`, {
        p_content_parse_events: events
    });

}

suite("Array scalar value collection retrieval tests", function() {

    test("Try to call the private method directly", function() {
    
        expect(function() {
        
            database.selectValues(`
                    *
                FROM TABLE(${implementationType}(-1).get_raw_values('S'))
            `);
        
        }).to.throw(/JDC-00052/);
    
    });

    test("Try to get strings for an array which contains a non-string", function() {
    
        let valueId = createValue([
            "Hello, World!",
            123.456
        ]);
    
        expect(function() {
        
            database.selectValues(`
                    *
                FROM TABLE(${implementationType}(${valueId}).get_strings())
            `);
        
        }).to.throw(/JDC-00010/);

    });

    test("Get strings", function() {
    
        let valueId = createValue([
            "Hello, World!",
            "Good bye, World!"
        ]);
    
        let values = database.selectValues(`
                *
            FROM TABLE(${implementationType}(${valueId}).get_strings())
        `);
        
        expect(values).to.eql([
            "Hello, World!",
            "Good bye, World!"
        ]);

    });

    test("Try to get numbers for an array which contains a non-number", function() {
    
        let valueId = createValue([
            "Hello, World!",
            123.456
        ]);
    
        expect(function() {
        
            database.selectValues(`
                    *
                FROM TABLE(${implementationType}(${valueId}).get_numbers())
            `);
        
        }).to.throw(/JDC-00010/);

    });

    test("Get numbers", function() {
    
        let valueId = createValue([
            123.456,
            654.321
        ]);
    
        let values = database.selectValues(`
                *
            FROM TABLE(${implementationType}(${valueId}).get_numbers())
        `);
        
        expect(values).to.eql([
            123.456,
            654.321
        ]);

    });

    test("Try to get dates for an array which contains a non-date string", function() {
    
        let valueId = createValue([
            "Hello, World!",
            "1982-08-06"
        ]);
    
        expect(function() {
        
            database.selectValues(`
                    *
                FROM TABLE(${implementationType}(${valueId}).get_dates())
            `);
        
        }).to.throw(/JDC-00010/);

    });

    test("Get dates with nulls", function() {
    
        let valueId = createValue([
            "1982-08-06",
            "1913-01-01",
            null
        ]);
    
        let values = database.selectValues(`
                *
            FROM TABLE(${implementationType}(${valueId}).get_dates())
        `);
        
        expect(values).to.eql([
            "1982-08-06",
            "1913-01-01",
            null
        ]);

    });
    
});