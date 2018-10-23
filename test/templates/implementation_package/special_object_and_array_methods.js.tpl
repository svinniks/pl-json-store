suite("GET_KEYS", function() {

    test("NULL value ID", function() {
    
        expect(function() {
        
            database.call(`${implementationPackage}.get_keys`, {
                p_object_id: null  
            });
        
        }).to.throw(/JDC-00031/);
    
    });
    
    test("Non-existing value ID", function() {
    
        expect(function() {
        
            database.call(`${implementationPackage}.get_keys`, {
                p_object_id: -1   
            });
        
        }).to.throw(/JDC-00009/);
    
    });

    test("Try requesting keys of a string", function() {
    
        let valueId = database.call(`${implementationPackage}.create_json`, {
            p_content_parse_events: [
                "SHello, World!"
            ]
        });

        expect(function() {
        
            database.call(`${implementationPackage}.get_keys`, {
                p_object_id: valueId 
            });
        
        }).to.throw(/JDC-00021/);
    
    });

    test("Try requesting keys of a number", function() {
    
        let valueId = database.call(`${implementationPackage}.create_json`, {
            p_content_parse_events: [
                "N123"
            ]
        });

        expect(function() {
        
            database.call(`${implementationPackage}.get_keys`, {
                p_object_id: valueId 
            });
        
        }).to.throw(/JDC-00021/);
    
    });

    test("Try requesting keys of a boolean", function() {
    
        let valueId = database.call(`${implementationPackage}.create_json`, {
            p_content_parse_events: [
                "Btrue"
            ]
        });

        expect(function() {
        
            database.call(`${implementationPackage}.get_keys`, {
                p_object_id: valueId 
            });
        
        }).to.throw(/JDC-00021/);
    
    });

    test("Try requesting keys of an array", function() {
    
        let valueId = database.call(`${implementationPackage}.create_json`, {
            p_content_parse_events: [
                "[",
                "]"
            ]
        });

        expect(function() {
        
            database.call(`${implementationPackage}.get_keys`, {
                p_object_id: valueId 
            });
        
        }).to.throw(/JDC-00021/);
    
    });

    test("Try requesting keys of a null", function() {
    
        let valueId = database.call(`${implementationPackage}.create_json`, {
            p_content_parse_events: [
                "E"
            ]
        });

        expect(function() {
        
            database.call(`${implementationPackage}.get_keys`, {
                p_object_id: valueId 
            });
        
        }).to.throw(/JDC-00021/);
    
    });

    test("Request keys of an empty object", function() {
        
        let valueId = database.call(`${implementationPackage}.create_json`, {
            p_content_parse_events: [
                "{",
                "}"
            ]
        });

        let keys = database.call(`${implementationPackage}.get_keys`, {
            p_object_id: valueId 
        });

        keys.sort();

        expect(keys).to.eql([]);

    });

    test("Request keys of an object", function() {
        
        let valueId = database.call(`${implementationPackage}.create_json`, {
            p_content_parse_events: [
                "{",
                ":name",
                "SSergejs",
                ":surname",
                "SVinniks",
                ":address",
                "{",
                ":city",
                "SRiga",
                "}",
                "}"
            ]
        });

        let keys = database.call(`${implementationPackage}.get_keys`, {
            p_object_id: valueId 
        });

        keys.sort();

        expect(keys).to.eql(["address", "name", "surname"]);

    });

    test("Request keys of the root", function() {
    
        let rootId = database.call(`${implementationPackage}.request_value`, {
            p_anchor_id: null,
            p_path: '$',
            p_bind: null
        });

        let keys = database.call(`${implementationPackage}.get_keys`, {
            p_object_id: rootId 
        });

    });

});

suite("GET_LENGTH", function() {

    test("NULL value ID", function() {
    
        expect(function() {
        
            database.call(`${implementationPackage}.get_length`, {
                p_array_id: null  
            });
        
        }).to.throw(/JDC-00031/);
    
    });
    
    test("Non-existing value ID", function() {
    
        expect(function() {
        
            database.call(`${implementationPackage}.get_length`, {
                p_array_id: -1   
            });
        
        }).to.throw(/JDC-00009/);
    
    });

    test("Try requesting length of a string", function() {
    
        let valueId = database.call(`${implementationPackage}.create_json`, {
            p_content_parse_events: [
                "SHello, World!"
            ]
        });

        expect(function() {
        
            database.call(`${implementationPackage}.get_length`, {
                p_array_id: valueId
            });
        
        }).to.throw(/JDC-00012/);
    
    });

    test("Try requesting length of a number", function() {
    
        let valueId = database.call(`${implementationPackage}.create_json`, {
            p_content_parse_events: [
                "N123"
            ]
        });

        expect(function() {
        
            database.call(`${implementationPackage}.get_length`, {
                p_array_id: valueId
            });
        
        }).to.throw(/JDC-00012/);
    
    });

    test("Try requesting length of a boolean", function() {
    
        let valueId = database.call(`${implementationPackage}.create_json`, {
            p_content_parse_events: [
                "Btrue"
            ]
        });

        expect(function() {
        
            database.call(`${implementationPackage}.get_length`, {
                p_array_id: valueId
            });
        
        }).to.throw(/JDC-00012/);
    
    });

    test("Try requesting length of an object", function() {
    
        let valueId = database.call(`${implementationPackage}.create_json`, {
            p_content_parse_events: [
                "{",
                "}"
            ]
        });

        expect(function() {
        
            database.call(`${implementationPackage}.get_length`, {
                p_array_id: valueId
            });
        
        }).to.throw(/JDC-00012/);
    
    });

    test("Try requesting length of a null", function() {
    
        let valueId = database.call(`${implementationPackage}.create_json`, {
            p_content_parse_events: [
                "E"
            ]
        });

        expect(function() {
        
            database.call(`${implementationPackage}.get_length`, {
                p_array_id: valueId
            });
        
        }).to.throw(/JDC-00012/);
    
    });

    test("Request length of an empty array", function() {
    
        let valueId = database.call(`${implementationPackage}.create_json`, {
            p_content_parse_events: [
                "[",
                "]"
            ]
        });
        
        let length = database.call(`${implementationPackage}.get_length`, {
            p_array_id: valueId
        });
        
        expect(length).to.be(0);
    
    });

    test("Request length of an array", function() {
    
        let valueId = database.call(`${implementationPackage}.create_json`, {
            p_content_parse_events: [
                "[",
                ":0",
                "SHello",
                ":1",
                "SWorld",
                ":2",
                "{",
                "}",
                ":3",
                "[",
                "]",
                ":4",
                "E",
                "]"
            ]
        });
        
        let length = database.call(`${implementationPackage}.get_length`, {
            p_array_id: valueId
        });
        
        expect(length).to.be(5);
    
    });

});

suite("INDEX_OF", function() {

    test("Try to call INDEX_OF with NULL array ID", function() {
    
        expect(function() {
        
            database.call(`${implementationPackage}.index_of`, {
                p_array_id: null,
                p_type: null,
                p_value: null,
                p_from_index: 0
            });
        
        }).to.throw(/JDC-00031/);
    
    });
    
    test("Try to call INDEX_OF with non-existing array ID", function() {
    
        expect(function() {
        
            database.call(`${implementationPackage}.index_of`, {
                p_array_id: -1,
                p_type: null,
                p_value: null,
                p_from_index: 0
            });
        
        }).to.throw(/JDC-00009/);
    
    });

    test("Try to call INDEX_OF with non-array ID", function() {
    
        let valueId = database.call(`${implementationPackage}.create_json`, {
            p_content_parse_events: [
                "SHello, World!"
            ]
        });

        expect(function() {
        
            database.call(`${implementationPackage}.index_of`, {
                p_array_id: valueId,
                p_type: null,
                p_value: null,
                p_from_index: 0
            });
        
        }).to.throw(/JDC-00012/);
    
    });

    test("Locate a string, don't find", function() {
    
        let arrayId = database.call(`${implementationPackage}.create_json`, {
            p_content_parse_events: [
                "[",
                ":0",
                "SHello, World!",
                ":1",
                "E",
                ":2",
                "N123.321",
                ":3",
                "{",
                "}",
                "]"
            ]
        });

        let indexOf = database.call(`${implementationPackage}.index_of`, {
            p_array_id: arrayId,
            p_type: "S",
            p_value: "Good bye, World!",
            p_from_index: 0
        });

        expect(indexOf).to.be(-1);
    
    });

    test("Locate empty string, find", function() {
    
        let arrayId = database.call(`${implementationPackage}.create_json`, {
            p_content_parse_events: [
                "[",
                ":0",
                "SHello, World!",
                ":1",
                "E",
                ":2",
                "N123.321",
                ":3",
                "{",
                "}",
                "]"
            ]
        });

        let indexOf = database.call(`${implementationPackage}.index_of`, {
            p_array_id: arrayId,
            p_type: "S",
            p_value: "Hello, World!",
            p_from_index: 0
        });

        expect(indexOf).to.be(0);
    
    });
    
    test("Locate second (empty) string string, find", function() {
    
        let arrayId = database.call(`${implementationPackage}.create_json`, {
            p_content_parse_events: [
                "[",
                ":0",
                "SHello, World!",
                ":1",
                "E",
                ":2",
                "N123.321",
                ":3",
                "{",
                "}",
                ":4",
                "S",
                "]"
            ]
        });

        let indexOf = database.call(`${implementationPackage}.index_of`, {
            p_array_id: arrayId,
            p_type: "S",
            p_value: null,
            p_from_index: 1
        });

        expect(indexOf).to.be(4);
    
    });

    test("Locate second empty string, don't find", function() {
    
        let arrayId = database.call(`${implementationPackage}.create_json`, {
            p_content_parse_events: [
                "[",
                ":0",
                "SHello, World!",
                ":1",
                "E",
                ":2",
                "N123.321",
                ":3",
                "{",
                "}",
                ":4",
                "S",
                "]"
            ]
        });

        let indexOf = database.call(`${implementationPackage}.index_of`, {
            p_array_id: arrayId,
            p_type: "S",
            p_value: null,
            p_from_index: 5
        });

        expect(indexOf).to.be(-1);
    
    });

});