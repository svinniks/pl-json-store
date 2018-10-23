suite("Named property creation", function() {

    function createTestObject(value) {
        return database.call(`${implementationPackage}.create_json`, {
            p_content_parse_events: database.call("json_parser.parse", {
                p_content: JSON.stringify(value)
            })
        });
    }

    test("Try setting property of a non-existing container", function() {
    
        let valueId = createTestObject({});

        expect(function() {
        
            database.call(`${implementationPackage}.set_property`, {
                p_anchor_id: null,
                p_path: `#${valueId}.address.city`,
                p_bind: null,
                p_content_parse_events: [
                    "E"
                ]
            });
        
        }).to.throw(/JDC-00007/);
    
    });
    
    test("Try setting property of a non-existing container, use bind variables", function() {
    
        let valueId = createTestObject({});

        expect(function() {
        
            database.call(`${implementationPackage}.set_property`, {
                p_anchor_id: null,
                p_path: `#id.address.city`,
                p_bind: [valueId],
                p_content_parse_events: [
                    "E"
                ]
            });
        
        }).to.throw(/JDC-00007/);
    
    });

    
    test("Try modifying a locked property", function() {
    
        let valueId = createTestObject({
            name: "Sergejs"
        });

        database.call(`${implementationPackage}.pin_value`, {
            p_id: valueId,
            p_pin_tree: true
        });

        expect(function() {
        
            database.call(`${implementationPackage}.set_property`, {
                p_anchor_id: null, 
                p_path: `#${valueId}.name`,
                p_bind: null,
                p_content_parse_events: [
                    "E"
                ]
            });
        
        }).to.throw(/JDC-00024/);
        
    });
    
    test("Try modifying property of a string", function() {
    
        let valueId = createTestObject({
            property: "Hello, World!"
        });
    
        expect(function() {
        
            database.call(`${implementationPackage}.set_property`, {
                p_anchor_id: null,
                p_path: `#${valueId}.property.property`,
                p_bind: null,
                p_content_parse_events: [
                    "E"
                ]
            });
        
        }).to.throw(/JDC-00008/);
    
    });

    test("Try modifying property of a number", function() {
    
        let valueId = createTestObject({
            property: 123.456
        });

        expect(function() {
        
            database.call(`${implementationPackage}.set_property`, {
                p_anchor_id: null,
                p_path: `#${valueId}.property.property`,
                p_bind: null,
                p_content_parse_events: [
                    "E"
                ]
            });
        
        }).to.throw(/JDC-00008/);
    
    });

    test("Try modifying property of a boolean", function() {
    
        let valueId = createTestObject({
            property: true
        });

        expect(function() {
        
            database.call(`${implementationPackage}.set_property`, {
                p_anchor_id: null, 
                p_path: `#${valueId}.property.property`,
                p_bind: null,
                p_content_parse_events: [
                    "E"
                ]
            });
        
        }).to.throw(/JDC-00008/);
    
    });

    test("Try modifying property of a null", function() {
    
        let valueId = createTestObject({
            property: null
        });

        expect(function() {
        
            database.call(`${implementationPackage}.set_property`, {
                p_anchor_id: null,
                p_path: `#${valueId}.property.property`,
                p_bind: null,
                p_content_parse_events: [
                    "E"
                ]
            });
        
        }).to.throw(/JDC-00008/);
    
    });

    test("Set non-existing property of an object", function() {
    
        let valueId = createTestObject({});

        database.call(`${implementationPackage}.set_property`, {
            p_anchor_id: null,
            p_path: `#${valueId}.property`,
            p_bind: null,
            p_content_parse_events: [
                "SHello, World!"
            ]
        });

        let events = database.call(`${implementationPackage}.get_parse_events`, {
            p_value_id: valueId,
            p_serialize_nulls: true
        });

        expect(events).to.eql([
            "{",
            ":property",
            "SHello, World!",
            "}"
        ]);
        
    });

    test("Modify existing property of an object", function() {
    
        let valueId = createTestObject({
            property: "Sveiki, Pasaule!"
        });
        
        database.call(`${implementationPackage}.set_property`, {
            p_anchor_id: null, 
            p_path: `#${valueId}.property`,
            p_bind: null,
            p_content_parse_events: [
                "SHello, World!"
            ]
        });

        let events = database.call(`${implementationPackage}.get_parse_events`, {
            p_value_id: valueId,
            p_serialize_nulls: true
        });

        expect(events).to.eql([
            "{",
            ":property",
            "SHello, World!",
            "}"
        ]);
        
    });

    test("Try setting array element with an invalid index", function() {
    
        let valueId = createTestObject([]);

        expect(function() {
            
            let propertyId = database.call(`${implementationPackage}.set_property`, {
                p_anchor_id: null,
                p_path: `#${valueId}["-1"]`,
                p_bind: null,
                p_content_parse_events: [
                    "S"
                ]
            });        
        
        }).to.throw(/JDC-00013/);
    
    });
    
    test("Modify existing element of an array", function() {
    
        let valueId = createTestObject([1, 2, 3, 4, 5]);

        let propertyId = database.call(`${implementationPackage}.set_property`, {
            p_anchor_id: null, 
            p_path: `#${valueId}[2]`,
            p_bind: null,
            p_content_parse_events: [
                "SHello, World!"
            ]
        });
        
        let events = database.call(`${implementationPackage}.get_parse_events`, {
            p_value_id: valueId,
            p_serialize_nulls: true
        });

        expect(events).to.eql([
            "[",
            ":0",
            "N1",
            ":1",
            "N2",
            ":2",
            "SHello, World!",
            ":3",
            "N4",
            ":4",
            "N5",
            "]"
        ]);
        
    });

    test("Add element to the end of an array", function() {
    
        let valueId = createTestObject([1, 2, 3, 4, 5]);

        let propertyId = database.call(`${implementationPackage}.set_property`, {
            p_anchor_id: null, 
            p_path: `#${valueId}[5]`,
            p_bind: null,
            p_content_parse_events: [
                "N6"
            ]
        });
        
        let events = database.call(`${implementationPackage}.get_parse_events`, {
            p_value_id: valueId,
            p_serialize_nulls: true
        });

        expect(events).to.eql([
            "[",
            ":0",
            "N1",
            ":1",
            "N2",
            ":2",
            "N3",
            ":3",
            "N4",
            ":4",
            "N5",
            ":5",
            "N6",
            "]"
        ]);
        
    });

    test("Add element further than the end of an array", function() {
    
        let valueId = createTestObject([1, 2, 3, 4, 5]);

        let propertyId = database.call(`${implementationPackage}.set_property`, {
            p_anchor_id: null, 
            p_path: `#${valueId}[8]`,
            p_bind: null,
            p_content_parse_events: [
                "N9"
            ]
        });
        
        let events = database.call(`${implementationPackage}.get_parse_events`, {
            p_value_id: valueId,
            p_serialize_nulls: true
        });

        expect(events).to.eql([
            "[",
            ":0",
            "N1",
            ":1",
            "N2",
            ":2",
            "N3",
            ":3",
            "N4",
            ":4",
            "N5",
            ":8",
            "N9",
            "]"
        ]);

    });

    test("Modify existing property of an object, use the anchored path version.", function() {
    
        let valueId = createTestObject({
            property: "Sveiki, Pasaule!"
        });

        database.call(`${implementationPackage}.set_property`, {
            p_anchor_id: valueId,
            p_path: `property`,
            p_bind: null,
            p_content_parse_events: [
                "SHello, World!"
            ]
        });

        let events = database.call(`${implementationPackage}.get_parse_events`, {
            p_value_id: valueId,
            p_serialize_nulls: true
        });

        expect(events).to.eql([
            "{",
            ":property",
            "SHello, World!",
            "}"
        ]);
        
    });

});