const VALUE_QUERY = 'V';
const PROPERTY_QUERY = 'P';
const VALUE_TABLE_QUERY = 'T';
const X_VALUE_TABLE_QUERY = 'X';

suite("Query column name retrieval", function() {

    test("No alias for a wildcard", function() {
    
        var elements = database.call("json_core.parse_query", {
            p_query: "person.*"
        });

        expect(function() {
        
            var columnNames = database.call("json_core.get_query_column_names", {
                p_query_elements: elements
            });
        
        }).to.throw(/JDOC-00023/);
    
    });

    test("Property name too long", function() {
    
        var elements = database.call("json_core.parse_query", {
            p_query: "person(.name, .abcabcabcabcabcabcabcabcabcabcA)"
        });

        expect(function() {
        
            var columnNames = database.call("json_core.get_query_column_names", {
                p_query_elements: elements
            });
        
        }).to.throw(/JDOC-00018/);
    
    });

    test("Duplicate porperty names", function() {
    
        var elements = database.call("json_core.parse_query", {
            p_query: "person(.name, .name)"
        });

        expect(function() {
        
            var columnNames = database.call("json_core.get_query_column_names", {
                p_query_elements: elements
            });
        
        }).to.throw(/JDOC-00016.*name/);
    
    });

    test("Duplicate aliases", function() {
    
        var elements = database.call("json_core.parse_query", {
            p_query: "person(.name as forename, .name as forename)"
        });

        expect(function() {
        
            var columnNames = database.call("json_core.get_query_column_names", {
                p_query_elements: elements
            });
        
        }).to.throw(/JDOC-00016/);
    
    });

    test("Duplicate property and alias", function() {
    
        var elements = database.call("json_core.parse_query", {
            p_query: "person(.NAME, .surname as name)"
        });

        expect(function() {
        
            var columnNames = database.call("json_core.get_query_column_names", {
                p_query_elements: elements
            });
        
        }).to.throw(/JDOC-00016/);
    
    });

    test("Duplicate variable and alias", function() {
    
        var elements = database.call("json_core.parse_query", {
            p_query: 'person(.:a, .surname as a)'
        });

        expect(function() {
        
            var details = database.call("json_core.get_query_column_names", {
                p_query_elements: elements
            });
        
        }).to.throw(/JDOC-00016/);
    
    });

    test("Duplicate ID variable and alias", function() {
    
        var elements = database.call("json_core.parse_query", {
            p_query: 'person(.#a, .surname as a)'
        });

        expect(function() {
        
            var details = database.call("json_core.get_query_column_names", {
                p_query_elements: elements
            });
        
        }).to.throw(/JDOC-00016/);
    
    });
    
    test("One simple property", function() {

        var elements = database.call("json_core.parse_query", {
            p_query: "person"
        });

        var columnNames = database.call("json_core.get_query_column_names", {
            p_query_elements: elements
        });

        expect(columnNames).to.eql([
            "person"
        ]);

    });        

    test("One variable", function() {

        var elements = database.call("json_core.parse_query", {
            p_query: ":var"
        });

        var columnNames = database.call("json_core.get_query_column_names", {
            p_query_elements: elements
        });

        expect(columnNames).to.eql([
            "VAR"
        ]);

    }); 

    test("One ID variable", function() {

        var elements = database.call("json_core.parse_query", {
            p_query: "#var"
        });

        var columnNames = database.call("json_core.get_query_column_names", {
            p_query_elements: elements
        });

        expect(columnNames).to.eql([
            "VAR"
        ]);

    });

    test("One ID reference", function() {

        var elements = database.call("json_core.parse_query", {
            p_query: "#123"
        });

        var columnNames = database.call("json_core.get_query_column_names", {
            p_query_elements: elements
        });

        expect(columnNames).to.eql([
            "123"
        ]);

    }); 

    test("One simple property with a case insensitive alias", function() {

        var elements = database.call("json_core.parse_query", {
            p_query: "value as name"
        });

        var columnNames = database.call("json_core.get_query_column_names", {
            p_query_elements: elements
        });

        expect(columnNames).to.eql([
            "NAME"
        ]);

    }); 

    test("One simple property with a case sensitive alias", function() {

        var elements = database.call("json_core.parse_query", {
            p_query: 'value as "name"'
        });

        var columnNames = database.call("json_core.get_query_column_names", {
            p_query_elements: elements
        });

        expect(columnNames).to.eql([
            "name"
        ]);

    }); 

    test("One wildcard with a case insesnsitive alias", function() {

        var elements = database.call("json_core.parse_query", {
            p_query: '* as value'
        });

        var columnNames = database.call("json_core.get_query_column_names", {
            p_query_elements: elements
        });

        expect(columnNames).to.eql([
            "VALUE"
        ]);

    }); 

    test("Multiple simple names", function() {

        var elements = database.call("json_core.parse_query", {
            p_query: 'person(.name, .surname, .address(.street))'
        });

        var columnNames = database.call("json_core.get_query_column_names", {
            p_query_elements: elements
        });

        expect(columnNames).to.eql([
            "name",
            "surname",
            "street"
        ]);

    }); 

    test("Combined column names", function() {

        var elements = database.call("json_core.parse_query", {
            p_query: 'person(.name as forename, .surname as "family_name", .address(.street, .:var, .#44, .#id))'
        });

        var columnNames = database.call("json_core.get_query_column_names", {
            p_query_elements: elements
        });

        expect(columnNames).to.eql([
            "FORENAME",
            "family_name",
            "street",
            "VAR",
            "44",
            "ID"
        ]);

    }); 

    test("Branching root columns", function() {

        var elements = database.call("json_core.parse_query", {
            p_query: '(person.name, person.surname)'
        });

        var columnNames = database.call("json_core.get_query_column_names", {
            p_query_elements: elements
        });

        expect(columnNames).to.eql([
            "name",
            "surname"
        ]);

    }); 

});

suite("Query variable bind number retrieval", function() {

    test("Single variable", function() {

        var elements = database.call("json_core.parse_query", {
            p_query: ':name'
        });

        var bindNumbers = database.call("json_core.get_query_bind_numbers", {
            p_query_elements: elements
        });

        expect(bindNumbers).to.eql([1]);

    }); 

    test("Single ID variable", function() {

        var elements = database.call("json_core.parse_query", {
            p_query: 'person(.#id)'
        });

        var bindNumbers = database.call("json_core.get_query_bind_numbers", {
            p_query_elements: elements
        });

        expect(bindNumbers).to.eql([1]);

    }); 

    test("Multiple different variables", function() {

        var elements = database.call("json_core.parse_query", {
            p_query: ':name.:surname.:address'
        });

        var bindNumbers = database.call("json_core.get_query_bind_numbers", {
            p_query_elements: elements
        });

        expect(bindNumbers).to.eql([1, 2, 3]);

    }); 

    test("Two equal variables", function() {

        var elements = database.call("json_core.parse_query", {
            p_query: ':name.:name'
        });

        var bindNumbers = database.call("json_core.get_query_bind_numbers", {
            p_query_elements: elements
        });

        expect(bindNumbers).to.eql([1, 1]);

    });

    test("Two equal, one different variables", function() {

        var elements = database.call("json_core.parse_query", {
            p_query: ':name.:name.:surname'
        });

        var bindNumbers = database.call("json_core.get_query_bind_numbers", {
            p_query_elements: elements
        });

        expect(bindNumbers).to.eql([1, 1, 2]);

    });

    test("Two pairs of equal variables", function() {

        var elements = database.call("json_core.parse_query", {
            p_query: ':name.:surname.:name.:surname'
        });

        var bindNumbers = database.call("json_core.get_query_bind_numbers", {
            p_query_elements: elements
        });

        expect(bindNumbers).to.eql([1, 2, 1, 2]);

    });

    test("Multiple different ID variables", function() {

        var elements = database.call("json_core.parse_query", {
            p_query: '#name.#surname.#address'
        });

        var bindNumbers = database.call("json_core.get_query_bind_numbers", {
            p_query_elements: elements
        });

        expect(bindNumbers).to.eql([1, 2, 3]);

    }); 

    test("Two equal ID variables", function() {

        var elements = database.call("json_core.parse_query", {
            p_query: '#name.#name'
        });

        var bindNumbers = database.call("json_core.get_query_bind_numbers", {
            p_query_elements: elements
        });

        expect(bindNumbers).to.eql([1, 1]);

    });

    test("Two equal, one different ID variables", function() {

        var elements = database.call("json_core.parse_query", {
            p_query: '#name.#name.#surname'
        });

        var bindNumbers = database.call("json_core.get_query_bind_numbers", {
            p_query_elements: elements
        });

        expect(bindNumbers).to.eql([1, 1, 2]);

    });

    test("Two pairs of equal ID variables", function() {

        var elements = database.call("json_core.parse_query", {
            p_query: '#name.#surname.#name.#surname'
        });

        var bindNumbers = database.call("json_core.get_query_bind_numbers", {
            p_query_elements: elements
        });

        expect(bindNumbers).to.eql([1, 2, 1, 2]);

    });

    test("Complex example with multiple variables", function() {

        var elements = database.call("json_core.parse_query", {
            p_query: '($.#id.a(.b,.:c),:a.b(.:c.d.#c,.:id))'
        });

        var bindNumbers = database.call("json_core.get_query_bind_numbers", {
            p_query_elements: elements
        });

        expect(bindNumbers).to.eql([1, 2, 3, 2, 2, 1]);

    });

});

suite("Query signature retrieval", function() {
    
    test("Single name", function() {
    
        var elements = database.call("json_core.parse_query", {
            p_query: "person"
        });

        var signature = database.call("json_core.get_query_signature", {
            p_query_elements: elements
        }); 

        expect(signature).to.be('(N)');
    
    });
    
    test("Multiple property names", function() {
    
        var elements = database.call("json_core.parse_query", {
            p_query: "person.address.street"
        });

        var signature = database.call("json_core.get_query_signature", {
            p_query_elements: elements
        }); 

        expect(signature).to.be('(N(N(N)))');
    
    });

    test("Single ID reference", function() {
    
        var elements = database.call("json_core.parse_query", {
            p_query: "#123"
        });

        var signature = database.call("json_core.get_query_signature", {
            p_query_elements: elements
        }); 

        expect(signature).to.be('(I)');
    
    });

    test("Single wildcard", function() {
    
        var elements = database.call("json_core.parse_query", {
            p_query: "*"
        });

        var signature = database.call("json_core.get_query_signature", {
            p_query_elements: elements
        }); 

        expect(signature).to.be('(W)');
    
    });

    test("Single variable", function() {
    
        var elements = database.call("json_core.parse_query", {
            p_query: ":var1"
        });

        var signature = database.call("json_core.get_query_signature", {
            p_query_elements: elements
        }); 

        expect(signature).to.be('(V)');
    
    });

    test("Single ID variable", function() {
    
        var elements = database.call("json_core.parse_query", {
            p_query: "#var1"
        });

        var signature = database.call("json_core.get_query_signature", {
            p_query_elements: elements
        }); 

        expect(signature).to.be('(A)');
    
    });

    test("Complex child property chain", function() {
    
        var elements = database.call("json_core.parse_query", {
            p_query: "person.:var1.#123.*.#id"
        });

        var signature = database.call("json_core.get_query_signature", {
            p_query_elements: elements
        }); 

        expect(signature).to.be('(N(V(I(W(A)))))');
    
    });

    test("Optional name", function() {
    
        var elements = database.call("json_core.parse_query", {
            p_query: "person.name?"
        });

        var signature = database.call("json_core.get_query_signature", {
            p_query_elements: elements
        }); 

        expect(signature).to.be('(N(N?))');
    
    });

    test("Branched names", function() {
    
        var elements = database.call("json_core.parse_query", {
            p_query: "person(.name, .surname)"
        });

        var signature = database.call("json_core.get_query_signature", {
            p_query_elements: elements
        }); 

        expect(signature).to.be('(N(NN))');
    
    });

    test("Reserved fields", function() {
    
        var elements = database.call("json_core.parse_query", {
            p_query: "person(._id, ._key, ._value)"
        });

        var signature = database.call("json_core.get_query_signature", {
            p_query_elements: elements
        }); 

        expect(signature).to.be('(N(ikv))');
    
    });

    test("Complex branched query", function() {
    
        var elements = database.call("json_core.parse_query", {
            p_query: "person(.name, .:var1, .address?(.*.#id), .surname)"
        });

        var signature = database.call("json_core.get_query_signature", {
            p_query_elements: elements
        }); 

        expect(signature).to.be('(N(NVN?(W(A))N))');
    
    });

});

suite("Query constant retrieval", function() {

    test("Query without constants", function() {

        let elements = database.call("json_core.parse_query", {
            p_query: "#id.:name1[:name2]"
        });

        let values = database.call("json_core.get_query_constants", {
            p_query_elements: elements
        });

        expect(values).to.eql([]);

    });

    test("Query with constant", function() {

        let elements = database.call("json_core.parse_query", {
            p_query: "$.person.#123"
        });

        let values = database.call("json_core.get_query_constants", {
            p_query_elements: elements
        });

        expect(values).to.eql(["0", "person", "123"]);

    });

});