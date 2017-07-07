suite("JSON path parser tests", function() {

    suite("Invalid path tests", function() {

        test("Invalid start of the path", function() {
        
            expect(function() {
            
                var result = database.call("json_store.parse_path", {
                    p_path: "123"
                });
            
            }).to.throw(/JDOC-00001/);
        
        });

        test("Invalid start of the path with spaces", function() {
        
            expect(function() {
            
                var result = database.call("json_store.parse_path", {
                    p_path: "   123"
                });
            
            }).to.throw(/JDOC-00001/);
        
        });
        
        test("Invalid start of the property", function() {
        
            expect(function() {
            
                var result = database.call("json_store.parse_path", {
                    p_path: "hello.123"
                });
            
            }).to.throw(/JDOC-00001/);
        
        });

        test("Invalid start of the property with spaces", function() {
        
            expect(function() {
            
                var result = database.call("json_store.parse_path", {
                    p_path: "  hello  .  123"
                });
            
            }).to.throw(/JDOC-00001/);
        
        });

        test("Invalid character in simple name", function() {
        
            expect(function() {
            
                var result = database.call("json_store.parse_path", {
                    p_path: "hello-123"
                });
            
            }).to.throw(/JDOC-00001/);
        
        });

        test("Invalid start of ID", function() {
        
            expect(function() {
            
                var result = database.call("json_store.parse_path", {
                    p_path: "#a"
                });
            
            }).to.throw(/JDOC-00001/);
        
        });

        test("Invalid character in ID", function() {
        
            expect(function() {
            
                var result = database.call("json_store.parse_path", {
                    p_path: "#123a"
                });
            
            }).to.throw(/JDOC-00001/);
        
        });

        test(". or [ missing", function() {
        
            expect(function() {
            
                var result = database.call("json_store.parse_path", {
                    p_path: "abc abc"
                });
            
            }).to.throw(/JDOC-00001/);
        
        });

        test("Invalid start of array element", function() {
        
            expect(function() {
            
                var result = database.call("json_store.parse_path", {
                    p_path: "abc[cda]"
                });
            
            }).to.throw(/JDOC-00001/);
        
        });

        test("Invalid start of array element with spaces", function() {
        
            expect(function() {
            
                var result = database.call("json_store.parse_path", {
                    p_path: "  abc  [  cba  ]  "
                });
            
            }).to.throw(/JDOC-00001/);
        
        });

        test("Invalid character in array element", function() {
        
            expect(function() {
            
                var result = database.call("json_store.parse_path", {
                    p_path: "abc[123a]"
                });
            
            }).to.throw(/JDOC-00001/);
        
        });

        test("] missing", function() {
        
            expect(function() {
            
                var result = database.call("json_store.parse_path", {
                    p_path: "abc[123.cba"
                });
            
            }).to.throw(/JDOC-00001/);
        
        });

        test("Trailing ] missing", function() {
        
            expect(function() {
            
                var result = database.call("json_store.parse_path", {
                    p_path: "abc[123"
                });
            
            }).to.throw(/JDOC-00002/);
        
        });

        test("Name closing quote missing", function() {
        
            expect(function() {
            
                var result = database.call("json_store.parse_path", {
                    p_path: "\"abc" 
                });
            
            }).to.throw(/JDOC-00002/);
        
        });

        test("Array element closing quote missing", function() {
        
            expect(function() {
            
                var result = database.call("json_store.parse_path", {
                    p_path: 'hello["world'
                });
            
            }).to.throw(/JDOC-00002/);
        
        });

        test("Dot in the end", function() {
        
            expect(function() {
            
                var result = database.call("json_store.parse_path", {
                    p_path: 'hello.world.'
                });
            
            }).to.throw(/JDOC-00002/);
        
        });

        test("Dot in the end with spaces", function() {
        
            expect(function() {
            
                var result = database.call("json_store.parse_path", {
                    p_path: '  hello  .  world  .  '
                });
            
            }).to.throw(/JDOC-00002/);
        
        });

    });

    suite("Valid path tests", function() {

        test("Empty path", function() {

            var result = database.call("json_store.parse_path", {
                p_path: null
            });

            expect(result).to.eql([]);

        });

        test("Empty path (spaces only)", function() {

            var result = database.call("json_store.parse_path", {
                p_path: "   "
            });

            expect(result).to.eql([]);

        });

        test("Root only", function() {

            var result = database.call("json_store.parse_path", {
                p_path: "$"
            });

            expect(result).to.eql([
                {
                    type: 'R',
                    value: null
                }
            ]);

        });

        test("Root only with spaces", function() {

            var result = database.call("json_store.parse_path", {
                p_path: "  $    "
            });

            expect(result).to.eql([
                {
                    type: 'R',
                    value: null
                }
            ]);

        });

        test("Single simple name", function() {

            var result = database.call("json_store.parse_path", {
                p_path: "hello"
            });

            expect(result).to.eql([
                {
                    type: 'N',
                    value: "hello"
                }
            ]);

        });

        test("Single simple name with spaces", function() {

            var result = database.call("json_store.parse_path", {
                p_path: "   hello   "
            });

            expect(result).to.eql([
                {
                    type: 'N',
                    value: "hello"
                }
            ]);

        });

        test("Single quoted name", function() {

            var result = database.call("json_store.parse_path", {
                p_path: '" 89 "'
            });

            expect(result).to.eql([
                {
                    type: 'N',
                    value: " 89 "
                }
            ]);

        });

        test("Single quoted name with spaces", function() {

            var result = database.call("json_store.parse_path", {
                p_path: '   " 89 "   '
            });

            expect(result).to.eql([
                {
                    type: 'N',
                    value: " 89 "
                }
            ]);

        });

        test("Single quoted name with escaped quote", function() {

            var result = database.call("json_store.parse_path", {
                p_path: '" 89\\" "'
            });

            expect(result).to.eql([
                {
                    type: 'N',
                    value: " 89\" "
                }
            ]);

        });

        test("Single ID", function() {

            var result = database.call("json_store.parse_path", {
                p_path: '#12345'
            });

            expect(result).to.eql([
                {
                    type: 'I',
                    value: "12345"
                }
            ]);

        });

        test("Single ID with spaces", function() {

            var result = database.call("json_store.parse_path", {
                p_path: '   #12345   '
            });

            expect(result).to.eql([
                {
                    type: 'I',
                    value: "12345"
                }
            ]);

        });

        test("Single digit array element of root", function() {

            var result = database.call("json_store.parse_path", {
                p_path: '$[1]'
            });

            expect(result).to.eql([
                {
                    type: 'R',
                    value: null
                },
                {
                    type: 'N',
                    value: "1"
                }
            ]);

        });

        test("Single digit array element of root with spaces", function() {

            var result = database.call("json_store.parse_path", {
                p_path: '  $  [  1  ]  '
            });

            expect(result).to.eql([
                {
                    type: 'R',
                    value: null
                },
                {
                    type: 'N',
                    value: "1"
                }
            ]);

        });

        test("Multi-digit array element of root", function() {

            var result = database.call("json_store.parse_path", {
                p_path: '$[12345]'
            });

            expect(result).to.eql([
                {
                    type: 'R',
                    value: null
                },
                {
                    type: 'N',
                    value: "12345"
                }
            ]);

        });

        test("Multi-digit array element of root with spaces", function() {

            var result = database.call("json_store.parse_path", {
                p_path: '  $  [  12345  ]  '
            });

            expect(result).to.eql([
                {
                    type: 'R',
                    value: null
                },
                {
                    type: 'N',
                    value: "12345"
                }
            ]);

        });

        test("Just an array element", function() {

            var result = database.call("json_store.parse_path", {
                p_path: '[12345]'
            });

            expect(result).to.eql([
                {
                    type: 'N',
                    value: "12345"
                }
            ]);

        });

        test("Quoted array element of root", function() {

            var result = database.call("json_store.parse_path", {
                p_path: '$["hello"]'
            });

            expect(result).to.eql([
                {
                    type: 'R',
                    value: null
                },
                {
                    type: 'N',
                    value: "hello"
                }
            ]);

        });

        test("Quoted array element of root with spaces", function() {

            var result = database.call("json_store.parse_path", {
                p_path: '  $  [  "hello"  ]  '
            });

            expect(result).to.eql([
                {
                    type: 'R',
                    value: null
                },
                {
                    type: 'N',
                    value: "hello"
                }
            ]);

        });

        test("Array element of simple name", function() {

            var result = database.call("json_store.parse_path", {
                p_path: 'hello[123]'
            });

            expect(result).to.eql([
                {
                    type: 'N',
                    value: "hello"
                },
                {
                    type: 'N',
                    value: "123"
                }
            ]);

        });

        test("Array element of simple name with spaces", function() {

            var result = database.call("json_store.parse_path", {
                p_path: '  hello  [  123  ]  '
            });

            expect(result).to.eql([
                {
                    type: 'N',
                    value: "hello"
                },
                {
                    type: 'N',
                    value: "123"
                }
            ]);

        });

        test("Array element of quoted name", function() {

            var result = database.call("json_store.parse_path", {
                p_path: '"hello"[123]'
            });

            expect(result).to.eql([
                {
                    type: 'N',
                    value: "hello"
                },
                {
                    type: 'N',
                    value: "123"
                }
            ]);

        });

        test("Array element of quoted name with spaces", function() {

            var result = database.call("json_store.parse_path", {
                p_path: '  "hello"  [  123  ]  '
            });

            expect(result).to.eql([
                {
                    type: 'N',
                    value: "hello"
                },
                {
                    type: 'N',
                    value: "123"
                }
            ]);

        });

        test("Array element of ID", function() {

            var result = database.call("json_store.parse_path", {
                p_path: '#123[456]'
            });

            expect(result).to.eql([
                {
                    type: 'I',
                    value: "123"
                },
                {
                    type: 'N',
                    value: "456"
                }
            ]);

        });

        test("Array element of ID with spaces", function() {

            var result = database.call("json_store.parse_path", {
                p_path: '  #123  [  456  ]  '
            });

            expect(result).to.eql([
                {
                    type: 'I',
                    value: "123"
                },
                {
                    type: 'N',
                    value: "456"
                }
            ]);

        });

        test("Multi-dimensional array access", function() {

            var result = database.call("json_store.parse_path", {
                p_path: 'array[123]["321"]'
            });

            expect(result).to.eql([
                {
                    type: 'N',
                    value: "array"
                },
                {
                    type: 'N',
                    value: "123"
                },
                {
                    type: 'N',
                    value: "321"
                }
            ]);

        });

        test("Multi-dimensional array access with spaces", function() {

            var result = database.call("json_store.parse_path", {
                p_path: ' array [123] ["321"] '
            });

            expect(result).to.eql([
                {
                    type: 'N',
                    value: "array"
                },
                {
                    type: 'N',
                    value: "123"
                },
                {
                    type: 'N',
                    value: "321"
                }
            ]);

        });

        test("Multiple mixed elements", function() {

            var result = database.call("json_store.parse_path", {
                p_path: 'hello.world.#12345.#54321."aaa"."bbb"[1]'
            });

            expect(result).to.eql([
                {
                    type: 'N',
                    value: "hello"
                },
                {
                    type: 'N',
                    value: "world"
                },
                {
                    type: 'I',
                    value: "12345"
                },
                {
                    type: 'I',
                    value: "54321"
                },
                {
                    type: 'N',
                    value: "aaa"
                },
                {
                    type: 'N',
                    value: "bbb"
                },
                {
                    type: 'N',
                    value: "1"
                }
            ]);

        });

        test("Multiple mixed elements with spaces", function() {

            var result = database.call("json_store.parse_path", {
                p_path: '  hello  .  world  .  #12345  .  #54321  .  "aaa"  .  "bbb"  '
            });

            expect(result).to.eql([
                {
                    type: 'N',
                    value: "hello"
                },
                {
                    type: 'N',
                    value: "world"
                },
                {
                    type: 'I',
                    value: "12345"
                },
                {
                    type: 'I',
                    value: "54321"
                },
                {
                    type: 'N',
                    value: "aaa"
                },
                {
                    type: 'N',
                    value: "bbb"
                }
            ]);

        });

        test("Multiple mixed elements starting with root", function() {

            var result = database.call("json_store.parse_path", {
                p_path: '$.hello.world.#12345.#54321."aaa"."bbb"'
            });

            expect(result).to.eql([
                {
                    type: 'R',
                    value: null
                },
                {
                    type: 'N',
                    value: "hello"
                },
                {
                    type: 'N',
                    value: "world"
                },
                {
                    type: 'I',
                    value: "12345"
                },
                {
                    type: 'I',
                    value: "54321"
                },
                {
                    type: 'N',
                    value: "aaa"
                },
                {
                    type: 'N',
                    value: "bbb"
                }
            ]);

        });

        test("Multiple mixed elements starting with root, with spaces", function() {

            var result = database.call("json_store.parse_path", {
                p_path: '  $  .  hello . world.#12345.#54321."aaa"."bbb"'
            });

            expect(result).to.eql([
                {
                    type: 'R',
                    value: null
                },
                {
                    type: 'N',
                    value: "hello"
                },
                {
                    type: 'N',
                    value: "world"
                },
                {
                    type: 'I',
                    value: "12345"
                },
                {
                    type: 'I',
                    value: "54321"
                },
                {
                    type: 'N',
                    value: "aaa"
                },
                {
                    type: 'N',
                    value: "bbb"
                }
            ]);

        });

    });

});

suite("JSON store management tests", function() {

    suite("JSON value creation tests", function() {
    
        suite("Scalar value creation tests", function() {
        
            suite("Create anonymous values using the JSON_STORE.CREATE_XXX function", function() {

                test("Create anonymous null", function() {

                    var id = database.call("json_store.create_null");

                    expect(id).to.not.be(null);

                    var value = database.selectObject(`*
                        FROM json_values
                        WHERE id = ${id}
                    `);

                    expect(value).to.eql({
                        id: id,
                        parent_id: null,
                        type: 'E',
                        name: null,
                        value: null
                    });

                });

                test("Create anonymous string", function() {

                    var id = database.call("json_store.create_string", {
                        p_value: "Hello, World!"
                    });

                    expect(id).to.not.be(null);

                    var value = database.selectObject(`*
                        FROM json_values
                        WHERE id = ${id}
                    `);

                    expect(value).to.eql({
                        id: id,
                        parent_id: null,
                        type: 'S',
                        name: null,
                        value: "Hello, World!"
                    });

                });

                test("Create anonymous number", function() {

                    var id = database.call("json_store.create_number", {
                        p_value: '123.456'
                    });

                    expect(id).to.not.be(null);

                    var value = database.selectObject(`*
                        FROM json_values
                        WHERE id = ${id}
                    `);

                    expect(value).to.eql({
                        id: id,
                        parent_id: null,
                        type: 'N',
                        name: null,
                        value: "123.456"
                    });

                });

                test("Create anonymous boolean", function() {

                    var id = database.call("json_store.create_boolean", {
                        p_value: true
                    });

                    expect(id).to.not.be(null);

                    var value = database.selectObject(`*
                        FROM json_values
                        WHERE id = ${id}
                    `);

                    expect(value).to.eql({
                        id: id,
                        parent_id: null,
                        type: 'B',
                        name: null,
                        value: "true"
                    });

                });

                test("Create anonymous null string", function() {

                    var id = database.call("json_store.create_string", {
                        p_value: null
                    });

                    expect(id).to.not.be(null);

                    var value = database.selectObject(`*
                        FROM json_values
                        WHERE id = ${id}
                    `);

                    expect(value).to.eql({
                        id: id,
                        parent_id: null,
                        type: 'E',
                        name: null,
                        value: null
                    });

                });

                test("Create anonymous null number", function() {

                    var id = database.call("json_store.create_number", {
                        p_value: null
                    });

                    expect(id).to.not.be(null);

                    var value = database.selectObject(`*
                        FROM json_values
                        WHERE id = ${id}
                    `);

                    expect(value).to.eql({
                        id: id,
                        parent_id: null,
                        type: 'E',
                        name: null,
                        value: null
                    });

                });

                test("Create anonymous null boolean", function() {

                    var id = database.call("json_store.create_boolean", {
                        p_value: null
                    });

                    expect(id).to.not.be(null);

                    var value = database.selectObject(`*
                        FROM json_values
                        WHERE id = ${id}
                    `);

                    expect(value).to.eql({
                        id: id,
                        parent_id: null,
                        type: 'E',
                        name: null,
                        value: null
                    });

                });

            });

            suite("Create anonymous values using the JSON_STORE.CREATE_JSON function", function() {
            
                test("Create anonymous null", function() {

                    var id = database.call("json_store.create_json", {
                        p_content: null
                    });

                    expect(id).to.not.be(null);

                    var value = database.selectObject(`*
                        FROM json_values
                        WHERE id = ${id}
                    `);

                    expect(value).to.eql({
                        id: id,
                        parent_id: null,
                        type: 'E',
                        name: null,
                        value: null
                    });

                });

                test("Create anonymous string", function() {

                    var id = database.call("json_store.create_json", {
                        p_content: "Hello, World!"
                    });

                    expect(id).to.not.be(null);

                    var value = database.selectObject(`*
                        FROM json_values
                        WHERE id = ${id}
                    `);

                    expect(value).to.eql({
                        id: id,
                        parent_id: null,
                        type: 'S',
                        name: null,
                        value: "Hello, World!"
                    });

                });

                test("Create anonymous number", function() {

                    var id = database.call("json_store.create_json", {
                        p_content: 123.456
                    });

                    expect(id).to.not.be(null);

                    var value = database.selectObject(`*
                        FROM json_values
                        WHERE id = ${id}
                    `);

                    expect(value).to.eql({
                        id: id,
                        parent_id: null,
                        type: 'N',
                        name: null,
                        value: "123.456"
                    });

                });

                test("Create anonymous boolean", function() {

                    var id = database.call("json_store.create_json", {
                        p_content: true
                    });

                    expect(id).to.not.be(null);

                    var value = database.selectObject(`*
                        FROM json_values
                        WHERE id = ${id}
                    `);

                    expect(value).to.eql({
                        id: id,
                        parent_id: null,
                        type: 'B',
                        name: null,
                        value: "true"
                    });

                });    
            
            });

            teardown("Rollback", function() {
                database.rollback();
            });
        
        });

        suite("Object creation tests", function() {
        
            test("Create anonymous object using the JSON_STORE.CREATE_OBJECT function", function() {

                var id = database.call("json_store.create_object");

                expect(id).to.not.be(null);

                var value = database.selectObject(`*
                    FROM json_values
                    WHERE id = ${id}
                `);

                expect(value).to.eql({
                    id: id,
                    parent_id: null,
                    type: 'O',
                    name: null,
                    value: null
                });

            });

            teardown("Rollback", function() {
                database.rollback();
            });

        });

        suite("Array creation tests", function() {
            
            test("Create anonymous array using the JSON_STORE.CREATE_ARRAY function", function() {

                var id = database.call("json_store.create_array");

                expect(id).to.not.be(null);

                var value = database.selectObject(`*
                    FROM json_values
                    WHERE id = ${id}
                `);

                expect(value).to.eql({
                    id: id,
                    parent_id: null,
                    type: 'A',
                    name: null,
                    value: null
                });

            });

            teardown("Rollback", function() {
                database.rollback();
            });

        });
    
    });

    suite("JSON value retrieval tests", function() {
    
        
    });

    suite("JSON value modification tests", function() {
    
    
    });

});

suite("JSON document creation in the root", function() {

    

    suite("Anonymous JSON creation in the root", function() {

        

        test("Create anonymous object", function() {

            var id = database.call("json_store.create_json", {
                p_content: {}
            });

            expect(id).to.not.be(null);

            var value = database.selectObject(`*
                FROM json_values
                WHERE id = ${id}
            `);

            expect(value).to.eql({
                id: id,
                parent_id: null,
                type: 'O',
                name: null,
                value: null
            });

        });

        test("Create anonymous array", function() {

            var id = database.call("json_store.create_json", {
                p_content: []
            });

            expect(id).to.not.be(null);

            var value = database.selectObject(`*
                FROM json_values
                WHERE id = ${id}
            `);

            expect(value).to.eql({
                id: id,
                parent_id: null,
                type: 'A',
                name: null,
                value: null
            });

        });

        test("Create anonymous object with all possible scalar properties", function() {

            var id = database.call("json_store.create_json", {
                p_content: {
                    name: "Sergejs",
                    age: 35,
                    married: true,
                    children: null
                }
            });

            expect(id).to.not.be(null);

            var values = database.selectRows(`LEVEL AS lvl
                    ,type
                    ,name
                    ,value
                FROM json_values
                START WITH id = ${id}
                CONNECT BY PRIOR id = parent_id
                ORDER SIBLINGS BY id
            `);

            expect(values).to.eql([
                [1, "O", null, null],
                [2, "S", "name", "Sergejs"],
                [2, "N", "age", "35"],
                [2, "B", "married", "true"],
                [2, "E", "children", null],
            ]);

        });

        test("Create anonymous object with a nested object property", function() {

            var id = database.call("json_store.create_json", {
                p_content: {
                    name: "Sergejs",
                    age: 35,
                    address: {
                       country: "Latvia",
                       city: "Riga"
                    }
                }
            });

            expect(id).to.not.be(null);

            var values = database.selectRows(`LEVEL AS lvl
                    ,type
                    ,name
                    ,value
                FROM json_values
                START WITH id = ${id}
                CONNECT BY PRIOR id = parent_id
                ORDER SIBLINGS BY id
            `);

            expect(values).to.eql([
                [1, "O", null, null],
                [2, "S", "name", "Sergejs"],
                [2, "N", "age", "35"],
                [2, "O", "address", null],
                [3, "S", "country", "Latvia"],
                [3, "S", "city", "Riga"]
            ]);

        });

        test("Create anonymous array with all possible scalar elements", function() {

            var id = database.call("json_store.create_json", {
                p_content: ["Sergejs", "Vinniks", 35, true, null]
            });

            expect(id).to.not.be(null);

            var values = database.selectRows(`LEVEL AS lvl
                    ,type
                    ,name
                    ,value
                FROM json_values
                START WITH id = ${id}
                CONNECT BY PRIOR id = parent_id
                ORDER SIBLINGS BY id
            `);

            expect(values).to.eql([
                [1, "A", null, null],
                [2, "S", "0", "Sergejs"],
                [2, "S", "1", "Vinniks"],
                [2, "N", "2", "35"],
                [2, "B", "3", "true"],
                [2, "E", "4", null]
            ]);

        });

        test("Create anonymous multidimensional array", function() {

            var id = database.call("json_store.create_json", {
                p_content: [["Sergejs", "Vinniks", 35, true, null], ["Hello", "World"]]
            });

            expect(id).to.not.be(null);

            var values = database.selectRows(`LEVEL AS lvl
                    ,type
                    ,name
                    ,value
                FROM json_values
                START WITH id = ${id}
                CONNECT BY PRIOR id = parent_id
                ORDER SIBLINGS BY id
            `);

            expect(values).to.eql([
                [1, "A", null, null],
                [2, "A", "0", null],
                [3, "S", "0", "Sergejs"],
                [3, "S", "1", "Vinniks"],
                [3, "N", "2", "35"],
                [3, "B", "3", "true"],
                [3, "E", "4", null],
                [2, "A", "1", null],
                [3, "S", "0", "Hello"],
                [3, "S", "1", "World"]
            ]);

        });

        test("Create anonymous complex object", function() {

            var id = database.call("json_store.create_json", {
                p_content: {
                    name: "Sergejs",
                    surname: "Vinniks",
                    phones: [
                        {
                            type: "fixed",
                            number: 1234567
                        }
                    ]
                }
            });

            expect(id).to.not.be(null);

            var values = database.selectRows(`LEVEL AS lvl
                    ,type
                    ,name
                    ,value
                FROM json_values
                START WITH id = ${id}
                CONNECT BY PRIOR id = parent_id
                ORDER SIBLINGS BY id
            `);

            expect(values).to.eql([
                [1, "O", null, null],
                [2, "S", "name", "Sergejs"],
                [2, "S", "surname", "Vinniks"],
                [2, "A", "phones", null],
                [3, "O", "0", null],
                [4, "S", "type", "fixed"],
                [4, "N", "number", "1234567"],
            ]);

        });

        teardown("Rollback", function() {
            database.rollback();
        });

    });

    suite("Named value creation", function() {

        test("Create named null", function() {

            var id = database.call("json_store.set_null", {
                p_path: '$.jodus_null'
            });

            expect(id).to.not.be(null);

            var value = database.selectObject(`*
                FROM json_values
                WHERE id = ${id}
            `);

            expect(value).to.eql({
                id: id,
                parent_id: null,
                type: 'E',
                name: "jodus_null",
                value: null
            });

        });

        test("Create named string", function() {

            var id = database.call("json_store.set_string", {
                p_path: '$.jodus_string',
                p_value: 'Hello, World!'
            });

            expect(id).to.not.be(null);

            var value = database.selectObject(`*
                FROM json_values
                WHERE id = ${id}
            `);

            expect(value).to.eql({
                id: id,
                parent_id: null,
                type: 'S',
                name: "jodus_string",
                value: "Hello, World!"
            });

        });

        test("Create named number", function() {

            var id = database.call("json_store.set_number", {
                p_path: '$.jodus_number',
                p_value: 123.456
            });

            expect(id).to.not.be(null);

            var value = database.selectObject(`*
                FROM json_values
                WHERE id = ${id}
            `);

            expect(value).to.eql({
                id: id,
                parent_id: null,
                type: 'N',
                name: "jodus_number",
                value: "123.456"
            });

        });

        test("Create named boolean", function() {

            var id = database.call("json_store.set_boolean", {
                p_path: '$.jodus_boolean',
                p_value: true
            });

            expect(id).to.not.be(null);

            var value = database.selectObject(`*
                FROM json_values
                WHERE id = ${id}
            `);

            expect(value).to.eql({
                id: id,
                parent_id: null,
                type: 'B',
                name: "jodus_boolean",
                value: "true"
            });

        });

        test("Create named object", function() {

            var id = database.call("json_store.set_object", {
                p_path: '$.jodus_object'
            });

            expect(id).to.not.be(null);

            var value = database.selectObject(`*
                FROM json_values
                WHERE id = ${id}
            `);

            expect(value).to.eql({
                id: id,
                parent_id: null,
                type: 'O',
                name: "jodus_object",
                value: null
            });

        });

        test("Create named array", function() {

            var id = database.call("json_store.set_array", {
                p_path: '$.jodus_array'
            });

            expect(id).to.not.be(null);

            var value = database.selectObject(`*
                FROM json_values
                WHERE id = ${id}
            `);

            expect(value).to.eql({
                id: id,
                parent_id: null,
                type: 'A',
                name: "jodus_array",
                value: null
            });

        });

    });

    suite("Named JSON creation", function() {

        test("Create named null", function() {

            var id = database.call("json_store.set_json", {
                p_path: '$.jodus_null',
                p_content: null
            });

            expect(id).to.not.be(null);

            var value = database.selectObject(`*
                FROM json_values
                WHERE id = ${id}
            `);

            expect(value).to.eql({
                id: id,
                parent_id: null,
                type: 'E',
                name: "jodus_null",
                value: null
            });

        });

        test("Create named string", function() {

            var id = database.call("json_store.set_json", {
                p_path: '$.jodus_string',
                p_content: "Hello, World!"
            });

            expect(id).to.not.be(null);

            var value = database.selectObject(`*
                FROM json_values
                WHERE id = ${id}
            `);

            expect(value).to.eql({
                id: id,
                parent_id: null,
                type: 'S',
                name: "jodus_string",
                value: "Hello, World!"
            });

        });

        test("Create named number", function() {

            var id = database.call("json_store.set_json", {
                p_path: '$.jodus_number',
                p_content: 123.456
            });

            expect(id).to.not.be(null);

            var value = database.selectObject(`*
                FROM json_values
                WHERE id = ${id}
            `);

            expect(value).to.eql({
                id: id,
                parent_id: null,
                type: 'N',
                name: "jodus_number",
                value: "123.456"
            });

        });

        test("Create named boolean", function() {

            var id = database.call("json_store.set_json", {
                p_path: '$.jodus_boolean',
                p_content: true
            });

            expect(id).to.not.be(null);

            var value = database.selectObject(`*
                FROM json_values
                WHERE id = ${id}
            `);

            expect(value).to.eql({
                id: id,
                parent_id: null,
                type: 'B',
                name: "jodus_boolean",
                value: "true"
            });

        });

        test("Create named object", function() {

            var id = database.call("json_store.set_json", {
                p_path: '$.jodus_object',
                p_content: {}
            });

            expect(id).to.not.be(null);

            var value = database.selectObject(`*
                FROM json_values
                WHERE id = ${id}
            `);

            expect(value).to.eql({
                id: id,
                parent_id: null,
                type: 'O',
                name: "jodus_object",
                value: null
            });

        });

        test("Create named array", function() {

            var id = database.call("json_store.set_json", {
                p_path: '$.jodus_array',
                p_content: []
            });

            expect(id).to.not.be(null);

            var value = database.selectObject(`*
                FROM json_values
                WHERE id = ${id}
            `);

            expect(value).to.eql({
                id: id,
                parent_id: null,
                type: 'A',
                name: "jodus_array",
                value: null
            });

        });

        teardown("Rollback", function() {
            database.rollback();
        })

    });

});

suite("JSON document retrieval from the root", function() {

    suite("Anonymous value retrieval", function () {

        test("Anonymous string retrieval", function() {

            var valueId = database.call("json_store.create_string", {
                p_value: "Hello, World!"
            });

            var value = database.call("json_store.get_string", {
                p_path: `#${valueId}`
            });

            expect(value).to.be("Hello, World!");

        });

        test("Anonymous number retrieval", function() {

            var valueId = database.call("json_store.create_number", {
                p_value: 123.456
            });

            var value = database.call("json_store.get_number", {
                p_path: `#${valueId}`
            });

            expect(value).to.be(123.456);

        });

        test("Anonymous boolean retrieval", function() {

            var valueId = database.call("json_store.create_boolean", {
                p_value: true
            });

            var value = database.call("json_store.get_boolean", {
                p_path: `#${valueId}`
            });

            expect(value).to.be(true);

        });

        test("Anonymous null retrieval as string", function() {

            var valueId = database.call("json_store.create_null");

            var value = database.call("json_store.get_string", {
                p_path: `#${valueId}`
            });

            expect(value).to.be(null);

        });

        test("Anonymous null retrieval as number", function() {

            var valueId = database.call("json_store.create_null");

            var value = database.call("json_store.get_number", {
                p_path: `#${valueId}`
            });

            expect(value).to.be(null);

        });

        test("Anonymous null retrieval as boolean", function() {

            var valueId = database.call("json_store.create_null");

            var value = database.call("json_store.get_boolean", {
                p_path: `#${valueId}`
            });

            expect(value).to.be(null);

        });

        test("Anonymous string retrieval as JSON", function() {
        
            var valueId = database.call("json_store.create_string", {
                p_value: "Hello, World!"
            });

            var value = database.call("json_store.get_json", {
                p_path: `#${valueId}`
            });

            expect(value).to.be("Hello, World!");
        
        });

        test("Anonymous escaped string retrieval as JSON", function() {
        
            var valueId = database.call("json_store.create_string", {
                p_value: "Hello,\n\"World\"!"
            });

            var value = database.call("json_store.get_json", {
                p_path: `#${valueId}`
            });

            expect(value).to.be("Hello,\n\"World\"!");
        
        });

        test("Anonymous number retrieval as JSON", function() {
        
            var valueId = database.call("json_store.create_number", {
                p_value: 123.456
            });

            var value = database.call("json_store.get_json", {
                p_path: `#${valueId}`
            });

            expect(value).to.be(123.456);
        
        });

        test("Anonymous boolean retrieval as JSON", function() {
        
            var valueId = database.call("json_store.create_boolean", {
                p_value: true
            });

            var value = database.call("json_store.get_json", {
                p_path: `#${valueId}`
            });

            expect(value).to.be(true);
        
        });

        test("Anonymous null retrieval as JSON", function() {
        
            var valueId = database.call("json_store.create_null");

            var value = database.call("json_store.get_json", {
                p_path: `#${valueId}`
            });

            expect(value).to.be(null);
        
        });

        test("Anonymous null retrieval as JSON", function() {
        
            var valueId = database.call("json_store.create_null");

            var value = database.call("json_store.get_json", {
                p_path: `#${valueId}`
            });

            expect(value).to.be(null);
        
        });

        test("Anonymous empty object retrieval as JSON", function() {
        
            var valueId = database.call("json_store.create_json", {
                p_content: {}
            });

            var value = database.call("json_store.get_json", {
                p_path: `#${valueId}`
            });

            expect(value).to.eql({});
        
        });

        test("Anonymous object with one property retrieval as JSON", function() {
        
            var valueId = database.call("json_store.create_json", {
                p_content: {
                    name: "Sergejs"
                }
            });

            var value = database.call("json_store.get_json", {
                p_path: `#${valueId}`
            });

            expect(value).to.eql({
                name: "Sergejs"
            });
        
        });

        test("Anonymous object with escaped property retrieval as JSON", function() {
        
            var valueId = database.call("json_store.create_json", {
                p_content: {
                    "Hello,\n\"World\"!": "Sergejs"
                }
            });

            var value = database.call("json_store.get_json", {
                p_path: `#${valueId}`
            });

            expect(value).to.eql({
                "Hello,\n\"World\"!": "Sergejs"
            });
        
        });

        test("Anonymous object with multiple properties retrieval as JSON", function() {
        
            var valueId = database.call("json_store.create_json", {
                p_content: {
                    name: "Sergejs",
                    surname: "Vinniks",
                    age: 35,
                    married: true
                }
            });

            var value = database.call("json_store.get_json", {
                p_path: `#${valueId}`
            });

            expect(value).to.eql({
                name: "Sergejs",
                surname: "Vinniks",
                age: 35,
                married: true
            });
        
        });

        test("Anonymous object with nested object retrieval as JSON", function() {
        
            var valueId = database.call("json_store.create_json", {
                p_content: {
                    name: "Sergejs",
                    surname: "Vinniks",
                    child: {
                        name: "Alisa",
                        surname: "Vinnika"
                    },
                    age: 35,
                    married: true
                }
            });

            var value = database.call("json_store.get_json", {
                p_path: `#${valueId}`
            });

            expect(value).to.eql({
                name: "Sergejs",
                surname: "Vinniks",
                child: {
                    name: "Alisa",
                    surname: "Vinnika"
                },
                age: 35,
                married: true
            });
        
        });

        test("Anonymous empty array retrieval as JSON", function() {
        
            var valueId = database.call("json_store.create_json", {
                p_content: []
            });

            var value = database.call("json_store.get_json", {
                p_path: `#${valueId}`
            });

            expect(value).to.eql([]);
        
        });

        test("Anonymous array with one element retrieval as JSON", function() {
        
            var valueId = database.call("json_store.create_json", {
                p_content: [123]
            });

            var value = database.call("json_store.get_json", {
                p_path: `#${valueId}`
            });

            expect(value).to.eql([123]);
        
        });

        test("Anonymous array with multiple elements retrieval as JSON", function() {
        
            var valueId = database.call("json_store.create_json", {
                p_content: [123, "Hello", true, null]
            });

            var value = database.call("json_store.get_json", {
                p_path: `#${valueId}`
            });

            expect(value).to.eql([123, "Hello", true, null]);
        
        });

        test("Anonymous two-dimensional array retrieval as JSON", function() {
        
            var valueId = database.call("json_store.create_json", {
                p_content: [123, ["a", "b"], [null, null, 1, 1]]
            });

            var value = database.call("json_store.get_json", {
                p_path: `#${valueId}`
            });

            expect(value).to.eql([123, ["a", "b"], [null, null, 1, 1]]);
        
        });

        test("Anonymous large array retrieval as JSON", function() {
        
            var array = [];

            for (var i = 0; i < 100; i++)
                array[i] = i;

            var valueId = database.call("json_store.create_json", {
                p_content: array
            });

            var value = database.call("json_store.get_json", {
                p_path: `#${valueId}`
            });

            expect(value).to.eql(array);
        
        });

        teardown("Rollback", function() {
            database.rollback();
        });

    });

    suite("Named value retrieval", function() {

        test("Named string retrieval", function() {

            database.call("json_store.set_string", {
                p_path: "$.jodus_string",
                p_value: "Hello, World!"
            });

            var value = database.call("json_store.get_string", {
                p_path: "$.jodus_string"
            });

            expect(value).to.be("Hello, World!");

        });

        test("Named number retrieval", function() {

            var valueId = database.call("json_store.set_number", {
                p_path: "$.jodus_number",
                p_value: 123.456
            });

            var value = database.call("json_store.get_number", {
                p_path: "$.jodus_number"
            });

            expect(value).to.be(123.456);

        });

        test("Named boolean retrieval", function() {

            var valueId = database.call("json_store.set_boolean", {
                p_path: "$.jodus_boolean",
                p_value: true
            });

            var value = database.call("json_store.get_boolean", {
                p_path: "$.jodus_boolean"
            });

            expect(value).to.be(true);

        });

        test("Named null retrieval as string", function() {

            database.call("json_store.set_null", {
                p_path: "$.jodus_null"
            });

            var value = database.call("json_store.get_string", {
                p_path: "$.jodus_null"
            });

            expect(value).to.be(null);

        });

        test("Named null retrieval as number", function() {

            database.call("json_store.set_null", {
                p_path: "$.jodus_null"
            });

            var value = database.call("json_store.get_number", {
                p_path: "$.jodus_null"
            });

            expect(value).to.be(null);

        });

        test("Named null retrieval as string", function() {

            database.call("json_store.set_null", {
                p_path: "$.jodus_null"
            });

            var value = database.call("json_store.get_boolean", {
                p_path: "$.jodus_null"
            });

            expect(value).to.be(null);

        });

        test("Named complex object retrieval", function() {
        
            database.call("json_store.set_json", {
                p_path: "$.jodus_me",
                p_content: {
                    name: "Sergejs",
                    surname: "Vinniks",
                    age: 35,
                    married: true,
                    phones: [
                        {
                            type: "fixed",
                            number: "12345"
                        },
                        {
                            type: "mobile",
                            number: "54321"
                        },
                    ]
                }
            });   

            var value = database.call("json_store.get_json", {
                p_path: "$.jodus_me"
            }); 

            expect(value).to.eql({
                name: "Sergejs",
                surname: "Vinniks",
                age: 35,
                married: true,
                phones: [
                    {
                        type: "fixed",
                        number: "12345"
                    },
                    {
                        type: "mobile",
                        number: "54321"
                    },
                ]
            });
        
        });
        
        teardown("Rollback", function() {
            database.rollback();
        });

    });

});

suite("Huge JSON document handling", function() {

    var document;
    var documentId;

    setup("Create a huge array", function() {
        
        document = [];

        for (var i = 0; i < 100000; i++)
            document[i] = i;

    });

    test("Save anonymous huge document via the VARCHAR method", function() {

        expect(function() {
        
            database.call("json_store.create_json", {
                p_content: JSON.stringify(document)
            });
        
        }).to.throw(/./);

    });

    test("Save anonymous huge document via the CLOB method", function() {

        documentId = database.call("json_store.create_json_clob", {
            p_content: document
        });
        
    });

    test("Retrieve anonymous huge document via the VARCHAR method", function() {

        expect(function() {
        
            database.call("json_store.get_json", {
                p_path: `#${documentId}`
            });
        
        }).to.throw(/./);
        
    });

    test("Retrieve anonymous huge document via the CLOB method", function() {
    
        var savedDocument = database.call("json_store.get_json_clob", {
            p_path: `#${documentId}`
        });

        expect(savedDocument).to.eql(document);
    
    });
    

    teardown("Rollback", function() {
        database.rollback();
    });

});

suite("JSON document modification", function() {

    setup("Create a document to play with", function() {

        database.call("json_store.set_json", {
            p_path: "$.jodus_document",
            p_content: {
                persons: [
                    {
                        id: 123,
                        name: "Sergejs",
                        age: 35,
                        children: [
                            {
                                name: "Alisa",
                                age: 2
                            }
                        ]
                    }
                ]
            }
        });

    });

    test("Add string property to the object", function() {
    
        database.call("json_store.set_string", {
            p_path: "$.jodus_document.persons[0].surname",
            p_value: "Vinniks"
        });    

        var document = database.call("json_store.get_json", {
            p_path: "$.jodus_document"
        });

        expect(document).to.eql({
            persons: [
                {
                    id: 123,
                    name: "Sergejs",
                    surname: "Vinniks",
                    age: 35,
                    children: [
                        {
                            name: "Alisa",
                            age: 2
                        }
                    ]
                }
            ]
        });
    
    });
    
    test("Add JSON property to the object", function() {
    
        database.call("json_store.set_json", {
            p_path: "$.jodus_document.persons[0].children[0].surname",
            p_content: "Vinnika"
        });    

        var document = database.call("json_store.get_json", {
            p_path: "$.jodus_document"
        });

        expect(document).to.eql({
            persons: [
                {
                    id: 123,
                    name: "Sergejs",
                    surname: "Vinniks",
                    age: 35,
                    children: [
                        {
                            name: "Alisa",
                            surname: "Vinnika",
                            age: 2
                        }
                    ]
                }
            ]
        });
    
    });

    test("Add a next object element into the array", function() {
    
        database.call("json_store.set_json", {
            p_path: "$.jodus_document.persons[1]",
            p_content: {
                id: 321,
                name: "Janis",
                surname: "Berzins"
            }
        });    

        var document = database.call("json_store.get_json", {
            p_path: "$.jodus_document"
        });

        expect(document).to.eql({
            persons: [
                {
                    id: 123,
                    name: "Sergejs",
                    surname: "Vinniks",
                    age: 35,
                    children: [
                        {
                            name: "Alisa",
                            surname: "Vinnika",
                            age: 2
                        }
                    ]
                },
                {
                    id: 321,
                    name: "Janis",
                    surname: "Berzins"
                }
            ]
        });
    
    });

    test("Fill a gap between array elements with nulls", function() {
    
        database.call("json_store.set_json", {
            p_path: "$.jodus_document.persons[4]",
            p_content: {
                id: 999,
                name: "Frank",
                surname: "Sinatra"
            }
        });    

        var document = database.call("json_store.get_json", {
            p_path: "$.jodus_document"
        });

        expect(document).to.eql({
            persons: [
                {
                    id: 123,
                    name: "Sergejs",
                    surname: "Vinniks",
                    age: 35,
                    children: [
                        {
                            name: "Alisa",
                            surname: "Vinnika",
                            age: 2
                        }
                    ]
                },
                {
                    id: 321,
                    name: "Janis",
                    surname: "Berzins"
                },
                null,
                null,
                {
                    id: 999,
                    name: "Frank",
                    surname: "Sinatra"
                }
            ]
        });
    
    });

    teardown("Rollback", function() {
        database.rollback();
    });

});