suite("Query detail retrieval tests", function() {

    suite("Negative tests", function() {
    
        test("No alias for a wildcard", function() {
        
            var elements = database.call("json_store.parse_query", {
                p_query: "person.*"
            });

            expect(function() {
            
                var details = database.call("json_store.get_query_details", {
                    p_query_elements: elements,
                    p_column_names: null,
                    p_variable_names: null
                });
            
            }).to.throw(/JDOC-00023/);
        
        });

        test("Property name too long", function() {
        
            var elements = database.call("json_store.parse_query", {
                p_query: "person(.name, .abcabcabcabcabcabcabcabcabcabcA)"
            });

            expect(function() {
            
                var details = database.call("json_store.get_query_details", {
                    p_query_elements: elements,
                    p_column_names: null,
                    p_variable_names: null
                });
            
            }).to.throw(/JDOC-00018/);
        
        });

        test("Duplicate porperty names", function() {
        
            var elements = database.call("json_store.parse_query", {
                p_query: "person(.name, .name)"
            });

            expect(function() {
            
                var details = database.call("json_store.get_query_details", {
                    p_query_elements: elements,
                    p_column_names: null,
                    p_variable_names: null
                });
            
            }).to.throw(/JDOC-00016/);
        
        });

        test("Duplicate aliases", function() {
        
            var elements = database.call("json_store.parse_query", {
                p_query: "person(.name as forename, .name as forename)"
            });

            expect(function() {
            
                var details = database.call("json_store.get_query_details", {
                    p_query_elements: elements,
                    p_column_names: null,
                    p_variable_names: null
                });
            
            }).to.throw(/JDOC-00016/);
        
        });

        test("Duplicate property and alias", function() {
        
            var elements = database.call("json_store.parse_query", {
                p_query: "person(.NAME, .suename as name)"
            });

            expect(function() {
            
                var details = database.call("json_store.get_query_details", {
                    p_query_elements: elements,
                    p_column_names: null,
                    p_variable_names: null
                });
            
            }).to.throw(/JDOC-00016/);
        
        });

        test("Duplicate variable and alias", function() {
        
            var elements = database.call("json_store.parse_query", {
                p_query: 'person(.:2, .surname as ":2")'
            });

            expect(function() {
            
                var details = database.call("json_store.get_query_details", {
                    p_query_elements: elements,
                    p_column_names: null,
                    p_variable_names: null
                });
            
            }).to.throw(/JDOC-00016/);
        
        });
        
    });

    suite("Positive tests", function() {
    
        test("One simple property", function() {

            var elements = database.call("json_store.parse_query", {
                p_query: "person"
            });
    
            var details = database.call("json_store.get_query_details", {
                p_query_elements: elements,
                p_column_names: null,
                p_variable_names: null
            });
    
            expect(details.p_column_names).to.eql([
                "person"
            ]);
    
            expect(details.p_variable_names).to.eql([
            ]);
    
        });        

        test("One variable", function() {

            var elements = database.call("json_store.parse_query", {
                p_query: ":15"
            });
    
            var details = database.call("json_store.get_query_details", {
                p_query_elements: elements,
                p_column_names: null,
                p_variable_names: null
            });
    
            expect(details.p_column_names).to.eql([
                ":15"
            ]);
    
            expect(details.p_variable_names).to.eql([
                "15"
            ]);
    
        }); 

        test("One ID reference", function() {

            var elements = database.call("json_store.parse_query", {
                p_query: "#123"
            });
    
            var details = database.call("json_store.get_query_details", {
                p_query_elements: elements,
                p_column_names: null,
                p_variable_names: null
            });
    
            expect(details.p_column_names).to.eql([
                "#123"
            ]);
    
            expect(details.p_variable_names).to.eql([
            ]);
    
        }); 

        test("One simple property with a case insensitive alias", function() {

            var elements = database.call("json_store.parse_query", {
                p_query: "value as name"
            });
    
            var details = database.call("json_store.get_query_details", {
                p_query_elements: elements,
                p_column_names: null,
                p_variable_names: null
            });
    
            expect(details.p_column_names).to.eql([
                "NAME"
            ]);
    
            expect(details.p_variable_names).to.eql([
            ]);
    
        }); 

        test("One simple property with a case sensitive alias", function() {

            var elements = database.call("json_store.parse_query", {
                p_query: 'value as "name"'
            });
    
            var details = database.call("json_store.get_query_details", {
                p_query_elements: elements,
                p_column_names: null,
                p_variable_names: null
            });
    
            expect(details.p_column_names).to.eql([
                "name"
            ]);
    
            expect(details.p_variable_names).to.eql([
            ]);
    
        }); 

        test("One wildcard with a case insesnsitive alias", function() {

            var elements = database.call("json_store.parse_query", {
                p_query: '* as value'
            });
    
            var details = database.call("json_store.get_query_details", {
                p_query_elements: elements,
                p_column_names: null,
                p_variable_names: null
            });
    
            expect(details.p_column_names).to.eql([
                "VALUE"
            ]);
    
            expect(details.p_variable_names).to.eql([
            ]);
    
        }); 

        test("Multiple simple names", function() {

            var elements = database.call("json_store.parse_query", {
                p_query: 'person(.name, .surname, .address(.street))'
            });
    
            var details = database.call("json_store.get_query_details", {
                p_query_elements: elements,
                p_column_names: null,
                p_variable_names: null
            });
    
            expect(details.p_column_names).to.eql([
                "name",
                "surname",
                "street"
            ]);
    
            expect(details.p_variable_names).to.eql([
            ]);
    
        }); 

        test("Combined column names", function() {

            var elements = database.call("json_store.parse_query", {
                p_query: 'person(.name as forename, .surname as "family_name", .address(.street, .:3, .#44))'
            });
    
            var details = database.call("json_store.get_query_details", {
                p_query_elements: elements,
                p_column_names: null,
                p_variable_names: null
            });
    
            expect(details.p_column_names).to.eql([
                "FORENAME",
                "family_name",
                "street",
                ":3",
                "#44"
            ]);
    
            expect(details.p_variable_names).to.eql([
                "3"
            ]);
    
        }); 

        test("Branching root columns", function() {

            var elements = database.call("json_store.parse_query", {
                p_query: '(person.name, person.surname)'
            });
    
            var details = database.call("json_store.get_query_details", {
                p_query_elements: elements,
                p_column_names: null,
                p_variable_names: null
            });
    
            expect(details.p_column_names).to.eql([
                "name",
                "surname"
            ]);
    
            expect(details.p_variable_names).to.eql([
            ]);
    
        }); 

        test("Multiple different variables", function() {

            var elements = database.call("json_store.parse_query", {
                p_query: 'person(.:1, .:2(.:3))'
            });
    
            var details = database.call("json_store.get_query_details", {
                p_query_elements: elements,
                p_column_names: null,
                p_variable_names: null
            });
    
            expect(details.p_column_names).to.eql([
                ":1",
                ":3"
            ]);
    
            expect(details.p_variable_names).to.eql([
                "1",
                "2",
                "3"
            ]);
    
        }); 

        test("Multiple repeating variables", function() {

            var elements = database.call("json_store.parse_query", {
                p_query: 'person(.:1, .:2(.:1 as value), .:2)'
            });
    
            var details = database.call("json_store.get_query_details", {
                p_query_elements: elements,
                p_column_names: null,
                p_variable_names: null
            });
    
            expect(details.p_column_names).to.eql([
                ":1",
                "VALUE",
                ":2"
            ]);
    
            expect(details.p_variable_names).to.eql([
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

});