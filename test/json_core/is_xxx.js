suite("IS_STRING", function() {

    test("NULL value ID", function() {
    
        expect(function() {
        
            database.call("json_core.is_string", {
                p_value_id: null  
            });
        
        }).to.throw(/JDOC-00031/);
    
    });
    
    test("Non-existing value ID", function() {
    
        expect(function() {
        
            database.call("json_core.is_string", {
                p_value_id: -1   
            });
        
        }).to.throw(/JDOC-00009/);
    
    });

    test("Check if a string is a string", function() {
    
        let valueId = database.call("json_store.create_string", {
            p_value: "Hello, World!"
        });

        let isObject = database.call("json_core.is_string", {
            p_value_id: valueId
        });

        expect(isObject).to.be(true);
        
    });

    test("Check if a number is a string", function() {
    
        let valueId = database.call("json_store.create_number", {
            p_value:123.456
        });

        let isObject = database.call("json_core.is_string", {
            p_value_id: valueId
        });

        expect(isObject).to.be(false);
        
    });

    test("Check if a boolean is a string", function() {
    
        let valueId = database.call("json_store.create_boolean", {
            p_value: true
        });

        let isObject = database.call("json_core.is_string", {
            p_value_id: valueId
        });

        expect(isObject).to.be(false);
        
    });

    test("Check if an object is a string", function() {
    
        let valueId = database.call("json_store.create_object");

        let isObject = database.call("json_core.is_string", {
            p_value_id: valueId
        });

        expect(isObject).to.be(false);
        
    });

    test("Check if an array is a string", function() {
    
        let valueId = database.call("json_store.create_array");

        let isObject = database.call("json_core.is_string", {
            p_value_id: valueId
        });

        expect(isObject).to.be(false);
        
    });

    test("Check if a null is a string", function() {
    
        let valueId = database.call("json_store.create_null");

        let isObject = database.call("json_core.is_string", {
            p_value_id: valueId
        });

        expect(isObject).to.be(false);
        
    });

    test("Check if the root is a string", function() {
    
        let isObject = database.call("json_core.is_string", {
            p_value_id: 0
        });

        expect(isObject).to.be(false);
        
    });

});

suite("IS_DATE", function() {

    test("NULL value ID", function() {
    
        expect(function() {
        
            database.call("json_core.is_date", {
                p_value_id: null  
            });
        
        }).to.throw(/JDOC-00031/);
    
    });
    
    test("Non-existing value ID", function() {
    
        expect(function() {
        
            database.call("json_core.is_date", {
                p_value_id: -1   
            });
        
        }).to.throw(/JDOC-00009/);
    
    });

    test("Check if a non-date is a date", function() {
    
        let valueId = database.call("json_store.create_string", {
            p_value: "Hello, World!"
        });

        let isObject = database.call("json_core.is_date", {
            p_value_id: valueId
        });

        expect(isObject).to.be(false);
        
    });

    test("Check if a date is a date", function() {
    
        let valueId = database.call("json_store.create_string", {
            p_value: "Hello, World!"
        });

        let isObject = database.call("json_core.is_date", {
            p_value_id: valueId
        });

        expect(isObject).to.be(false);
        
    });

});    

suite("IS_NUMBER", function() {

    test("NULL value ID", function() {
    
        expect(function() {
        
            database.call("json_core.is_number", {
                p_value_id: null  
            });
        
        }).to.throw(/JDOC-00031/);
    
    });
    
    test("Non-existing value ID", function() {
    
        expect(function() {
        
            database.call("json_core.is_number", {
                p_value_id: -1   
            });
        
        }).to.throw(/JDOC-00009/);
    
    });

    test("Check if a string is a number", function() {
    
        let valueId = database.call("json_store.create_string", {
            p_value: "Hello, World!"
        });

        let isObject = database.call("json_core.is_number", {
            p_value_id: valueId
        });

        expect(isObject).to.be(false);
        
    });

    test("Check if a number is a number", function() {
    
        let valueId = database.call("json_store.create_number", {
            p_value:123.456
        });

        let isObject = database.call("json_core.is_number", {
            p_value_id: valueId
        });

        expect(isObject).to.be(true);
        
    });

    test("Check if a boolean is a number", function() {
    
        let valueId = database.call("json_store.create_boolean", {
            p_value: true
        });

        let isObject = database.call("json_core.is_number", {
            p_value_id: valueId
        });

        expect(isObject).to.be(false);
        
    });

    test("Check if an object is a number", function() {
    
        let valueId = database.call("json_store.create_object");

        let isObject = database.call("json_core.is_number", {
            p_value_id: valueId
        });

        expect(isObject).to.be(false);
        
    });

    test("Check if an array is a number", function() {
    
        let valueId = database.call("json_store.create_array");

        let isObject = database.call("json_core.is_number", {
            p_value_id: valueId
        });

        expect(isObject).to.be(false);
        
    });

    test("Check if a null is a number", function() {
    
        let valueId = database.call("json_store.create_null");

        let isObject = database.call("json_core.is_number", {
            p_value_id: valueId
        });

        expect(isObject).to.be(false);
        
    });

    test("Check if the root is a number", function() {
    
        let isObject = database.call("json_core.is_number", {
            p_value_id: 0
        });

        expect(isObject).to.be(false);
        
    });

});

suite("IS_BOOLEAN", function() {

    test("NULL value ID", function() {
    
        expect(function() {
        
            database.call("json_core.is_boolean", {
                p_value_id: null  
            });
        
        }).to.throw(/JDOC-00031/);
    
    });
    
    test("Non-existing value ID", function() {
    
        expect(function() {
        
            database.call("json_core.is_boolean", {
                p_value_id: -1   
            });
        
        }).to.throw(/JDOC-00009/);
    
    });

    test("Check if a string is a boolean", function() {
    
        let valueId = database.call("json_store.create_string", {
            p_value: "Hello, World!"
        });

        let isObject = database.call("json_core.is_boolean", {
            p_value_id: valueId
        });

        expect(isObject).to.be(false);
        
    });

    test("Check if a number is a boolean", function() {
    
        let valueId = database.call("json_store.create_number", {
            p_value:123.456
        });

        let isObject = database.call("json_core.is_boolean", {
            p_value_id: valueId
        });

        expect(isObject).to.be(false);
        
    });

    test("Check if a boolean is a boolean", function() {
    
        let valueId = database.call("json_store.create_boolean", {
            p_value: true
        });

        let isObject = database.call("json_core.is_boolean", {
            p_value_id: valueId
        });

        expect(isObject).to.be(true);
        
    });

    test("Check if an object is a boolean", function() {
    
        let valueId = database.call("json_store.create_object");

        let isObject = database.call("json_core.is_boolean", {
            p_value_id: valueId
        });

        expect(isObject).to.be(false);
        
    });

    test("Check if an array is a boolean", function() {
    
        let valueId = database.call("json_store.create_array");

        let isObject = database.call("json_core.is_boolean", {
            p_value_id: valueId
        });

        expect(isObject).to.be(false);
        
    });

    test("Check if a null is a boolean", function() {
    
        let valueId = database.call("json_store.create_null");

        let isObject = database.call("json_core.is_boolean", {
            p_value_id: valueId
        });

        expect(isObject).to.be(false);
        
    });

    test("Check if the root is a boolean", function() {
    
        let isObject = database.call("json_core.is_boolean", {
            p_value_id: 0
        });

        expect(isObject).to.be(false);
        
    });

});

suite("IS_NULL", function() {

    test("NULL value ID", function() {
    
        expect(function() {
        
            database.call("json_core.is_null", {
                p_value_id: null  
            });
        
        }).to.throw(/JDOC-00031/);
    
    });
    
    test("Non-existing value ID", function() {
    
        expect(function() {
        
            database.call("json_core.is_null", {
                p_value_id: -1   
            });
        
        }).to.throw(/JDOC-00009/);
    
    });

    test("Check if a string is a null", function() {
    
        let valueId = database.call("json_store.create_string", {
            p_value: "Hello, World!"
        });

        let isObject = database.call("json_core.is_null", {
            p_value_id: valueId
        });

        expect(isObject).to.be(false);
        
    });

    test("Check if a number is a null", function() {
    
        let valueId = database.call("json_store.create_number", {
            p_value:123.456
        });

        let isObject = database.call("json_core.is_null", {
            p_value_id: valueId
        });

        expect(isObject).to.be(false);
        
    });

    test("Check if a boolean is a null", function() {
    
        let valueId = database.call("json_store.create_boolean", {
            p_value: true
        });

        let isObject = database.call("json_core.is_null", {
            p_value_id: valueId
        });

        expect(isObject).to.be(false);
        
    });

    test("Check if an object is a null", function() {
    
        let valueId = database.call("json_store.create_object");

        let isObject = database.call("json_core.is_null", {
            p_value_id: valueId
        });

        expect(isObject).to.be(false);
        
    });

    test("Check if an array is a null", function() {
    
        let valueId = database.call("json_store.create_array");

        let isObject = database.call("json_core.is_null", {
            p_value_id: valueId
        });

        expect(isObject).to.be(false);
        
    });

    test("Check if a null is a null", function() {
    
        let valueId = database.call("json_store.create_null");

        let isObject = database.call("json_core.is_null", {
            p_value_id: valueId
        });

        expect(isObject).to.be(true);
        
    });

    test("Check if the root is a null", function() {
    
        let isObject = database.call("json_core.is_null", {
            p_value_id: 0
        });

        expect(isObject).to.be(false);
        
    });

});

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