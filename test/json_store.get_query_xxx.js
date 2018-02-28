suite("Query column name retrieval", function() {

    test("No alias for a wildcard", function() {
    
        var elements = database.call("json_store.parse_query", {
            p_query: "person.*"
        });

        expect(function() {
        
            var columnNames = database.call("json_store.get_query_column_names", {
                p_query_elements: elements
            });
        
        }).to.throw(/JDOC-00023/);
    
    });

    test("Property name too long", function() {
    
        var elements = database.call("json_store.parse_query", {
            p_query: "person(.name, .abcabcabcabcabcabcabcabcabcabcA)"
        });

        expect(function() {
        
            var columnNames = database.call("json_store.get_query_column_names", {
                p_query_elements: elements
            });
        
        }).to.throw(/JDOC-00018/);
    
    });

    test("Duplicate porperty names", function() {
    
        var elements = database.call("json_store.parse_query", {
            p_query: "person(.name, .name)"
        });

        expect(function() {
        
            var columnNames = database.call("json_store.get_query_column_names", {
                p_query_elements: elements
            });
        
        }).to.throw(/JDOC-00016/);
    
    });

    test("Duplicate aliases", function() {
    
        var elements = database.call("json_store.parse_query", {
            p_query: "person(.name as forename, .name as forename)"
        });

        expect(function() {
        
            var columnNames = database.call("json_store.get_query_column_names", {
                p_query_elements: elements
            });
        
        }).to.throw(/JDOC-00016/);
    
    });

    test("Duplicate property and alias", function() {
    
        var elements = database.call("json_store.parse_query", {
            p_query: "person(.NAME, .surname as name)"
        });

        expect(function() {
        
            var columnNames = database.call("json_store.get_query_column_names", {
                p_query_elements: elements
            });
        
        }).to.throw(/JDOC-00016/);
    
    });

    test("Duplicate variable and alias", function() {
    
        var elements = database.call("json_store.parse_query", {
            p_query: 'person(.:2, .surname as ":2")'
        });

        expect(function() {
        
            var details = database.call("json_store.get_query_column_names", {
                p_query_elements: elements
            });
        
        }).to.throw(/JDOC-00016/);
    
    });
    
    test("One simple property", function() {

        var elements = database.call("json_store.parse_query", {
            p_query: "person"
        });

        var columnNames = database.call("json_store.get_query_column_names", {
            p_query_elements: elements
        });

        expect(columnNames).to.eql([
            "person"
        ]);

    });        

    test("One variable", function() {

        var elements = database.call("json_store.parse_query", {
            p_query: ":15"
        });

        var columnNames = database.call("json_store.get_query_column_names", {
            p_query_elements: elements
        });

        expect(columnNames).to.eql([
            ":15"
        ]);

    }); 

    test("One ID reference", function() {

        var elements = database.call("json_store.parse_query", {
            p_query: "#123"
        });

        var columnNames = database.call("json_store.get_query_column_names", {
            p_query_elements: elements
        });

        expect(columnNames).to.eql([
            "#123"
        ]);

    }); 

    test("One simple property with a case insensitive alias", function() {

        var elements = database.call("json_store.parse_query", {
            p_query: "value as name"
        });

        var columnNames = database.call("json_store.get_query_column_names", {
            p_query_elements: elements
        });

        expect(columnNames).to.eql([
            "NAME"
        ]);

    }); 

    test("One simple property with a case sensitive alias", function() {

        var elements = database.call("json_store.parse_query", {
            p_query: 'value as "name"'
        });

        var columnNames = database.call("json_store.get_query_column_names", {
            p_query_elements: elements
        });

        expect(columnNames).to.eql([
            "name"
        ]);

    }); 

    test("One wildcard with a case insesnsitive alias", function() {

        var elements = database.call("json_store.parse_query", {
            p_query: '* as value'
        });

        var columnNames = database.call("json_store.get_query_column_names", {
            p_query_elements: elements
        });

        expect(columnNames).to.eql([
            "VALUE"
        ]);

    }); 

    test("Multiple simple names", function() {

        var elements = database.call("json_store.parse_query", {
            p_query: 'person(.name, .surname, .address(.street))'
        });

        var columnNames = database.call("json_store.get_query_column_names", {
            p_query_elements: elements
        });

        expect(columnNames).to.eql([
            "name",
            "surname",
            "street"
        ]);

    }); 

    test("Combined column names", function() {

        var elements = database.call("json_store.parse_query", {
            p_query: 'person(.name as forename, .surname as "family_name", .address(.street, .:3, .#44))'
        });

        var columnNames = database.call("json_store.get_query_column_names", {
            p_query_elements: elements
        });

        expect(columnNames).to.eql([
            "FORENAME",
            "family_name",
            "street",
            ":3",
            "#44"
        ]);

    }); 

    test("Branching root columns", function() {

        var elements = database.call("json_store.parse_query", {
            p_query: '(person.name, person.surname)'
        });

        var columnNames = database.call("json_store.get_query_column_names", {
            p_query_elements: elements
        });

        expect(columnNames).to.eql([
            "name",
            "surname"
        ]);

    }); 

});

suite("QUery variable name retrieval", function() {

    test("Multiple different variables", function() {

        var elements = database.call("json_store.parse_query", {
            p_query: 'person(.:1, .:2(.:3))'
        });

        var variableNames = database.call("json_store.get_query_variable_names", {
            p_query_elements: elements
        });

        expect(variableNames).to.eql([
            "1",
            "2",
            "3"
        ]);

    }); 

    test("Multiple repeating variables", function() {

        var elements = database.call("json_store.parse_query", {
            p_query: 'person(.:1, .:2(.:1 as value), .:2)'
        });

        var variableNames = database.call("json_store.get_query_variable_names", {
            p_query_elements: elements
        });

        expect(variableNames).to.eql([
            "1",
            "2"
        ]);

    }); 

});

suite("Query signature retrieval", function() {
    
    test("Single name", function() {
    
        var elements = database.call("json_store.parse_query", {
            p_query: "person"
        });

        var signature = database.call("json_store.get_query_signature", {
            p_query_elements: elements
        }); 

        expect(signature).to.be('(N)');
    
    });
    
    test("Multiple property names", function() {
    
        var elements = database.call("json_store.parse_query", {
            p_query: "person.address.street"
        });

        var signature = database.call("json_store.get_query_signature", {
            p_query_elements: elements
        }); 

        expect(signature).to.be('(N(N(N)))');
    
    });

    test("Single ID reference", function() {
    
        var elements = database.call("json_store.parse_query", {
            p_query: "#123"
        });

        var signature = database.call("json_store.get_query_signature", {
            p_query_elements: elements
        }); 

        expect(signature).to.be('(I)');
    
    });

    test("Single wildcard", function() {
    
        var elements = database.call("json_store.parse_query", {
            p_query: "*"
        });

        var signature = database.call("json_store.get_query_signature", {
            p_query_elements: elements
        }); 

        expect(signature).to.be('(W)');
    
    });

    test("Single variable", function() {
    
        var elements = database.call("json_store.parse_query", {
            p_query: ":12"
        });

        var signature = database.call("json_store.get_query_signature", {
            p_query_elements: elements
        }); 

        expect(signature).to.be('(V)');
    
    });

    test("Complex child property chain", function() {
    
        var elements = database.call("json_store.parse_query", {
            p_query: "person.:2.#123.*"
        });

        var signature = database.call("json_store.get_query_signature", {
            p_query_elements: elements
        }); 

        expect(signature).to.be('(N(V(I(W))))');
    
    });

    test("Single optional name", function() {
    
        var elements = database.call("json_store.parse_query", {
            p_query: "person?"
        });

        var signature = database.call("json_store.get_query_signature", {
            p_query_elements: elements
        }); 

        expect(signature).to.be('(N?)');
    
    });

    test("Branched names", function() {
    
        var elements = database.call("json_store.parse_query", {
            p_query: "person(.name, .surname)"
        });

        var signature = database.call("json_store.get_query_signature", {
            p_query_elements: elements
        }); 

        expect(signature).to.be('(N(NN))');
    
    });

    test("Complex branched query", function() {
    
        var elements = database.call("json_store.parse_query", {
            p_query: "person(.name, .:1, .address?(.*), .surname)"
        });

        var signature = database.call("json_store.get_query_signature", {
            p_query_elements: elements
        }); 

        expect(signature).to.be('(N(NVN?(W)N))');
    
    });

});