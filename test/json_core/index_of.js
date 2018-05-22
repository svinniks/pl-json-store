suite("INDEX_OF tests", function() {

    test("Try to call INDEX_OF VARCHAR version with NULL array ID", function() {
    
        expect(function() {
        
            database.call("json_core.index_of", {
                p_array_id: null,
                p_value: null,
                p_from_index: 0
            });
        
        }).to.throw(/JDOC-00031/);
    
    });
    
    test("Try to call INDEX_OF VARCHAR version with non-existing array ID", function() {
    
        expect(function() {
        
            database.call("json_core.index_of", {
                p_array_id: -1,
                p_value: null,
                p_from_index: 0
            });
        
        }).to.throw(/JDOC-00009/);
    
    });

    test("Try to call INDEX_OF VARCHAR version with non-array ID", function() {
    
        let valueId = database.call("json_store.create_string", {
            p_value: "Hello, World!"
        });

        expect(function() {
        
            database.call("json_core.index_of", {
                p_array_id: valueId,
                p_value: null,
                p_from_index: 0
            });
        
        }).to.throw(/JDOC-00012/);
    
    });

    test("Locate empty string, don't find", function() {
    
        let arrayId = database.call("json_store.create_json", {
            p_content: [
                "Hello, World!",
                null,
                123.321,
                {}
            ]
        });

        let indexOf = database.call("json_core.index_of", {
            p_array_id: arrayId,
            p_value: null,
            p_from_index: 0
        });

        expect(indexOf).to.be(-1);
    
    });

    test("Locate empty string, find", function() {
    
        let arrayId = database.call("json_store.create_json", {
            p_content: [
                "Hello, World!",
                null,
                123.321,
                "",
                {}
            ]
        });

        let indexOf = database.call("json_core.index_of", {
            p_array_id: arrayId,
            p_value: null,
            p_from_index: 0
        });

        expect(indexOf).to.be(3);
    
    });
    
    test("Locate empty string, find", function() {
    
        let arrayId = database.call("json_store.create_json", {
            p_content: [
                "Hello, World!",
                "",
                null,
                123.321,
                "",
                {},
            ]
        });

        let indexOf = database.call("json_core.index_of", {
            p_array_id: arrayId,
            p_value: null,
            p_from_index: 0
        });

        expect(indexOf).to.be(1);
    
    });

    test("Locate second empty string, find", function() {
    
        let arrayId = database.call("json_store.create_json", {
            p_content: [
                "Hello, World!",
                "",
                null,
                123.321,
                "",
                {},
            ]
        });

        let indexOf = database.call("json_core.index_of", {
            p_array_id: arrayId,
            p_value: null,
            p_from_index: 2
        });

        expect(indexOf).to.be(4);
    
    });

    test("Locate second empty string, don't find", function() {
    
        let arrayId = database.call("json_store.create_json", {
            p_content: [
                "Hello, World!",
                "",
                null,
                123.321,
                "",
                {},
            ]
        });

        let indexOf = database.call("json_core.index_of", {
            p_array_id: arrayId,
            p_value: null,
            p_from_index: 5
        });

        expect(indexOf).to.be(-1);
    
    });

    test("Try to call INDEX_OF DATE version with NULL array ID", function() {
    
        expect(function() {
        
            database.call2("json_core.index_of", {
                p_array_id: null,
                p_value: null,
                p_from_index: 0
            });
        
        }).to.throw(/JDOC-00031/);
    
    });
    
    test("Try to call INDEX_OF DATE version with non-existing array ID", function() {
    
        expect(function() {
        
            database.call2("json_core.index_of", {
                p_array_id: -1,
                p_value: null,
                p_from_index: 0
            });
        
        }).to.throw(/JDOC-00009/);
    
    });

    test("Try to call INDEX_OF DATE version with non-array ID", function() {
    
        let valueId = database.call("json_store.create_string", {
            p_value: "Hello, World!"
        });

        expect(function() {
        
            database.call2("json_core.index_of", {
                p_array_id: valueId,
                p_value: null,
                p_from_index: 0
            });
        
        }).to.throw(/JDOC-00012/);
    
    });

    test("Locate null date, don't find", function() {
    
        let arrayId = database.call("json_store.create_json", {
            p_content: [
                "Hello, World!",
                123.321,
                "",
                {}
            ]
        });

        let indexOf = database.call2("json_core.index_of", {
            p_array_id: arrayId,
            p_value: null,
            p_from_index: 0
        });

        expect(indexOf).to.be(-1);
    
    });

    test("Locate null date, find", function() {
    
        let arrayId = database.call("json_store.create_json", {
            p_content: [
                "Hello, World!",
                null,
                123.321,
                "",
                {}
            ]
        });

        let indexOf = database.call2("json_core.index_of", {
            p_array_id: arrayId,
            p_value: null,
            p_from_index: 0
        });

        expect(indexOf).to.be(1);
    
    });

    test("Locate date, find", function() {
    
        let arrayId = database.call("json_store.create_json", {
            p_content: [
                "Hello, World!",
                "1992-04-07",
                123.321,
                "",
                "1992-04-07",
                {}
            ]
        });

        let indexOf = database.call2("json_core.index_of", {
            p_array_id: arrayId,
            p_value: "1992-04-07",
            p_from_index: 0
        });

        expect(indexOf).to.be(1);
    
    });

    test("Locate second date, find", function() {
    
        let arrayId = database.call("json_store.create_json", {
            p_content: [
                "Hello, World!",
                "1992-04-07",
                123.321,
                "",
                "1992-04-07",
                {}
            ]
        });

        let indexOf = database.call2("json_core.index_of", {
            p_array_id: arrayId,
            p_value: "1992-04-07",
            p_from_index: 2
        });

        expect(indexOf).to.be(4);
    
    });

    test("Try to call INDEX_OF NUMBER version with NULL array ID", function() {
    
        expect(function() {
        
            database.call3("json_core.index_of", {
                p_array_id: null,
                p_value: null,
                p_from_index: 0
            });
        
        }).to.throw(/JDOC-00031/);
    
    });
    
    test("Try to call INDEX_OF NUMBER version with non-existing array ID", function() {
    
        expect(function() {
        
            database.call3("json_core.index_of", {
                p_array_id: -1,
                p_value: null,
                p_from_index: 0
            });
        
        }).to.throw(/JDOC-00009/);
    
    });

    test("Try to call INDEX_OF NUMBER version with non-array ID", function() {
    
        let valueId = database.call("json_store.create_string", {
            p_value: "Hello, World!"
        });

        expect(function() {
        
            database.call3("json_core.index_of", {
                p_array_id: valueId,
                p_value: null,
                p_from_index: 0
            });
        
        }).to.throw(/JDOC-00012/);
    
    });

    test("Locate null number, don't find", function() {
    
        let arrayId = database.call("json_store.create_json", {
            p_content: [
                "Hello, World!",
                123.321,
                "",
                {}
            ]
        });

        let indexOf = database.call3("json_core.index_of", {
            p_array_id: arrayId,
            p_value: null,
            p_from_index: 0
        });

        expect(indexOf).to.be(-1);
    
    });

    test("Locate null number, find", function() {
    
        let arrayId = database.call("json_store.create_json", {
            p_content: [
                "Hello, World!",
                null,
                123.321,
                "",
                {}
            ]
        });

        let indexOf = database.call3("json_core.index_of", {
            p_array_id: arrayId,
            p_value: null,
            p_from_index: 0
        });

        expect(indexOf).to.be(1);
    
    });

    test("Locate number, find", function() {
    
        let arrayId = database.call("json_store.create_json", {
            p_content: [
                "Hello, World!",
                "1992-04-07",
                123.321,
                "",
                "1992-04-07",
                {}
            ]
        });

        let indexOf = database.call3("json_core.index_of", {
            p_array_id: arrayId,
            p_value: 123.321,
            p_from_index: 0
        });

        expect(indexOf).to.be(2);
    
    });

    test("Locate second number, don't find", function() {
    
        let arrayId = database.call("json_store.create_json", {
            p_content: [
                "Hello, World!",
                "1992-04-07",
                123.321,
                "",
                "1992-04-07",
                {}
            ]
        });

        let indexOf = database.call3("json_core.index_of", {
            p_array_id: arrayId,
            p_value: 123.321,
            p_from_index: 3
        });

        expect(indexOf).to.be(-1);
    
    });

    test("Locate second number, find", function() {
    
        let arrayId = database.call("json_store.create_json", {
            p_content: [
                "Hello, World!",
                "1992-04-07",
                123.321,
                "",
                "1992-04-07",
                {},
                123.321
            ]
        });

        let indexOf = database.call3("json_core.index_of", {
            p_array_id: arrayId,
            p_value: 123.321,
            p_from_index: 3
        });

        expect(indexOf).to.be(6);
    
    });

    test("Try to call INDEX_OF BOOLEAN version with NULL array ID", function() {
    
        expect(function() {
        
            database.call4("json_core.index_of", {
                p_array_id: null,
                p_value: null,
                p_from_index: 0
            });
        
        }).to.throw(/JDOC-00031/);
    
    });
    
    test("Try to call INDEX_OF BOOLEAN version with non-existing array ID", function() {
    
        expect(function() {
        
            database.call4("json_core.index_of", {
                p_array_id: -1,
                p_value: null,
                p_from_index: 0
            });
        
        }).to.throw(/JDOC-00009/);
    
    });

    test("Try to call INDEX_OF BOOLEAN version with non-array ID", function() {
    
        let valueId = database.call("json_store.create_string", {
            p_value: "Hello, World!"
        });

        expect(function() {
        
            database.call4("json_core.index_of", {
                p_array_id: valueId,
                p_value: null,
                p_from_index: 0
            });
        
        }).to.throw(/JDOC-00012/);
    
    });

    test("Locate null boolean, don't find", function() {
    
        let arrayId = database.call("json_store.create_json", {
            p_content: [
                "Hello, World!",
                123.321,
                "",
                {}
            ]
        });

        let indexOf = database.call4("json_core.index_of", {
            p_array_id: arrayId,
            p_value: null,
            p_from_index: 0
        });

        expect(indexOf).to.be(-1);
    
    });

    test("Locate null boolean, find", function() {
    
        let arrayId = database.call("json_store.create_json", {
            p_content: [
                "Hello, World!",
                null,
                123.321,
                "",
                {}
            ]
        });

        let indexOf = database.call4("json_core.index_of", {
            p_array_id: arrayId,
            p_value: null,
            p_from_index: 0
        });

        expect(indexOf).to.be(1);
    
    });

    test("Locate boolean, find", function() {
    
        let arrayId = database.call("json_store.create_json", {
            p_content: [
                "Hello, World!",
                "1992-04-07",
                123.321,
                true,
                "1992-04-07",
                {}
            ]
        });

        let indexOf = database.call4("json_core.index_of", {
            p_array_id: arrayId,
            p_value: true,
            p_from_index: 0
        });

        expect(indexOf).to.be(3);
    
    });

    test("Locate second boolean, don't find", function() {
    
        let arrayId = database.call("json_store.create_json", {
            p_content: [
                "Hello, World!",
                "1992-04-07",
                true,
                "",
                "1992-04-07",
                {}
            ]
        });

        let indexOf = database.call4("json_core.index_of", {
            p_array_id: arrayId,
            p_value: true,
            p_from_index: 3
        });

        expect(indexOf).to.be(-1);
    
    });

    test("Locate second boolean, find", function() {
    
        let arrayId = database.call("json_store.create_json", {
            p_content: [
                "Hello, World!",
                "1992-04-07",
                true,
                "",
                "1992-04-07",
                {},
                true
            ]
        });

        let indexOf = database.call4("json_core.index_of", {
            p_array_id: arrayId,
            p_value: true,
            p_from_index: 3
        });

        expect(indexOf).to.be(6);
    
    });

    test("Try to call INDEX_OF_NULL with NULL array ID", function() {
    
        expect(function() {
        
            database.call("json_core.index_of_null", {
                p_array_id: null,
                p_from_index: 0
            });
        
        }).to.throw(/JDOC-00031/);
    
    });
    
    test("Try to call INDEX_OF_NULL with non-existing array ID", function() {
    
        expect(function() {
        
            database.call("json_core.index_of_null", {
                p_array_id: -1,
                p_from_index: 0
            });
        
        }).to.throw(/JDOC-00009/);
    
    });

    test("Try to call INDEX_OF_NULL with non-array ID", function() {
    
        let valueId = database.call("json_store.create_string", {
            p_value: "Hello, World!"
        });

        expect(function() {
        
            database.call("json_core.index_of_null", {
                p_array_id: valueId,
                p_from_index: 0
            });
        
        }).to.throw(/JDOC-00012/);
    
    });

    test("Locate null, don't find", function() {
    
        let arrayId = database.call("json_store.create_json", {
            p_content: [
                "Hello, World!",
                123.321,
                "",
                {}
            ]
        });

        let indexOf = database.call("json_core.index_of_null", {
            p_array_id: arrayId,
            p_from_index: 0
        });

        expect(indexOf).to.be(-1);
    
    });

    test("Locate null, find", function() {
    
        let arrayId = database.call("json_store.create_json", {
            p_content: [
                "Hello, World!",
                null,
                123.321,
                "",
                {}
            ]
        });

        let indexOf = database.call("json_core.index_of_null", {
            p_array_id: arrayId,
            p_from_index: 0
        });

        expect(indexOf).to.be(1);
    
    });


    test("Locate second null, don't find", function() {
    
        let arrayId = database.call("json_store.create_json", {
            p_content: [
                "Hello, World!",
                "1992-04-07",
                null,
                "",
                "1992-04-07",
                {}
            ]
        });

        let indexOf = database.call("json_core.index_of_null", {
            p_array_id: arrayId,
            p_from_index: 3
        });

        expect(indexOf).to.be(-1);
    
    });

    test("Locate second null, find", function() {
    
        let arrayId = database.call("json_store.create_json", {
            p_content: [
                "Hello, World!",
                "1992-04-07",
                null,
                "",
                "1992-04-07",
                {},
                null
            ]
        });

        let indexOf = database.call("json_core.index_of_null", {
            p_array_id: arrayId,
            p_from_index: 3
        });

        expect(indexOf).to.be(6);
    
    });

});