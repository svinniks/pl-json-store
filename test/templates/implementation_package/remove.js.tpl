function createValue(value) {

    let events = database.call("json_parser.parse", {
        p_content: JSON.stringify(value)
    });

    return database.call(`${implementationPackage}.create_json`, {
        p_content_parse_events: events
    });

}

suite("JSON value deletion tests", function() {

    test("Try to delete non-existing value", function() {
    
        expect(function() {
        
            database.run(`
                BEGIN
                    ${implementationPackage}.delete_value(-1);    
                END;
            `);
        
        }).to.throw(/JDC-00009/);
    
    });
    
    test("Try to delete root", function() {
    
        let rootId = database.call(`${implementationPackage}.request_value`, {
            p_anchor_id: null,
            p_path: "$",
            p_bind: null
        });

        expect(function() {
        
            database.run(`
                BEGIN
                    ${implementationPackage}.delete_value(${rootId});    
                END;
            `);
        
        }).to.throw(/JDC-00035/);
    
    });

    test("Try to delete a pinned value", function() {
    
        let valueId = createValue("Hello, World!");

        database.call(`${implementationPackage}.pin_value`, {
            p_id: valueId,
            p_pin_tree: false    
        });

        expect(function() {
        
            database.run(`
                BEGIN
                    ${implementationPackage}.delete_value(${valueId});    
                END;
            `);
        
        }).to.throw(/JDC-00024/);
    
    });

    test("Delete a scalar value", function() {
    
        let valueId = createValue("Hello, World!");

        database.run(`
            BEGIN
                ${implementationPackage}.delete_value(${valueId});    
            END;
        `);

        expect(function() {
        
            database.call(`${implementationPackage}.get_value`, {
                p_id: valueId
            });
        
        }).to.throw(/JDC-00009/);
    
    });

    test("Delete object with properties", function() {
    
        let valueId = createValue({
            name: "Sergejs"
        });

        let propertyId = database.call(`${implementationPackage}.set_property`, {
            p_anchor_id: valueId,
            p_path: "surname",
            p_bind: null,
            p_content_parse_events: [
                "SVinniks"
            ]
        });

        database.run(`
            BEGIN
                ${implementationPackage}.delete_value(${valueId});    
            END;
        `);

        expect(function() {
        
            database.call(`${implementationPackage}.get_value`, {
                p_id: valueId
            });
        
        }).to.throw(/JDC-00009/);

        expect(function() {
        
            database.call(`${implementationPackage}.get_value`, {
                p_id: propertyId
            });
        
        }).to.throw(/JDC-00009/);
    
    });

    test("Delete property of an object", function() {
    
        let valueId = createValue({
            name: "Sergejs"
        });

        let propertyId = database.call(`${implementationPackage}.set_property`, {
            p_anchor_id: valueId,
            p_path: "surname",
            p_bind: null,
            p_content_parse_events: [
                "SVinniks"
            ]
        });

        database.run(`
            BEGIN
                ${implementationPackage}.delete_value(${propertyId});    
            END;
        `);

        expect(function() {
        
            database.call(`${implementationPackage}.get_value`, {
                p_id: propertyId
            });
        
        }).to.throw(/JDC-00009/);
    
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

    test("Delete element of an array", function() {
    
        let valueId = createValue([
            "Sergejs"
        ]);

        let propertyId = database.call(`${implementationPackage}.set_property`, {
            p_anchor_id: valueId,
            p_path: "[1]",
            p_bind: null,
            p_content_parse_events: [
                "SVinniks"
            ]
        });

        database.run(`
            BEGIN
                ${implementationPackage}.delete_value(${propertyId});    
            END;
        `);

        expect(function() {
        
            database.call(`${implementationPackage}.get_value`, {
                p_id: propertyId
            });
        
        }).to.throw(/JDC-00009/);
    
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