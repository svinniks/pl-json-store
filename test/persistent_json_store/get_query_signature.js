suite("Query signature retrieval", function() {
    
    test("Single name", function() {
    
        var elementI = database.call("json_core.parse_query", {
            p_query: "person"
        });

        var signature = database.call("persistent_json_store.get_query_signature", {
            p_query_element_i: elementI
        }); 

        expect(signature).to.be('(N)');
    
    });
    
    test("Multiple property names", function() {
    
        var elementI = database.call("json_core.parse_query", {
            p_query: "person.address.street"
        });

        var signature = database.call("persistent_json_store.get_query_signature", {
            p_query_element_i: elementI
        }); 

        expect(signature).to.be('(N(N(N)))');
    
    });

    test("Single ID reference", function() {
    
        var elementI = database.call("json_core.parse_query", {
            p_query: "#123"
        });

        var signature = database.call("persistent_json_store.get_query_signature", {
            p_query_element_i: elementI
        }); 

        expect(signature).to.be('(I)');
    
    });

    test("Single wildcard", function() {
    
        var elementI = database.call("json_core.parse_query", {
            p_query: "*"
        });

        var signature = database.call("persistent_json_store.get_query_signature", {
            p_query_element_i: elementI
        }); 

        expect(signature).to.be('(W)');
    
    });

    test("Single variable", function() {
    
        var elementI = database.call("json_core.parse_query", {
            p_query: ":var1"
        });

        var signature = database.call("persistent_json_store.get_query_signature", {
            p_query_element_i: elementI
        }); 

        expect(signature).to.be('(:)');
    
    });

    test("Single ID variable", function() {
    
        var elementI = database.call("json_core.parse_query", {
            p_query: "#var1"
        });

        var signature = database.call("persistent_json_store.get_query_signature", {
            p_query_element_i: elementI
        }); 

        expect(signature).to.be('(#)');
    
    });

    test("Complex child property chain", function() {
    
        var elementI = database.call("json_core.parse_query", {
            p_query: "person.:var1.#123.*.#id"
        });

        var signature = database.call("persistent_json_store.get_query_signature", {
            p_query_element_i: elementI
        }); 

        expect(signature).to.be('(N(:(I(W(#)))))');
    
    });

    test("Optional name", function() {
    
        var elementI = database.call("json_core.parse_query", {
            p_query: "person.name?"
        });

        var signature = database.call("persistent_json_store.get_query_signature", {
            p_query_element_i: elementI
        }); 

        expect(signature).to.be('(N(N?))');
    
    });

    test("Branched names", function() {
    
        var elementI = database.call("json_core.parse_query", {
            p_query: "person(.name, .surname)"
        });

        var signature = database.call("persistent_json_store.get_query_signature", {
            p_query_element_i: elementI
        }); 

        expect(signature).to.be('(N(NN))');
    
    });

    test("Reserved fields", function() {
    
        var elementI = database.call("json_core.parse_query", {
            p_query: "person(._id, ._key, ._value)"
        });

        var signature = database.call("persistent_json_store.get_query_signature", {
            p_query_element_i: elementI
        }); 

        expect(signature).to.be('(N(ikv))');
    
    });

    test("Complex branched query", function() {
    
        var elementI = database.call("json_core.parse_query", {
            p_query: "$.person(.name, .:var1, .address?(.*.#id), .surname)",
            p_anchored: true
        });

        var signature = database.call("persistent_json_store.get_query_signature", {
            p_query_element_i: elementI
        }); 

        expect(signature).to.be('(A(R(N(N:N?(W(#))N))))');
    
    });

});