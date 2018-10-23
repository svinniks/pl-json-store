let valueId;

setup("Create a value for testing", function() {

    let value = {
        name: "Sergejs",
        surname: "Vinniks",
        addresses: {
            home: {
                street: "Raunas iela",
                city: "Riga"
            },
            office: {
                city: "Riga"
            }
        }
    };

    valueId = database.call(`${implementationPackage}.create_json`, {
        p_content_parse_events: database.call('json_parser.parse', {
            p_content: JSON.stringify(value)
        }) 
    });

});

suite("Property requests", function() {

    test("Try requesting a property for an invalid path", function() {
    
        expect(function() {
        
            database.call(`${implementationPackage}.request_property`, {
                p_anchor_id: null,
                p_path: `#${valueId}.address.city?`,
                p_bind: null
            });
        
        }).to.throw(/JDC-00036/);
    
    });

    test("Property name missing (less than 2 elements in the query)", function() {
    
        expect(function() {
        
            database.call(`${implementationPackage}.request_property`, {
                p_anchor_id: null,
                p_path: "#123",
                p_bind: null
            });
        
        }).to.throw(/JDC-00041/);
    
    });
    
    test("Invalid property name (not a property name or a name variable)", function() {
    
        expect(function() {
        
            database.call(`${implementationPackage}.request_property`, {
                p_anchor_id: null,
                p_path: "#123.#321",
                p_bind: null
            });
        
        }).to.throw(/JDC-00022/);
    
    });

    test("Request property of a non-existing container", function() {
    
        expect(function() {
        
            database.call(`${implementationPackage}.request_property`, {
                p_anchor_id: null,
                p_path: `#${valueId}.addresses.work.street`,
                p_bind: null
            });
        
        }).to.throw(/JDC-00007/);
    
    });

    test("Request an existing property with a literal name", function() {
    
        let property = database.call(`${implementationPackage}.request_property`, {
            p_anchor_id: null,
            p_path: `#${valueId}.addresses.home.city`,
            p_bind: null
        });

        expect(property).to.eql({
            parent_id: valueId + 4,
            parent_type: "O",
            property_id: valueId + 6,
            property_type: "S",
            property_name: "city",
            property_locked: null
        });
    
    });
    
    test("Request an existing property with a variable name", function() {
    
        let property = database.call(`${implementationPackage}.request_property`, {
            p_anchor_id: null,
            p_path: `#${valueId}.addresses.home.:property`,
            p_bind: ["city"]
        });

        expect(property).to.eql({
            parent_id: valueId + 4,
            parent_type: "O",
            property_id: valueId + 6,
            property_type: "S",
            property_name: "city",
            property_locked: null
        });
    
    });

    test("Request a non-existing property with a literal name", function() {
    
        let property = database.call(`${implementationPackage}.request_property`, {
            p_anchor_id: null,
            p_path: `#${valueId}.addresses.home.house`,
            p_bind: null
        });

        expect(property).to.eql({
            parent_id: valueId + 4,
            parent_type: "O",
            property_id: null,
            property_type: null,
            property_name: "house",
            property_locked: null
        });
    
    });
    
    test("Request an existing property with a variable name", function() {
    
        let property = database.call(`${implementationPackage}.request_property`, {
            p_anchor_id: null,
            p_path: `#${valueId}.addresses.home.:property`,
            p_bind: ["house"]
        });

        expect(property).to.eql({
            parent_id: valueId + 4,
            parent_type: "O",
            property_id: null,
            property_type: null,
            property_name: "house",
            property_locked: null
        });
    
    });
    
    test("Request property of a non-existing parent", function() {
    
        expect(function() {
        
            database.call(`${implementationPackage}.request_property`, {
                p_anchor_id: -1,
                p_path: `addresses.work.street`,
                p_bind: null
            });
        
        }).to.throw(/JDC-00007/);
    
    });

    test("Request child property of a non-existing container", function() {
    
        expect(function() {
        
            database.call(`${implementationPackage}.request_property`, {
                p_anchor_id: valueId,
                p_path: `addresses.work.street`,
                p_bind: null
            });
        
        }).to.throw(/JDC-00007/);
    
    });

    test("Request an existing child property with a variable name", function() {
    
        let property = database.call(`${implementationPackage}.request_property`, {
            p_anchor_id: valueId,
            p_path: `addresses.home.:property`,
            p_bind: ["city"]
        });

        expect(property).to.eql({
            parent_id: valueId + 4,
            parent_type: "O",
            property_id: valueId + 6,
            property_type: "S",
            property_name: "city",
            property_locked: null
        });
    
    });

});

