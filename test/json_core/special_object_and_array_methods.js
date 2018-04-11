suite("IS_OBJECT", function() {

    test("NULL value ID", function() {
    
        expect(function() {
        
            database.call("json_core.is_object", {
                p_value_id: null  
            });
        
        }).to.throw(/JDOC-00031/);
    
    });
    
    test("Non-existing value ID", function() {
    
        expect(function() {
        
            database.call("json_core.is_object", {
                p_value_id: -1   
            });
        
        }).to.throw(/JDOC-00009/);
    
    });

    test("Check if a string is an object", function() {
    
        let valueId = database.call("json_store.create_string", {
            p_value: "Hello, World!"
        });

        let isObject = database.call("json_core.is_object", {
            p_value_id: valueId
        });

        expect(isObject).to.be(false);
        
    });

    test("Check if a number is an object", function() {
    
        let valueId = database.call("json_store.create_number", {
            p_value:123.456
        });

        let isObject = database.call("json_core.is_object", {
            p_value_id: valueId
        });

        expect(isObject).to.be(false);
        
    });

    test("Check if a boolean is an object", function() {
    
        let valueId = database.call("json_store.create_boolean", {
            p_value: true
        });

        let isObject = database.call("json_core.is_object", {
            p_value_id: valueId
        });

        expect(isObject).to.be(false);
        
    });

    test("Check if an object is an object", function() {
    
        let valueId = database.call("json_store.create_object");

        let isObject = database.call("json_core.is_object", {
            p_value_id: valueId
        });

        expect(isObject).to.be(true);
        
    });

    test("Check if an array is an object", function() {
    
        let valueId = database.call("json_store.create_array");

        let isObject = database.call("json_core.is_object", {
            p_value_id: valueId
        });

        expect(isObject).to.be(false);
        
    });

    test("Check if a null is an object", function() {
    
        let valueId = database.call("json_store.create_null");

        let isObject = database.call("json_core.is_object", {
            p_value_id: valueId
        });

        expect(isObject).to.be(false);
        
    });

    test("Check if the root is an object", function() {
    
        let isObject = database.call("json_core.is_object", {
            p_value_id: 0
        });

        expect(isObject).to.be(true);
        
    });

});

suite("IS_ARRAY", function() {

    test("NULL value ID", function() {
    
        expect(function() {
        
            database.call("json_core.is_array", {
                p_value_id: null  
            });
        
        }).to.throw(/JDOC-00031/);
    
    });
    
    test("Non-existing value ID", function() {
    
        expect(function() {
        
            database.call("json_core.is_array", {
                p_value_id: -1   
            });
        
        }).to.throw(/JDOC-00009/);
    
    });

    test("Check if a string is an array", function() {
    
        let valueId = database.call("json_store.create_string", {
            p_value: "Hello, World!"
        });

        let isObject = database.call("json_core.is_array", {
            p_value_id: valueId
        });

        expect(isObject).to.be(false);
        
    });

    test("Check if a number is an array", function() {
    
        let valueId = database.call("json_store.create_number", {
            p_value:123.456
        });

        let isObject = database.call("json_core.is_array", {
            p_value_id: valueId
        });

        expect(isObject).to.be(false);
        
    });

    test("Check if a boolean is an array", function() {
    
        let valueId = database.call("json_store.create_boolean", {
            p_value: true
        });

        let isObject = database.call("json_core.is_array", {
            p_value_id: valueId
        });

        expect(isObject).to.be(false);
        
    });

    test("Check if an object is an array", function() {
    
        let valueId = database.call("json_store.create_object");

        let isObject = database.call("json_core.is_array", {
            p_value_id: valueId
        });

        expect(isObject).to.be(false);
        
    });

    test("Check if an array is an array", function() {
    
        let valueId = database.call("json_store.create_array");

        let isObject = database.call("json_core.is_array", {
            p_value_id: valueId
        });

        expect(isObject).to.be(true);
        
    });

    test("Check if a null is an array", function() {
    
        let valueId = database.call("json_store.create_null");

        let isObject = database.call("json_core.is_array", {
            p_value_id: valueId
        });

        expect(isObject).to.be(false);
        
    });

    test("Check if the root is an array", function() {
    
        let isObject = database.call("json_core.is_array", {
            p_value_id: 0
        });

        expect(isObject).to.be(false);
        
    });

});

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