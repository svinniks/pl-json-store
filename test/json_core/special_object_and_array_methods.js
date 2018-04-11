suite("GET_KEYS", function() {

    test("NULL value ID", function() {
    
        expect(function() {
        
            database.call("json_core.get_keys", {
                p_object_id: null  
            });
        
        }).to.throw(/JDOC-00031/);
    
    });
    
    test("Non-existing value ID", function() {
    
        expect(function() {
        
            database.call("json_core.get_keys", {
                p_object_id: -1   
            });
        
        }).to.throw(/JDOC-00009/);
    
    });

    test("Try requesting keys of a string", function() {
    
        let valueId = database.call("json_store.create_string", {
            p_value: "Hello, World!"
        });

        expect(function() {
        
            database.call("json_core.get_keys", {
                p_object_id: valueId 
            });
        
        }).to.throw(/JDOC-00021/);
    
    });

    test("Try requesting keys of a number", function() {
    
        let valueId = database.call("json_store.create_number", {
            p_value: 123.456
        });

        expect(function() {
        
            database.call("json_core.get_keys", {
                p_object_id: valueId 
            });
        
        }).to.throw(/JDOC-00021/);
    
    });

    test("Try requesting keys of a boolean", function() {
    
        let valueId = database.call("json_store.create_boolean", {
            p_value: true
        });

        expect(function() {
        
            database.call("json_core.get_keys", {
                p_object_id: valueId 
            });
        
        }).to.throw(/JDOC-00021/);
    
    });

    test("Try requesting keys of an array", function() {
    
        let valueId = database.call("json_store.create_boolean", {
            p_value: true
        });

        expect(function() {
        
            database.call("json_core.get_keys", {
                p_object_id: valueId 
            });
        
        }).to.throw(/JDOC-00021/);
    
    });

    test("Try requesting keys of a null", function() {
    
        let valueId = database.call("json_store.create_boolean", {
            p_value: null
        });

        expect(function() {
        
            database.call("json_core.get_keys", {
                p_object_id: valueId 
            });
        
        }).to.throw(/JDOC-00021/);
    
    });

    test("Request keys of an object", function() {
    
        let valueId = database.call("json_store.create_json", {
            p_content: {
                name: "Sergejs",
                surname: "Vinniks",
                address: {
                    city: "Riga"
                }
            }
        });

        let keys = database.call("json_core.get_keys", {
            p_object_id: valueId 
        });

        keys.sort();

        expect(keys).to.eql(["address", "name", "surname"]);

    });

    test("Request keys of the root", function() {
    
        let keys = database.call("json_core.get_keys", {
            p_object_id: 0 
        });

    });

});

suite("GET_LENGTH", function() {

    test("NULL value ID", function() {
    
        expect(function() {
        
            database.call("json_core.get_length", {
                p_array_id: null  
            });
        
        }).to.throw(/JDOC-00031/);
    
    });
    
    test("Non-existing value ID", function() {
    
        expect(function() {
        
            database.call("json_core.get_length", {
                p_array_id: -1   
            });
        
        }).to.throw(/JDOC-00009/);
    
    });

    test("Try requesting length of a string", function() {
    
        let valueId = database.call("json_store.create_json", {
            p_content: "Hello, World!"
        });

        expect(function() {
        
            database.call("json_core.get_length", {
                p_array_id: valueId
            });
        
        }).to.throw(/JDOC-00012/);
    
    });

    test("Try requesting length of a number", function() {
    
        let valueId = database.call("json_store.create_json", {
            p_content: 123.456
        });

        expect(function() {
        
            database.call("json_core.get_length", {
                p_array_id: valueId
            });
        
        }).to.throw(/JDOC-00012/);
    
    });

    test("Try requesting length of a boolean", function() {
    
        let valueId = database.call("json_store.create_json", {
            p_content: true
        });

        expect(function() {
        
            database.call("json_core.get_length", {
                p_array_id: valueId
            });
        
        }).to.throw(/JDOC-00012/);
    
    });

    test("Try requesting length of an object", function() {
    
        let valueId = database.call("json_store.create_json", {
            p_content: {}
        });

        expect(function() {
        
            database.call("json_core.get_length", {
                p_array_id: valueId
            });
        
        }).to.throw(/JDOC-00012/);
    
    });

    test("Try requesting length of a null", function() {
    
        let valueId = database.call("json_store.create_json", {
            p_content: null
        });

        expect(function() {
        
            database.call("json_core.get_length", {
                p_array_id: valueId
            });
        
        }).to.throw(/JDOC-00012/);
    
    });

    test("Try requesting length of an array", function() {
    
        let valueId = database.call("json_store.create_json", {
            p_content: ["Hello", "World", {}, [], null]
        });

        let length = database.call("json_core.get_length", {
            p_array_id: valueId
        });
        
        expect(length).to.be(5);
    
    });

});