let valueId;

setup("Create a value for testing", function() {

    valueId = database.call("json_store.create_json", {
        p_content: {
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
        }
    });

});

suite("Value requests", function() {

    test("Try requesting a value with an invalid path", function() {
    
        expect(function() {
        
            database.call("json_core.request_value", {
                p_path: `#${valueId}.address.name?`,
                p_bind: null
            });
        
        }).to.throw(/JDOC-00036/);
    
    });
    

    test("Request a non-existing value, return NULL", function() {
    
        let id = database.call("json_core.request_value", {
            p_path: `#${valueId}.job`,
            p_bind: null
        });

        expect(id).to.be(null);
    
    });
    
    test("Request a non-existing value, raise an exception", function() {
    
        expect(function() {
        
            database.call("json_core.request_value", {
                p_path: `#${valueId}.job`,
                p_bind: null, 
                p_raise_not_found: true
            });
        
        }).to.throw(/JDOC-00009/);

    });

    test("Request an ambiguous value", function() {
    
        expect(function() {
        
            database.call("json_core.request_value", {
                p_path: `#${valueId}.*`,
                p_bind: null, 
                p_raise_not_found: true
            });
        
        }).to.throw(/JDOC-00004/);

    });

    test("Request a value without bind variables", function() {
    
        let id = database.call("json_core.request_value", {
            p_path: `#${valueId}.addresses.home.city`,
            p_bind: null
        });

        expect(id).to.be(valueId + 6);
    
    });

    test("Request a value with bind variables", function() {
    
        let id = database.call("json_core.request_value", {
            p_path: `#id.addresses.home.:property`,
            p_bind: [valueId, "city"]
        });

        expect(id).to.be(valueId + 6);
    
    });

    test("Request value of a non-existing parent", function() {
    
        expect(function() {
        
            database.call2("json_core.request_value", {
                p_parent_value_id: -1,
                p_path: "addresses.home.house",
                p_bind: null
            });
        
        }).to.throw(/JDOC-00009/);

    });

    test("Request non-existing child value, return NULL", function() {
    
        let id = database.call2("json_core.request_value", {
            p_parent_value_id: valueId,
            p_path: "addresses.home.house",
            p_bind: null
        });
        
        expect(id).to.be(null);

    });

    test("Request non-existing child value, raise an exception", function() {
    
        expect(function() {
        
            database.call2("json_core.request_value", {
                p_parent_value_id: valueId,
                p_path: "addresses.home.house",
                p_bind: null,
                p_raise_not_found: true
            });
        
        }).to.throw(/JDOC-00009/);

    });

    test("Request ambiguous child value", function() {
    
        expect(function() {
        
            database.call2("json_core.request_value", {
                p_parent_value_id: valueId,
                p_path: "addresses.home.*",
                p_bind: null,
                p_raise_not_found: true
            });
        
        }).to.throw(/JDOC-00004/);

    });

    test("Request child value without bind variables", function() {
    
        let id = database.call2("json_core.request_value", {
            p_parent_value_id: valueId,
            p_path: "addresses.home.city",
            p_bind: null
        });
    
        expect(id).to.be(valueId + 6);

    });

    test("Request child value with bind variables", function() {
    
        let id = database.call2("json_core.request_value", {
            p_parent_value_id: valueId,
            p_path: ":property1.home.:property2",
            p_bind: ["addresses", "city"]
        });
    
        expect(id).to.be(valueId + 6);

    });
            
    test("Request child value with a branching root in the path", function() {
    
        let id = database.call2("json_core.request_value", {
            p_parent_value_id: valueId,
            p_path: "(addresses.home.city)",
            p_bind: null
        });
    
        expect(id).to.be(valueId + 6);

    });

});

suite("Property requests", function() {

    test("Try requesting a property for an invalid path", function() {
    
        expect(function() {
        
            database.call("json_core.request_property", {
                p_parent_value_id: null,
                p_path: `#${valueId}.address.city?`,
                p_bind: null
            });
        
        }).to.throw(/JDOC-00036/);
    
    });

    test("Property name missing (less than 2 elements in the query)", function() {
    
        expect(function() {
        
            database.call("json_core.request_property", {
                p_parent_value_id: null,
                p_path: "person",
                p_bind: null
            });
        
        }).to.throw(/JDOC-00041/);
    
    });
    
    test("Invalid property name (not a property name or a name variable)", function() {
    
        expect(function() {
        
            database.call("json_core.request_property", {
                p_parent_value_id: null,
                p_path: "person.*",
                p_bind: null
            });
        
        }).to.throw(/JDOC-00022/);
    
    });

    test("Request property of a non-existing container", function() {
    
        expect(function() {
        
            database.call("json_core.request_property", {
                p_parent_value_id: null,
                p_path: `#${valueId}.addresses.work.street`,
                p_bind: null
            });
        
        }).to.throw(/JDOC-00007/);
    
    });

    test("Request ambiguous property container", function() {
    
        expect(function() {
        
            database.call("json_core.request_property", {
                p_parent_value_id: null,
                p_path: `#${valueId}.addresses.*.street`,
                p_bind: null
            });
        
        }).to.throw(/JDOC-00004/);
    
    });

    test("Request an existing property with a literal name", function() {
    
        let property = database.call("json_core.request_property", {
            p_parent_value_id: null,
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
    
        let property = database.call("json_core.request_property", {
            p_parent_value_id: null,
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
    
        let property = database.call("json_core.request_property", {
            p_parent_value_id: null,
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
    
        let property = database.call("json_core.request_property", {
            p_parent_value_id: null,
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
        
            database.call("json_core.request_property", {
                p_parent_value_id: -1,
                p_path: `addresses.work.street`,
                p_bind: null
            });
        
        }).to.throw(/JDOC-00009/);
    
    });

    test("Request child property of a non-existing container", function() {
    
        expect(function() {
        
            database.call("json_core.request_property", {
                p_parent_value_id: valueId,
                p_path: `addresses.work.street`,
                p_bind: null
            });
        
        }).to.throw(/JDOC-00007/);
    
    });

    test("Request an ambiguous child property container", function() {
    
        expect(function() {
        
            database.call("json_core.request_property", {
                p_parent_value_id: valueId,
                p_path: `addresses.*.street`,
                p_bind: null
            });
        
        }).to.throw(/JDOC-00004/);
    
    });

    test("Request an existing child property with a variable name", function() {
    
        let property = database.call("json_core.request_property", {
            p_parent_value_id: valueId,
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

