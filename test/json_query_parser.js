suite("Invalid query parser", function() {

});

suite("Valid query parser", function() {

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

    test("Root only", function() {
    
        var elements = database.call("json_store.parse_query", {
            p_query: "$"
        });

        expect(elements).to.eql([
            {
                type: "R",
                value: null,
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null
            }
        ]);
    
    });

    test("Root only, spaces before $", function() {
    
        var elements = database.call("json_store.parse_query", {
            p_query: "   $"
        });

        expect(elements).to.eql([
            {
                type: "R",
                value: null,
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null
            }
        ]);
    
    });

    test("Root only, spaces after $", function() {
    
        var elements = database.call("json_store.parse_query", {
            p_query: "$   "
        });

        expect(elements).to.eql([
            {
                type: "R",
                value: null,
                optional: false,
                first_child_i: null,
                next_sibling_i: null,
                alias: null
            }
        ]);
    
    });

    test("Branched root with two roots", function() {
    
        var elements = database.call("json_store.parse_query", {
            p_query: "($, $)"
        });

        expect(elements).to.eql([
            {
                type: "R",
                value: null,
                optional: false,
                first_child_i: null,
                next_sibling_i: 2,
                alias: null
            },
            {
                type: "R",
                value: null,
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

});