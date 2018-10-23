/*
suite("Invalid query tests", function() {

    suite("Unexpected end of the input", function() {
    
        test("Empty query", function() {
            
            expect(function() {
            
                var elements = database.call("json_core.parse_query", {
                    p_query: null
                });
            
            }).to.throw(/JDC-00002/);

        });

        test("Empty query, spaces only", function() {
            
            expect(function() {
            
                var elements = database.call("json_core.parse_query", {
                    p_query: "   "
                });
            
            }).to.throw(/JDC-00002/);

        });

        test("Query ends with a dot", function() {
            
            expect(function() {
            
                var elements = database.call("json_core.parse_query", {
                    p_query: "person."
                });
            
            }).to.throw(/JDC-00002/);

        });        

        test("Query ends with a dot with spaces", function() {
            
            expect(function() {
            
                var elements = database.call("json_core.parse_query", {
                    p_query: "person.  "
                });
            
            }).to.throw(/JDC-00002/);

        }); 

        test("Query ends with [", function() {
            
            expect(function() {
            
                var elements = database.call("json_core.parse_query", {
                    p_query: "person["
                });
            
            }).to.throw(/JDC-00002/);

        }); 

        test("Query ends with [ and spaces", function() {
            
            expect(function() {
            
                var elements = database.call("json_core.parse_query", {
                    p_query: "person[   "
                });
            
            }).to.throw(/JDC-00002/);

        }); 

        test("Incomplete quoted property", function() {
            
            expect(function() {
            
                var elements = database.call("json_core.parse_query", {
                    p_query: 'person["name'
                });
            
            }).to.throw(/JDC-00002/);

        }); 

        test("Array element closing bracket ] missing", function() {
            
            expect(function() {
            
                var elements = database.call("json_core.parse_query", {
                    p_query: 'person[123'
                });
            
            }).to.throw(/JDC-00002/);

        }); 

        test("Array element closing bracket ] missing, spaces in the end", function() {
            
            expect(function() {
            
                var elements = database.call("json_core.parse_query", {
                    p_query: 'person[123   '
                });
            
            }).to.throw(/JDC-00002/);

        }); 

        test("Quoted property closing bracket ] missing", function() {
            
            expect(function() {
            
                var elements = database.call("json_core.parse_query", {
                    p_query: 'person["name"'
                });
            
            }).to.throw(/JDC-00002/);

        }); 

        test("Quoted property closing bracket ] missing, spaces in the end", function() {
            
            expect(function() {
            
                var elements = database.call("json_core.parse_query", {
                    p_query: 'person["name"   '
                });
            
            }).to.throw(/JDC-00002/);

        }); 

        test("Branched query ends with ,", function() {
            
            expect(function() {
            
                var elements = database.call("json_core.parse_query", {
                    p_query: 'person(.name,'
                });
            
            }).to.throw(/JDC-00002/);

        }); 

        test("Branched query ends with , and spaces", function() {
            
            expect(function() {
            
                var elements = database.call("json_core.parse_query", {
                    p_query: 'person(.name,   '
                });
            
            }).to.throw(/JDC-00002/);

        }); 

        test("Branch closing bracket missing", function() {
            
            expect(function() {
            
                var elements = database.call("json_core.parse_query", {
                    p_query: 'person(.name'
                });
            
            }).to.throw(/JDC-00002/);

        }); 

        test("Branch closing bracket missing, spaces in the end", function() {
            
            expect(function() {
            
                var elements = database.call("json_core.parse_query", {
                    p_query: 'person(.name   '
                });
            
            }).to.throw(/JDC-00002/);

        }); 

        test("Query ends with (", function() {
            
            expect(function() {
            
                var elements = database.call("json_core.parse_query", {
                    p_query: 'person('
                });
            
            }).to.throw(/JDC-00002/);

        }); 

        test("Query ends with ( and spaces", function() {
            
            expect(function() {
            
                var elements = database.call("json_core.parse_query", {
                    p_query: 'person(   '
                });
            
            }).to.throw(/JDC-00002/);

        }); 

        test("Query ends with #", function() {
            
            expect(function() {
            
                var elements = database.call("json_core.parse_query", {
                    p_query: '#'
                });
            
            }).to.throw(/JDC-00002/);

        }); 

        test("Query ends with :", function() {
            
            expect(function() {
            
                var elements = database.call("json_core.parse_query", {
                    p_query: '#'
                });
            
            }).to.throw(/JDC-00002/);

        }); 

        test('Query ends with "as"', function() {
            
            expect(function() {
            
                var elements = database.call("json_core.parse_query", {
                    p_query: 'person.name as'
                });
            
            }).to.throw(/JDC-00002/);

        }); 

        test('Query ends with "as" and spaces', function() {
            
            expect(function() {
            
                var elements = database.call("json_core.parse_query", {
                    p_query: 'person.name as   '
                });
            
            }).to.throw(/JDC-00002/);

        }); 

        test("Incomplete quoted alias", function() {
            
            expect(function() {
            
                var elements = database.call("json_core.parse_query", {
                    p_query: 'person.name as "name'
                });
            
            }).to.throw(/JDC-00002/);

        }); 

        test("Missing escaped character in the end", function() {
            
            expect(function() {
            
                var elements = database.call("json_core.parse_query", {
                    p_query: 'person["name\\'
                });
            
            }).to.throw(/JDC-00002/);

        }); 

        test('Incomplete "as"', function() {
            
            expect(function() {
            
                var elements = database.call("json_core.parse_query", {
                    p_query: 'person.name a'
                });
            
            }).to.throw(/JDC-00002/);

        }); 
    
    });

    suite("Unexpected character", function() {
    
        test("Unexpected characted in the beginning", function() {
        
            expect(function() {
            
                var elements = database.call("json_core.parse_query", {
                    p_query: ".name"
                });
            
            }).to.throw(/JDC-00001/);
        
        });
        
        test("Spaces and unexpected characted in the beginning", function() {
        
            expect(function() {
            
                var elements = database.call("json_core.parse_query", {
                    p_query: "  .name"
                });
            
            }).to.throw(/JDC-00001/);
        
        });

        test("Unexpected characted when expected the first child in a branch", function() {
        
            expect(function() {
            
                var elements = database.call("json_core.parse_query", {
                    p_query: "person.(a"
                });
            
            }).to.throw(/JDC-00001/);
        
        });

        test("Unexpected characted when expected the n-th child in a branch", function() {
        
            expect(function() {
            
                var elements = database.call("json_core.parse_query", {
                    p_query: "person.(.name,surname"
                });
            
            }).to.throw(/JDC-00001/);
        
        });

        test("Unexpected characted in the simple property", function() {
        
            expect(function() {
            
                var elements = database.call("json_core.parse_query", {
                    p_query: "person.name^"
                });
            
            }).to.throw(/JDC-00001/);
        
        });

        test("Unexpected comma in a non-branching query", function() {
        
            expect(function() {
            
                var elements = database.call("json_core.parse_query", {
                    p_query: "person.name,"
                });
            
            }).to.throw(/JDC-00015/);
        
        });

        test("Unexpected spaces and comma in a non-branching query", function() {
        
            expect(function() {
            
                var elements = database.call("json_core.parse_query", {
                    p_query: "person.name  ,"
                });
            
            }).to.throw(/JDC-00015/);
        
        });

        test("Unexpected ) in a non-branching query", function() {
        
            expect(function() {
            
                var elements = database.call("json_core.parse_query", {
                    p_query: "person.name)"
                });
            
            }).to.throw(/JDC-00015/);
        
        });

        test("Unexpected ) and comma in a non-branching query", function() {
        
            expect(function() {
            
                var elements = database.call("json_core.parse_query", {
                    p_query: "person.name  )"
                });
            
            }).to.throw(/JDC-00015/);
        
        });

        test("Unexpected character in the simple property", function() {
        
            expect(function() {
            
                var elements = database.call("json_core.parse_query", {
                    p_query: "person.name^"
                });
            
            }).to.throw(/JDC-00001/);
        
        });

        test("Unexpected character after the branch close", function() {
        
            expect(function() {
            
                var elements = database.call("json_core.parse_query", {
                    p_query: "person(.name).surname"
                });
            
            }).to.throw(/JDC-00001/);
        
        });

        test("Unexpected spaces and a character after the branch close", function() {
        
            expect(function() {
            
                var elements = database.call("json_core.parse_query", {
                    p_query: "person(.name)   .surname"
                });
            
            }).to.throw(/JDC-00001/);
        
        });

        test("Unexpected spaces and a character after an aliased property", function() {
        
            expect(function() {
            
                var elements = database.call("json_core.parse_query", {
                    p_query: "person as person  .surname"
                });
            
            }).to.throw(/JDC-00001/);
        
        });

        test("Unexpected character after an quoted alias", function() {
        
            expect(function() {
            
                var elements = database.call("json_core.parse_query", {
                    p_query: 'person as "person".surname'
                });
            
            }).to.throw(/JDC-00001/);
        
        });

        test("Unexpected spaces and a character after an quoted alias", function() {
        
            expect(function() {
            
                var elements = database.call("json_core.parse_query", {
                    p_query: 'person as "person"  .surname'
                });
            
            }).to.throw(/JDC-00001/);
        
        });

        test("Unexpected character after a wildcard", function() {
        
            expect(function() {
            
                var elements = database.call("json_core.parse_query", {
                    p_query: "* name"
                });
            
            }).to.throw(/JDC-00001/);
        
        });

        test("Unexpected character after a simple name", function() {
        
            expect(function() {
            
                var elements = database.call("json_core.parse_query", {
                    p_query: "name surname"
                });
            
            }).to.throw(/JDC-00001/);
        
        });

        test("Unexpected character after a simple optional name", function() {
        
            expect(function() {
            
                var elements = database.call("json_core.parse_query", {
                    p_query: "person.name? surname"
                });
            
            }).to.throw(/JDC-00001/);
        
        });

        test("Unexpected character after an ID reference", function() {
        
            expect(function() {
            
                var elements = database.call("json_core.parse_query", {
                    p_query: "person.#123 surname"
                });
            
            }).to.throw(/JDC-00001/);
        
        });

        test("Unexpected character after an optional ID reference", function() {
        
            expect(function() {
            
                var elements = database.call("json_core.parse_query", {
                    p_query: "person.#123? surname"
                });
            
            }).to.throw(/JDC-00001/);
        
        });

        test("Unexpected character after an array element", function() {
        
            expect(function() {
            
                var elements = database.call("json_core.parse_query", {
                    p_query: "persons[123] name"
                });
            
            }).to.throw(/JDC-00001/);
        
        });

        test("Unexpected character after an optional array element", function() {
        
            expect(function() {
            
                var elements = database.call("json_core.parse_query", {
                    p_query: "persons[123]? name"
                });
            
            }).to.throw(/JDC-00001/);
        
        });

        test("Unexpected character after in a variable name", function() {
        
            expect(function() {
            
                var elements = database.call("json_core.parse_query", {
                    p_query: ":2 name"
                });
            
            }).to.throw(/JDC-00001/);
        
        });

        test("Unexpected character after a variable", function() {
        
            expect(function() {
            
                var elements = database.call("json_core.parse_query", {
                    p_query: ":2 name"
                });
            
            }).to.throw(/JDC-00001/);
        
        });

        test("Unexpected character after an optional variable", function() {
        
            expect(function() {
            
                var elements = database.call("json_core.parse_query", {
                    p_query: ":2?name"
                });
            
            }).to.throw(/JDC-00001/);
        
        });

        test("Unexpected character in an ID reference", function() {
        
            expect(function() {
            
                var elements = database.call("json_core.parse_query", {
                    p_query: "#123n"
                });
            
            }).to.throw(/JDC-00001/);
        
        });

        test("Unexpected character after [", function() {
        
            expect(function() {
            
                var elements = database.call("json_core.parse_query", {
                    p_query: "persons[name"
                });
            
            }).to.throw(/JDC-00001/);
        
        });

        test("Unexpected character in an array element", function() {
        
            expect(function() {
            
                var elements = database.call("json_core.parse_query", {
                    p_query: "persons[123abc"
                });
            
            }).to.throw(/JDC-00001/);
        
        });

        test("Unexpected character in an array element before ]", function() {
        
            expect(function() {
            
                var elements = database.call("json_core.parse_query", {
                    p_query: "persons[123 123]"
                });
            
            }).to.throw(/JDC-00001/);
        
        });

        test('Invalid "as"', function() {
        
            expect(function() {
            
                var elements = database.call("json_core.parse_query", {
                    p_query: "persons.name ab name"
                });
            
            }).to.throw(/JDC-00001/);
        
        });

        test('No space after "as"', function() {
        
            expect(function() {
            
                var elements = database.call("json_core.parse_query", {
                    p_query: "persons.name asname"
                });
            
            }).to.throw(/JDC-00001/);
        
        });

        test("Invalid alias start", function() {
        
            expect(function() {
            
                var elements = database.call("json_core.parse_query", {
                    p_query: "persons.name as 123"
                });
            
            }).to.throw(/JDC-00001/);
        
        });

        test("Unexpected character in an alias" , function() {
        
            expect(function() {
            
                var elements = database.call("json_core.parse_query", {
                    p_query: "persons.name as name^"
                });
            
            }).to.throw(/JDC-00001/);
        
        });

        test("Invalid variable start", function() {
        
            expect(function() {
            
                var elements = database.call("json_core.parse_query", {
                    p_query: "persons.:1a"
                });
            
            }).to.throw(/JDC-00001/);
        
        });

        test("Unexpected character in a variable" , function() {
        
            expect(function() {
            
                var elements = database.call("json_core.parse_query", {
                    p_query: ":ab12-"
                });
            
            }).to.throw(/JDC-00001/);
        
        });

        test("Invalid array element variable start", function() {
        
            expect(function() {
            
                var elements = database.call("json_core.parse_query", {
                    p_query: "persons[:1"
                });
            
            }).to.throw(/JDC-00001/);
        
        });

        test("Unexpected character in an array element variable" , function() {
        
            expect(function() {
            
                var elements = database.call("json_core.parse_query", {
                    p_query: "persons[:123a"
                });
            
            }).to.throw(/JDC-00001/);
        
        });
        
        test("Empty branch" , function() {
        
            expect(function() {
            
                var elements = database.call("json_core.parse_query", {
                    p_query: "persons[123]()"
                });
            
            }).to.throw(/JDC-00001/);
        
        });

        test("Empty branch with spaces" , function() {
        
            expect(function() {
            
                var elements = database.call("json_core.parse_query", {
                    p_query: "persons[123](   )"
                });
            
            }).to.throw(/JDC-00001/);
        
        });

    });

    suite("Other errors", function() {
    
        test("Alias too long", function() {
        
            expect(function() {
            
                var elements = database.call("json_core.parse_query", {
                    p_query: "person as abcabcabcabcabcabcabcabcabcabcA"
                });
            
            }).to.throw(/JDC-00017/);
        
        });
        
        test("Variable number too long", function() {
        
            expect(function() {
            
                var elements = database.call("json_core.parse_query", {
                    p_query: ":abcabcabcabcabcabcabcabcabcabcA"
                });
            
            }).to.throw(/JDC-00020/);
        
        });

        test("ID variable number too long", function() {
        
            expect(function() {
            
                var elements = database.call("json_core.parse_query", {
                    p_query: "#abcabcabcabcabcabcabcabcabcabcA"
                });
            
            }).to.throw(/JDC-00020/);
        
        });

        test("Branching reserved field", function() {
        
            expect(function() {
            
                var elements = database.call("json_core.parse_query", {
                    p_query: "field._key(._value)"
                });
            
            }).to.throw(/JDC-00026/);

        });

        test("Optional reserved field", function() {
        
            expect(function() {
            
                var elements = database.call("json_core.parse_query", {
                    p_query: "field._key?"
                });
            
            }).to.throw(/JDC-00025/);

        });

        test("Reserved field with a child", function() {
        
            expect(function() {
            
                var elements = database.call("json_core.parse_query", {
                    p_query: "field._key.name"
                });
            
            }).to.throw(/JDC-00027/);

        });

        test("Reserved field as the topmost element", function() {
        
            expect(function() {
            
                var elements = database.call("json_core.parse_query", {
                    p_query: "_key"
                });
            
            }).to.throw(/JDC-00028/);

        });

        test("Optional topmost element", function() {
        
            expect(function() {
            
                var elements = database.call("json_core.parse_query", {
                    p_query: "object?"
                });
            
            }).to.throw(/JDC-00029/);

        });

    });

});
*/
function resetPackage() {
    database.run(`
        BEGIN
            dbms_session.reset_package;
        END;
    `);
}

suite("Valid query tests", function() {

    test("Root only", function() {
    
        resetPackage();    

        database.call("json_core.parse_query", {
            p_query: "$"
        });

        let elements = database.call("json_core.dump").p_query_elements;

        expect(elements).to.eql([
            {
                type: "R",
                value: null,
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null,
                bind_number: 1
            }
        ]);
    
    });

    test("Root only, spaces before $", function() {
    
        resetPackage()

        database.call("json_core.parse_query", {
            p_query: "   $"
        });

        let elements = database.call("json_core.dump").p_query_elements;

        expect(elements).to.eql([
            {
                type: "R",
                value: null,
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null,
                bind_number: 1
            }
        ]);

    });

    test("Root only, spaces after $", function() {
    
        resetPackage();

        database.call("json_core.parse_query", {
            p_query: "$   "
        });

        let elements = database.call("json_core.dump").p_query_elements;

        expect(elements).to.eql([
            {
                type: "R",
                value: null,
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null,
                bind_number: 1
            }
        ]);
        
    });

    test("Branched root with two roots", function() {

        resetPackage();

        database.call("json_core.parse_query", {
            p_query: "($, $)"
        });    

        let elements = database.call("json_core.dump").p_query_elements;

        expect(elements).to.eql([
            {
                type: "R",
                value: null,
                optional: false,
                first_child_i: null,
                next_sibling_i: 2,
                alias: null,
                bind_number: 1
            },
            {
                type: "R",
                value: null,
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null,
                bind_number: 2
            }
        ]);
    
    });

    test("One simple name", function() {
    
        resetPackage();

        database.call("json_core.parse_query", {
            p_query: "person"
        });

        let elements = database.call("json_core.dump").p_query_elements;

        expect(elements).to.eql([
            {
                type: "N",
                value: "person",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null,
                bind_number: 1
            }
        ]);
    
    });

    test("One simple name with all allowed characters", function() {
    
        resetPackage();

        database.call("json_core.parse_query", {
            p_query: "qwertyuioplkjhgfdsazxcvbnmQWERTYUIOPLKJHGFDSAXZXCVBNM1234567890_$"
        });

        let elements = database.call("json_core.dump").p_query_elements;

        expect(elements).to.eql([
            {
                type: "N",
                value: "qwertyuioplkjhgfdsazxcvbnmQWERTYUIOPLKJHGFDSAXZXCVBNM1234567890_$",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null,
                bind_number: 1
            }
        ]);
    
    });

    test("One simple name with spaces in the beginning", function() {
    
        resetPackage();

        database.call("json_core.parse_query", {
            p_query: "    person"
        });

        let elements = database.call("json_core.dump").p_query_elements;

        expect(elements).to.eql([
            {
                type: "N",
                value: "person",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null,
                bind_number: 1
            }
        ]);
    
    });

    test("One simple name with spaces in the end", function() {
    
        resetPackage();

        database.call("json_core.parse_query", {
            p_query: "person    "
        });

        let elements = database.call("json_core.dump").p_query_elements;

        expect(elements).to.eql([
            {
                type: "N",
                value: "person",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null,
                bind_number: 1
            }
        ]);
    
    });

    test("Two simple names dot-separated", function() {
    
        resetPackage();

        database.call("json_core.parse_query", {
            p_query: "person.name"
        });

        let elements = database.call("json_core.dump").p_query_elements;

        expect(elements).to.eql([
            {
                type: "N",
                value: "person",
                optional: false,
                first_child_i: 2,
                next_sibling_i: null,
                alias: null,
                bind_number: 1
            },
            {
                type: "N",
                value: "name",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null,
                bind_number: 2
            }
        ]);
    
    });

    test("Two simple names dot-separated, spaces before the dot", function() {
    
        resetPackage();

        database.call("json_core.parse_query", {
            p_query: "person   .name"
        });

        let elements = database.call("json_core.dump").p_query_elements;

        expect(elements).to.eql([
            {
                type: "N",
                value: "person",
                optional: false,
                first_child_i: 2,
                next_sibling_i: null,
                alias: null,
                bind_number: 1
            },
            {
                type: "N",
                value: "name",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null,
                bind_number: 2
            }
        ]);
    
    });

    test("Two simple names dot-separated, spaces after the dot", function() {
    
        resetPackage();

        database.call("json_core.parse_query", {
            p_query: "person.   name"
        });

        let elements = database.call("json_core.dump").p_query_elements;

        expect(elements).to.eql([
            {
                type: "N",
                value: "person",
                optional: false,
                first_child_i: 2,
                next_sibling_i: null,
                alias: null,
                bind_number: 1
            },
            {
                type: "N",
                value: "name",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null,
                bind_number: 2
            }
        ]);
    
    });

    test("Multiple simple names dot-separated", function() {
    
        resetPackage();

        database.call("json_core.parse_query", {
            p_query: "person   .  address .street.house   "
        });

        let elements = database.call("json_core.dump").p_query_elements;

        expect(elements).to.eql([
            {
                type: "N",
                value: "person",
                optional: false,
                first_child_i: 2,
                next_sibling_i: null,
                alias: null,
                bind_number: 1
            },
            {
                type: "N",
                value: "address",
                optional: false,
                first_child_i: 3,
                next_sibling_i: null,
                alias: null,
                bind_number: 2
            },
            {
                type: "N",
                value: "street",
                optional: false,
                first_child_i: 4,
                next_sibling_i: null,
                alias: null,
                bind_number: 3
            },
            {
                type: "N",
                value: "house",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null,
                bind_number: 4
            }
        ]);
    
    });

    test("Branching root with one simple name", function() {
    
        resetPackage();

        database.call("json_core.parse_query", {
            p_query: "(name)"
        });

        let elements = database.call("json_core.dump").p_query_elements;

        expect(elements).to.eql([
            {
                type: "N",
                value: "name",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null,
                bind_number: 1
            }
        ]);
    
    });

    test("Branching root with one simple name, spaces in the beginning", function() {
    
        resetPackage();

        database.call("json_core.parse_query", {
            p_query: "   (name)"
        });

        let elements = database.call("json_core.dump").p_query_elements;

        expect(elements).to.eql([
            {
                type: "N",
                value: "name",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null,
                bind_number: 1
            }
        ]);
    
    });

    test("Branching root with one simple name, spaces after the opening bracket", function() {

        resetPackage();

        database.call("json_core.parse_query", {
            p_query: "(   name)"
        });

        let elements = database.call("json_core.dump").p_query_elements;

        expect(elements).to.eql([
            {
                type: "N",
                value: "name",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null,
                bind_number: 1
            }
        ]);
    
    });

    test("Branching root with one simple name, spaces before the closing bracket", function() {
    
        resetPackage();

        database.call("json_core.parse_query", {
            p_query: "(name   )"
        });

        let elements = database.call("json_core.dump").p_query_elements;

        expect(elements).to.eql([
            {
                type: "N",
                value: "name",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null,
                bind_number: 1
            }
        ]);
    
    });

    test("Branching root with one simple name, spaces in the end", function() {
    
        resetPackage();

        database.call("json_core.parse_query", {
            p_query: "(name)   "
        });

        let elements = database.call("json_core.dump").p_query_elements;

        expect(elements).to.eql([
            {
                type: "N",
                value: "name",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null,
                bind_number: 1
            }
        ]);
    
    });

    test("Branching root with two simple names", function() {
    
        resetPackage();

        database.call("json_core.parse_query", {
            p_query: "(name,surname)"
        });

        let elements = database.call("json_core.dump").p_query_elements;

        expect(elements).to.eql([
            {
                type: "N",
                value: "name",
                optional: false,
                first_child_i: null,
                next_sibling_i: 2,
                alias: null,
                bind_number: 1
            },
            {
                type: "N",
                value: "surname",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null,
                bind_number: 2
            }
        ]);
    
    });

    test("Branching root with two simple names, spaces before the comma", function() {
    
        resetPackage();

        database.call("json_core.parse_query", {
            p_query: "(name   ,surname)"
        });

        let elements = database.call("json_core.dump").p_query_elements;

        expect(elements).to.eql([
            {
                type: "N",
                value: "name",
                optional: false,
                first_child_i: null,
                next_sibling_i: 2,
                alias: null,
                bind_number: 1
            },
            {
                type: "N",
                value: "surname",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null,
                bind_number: 2
            }
        ]);
    
    });

    test("Branching root with two simple names, spaces after the comma", function() {
    
        resetPackage();

        database.call("json_core.parse_query", {
            p_query: "(name,   surname)"
        });

        let elements = database.call("json_core.dump").p_query_elements;

        expect(elements).to.eql([
            {
                type: "N",
                value: "name",
                optional: false,
                first_child_i: null,
                next_sibling_i: 2,
                alias: null,
                bind_number: 1
            },
            {
                type: "N",
                value: "surname",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null,
                bind_number: 2
            }
        ]);
    
    });

    test("Branching root with one array element", function() {
    
        resetPackage();

        database.call("json_core.parse_query", {
            p_query: "([123])"
        });

        let elements = database.call("json_core.dump").p_query_elements;

        expect(elements).to.eql([
            {
                type: "N",
                value: "123",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null,
                bind_number: 1
            }
        ]);
    
    });

    test("Branching root with two array elements", function() {
    
        resetPackage();

        database.call("json_core.parse_query", {
            p_query: "([123],[\"abc\"])"
        });

        let elements = database.call("json_core.dump").p_query_elements;

        expect(elements).to.eql([
            {
                type: "N",
                value: "123",
                optional: false,
                first_child_i: null,
                next_sibling_i: 2,
                alias: null,
                bind_number: 1
            },
            {
                type: "N",
                value: "abc",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null,
                bind_number: 2
            }
        ]);
    
    });

    test("Branching root with two array elements, spaces before the comma", function() {

        resetPackage();

        database.call("json_core.parse_query", {
            p_query: "([123]   ,[\"abc\"])"
        });

        let elements = database.call("json_core.dump").p_query_elements;

        expect(elements).to.eql([
            {
                type: "N",
                value: "123",
                optional: false,
                first_child_i: null,
                next_sibling_i: 2,
                alias: null,
                bind_number: 1
            },
            {
                type: "N",
                value: "abc",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null,
                bind_number: 2
            }
        ]);
    
    });

    test("Branching root with two array elements, spaces after the comma", function() {
    
        resetPackage();

        database.call("json_core.parse_query", {
            p_query: "([123],   [\"abc\"])"
        });

        let elements = database.call("json_core.dump").p_query_elements;

        expect(elements).to.eql([
            {
                type: "N",
                value: "123",
                optional: false,
                first_child_i: null,
                next_sibling_i: 2,
                alias: null,
                bind_number: 1
            },
            {
                type: "N",
                value: "abc",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null,
                bind_number: 2
            }
        ]);
    
    });

    test("Branching root with one variable", function() {
    
        resetPackage();

        database.call("json_core.parse_query", {
            p_query: "(:name)"
        });

        let elements = database.call("json_core.dump").p_query_elements;

        expect(elements).to.eql([
            {
                type: ":",
                value: "NAME",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null,
                bind_number: 1
            }
        ]);
    
    });

    test("Branching root with two variables", function() {
    
        resetPackage();

        database.call("json_core.parse_query", {
            p_query: "(:name,:name)"
        });

        let elements = database.call("json_core.dump").p_query_elements;

        expect(elements).to.eql([
            {
                type: ":",
                value: "NAME",
                optional: false,
                first_child_i: null,
                next_sibling_i: 2,
                alias: null,
                bind_number: 1
            },
            {
                type: ":",
                value: "NAME",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null,
                bind_number: 1
            }
        ]);
    
    });

    test("Branching root with two variables, spaces before the comma", function() {
    
        resetPackage();

        database.call("json_core.parse_query", {
            p_query: "(:name   ,:name)"
        });

        let elements = database.call("json_core.dump").p_query_elements;

        expect(elements).to.eql([
            {
                type: ":",
                value: "NAME",
                optional: false,
                first_child_i: null,
                next_sibling_i: 2,
                alias: null,
                bind_number: 1
            },
            {
                type: ":",
                value: "NAME",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null,
                bind_number: 1
            }
        ]);
    
    });

    test("Branching root with two variables, spaces after the comma", function() {
    
        resetPackage();

        database.call("json_core.parse_query", {
            p_query: "(:name,   :name)"
        });

        let elements = database.call("json_core.dump").p_query_elements;

        expect(elements).to.eql([
            {
                type: ":",
                value: "NAME",
                optional: false,
                first_child_i: null,
                next_sibling_i: 2,
                alias: null,
                bind_number: 1
            },
            {
                type: ":",
                value: "NAME",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null,
                bind_number: 1
            }
        ]);
    
    });

    test("Branching root with one ID variable", function() {
    
        resetPackage();

        database.call("json_core.parse_query", {
            p_query: "(#name)"
        });

        let elements = database.call("json_core.dump").p_query_elements;

        expect(elements).to.eql([
            {
                type: "#",
                value: "NAME",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null,
                bind_number: 1
            }
        ]);
    
    });

    test("Branching root with two ID variables", function() {
    
        resetPackage();

        database.call("json_core.parse_query", {
            p_query: "(#name,#name)"
        });

        let elements = database.call("json_core.dump").p_query_elements;

        expect(elements).to.eql([
            {
                type: "#",
                value: "NAME",
                optional: false,
                first_child_i: null,
                next_sibling_i: 2,
                alias: null,
                bind_number: 1
            },
            {
                type: "#",
                value: "NAME",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null,
                bind_number: 1
            }
        ]);
    
    });

    test("Branching root with two IDvariables, spaces before the comma", function() {
    
        resetPackage();

        database.call("json_core.parse_query", {
            p_query: "(#name   ,#name)"
        });

        let elements = database.call("json_core.dump").p_query_elements;

        expect(elements).to.eql([
            {
                type: "#",
                value: "NAME",
                optional: false,
                first_child_i: null,
                next_sibling_i: 2,
                alias: null,
                bind_number: 1
            },
            {
                type: "#",
                value: "NAME",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null,
                bind_number: 1
            }
        ]);
    
    });

    test("Branching root with two ID variables, spaces after the comma", function() {
    
        resetPackage();

        database.call("json_core.parse_query", {
            p_query: "(#name,   #name)"
        });

        let elements = database.call("json_core.dump").p_query_elements;

        expect(elements).to.eql([
            {
                type: "#",
                value: "NAME",
                optional: false,
                first_child_i: null,
                next_sibling_i: 2,
                alias: null,
                bind_number: 1
            },
            {
                type: "#",
                value: "NAME",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null,
                bind_number: 1
            }
        ]);
    
    });

    test("Branching root with one ID reference", function() {
    
        resetPackage();

        database.call("json_core.parse_query", {
            p_query: "(#123)"
        });

        let elements = database.call("json_core.dump").p_query_elements;

        expect(elements).to.eql([
            {
                type: "I",
                value: "123",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null,
                bind_number: 1
            }
        ]);
    
    });

    test("Branching root with two ID references", function() {
    
        resetPackage();

        database.call("json_core.parse_query", {
            p_query: "(#123,#321)"
        });

        let elements = database.call("json_core.dump").p_query_elements;

        expect(elements).to.eql([
            {
                type: "I",
                value: "123",
                optional: false,
                first_child_i: null,
                next_sibling_i: 2,
                alias: null,
                bind_number: 1
            },
            {
                type: "I",
                value: "321",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null,
                bind_number: 2
            }
        ]);
    
    });

    test("Branching root with two ID references, spaces before the comma", function() {
    
        resetPackage();

        database.call("json_core.parse_query", {
            p_query: "(#123   ,#321)"
        });

        let elements = database.call("json_core.dump").p_query_elements;

        expect(elements).to.eql([
            {
                type: "I",
                value: "123",
                optional: false,
                first_child_i: null,
                next_sibling_i: 2,
                alias: null,
                bind_number: 1
            },
            {
                type: "I",
                value: "321",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null,
                bind_number: 2
            }
        ]);
    
    });

    test("Branching root with two ID references, spaces after the comma", function() {
    
        resetPackage();

        database.call("json_core.parse_query", {
            p_query: "(#123,   #321)"
        });

        let elements = database.call("json_core.dump").p_query_elements;

        expect(elements).to.eql([
            {
                type: "I",
                value: "123",
                optional: false,
                first_child_i: null,
                next_sibling_i: 2,
                alias: null,
                bind_number: 1
            },
            {
                type: "I",
                value: "321",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null,
                bind_number: 2
            }
        ]);
    
    });

    test("Branching root with one wildcard", function() {
    
        resetPackage();

        database.call("json_core.parse_query", {
            p_query: "(*)"
        });

        let elements = database.call("json_core.dump").p_query_elements;

        expect(elements).to.eql([
            {
                type: "W",
                value: null,
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null,
                bind_number: null
                
            }
        ]);
    
    });

    test("Branching root with two wildcards", function() {
    
        resetPackage();

        database.call("json_core.parse_query", {
            p_query: "(*,*)"
        });

        let elements = database.call("json_core.dump").p_query_elements;

        expect(elements).to.eql([
            {
                type: "W",
                value: null,
                optional: false,
                first_child_i: null,
                next_sibling_i: 2,
                alias: null,
                bind_number: null
            },
            {
                type: "W",
                value: null,
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null,
                bind_number: null
            }
        ]);
    
    });

    test("Branching root with two wildcards, spaces before the comma", function() {
    
        resetPackage();

        database.call("json_core.parse_query", {
            p_query: "(*   ,*)"
        });

        let elements = database.call("json_core.dump").p_query_elements;

        expect(elements).to.eql([
            {
                type: "W",
                value: null,
                optional: false,
                first_child_i: null,
                next_sibling_i: 2,
                alias: null,
                bind_number: null
            },
            {
                type: "W",
                value: null,
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null,
                bind_number: null
            }
        ]);
    
    });

    test("Branching root with two wildcards, spaces after the comma", function() {
    
        resetPackage();

        database.call("json_core.parse_query", {
            p_query: "(*,   *)"
        });

        let elements = database.call("json_core.dump").p_query_elements;

        expect(elements).to.eql([
            {
                type: "W",
                value: null,
                optional: false,
                first_child_i: null,
                next_sibling_i: 2,
                alias: null,
                bind_number: null
            },
            {
                type: "W",
                value: null,
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null,
                bind_number: null
            }
        ]);
    
    });

    test("Branching root with a simple name and an array element", function() {
    
        resetPackage();

        database.call("json_core.parse_query", {
            p_query: "(person,[123])"
        });

        let elements = database.call("json_core.dump").p_query_elements;

        expect(elements).to.eql([
            {
                type: "N",
                value: "person",
                optional: false,
                first_child_i: null,
                next_sibling_i: 2,
                alias: null,
                bind_number: 1
            },
            {
                type: "N",
                value: "123",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null,
                bind_number: 2
            }
        ]);
    
    });

    test("Branching root with a simple name and an array element, spaces before the comma", function() {
    
        resetPackage();

        database.call("json_core.parse_query", {
            p_query: "(person   ,[123])"
        });

        let elements = database.call("json_core.dump").p_query_elements;

        expect(elements).to.eql([
            {
                type: "N",
                value: "person",
                optional: false,
                first_child_i: null,
                next_sibling_i: 2,
                alias: null,
                bind_number: 1
            },
            {
                type: "N",
                value: "123",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null,
                bind_number: 2
            }
        ]);
    
    });

    test("Branching root with a variable and an array element", function() {
    
        resetPackage();

        database.call("json_core.parse_query", {
            p_query: "(:name,[123])"
        });

        let elements = database.call("json_core.dump").p_query_elements;

        expect(elements).to.eql([
            {
                type: ":",
                value: "NAME",
                optional: false,
                first_child_i: null,
                next_sibling_i: 2,
                alias: null,
                bind_number: 1
            },
            {
                type: "N",
                value: "123",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null,
                bind_number: 1
            }
        ]);
    
    });

    test("Branching root with a variable and an array element, spaces before the comma", function() {
    
        resetPackage();

        database.call("json_core.parse_query", {
            p_query: "(:name   ,[123])"
        });

        let elements = database.call("json_core.dump").p_query_elements;

        expect(elements).to.eql([
            {
                type: ":",
                value: "NAME",
                optional: false,
                first_child_i: null,
                next_sibling_i: 2,
                alias: null,
                bind_number: 1
            },
            {
                type: "N",
                value: "123",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null,
                bind_number: 1
            }
        ]);
    
    });

    test("Branching root with an ID variable and an array element", function() {
    
        resetPackage();

        database.call("json_core.parse_query", {
            p_query: "(#id,[123])"
        });

        let elements = database.call("json_core.dump").p_query_elements;

        expect(elements).to.eql([
            {
                type: "#",
                value: "ID",
                optional: false,
                first_child_i: null,
                next_sibling_i: 2,
                alias: null,
                bind_number: 1
            },
            {
                type: "N",
                value: "123",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null,
                bind_number: 1
            }
        ]);
    
    });

    test("Branching root with an ID variable and an array element, spaces before the comma", function() {
    
        resetPackage();

        database.call("json_core.parse_query", {
            p_query: "(#id   ,[123])"
        });

        let elements = database.call("json_core.dump").p_query_elements;

        expect(elements).to.eql([
            {
                type: "#",
                value: "ID",
                optional: false,
                first_child_i: null,
                next_sibling_i: 2,
                alias: null,
                bind_number: 1
            },
            {
                type: "N",
                value: "123",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null,
                bind_number: 1
            }
        ]);
    
    });

    test("Branching root with an ID reference and an array element", function() {
    
        resetPackage();

        database.call("json_core.parse_query", {
            p_query: "(#123,[123])"
        });

        let elements = database.call("json_core.dump").p_query_elements;

        expect(elements).to.eql([
            {
                type: "I",
                value: "123",
                optional: false,
                first_child_i: null,
                next_sibling_i: 2,
                alias: null,
                bind_number: 1
            },
            {
                type: "N",
                value: "123",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null,
                bind_number: 2
            }
        ]);
    
    });

    test("Branching root with an ID reference and an array element, spaces before the comma", function() {
    
        resetPackage();

        database.call("json_core.parse_query", {
            p_query: "(#123   ,[123])"
        });

        let elements = database.call("json_core.dump").p_query_elements;

        expect(elements).to.eql([
            {
                type: "I",
                value: "123",
                optional: false,
                first_child_i: null,
                next_sibling_i: 2,
                alias: null,
                bind_number: 1
            },
            {
                type: "N",
                value: "123",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null,
                bind_number: 2
            }
        ]);
    
    });

    test("Branching root with a wildcard and an array element", function() {
    
        resetPackage();

        database.call("json_core.parse_query", {
            p_query: "(*,[123])"
        });

        let elements = database.call("json_core.dump").p_query_elements;

        expect(elements).to.eql([
            {
                type: "W",
                value: null,
                optional: false,
                first_child_i: null,
                next_sibling_i: 2,
                alias: null,
                bind_number: null
            },
            {
                type: "N",
                value: "123",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null,
                bind_number: 1
            }
        ]);
    
    });

    test("Branching root with a wildcard and an array element, spaces before the comma", function() {
    
        resetPackage();

        database.call("json_core.parse_query", {
            p_query: "(*   ,[123])"
        });

        let elements = database.call("json_core.dump").p_query_elements;

        expect(elements).to.eql([
            {
                type: "W",
                value: null,
                optional: false,
                first_child_i: null,
                next_sibling_i: 2,
                alias: null,
                bind_number: null
            },
            {
                type: "N",
                value: "123",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null,
                bind_number: 1
            }
        ]);
    
    });

    test("Branching root with a aliased name and an array element", function() {
    
        resetPackage();

        database.call("json_core.parse_query", {
            p_query: "(name as name,[123])"
        });

        let elements = database.call("json_core.dump").p_query_elements;

        expect(elements).to.eql([
            {
                type: "N",
                value: "name",
                optional: false,
                first_child_i: null,
                next_sibling_i: 2,
                alias: "NAME",
                bind_number: 1
            },
            {
                type: "N",
                value: "123",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null,
                bind_number: 2
            }
        ]);
    
    });

    test("Branching root with an aliased name and an array element, spaces before the comma", function() {
    
        resetPackage();

        database.call("json_core.parse_query", {
            p_query: "(name as name   ,[123])"
        });

        let elements = database.call("json_core.dump").p_query_elements;

        expect(elements).to.eql([
            {
                type: "N",
                value: "name",
                optional: false,
                first_child_i: null,
                next_sibling_i: 2,
                alias: "NAME",
                bind_number: 1
            },
            {
                type: "N",
                value: "123",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null,
                bind_number: 2
            }
        ]);
    
    });

    test("Branching element with one simple name", function() {
    
        resetPackage();

        database.call("json_core.parse_query", {
            p_query: "person(.name)"
        });

        let elements = database.call("json_core.dump").p_query_elements;

        expect(elements).to.eql([
            {
                type: "N",
                value: "person",
                optional: false,
                first_child_i: 2,
                next_sibling_i: null,
                alias: null,
                bind_number: 1
            },
            {
                type: "N",
                value: "name",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null,
                bind_number: 2
            }
        ]);
    
    });

    test("Branching element with one simple name, spaces before opening bracket", function() {
    
        resetPackage();

        database.call("json_core.parse_query", {
            p_query: "person   (.name)"
        });

        let elements = database.call("json_core.dump").p_query_elements;

        expect(elements).to.eql([
            {
                type: "N",
                value: "person",
                optional: false,
                first_child_i: 2,
                next_sibling_i: null,
                alias: null,
                bind_number: 1
            },
            {
                type: "N",
                value: "name",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null,
                bind_number: 2
            }
        ]);
    
    });

    test("Branching element with one simple name, spaces before the dot", function() {
    
        resetPackage();

        database.call("json_core.parse_query", {
            p_query: "person(   .name)"
        });

        let elements = database.call("json_core.dump").p_query_elements;

        expect(elements).to.eql([
            {
                type: "N",
                value: "person",
                optional: false,
                first_child_i: 2,
                next_sibling_i: null,
                alias: null,
                bind_number: 1
            },
            {
                type: "N",
                value: "name",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null,
                bind_number: 2
            }
        ]);
    
    });

    test("Branching element with one simple name, spaces after the dot", function() {
    
        resetPackage();

        database.call("json_core.parse_query", {
            p_query: "person(.   name)"
        });

        let elements = database.call("json_core.dump").p_query_elements;

        expect(elements).to.eql([
            {
                type: "N",
                value: "person",
                optional: false,
                first_child_i: 2,
                next_sibling_i: null,
                alias: null,
                bind_number: 1
            },
            {
                type: "N",
                value: "name",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null,
                bind_number: 2
            }
        ]);
    
    });

    test("Branching element with two simple names", function() {
    
        resetPackage();

        database.call("json_core.parse_query", {
            p_query: "person(.name, .surname)"
        });

        let elements = database.call("json_core.dump").p_query_elements;

        expect(elements).to.eql([
            {
                type: "N",
                value: "person",
                optional: false,
                first_child_i: 2,
                next_sibling_i: null,
                alias: null,
                bind_number: 1
            },
            {
                type: "N",
                value: "name",
                optional: false,
                first_child_i: null,
                next_sibling_i: 3,
                alias: null,
                bind_number: 2
            },
            {
                type: "N",
                value: "surname",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null,
                bind_number: 3
            }
        ]);
    
    });

    test("Complex branching query with simple names 1", function() {
    
        resetPackage();

        database.call("json_core.parse_query", {
            p_query: "person(.name, .surname, .address(.street, .city))"
        });

        let elements = database.call("json_core.dump").p_query_elements;

        expect(elements).to.eql([
            {
                type: "N",
                value: "person",
                optional: false,
                first_child_i: 2,
                next_sibling_i: null,
                alias: null,
                bind_number: 1
            },
            {
                type: "N",
                value: "name",
                optional: false,
                first_child_i: null,
                next_sibling_i: 3,
                alias: null,
                bind_number: 2
            },
            {
                type: "N",
                value: "surname",
                optional: false,
                first_child_i: null,
                next_sibling_i: 4,
                alias: null,
                bind_number: 3
            },
            {
                type: "N",
                value: "address",
                optional: false,
                first_child_i: 5,
                next_sibling_i: null,
                alias: null,
                bind_number: 4
            },
            {
                type: "N",
                value: "street",
                optional: false,
                first_child_i: null,
                next_sibling_i: 6,
                alias: null,
                bind_number: 5
            },
            {
                type: "N",
                value: "city",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null,
                bind_number: 6
            }
        ]);
    
    });

    test("Complex branching query with simple names 2", function() {
    
        resetPackage();

        database.call("json_core.parse_query", {
            p_query: "person(.name, .surname, .address(.street, .city), .birthDate)"
        });

        let elements = database.call("json_core.dump").p_query_elements;

        expect(elements).to.eql([
            {
                type: "N",
                value: "person",
                optional: false,
                first_child_i: 2,
                next_sibling_i: null,
                alias: null,
                bind_number: 1
            },
            {
                type: "N",
                value: "name",
                optional: false,
                first_child_i: null,
                next_sibling_i: 3,
                alias: null,
                bind_number: 2
            },
            {
                type: "N",
                value: "surname",
                optional: false,
                first_child_i: null,
                next_sibling_i: 4,
                alias: null,
                bind_number: 3
            },
            {
                type: "N",
                value: "address",
                optional: false,
                first_child_i: 5,
                next_sibling_i: 7,
                alias: null,
                bind_number: 4
            },
            {
                type: "N",
                value: "street",
                optional: false,
                first_child_i: null,
                next_sibling_i: 6,
                alias: null,
                bind_number: 5
            },
            {
                type: "N",
                value: "city",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null,
                bind_number: 6
            },
            {
                type: "N",
                value: "birthDate",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null,
                bind_number: 7
            }
        ]);
    
    });

    test("Property of the root", function() {
    
        resetPackage();

        database.call("json_core.parse_query", {
            p_query: "$.persons"
        });

        let elements = database.call("json_core.dump").p_query_elements;

        expect(elements).to.eql([
            {
                type: "R",
                value: null,
                optional: false,
                first_child_i: 2,
                next_sibling_i: null,
                alias: null,
                bind_number: 1
            },
            {
                type: "N",
                value: "persons",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null,
                bind_number: 2
            }
        ]);
    
    });

    test("Property of the root, spaces after $", function() {
    
        resetPackage();

        database.call("json_core.parse_query", {
            p_query: "$.persons"
        });

        let elements = database.call("json_core.dump").p_query_elements;

        expect(elements).to.eql([
            {
                type: "R",
                value: null,
                optional: false,
                first_child_i: 2,
                next_sibling_i: null,
                alias: null,
                bind_number: 1
            },
            {
                type: "N",
                value: "persons",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null,
                bind_number: 2
            }
        ]);
    
    });

    test("Array element of the root", function() {
    
        resetPackage();

        database.call("json_core.parse_query", {
            p_query: "$[123]"
        });

        let elements = database.call("json_core.dump").p_query_elements;

        expect(elements).to.eql([
            {
                type: "R",
                value: null,
                optional: false,
                first_child_i: 2,
                next_sibling_i: null,
                alias: null,
                bind_number: 1
            },
            {
                type: "N",
                value: "123",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null,
                bind_number: 2
            }
        ]);
    
    });

    test("Array element of the root, spaces after $", function() {
    
        resetPackage();

        database.call("json_core.parse_query", {
            p_query: "$   [123]"
        });

        let elements = database.call("json_core.dump").p_query_elements;

        expect(elements).to.eql([
            {
                type: "R",
                value: null,
                optional: false,
                first_child_i: 2,
                next_sibling_i: null,
                alias: null,
                bind_number: 1
            },
            {
                type: "N",
                value: "123",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null,
                bind_number: 2
            }
        ]);
    
    });

    test("Single ID variable", function() {
    
        resetPackage();

        database.call("json_core.parse_query", {
            p_query: "#id"
        });

        let elements = database.call("json_core.dump").p_query_elements;

        expect(elements).to.eql([
            {
                type: "#",
                value: "ID",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null,
                bind_number: 1
            }
        ]);
    
    });

    test("Single ID reference", function() {
    
        resetPackage();

        database.call("json_core.parse_query", {
            p_query: "#123"
        });

        let elements = database.call("json_core.dump").p_query_elements;

        expect(elements).to.eql([
            {
                type: "I",
                value: "123",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null,
                bind_number: 1
            }
        ]);
    
    });

    test("Single ID reference, spaces before #", function() {
    
        resetPackage();

        database.call("json_core.parse_query", {
            p_query: "   #123"
        });

        let elements = database.call("json_core.dump").p_query_elements;

        expect(elements).to.eql([
            {
                type: "I",
                value: "123",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null,
                bind_number: 1
            }
        ]);
    
    });

    test("Single ID reference, spaces after ID", function() {
    
        resetPackage();

        database.call("json_core.parse_query", {
            p_query: "#123   "
        });

        let elements = database.call("json_core.dump").p_query_elements;

        expect(elements).to.eql([
            {
                type: "I",
                value: "123",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null,
                bind_number: 1
            }
        ]);
    
    });

    test("Simple name property of an ID reference", function() {
    
        resetPackage();

        database.call("json_core.parse_query", {
            p_query: "#123.name"
        });

        let elements = database.call("json_core.dump").p_query_elements;

        expect(elements).to.eql([
            {
                type: "I",
                value: "123",
                optional: false,
                first_child_i: 2,
                next_sibling_i: null,
                alias: null,
                bind_number: 1
            },
            {
                type: "N",
                value: "name",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null,
                bind_number: 2
            }
        ]);
    
    });

    test("Simple name property of an ID reference, spaces before the dot", function() {
    
        resetPackage();

        database.call("json_core.parse_query", {
            p_query: "#123   .name"
        });

        let elements = database.call("json_core.dump").p_query_elements;

        expect(elements).to.eql([
            {
                type: "I",
                value: "123",
                optional: false,
                first_child_i: 2,
                next_sibling_i: null,
                alias: null,
                bind_number: 1
            },
            {
                type: "N",
                value: "name",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null,
                bind_number: 2
            }
        ]);
    
    });

    test("ID reference as a property", function() {
    
        resetPackage();

        database.call("json_core.parse_query", {
            p_query: "person.#123"
        });

        let elements = database.call("json_core.dump").p_query_elements;

        expect(elements).to.eql([
            {
                type: "N",
                value: "person",
                optional: false,
                first_child_i: 2,
                next_sibling_i: null,
                alias: null,
                bind_number: 1
            },
            {
                type: "I",
                value: "123",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null,
                bind_number: 2
            }
        ]);
    
    });

    test("ID reference as a property, spaces before #", function() {
    
        resetPackage();

        database.call("json_core.parse_query", {
            p_query: "person.   #123"
        });

        let elements = database.call("json_core.dump").p_query_elements;

        expect(elements).to.eql([
            {
                type: "N",
                value: "person",
                optional: false,
                first_child_i: 2,
                next_sibling_i: null,
                alias: null,
                bind_number: 1
            },
            {
                type: "I",
                value: "123",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null,
                bind_number: 2
            }
        ]);
    
    });

    test("ID references as branched properties", function() {
    
        resetPackage();

        database.call("json_core.parse_query", {
            p_query: "person(.#123, .#321)"
        });

        let elements = database.call("json_core.dump").p_query_elements;

        expect(elements).to.eql([
            {
                type: "N",
                value: "person",
                optional: false,
                first_child_i: 2,
                next_sibling_i: null,
                alias: null,
                bind_number: 1
            },
            {
                type: "I",
                value: "123",
                optional: false,
                first_child_i: null,
                next_sibling_i: 3,
                alias: null,
                bind_number: 2
            },
            {
                type: "I",
                value: "321",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null,
                bind_number: 3
            }
        ]);
    
    });

    test("ID reference parent of a branch", function() {
    
        resetPackage();

        database.call("json_core.parse_query", {
            p_query: "#123(.name, .surname)"
        });

        let elements = database.call("json_core.dump").p_query_elements;

        expect(elements).to.eql([
            {
                type: "I",
                value: "123",
                optional: false,
                first_child_i: 2,
                next_sibling_i: null,
                alias: null,
                bind_number: 1
            },
            {
                type: "N",
                value: "name",
                optional: false,
                first_child_i: null,
                next_sibling_i: 3,
                alias: null,
                bind_number: 2
            },
            {
                type: "N",
                value: "surname",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null,
                bind_number: 3
            }
        ]);
    
    });

    test("ID reference parent of a branch, spaces before (", function() {
    
        resetPackage();

        database.call("json_core.parse_query", {
            p_query: "#123   (.name, .surname)"
        });

        let elements = database.call("json_core.dump").p_query_elements;

        expect(elements).to.eql([
            {
                type: "I",
                value: "123",
                optional: false,
                first_child_i: 2,
                next_sibling_i: null,
                alias: null,
                bind_number: 1
            },
            {
                type: "N",
                value: "name",
                optional: false,
                first_child_i: null,
                next_sibling_i: 3,
                alias: null,
                bind_number: 2
            },
            {
                type: "N",
                value: "surname",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null,
                bind_number: 3
            }
        ]);
    
    });

    test("Single array element", function() {
    
        resetPackage();

        database.call("json_core.parse_query", {
            p_query: "[123]"
        });

        let elements = database.call("json_core.dump").p_query_elements;

        expect(elements).to.eql([
            {
                type: "N",
                value: "123",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null,
                bind_number: 1
            }
        ]);
    
    });

    test("Single array element, spaces before [", function() {
    
        resetPackage();

        database.call("json_core.parse_query", {
            p_query: "   [123]"
        });

        let elements = database.call("json_core.dump").p_query_elements;

        expect(elements).to.eql([
            {
                type: "N",
                value: "123",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null,
                bind_number: 1
            }
        ]);
    
    });

    test("Single array element, spaces after [", function() {
    
        resetPackage();

        database.call("json_core.parse_query", {
            p_query: "[   123]"
        });

        let elements = database.call("json_core.dump").p_query_elements;

        expect(elements).to.eql([
            {
                type: "N",
                value: "123",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null,
                bind_number: 1
            }
        ]);
    
    });

    test("Single array element, spaces before ]", function() {
    
        resetPackage();

        database.call("json_core.parse_query", {
            p_query: "[123    ]"
        });

        let elements = database.call("json_core.dump").p_query_elements;

        expect(elements).to.eql([
            {
                type: "N",
                value: "123",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null,
                bind_number: 1
            }
        ]);
    
    });

    test("Single array element, spaces after ]", function() {
    
        resetPackage();

        database.call("json_core.parse_query", {
            p_query: "[123]  "
        });

        let elements = database.call("json_core.dump").p_query_elements;

        expect(elements).to.eql([
            {
                type: "N",
                value: "123",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null,
                bind_number: 1
            }
        ]);
    
    });

    test("Array element of a name", function() {
    
        resetPackage();

        database.call("json_core.parse_query", {
            p_query: "persons[123]"
        });

        let elements = database.call("json_core.dump").p_query_elements;

        expect(elements).to.eql([
            {
                type: "N",
                value: "persons",
                optional: false,
                first_child_i: 2,
                next_sibling_i: null,
                alias: null,
                bind_number: 1
            },
            {
                type: "N",
                value: "123",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null,
                bind_number: 2
            }
        ]);
    
    });

    test("Array element of a name,spaces before [", function() {
    
        resetPackage();

        database.call("json_core.parse_query", {
            p_query: "persons   [123]"
        });

        let elements = database.call("json_core.dump").p_query_elements;

        expect(elements).to.eql([
            {
                type: "N",
                value: "persons",
                optional: false,
                first_child_i: 2,
                next_sibling_i: null,
                alias: null,
                bind_number: 1
            },
            {
                type: "N",
                value: "123",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null,
                bind_number: 2
            }
        ]);
    
    });

    test("Array element of an ID reference", function() {
    
        resetPackage();

        database.call("json_core.parse_query", {
            p_query: "#123[321]"
        });

        let elements = database.call("json_core.dump").p_query_elements;

        expect(elements).to.eql([
            {
                type: "I",
                value: "123",
                optional: false,
                first_child_i: 2,
                next_sibling_i: null,
                alias: null,
                bind_number: 1
            },
            {
                type: "N",
                value: "321",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null,
                bind_number: 2
            }
        ]);
    
    });

    test("Array element of an ID reference, spaces before [", function() {
    
        resetPackage();

        database.call("json_core.parse_query", {
            p_query: "#123   [321]"
        });

        let elements = database.call("json_core.dump").p_query_elements;

        expect(elements).to.eql([
            {
                type: "I",
                value: "123",
                optional: false,
                first_child_i: 2,
                next_sibling_i: null,
                alias: null,
                bind_number: 1
            },
            {
                type: "N",
                value: "321",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null,
                bind_number: 2
            }
        ]);
    
    });

    test("Array element of an array element", function() {
    
        resetPackage();

        database.call("json_core.parse_query", {
            p_query: "[123][321]"
        });

        let elements = database.call("json_core.dump").p_query_elements;

        expect(elements).to.eql([
            {
                type: "N",
                value: "123",
                optional: false,
                first_child_i: 2,
                next_sibling_i: null,
                alias: null,
                bind_number: 1
            },
            {
                type: "N",
                value: "321",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null,
                bind_number: 2
            }
        ]);
    
    });

    test("Array element of an array element, spaces between elements", function() {
    
        resetPackage();

        database.call("json_core.parse_query", {
            p_query: "[123]   [321]"
        });

        let elements = database.call("json_core.dump").p_query_elements;

        expect(elements).to.eql([
            {
                type: "N",
                value: "123",
                optional: false,
                first_child_i: 2,
                next_sibling_i: null,
                alias: null,
                bind_number: 1
            },
            {
                type: "N",
                value: "321",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null,
                bind_number: 2
            }
        ]);
    
    });

    test("Single quoted name", function() {
    
        resetPackage();

        database.call("json_core.parse_query", {
            p_query: '["person"]'
        });

        let elements = database.call("json_core.dump").p_query_elements;

        expect(elements).to.eql([
            {
                type: "N",
                value: "person",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null,
                bind_number: 1
            }
        ]);
    
    });

    test("Single quoted name, spaces after [", function() {
    
        resetPackage();

        database.call("json_core.parse_query", {
            p_query: '[   "person"]'
        });

        let elements = database.call("json_core.dump").p_query_elements;

        expect(elements).to.eql([
            {
                type: "N",
                value: "person",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null,
                bind_number: 1
            }
        ]);
    
    });

    test("Single quoted name, spaces before ]", function() {
    
        resetPackage();

        database.call("json_core.parse_query", {
            p_query: '["person"   ]'
        });

        let elements = database.call("json_core.dump").p_query_elements;

        expect(elements).to.eql([
            {
                type: "N",
                value: "person",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null,
                bind_number: 1
            }
        ]);
    
    });

    test("Single quoted name, spaces before ]", function() {
    
        resetPackage();

        database.call("json_core.parse_query", {
            p_query: '["person"   ]'
        });

        let elements = database.call("json_core.dump").p_query_elements;

        expect(elements).to.eql([
            {
                type: "N",
                value: "person",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null,
                bind_number: 1
            }
        ]);
    
    });

    test("Single quoted name with escaped characters", function() {
    
        resetPackage();

        database.call("json_core.parse_query", {
            p_query: '["\\\\\\""]'
        });

        let elements = database.call("json_core.dump").p_query_elements;

        expect(elements).to.eql([
            {
                type: "N",
                value: "\\\"",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null,
                bind_number: 1
            }
        ]);
    
    });

    test("Branched query with combined element types", function() {
    
        resetPackage();

        database.call("json_core.parse_query", {
            p_query: '["persons"][123](.name, ["surname"], .#321)'
        });

        let elements = database.call("json_core.dump").p_query_elements;

        expect(elements).to.eql([
            {
                type: "N",
                value: "persons",
                optional: false,
                first_child_i: 2,
                next_sibling_i: null,
                alias: null,
                bind_number: 1
            },
            {
                type: "N",
                value: "123",
                optional: false,
                first_child_i: 3,
                next_sibling_i: null,
                alias: null,
                bind_number: 2
            },
            {
                type: "N",
                value: "name",
                optional: false,
                first_child_i: null,
                next_sibling_i: 4,
                alias: null,
                bind_number: 3
            },
            {
                type: "N",
                value: "surname",
                optional: false,
                first_child_i: null,
                next_sibling_i: 5,
                alias: null,
                bind_number: 4
            },
            {
                type: "I",
                value: "321",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null,
                bind_number: 5
            }
        ]);
    
    });

    test("Simple name with an alias, lower case 'as'", function() {
        
        resetPackage();

        database.call("json_core.parse_query", {
            p_query: 'person as human'
        });

        let elements = database.call("json_core.dump").p_query_elements;

        expect(elements).to.eql([
            {
                type: "N",
                value: "person",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: "HUMAN",
                bind_number: 1
            }
        ]);
    
    });

    test("Simple name with an alias, mixed case 'as'", function() {
    
        resetPackage();

        database.call("json_core.parse_query", {
            p_query: 'person aS human'
        });

        let elements = database.call("json_core.dump").p_query_elements;

        expect(elements).to.eql([
            {
                type: "N",
                value: "person",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: "HUMAN",
                bind_number: 1
            }
        ]);
    
    });

    test("Simple name with a quoted alias", function() {
    
        resetPackage();

        database.call("json_core.parse_query", {
            p_query: 'person as "human"'
        });

        let elements = database.call("json_core.dump").p_query_elements;

        expect(elements).to.eql([
            {
                type: "N",
                value: "person",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: "human",
                bind_number: 1
            }
        ]);
    
    });

    test("ID reference with an alias", function() {
    
        resetPackage();

        database.call("json_core.parse_query", {
            p_query: '#123 as human'
        });

        let elements = database.call("json_core.dump").p_query_elements;

        expect(elements).to.eql([
            {
                type: "I",
                value: "123",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: "HUMAN",
                bind_number: 1
            }
        ]);
    
    });

    test("Simple name property with an alias", function() {
    
        resetPackage();

        database.call("json_core.parse_query", {
            p_query: 'person.name as person_name'
        });

        let elements = database.call("json_core.dump").p_query_elements;

        expect(elements).to.eql([
            {
                type: "N",
                value: "person",
                optional: false,
                first_child_i: 2,
                next_sibling_i: null,
                alias: null,
                bind_number: 1
            },
            {
                type: "N",
                value: "name",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: "PERSON_NAME",
                bind_number: 2
            }
        ]);
    
    });

    test("Quoted name property with an alias", function() {
    
        resetPackage();

        database.call("json_core.parse_query", {
            p_query: 'person["name"] as person_name'
        });

        let elements = database.call("json_core.dump").p_query_elements;

        expect(elements).to.eql([
            {
                type: "N",
                value: "person",
                optional: false,
                first_child_i: 2,
                next_sibling_i: null,
                alias: null,
                bind_number: 1
            },
            {
                type: "N",
                value: "name",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: "PERSON_NAME",
                bind_number: 2
            }
        ]);
    
    });

    test("Alias in a branch", function() {
    
        resetPackage();

        database.call("json_core.parse_query", {
            p_query: `
                person (
                    .name as person_name, 
                    .surname as person_surname, 
                    .phones[0] (
                        .type as phone_type,
                        .number as phone_number 
                    )
                )`          
        });

        let elements = database.call("json_core.dump").p_query_elements;

        expect(elements).to.eql([
            {
                type: "N",
                value: "person",
                optional: false,
                first_child_i: 2,
                next_sibling_i: null,
                alias: null,
                bind_number: 1
            },
            {
                type: "N",
                value: "name",
                optional: false,
                first_child_i: null,
                next_sibling_i: 3,
                alias: "PERSON_NAME",
                bind_number: 2
            },
            {
                type: "N",
                value: "surname",
                optional: false,
                first_child_i: null,
                next_sibling_i: 4,
                alias: "PERSON_SURNAME",
                bind_number: 3
            },
            {
                type: "N",
                value: "phones",
                optional: false,
                first_child_i: 5,
                next_sibling_i: null,
                alias: null,
                bind_number: 4
            },
            {
                type: "N",
                value: "0",
                optional: false,
                first_child_i: 6,
                next_sibling_i: null,
                alias: null,
                bind_number: 5
            },
            {
                type: "N",
                value: "type",
                optional: false,
                first_child_i: null,
                next_sibling_i: 7,
                alias: "PHONE_TYPE",
                bind_number: 6
            },
            {
                type: "N",
                value: "number",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: "PHONE_NUMBER",
                bind_number: 7
            }
        ]);
    
    });

    test("Optional simple name property", function() {
    
        resetPackage();

        database.call("json_core.parse_query", {
            p_query: 'person.name?'
        });

        let elements = database.call("json_core.dump").p_query_elements;

        expect(elements).to.eql([
            {
                type: "N",
                value: "person",
                optional: false,
                first_child_i: 2,
                next_sibling_i: null,
                alias: null,
                bind_number: 1
            },
            {
                type: "N",
                value: "name",
                optional: true,
                first_child_i: null,
                next_sibling_i: null,
                alias: null,
                bind_number: 2
            }
        ]);
    
    });

    test("Optional simple name property, spaces before ?", function() {

        resetPackage();

        database.call("json_core.parse_query", {
            p_query: 'person.name   ?'
        });

        let elements = database.call("json_core.dump").p_query_elements;

        expect(elements).to.eql([
            {
                type: "N",
                value: "person",
                optional: false,
                first_child_i: 2,
                next_sibling_i: null,
                alias: null,
                bind_number: 1
            },
            {
                type: "N",
                value: "name",
                optional: true,
                first_child_i: null,
                next_sibling_i: null,
                alias: null,
                bind_number: 2
            }
        ]);
    
    });

    test("Optional simple name property, spaces after ?", function() {
    
        resetPackage();

        database.call("json_core.parse_query", {
            p_query: 'person.name?   '
        });

        let elements = database.call("json_core.dump").p_query_elements;

        expect(elements).to.eql([
            {
                type: "N",
                value: "person",
                optional: false,
                first_child_i: 2,
                next_sibling_i: null,
                alias: null,
                bind_number: 1
            },
            {
                type: "N",
                value: "name",
                optional: true,
                first_child_i: null,
                next_sibling_i: null,
                alias: null,
                bind_number: 2
            }
        ]);
    
    });

    test("Optional ID reference property", function() {
    
        resetPackage();

        database.call("json_core.parse_query", {
            p_query: 'person.#123?'
        });

        let elements = database.call("json_core.dump").p_query_elements;

        expect(elements).to.eql([
            {
                type: "N",
                value: "person",
                optional: false,
                first_child_i: 2,
                next_sibling_i: null,
                alias: null,
                bind_number: 1
            },
            {
                type: "I",
                value: "123",
                optional: true,
                first_child_i: null,
                next_sibling_i: null,
                alias: null,
                bind_number: 2
            }
        ]);
    
    });

    test("Optional ID reference property, spaces before ?", function() {
    
        resetPackage();

        database.call("json_core.parse_query", {
            p_query: 'person.#123   ?'
        });

        let elements = database.call("json_core.dump").p_query_elements;

        expect(elements).to.eql([
            {
                type: "N",
                value: "person",
                optional: false,
                first_child_i: 2,
                next_sibling_i: null,
                alias: null,
                bind_number: 1
            },
            {
                type: "I",
                value: "123",
                optional: true,
                first_child_i: null,
                next_sibling_i: null,
                alias: null,
                bind_number: 2
            }
        ]);
    
    });

    test("Optional ID reference property, spaces after ?", function() {
    
        resetPackage();

        database.call("json_core.parse_query", {
            p_query: 'person.#123?   '
        });

        let elements = database.call("json_core.dump").p_query_elements;

        expect(elements).to.eql([
            {
                type: "N",
                value: "person",
                optional: false,
                first_child_i: 2,
                next_sibling_i: null,
                alias: null,
                bind_number: 1
            },
            {
                type: "I",
                value: "123",
                optional: true,
                first_child_i: null,
                next_sibling_i: null,
                alias: null,
                bind_number: 2
            }
        ]);
    
    });

    test("Optional array element property", function() {
    
        resetPackage();

        database.call("json_core.parse_query", {
            p_query: 'person["name"]?'
        });

        let elements = database.call("json_core.dump").p_query_elements;

        expect(elements).to.eql([
            {
                type: "N",
                value: "person",
                optional: false,
                first_child_i: 2,
                next_sibling_i: null,
                alias: null,
                bind_number: 1
            },
            {
                type: "N",
                value: "name",
                optional: true,
                first_child_i: null,
                next_sibling_i: null,
                alias: null,
                bind_number: 2
            }
        ]);
    
    });

    test("Optional array element property, spaces before ?", function() {
    
        resetPackage();

        database.call("json_core.parse_query", {
            p_query: 'person["name"]   ?'
        });

        let elements = database.call("json_core.dump").p_query_elements;

        expect(elements).to.eql([
            {
                type: "N",
                value: "person",
                optional: false,
                first_child_i: 2,
                next_sibling_i: null,
                alias: null,
                bind_number: 1
            },
            {
                type: "N",
                value: "name",
                optional: true,
                first_child_i: null,
                next_sibling_i: null,
                alias: null,
                bind_number: 2
            }
        ]);
    
    });

    test("Optional array element property, spaces after ?", function() {
    
        resetPackage();

        database.call("json_core.parse_query", {
            p_query: 'person["name"]?   '
        });

        let elements = database.call("json_core.dump").p_query_elements;

        expect(elements).to.eql([
            {
                type: "N",
                value: "person",
                optional: false,
                first_child_i: 2,
                next_sibling_i: null,
                alias: null,
                bind_number: 1
            },
            {
                type: "N",
                value: "name",
                optional: true,
                first_child_i: null,
                next_sibling_i: null,
                alias: null,
                bind_number: 2
            }
        ]);
    
    });

    test("Single wildcard", function() {
    
        resetPackage();

        database.call("json_core.parse_query", {
            p_query: '*'
        });

        let elements = database.call("json_core.dump").p_query_elements;

        expect(elements).to.eql([
            {
                type: "W",
                value: null,
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null,
                bind_number: null
            }
        ]);
    
    });

    test("Single wildcard, spaces before", function() {
    
        resetPackage();

        database.call("json_core.parse_query", {
            p_query: '   *'
        });

        let elements = database.call("json_core.dump").p_query_elements;

        expect(elements).to.eql([
            {
                type: "W",
                value: null,
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null,
                bind_number: null
            }
        ]);
    
    });

    test("Single wildcard, spaces after", function() {
    
        resetPackage();

        database.call("json_core.parse_query", {
            p_query: '*   '
        });

        let elements = database.call("json_core.dump").p_query_elements;

        expect(elements).to.eql([
            {
                type: "W",
                value: null,
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null,
                bind_number: null
            }
        ]);
    
    });

    test("Single wildcard with an alias", function() {
    
        resetPackage();

        database.call("json_core.parse_query", {
            p_query: '* as something'
        });

        let elements = database.call("json_core.dump").p_query_elements;

        expect(elements).to.eql([
            {
                type: "W",
                value: null,
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: "SOMETHING",
                bind_number: null
            }
        ]);
    
    });

    test("Optional wildcard", function() {
    
        resetPackage();

        database.call("json_core.parse_query", {
            p_query: 'persons.*?'
        });

        let elements = database.call("json_core.dump").p_query_elements;

        expect(elements).to.eql([
            {
                type: "N",
                value: "persons",
                optional: false,
                first_child_i: 2,
                next_sibling_i: null,
                alias: null,
                bind_number: 1
            },
            {
                type: "W",
                value: null,
                optional: true,
                first_child_i: null,
                next_sibling_i: null,
                alias: null,
                bind_number: null
            }
        ]);
    
    });

    test("Optional wildcard, spaces after *", function() {
    
        resetPackage();

        database.call("json_core.parse_query", {
            p_query: 'persons.*   ?'
        });

        let elements = database.call("json_core.dump").p_query_elements;

        expect(elements).to.eql([
            {
                type: "N",
                value: "persons",
                optional: false,
                first_child_i: 2,
                next_sibling_i: null,
                alias: null,
                bind_number: 1
            },
            {
                type: "W",
                value: null,
                optional: true,
                first_child_i: null,
                next_sibling_i: null,
                alias: null,
                bind_number: null
            }
        ]);
    
    });

    test("Two wildcards in a branching root", function() {
    
        resetPackage();

        database.call("json_core.dump").p_query_elements;database.call("json_core.parse_query", {
            p_query: '(*,*)'
        });

        let elements = database.call("json_core.dump").p_query_elements;

        expect(elements).to.eql([
            {
                type: "W",
                value: null,
                optional: false,
                first_child_i: null,
                next_sibling_i: 2,
                alias: null,
                bind_number: null
            },
            {
                type: "W",
                value: null,
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null,
                bind_number: null
            }
        ]);
    
    });

    test("Two wildcards in a branching root, spaces before the comma", function() {
    
        resetPackage();

        database.call("json_core.parse_query", {
            p_query: '(*   ,*)'
        });

        let elements = database.call("json_core.dump").p_query_elements;

        expect(elements).to.eql([
            {
                type: "W",
                value: null,
                optional: false,
                first_child_i: null,
                next_sibling_i: 2,
                alias: null,
                bind_number: null
            },
            {
                type: "W",
                value: null,
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null,
                bind_number: null
            }
        ]);
    
    });

    test("Two wildcards in a branching root, spaces after the comma", function() {
    
        resetPackage();

        database.call("json_core.parse_query", {
            p_query: '(*,   *)'
        });

        let elements = database.call("json_core.dump").p_query_elements;

        expect(elements).to.eql([
            {
                type: "W",
                value: null,
                optional: false,
                first_child_i: null,
                next_sibling_i: 2,
                alias: null,
                bind_number: null
            },
            {
                type: "W",
                value: null,
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null,
                bind_number: null
            }
        ]);
    
    });

    test("Two wildcards in a branching root, spaces after (", function() {
    
        resetPackage();

        database.call("json_core.parse_query", {
            p_query: '(   *,*)'
        });

        let elements = database.call("json_core.dump").p_query_elements;

        expect(elements).to.eql([
            {
                type: "W",
                value: null,
                optional: false,
                first_child_i: null,
                next_sibling_i: 2,
                alias: null,
                bind_number: null
            },
            {
                type: "W",
                value: null,
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null,
                bind_number: null
            }
        ]);
    
    });

    test("Two wildcards in a branching root, spaces before )", function() {
    
        resetPackage();

        database.call("json_core.parse_query", {
            p_query: '(*,*   )'
        });

        let elements = database.call("json_core.dump").p_query_elements;

        expect(elements).to.eql([
            {
                type: "W",
                value: null,
                optional: false,
                first_child_i: null,
                next_sibling_i: 2,
                alias: null,
                bind_number: null
            },
            {
                type: "W",
                value: null,
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null,
                bind_number: null
            }
        ]);
    
    });

    test("Wildcard property", function() {
    
        resetPackage();

        database.call("json_core.parse_query", {
            p_query: 'person.*'
        });

        let elements = database.call("json_core.dump").p_query_elements;

        expect(elements).to.eql([
            {
                type: "N",
                value: "person",
                optional: false,
                first_child_i: "2",
                next_sibling_i: null,
                alias: null,
                bind_number: 1
            },
            {
                type: "W",
                value: null,
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null,
                bind_number: null
            }
        ]);
    
    });

    test("Wildcard property, spaces after the dot", function() {
    
        resetPackage();

        database.call("json_core.parse_query", {
            p_query: 'person.   *'
        });

        let elements = database.call("json_core.dump").p_query_elements;

        expect(elements).to.eql([
            {
                type: "N",
                value: "person",
                optional: false,
                first_child_i: "2",
                next_sibling_i: null,
                alias: null,
                bind_number: 1
            },
            {
                type: "W",
                value: null,
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null,
                bind_number: null
            }
        ]);
    
    });

    test("Wildcard array elements", function() {
    
        resetPackage();

        database.call("json_core.parse_query", {
            p_query: 'person[*]'
        });

        let elements = database.call("json_core.dump").p_query_elements;

        expect(elements).to.eql([
            {
                type: "N",
                value: "person",
                optional: false,
                first_child_i: "2",
                next_sibling_i: null,
                alias: null,
                bind_number: 1
            },
            {
                type: "W",
                value: null,
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null,
                bind_number: null
            }
        ]);
    
    });

    test("Wildcard array elements, spaces after [", function() {
    
        resetPackage();

        database.call("json_core.parse_query", {
            p_query: 'person[   *]'
        });

        let elements = database.call("json_core.dump").p_query_elements;

        expect(elements).to.eql([
            {
                type: "N",
                value: "person",
                optional: false,
                first_child_i: "2",
                next_sibling_i: null,
                alias: null,
                bind_number: 1
            },
            {
                type: "W",
                value: null,
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null,
                bind_number: null
            }
        ]);
    
    });

    test("Wildcard array elements, spaces before ]", function() {
    
        resetPackage();

        database.call("json_core.parse_query", {
            p_query: 'person[*   ]'
        });

        let elements = database.call("json_core.dump").p_query_elements;

        expect(elements).to.eql([
            {
                type: "N",
                value: "person",
                optional: false,
                first_child_i: "2",
                next_sibling_i: null,
                alias: null,
                bind_number: 1
            },
            {
                type: "W",
                value: null,
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null,
                bind_number: null
            }
        ]);
    
    });

    test("Optional wildcard property with an alias", function() {
    
        resetPackage();

        database.call("json_core.parse_query", {
            p_query: 'person.*? as person_property'
        });

        let elements = database.call("json_core.dump").p_query_elements;

        expect(elements).to.eql([
            {
                type: "N",
                value: "person",
                optional: false,
                first_child_i: "2",
                next_sibling_i: null,
                alias: null,
                bind_number: 1
            },
            {
                type: "W",
                value: null,
                optional: true,
                first_child_i: null,
                next_sibling_i: null,
                alias: "PERSON_PROPERTY",
                bind_number: null
            }
        ]);
    
    });

    test("Single variable", function() {
    
        resetPackage();

        database.call("json_core.parse_query", {
            p_query: ':var'
        });

        let elements = database.call("json_core.dump").p_query_elements;

        expect(elements).to.eql([
            {
                type: ":",
                value: "VAR",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null,
                bind_number: 1
            }
        ]);
    
    });

    test("Single variable, spaces before :", function() {
    
        resetPackage();

        database.call("json_core.parse_query", {
            p_query: '   :var'
        });

        let elements = database.call("json_core.dump").p_query_elements;

        expect(elements).to.eql([
            {
                type: ":",
                value: "VAR",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null,
                bind_number: 1
            }
        ]);
    
    });

    test("Single variable, spaces after", function() {
    
        resetPackage();

        database.call("json_core.parse_query", {
            p_query: ':var  '
        });

        let elements = database.call("json_core.dump").p_query_elements;

        expect(elements).to.eql([
            {
                type: ":",
                value: "VAR",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null,
                bind_number: 1
            }
        ]);
    
    });

    test("Optional variable", function() {
    
        resetPackage();

        database.call("json_core.parse_query", {
            p_query: 'person.:var?'
        });

        let elements = database.call("json_core.dump").p_query_elements;

        expect(elements).to.eql([
            {
                type: "N",
                value: "person",
                optional: false,
                first_child_i: 2,
                next_sibling_i: null,
                alias: null,
                bind_number: 1
            },
            {
                type: ":",
                value: "VAR",
                optional: true,
                first_child_i: null,
                next_sibling_i: null,
                alias: null,
                bind_number: 1
            }
        ]);
    
    });

    test("Optional variable, spaces before ?", function() {
    
        resetPackage();

        database.call("json_core.parse_query", {
            p_query: 'person.:var ?'
        });

        let elements = database.call("json_core.dump").p_query_elements;

        expect(elements).to.eql([
            {
                type: "N",
                value: "person",
                optional: false,
                first_child_i: 2,
                next_sibling_i: null,
                alias: null,
                bind_number: 1
            },
            {
                type: ":",
                value: "VAR",
                optional: true,
                first_child_i: null,
                next_sibling_i: null,
                alias: null,
                bind_number: 1
            }
        ]);
    
    });

    test("Variable as a property", function() {
    
        resetPackage();

        database.call("json_core.parse_query", {
            p_query: 'persons.:var'
        });

        let elements = database.call("json_core.dump").p_query_elements;

        expect(elements).to.eql([
            {
                type: "N",
                value: "persons",
                optional: false,
                first_child_i: 2,
                next_sibling_i: null,
                alias: null,
                bind_number: 1
            },
            {
                type: ":",
                value: "VAR",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null,
                bind_number: 1
            }
        ]);
    
    });

    test("Variable as a property, spaces after the dot", function() {
    
        resetPackage();

        database.call("json_core.parse_query", {
            p_query: 'persons. :var'
        });

        let elements = database.call("json_core.dump").p_query_elements;

        expect(elements).to.eql([
            {
                type: "N",
                value: "persons",
                optional: false,
                first_child_i: 2,
                next_sibling_i: null,
                alias: null,
                bind_number: 1
            },
            {
                type: ":",
                value: "VAR",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null,
                bind_number: 1
            }
        ]);
    
    });

    test("Variable as an array element", function() {
    
        resetPackage();

        database.call("json_core.parse_query", {
            p_query: 'persons[:var]'
        });

        let elements = database.call("json_core.dump").p_query_elements;

        expect(elements).to.eql([
            {
                type: "N",
                value: "persons",
                optional: false,
                first_child_i: 2,
                next_sibling_i: null,
                alias: null,
                bind_number: 1
            },
            {
                type: ":",
                value: "VAR",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null,
                bind_number: 1
            }
        ]);
    
    });

    test("Variable as an array element, spaces after [", function() {
    
        resetPackage();

        database.call("json_core.parse_query", {
            p_query: 'persons[   :var]'
        });

        let elements = database.call("json_core.dump").p_query_elements;

        expect(elements).to.eql([
            {
                type: "N",
                value: "persons",
                optional: false,
                first_child_i: 2,
                next_sibling_i: null,
                alias: null,
                bind_number: 1
            },
            {
                type: ":",
                value: "VAR",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null,
                bind_number: 1
            }
        ]);
    
    });

    test("Variable as an array element, spaces before ]", function() {
    
        resetPackage();

        database.call("json_core.parse_query", {
            p_query: 'persons[:var   ]'
        });

        let elements = database.call("json_core.dump").p_query_elements;

        expect(elements).to.eql([
            {
                type: "N",
                value: "persons",
                optional: false,
                first_child_i: 2,
                next_sibling_i: null,
                alias: null,
                bind_number: 1
            },
            {
                type: ":",
                value: "VAR",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null,
                bind_number: 1
            }
        ]);
    
    });

    test("Property of a variable", function() {
    
        resetPackage();

        database.call("json_core.parse_query", {
            p_query: 'persons.:var.name'
        });

        let elements = database.call("json_core.dump").p_query_elements;

        expect(elements).to.eql([
            {
                type: "N",
                value: "persons",
                optional: false,
                first_child_i: 2,
                next_sibling_i: null,
                alias: null,
                bind_number: 1
            },
            {
                type: ":",
                value: "VAR",
                optional: false,
                first_child_i: 3,
                next_sibling_i: null,
                alias: null,
                bind_number: 1
            },
            {
                type: "N",
                value: "name",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null,
                bind_number: 2
            }
        ]);
    
    });

    test("Property of a variable, spaces after the variable", function() {
    
        resetPackage();

        database.call("json_core.parse_query", {
            p_query: 'persons.:var   .name'
        });

        let elements = database.call("json_core.dump").p_query_elements;

        expect(elements).to.eql([
            {
                type: "N",
                value: "persons",
                optional: false,
                first_child_i: 2,
                next_sibling_i: null,
                alias: null,
                bind_number: 1
            },
            {
                type: ":",
                value: "VAR",
                optional: false,
                first_child_i: 3,
                next_sibling_i: null,
                alias: null,
                bind_number: 1
            },
            {
                type: "N",
                value: "name",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null,
                bind_number: 2
            }
        ]);
    
    });

    test("Variable property in a branch", function() {
    
        resetPackage();

        database.call("json_core.parse_query", {
            p_query: 'persons(.:var1,.:var2)'
        });

        let elements = database.call("json_core.dump").p_query_elements;

        expect(elements).to.eql([
            {
                type: "N",
                value: "persons",
                optional: false,
                first_child_i: 2,
                next_sibling_i: null,
                alias: null,
                bind_number: 1
            },
            {
                type: ":",
                value: "VAR1",
                optional: false,
                first_child_i: null,
                next_sibling_i: 3,
                alias: null,
                bind_number: 1
            },
            {
                type: ":",
                value: "VAR2",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null,
                bind_number: 2
            }
        ]);
    
    });

    test("Variable property in a branch, spaces after (", function() {
    
        resetPackage();

        database.call("json_core.parse_query", {
            p_query: 'persons(   .:var1,.:var2)'
        });

        let elements = database.call("json_core.dump").p_query_elements;

        expect(elements).to.eql([
            {
                type: "N",
                value: "persons",
                optional: false,
                first_child_i: 2,
                next_sibling_i: null,
                alias: null,
                bind_number: 1
            },
            {
                type: ":",
                value: "VAR1",
                optional: false,
                first_child_i: null,
                next_sibling_i: 3,
                alias: null,
                bind_number: 1
            },
            {
                type: ":",
                value: "VAR2",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null,
                bind_number: 2
            }
        ]);
    
    });

    test("Variable property in a branch, spaces before the comma", function() {
    
        resetPackage();

        database.call("json_core.parse_query", {
            p_query: 'persons(.:var1   ,.:var2)'
        });

        let elements = database.call("json_core.dump").p_query_elements;

        expect(elements).to.eql([
            {
                type: "N",
                value: "persons",
                optional: false,
                first_child_i: 2,
                next_sibling_i: null,
                alias: null,
                bind_number: 1
            },
            {
                type: ":",
                value: "VAR1",
                optional: false,
                first_child_i: null,
                next_sibling_i: 3,
                alias: null,
                bind_number: 1
            },
            {
                type: ":",
                value: "VAR2",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null,
                bind_number: 2
            }
        ]);
    
    });

    test("Variable property in a branch, spaces after the comma", function() {
    
        resetPackage();

        database.call("json_core.parse_query", {
            p_query: 'persons(.:var1,   .:var2)'
        });

        let elements = database.call("json_core.dump").p_query_elements;

        expect(elements).to.eql([
            {
                type: "N",
                value: "persons",
                optional: false,
                first_child_i: 2,
                next_sibling_i: null,
                alias: null,
                bind_number: 1
            },
            {
                type: ":",
                value: "VAR1",
                optional: false,
                first_child_i: null,
                next_sibling_i: 3,
                alias: null,
                bind_number: 1
            },
            {
                type: ":",
                value: "VAR2",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null,
                bind_number: 2
            }
        ]);
    
    });

    test("Variable property in a branch, spaces before )", function() {
    
        resetPackage();

        database.call("json_core.parse_query", {
            p_query: 'persons(.:var1,.:var2   )'
        });

        let elements = database.call("json_core.dump").p_query_elements;

        expect(elements).to.eql([
            {
                type: "N",
                value: "persons",
                optional: false,
                first_child_i: 2,
                next_sibling_i: null,
                alias: null,
                bind_number: 1
            },
            {
                type: ":",
                value: "VAR1",
                optional: false,
                first_child_i: null,
                next_sibling_i: 3,
                alias: null,
                bind_number: 1
            },
            {
                type: ":",
                value: "VAR2",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null,
                bind_number: 2
            }
        ]);
    
    });

    test("Reserved fields _id, _key and _value", function() {
    
        resetPackage();

        database.call("json_core.parse_query", {
            p_query: 'persons.*(._id, ._key, ._value)'
        });

        let elements = database.call("json_core.dump").p_query_elements;

        expect(elements).to.eql([
            {
                type: "N",
                value: "persons",
                optional: false,
                first_child_i: 2,
                next_sibling_i: null,
                alias: null,
                bind_number: 1
            },
            {
                type: "W",
                value: null,
                optional: false,
                first_child_i: 3,
                next_sibling_i: null,
                alias: null,
                bind_number: null
            },
            {
                type: "F",
                value: "id",
                optional: false,
                first_child_i: null,
                next_sibling_i: 4,
                alias: null,
                bind_number: null
            },
            {
                type: "F",
                value: "key",
                optional: false,
                first_child_i: null,
                next_sibling_i: 5,
                alias: null,
                bind_number: null
            },
            {
                type: "F",
                value: "value",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null,
                bind_number: null
            }
        ]);
    
    });

});

suite("Anchored query parse tests", function() {

    test("Try to parse anchored empty query", function() {
    
        resetPackage();

        expect(function() {
        
            database.call("json_core.parse_query", {
                p_query: null,
                p_anchored: true
            });    
        
        }).to.throw(/JDC-00002/);
    
    });
    
    test("Parse valid anchored query", function() {
    
        resetPackage();

        database.call("json_core.parse_query", {
            p_query: 'persons[:var]',
            p_anchored: true
        });

        let elements = database.call("json_core.dump").p_query_elements;

        expect(elements).to.eql([
            {
                type: "A",
                value: null,
                optional: false,
                first_child_i: 2,
                next_sibling_i: null,
                alias: null,
                bind_number: null
            },
            {
                type: "N",
                value: "persons",
                optional: false,
                first_child_i: 3,
                next_sibling_i: null,
                alias: null,
                bind_number: 1
            },
            {
                type: ":",
                value: "VAR",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null,
                bind_number: 1
            }
        ]);
    
    });

});

suite("Query element cache tests", function() {

    let query1ElementI, query2ElementI;

    setup("Reset cache", function() {
        resetPackage();
    });

    test("Parse one query", function() {
        query1ElementI = database.call('json_core.parse_query', {
            p_query: "person.name"
        });
    });

    test("Parse another query, check if element i-s differ", function() {

        query2ElementI = database.call('json_core.parse_query', {
            p_query: "person.surname"
        });

        expect(query2ElementI).to.not.be(query1ElementI);

    });

    test("Parse the first query again, check if the same element i has been returned", function() {
    
        elementI = database.call('json_core.parse_query', {
            p_query: "person.name"
        });
    
        expect(elementI).to.be(query1ElementI);

    });
    
});

suite("Variable enumeration tests", function() {

    function getBindNumbers(elements) {

        let bindNumbers = [];

        for (let i = 0; i < elements.length; i++) {
            if (elements[i].type == ':' || elements[i].type == '#')
                bindNumbers.push(elements[i].bind_number);
        }

        return bindNumbers;

    }

    test("Single variable", function() {

        resetPackage();

        database.call("json_core.parse_query", {
            p_query: ':name'
        });

        let elements = database.call("json_core.dump").p_query_elements;
        let bindNumbers = getBindNumbers(elements);

        expect(bindNumbers).to.eql([1]);

    }); 

    test("Single ID variable", function() {

        resetPackage();

        database.call("json_core.parse_query", {
            p_query: 'person(.#id)'
        });

        let elements = database.call("json_core.dump").p_query_elements;
        let bindNumbers = getBindNumbers(elements);

        expect(bindNumbers).to.eql([1]);

    }); 

    test("Multiple different variables", function() {

        resetPackage();

        database.call("json_core.parse_query", {
            p_query: ':name.:surname.:address'
        });

        let elements = database.call("json_core.dump").p_query_elements;
        let bindNumbers = getBindNumbers(elements);

        expect(bindNumbers).to.eql([1, 2, 3]);

    }); 

    test("Two equal variables", function() {

        resetPackage();

        database.call("json_core.parse_query", {
            p_query: ':name.:name'
        });

        let elements = database.call("json_core.dump").p_query_elements;
        let bindNumbers = getBindNumbers(elements);

        expect(bindNumbers).to.eql([1, 1]);

    });

    test("Two equal, one different variables", function() {

        resetPackage();

        database.call("json_core.parse_query", {
            p_query: ':name.:name.:surname'
        });

        let elements = database.call("json_core.dump").p_query_elements;
        let bindNumbers = getBindNumbers(elements);

        expect(bindNumbers).to.eql([1, 1, 2]);

    });

    test("Two pairs of equal variables", function() {

        resetPackage();

        database.call("json_core.parse_query", {
            p_query: ':name.:surname.:name.:surname'
        });

        let elements = database.call("json_core.dump").p_query_elements;
        let bindNumbers = getBindNumbers(elements);

        expect(bindNumbers).to.eql([1, 2, 1, 2]);

    });

    test("Multiple different ID variables", function() {

        resetPackage();

        database.call("json_core.parse_query", {
            p_query: '#name.#surname.#address'
        });

        let elements = database.call("json_core.dump").p_query_elements;
        let bindNumbers = getBindNumbers(elements);

        expect(bindNumbers).to.eql([1, 2, 3]);

    }); 

    test("Two equal ID variables", function() {

        resetPackage();

        database.call("json_core.parse_query", {
            p_query: '#name.#name'
        });

        let elements = database.call("json_core.dump").p_query_elements;
        let bindNumbers = getBindNumbers(elements);

        expect(bindNumbers).to.eql([1, 1]);

    });

    test("Two equal, one different ID variables", function() {

        resetPackage();

        database.call("json_core.parse_query", {
            p_query: '#name.#name.#surname'
        });

        let elements = database.call("json_core.dump").p_query_elements;
        let bindNumbers = getBindNumbers(elements);

        expect(bindNumbers).to.eql([1, 1, 2]);

    });

    test("Two pairs of equal ID variables", function() {

        resetPackage();

        database.call("json_core.parse_query", {
            p_query: '#name.#surname.#name.#surname'
        });

        let elements = database.call("json_core.dump").p_query_elements;
        let bindNumbers = getBindNumbers(elements);

        expect(bindNumbers).to.eql([1, 2, 1, 2]);

    });

    test("Complex example with multiple variables", function() {

        resetPackage();

        database.call("json_core.parse_query", {
            p_query: '($.#id.a(.b,.:c),:a.b(.:c.d.#c,.:id))'
        });

        let elements = database.call("json_core.dump").p_query_elements;
        let bindNumbers = getBindNumbers(elements);

        expect(bindNumbers).to.eql([1, 2, 3, 2, 2, 1]);

    });
    
});
