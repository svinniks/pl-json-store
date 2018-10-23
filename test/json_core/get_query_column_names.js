suite("Query column name retrieval", function() {

    test("No alias for a wildcard", function() {
    
        var elementI = database.call("json_core.parse_query", {
            p_query: "person.*"
        });

        expect(function() {
        
            var columnNames = database.call("json_core.get_query_column_names", {
                p_query_element_i: elementI
            });
        
        }).to.throw(/JDC-00023/);
    
    });

    test("Property name too long", function() {
    
        var elementI = database.call("json_core.parse_query", {
            p_query: "person(.name, .abcabcabcabcabcabcabcabcabcabcA)"
        });

        expect(function() {
        
            var columnNames = database.call("json_core.get_query_column_names", {
                p_query_element_i: elementI
            });
        
        }).to.throw(/JDC-00018/);
    
    });

    test("Duplicate porperty names", function() {
    
        var elementI = database.call("json_core.parse_query", {
            p_query: "person(.name, .name)"
        });

        expect(function() {
        
            var columnNames = database.call("json_core.get_query_column_names", {
                p_query_element_i: elementI
            });
        
        }).to.throw(/JDC-00016.*name/);
    
    });

    test("Duplicate aliases", function() {
    
        var elementI = database.call("json_core.parse_query", {
            p_query: "person(.name as forename, .name as forename)"
        });

        expect(function() {
        
            var columnNames = database.call("json_core.get_query_column_names", {
                p_query_element_i: elementI
            });
        
        }).to.throw(/JDC-00016/);
    
    });

    test("Duplicate property and alias", function() {
    
        var elementI = database.call("json_core.parse_query", {
            p_query: "person(.NAME, .surname as name)"
        });

        expect(function() {
        
            var columnNames = database.call("json_core.get_query_column_names", {
                p_query_element_i: elementI
            });
        
        }).to.throw(/JDC-00016/);
    
    });

    test("Duplicate variable and alias", function() {
    
        var elementI = database.call("json_core.parse_query", {
            p_query: 'person(.:a, .surname as a)'
        });

        expect(function() {
        
            var details = database.call("json_core.get_query_column_names", {
                p_query_element_i: elementI
            });
        
        }).to.throw(/JDC-00016/);
    
    });

    test("Duplicate ID variable and alias", function() {
    
        var elementI = database.call("json_core.parse_query", {
            p_query: 'person(.#a, .surname as a)'
        });

        expect(function() {
        
            var details = database.call("json_core.get_query_column_names", {
                p_query_element_i: elementI
            });
        
        }).to.throw(/JDC-00016/);
    
    });
    
    test("One simple property", function() {

        var elementI = database.call("json_core.parse_query", {
            p_query: "person"
        });

        var columnNames = database.call("json_core.get_query_column_names", {
            p_query_element_i: elementI
        });

        expect(columnNames).to.eql([
            "person"
        ]);

    });        

    test("One variable", function() {

        var elementI = database.call("json_core.parse_query", {
            p_query: ":var"
        });

        var columnNames = database.call("json_core.get_query_column_names", {
            p_query_element_i: elementI
        });

        expect(columnNames).to.eql([
            "VAR"
        ]);

    }); 

    test("One ID variable", function() {

        var elementI = database.call("json_core.parse_query", {
            p_query: "#var"
        });

        var columnNames = database.call("json_core.get_query_column_names", {
            p_query_element_i: elementI
        });

        expect(columnNames).to.eql([
            "VAR"
        ]);

    });

    test("One ID reference", function() {

        var elementI = database.call("json_core.parse_query", {
            p_query: "#123"
        });

        var columnNames = database.call("json_core.get_query_column_names", {
            p_query_element_i: elementI
        });

        expect(columnNames).to.eql([
            "123"
        ]);

    }); 

    test("One simple property with a case insensitive alias", function() {

        var elementI = database.call("json_core.parse_query", {
            p_query: "value as name"
        });

        var columnNames = database.call("json_core.get_query_column_names", {
            p_query_element_i: elementI
        });

        expect(columnNames).to.eql([
            "NAME"
        ]);

    }); 

    test("One simple property with a case sensitive alias", function() {

        var elementI = database.call("json_core.parse_query", {
            p_query: 'value as "name"'
        });

        var columnNames = database.call("json_core.get_query_column_names", {
            p_query_element_i: elementI
        });

        expect(columnNames).to.eql([
            "name"
        ]);

    }); 

    test("One wildcard with a case insesnsitive alias", function() {

        var elementI = database.call("json_core.parse_query", {
            p_query: '* as value'
        });

        var columnNames = database.call("json_core.get_query_column_names", {
            p_query_element_i: elementI
        });

        expect(columnNames).to.eql([
            "VALUE"
        ]);

    }); 

    test("Multiple simple names", function() {

        var elementI = database.call("json_core.parse_query", {
            p_query: 'person(.name, .surname, .address(.street))'
        });

        var columnNames = database.call("json_core.get_query_column_names", {
            p_query_element_i: elementI
        });

        expect(columnNames).to.eql([
            "name",
            "surname",
            "street"
        ]);

    }); 

    test("Combined column names", function() {

        var elementI = database.call("json_core.parse_query", {
            p_query: 'person(.name as forename, .surname as "family_name", .address(.street, .:var, .#44, .#id))'
        });

        var columnNames = database.call("json_core.get_query_column_names", {
            p_query_element_i: elementI
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

        var elementI = database.call("json_core.parse_query", {
            p_query: '(person.name, person.surname)'
        });

        var columnNames = database.call("json_core.get_query_column_names", {
            p_query_element_i: elementI
        });

        expect(columnNames).to.eql([
            "name",
            "surname"
        ]);

    }); 

});