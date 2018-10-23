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
        },
        phones: [
            "123456789", 
            "987654321"
        ]
    };

    valueId = database.call(`${implementationPackage}.create_json`, {
        p_content_parse_events: database.call('json_parser.parse', {
            p_content: JSON.stringify(value)
        }) 
    });

});

suite("Value requests", function() {

    test("Try requesting a value with an invalid path", function() {
    
        expect(function() {
        
            database.call(`${implementationPackage}.request_value`, {
                p_anchor_id: null,
                p_path: `#${valueId}.address.name?`,
                p_bind: null
            });
        
        }).to.throw(/JDC-00036/);
    
    });
    

    test("Request a non-existing value, return NULL", function() {
    
        let id = database.call(`${implementationPackage}.request_value`, {
            p_anchor_id: null,
            p_path: `#${valueId}.job`,
            p_bind: null
        });

        expect(id).to.be(null);
    
    });
    
    test("Request a non-existing value, raise an exception", function() {
    
        expect(function() {
        
            database.call(`${implementationPackage}.request_value`, {
                p_anchor_id: null,
                p_path: `#${valueId}.job`,
                p_bind: null, 
                p_raise_not_found: true
            });
        
        }).to.throw(/JDC-00009/);

    });

    test("Request a value without bind variables", function() {
    
        let id = database.call(`${implementationPackage}.request_value`, {
            p_anchor_id: null,
            p_path: `#${valueId}.addresses.home.city`,
            p_bind: null
        });

        expect(id).to.be(valueId + 6);
    
    });

    test("Request a value with bind variables", function() {
    
        let id = database.call(`${implementationPackage}.request_value`, {
            p_anchor_id: null,
            p_path: `#id.addresses.home.:property`,
            p_bind: [valueId, "city"]
        });

        expect(id).to.be(valueId + 6);
    
    });

    test("Request value of a non-existing parent", function() {
    
        expect(function() {
        
            database.call(`${implementationPackage}.request_value`, {
                p_anchor_id: -1,
                p_path: "addresses.home.house",
                p_bind: null,
                p_raise_not_found: true
            });
        
        }).to.throw(/JDC-00009/);

    });

    test("Request non-existing child value, return NULL", function() {
    
        let id = database.call(`${implementationPackage}.request_value`, {
            p_anchor_id: null,
            p_anchor_id: valueId,
            p_path: "addresses.home.house",
            p_bind: null
        });
        
        expect(id).to.be(null);

    });

    test("Request non-existing child value, raise an exception", function() {
    
        expect(function() {
        
            database.call(`${implementationPackage}.request_value`, {
                p_anchor_id: valueId,
                p_path: "addresses.home.house",
                p_bind: null,
                p_raise_not_found: true
            });
        
        }).to.throw(/JDC-00009/);

    });

    test("Request child value without bind variables", function() {
    
        let id = database.call(`${implementationPackage}.request_value`, {
            p_anchor_id: valueId,
            p_path: "addresses.home.city",
            p_bind: null
        });
    
        expect(id).to.be(valueId + 6);

    });

    test("Request child value with bind variables", function() {
    
        let id = database.call(`${implementationPackage}.request_value`, {
            p_anchor_id: valueId,
            p_path: ":property1.home.:property2",
            p_bind: ["addresses", "city"]
        });
    
        expect(id).to.be(valueId + 6);

    });
            
    test("Request child value with a branching root in the path", function() {
    
        let id = database.call(`${implementationPackage}.request_value`, {
            p_anchor_id: valueId,
            p_path: "(addresses.home.city)",
            p_bind: null
        });
    
        expect(id).to.be(valueId + 6);

    });

    test("Request existing array element", function() {
    
        let id = database.call(`${implementationPackage}.request_value`, {
            p_anchor_id: valueId,
            p_path: "phones[1]",
            p_bind: null
        });
    
        expect(id).to.be(valueId + 11);

    });

    test("Request non-existing array element", function() {
    
        let id = database.call(`${implementationPackage}.request_value`, {
            p_anchor_id: valueId,
            p_path: "phones[2]",
            p_bind: null
        });
    
        expect(id).to.be(null);

    });

});