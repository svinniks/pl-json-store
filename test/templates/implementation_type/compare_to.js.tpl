function createValue(value) {

    let events = database.call("json_parser.parse", {
        p_content: JSON.stringify(value)
    });

    return database.call(`${implementationPackage}.create_json`, {
        p_content_parse_events: events
    });

}

let functionName;

function compare(left, right) {
    return database.call(functionName, {
        p_left_id: createValue(left),
        p_right_id: createValue(right)
    });
}

suite("JSON comparison tests", function() {

    functionName = 'F' + randomString(16);

    test("Create a wrapper function to call COMPARE_TO", function() {
    
        database.run(`
            BEGIN
                EXECUTE IMMEDIATE '
                    CREATE OR REPLACE FUNCTION ${functionName} (
                        p_left_id IN NUMBER,
                        p_right_id IN NUMBER
                    ) 
                    -- @json
                    RETURN CLOB IS
                        v_mismatches t_json_mismatches;
                        v_builder t_json_builder;
                    BEGIN

                        v_mismatches := ${implementationType}(p_left_id).compare_to(${implementationType}(p_right_id));
                        v_builder := t_json_builder().array();

                        FOR v_i IN 1..v_mismatches.COUNT LOOP

                            v_builder
                                .array()
                                .array;

                            FOR v_j IN 1..v_mismatches(v_i).path.COUNT LOOP
                                v_builder.value(v_mismatches(v_i).path(v_j));
                            END LOOP;

                            v_builder
                                .close()
                                .value(v_mismatches(v_i).mismatch)
                                .close();

                        END LOOP;

                        v_builder.close();

                        RETURN v_builder.build_json_clob();

                    END;
                ';    
            END;
        `);
    
    });
    
    test("Try to compare to a NULL value", function() {
    
        expect(function() {
        
            database.run(`
                DECLARE
                    v_mismatches t_json_mismatches;
                BEGIN
                    v_mismatches := ${implementationType}.create_json('null').compare_to(NULL);
                END;
            `);

        }).to.throw(/JDC-00051/);
    
    });
    
    test("Try to compare a non-existing value", function() {
    
        expect(function() {
        
            database.call(functionName, {
                p_left_id: -1,
                p_right_id: createValue(null)
            });
        
        }).to.throw(/JDC-00009/);
    
    });

    test("Try to compare to a non-existing value", function() {
    
        expect(function() {
        
            database.call(functionName, {
                p_left_id: createValue(null),
                p_right_id: -1
            });
        
        }).to.throw(/JDC-00009/);
    
    });

    test("Compare two values of different types", function() {
        
        let mismatches = compare(
            "Hello, World!",
            123.456
        )

        expect(mismatches).to.eql([
            [[], "TM"]
        ]);

    });

    test("Compare two different strings", function() {
        
        let mismatches = compare(
            "Hello, World!",
            "Good bye, World!"
        )

        expect(mismatches).to.eql([
            [[], "VM"]
        ]);

    });

    test("Compare two equal strings", function() {
        
        let mismatches = compare(
            "Hello, World!",
            "Hello, World!"
        )

        expect(mismatches).to.eql([
        ]);

    });

    test("Compare two different numbers", function() {
        
        let mismatches = compare(
            123.456,
            654.321
        )

        expect(mismatches).to.eql([
            [[], "VM"]
        ]);

    });

    test("Compare two equal numbers", function() {
        
        let mismatches = compare(
            123.456,
            123.456
        )

        expect(mismatches).to.eql([
        ]);

    });

    test("Compare two different booleans", function() {
        
        let mismatches = compare(
            true,
            false
        )

        expect(mismatches).to.eql([
            [[], "VM"]
        ]);

    });

    test("Compare two equal booleans", function() {
        
        let mismatches = compare(
            true,
            true
        )

        expect(mismatches).to.eql([
        ]);

    });

    test("Compare two nulls", function() {
        
        let mismatches = compare(
            null,
            null
        )

        expect(mismatches).to.eql([
        ]);

    });

    test("Compare two empty objects", function() {
        
        let mismatches = compare(
            {},
            {}
        )

        expect(mismatches).to.eql([
        ]);

    });

    test("Compare two objects with one equally named property of different types", function() {
        
        let mismatches = compare(
            {
                "name": "Sergejs"
            },
            {
                "name": 123.456
            }
        )

        expect(mismatches).to.eql([
            [["name"], "TM"]
        ]);

    });

    test("Compare two objects with one equally named property of different values", function() {
        
        let mismatches = compare(
            {
                "name": "Sergejs"
            },
            {
                "name": "Janis"
            }
        )

        expect(mismatches).to.eql([
            [["name"], "VM"]
        ]);

    });

    test("Compare two objects with one equally named property of equal values", function() {
        
        let mismatches = compare(
            {
                "name": "Sergejs"
            },
            {
                "name": "Sergejs"
            }
        )

        expect(mismatches).to.eql([
        ]);

    });

    test("Compare two objects with multiple properties", function() {
        
        let mismatches = compare(
            {
                "name": "Sergejs",
                "surname": "Vinniks",
                "city": "Riga"
            },
            {
                "name": "Janis",
                "surname": 123.456,
                "city": "Riga"
            }
        )

        expect(mismatches).to.eql([
            [["name"], "VM"],
            [["surname"], "TM"]
        ]);

    });

    test("Compare two objects with one property, missing right", function() {
        
        let mismatches = compare(
            {
                "name": "Sergejs"
            },
            {
            }
        )

        expect(mismatches).to.eql([
            [["name"], "MR"]
        ]);

    });

    test("Compare two objects with one property, missing left", function() {
        
        let mismatches = compare(
            {
            },
            {
                "name": "Sergejs"
            }
        )

        expect(mismatches).to.eql([
            [["name"], "ML"]
        ]);

    });

    test("Compare two objects, missing last right properties", function() {
        
        let mismatches = compare(
            {
                "A": null,
                "B": null,
                "C": null,
                "D": null
            },
            {
                "A": null,
                "B": null
            }
        )

        expect(mismatches).to.eql([
            [["C"], "MR"],
            [["D"], "MR"]
        ]);

    });

    test("Compare two objects, missing last left properties", function() {
        
        let mismatches = compare(
            {
                "A": null,
                "B": null
            },
            {
                "A": null,
                "B": null,
                "C": null,
                "D": null
            }
        )

        expect(mismatches).to.eql([
            [["C"], "ML"],
            [["D"], "ML"]
        ]);

    });

    test("Compare two objects, missing multiple properties in different positions", function() {
        
        let mismatches = compare(
            {
                "A": null,
                "B": null,
                "E": null,
                "F": null,
                "G": null,
                "H": null
            },
            {
                "B": null,
                "C": null,
                "D": null,
                "E": null,
                "F": null,
                "H": null
            }
        )

        expect(mismatches).to.eql([
            [["A"], "MR"],
            [["C"], "ML"],
            [["D"], "ML"],
            [["G"], "MR"]
        ]);

    });

    test("Compare two equal objects with multiple properties", function() {
        
        let mismatches = compare(
            {
                "surname": "Vinniks",
                "name": "Sergejs",
                "address": {
                    "street": "Raunas",
                    "city": "Riga"
                }
            },
            {
                "address": {
                    "street": "Raunas",
                    "city": "Riga"
                },
                "name": "Sergejs",
                "surname": "Vinniks"
            }
        )

        expect(mismatches).to.eql([
        ]);

    });

    test("Compare two empty arrays", function() {
        
        let mismatches = compare(
            [],
            []
        );

        expect(mismatches).to.eql([
        ]);

    });

    test("Compare two equal arrays", function() {
        
        let mismatches = compare(
            ["Hello, World!", 123.456, true, null],
            ["Hello, World!", 123.456, true, null]
        );

        expect(mismatches).to.eql([
        ]);

    });

    test("Compare two equal length arrays with some differences", function() {
        
        let mismatches = compare(
            ["Hello, World!", true, false, null],
            ["Hello, World!", 123.456, true, null]
        );

        expect(mismatches).to.eql([
            [["1"], "TM"],
            [["2"], "VM"]
        ]);

    });

    test("Compare two arrays, the right is longer", function() {
        
        let mismatches = compare(
            [1, 2, 3, 4, 5, 6, 7, 8],
            [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13]
        );

        expect(mismatches).to.eql([
            [["8"], "ML"],
            [["9"], "ML"],
            [["10"], "ML"],
            [["11"], "ML"],
            [["12"], "ML"]
        ]);

    });

    test("Compare two arrays, the left is longer", function() {
        
        let mismatches = compare(
            [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13],
            [1, 2, 3, 4, 5, 6, 7, 8]
        );

        expect(mismatches).to.eql([
            [["8"], "MR"],
            [["9"], "MR"],
            [["10"], "MR"],
            [["11"], "MR"],
            [["12"], "MR"]
        ]);

    });

    test("Complex JSON comparison", function() {

        let mismatches = compare(
            {
                "name": "Sergejs",
                "surname": "Vinniks",
                "birthDate": "1982-08-06",
                "address": {
                    "street": "Raunas",
                    "city": "Riga"
                },
                "married": true,
                "phones": [
                    {
                        "type": "mobile",
                        "number": "1234567"
                    },
                    {
                        "type": "office",
                        "number": "7654321"
                    }
                ]
            },
            {
                "name": "Sergejs",
                "surname": "Vinniks",
                "birthDate": "06.08.1982",
                "address": {
                    "street": "Raunas",
                    "city": "Riga"
                },
                "married": "true",
                "children": 1,
                "phones": [
                    {
                        "type": "cellular",
                        "number": "1234567"
                    },
                    {
                        "type": "office",
                        "number": 7654321
                    }
                ]
            }
        );

        expect(mismatches).to.eql([
            [["birthDate"], "VM"],
            [["children"], "ML"],
            [["married"], "TM"],
            [["phones", "0", "type"], "VM"],
            [["phones", "1", "number"], "TM"],
        ]);
    
    });
    
    teardown("Drop the wrapper function", function() {
    
        database.run(`
            BEGIN
                EXECUTE IMMEDIATE '
                    DROP FUNCTION ${functionName}
                ';
            END;
        `);
    
    });
    

});