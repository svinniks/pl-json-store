
suite("JSON path parser tests", function() {

    test("Invalid start of the path", function() {
    
        expect(function() {
        
            var result = database.call("json_documents.parse_path", {
                p_path_string: "123"
            });
        
        }).to.throw(/JDOC-00001/);
    
    });

    test("Invalid start of the path with spaces", function() {
    
        expect(function() {
        
            var result = database.call("json_documents.parse_path", {
                p_path_string: "   123"
            });
        
        }).to.throw(/JDOC-00001/);
    
    });
    
    test("Invalid start of the property", function() {
    
        expect(function() {
        
            var result = database.call("json_documents.parse_path", {
                p_path_string: "hello.123"
            });
        
        }).to.throw(/JDOC-00001/);
    
    });

    test("Invalid start of the property with spaces", function() {
    
        expect(function() {
        
            var result = database.call("json_documents.parse_path", {
                p_path_string: "  hello  .  123"
            });
        
        }).to.throw(/JDOC-00001/);
    
    });

    test("Invalid character in simple name", function() {
    
        expect(function() {
        
            var result = database.call("json_documents.parse_path", {
                p_path_string: "hello-123"
            });
        
        }).to.throw(/JDOC-00001/);
    
    });

    test("Invalid start of ID", function() {
    
        expect(function() {
        
            var result = database.call("json_documents.parse_path", {
                p_path_string: "#a"
            });
        
        }).to.throw(/JDOC-00001/);
    
    });

    test("Invalid character in ID", function() {
    
        expect(function() {
        
            var result = database.call("json_documents.parse_path", {
                p_path_string: "#123a"
            });
        
        }).to.throw(/JDOC-00001/);
    
    });

    test(". or [ missing", function() {
    
        expect(function() {
        
            var result = database.call("json_documents.parse_path", {
                p_path_string: "abc abc"
            });
        
        }).to.throw(/JDOC-00001/);
    
    });

    test("Invalid start of array element", function() {
    
        expect(function() {
        
            var result = database.call("json_documents.parse_path", {
                p_path_string: "abc[cda]"
            });
        
        }).to.throw(/JDOC-00001/);
    
    });

    test("Invalid start of array element with spaces", function() {
    
        expect(function() {
        
            var result = database.call("json_documents.parse_path", {
                p_path_string: "  abc  [  cba  ]  "
            });
        
        }).to.throw(/JDOC-00001/);
    
    });

    test("Invalid character in array element", function() {
    
        expect(function() {
        
            var result = database.call("json_documents.parse_path", {
                p_path_string: "abc[123a]"
            });
        
        }).to.throw(/JDOC-00001/);
    
    });

    test("] missing", function() {
    
        expect(function() {
        
            var result = database.call("json_documents.parse_path", {
                p_path_string: "abc[123.cba"
            });
        
        }).to.throw(/JDOC-00001/);
    
    });

    test("Trailing ] missing", function() {
    
        expect(function() {
        
            var result = database.call("json_documents.parse_path", {
                p_path_string: "abc[123"
            });
        
        }).to.throw(/JDOC-00002/);
    
    });

    test("Name closing quote missing", function() {
    
        expect(function() {
        
            var result = database.call("json_documents.parse_path", {
                p_path_string: "\"abc" 
            });
        
        }).to.throw(/JDOC-00002/);
    
    });

    test("Array element closing quote missing", function() {
    
        expect(function() {
        
            var result = database.call("json_documents.parse_path", {
                p_path_string: 'hello["world'
            });
        
        }).to.throw(/JDOC-00002/);
    
    });

    test("Dot in the end", function() {
    
        expect(function() {
        
            var result = database.call("json_documents.parse_path", {
                p_path_string: 'hello.world.'
            });
        
        }).to.throw(/JDOC-00002/);
    
    });

    test("Dot in the end with spaces", function() {
    
        expect(function() {
        
            var result = database.call("json_documents.parse_path", {
                p_path_string: '  hello  .  world  .  '
            });
        
        }).to.throw(/JDOC-00002/);
    
    });

    test("Empty path", function() {

        var result = database.call("json_documents.parse_path", {
            p_path_string: null
        });

        expect(result).to.eql([]);

    });

    test("Empty path (spaces only)", function() {

        var result = database.call("json_documents.parse_path", {
            p_path_string: "   "
        });

        expect(result).to.eql([]);

    });

    test("Root only", function() {

        var result = database.call("json_documents.parse_path", {
            p_path_string: "$"
        });

        expect(result).to.eql([
            {
                type: 1,
                value: null
            }
        ]);

    });

    test("Root only with spaces", function() {

        var result = database.call("json_documents.parse_path", {
            p_path_string: "  $    "
        });

        expect(result).to.eql([
            {
                type: 1,
                value: null
            }
        ]);

    });

    test("Single simple name", function() {

        var result = database.call("json_documents.parse_path", {
            p_path_string: "hello"
        });

        expect(result).to.eql([
            {
                type: 3,
                value: "hello"
            }
        ]);

    });

    test("Single simple name with spaces", function() {

        var result = database.call("json_documents.parse_path", {
            p_path_string: "   hello   "
        });

        expect(result).to.eql([
            {
                type: 3,
                value: "hello"
            }
        ]);

    });

    test("Single quoted name", function() {

        var result = database.call("json_documents.parse_path", {
            p_path_string: '" 89 "'
        });

        expect(result).to.eql([
            {
                type: 3,
                value: " 89 "
            }
        ]);

    });

    test("Single quoted name with spaces", function() {

        var result = database.call("json_documents.parse_path", {
            p_path_string: '   " 89 "   '
        });

        expect(result).to.eql([
            {
                type: 3,
                value: " 89 "
            }
        ]);

    });

    test("Single quoted name with escaped quote", function() {

        var result = database.call("json_documents.parse_path", {
            p_path_string: '" 89\\" "'
        });

        expect(result).to.eql([
            {
                type: 3,
                value: " 89\" "
            }
        ]);

    });

    test("Single ID", function() {

        var result = database.call("json_documents.parse_path", {
            p_path_string: '#12345'
        });

        expect(result).to.eql([
            {
                type: 2,
                value: "12345"
            }
        ]);

    });

    test("Single ID with spaces", function() {

        var result = database.call("json_documents.parse_path", {
            p_path_string: '   #12345   '
        });

        expect(result).to.eql([
            {
                type: 2,
                value: "12345"
            }
        ]);

    });

    test("Single digit array element of root", function() {

        var result = database.call("json_documents.parse_path", {
            p_path_string: '$[1]'
        });

        expect(result).to.eql([
            {
                type: 1,
                value: null
            },
            {
                type: 3,
                value: "1"
            }
        ]);

    });

    test("Single digit array element of root with spaces", function() {

        var result = database.call("json_documents.parse_path", {
            p_path_string: '  $  [  1  ]  '
        });

        expect(result).to.eql([
            {
                type: 1,
                value: null
            },
            {
                type: 3,
                value: "1"
            }
        ]);

    });

    test("Multi-digit array element of root", function() {

        var result = database.call("json_documents.parse_path", {
            p_path_string: '$[12345]'
        });

        expect(result).to.eql([
            {
                type: 1,
                value: null
            },
            {
                type: 3,
                value: "12345"
            }
        ]);

    });

    test("Multi-digit array element of root with spaces", function() {

        var result = database.call("json_documents.parse_path", {
            p_path_string: '  $  [  12345  ]  '
        });

        expect(result).to.eql([
            {
                type: 1,
                value: null
            },
            {
                type: 3,
                value: "12345"
            }
        ]);

    });

    test("Just an array element", function() {

        var result = database.call("json_documents.parse_path", {
            p_path_string: '[12345]'
        });

        expect(result).to.eql([
            {
                type: 3,
                value: "12345"
            }
        ]);

    });

    test("Quoted array element of root", function() {

        var result = database.call("json_documents.parse_path", {
            p_path_string: '$["hello"]'
        });

        expect(result).to.eql([
            {
                type: 1,
                value: null
            },
            {
                type: 3,
                value: "hello"
            }
        ]);

    });

    test("Quoted array element of root with spaces", function() {

        var result = database.call("json_documents.parse_path", {
            p_path_string: '  $  [  "hello"  ]  '
        });

        expect(result).to.eql([
            {
                type: 1,
                value: null
            },
            {
                type: 3,
                value: "hello"
            }
        ]);

    });

    test("Array element of simple name", function() {

        var result = database.call("json_documents.parse_path", {
            p_path_string: 'hello[123]'
        });

        expect(result).to.eql([
            {
                type: 3,
                value: "hello"
            },
            {
                type: 3,
                value: "123"
            }
        ]);

    });

    test("Array element of simple name with spaces", function() {

        var result = database.call("json_documents.parse_path", {
            p_path_string: '  hello  [  123  ]  '
        });

        expect(result).to.eql([
            {
                type: 3,
                value: "hello"
            },
            {
                type: 3,
                value: "123"
            }
        ]);

    });

    test("Array element of quoted name", function() {

        var result = database.call("json_documents.parse_path", {
            p_path_string: '"hello"[123]'
        });

        expect(result).to.eql([
            {
                type: 3,
                value: "hello"
            },
            {
                type: 3,
                value: "123"
            }
        ]);

    });

    test("Array element of quoted name with spaces", function() {

        var result = database.call("json_documents.parse_path", {
            p_path_string: '  "hello"  [  123  ]  '
        });

        expect(result).to.eql([
            {
                type: 3,
                value: "hello"
            },
            {
                type: 3,
                value: "123"
            }
        ]);

    });

    test("Array element of ID", function() {

        var result = database.call("json_documents.parse_path", {
            p_path_string: '#123[456]'
        });

        expect(result).to.eql([
            {
                type: 2,
                value: "123"
            },
            {
                type: 3,
                value: "456"
            }
        ]);

    });

    test("Array element of ID with spaces", function() {

        var result = database.call("json_documents.parse_path", {
            p_path_string: '  #123  [  456  ]  '
        });

        expect(result).to.eql([
            {
                type: 2,
                value: "123"
            },
            {
                type: 3,
                value: "456"
            }
        ]);

    });

    test("Multi-dimensional array access", function() {

        var result = database.call("json_documents.parse_path", {
            p_path_string: 'array[123]["321"]'
        });

        expect(result).to.eql([
            {
                type: 3,
                value: "array"
            },
            {
                type: 3,
                value: "123"
            },
            {
                type: 3,
                value: "321"
            }
        ]);

    });

    test("Multi-dimensional array access with spaces", function() {

        var result = database.call("json_documents.parse_path", {
            p_path_string: ' array [123] ["321"] '
        });

        expect(result).to.eql([
            {
                type: 3,
                value: "array"
            },
            {
                type: 3,
                value: "123"
            },
            {
                type: 3,
                value: "321"
            }
        ]);

    });

    test("Multiple mixed elements", function() {

        var result = database.call("json_documents.parse_path", {
            p_path_string: 'hello.world.#12345.#54321."aaa"."bbb"[1]'
        });

        expect(result).to.eql([
            {
                type: 3,
                value: "hello"
            },
            {
                type: 3,
                value: "world"
            },
            {
                type: 2,
                value: "12345"
            },
            {
                type: 2,
                value: "54321"
            },
            {
                type: 3,
                value: "aaa"
            },
            {
                type: 3,
                value: "bbb"
            },
            {
                type: 3,
                value: "1"
            }
        ]);

    });

    test("Multiple mixed elements with spaces", function() {

        var result = database.call("json_documents.parse_path", {
            p_path_string: '  hello  .  world  .  #12345  .  #54321  .  "aaa"  .  "bbb"  '
        });

        expect(result).to.eql([
            {
                type: 3,
                value: "hello"
            },
            {
                type: 3,
                value: "world"
            },
            {
                type: 2,
                value: "12345"
            },
            {
                type: 2,
                value: "54321"
            },
            {
                type: 3,
                value: "aaa"
            },
            {
                type: 3,
                value: "bbb"
            }
        ]);

    });

    test("Multiple mixed elements starting with root", function() {

        var result = database.call("json_documents.parse_path", {
            p_path_string: '$.hello.world.#12345.#54321."aaa"."bbb"'
        });

        expect(result).to.eql([
            {
                type: 1,
                value: null
            },
            {
                type: 3,
                value: "hello"
            },
            {
                type: 3,
                value: "world"
            },
            {
                type: 2,
                value: "12345"
            },
            {
                type: 2,
                value: "54321"
            },
            {
                type: 3,
                value: "aaa"
            },
            {
                type: 3,
                value: "bbb"
            }
        ]);

    });

    test("Multiple mixed elements starting with root, with spaces", function() {

        var result = database.call("json_documents.parse_path", {
            p_path_string: '  $  .  hello . world.#12345.#54321."aaa"."bbb"'
        });

        expect(result).to.eql([
            {
                type: 1,
                value: null
            },
            {
                type: 3,
                value: "hello"
            },
            {
                type: 3,
                value: "world"
            },
            {
                type: 2,
                value: "12345"
            },
            {
                type: 2,
                value: "54321"
            },
            {
                type: 3,
                value: "aaa"
            },
            {
                type: 3,
                value: "bbb"
            }
        ]);

    });

});

suite("JSON document management tests", function() {

    test("Try to modify the root", function() {
        
        expect(function() {
        
            var result = database.call("json_documents.set_json", {
                p_path: '$',
                p_content: 'null'
            });
        
        }).to.throw(/JDOC-00003/);
    
    });

    suite("Anonymous value creation tests", function() {

        test("Create anonymous null", function() {

            var id = database.call("json_documents.set_json", {
                p_path: null,
                p_content: 'null'
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

            var id = database.call("json_documents.set_json", {
                p_path: null,
                p_content: '"Hello, World!"'
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

            var id = database.call("json_documents.set_json", {
                p_path: null,
                p_content: '123.456'
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

            var id = database.call("json_documents.set_json", {
                p_path: null,
                p_content: 'true'
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

        test("Create anonymous object", function() {

            var id = database.call("json_documents.set_json", {
                p_path: null,
                p_content: '{}'
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

            var id = database.call("json_documents.set_json", {
                p_path: null,
                p_content: '[]'
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

            var id = database.call("json_documents.set_json", {
                p_path: null,
                p_content: '{"name":"Sergejs","age":35,"married":true,"children":null}'
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

            var id = database.call("json_documents.set_json", {
                p_path: null,
                p_content: '{"name":"Sergejs","age":35,"address":{"country":"Latvia","city":"Riga"}}'
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

            var id = database.call("json_documents.set_json", {
                p_path: null,
                p_content: '["Sergejs","Vinniks",35,true,null]'
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
                [2, "S", "1", "Sergejs"],
                [2, "S", "2", "Vinniks"],
                [2, "N", "3", "35"],
                [2, "B", "4", "true"],
                [2, "E", "5", null]
            ]);

        });

        test("Create anonymous multidimensional array", function() {

            var id = database.call("json_documents.set_json", {
                p_path: null,
                p_content: '[["Sergejs","Vinniks",35,true,null],["Hello","World"]]'
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
                [2, "A", "1", null],
                [3, "S", "1", "Sergejs"],
                [3, "S", "2", "Vinniks"],
                [3, "N", "3", "35"],
                [3, "B", "4", "true"],
                [3, "E", "5", null],
                [2, "A", "2", null],
                [3, "S", "1", "Hello"],
                [3, "S", "2", "World"]
            ]);

        });

        test("Create anonymous complex object", function() {

            var id = database.call("json_documents.set_json", {
                p_path: null,
                p_content: JSON.stringify({
                    name: "Sergejs",
                    surname: "Vinniks",
                    phones: [
                        {
                            type: "fixed",
                            number: 1234567
                        }
                    ]
                })
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
                [3, "O", "1", null],
                [4, "S", "type", "fixed"],
                [4, "N", "number", "1234567"],
            ]);

        });

        teardown("Teardown", function() {
            database.rollback();
        });

    });

    suite("Named value management tests", function() {

        test("Create named null in the root", function() {

            var id = database.call("json_documents.set_json", {
                p_path: '$.null',
                p_content: 'null'
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
                name: "null",
                value: null
            });

        });

        test("Create named string in the root", function() {

            var id = database.call("json_documents.set_json", {
                p_path: '$.string',
                p_content: '"Hello, World!"'
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
                name: "string",
                value: "Hello, World!"
            });

        });

        test("Create named number in the root", function() {

            var id = database.call("json_documents.set_json", {
                p_path: '$.number',
                p_content: '123.456'
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
                name: "number",
                value: "123.456"
            });

        });

        test("Create named boolean in the root", function() {

            var id = database.call("json_documents.set_json", {
                p_path: '$.boolean',
                p_content: 'true'
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
                name: "boolean",
                value: "true"
            });

        });

        test("Create named object in the root", function() {

            var id = database.call("json_documents.set_json", {
                p_path: '$.object',
                p_content: '{}'
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
                name: "object",
                value: null
            });

        });

        test("Create named array in the root", function() {

            var id = database.call("json_documents.set_json", {
                p_path: '$.array',
                p_content: '[]'
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
                name: "array",
                value: null
            });

        });

    });

});

