suite("GET_STRING", function() {

    test("NULL value ID", function() {
    
        let value = database.call("json_core.get_string", {
            p_value_id: null
        });

        expect(value).to.be(null);
    
    });
    
    test("Non-existing value ID", function() {
    
        expect(function() {
        
            database.call("json_core.get_string  ", {
                p_value_id: -1   
            });
        
        }).to.throw(/JDC-00009/);
    
    });

    test("Try getting a boolean as string", function() {
    
        let valueId = database.call("json_store.create_boolean", {
            p_value: true
        });

        expect(function() {
        
            database.call("json_core.get_string", {
                p_value_id: valueId
            });
        
        }).to.throw(/JDC-00010/);
    
    });

    test("Try getting an object as string", function() {
    
        let valueId = database.call("json_store.create_object");

        expect(function() {
        
            database.call("json_core.get_string  ", {
                p_value_id: valueId
            });
        
        }).to.throw(/JDC-00010/);
    
    });
    
    test("Try getting an array as string", function() {
    
        let valueId = database.call("json_store.create_array");

        expect(function() {
        
            database.call("json_core.get_string  ", {
                p_value_id: valueId
            });
        
        }).to.throw(/JDC-00010/);
    
    });

    test("Try getting the root as string", function() {

        expect(function() {
        
            database.call("json_core.get_string  ", {
                p_value_id: 0
            });
        
        }).to.throw(/JDC-00010/);
    
    });

    test("Get a string as string", function() {
    
        let value = "Hello, World!"

        let valueId = database.call("json_store.create_string", {
            p_value: value
        });

        let retrieved = database.call("json_core.get_string", {
            p_value_id: valueId
        });

        expect(retrieved).to.eql(value);
    
    });

    test("Get a number as string", function() {
    
        let value = "123.456"

        let valueId = database.call("json_store.create_number", {
            p_value: value
        });

        let retrieved = database.call("json_core.get_string", {
            p_value_id: valueId
        });

        expect(retrieved).to.eql(value);
    
    });

    test("Get a null as string", function() {
    
        let valueId = database.call("json_store.create_null");

        let retrieved = database.call("json_core.get_string", {
            p_value_id: valueId
        });

        expect(retrieved).to.be(null);
    
    });

});

suite("GET_DATE", function() {

    test("NULL value ID", function() {
    
        let value = database.call("json_core.get_date", {
            p_value_id: null
        });

        expect(value).to.be(null);
    
    });
    
    test("Non-existing value ID", function() {
    
        expect(function() {
        
            database.call("json_core.get_date", {
                p_value_id: -1   
            });
        
        }).to.throw(/JDC-00009/);
    
    });

    test("Try getting a non-string as date", function() {
    
        let valueId = database.call("json_store.create_boolean", {
            p_value: true
        });

        expect(function() {
        
            database.call("json_core.get_date", {
                p_value_id: valueId
            });
        
        }).to.throw(/JDC-00010/);
    
    });

    test("Try getting a non-date string as date", function() {
    
        let valueId = database.call("json_store.create_string", {
            p_value: "2018-AA-BB"
        });

        expect(function() {
        
            database.call("json_core.get_date", {
                p_value_id: valueId
            });
        
        }).to.throw(/JDC-00010/);
    
    });

    test("Get a valid date string as date", function() {
    
        let valueId = database.call("json_store.create_string", {
            p_value: "2018-01-18"
        });

        let value = database.call("json_core.get_date", {
            p_value_id: valueId
        });
    
        expect(value).to.be("2018-01-18");
    
    });

});    

suite("GET_NUMBER", function() {

    test("NULL value ID", function() {
    
        let value = database.call("json_core.get_number", {
            p_value_id: null
        });

        expect(value).to.be(null);
    
    });
    
    test("Non-existing value ID", function() {
    
        expect(function() {
        
            database.call("json_core.get_number", {
                p_value_id: -1   
            });
        
        }).to.throw(/JDC-00009/);
    
    });

    test("Try getting a boolean as number", function() {
    
        let valueId = database.call("json_store.create_boolean", {
            p_value: true
        });

        expect(function() {
        
            database.call("json_core.get_number", {
                p_value_id: valueId
            });
        
        }).to.throw(/JDC-00010/);
    
    });

    test("Try getting an object as number", function() {
    
        let valueId = database.call("json_store.create_object");

        expect(function() {
        
            database.call("json_core.get_number", {
                p_value_id: valueId
            });
        
        }).to.throw(/JDC-00010/);
    
    });
    
    test("Try getting an array as number", function() {
    
        let valueId = database.call("json_store.create_array");

        expect(function() {
        
            database.call("json_core.get_number", {
                p_value_id: valueId
            });
        
        }).to.throw(/JDC-00010/);
    
    });

    test("Try getting the root as string", function() {

        expect(function() {
        
            database.call("json_core.get_number", {
                p_value_id: 0
            });
        
        }).to.throw(/JDC-00010/);
    
    });

    test("Get a number as number", function() {
    
        let value = 123.456

        let valueId = database.call("json_store.create_number", {
            p_value: value
        });

        let retrieved = database.call("json_core.get_number", {
            p_value_id: valueId
        });

        expect(retrieved).to.eql(value);
    
    });

    test("Get a string as number", function() {
    
        let value = "123.456"

        let valueId = database.call("json_store.create_string", {
            p_value: value
        });

        let retrieved = database.call("json_core.get_number", {
            p_value_id: valueId
        });

        expect(retrieved).to.eql(value);
    
    });

    test("Get a non-number string as number", function() {
    
        let value = "Helo, World!"

        let valueId = database.call("json_store.create_string", {
            p_value: value
        });

        expect(function() {
        
            database.call("json_core.get_number", {
                p_value_id: valueId
            });  
        
        }).to.throw(/JDC-00010/);
    
    });

    test("Get a null as number", function() {
    
        let valueId = database.call("json_store.create_null");

        let retrieved = database.call("json_core.get_number", {
            p_value_id: valueId
        });

        expect(retrieved).to.be(null);
    
    });

});

suite("GET_BOOLEAN", function() {

    test("NULL value ID", function() {
    
        let value = database.call("json_core.get_boolean", {
            p_value_id: null
        });

        expect(value).to.be(null);
    
    });
    
    test("Non-existing value ID", function() {
    
        expect(function() {
        
            database.call("json_core.get_boolean", {
                p_value_id: -1   
            });
        
        }).to.throw(/JDC-00009/);
    
    });

    test("Try getting a string as boolean", function() {
    
        let valueId = database.call("json_store.create_string", {
            p_value: "Hello, World!"
        });

        expect(function() {
        
            database.call("json_core.get_boolean", {
                p_value_id: valueId
            });
        
        }).to.throw(/JDC-00010/);
    
    });

    test("Try getting a number as boolean", function() {
    
        let valueId = database.call("json_store.create_number", {
            p_value: 123.45
        });

        expect(function() {
        
            database.call("json_core.get_boolean", {
                p_value_id: valueId
            });
        
        }).to.throw(/JDC-00010/);
    
    });

    test("Try getting an object as boolean", function() {
    
        let valueId = database.call("json_store.create_object");

        expect(function() {
        
            database.call("json_core.get_boolean", {
                p_value_id: valueId
            });
        
        }).to.throw(/JDC-00010/);
    
    });
    
    test("Try getting an array as boolean", function() {
    
        let valueId = database.call("json_store.create_array");

        expect(function() {
        
            database.call("json_core.get_boolean", {
                p_value_id: valueId
            });
        
        }).to.throw(/JDC-00010/);
    
    });

    test("Try getting the root as boolean", function() {

        expect(function() {
        
            database.call("json_core.get_boolean", {
                p_value_id: 0
            });
        
        }).to.throw(/JDC-00010/);
    
    });

    test("Get a boolean as boolean", function() {
    
        let value = true

        let valueId = database.call("json_store.create_boolean", {
            p_value: value
        });

        let retrieved = database.call("json_core.get_boolean", {
            p_value_id: valueId
        });

        expect(retrieved).to.eql(value);
    
    });

    test("Get a null as boolean", function() {
    
        let valueId = database.call("json_store.create_null");

        let retrieved = database.call("json_core.get_boolean", {
            p_value_id: valueId
        });

        expect(retrieved).to.be(null);
    
    });

});

suite("GET_JSON", function() {

    test("NULL value ID", function() {
    
        let value = database.call("json_core.get_json", {
            p_value_id: null,
            p_serialize_nulls: true
        });

        expect(value).to.be(null);
    
    });
    
    test("Non-existing value ID", function() {
    
        expect(function() {
        
            database.call("json_core.get_json", {
                p_value_id: -1,
                p_serialize_nulls: true   
            });
        
        }).to.throw(/JDC-00009/);
    
    });

    test("Successfully serialize a value using", function() {
    
        let value = {
            name: "Sergejs",
            surname: "Vinniks"
        };

        let valueId = database.call("json_store.create_json", {
            p_content: value
        });

        let retrieved = database.call("json_core.get_json", {
            p_value_id: valueId,
            p_serialize_nulls: true
        });

        expect(JSON.parse(retrieved)).to.eql(value);
    
    });
    
});

suite("GET_JSON_CLOB", function() {

    test("NULL value ID", function() {
    
        let value = database.call("json_core.get_json_clob", {
            p_value_id: null,
            p_serialize_nulls: true
        });

        expect(value).to.be(null);
    
    });
    
    test("Non-existing value ID", function() {
    
        expect(function() {
        
            database.call("json_core.get_json_clob", {
                p_value_id: -1,
                p_serialize_nulls: true   
            });
        
        }).to.throw(/JDC-00009/);
    
    });

    test("Successfully serialize a value using", function() {
    
        let value = {
            name: "Sergejs",
            surname: "Vinniks"
        };

        let valueId = database.call("json_store.create_json", {
            p_content: value
        });

        let retrieved = database.call("json_core.get_json_clob", {
            p_value_id: valueId,
            p_serialize_nulls: true
        });

        expect(JSON.parse(retrieved)).to.eql(value);
    
    });
    
});