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

});

suite("Column name retrieval tests", function() {

    test("One simple property", function() {

        var elements = database.call("json_store.parse_query", {
            p_query: "person"
        });

        var names = database.call("json_store.get_query_column_names", {
            p_query_elements: elements
        });

        expect(names).to.eql([
            "person"
        ]);

    });

    test("One simple property with an alias", function() {

        var elements = database.call("json_store.parse_query", {
            p_query: "person AS person"
        });

        var names = database.call("json_store.get_query_column_names", {
            p_query_elements: elements
        });

        expect(names).to.eql([
            "PERSON"
        ]);

    });

    test("Two branched properties", function() {

        var elements = database.call("json_store.parse_query", {
            p_query: "person(.name, .surname)"
        });

        var names = database.call("json_store.get_query_column_names", {
            p_query_elements: elements
        });

        expect(names).to.eql([
            "name",
            "surname"
        ]);

    });

    test("Two branched properties with aliases", function() {

        var elements = database.call("json_store.parse_query", {
            p_query: "person(.name as person_name, .surname as person_surname)"
        });

        var names = database.call("json_store.get_query_column_names", {
            p_query_elements: elements
        });

        expect(names).to.eql([
            "PERSON_NAME",
            "PERSON_SURNAME"
        ]);

    });

});