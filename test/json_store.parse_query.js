suite("Invalid query tests", function() {

    suite("Unexpected end of the input", function() {
    
        test("Empty query", function() {
            
            expect(function() {
            
                var elements = database.call("json_store.parse_query", {
                    p_query: null
                });
            
            }).to.throw(/JDOC-00002/);

        });

        test("Empty query, spaces only", function() {
            
            expect(function() {
            
                var elements = database.call("json_store.parse_query", {
                    p_query: "   "
                });
            
            }).to.throw(/JDOC-00002/);

        });

        test("Query ends with a dot", function() {
            
            expect(function() {
            
                var elements = database.call("json_store.parse_query", {
                    p_query: "person."
                });
            
            }).to.throw(/JDOC-00002/);

        });        

        test("Query ends with a dot with spaces", function() {
            
            expect(function() {
            
                var elements = database.call("json_store.parse_query", {
                    p_query: "person.  "
                });
            
            }).to.throw(/JDOC-00002/);

        }); 

        test("Query ends with [", function() {
            
            expect(function() {
            
                var elements = database.call("json_store.parse_query", {
                    p_query: "person["
                });
            
            }).to.throw(/JDOC-00002/);

        }); 

        test("Query ends with [ and spaces", function() {
            
            expect(function() {
            
                var elements = database.call("json_store.parse_query", {
                    p_query: "person[   "
                });
            
            }).to.throw(/JDOC-00002/);

        }); 

        test("Incomplete quoted property", function() {
            
            expect(function() {
            
                var elements = database.call("json_store.parse_query", {
                    p_query: 'person["name'
                });
            
            }).to.throw(/JDOC-00002/);

        }); 

        test("Array element closing bracket ] missing", function() {
            
            expect(function() {
            
                var elements = database.call("json_store.parse_query", {
                    p_query: 'person[123'
                });
            
            }).to.throw(/JDOC-00002/);

        }); 

        test("Array element closing bracket ] missing, spaces in the end", function() {
            
            expect(function() {
            
                var elements = database.call("json_store.parse_query", {
                    p_query: 'person[123   '
                });
            
            }).to.throw(/JDOC-00002/);

        }); 

        test("Quoted property closing bracket ] missing", function() {
            
            expect(function() {
            
                var elements = database.call("json_store.parse_query", {
                    p_query: 'person["name"'
                });
            
            }).to.throw(/JDOC-00002/);

        }); 

        test("Quoted property closing bracket ] missing, spaces in the end", function() {
            
            expect(function() {
            
                var elements = database.call("json_store.parse_query", {
                    p_query: 'person["name"   '
                });
            
            }).to.throw(/JDOC-00002/);

        }); 

        test("Branched query ends with ,", function() {
            
            expect(function() {
            
                var elements = database.call("json_store.parse_query", {
                    p_query: 'person(.name,'
                });
            
            }).to.throw(/JDOC-00002/);

        }); 

        test("Branched query ends with , and spaces", function() {
            
            expect(function() {
            
                var elements = database.call("json_store.parse_query", {
                    p_query: 'person(.name,   '
                });
            
            }).to.throw(/JDOC-00002/);

        }); 

        test("Branch closing bracket missing", function() {
            
            expect(function() {
            
                var elements = database.call("json_store.parse_query", {
                    p_query: 'person(.name'
                });
            
            }).to.throw(/JDOC-00002/);

        }); 

        test("Branch closing bracket missing, spaces in the end", function() {
            
            expect(function() {
            
                var elements = database.call("json_store.parse_query", {
                    p_query: 'person(.name   '
                });
            
            }).to.throw(/JDOC-00002/);

        }); 

        test("Query ends with (", function() {
            
            expect(function() {
            
                var elements = database.call("json_store.parse_query", {
                    p_query: 'person('
                });
            
            }).to.throw(/JDOC-00002/);

        }); 

        test("Query ends with ( and spaces", function() {
            
            expect(function() {
            
                var elements = database.call("json_store.parse_query", {
                    p_query: 'person(   '
                });
            
            }).to.throw(/JDOC-00002/);

        }); 

        test("Query ends with #", function() {
            
            expect(function() {
            
                var elements = database.call("json_store.parse_query", {
                    p_query: '#'
                });
            
            }).to.throw(/JDOC-00002/);

        }); 

        test("Query ends with :", function() {
            
            expect(function() {
            
                var elements = database.call("json_store.parse_query", {
                    p_query: '#'
                });
            
            }).to.throw(/JDOC-00002/);

        }); 

        test('Query ends with "as"', function() {
            
            expect(function() {
            
                var elements = database.call("json_store.parse_query", {
                    p_query: 'person.name as'
                });
            
            }).to.throw(/JDOC-00002/);

        }); 

        test('Query ends with "as" and spaces', function() {
            
            expect(function() {
            
                var elements = database.call("json_store.parse_query", {
                    p_query: 'person.name as   '
                });
            
            }).to.throw(/JDOC-00002/);

        }); 

        test("Incomplete quoted alias", function() {
            
            expect(function() {
            
                var elements = database.call("json_store.parse_query", {
                    p_query: 'person.name as "name'
                });
            
            }).to.throw(/JDOC-00002/);

        }); 

        test("Missing escaped character in the end", function() {
            
            expect(function() {
            
                var elements = database.call("json_store.parse_query", {
                    p_query: 'person["name\\'
                });
            
            }).to.throw(/JDOC-00002/);

        }); 

        test('Incomplete "as"', function() {
            
            expect(function() {
            
                var elements = database.call("json_store.parse_query", {
                    p_query: 'person.name a'
                });
            
            }).to.throw(/JDOC-00002/);

        }); 
    
    });

    suite("Unexpected character", function() {
    
        test("Unexpected characted in the beginning", function() {
        
            expect(function() {
            
                var elements = database.call("json_store.parse_query", {
                    p_query: ".name"
                });
            
            }).to.throw(/JDOC-00001/);
        
        });
        
        test("Spaces and unexpected characted in the beginning", function() {
        
            expect(function() {
            
                var elements = database.call("json_store.parse_query", {
                    p_query: "  .name"
                });
            
            }).to.throw(/JDOC-00001/);
        
        });

        test("Unexpected characted when expected the first child in a branch", function() {
        
            expect(function() {
            
                var elements = database.call("json_store.parse_query", {
                    p_query: "person.(a"
                });
            
            }).to.throw(/JDOC-00001/);
        
        });

        test("Unexpected characted when expected the n-th child in a branch", function() {
        
            expect(function() {
            
                var elements = database.call("json_store.parse_query", {
                    p_query: "person.(.name,surname"
                });
            
            }).to.throw(/JDOC-00001/);
        
        });

        test("Unexpected characted in the simple property", function() {
        
            expect(function() {
            
                var elements = database.call("json_store.parse_query", {
                    p_query: "person.name^"
                });
            
            }).to.throw(/JDOC-00001/);
        
        });

        test("Unexpected comma in a non-branching query", function() {
        
            expect(function() {
            
                var elements = database.call("json_store.parse_query", {
                    p_query: "person.name,"
                });
            
            }).to.throw(/JDOC-00015/);
        
        });

        test("Unexpected spaces and comma in a non-branching query", function() {
        
            expect(function() {
            
                var elements = database.call("json_store.parse_query", {
                    p_query: "person.name  ,"
                });
            
            }).to.throw(/JDOC-00015/);
        
        });

        test("Unexpected ) in a non-branching query", function() {
        
            expect(function() {
            
                var elements = database.call("json_store.parse_query", {
                    p_query: "person.name)"
                });
            
            }).to.throw(/JDOC-00015/);
        
        });

        test("Unexpected ) and comma in a non-branching query", function() {
        
            expect(function() {
            
                var elements = database.call("json_store.parse_query", {
                    p_query: "person.name  )"
                });
            
            }).to.throw(/JDOC-00015/);
        
        });

        test("Unexpected character in the simple property", function() {
        
            expect(function() {
            
                var elements = database.call("json_store.parse_query", {
                    p_query: "person.name^"
                });
            
            }).to.throw(/JDOC-00001/);
        
        });

        test("Unexpected character after the branch close", function() {
        
            expect(function() {
            
                var elements = database.call("json_store.parse_query", {
                    p_query: "person(.name).surname"
                });
            
            }).to.throw(/JDOC-00001/);
        
        });

        test("Unexpected spaces and a character after the branch close", function() {
        
            expect(function() {
            
                var elements = database.call("json_store.parse_query", {
                    p_query: "person(.name)   .surname"
                });
            
            }).to.throw(/JDOC-00001/);
        
        });

        test("Unexpected spaces and a character after an aliased property", function() {
        
            expect(function() {
            
                var elements = database.call("json_store.parse_query", {
                    p_query: "person as person  .surname"
                });
            
            }).to.throw(/JDOC-00001/);
        
        });

        test("Unexpected character after an quoted alias", function() {
        
            expect(function() {
            
                var elements = database.call("json_store.parse_query", {
                    p_query: 'person as "person".surname'
                });
            
            }).to.throw(/JDOC-00001/);
        
        });

        test("Unexpected spaces and a character after an quoted alias", function() {
        
            expect(function() {
            
                var elements = database.call("json_store.parse_query", {
                    p_query: 'person as "person"  .surname'
                });
            
            }).to.throw(/JDOC-00001/);
        
        });

        test("Unexpected character after a wildcard", function() {
        
            expect(function() {
            
                var elements = database.call("json_store.parse_query", {
                    p_query: "* name"
                });
            
            }).to.throw(/JDOC-00001/);
        
        });

        test("Unexpected character after a simple name", function() {
        
            expect(function() {
            
                var elements = database.call("json_store.parse_query", {
                    p_query: "name surname"
                });
            
            }).to.throw(/JDOC-00001/);
        
        });

        test("Unexpected character after a simple optional name", function() {
        
            expect(function() {
            
                var elements = database.call("json_store.parse_query", {
                    p_query: "name? surname"
                });
            
            }).to.throw(/JDOC-00001/);
        
        });

        test("Unexpected character after an ID reference", function() {
        
            expect(function() {
            
                var elements = database.call("json_store.parse_query", {
                    p_query: "#123 surname"
                });
            
            }).to.throw(/JDOC-00001/);
        
        });

        test("Unexpected character after an optional ID refernce", function() {
        
            expect(function() {
            
                var elements = database.call("json_store.parse_query", {
                    p_query: "#123? surname"
                });
            
            }).to.throw(/JDOC-00001/);
        
        });

        test("Unexpected character after an array element", function() {
        
            expect(function() {
            
                var elements = database.call("json_store.parse_query", {
                    p_query: "persons[123] name"
                });
            
            }).to.throw(/JDOC-00001/);
        
        });

        test("Unexpected character after an optional array element", function() {
        
            expect(function() {
            
                var elements = database.call("json_store.parse_query", {
                    p_query: "persons[123]? name"
                });
            
            }).to.throw(/JDOC-00001/);
        
        });

        test("Unexpected character after in a variable name", function() {
        
            expect(function() {
            
                var elements = database.call("json_store.parse_query", {
                    p_query: ":2 name"
                });
            
            }).to.throw(/JDOC-00001/);
        
        });

        test("Unexpected character after a variable", function() {
        
            expect(function() {
            
                var elements = database.call("json_store.parse_query", {
                    p_query: ":2 name"
                });
            
            }).to.throw(/JDOC-00001/);
        
        });

        test("Unexpected character after an optional variable", function() {
        
            expect(function() {
            
                var elements = database.call("json_store.parse_query", {
                    p_query: ":2?name"
                });
            
            }).to.throw(/JDOC-00001/);
        
        });

        test("Unexpected character after #", function() {
        
            expect(function() {
            
                var elements = database.call("json_store.parse_query", {
                    p_query: "#name"
                });
            
            }).to.throw(/JDOC-00001/);
        
        });

        test("Unexpected character in an ID reference", function() {
        
            expect(function() {
            
                var elements = database.call("json_store.parse_query", {
                    p_query: "#123n"
                });
            
            }).to.throw(/JDOC-00001/);
        
        });

        test("Unexpected character after [", function() {
        
            expect(function() {
            
                var elements = database.call("json_store.parse_query", {
                    p_query: "persons[name"
                });
            
            }).to.throw(/JDOC-00001/);
        
        });

        test("Unexpected character in an array element", function() {
        
            expect(function() {
            
                var elements = database.call("json_store.parse_query", {
                    p_query: "persons[123abc"
                });
            
            }).to.throw(/JDOC-00001/);
        
        });

        test("Unexpected character in an array element before ]", function() {
        
            expect(function() {
            
                var elements = database.call("json_store.parse_query", {
                    p_query: "persons[123 123]"
                });
            
            }).to.throw(/JDOC-00001/);
        
        });

        test('Invalid "as"', function() {
        
            expect(function() {
            
                var elements = database.call("json_store.parse_query", {
                    p_query: "persons.name ab name"
                });
            
            }).to.throw(/JDOC-00001/);
        
        });

        test('No space after "as"', function() {
        
            expect(function() {
            
                var elements = database.call("json_store.parse_query", {
                    p_query: "persons.name asname"
                });
            
            }).to.throw(/JDOC-00001/);
        
        });

        test("Invalid alias start", function() {
        
            expect(function() {
            
                var elements = database.call("json_store.parse_query", {
                    p_query: "persons.name as 123"
                });
            
            }).to.throw(/JDOC-00001/);
        
        });

        test("Unexpected character in an alias" , function() {
        
            expect(function() {
            
                var elements = database.call("json_store.parse_query", {
                    p_query: "persons.name as name^"
                });
            
            }).to.throw(/JDOC-00001/);
        
        });

        test("Invalid variable start", function() {
        
            expect(function() {
            
                var elements = database.call("json_store.parse_query", {
                    p_query: "persons.:abc"
                });
            
            }).to.throw(/JDOC-00001/);
        
        });

        test("Unexpected character in a variable" , function() {
        
            expect(function() {
            
                var elements = database.call("json_store.parse_query", {
                    p_query: ":23a"
                });
            
            }).to.throw(/JDOC-00001/);
        
        });

        test("Invalid array element variable start", function() {
        
            expect(function() {
            
                var elements = database.call("json_store.parse_query", {
                    p_query: "persons[:abc"
                });
            
            }).to.throw(/JDOC-00001/);
        
        });

        test("Unexpected character in an array element variable" , function() {
        
            expect(function() {
            
                var elements = database.call("json_store.parse_query", {
                    p_query: "persons[:123a"
                });
            
            }).to.throw(/JDOC-00001/);
        
        });
        
        test("Empty branch" , function() {
        
            expect(function() {
            
                var elements = database.call("json_store.parse_query", {
                    p_query: "persons[123]()"
                });
            
            }).to.throw(/JDOC-00001/);
        
        });

        test("Empty branch with spaces" , function() {
        
            expect(function() {
            
                var elements = database.call("json_store.parse_query", {
                    p_query: "persons[123](   )"
                });
            
            }).to.throw(/JDOC-00001/);
        
        });

    });

    suite("Other errors", function() {
    
        test("Optional root", function() {
        
            expect(function() {
            
                var elements = database.call("json_store.parse_query", {
                    p_query: "$?"
                });
            
            }).to.throw(/JDOC-00022/);
        
        });

        test("Alias too long", function() {
        
            expect(function() {
            
                var elements = database.call("json_store.parse_query", {
                    p_query: "person as abcabcabcabcabcabcabcabcabcabcA"
                });
            
            }).to.throw(/JDOC-00017/);
        
        });
        
        test("Variable number too big", function() {
        
            expect(function() {
            
                var elements = database.call("json_store.parse_query", {
                    p_query: "person.$"
                });
            
            }).to.throw(/JDOC-00006/);
        
        });

        test("Root requested as a property", function() {
        
            expect(function() {
            
                var elements = database.call("json_store.parse_query", {
                    p_query: ":25"
                });
            
            }).to.throw(/JDOC-00021/);
        
        });

        test("Root only", function() {
    
            expect(function() {
            
                var elements = database.call("json_store.parse_query", {
                    p_query: "$"
                });
            
            }).to.throw(/JDOC-00006/);
        
        });
    
        test("Root only, spaces before $", function() {
        
            expect(function() {
            
                var elements = database.call("json_store.parse_query", {
                    p_query: "   $"
                });
            
            }).to.throw(/JDOC-00006/);

        });
    
        test("Root only, spaces after $", function() {
        
            expect(function() {
            
                var elements = database.call("json_store.parse_query", {
                    p_query: "$   "
                });
            
            }).to.throw(/JDOC-00006/);
            
        });

        test("Branched root with two roots", function() {
    
            expect(function() {
            
                var elements = database.call("json_store.parse_query", {
                    p_query: "($, $)"
                });    
            
            }).to.throw(/JDOC-00006/);
        
        });
    
    });

});

suite("Valid query tests", function() {

    test("One simple name", function() {
    
        var elements = database.call("json_store.parse_query", {
            p_query: "person"
        });

        expect(elements).to.eql([
            {
                type: "N",
                value: "person",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null
            }
        ]);
    
    });

    test("One simple name with all allowed characters", function() {
    
        var elements = database.call("json_store.parse_query", {
            p_query: "qwertyuioplkjhgfdsazxcvbnmQWERTYUIOPLKJHGFDSAXZXCVBNM1234567890_$"
        });

        expect(elements).to.eql([
            {
                type: "N",
                value: "qwertyuioplkjhgfdsazxcvbnmQWERTYUIOPLKJHGFDSAXZXCVBNM1234567890_$",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null
            }
        ]);
    
    });

    test("One simple name with spaces in the beginning", function() {
    
        var elements = database.call("json_store.parse_query", {
            p_query: "    person"
        });

        expect(elements).to.eql([
            {
                type: "N",
                value: "person",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null
            }
        ]);
    
    });

    test("One simple name with spaces in the end", function() {
    
        var elements = database.call("json_store.parse_query", {
            p_query: "person    "
        });

        expect(elements).to.eql([
            {
                type: "N",
                value: "person",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null
            }
        ]);
    
    });

    test("Two simple names dot-separated", function() {
    
        var elements = database.call("json_store.parse_query", {
            p_query: "person.name"
        });

        expect(elements).to.eql([
            {
                type: "N",
                value: "person",
                optional: false,
                first_child_i: 2,
                next_sibling_i: null,
                alias: null
            },
            {
                type: "N",
                value: "name",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null
            }
        ]);
    
    });

    test("Two simple names dot-separated, spaces before the dot", function() {
    
        var elements = database.call("json_store.parse_query", {
            p_query: "person   .name"
        });

        expect(elements).to.eql([
            {
                type: "N",
                value: "person",
                optional: false,
                first_child_i: 2,
                next_sibling_i: null,
                alias: null
            },
            {
                type: "N",
                value: "name",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null
            }
        ]);
    
    });

    test("Two simple names dot-separated, spaces after the dot", function() {
    
        var elements = database.call("json_store.parse_query", {
            p_query: "person.   name"
        });

        expect(elements).to.eql([
            {
                type: "N",
                value: "person",
                optional: false,
                first_child_i: 2,
                next_sibling_i: null,
                alias: null
            },
            {
                type: "N",
                value: "name",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null
            }
        ]);
    
    });

    test("Multiple simple names dot-separated", function() {
    
        var elements = database.call("json_store.parse_query", {
            p_query: "person   .  address .street.house   "
        });

        expect(elements).to.eql([
            {
                type: "N",
                value: "person",
                optional: false,
                first_child_i: 2,
                next_sibling_i: null,
                alias: null
            },
            {
                type: "N",
                value: "address",
                optional: false,
                first_child_i: 3,
                next_sibling_i: null,
                alias: null
            },
            {
                type: "N",
                value: "street",
                optional: false,
                first_child_i: 4,
                next_sibling_i: null,
                alias: null
            },
            {
                type: "N",
                value: "house",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null
            }
        ]);
    
    });

    test("Branching root with one simple name", function() {
    
        var elements = database.call("json_store.parse_query", {
            p_query: "(name)"
        });

        expect(elements).to.eql([
            {
                type: "N",
                value: "name",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null
            }
        ]);
    
    });

    test("Branching root with one simple name, spaces in the beginning", function() {
    
        var elements = database.call("json_store.parse_query", {
            p_query: "   (name)"
        });

        expect(elements).to.eql([
            {
                type: "N",
                value: "name",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null
            }
        ]);
    
    });

    test("Branching root with one simple name, spaces after the opening bracket", function() {
    
        var elements = database.call("json_store.parse_query", {
            p_query: "(   name)"
        });

        expect(elements).to.eql([
            {
                type: "N",
                value: "name",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null
            }
        ]);
    
    });

    test("Branching root with one simple name, spaces before the closing bracket", function() {
    
        var elements = database.call("json_store.parse_query", {
            p_query: "(name   )"
        });

        expect(elements).to.eql([
            {
                type: "N",
                value: "name",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null
            }
        ]);
    
    });

    test("Branching root with one simple name, spaces in the end", function() {
    
        var elements = database.call("json_store.parse_query", {
            p_query: "(name)   "
        });

        expect(elements).to.eql([
            {
                type: "N",
                value: "name",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null
            }
        ]);
    
    });

    test("Branching root with two simple names", function() {
    
        var elements = database.call("json_store.parse_query", {
            p_query: "(name,surname)"
        });

        expect(elements).to.eql([
            {
                type: "N",
                value: "name",
                optional: false,
                first_child_i: null,
                next_sibling_i: 2,
                alias: null
            },
            {
                type: "N",
                value: "surname",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null
            }
        ]);
    
    });

    test("Branching root with two simple names, spaces before the comma", function() {
    
        var elements = database.call("json_store.parse_query", {
            p_query: "(name   ,surname)"
        });

        expect(elements).to.eql([
            {
                type: "N",
                value: "name",
                optional: false,
                first_child_i: null,
                next_sibling_i: 2,
                alias: null
            },
            {
                type: "N",
                value: "surname",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null
            }
        ]);
    
    });

    test("Branching root with two simple names, spaces after the comma", function() {
    
        var elements = database.call("json_store.parse_query", {
            p_query: "(name,   surname)"
        });

        expect(elements).to.eql([
            {
                type: "N",
                value: "name",
                optional: false,
                first_child_i: null,
                next_sibling_i: 2,
                alias: null
            },
            {
                type: "N",
                value: "surname",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null
            }
        ]);
    
    });

    test("Branching element with one simple name", function() {
    
        var elements = database.call("json_store.parse_query", {
            p_query: "person(.name)"
        });

        expect(elements).to.eql([
            {
                type: "N",
                value: "person",
                optional: false,
                first_child_i: 2,
                next_sibling_i: null,
                alias: null
            },
            {
                type: "N",
                value: "name",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null
            }
        ]);
    
    });

    test("Branching element with one simple name, spaces before opening bracket", function() {
    
        var elements = database.call("json_store.parse_query", {
            p_query: "person   (.name)"
        });

        expect(elements).to.eql([
            {
                type: "N",
                value: "person",
                optional: false,
                first_child_i: 2,
                next_sibling_i: null,
                alias: null
            },
            {
                type: "N",
                value: "name",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null
            }
        ]);
    
    });

    test("Branching element with one simple name, spaces before the dot", function() {
    
        var elements = database.call("json_store.parse_query", {
            p_query: "person(   .name)"
        });

        expect(elements).to.eql([
            {
                type: "N",
                value: "person",
                optional: false,
                first_child_i: 2,
                next_sibling_i: null,
                alias: null
            },
            {
                type: "N",
                value: "name",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null
            }
        ]);
    
    });

    test("Branching element with one simple name, spaces after the dot", function() {
    
        var elements = database.call("json_store.parse_query", {
            p_query: "person(.   name)"
        });

        expect(elements).to.eql([
            {
                type: "N",
                value: "person",
                optional: false,
                first_child_i: 2,
                next_sibling_i: null,
                alias: null
            },
            {
                type: "N",
                value: "name",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null
            }
        ]);
    
    });

    test("Branching element with two simple names", function() {
    
        var elements = database.call("json_store.parse_query", {
            p_query: "person(.name, .surname)"
        });

        expect(elements).to.eql([
            {
                type: "N",
                value: "person",
                optional: false,
                first_child_i: 2,
                next_sibling_i: null,
                alias: null
            },
            {
                type: "N",
                value: "name",
                optional: false,
                first_child_i: null,
                next_sibling_i: 3,
                alias: null
            },
            {
                type: "N",
                value: "surname",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null
            }
        ]);
    
    });

    test("Complex branching query with simple names 1", function() {
    
        var elements = database.call("json_store.parse_query", {
            p_query: "person(.name, .surname, .address(.street, .city))"
        });

        expect(elements).to.eql([
            {
                type: "N",
                value: "person",
                optional: false,
                first_child_i: 2,
                next_sibling_i: null,
                alias: null
            },
            {
                type: "N",
                value: "name",
                optional: false,
                first_child_i: null,
                next_sibling_i: 3,
                alias: null
            },
            {
                type: "N",
                value: "surname",
                optional: false,
                first_child_i: null,
                next_sibling_i: 4,
                alias: null
            },
            {
                type: "N",
                value: "address",
                optional: false,
                first_child_i: 5,
                next_sibling_i: null,
                alias: null
            },
            {
                type: "N",
                value: "street",
                optional: false,
                first_child_i: null,
                next_sibling_i: 6,
                alias: null
            },
            {
                type: "N",
                value: "city",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null
            }
        ]);
    
    });

    test("Complex branching query with simple names 2", function() {
    
        var elements = database.call("json_store.parse_query", {
            p_query: "person(.name, .surname, .address(.street, .city), .birthDate)"
        });

        expect(elements).to.eql([
            {
                type: "N",
                value: "person",
                optional: false,
                first_child_i: 2,
                next_sibling_i: null,
                alias: null
            },
            {
                type: "N",
                value: "name",
                optional: false,
                first_child_i: null,
                next_sibling_i: 3,
                alias: null
            },
            {
                type: "N",
                value: "surname",
                optional: false,
                first_child_i: null,
                next_sibling_i: 4,
                alias: null
            },
            {
                type: "N",
                value: "address",
                optional: false,
                first_child_i: 5,
                next_sibling_i: 7,
                alias: null
            },
            {
                type: "N",
                value: "street",
                optional: false,
                first_child_i: null,
                next_sibling_i: 6,
                alias: null
            },
            {
                type: "N",
                value: "city",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null
            },
            {
                type: "N",
                value: "birthDate",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null
            }
        ]);
    
    });

    test("Property of the root", function() {
    
        var elements = database.call("json_store.parse_query", {
            p_query: "$.persons"
        });

        expect(elements).to.eql([
            {
                type: "R",
                value: null,
                optional: false,
                first_child_i: 2,
                next_sibling_i: null,
                alias: null
            },
            {
                type: "N",
                value: "persons",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null
            }
        ]);
    
    });

    test("Property of the root, spaces after $", function() {
    
        var elements = database.call("json_store.parse_query", {
            p_query: "$.persons"
        });

        expect(elements).to.eql([
            {
                type: "R",
                value: null,
                optional: false,
                first_child_i: 2,
                next_sibling_i: null,
                alias: null
            },
            {
                type: "N",
                value: "persons",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null
            }
        ]);
    
    });

    test("Array element of the root", function() {
    
        var elements = database.call("json_store.parse_query", {
            p_query: "$[123]"
        });

        expect(elements).to.eql([
            {
                type: "R",
                value: null,
                optional: false,
                first_child_i: 2,
                next_sibling_i: null,
                alias: null
            },
            {
                type: "N",
                value: "123",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null
            }
        ]);
    
    });

    test("Array element of the root, spaces after $", function() {
    
        var elements = database.call("json_store.parse_query", {
            p_query: "$   [123]"
        });

        expect(elements).to.eql([
            {
                type: "R",
                value: null,
                optional: false,
                first_child_i: 2,
                next_sibling_i: null,
                alias: null
            },
            {
                type: "N",
                value: "123",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null
            }
        ]);
    
    });

    test("Single ID reference", function() {
    
        var elements = database.call("json_store.parse_query", {
            p_query: "#123"
        });

        expect(elements).to.eql([
            {
                type: "I",
                value: "123",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null
            }
        ]);
    
    });

    test("Single ID reference, spaces before #", function() {
    
        var elements = database.call("json_store.parse_query", {
            p_query: "   #123"
        });

        expect(elements).to.eql([
            {
                type: "I",
                value: "123",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null
            }
        ]);
    
    });

    test("Single ID reference, spaces after ID", function() {
    
        var elements = database.call("json_store.parse_query", {
            p_query: "#123   "
        });

        expect(elements).to.eql([
            {
                type: "I",
                value: "123",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null
            }
        ]);
    
    });

    test("Simple name property of an ID reference", function() {
    
        var elements = database.call("json_store.parse_query", {
            p_query: "#123.name"
        });

        expect(elements).to.eql([
            {
                type: "I",
                value: "123",
                optional: false,
                first_child_i: 2,
                next_sibling_i: null,
                alias: null
            },
            {
                type: "N",
                value: "name",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null
            }
        ]);
    
    });

    test("Simple name property of an ID reference, spaces before the dot", function() {
    
        var elements = database.call("json_store.parse_query", {
            p_query: "#123   .name"
        });

        expect(elements).to.eql([
            {
                type: "I",
                value: "123",
                optional: false,
                first_child_i: 2,
                next_sibling_i: null,
                alias: null
            },
            {
                type: "N",
                value: "name",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null
            }
        ]);
    
    });

    test("ID reference as a property", function() {
    
        var elements = database.call("json_store.parse_query", {
            p_query: "person.#123"
        });

        expect(elements).to.eql([
            {
                type: "N",
                value: "person",
                optional: false,
                first_child_i: 2,
                next_sibling_i: null,
                alias: null
            },
            {
                type: "I",
                value: "123",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null
            }
        ]);
    
    });

    test("ID reference as a property, spaces before #", function() {
    
        var elements = database.call("json_store.parse_query", {
            p_query: "person.   #123"
        });

        expect(elements).to.eql([
            {
                type: "N",
                value: "person",
                optional: false,
                first_child_i: 2,
                next_sibling_i: null,
                alias: null
            },
            {
                type: "I",
                value: "123",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null
            }
        ]);
    
    });

    test("ID references as branched properties", function() {
    
        var elements = database.call("json_store.parse_query", {
            p_query: "person(.#123, .#321)"
        });

        expect(elements).to.eql([
            {
                type: "N",
                value: "person",
                optional: false,
                first_child_i: 2,
                next_sibling_i: null,
                alias: null
            },
            {
                type: "I",
                value: "123",
                optional: false,
                first_child_i: null,
                next_sibling_i: 3,
                alias: null
            },
            {
                type: "I",
                value: "321",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null
            }
        ]);
    
    });

    test("ID reference parent of a branch", function() {
    
        var elements = database.call("json_store.parse_query", {
            p_query: "#123(.name, .surname)"
        });

        expect(elements).to.eql([
            {
                type: "I",
                value: "123",
                optional: false,
                first_child_i: 2,
                next_sibling_i: null,
                alias: null
            },
            {
                type: "N",
                value: "name",
                optional: false,
                first_child_i: null,
                next_sibling_i: 3,
                alias: null
            },
            {
                type: "N",
                value: "surname",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null
            }
        ]);
    
    });

    test("ID reference parent of a branch, spaces before (", function() {
    
        var elements = database.call("json_store.parse_query", {
            p_query: "#123   (.name, .surname)"
        });

        expect(elements).to.eql([
            {
                type: "I",
                value: "123",
                optional: false,
                first_child_i: 2,
                next_sibling_i: null,
                alias: null
            },
            {
                type: "N",
                value: "name",
                optional: false,
                first_child_i: null,
                next_sibling_i: 3,
                alias: null
            },
            {
                type: "N",
                value: "surname",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null
            }
        ]);
    
    });

    test("Single array element", function() {
    
        var elements = database.call("json_store.parse_query", {
            p_query: "[123]"
        });

        expect(elements).to.eql([
            {
                type: "N",
                value: "123",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null
            }
        ]);
    
    });

    test("Single array element, spaces before [", function() {
    
        var elements = database.call("json_store.parse_query", {
            p_query: "   [123]"
        });

        expect(elements).to.eql([
            {
                type: "N",
                value: "123",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null
            }
        ]);
    
    });

    test("Single array element, spaces after [", function() {
    
        var elements = database.call("json_store.parse_query", {
            p_query: "[   123]"
        });

        expect(elements).to.eql([
            {
                type: "N",
                value: "123",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null
            }
        ]);
    
    });

    test("Single array element, spaces before ]", function() {
    
        var elements = database.call("json_store.parse_query", {
            p_query: "[123    ]"
        });

        expect(elements).to.eql([
            {
                type: "N",
                value: "123",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null
            }
        ]);
    
    });

    test("Single array element, spaces after ]", function() {
    
        var elements = database.call("json_store.parse_query", {
            p_query: "[123]  "
        });

        expect(elements).to.eql([
            {
                type: "N",
                value: "123",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null
            }
        ]);
    
    });

    test("Array element of a name", function() {
    
        var elements = database.call("json_store.parse_query", {
            p_query: "persons[123]"
        });

        expect(elements).to.eql([
            {
                type: "N",
                value: "persons",
                optional: false,
                first_child_i: 2,
                next_sibling_i: null,
                alias: null
            },
            {
                type: "N",
                value: "123",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null
            }
        ]);
    
    });

    test("Array element of a name,spaces before [", function() {
    
        var elements = database.call("json_store.parse_query", {
            p_query: "persons   [123]"
        });

        expect(elements).to.eql([
            {
                type: "N",
                value: "persons",
                optional: false,
                first_child_i: 2,
                next_sibling_i: null,
                alias: null
            },
            {
                type: "N",
                value: "123",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null
            }
        ]);
    
    });

    test("Array element of an ID reference", function() {
    
        var elements = database.call("json_store.parse_query", {
            p_query: "#123[321]"
        });

        expect(elements).to.eql([
            {
                type: "I",
                value: "123",
                optional: false,
                first_child_i: 2,
                next_sibling_i: null,
                alias: null
            },
            {
                type: "N",
                value: "321",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null
            }
        ]);
    
    });

    test("Array element of an ID reference, spaces before [", function() {
    
        var elements = database.call("json_store.parse_query", {
            p_query: "#123   [321]"
        });

        expect(elements).to.eql([
            {
                type: "I",
                value: "123",
                optional: false,
                first_child_i: 2,
                next_sibling_i: null,
                alias: null
            },
            {
                type: "N",
                value: "321",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null
            }
        ]);
    
    });

    test("Array element of an array element", function() {
    
        var elements = database.call("json_store.parse_query", {
            p_query: "[123][321]"
        });

        expect(elements).to.eql([
            {
                type: "N",
                value: "123",
                optional: false,
                first_child_i: 2,
                next_sibling_i: null,
                alias: null
            },
            {
                type: "N",
                value: "321",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null
            }
        ]);
    
    });

    test("Array element of an array element, spaces between elements", function() {
    
        var elements = database.call("json_store.parse_query", {
            p_query: "[123]   [321]"
        });

        expect(elements).to.eql([
            {
                type: "N",
                value: "123",
                optional: false,
                first_child_i: 2,
                next_sibling_i: null,
                alias: null
            },
            {
                type: "N",
                value: "321",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null
            }
        ]);
    
    });

    test("Single quoted name", function() {
    
        var elements = database.call("json_store.parse_query", {
            p_query: '["person"]'
        });

        expect(elements).to.eql([
            {
                type: "N",
                value: "person",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null
            }
        ]);
    
    });

    test("Single quoted name, spaces after [", function() {
    
        var elements = database.call("json_store.parse_query", {
            p_query: '[   "person"]'
        });

        expect(elements).to.eql([
            {
                type: "N",
                value: "person",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null
            }
        ]);
    
    });

    test("Single quoted name, spaces before ]", function() {
    
        var elements = database.call("json_store.parse_query", {
            p_query: '["person"   ]'
        });

        expect(elements).to.eql([
            {
                type: "N",
                value: "person",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null
            }
        ]);
    
    });

    test("Single quoted name, spaces before ]", function() {
    
        var elements = database.call("json_store.parse_query", {
            p_query: '["person"   ]'
        });

        expect(elements).to.eql([
            {
                type: "N",
                value: "person",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null
            }
        ]);
    
    });

    test("Single quoted name with escaped characters", function() {
    
        var elements = database.call("json_store.parse_query", {
            p_query: '["\\\\\\""]'
        });

        expect(elements).to.eql([
            {
                type: "N",
                value: "\\\"",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null
            }
        ]);
    
    });

    test("Branched query with combined element types", function() {
    
        var elements = database.call("json_store.parse_query", {
            p_query: '["persons"][123](.name, ["surname"], .#321)'
        });

        expect(elements).to.eql([
            {
                type: "N",
                value: "persons",
                optional: false,
                first_child_i: 2,
                next_sibling_i: null,
                alias: null
            },
            {
                type: "N",
                value: "123",
                optional: false,
                first_child_i: 3,
                next_sibling_i: null,
                alias: null
            },
            {
                type: "N",
                value: "name",
                optional: false,
                first_child_i: null,
                next_sibling_i: 4,
                alias: null
            },
            {
                type: "N",
                value: "surname",
                optional: false,
                first_child_i: null,
                next_sibling_i: 5,
                alias: null
            },
            {
                type: "I",
                value: "321",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null
            }
        ]);
    
    });

    test("Simple name with an alias, lower case 'as'", function() {
    
        var elements = database.call("json_store.parse_query", {
            p_query: 'person as human'
        });

        expect(elements).to.eql([
            {
                type: "N",
                value: "person",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: "HUMAN"
            }
        ]);
    
    });

    test("Simple name with an alias, mixed case 'as'", function() {
    
        var elements = database.call("json_store.parse_query", {
            p_query: 'person aS human'
        });

        expect(elements).to.eql([
            {
                type: "N",
                value: "person",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: "HUMAN"
            }
        ]);
    
    });

    test("Simple name with a quoted alias", function() {
    
        var elements = database.call("json_store.parse_query", {
            p_query: 'person as "human"'
        });

        expect(elements).to.eql([
            {
                type: "N",
                value: "person",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: "human"
            }
        ]);
    
    });

    test("ID reference with an alias", function() {
    
        var elements = database.call("json_store.parse_query", {
            p_query: '#123 as human'
        });

        expect(elements).to.eql([
            {
                type: "I",
                value: "123",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: "HUMAN"
            }
        ]);
    
    });

    test("Simple name property with an alias", function() {
    
        var elements = database.call("json_store.parse_query", {
            p_query: 'person.name as person_name'
        });

        expect(elements).to.eql([
            {
                type: "N",
                value: "person",
                optional: false,
                first_child_i: 2,
                next_sibling_i: null,
                alias: null
            },
            {
                type: "N",
                value: "name",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: "PERSON_NAME"
            }
        ]);
    
    });

    test("Quoted name property with an alias", function() {
    
        var elements = database.call("json_store.parse_query", {
            p_query: 'person["name"] as person_name'
        });

        expect(elements).to.eql([
            {
                type: "N",
                value: "person",
                optional: false,
                first_child_i: 2,
                next_sibling_i: null,
                alias: null
            },
            {
                type: "N",
                value: "name",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: "PERSON_NAME"
            }
        ]);
    
    });

    test("Alias in a branch", function() {
    
        var elements = database.call("json_store.parse_query", {
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

        expect(elements).to.eql([
            {
                type: "N",
                value: "person",
                optional: false,
                first_child_i: 2,
                next_sibling_i: null,
                alias: null
            },
            {
                type: "N",
                value: "name",
                optional: false,
                first_child_i: null,
                next_sibling_i: 3,
                alias: "PERSON_NAME"
            },
            {
                type: "N",
                value: "surname",
                optional: false,
                first_child_i: null,
                next_sibling_i: 4,
                alias: "PERSON_SURNAME"
            },
            {
                type: "N",
                value: "phones",
                optional: false,
                first_child_i: 5,
                next_sibling_i: null,
                alias: null
            },
            {
                type: "N",
                value: "0",
                optional: false,
                first_child_i: 6,
                next_sibling_i: null,
                alias: null
            },
            {
                type: "N",
                value: "type",
                optional: false,
                first_child_i: null,
                next_sibling_i: 7,
                alias: "PHONE_TYPE"
            },
            {
                type: "N",
                value: "number",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: "PHONE_NUMBER"
            }
        ]);
    
    });

    test("Optional simple name property", function() {
    
        var elements = database.call("json_store.parse_query", {
            p_query: 'person.name?'
        });

        expect(elements).to.eql([
            {
                type: "N",
                value: "person",
                optional: false,
                first_child_i: 2,
                next_sibling_i: null,
                alias: null
            },
            {
                type: "N",
                value: "name",
                optional: true,
                first_child_i: null,
                next_sibling_i: null,
                alias: null
            }
        ]);
    
    });

    test("Optional simple name property, spaces before ?", function() {
    
        var elements = database.call("json_store.parse_query", {
            p_query: 'person.name   ?'
        });

        expect(elements).to.eql([
            {
                type: "N",
                value: "person",
                optional: false,
                first_child_i: 2,
                next_sibling_i: null,
                alias: null
            },
            {
                type: "N",
                value: "name",
                optional: true,
                first_child_i: null,
                next_sibling_i: null,
                alias: null
            }
        ]);
    
    });

    test("Optional simple name property, spaces after ?", function() {
    
        var elements = database.call("json_store.parse_query", {
            p_query: 'person.name?   '
        });

        expect(elements).to.eql([
            {
                type: "N",
                value: "person",
                optional: false,
                first_child_i: 2,
                next_sibling_i: null,
                alias: null
            },
            {
                type: "N",
                value: "name",
                optional: true,
                first_child_i: null,
                next_sibling_i: null,
                alias: null
            }
        ]);
    
    });

    test("Optional ID reference property", function() {
    
        var elements = database.call("json_store.parse_query", {
            p_query: 'person.#123?'
        });

        expect(elements).to.eql([
            {
                type: "N",
                value: "person",
                optional: false,
                first_child_i: 2,
                next_sibling_i: null,
                alias: null
            },
            {
                type: "I",
                value: "123",
                optional: true,
                first_child_i: null,
                next_sibling_i: null,
                alias: null
            }
        ]);
    
    });

    test("Optional ID reference property, spaces before ?", function() {
    
        var elements = database.call("json_store.parse_query", {
            p_query: 'person.#123   ?'
        });

        expect(elements).to.eql([
            {
                type: "N",
                value: "person",
                optional: false,
                first_child_i: 2,
                next_sibling_i: null,
                alias: null
            },
            {
                type: "I",
                value: "123",
                optional: true,
                first_child_i: null,
                next_sibling_i: null,
                alias: null
            }
        ]);
    
    });

    test("Optional ID reference property, spaces after ?", function() {
    
        var elements = database.call("json_store.parse_query", {
            p_query: 'person.#123?   '
        });

        expect(elements).to.eql([
            {
                type: "N",
                value: "person",
                optional: false,
                first_child_i: 2,
                next_sibling_i: null,
                alias: null
            },
            {
                type: "I",
                value: "123",
                optional: true,
                first_child_i: null,
                next_sibling_i: null,
                alias: null
            }
        ]);
    
    });

    test("Optional array element property", function() {
    
        var elements = database.call("json_store.parse_query", {
            p_query: 'person["name"]?'
        });

        expect(elements).to.eql([
            {
                type: "N",
                value: "person",
                optional: false,
                first_child_i: 2,
                next_sibling_i: null,
                alias: null
            },
            {
                type: "N",
                value: "name",
                optional: true,
                first_child_i: null,
                next_sibling_i: null,
                alias: null
            }
        ]);
    
    });

    test("Optional array element property, spaces before ?", function() {
    
        var elements = database.call("json_store.parse_query", {
            p_query: 'person["name"]   ?'
        });

        expect(elements).to.eql([
            {
                type: "N",
                value: "person",
                optional: false,
                first_child_i: 2,
                next_sibling_i: null,
                alias: null
            },
            {
                type: "N",
                value: "name",
                optional: true,
                first_child_i: null,
                next_sibling_i: null,
                alias: null
            }
        ]);
    
    });

    test("Optional array element property, spaces after ?", function() {
    
        var elements = database.call("json_store.parse_query", {
            p_query: 'person["name"]?   '
        });

        expect(elements).to.eql([
            {
                type: "N",
                value: "person",
                optional: false,
                first_child_i: 2,
                next_sibling_i: null,
                alias: null
            },
            {
                type: "N",
                value: "name",
                optional: true,
                first_child_i: null,
                next_sibling_i: null,
                alias: null
            }
        ]);
    
    });

    test("Single wildcard", function() {
    
        var elements = database.call("json_store.parse_query", {
            p_query: '*'
        });

        expect(elements).to.eql([
            {
                type: "W",
                value: null,
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null
            }
        ]);
    
    });

    test("Single wildcard, spaces before", function() {
    
        var elements = database.call("json_store.parse_query", {
            p_query: '   *'
        });

        expect(elements).to.eql([
            {
                type: "W",
                value: null,
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null
            }
        ]);
    
    });

    test("Single wildcard, spaces after", function() {
    
        var elements = database.call("json_store.parse_query", {
            p_query: '*   '
        });

        expect(elements).to.eql([
            {
                type: "W",
                value: null,
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null
            }
        ]);
    
    });

    test("Single wildcard with an alias", function() {
    
        var elements = database.call("json_store.parse_query", {
            p_query: '* as something'
        });

        expect(elements).to.eql([
            {
                type: "W",
                value: null,
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: "SOMETHING"
            }
        ]);
    
    });

    test("Single optional wildcard", function() {
    
        var elements = database.call("json_store.parse_query", {
            p_query: '*?'
        });

        expect(elements).to.eql([
            {
                type: "W",
                value: null,
                optional: true,
                first_child_i: null,
                next_sibling_i: null,
                alias: null
            }
        ]);
    
    });

    test("Single optional wildcard, spaces after *", function() {
    
        var elements = database.call("json_store.parse_query", {
            p_query: '*   ?'
        });

        expect(elements).to.eql([
            {
                type: "W",
                value: null,
                optional: true,
                first_child_i: null,
                next_sibling_i: null,
                alias: null
            }
        ]);
    
    });

    test("Two wildcards in a branching root", function() {
    
        var elements = database.call("json_store.parse_query", {
            p_query: '(*,*)'
        });

        expect(elements).to.eql([
            {
                type: "W",
                value: null,
                optional: false,
                first_child_i: null,
                next_sibling_i: 2,
                alias: null
            },
            {
                type: "W",
                value: null,
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null
            }
        ]);
    
    });

    test("Two wildcards in a branching root, spaces before the comma", function() {
    
        var elements = database.call("json_store.parse_query", {
            p_query: '(*   ,*)'
        });

        expect(elements).to.eql([
            {
                type: "W",
                value: null,
                optional: false,
                first_child_i: null,
                next_sibling_i: 2,
                alias: null
            },
            {
                type: "W",
                value: null,
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null
            }
        ]);
    
    });

    test("Two wildcards in a branching root, spaces after the comma", function() {
    
        var elements = database.call("json_store.parse_query", {
            p_query: '(*,   *)'
        });

        expect(elements).to.eql([
            {
                type: "W",
                value: null,
                optional: false,
                first_child_i: null,
                next_sibling_i: 2,
                alias: null
            },
            {
                type: "W",
                value: null,
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null
            }
        ]);
    
    });

    test("Two wildcards in a branching root, spaces after (", function() {
    
        var elements = database.call("json_store.parse_query", {
            p_query: '(   *,*)'
        });

        expect(elements).to.eql([
            {
                type: "W",
                value: null,
                optional: false,
                first_child_i: null,
                next_sibling_i: 2,
                alias: null
            },
            {
                type: "W",
                value: null,
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null
            }
        ]);
    
    });

    test("Two wildcards in a branching root, spaces before )", function() {
    
        var elements = database.call("json_store.parse_query", {
            p_query: '(*,*   )'
        });

        expect(elements).to.eql([
            {
                type: "W",
                value: null,
                optional: false,
                first_child_i: null,
                next_sibling_i: 2,
                alias: null
            },
            {
                type: "W",
                value: null,
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null
            }
        ]);
    
    });

    test("Wildcard property", function() {
    
        var elements = database.call("json_store.parse_query", {
            p_query: 'person.*'
        });

        expect(elements).to.eql([
            {
                type: "N",
                value: "person",
                optional: false,
                first_child_i: "2",
                next_sibling_i: null,
                alias: null
            },
            {
                type: "W",
                value: null,
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null
            }
        ]);
    
    });

    test("Wildcard property, spaces after the dot", function() {
    
        var elements = database.call("json_store.parse_query", {
            p_query: 'person.   *'
        });

        expect(elements).to.eql([
            {
                type: "N",
                value: "person",
                optional: false,
                first_child_i: "2",
                next_sibling_i: null,
                alias: null
            },
            {
                type: "W",
                value: null,
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null
            }
        ]);
    
    });

    test("Wildcard array elements", function() {
    
        var elements = database.call("json_store.parse_query", {
            p_query: 'person[*]'
        });

        expect(elements).to.eql([
            {
                type: "N",
                value: "person",
                optional: false,
                first_child_i: "2",
                next_sibling_i: null,
                alias: null
            },
            {
                type: "W",
                value: null,
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null
            }
        ]);
    
    });

    test("Wildcard array elements, spaces after [", function() {
    
        var elements = database.call("json_store.parse_query", {
            p_query: 'person[   *]'
        });

        expect(elements).to.eql([
            {
                type: "N",
                value: "person",
                optional: false,
                first_child_i: "2",
                next_sibling_i: null,
                alias: null
            },
            {
                type: "W",
                value: null,
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null
            }
        ]);
    
    });

    test("Wildcard array elements, spaces before ]", function() {
    
        var elements = database.call("json_store.parse_query", {
            p_query: 'person[*   ]'
        });

        expect(elements).to.eql([
            {
                type: "N",
                value: "person",
                optional: false,
                first_child_i: "2",
                next_sibling_i: null,
                alias: null
            },
            {
                type: "W",
                value: null,
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null
            }
        ]);
    
    });

    test("Optional wildcard property with an alias", function() {
    
        var elements = database.call("json_store.parse_query", {
            p_query: 'person.*? as person_property'
        });

        expect(elements).to.eql([
            {
                type: "N",
                value: "person",
                optional: false,
                first_child_i: "2",
                next_sibling_i: null,
                alias: null
            },
            {
                type: "W",
                value: null,
                optional: true,
                first_child_i: null,
                next_sibling_i: null,
                alias: "PERSON_PROPERTY"
            }
        ]);
    
    });

    test("Single variable", function() {
    
        var elements = database.call("json_store.parse_query", {
            p_query: ':1'
        });

        expect(elements).to.eql([
            {
                type: "V",
                value: "1",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null
            }
        ]);
    
    });

    test("Single variable, spaces before :", function() {
    
        var elements = database.call("json_store.parse_query", {
            p_query: '   :1'
        });

        expect(elements).to.eql([
            {
                type: "V",
                value: "1",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null
            }
        ]);
    
    });

    test("Single variable, spaces after", function() {
    
        var elements = database.call("json_store.parse_query", {
            p_query: ':1  '
        });

        expect(elements).to.eql([
            {
                type: "V",
                value: "1",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null
            }
        ]);
    
    });

    test("Single optional variable", function() {
    
        var elements = database.call("json_store.parse_query", {
            p_query: ':1?'
        });

        expect(elements).to.eql([
            {
                type: "V",
                value: "1",
                optional: true,
                first_child_i: null,
                next_sibling_i: null,
                alias: null
            }
        ]);
    
    });

    test("Single optional variable, spaces before ?", function() {
    
        var elements = database.call("json_store.parse_query", {
            p_query: ':1 ?'
        });

        expect(elements).to.eql([
            {
                type: "V",
                value: "1",
                optional: true,
                first_child_i: null,
                next_sibling_i: null,
                alias: null
            }
        ]);
    
    });

    test("Single :10 variable", function() {
    
        var elements = database.call("json_store.parse_query", {
            p_query: ':10'
        });

        expect(elements).to.eql([
            {
                type: "V",
                value: "10",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null
            }
        ]);
    
    });

    test("Variable as a property", function() {
    
        var elements = database.call("json_store.parse_query", {
            p_query: 'persons.:5'
        });

        expect(elements).to.eql([
            {
                type: "N",
                value: "persons",
                optional: false,
                first_child_i: 2,
                next_sibling_i: null,
                alias: null
            },
            {
                type: "V",
                value: "5",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null
            }
        ]);
    
    });

    test("Variable as a property, spaces after the dot", function() {
    
        var elements = database.call("json_store.parse_query", {
            p_query: 'persons. :5'
        });

        expect(elements).to.eql([
            {
                type: "N",
                value: "persons",
                optional: false,
                first_child_i: 2,
                next_sibling_i: null,
                alias: null
            },
            {
                type: "V",
                value: "5",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null
            }
        ]);
    
    });

    test("Variable as an array element", function() {
    
        var elements = database.call("json_store.parse_query", {
            p_query: 'persons[:5]'
        });

        expect(elements).to.eql([
            {
                type: "N",
                value: "persons",
                optional: false,
                first_child_i: 2,
                next_sibling_i: null,
                alias: null
            },
            {
                type: "V",
                value: "5",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null
            }
        ]);
    
    });

    test("Variable as an array element, spaces after [", function() {
    
        var elements = database.call("json_store.parse_query", {
            p_query: 'persons[   :5]'
        });

        expect(elements).to.eql([
            {
                type: "N",
                value: "persons",
                optional: false,
                first_child_i: 2,
                next_sibling_i: null,
                alias: null
            },
            {
                type: "V",
                value: "5",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null
            }
        ]);
    
    });

    test("Variable as an array element, spaces before ]", function() {
    
        var elements = database.call("json_store.parse_query", {
            p_query: 'persons[   :5]'
        });

        expect(elements).to.eql([
            {
                type: "N",
                value: "persons",
                optional: false,
                first_child_i: 2,
                next_sibling_i: null,
                alias: null
            },
            {
                type: "V",
                value: "5",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null
            }
        ]);
    
    });

    test("Property of a variable", function() {
    
        var elements = database.call("json_store.parse_query", {
            p_query: 'persons.:5.name'
        });

        expect(elements).to.eql([
            {
                type: "N",
                value: "persons",
                optional: false,
                first_child_i: 2,
                next_sibling_i: null,
                alias: null
            },
            {
                type: "V",
                value: "5",
                optional: false,
                first_child_i: 3,
                next_sibling_i: null,
                alias: null
            },
            {
                type: "N",
                value: "name",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null
            }
        ]);
    
    });

    test("Property of a variable, spaces after the variable", function() {
    
        var elements = database.call("json_store.parse_query", {
            p_query: 'persons.:5   .name'
        });

        expect(elements).to.eql([
            {
                type: "N",
                value: "persons",
                optional: false,
                first_child_i: 2,
                next_sibling_i: null,
                alias: null
            },
            {
                type: "V",
                value: "5",
                optional: false,
                first_child_i: 3,
                next_sibling_i: null,
                alias: null
            },
            {
                type: "N",
                value: "name",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null
            }
        ]);
    
    });

    test("Variable property in a branch", function() {
    
        var elements = database.call("json_store.parse_query", {
            p_query: 'persons(.:2,.:3)'
        });

        expect(elements).to.eql([
            {
                type: "N",
                value: "persons",
                optional: false,
                first_child_i: 2,
                next_sibling_i: null,
                alias: null
            },
            {
                type: "V",
                value: "2",
                optional: false,
                first_child_i: null,
                next_sibling_i: 3,
                alias: null
            },
            {
                type: "V",
                value: "3",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null
            }
        ]);
    
    });

    test("Variable property in a branch, spaces after (", function() {
    
        var elements = database.call("json_store.parse_query", {
            p_query: 'persons(   .:2,.:3)'
        });

        expect(elements).to.eql([
            {
                type: "N",
                value: "persons",
                optional: false,
                first_child_i: 2,
                next_sibling_i: null,
                alias: null
            },
            {
                type: "V",
                value: "2",
                optional: false,
                first_child_i: null,
                next_sibling_i: 3,
                alias: null
            },
            {
                type: "V",
                value: "3",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null
            }
        ]);
    
    });

    test("Variable property in a branch, spaces before the comma", function() {
    
        var elements = database.call("json_store.parse_query", {
            p_query: 'persons(.:2   ,.:3)'
        });

        expect(elements).to.eql([
            {
                type: "N",
                value: "persons",
                optional: false,
                first_child_i: 2,
                next_sibling_i: null,
                alias: null
            },
            {
                type: "V",
                value: "2",
                optional: false,
                first_child_i: null,
                next_sibling_i: 3,
                alias: null
            },
            {
                type: "V",
                value: "3",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null
            }
        ]);
    
    });

    test("Variable property in a branch, spaces after the comma", function() {
    
        var elements = database.call("json_store.parse_query", {
            p_query: 'persons(.:2,   .:3)'
        });

        expect(elements).to.eql([
            {
                type: "N",
                value: "persons",
                optional: false,
                first_child_i: 2,
                next_sibling_i: null,
                alias: null
            },
            {
                type: "V",
                value: "2",
                optional: false,
                first_child_i: null,
                next_sibling_i: 3,
                alias: null
            },
            {
                type: "V",
                value: "3",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null
            }
        ]);
    
    });

    test("Variable property in a branch, spaces before )", function() {
    
        var elements = database.call("json_store.parse_query", {
            p_query: 'persons(.:2,.:3   )'
        });

        expect(elements).to.eql([
            {
                type: "N",
                value: "persons",
                optional: false,
                first_child_i: 2,
                next_sibling_i: null,
                alias: null
            },
            {
                type: "V",
                value: "2",
                optional: false,
                first_child_i: null,
                next_sibling_i: 3,
                alias: null
            },
            {
                type: "V",
                value: "3",
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null
            }
        ]);
    
    });

});

