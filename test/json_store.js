/* 
    Copyright 2017 Sergejs Vinniks

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at
 
      http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
*/

suite("TO_INDEX function tests", function() {

    test("Zero", function() {
        
        var result = database.call("to_index", {
            p_index: "0"
        });

        expect(result).to.be(0);

    });

    test("Positive integer", function() {
        
        var result = database.call("to_index", {
            p_index: "123"
        });

        expect(result).to.be(123);

    });

    test("Positive float", function() {
        
        var result = database.call("to_index", {
            p_index: "123.321"
        });

        expect(result).to.be.null;

    });

    test("Negative integer", function() {
        
        var result = database.call("to_index", {
            p_index: "-123"
        });

        expect(result).to.be.null;

    });

    test("Negative float", function() {
        
        var result = database.call("to_index", {
            p_index: "-123.321"
        });

        expect(result).to.be.null;

    });

    test("Non-number (letters)", function() {
        
        var result = database.call("to_index", {
            p_index: "ABC"
        });

        expect(result).to.be.null;

    });

    test("Number starting with 0", function() {
        
        var result = database.call("to_index", {
            p_index: "00123"
        });

        expect(result).to.be.null;

    });

    test("Number starting with space", function() {
        
        var result = database.call("to_index", {
            p_index: " 123"
        });

        expect(result).to.be.null;

    });

});

suite("JSON store management tests", function() {

    suite("JSON value creation tests", function() {
    
        suite("Scalar value creation tests", function() {
        
            suite("Create anonymous values using JSON_STORE.CREATE_XXX functions", function() {

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
                        value: null,
                        locked: null
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
                        value: "Hello, World!",
                        locked: null
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
                        value: "123.456",
                        locked: null
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
                        value: "true",
                        locked: null
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
                        value: null,
                        locked: null
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
                        value: null,
                        locked: null
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
                        value: null,
                        locked: null
                    });

                });

                teardown("Rollback", function() {
                    database.rollback();
                });

            });

            suite("Create anonymous values using JSON_STORE.CREATE_JSON", function() {
            
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
                        value: null,
                        locked: null
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
                        value: "Hello, World!",
                        locked: null
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
                        value: "123.456",
                        locked: null
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
                        value: "true",
                        locked: null
                    });

                });  

                teardown("Rollback", function() {
                    database.rollback();
                });  
            
            });

            suite("Create named values in the root using JSON_STORE.SET_XXX functions", function() {
            
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
                        parent_id: 0,
                        type: 'E',
                        name: "jodus_null",
                        value: null,
                        locked: null
                    });

                });

                test("Create named null (overloaded)", function() {

                    database.call2("json_store.set_null", {
                        p_path: '$.jodus_null'
                    });

                    var value = database.selectObject(`*
                        FROM json_values
                        WHERE name = 'jodus_null'
                              AND parent_id = 0
                    `);

                    expect(value).to.eql({
                        id: value.id,
                        parent_id: 0,
                        type: 'E',
                        name: "jodus_null",
                        value: null,
                        locked: null
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
                        parent_id: 0,
                        type: 'S',
                        name: "jodus_string",
                        value: "Hello, World!",
                        locked: null
                    });

                });

                test("Create named string (overloaded)", function() {

                    database.call2("json_store.set_string", {
                        p_path: '$.jodus_string',
                        p_value: 'Hello, World!'
                    });

                    var value = database.selectObject(`*
                        FROM json_values
                        WHERE name = 'jodus_string'
                              AND parent_id = 0
                    `);

                    expect(value).to.eql({
                        id: value.id,
                        parent_id: 0,
                        type: 'S',
                        name: "jodus_string",
                        value: "Hello, World!",
                        locked: null
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
                        parent_id: 0,
                        type: 'N',
                        name: "jodus_number",
                        value: "123.456",
                        locked: null
                    });

                });

                test("Create named number (overloaded)", function() {

                    database.call2("json_store.set_number", {
                        p_path: '$.jodus_number',
                        p_value: 123.456
                    });

                    var value = database.selectObject(`*
                        FROM json_values
                        WHERE name = 'jodus_number'
                              AND parent_id = 0
                    `);

                    expect(value).to.eql({
                        id: value.id,
                        parent_id: 0,
                        type: 'N',
                        name: "jodus_number",
                        value: "123.456",
                        locked: null
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
                        parent_id: 0,
                        type: 'B',
                        name: "jodus_boolean",
                        value: "true",
                        locked: null
                    });

                });

                test("Create named boolean (overloaded)", function() {

                    database.call2("json_store.set_boolean", {
                        p_path: '$.jodus_boolean',
                        p_value: true
                    });

                    var value = database.selectObject(`*
                        FROM json_values
                        WHERE name = 'jodus_boolean'
                              AND parent_id = 0
                    `);

                    expect(value).to.eql({
                        id: value.id,
                        parent_id: 0,
                        type: 'B',
                        name: "jodus_boolean",
                        value: "true",
                        locked: null
                    });

                });

                test("Create named null string", function() {

                    var id = database.call("json_store.set_string", {
                        p_path: '$.jodus_string',
                        p_value: null
                    });

                    expect(id).to.not.be(null);

                    var value = database.selectObject(`*
                        FROM json_values
                        WHERE id = ${id}
                    `);

                    expect(value).to.eql({
                        id: id,
                        parent_id: 0,
                        type: 'E',
                        name: "jodus_string",
                        value: null,
                        locked: null
                    });

                });

                test("Create named null number", function() {

                    var id = database.call("json_store.set_number", {
                        p_path: '$.jodus_number',
                        p_value: null
                    });

                    expect(id).to.not.be(null);

                    var value = database.selectObject(`*
                        FROM json_values
                        WHERE id = ${id}
                    `);

                    expect(value).to.eql({
                        id: id,
                        parent_id: 0,
                        type: 'E',
                        name: "jodus_number",
                        value: null,
                        locked: null
                    });

                });

                test("Create named null boolean", function() {

                    var id = database.call("json_store.set_boolean", {
                        p_path: '$.jodus_boolean',
                        p_value: null
                    });

                    expect(id).to.not.be(null);

                    var value = database.selectObject(`*
                        FROM json_values
                        WHERE id = ${id}
                    `);

                    expect(value).to.eql({
                        id: id,
                        parent_id: 0,
                        type: 'E',
                        name: "jodus_boolean",
                        value: null,
                        locked: null
                    });

                });

                teardown("Rollback", function() {
                    database.rollback();
                });
            
            });

            suite("Create named values in the root using JSON_STORE.SET_JSON", function() {
            
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
                        parent_id: 0,
                        type: 'E',
                        name: "jodus_null",
                        value: null,
                        locked: null
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
                        parent_id: 0,
                        type: 'S',
                        name: "jodus_string",
                        value: "Hello, World!",
                        locked: null
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
                        parent_id: 0,
                        type: 'N',
                        name: "jodus_number",
                        value: "123.456",
                        locked: null
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
                        parent_id: 0,
                        type: 'B',
                        name: "jodus_boolean",
                        value: "true",
                        locked: null
                    });

                });

                teardown("Rollback", function() {
                    database.rollback();
                });
            
            });
        
        });

        suite("Object creation tests", function() {
        
            test("Create anonymous object using JSON_STORE.CREATE_OBJECT", function() {

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
                    value: null,
                    locked: null
                });

            });

            test("Create anonymous object using JSON_STORE.CREATE_JSON", function() {

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
                    value: null,
                    locked: null
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

            test("Create named object in the root using JSON_STORE.SET_OBJECT", function() {

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
                    parent_id: 0,
                    type: 'O',
                    name: "jodus_object",
                    value: null,
                    locked: null
                });

            });

            test("Create named object in the root using JSON_STORE.SET_JSON", function() {

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
                    parent_id: 0,
                    type: 'O',
                    name: "jodus_object",
                    value: null,
                    locked: null
                });

            });

            teardown("Rollback", function() {
                database.rollback();
            });

        });

        suite("Array creation tests", function() {
            
            test("Create anonymous array using JSON_STORE.CREATE_ARRAY", function() {

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
                    value: null,
                    locked: null
                });

            });

            test("Create anonymous array using JSON_STORE.CREATE_JSON", function() {

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
                    value: null,
                    locked: null
                });

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

            test("Create named array in the root using JSON_STORE.SET_ARRAY", function() {

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
                    parent_id: 0,
                    type: 'A',
                    name: "jodus_array",
                    value: null,
                    locked: null
                });

            });

            test("Create named array in the root using JSON_STORE.SET_JSON", function() {

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
                    parent_id: 0,
                    type: 'A',
                    name: "jodus_array",
                    value: null,
                    locked: null
                });

            });

            teardown("Rollback", function() {
                database.rollback();
            });

        });

    });

    suite("Complex object creation tests", function() {
    
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

    suite("JSON value retrieval tests", function() {
    
        suite("Anonymous value retrieval from the root", function () {

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

        suite("Named value retrieval from the root", function() {

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

    suite("JSON value modification tests", function() {
    
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

        suite("Object handling tests", function() {

            test("Add string property to an object", function() {
            
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
            
            test("Add JSON property to an object", function() {
            
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

        });

        suite("Array handling tests", function() {

            test("Access invalid index array element", function() {

                expect(function() {

                    database.call("json_store.set_string", {
                        p_path: "$.jodus_document.persons.abc",
                        p_value: "Hello, World!"
                    });

                }).to.throw(/JDOC-00013/);

            });

            test("Add next index object element into an array", function() {
            
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

            test("Fill the gap between array elements with nulls", function() {
            
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

            test("Retrieve length of an empty array", function() {
            
                var id = database.call("json_store.create_array");
            
                var length = database.call("json_store.get_length", {
                    p_path: `#${id}`
                });

                expect(length).to.be(0);

            });
           
            test("Retrieve array length", function() {

                var length = database.call("json_store.get_length", {
                    p_path: "$.jodus_document.persons"
                })

                expect(length).to.be(5);

            });

            test("Retrieve length of a non-array value", function() {

                expect(function() {

                    database.call("json_store.get_length", {
                        p_path: "$.jodus_document.persons[0]"
                    });

                }).to.throw(/JDOC-00012/);

            });

            test("Push string element into an array", function() {

                database.call("json_store.set_json", {
                    p_path: "$.jodus_document",
                    p_content: [1, 2, 3]
                });

                database.call("json_store.push_string", {
                    p_path: "$.jodus_document",
                    p_value: "Hello, World!"
                });

                var document = database.call("json_store.get_json", {
                    p_path: "$.jodus_document"
                });

                expect(document).to.eql([1, 2, 3, "Hello, World!"])

                database.rollback;

            });

            test("Push string element into an array (overloaded)", function() {

                database.call("json_store.set_json", {
                    p_path: "$.jodus_document",
                    p_content: [1, 2, 3]
                });

                database.call2("json_store.push_string", {
                    p_path: "$.jodus_document",
                    p_value: "Hello, World!"
                });

                var document = database.call("json_store.get_json", {
                    p_path: "$.jodus_document"
                });

                expect(document).to.eql([1, 2, 3, "Hello, World!"])

                database.rollback;

            });

            test("Push number element into an array", function() {

                database.call("json_store.set_json", {
                    p_path: "$.jodus_document",
                    p_content: [1, 2, 3]
                });

                database.call("json_store.push_number", {
                    p_path: "$.jodus_document",
                    p_value: 4
                });

                var document = database.call("json_store.get_json", {
                    p_path: "$.jodus_document"
                });

                expect(document).to.eql([1, 2, 3, 4])

                database.rollback;

            });

            test("Push number element into an array (overloaded)", function() {

                database.call("json_store.set_json", {
                    p_path: "$.jodus_document",
                    p_content: [1, 2, 3]
                });

                database.call2("json_store.push_number", {
                    p_path: "$.jodus_document",
                    p_value: 4
                });

                var document = database.call("json_store.get_json", {
                    p_path: "$.jodus_document"
                });

                expect(document).to.eql([1, 2, 3, 4])

                database.rollback;

            });

            test("Push boolean element into an array", function() {

                database.call("json_store.set_json", {
                    p_path: "$.jodus_document",
                    p_content: [1, 2, 3]
                });

                database.call("json_store.push_boolean", {
                    p_path: "$.jodus_document",
                    p_value: true
                });

                var document = database.call("json_store.get_json", {
                    p_path: "$.jodus_document"
                });

                expect(document).to.eql([1, 2, 3, true])

                database.rollback;

            });

            test("Push boolean element into an array (overloaded)", function() {

                database.call("json_store.set_json", {
                    p_path: "$.jodus_document",
                    p_content: [1, 2, 3]
                });

                database.call2("json_store.push_boolean", {
                    p_path: "$.jodus_document",
                    p_value: true
                });

                var document = database.call("json_store.get_json", {
                    p_path: "$.jodus_document"
                });

                expect(document).to.eql([1, 2, 3, true])

                database.rollback;

            });

            test("Push null into an array", function() {

                database.call("json_store.set_json", {
                    p_path: "$.jodus_document",
                    p_content: [1, 2, 3]
                });

                database.call("json_store.push_null", {
                    p_path: "$.jodus_document"
                });

                var document = database.call("json_store.get_json", {
                    p_path: "$.jodus_document"
                });

                expect(document).to.eql([1, 2, 3, null])

                database.rollback;

            });

            test("Push null into an array (overloaded)", function() {

                database.call("json_store.set_json", {
                    p_path: "$.jodus_document",
                    p_content: [1, 2, 3]
                });

                database.call("json_store.push_null", {
                    p_path: "$.jodus_document"
                });

                var document = database.call("json_store.get_json", {
                    p_path: "$.jodus_document"
                });

                expect(document).to.eql([1, 2, 3, null])

                database.rollback;

            });

            test("Push null string into an array", function() {

                database.call("json_store.set_json", {
                    p_path: "$.jodus_document",
                    p_content: [1, 2, 3]
                });

                database.call("json_store.push_string", {
                    p_path: "$.jodus_document",
                    p_value: null
                });

                var document = database.call("json_store.get_json", {
                    p_path: "$.jodus_document"
                });

                expect(document).to.eql([1, 2, 3, null])

                database.rollback;

            });

            test("Push null number into an array", function() {

                database.call("json_store.set_json", {
                    p_path: "$.jodus_document",
                    p_content: [1, 2, 3]
                });

                database.call("json_store.push_number", {
                    p_path: "$.jodus_document",
                    p_value: null
                });

                var document = database.call("json_store.get_json", {
                    p_path: "$.jodus_document"
                });

                expect(document).to.eql([1, 2, 3, null])

                database.rollback;

            });

            test("Push null boolean into an array", function() {

                database.call("json_store.set_json", {
                    p_path: "$.jodus_document",
                    p_content: [1, 2, 3]
                });

                database.call("json_store.push_boolean", {
                    p_path: "$.jodus_document",
                    p_value: null
                });

                var document = database.call("json_store.get_json", {
                    p_path: "$.jodus_document"
                });

                expect(document).to.eql([1, 2, 3, null])

                database.rollback;

            });

            test("Push object into an array", function() {

                database.call("json_store.set_json", {
                    p_path: "$.jodus_document",
                    p_content: [1, 2, 3]
                });

                database.call("json_store.push_object", {
                    p_path: "$.jodus_document"
                });

                var document = database.call("json_store.get_json", {
                    p_path: "$.jodus_document"
                });

                expect(document).to.eql([1, 2, 3, {}])

                database.rollback;

            });

            test("Push object into an array (overloaded)", function() {

                database.call("json_store.set_json", {
                    p_path: "$.jodus_document",
                    p_content: [1, 2, 3]
                });

                database.call("json_store.push_object", {
                    p_path: "$.jodus_document"
                });

                var document = database.call("json_store.get_json", {
                    p_path: "$.jodus_document"
                });

                expect(document).to.eql([1, 2, 3, {}])

                database.rollback;

            });

            test("Push array into an array", function() {

                database.call("json_store.set_json", {
                    p_path: "$.jodus_document",
                    p_content: [1, 2, 3]
                });
    
                database.call("json_store.push_array", {
                    p_path: "$.jodus_document"
                });
    
                var document = database.call("json_store.get_json", {
                    p_path: "$.jodus_document"
                });
    
                expect(document).to.eql([1, 2, 3, []])
    
                database.rollback;
    
            });
    
            test("Push array into an array (overloaded)", function() {
    
                database.call("json_store.set_json", {
                    p_path: "$.jodus_document",
                    p_content: [1, 2, 3]
                });
    
                database.call2("json_store.push_array", {
                    p_path: "$.jodus_document"
                });
    
                var document = database.call("json_store.get_json", {
                    p_path: "$.jodus_document"
                });
    
                expect(document).to.eql([1, 2, 3, []])
    
                database.rollback;
    
            });
    
            test("Push JSON into an array", function() {
    
                database.call("json_store.set_json", {
                    p_path: "$.jodus_document",
                    p_content: [1, 2, 3]
                });
    
                database.call("json_store.push_json", {
                    p_path: "$.jodus_document",
                    p_content: {
                        name: "Sergejs",
                        surname: "Vinniks"
                    }
                });
    
                var document = database.call("json_store.get_json", {
                    p_path: "$.jodus_document"
                });
    
                expect(document).to.eql([1, 2, 3, {
                    name: "Sergejs", 
                    surname: "Vinniks"
                }]);
    
                database.rollback;
    
            });
    
            test("Push JSON into an array (overloaded)", function() {
    
                database.call("json_store.set_json", {
                    p_path: "$.jodus_document",
                    p_content: [1, 2, 3]
                });
    
                database.call("json_store.push_json", {
                    p_path: "$.jodus_document",
                    p_content: {
                        name: "Sergejs",
                        surname: "Vinniks"
                    }
                });
    
                var document = database.call("json_store.get_json", {
                    p_path: "$.jodus_document"
                });
    
                expect(document).to.eql([1, 2, 3, {
                    name: "Sergejs", 
                    surname: "Vinniks"
                }]);
    
                database.rollback;
    
            });
    
            test("Push JSON into an array (CLOB method)", function() {
    
                database.call("json_store.set_json", {
                    p_path: "$.jodus_document",
                    p_content: [1, 2, 3]
                });
    
                database.call("json_store.push_json_clob", {
                    p_path: "$.jodus_document",
                    p_content: {
                        name: "Sergejs",
                        surname: "Vinniks"
                    }
                });
    
                var document = database.call("json_store.get_json", {
                    p_path: "$.jodus_document"
                });
    
                expect(document).to.eql([1, 2, 3, {
                    name: "Sergejs", 
                    surname: "Vinniks"
                }]);
    
                database.rollback;
    
            });
    
            test("Push JSON into an array (CLOB method, overloaded)", function() {
    
                database.call("json_store.set_json", {
                    p_path: "$.jodus_document",
                    p_content: [1, 2, 3]
                });
    
                database.call2("json_store.push_json_clob", {
                    p_path: "$.jodus_document",
                    p_content: {
                        name: "Sergejs",
                        surname: "Vinniks"
                    }
                });
    
                var document = database.call("json_store.get_json", {
                    p_path: "$.jodus_document"
                });
    
                expect(document).to.eql([1, 2, 3, {
                    name: "Sergejs", 
                    surname: "Vinniks"
                }]);
    
                database.rollback;
    
            });

        });

        teardown("Rollback", function() {
            database.rollback();
        });

    });

    function scalarApplyObject() {
        return {
            stringValue: "Hello, World!",
            numberValue: 123456,
            booleanValue: true,
            nullValue: null
        };
    }

    function complexApplyObject() {
        return {
            stringValue: "Hello, World!",
            numberValue: 123456,
            objectValue: {
                stringValue: "Hello, World!",
                numberValue: 123456,
                objectValue: {
                    stringValue: "Hello, World"
                }
            }
        };
    }

    suite("JSON apply tests", function() {

        test("Try applying to a non-existing JSON value", function() {

            var applyObject = scalarApplyObject();

            database.call("json_store.set_json", {
                p_path: "$.apply",
                p_content: applyObject
            });

            try {

                database.call("json_store.apply_json", {
                    p_path: "$.apply.otherValue",
                    p_content: "Hello, World!"
                });

                throw "Operation successfull!";

            } catch(error) {
                expect(error).to.match(/JDOC-00009/);
            }

        });

        test("Try applying a non-string to a string value", function() {

            var applyObject = scalarApplyObject();

            database.call("json_store.set_json", {
                p_path: "$.apply",
                p_content: applyObject
            });

            try {

                database.call("json_store.apply_json", {
                    p_path: "$.apply.stringValue",
                    p_content: 123,
                    p_check_types: true
                });

                throw "Operation successfull!";

            } catch(error) {
                expect(error).to.match(/JDOC-00011/);
            }

        });

        test("Apply single string value", function() {
            
            var applyObject = scalarApplyObject();

            database.call("json_store.set_json", {
                p_path: "$.apply",
                p_content: applyObject
            });

            database.call("json_store.apply_json", {
                p_path: "$.apply.stringValue",
                p_content: "Good bye, World!"
            });

            applyObject.stringValue = "Good bye, World!";

            var json = database.call("json_store.get_json", {
                p_path: "$.apply"
            });

            expect(json).to.eql(applyObject);

        });

        test("Try applying a non-number to a number value", function() {

            var applyObject = scalarApplyObject();

            database.call("json_store.set_json", {
                p_path: "$.apply",
                p_content: applyObject
            });

            try {

                database.call("json_store.apply_json", {
                    p_path: "$.apply.numberValue",
                    p_content: "Hello, World!",
                    p_check_types: true
                });

                throw "Operation successfull!";

            } catch(error) {
                expect(error).to.match(/JDOC-00011/);
            }

        });

        test("Apply single number value", function() {
            
            var applyObject = scalarApplyObject();

            database.call("json_store.set_json", {
                p_path: "$.apply",
                p_content: applyObject
            });

            database.call("json_store.apply_json", {
                p_path: "$.apply.numberValue",
                p_content: 654321
            });

            applyObject.numberValue = 654321;

            var json = database.call("json_store.get_json", {
                p_path: "$.apply"
            });

            expect(json).to.eql(applyObject);

        });

        test("Try applying a non-boolean to a boolean value", function() {

            var applyObject = scalarApplyObject();

            database.call("json_store.set_json", {
                p_path: "$.apply",
                p_content: applyObject
            });

            try {

                database.call("json_store.apply_json", {
                    p_path: "$.apply.booleanValue",
                    p_content: "Hello, World!",
                    p_check_types: true
                });

                throw "Operation successfull!";

            } catch(error) {
                expect(error).to.match(/JDOC-00011/);
            }

        });

        test("Apply single boolean value", function() {
            
            var applyObject = scalarApplyObject();

            database.call("json_store.set_json", {
                p_path: "$.apply",
                p_content: applyObject
            });

            database.call("json_store.apply_json", {
                p_path: "$.apply.booleanValue",
                p_content: false
            });

            applyObject.booleanValue = false;

            var json = database.call("json_store.get_json", {
                p_path: "$.apply"
            });

            expect(json).to.eql(applyObject);

        });

        test("Apply null to a null", function() {
            
            var applyObject = scalarApplyObject();

            database.call("json_store.set_json", {
                p_path: "$.apply",
                p_content: applyObject
            });

            database.call("json_store.apply_json", {
                p_path: "$.apply.nullValue",
                p_content: null
            });

            var json = database.call("json_store.get_json", {
                p_path: "$.apply"
            });

            expect(json).to.eql(applyObject);

        });

        test("Apply scalar value (string) to a null", function() {
            
            var applyObject = scalarApplyObject();

            database.call("json_store.set_json", {
                p_path: "$.apply",
                p_content: applyObject
            });

            database.call("json_store.apply_json", {
                p_path: "$.apply.nullValue",
                p_content: "Hello, World!"
            });

            applyObject.nullValue = "Hello, World!";

            var json = database.call("json_store.get_json", {
                p_path: "$.apply"
            });

            expect(json).to.eql(applyObject);

        });

        test("Apply null to a non-null (scalar) value", function() {
            
            var applyObject = scalarApplyObject();

            database.call("json_store.set_json", {
                p_path: "$.apply",
                p_content: applyObject
            });

            database.call("json_store.apply_json", {
                p_path: "$.apply.stringValue",
                p_content: null
            });

            applyObject.stringValue = null;

            var json = database.call("json_store.get_json", {
                p_path: "$.apply"
            });

            expect(json).to.eql(applyObject);

        });

        test("Apply number to a string value", function() {
            
            var applyObject = scalarApplyObject();

            database.call("json_store.set_json", {
                p_path: "$.apply",
                p_content: applyObject
            });

            database.call("json_store.apply_json", {
                p_path: "$.apply.stringValue",
                p_content: 123456
            });

            applyObject.stringValue = 123456;

            var json = database.call("json_store.get_json", {
                p_path: "$.apply"
            });

            expect(json).to.eql(applyObject);

        });

        test("Apply object to a string value", function() {
            
            var applyObject = scalarApplyObject();

            database.call("json_store.set_json", {
                p_path: "$.apply",
                p_content: applyObject
            });

            database.call("json_store.apply_json", {
                p_path: "$.apply.stringValue",
                p_content: {
                    hello: "world"
                }
            });

            applyObject.stringValue = {
                hello: "world"
            };

            var json = database.call("json_store.get_json", {
                p_path: "$.apply"
            });

            expect(json).to.eql(applyObject);

        });

        test("Apply object existing property", function() {
            
            var applyObject = complexApplyObject();

            database.call("json_store.set_json", {
                p_path: "$.apply",
                p_content: applyObject
            });

            database.call("json_store.apply_json", {
                p_path: "$.apply.objectValue",
                p_content: {
                    stringValue: "Good bye, World!"
                }
            });

            applyObject.objectValue.stringValue = "Good bye, World!";

            var json = database.call("json_store.get_json", {
                p_path: "$.apply"
            });

            expect(json).to.eql(applyObject);

        });

        test("Apply object non-existing property", function() {
            
            var applyObject = complexApplyObject();

            database.call("json_store.set_json", {
                p_path: "$.apply",
                p_content: applyObject
            });

            database.call("json_store.apply_json", {
                p_path: "$.apply.objectValue",
                p_content: {
                    newValue: "Good bye, World!"
                }
            });

            applyObject.objectValue.newValue = "Good bye, World!";

            var json = database.call("json_store.get_json", {
                p_path: "$.apply"
            });

            expect(json).to.eql(applyObject);

        });

        test("Apply properties on two object levels", function() {
            
            var applyObject = complexApplyObject();

            database.call("json_store.set_json", {
                p_path: "$.apply",
                p_content: applyObject
            });

            database.call("json_store.apply_json", {
                p_path: "$.apply.objectValue",
                p_content: {
                    newValue: "Good bye, World!",
                    objectValue: {
                        stringValue: "Good bye, World!"
                    }
                }
            });

            applyObject.objectValue.newValue = "Good bye, World!";
            applyObject.objectValue.objectValue.stringValue = "Good bye, World!";

            var json = database.call("json_store.get_json", {
                p_path: "$.apply"
            });

            expect(json).to.eql(applyObject);

        });

        test("Apply part of array of scalar elements", function() {
            
            var applyObject = {
                numbers: [1, 2, 3, 4, 5]
            }

            database.call("json_store.set_json", {
                p_path: "$.jodus_document",
                p_content: {
                    numbers: [1, 2, 3, 4, 5]
                }
            });

            database.call("json_store.apply_json", {
                p_path: "$.jodus_document.numbers",
                p_content: [11, 22, 33]
            });

            applyObject.numbers[0] = 11;
            applyObject.numbers[1] = 22;
            applyObject.numbers[2] = 33;

            var json = database.call("json_store.get_json", {
                p_path: "$.jodus_document"
            });

            expect(json).to.eql(applyObject);

        });

        test("Apply one element of an array", function() {
            
            var applyObject = {
                numbers: [1, 2, 3, 4, 5]
            }

            database.call("json_store.set_json", {
                p_path: "$.jodus_document",
                p_content: {
                    numbers: [1, 2, 3, 4, 5]
                }
            });

            database.call("json_store.apply_json", {
                p_path: "$.jodus_document.numbers[2]",
                p_content: "Hello, World!"
            });

            applyObject.numbers[2] = "Hello, World!";

            var json = database.call("json_store.get_json", {
                p_path: "$.jodus_document"
            });

            expect(json).to.eql(applyObject);

        });

        test("Apply property of an element of an array", function() {
            
            var applyObject = {
                items: [{
                    name: "Sergejs",
                    surname: "Vinniks"
                }]
            }

            database.call("json_store.set_json", {
                p_path: "$.jodus_document",
                p_content: applyObject
            });

            database.call("json_store.apply_json", {
                p_path: "$.jodus_document",
                p_content: {
                    items: [{
                        name: "Janis"
                    }]
                }
            });

            applyObject.items[0].name = "Janis";

            var json = database.call("json_store.get_json", {
                p_path: "$.jodus_document"
            });

            expect(json).to.eql(applyObject);

        });

        test("Apply non-object to the root", function() {
            
            expect(function() {

                database.call("json_store.apply_json", {
                    p_path: "$",
                    p_content: "Hello, World!"
                });

            }).to.throw(/./);

        });

        test("Apply object to the root", function() {
            
            var applyObject = {
                jodus_document: {
                    name: "Sergejs",
                    surname: "Vinniks"
                }
            }

            database.call("json_store.set_json", {
                p_path: "$.jodus_document",
                p_content: null
            });

            database.call("json_store.apply_json", {
                p_path: "$",
                p_content: applyObject
            });

            var json = database.call("json_store.get_json", {
                p_path: "$.jodus_document"
            });

            expect(json).to.eql(applyObject.jodus_document);

        });

    });

    suite("JSON value deletion tests", function() {
    
        test("Delete anonymous null value", function() {

            var id = database.call("json_store.create_null");

            database.call('json_store.delete_value', {
                p_path: `#${id}`
            });

            var rows = database.selectObjects(`
                    *
                FROM json_values
                WHERE id = ${id}
            `);

            expect(rows).to.eql([]);

        });

        test("Delete anonymous string value", function() {

            var id = database.call("json_store.create_string", {
                p_value: "Hello, World!"
            });

            database.call('json_store.delete_value', {
                p_path: `#${id}`
            });

            var rows = database.selectObjects(`
                    *
                FROM json_values
                WHERE id = ${id}
            `);

            expect(rows).to.eql([]);

        });

        test("Delete anonymous number value", function() {

            var id = database.call("json_store.create_number", {
                p_value: 123
            });

            database.call('json_store.delete_value', {
                p_path: `#${id}`
            });

            var rows = database.selectObjects(`
                    *
                FROM json_values
                WHERE id = ${id}
            `);

            expect(rows).to.eql([]);

        });

        test("Delete anonymous boolean value", function() {

            var id = database.call("json_store.create_boolean", {
                p_value: true
            });

            database.call('json_store.delete_value', {
                p_path: `#${id}`
            });

            var rows = database.selectObjects(`
                    *
                FROM json_values
                WHERE id = ${id}
            `);

            expect(rows).to.eql([]);

        });

        test("Delete anonymous object", function() {

            var id = database.call("json_store.create_json", {
                p_content: {
                    name: "Sergejs",
                    surname: "Vinniks"
                }
            });

            database.call('json_store.delete_value', {
                p_path: `#${id}`
            });

            var rows = database.selectObjects(`
                    *
                FROM json_values
                WHERE id = ${id}
            `);

            expect(rows).to.eql([]);

        });

        test("Delete anonymous array", function() {

            var id = database.call("json_store.create_json", {
                p_content: [1, 2, 3, 4, 5]
            });

            database.call('json_store.delete_value', {
                p_path: `#${id}`
            });

            var rows = database.selectObjects(`
                    *
                FROM json_values
                WHERE id = ${id}
            `);

            expect(rows).to.eql([]);

        });

        test("Delete object property", function() {

            var id = database.call("json_store.set_json", {
                p_path: "$.jodus_document",
                p_content: {
                    name: "Sergejs",
                    surname: "Vinniks"
                }
            });

            database.call('json_store.delete_value', {
                p_path: "$.jodus_document.name"
            });

            var object = database.call("json_store.get_json", {
                p_path: "$.jodus_document"
            })

            expect(object).to.eql({
                surname: "Vinniks"
            });

        });

        test("Delete array element", function() {

            var id = database.call("json_store.set_json", {
                p_path: "$.jodus_document",
                p_content: [1, 2, 3, 4, 5]
            });

            database.call('json_store.delete_value', {
                p_path: "$.jodus_document[2]"
            });

            var object = database.call("json_store.get_json", {
                p_path: "$.jodus_document"
            })

            expect(object).to.eql([1, 2, null, 4, 5]);

        });

        test("Try deleting non-existing property", function() {

            expect(function() {

                database.call('json_store.delete_value', {
                    p_path: "$.jodus_non_existing_property"
                });

            }).to.throw(/JDOC-00009/);

        });

        test("Try deleting property of a non-existing object", function() {

            expect(function() {

                database.call('json_store.delete_value', {
                    p_path: "$.jodus.non_existing_object.jodus_non_existing_property"
                });

            }).to.throw(/JDOC-00009/);

        });

        test("Try deleting the root", function() {

            expect(function() {

                database.call('json_store.delete_value', {
                    p_path: "$"
                });

            }).to.throw(/JDOC-00006/);

        });
    
    });

    suite("JSON node locking tests", function() {
    
        test("Try to unlock the root", function() {
        
            expect(function() {
            
                database.call("json_store.unlock_value", {
                    p_path: "$"
                });
            
            }).to.throw(/JDOC-00026/);
        
        });

        test("Lock anonymous scalar value", function() {
    
            let id = database.call("json_store.create_string", {
                p_value: "Hello, World!"
            });

            database.call("json_store.lock_value", {
                p_path: `#${id}`
            });

            let value = database.selectObject(`*
                FROM json_values
                WHERE id = ${id}`);

            expect(value).to.eql({
                id: id,
                parent_id: null,
                type: "S",
                name: null,
                value: "Hello, World!",
                locked: "T"
            });
    
        });

        test("Try to modify locked anonymous scalar value", function() {
    
            let id = database.call("json_store.create_string", {
                p_value: "Hello, World!"
            });

            database.call("json_store.lock_value", {
                p_path: `#${id}`
            });

            expect(function() {
            
                database.call("json_store.set_string", {
                    p_path: `#${id}`,
                    p_value: "Good bye, World!"
                });
            
            }).to.throw(/JDOC-00024/);

        });

        test("Lock scalar property of the root", function() {
    
            let name = randomString(32);

            let id = database.call("json_store.set_string", {
                p_path: `$["${name}"]`,
                p_value: "Hello, World!"
            });

            database.call("json_store.lock_value", {
                p_path: `$["${name}"]`
            });

            let value = database.selectObject(`*
                FROM json_values
                WHERE parent_id = 0
                      AND name = '${name}'`);

            expect(value).to.eql({
                id: id,
                parent_id: 0,
                type: "S",
                name: name,
                value: "Hello, World!",
                locked: "T"
            });
    
        });

        test("Try to modify locked anonymous value", function() {
    
            let name = randomString(32);

            let id = database.call("json_store.set_string", {
                p_path: `$["${name}"]`,
                p_value: "Hello, World!"
            });

            database.call("json_store.lock_value", {
                p_path: `$["${name}"]`
            });

            expect(function() {
            
                database.call("json_store.set_string", {
                    p_path: `$["${name}"]`,
                    p_value: "Good bye, World!"
                });
            
            }).to.throw(/JDOC-00024/);

        });

        test("Lock child property", function() {
        
            let name = randomString(32);

            let id = database.call("json_store.set_json", {
                p_path: `$["${name}"]`,
                p_content: {
                    name: "Sergejs",
                    addresses: {
                        home: {
                            city: "Riga"
                        }
                    }
                }
            });

            database.call("json_store.lock_value", {
                p_path: `$["${name}"].addresses.home.city`
            });

            let values = database.selectRows(`
                     name,
                     locked
                FROM json_values
                START WITH id = ${id}
                CONNECT BY PRIOR id = parent_id
                ORDER SIBLINGS BY name`);

            expect(values).to.eql([
                [name, "T"],
                ["addresses", "T"],
                ["home", "T"],
                ["city", "T"],
                ["name", null]
            ]);
        
        });
          
        test("Delete locked property", function() {
        
            let name = randomString(32);

            let id = database.call("json_store.set_json", {
                p_path: `$["${name}"]`,
                p_content: {
                    name: "Sergejs",
                    addresses: {
                        home: {
                            city: "Riga"
                        }
                    }
                }
            });

            database.call("json_store.lock_value", {
                p_path: `$["${name}"].addresses.home.city`
            });

            expect(function() {
            
                database.call("json_store.delete_value", {
                    p_path: `$["${name}"].addresses.home`
                });
            
            }).to.throw(/JDOC-00024/);
        
        });

        test("Unlock anonymous scalar value", function() {
    
            let id = database.call("json_store.create_string", {
                p_value: "Hello, World!"
            });

            database.call("json_store.lock_value", {
                p_path: `#${id}`
            });

            let value = database.selectObject(`*
                FROM json_values
                WHERE id = ${id}`);

            expect(value).to.eql({
                id: id,
                parent_id: null,
                type: "S",
                name: null,
                value: "Hello, World!",
                locked: "T"
            });

            database.call("json_store.unlock_value", {
                p_path: `#${id}`
            });

            value = database.selectObject(`*
                FROM json_values
                WHERE id = ${id}`);

            expect(value).to.eql({
                id: id,
                parent_id: null,
                type: "S",
                name: null,
                value: "Hello, World!",
                locked: null
            });
    
        });

        test("Try to unlock a value with locked children", function() {
        
            let name = randomString(32);

            let id = database.call("json_store.set_json", {
                p_path: `$["${name}"]`,
                p_content: {
                    name: "Sergejs",
                    addresses: {
                        home: {
                            city: "Riga"
                        }
                    }
                }
            });

            database.call("json_store.lock_value", {
                p_path: `$["${name}"].addresses.home.city`
            });

            let values = database.selectRows(`
                     name,
                     locked
                FROM json_values
                START WITH id = ${id}
                CONNECT BY PRIOR id = parent_id
                ORDER SIBLINGS BY name`);

            expect(values).to.eql([
                [name, "T"],
                ["addresses", "T"],
                ["home", "T"],
                ["city", "T"],
                ["name", null]
            ]);

            expect(function() {
            
                database.call("json_store.unlock_value", {
                    p_path:  `$["${name}"].addresses.home`
                });
            
            }).to.throw(/JDOC-00025/);
        
        });

        test("Unlock a value with all children unlocked", function() {
        
            let name = randomString(32);

            let id = database.call("json_store.set_json", {
                p_path: `$["${name}"]`,
                p_content: {
                    name: "Sergejs",
                    addresses: {
                        home: {
                            city: "Riga"
                        }
                    }
                }
            });

            database.call("json_store.lock_value", {
                p_path: `$["${name}"].addresses.home.city`
            });

            let values = database.selectRows(`
                     name,
                     locked
                FROM json_values
                START WITH id = ${id}
                CONNECT BY PRIOR id = parent_id
                ORDER SIBLINGS BY name`);

            expect(values).to.eql([
                [name, "T"],
                ["addresses", "T"],
                ["home", "T"],
                ["city", "T"],
                ["name", null]
            ]);

            database.call("json_store.unlock_value", {
                p_path:  `$["${name}"].addresses.home.city`
            });

            database.call("json_store.unlock_value", {
                p_path:  `$["${name}"].addresses.home`
            });

            values = database.selectRows(`
                     name,
                     locked
                FROM json_values
                START WITH id = ${id}
                CONNECT BY PRIOR id = parent_id
                ORDER SIBLINGS BY name`);

            expect(values).to.eql([
                [name, "T"],
                ["addresses", "T"],
                ["home", null],
                ["city", null],
                ["name", null]
            ]);
        
        });
    
    });

});

suite("Huge JSON document handling", function() {

    var document;
    var documentJSON;
    var documentId;

    setup("Create a huge array", function() {
        
        document = [];

        for (var i = 0; i < 200000; i++)
            document[i] = i;

        documentJSON = JSON.stringify(document);

    });

    test("Save anonymous huge document via the VARCHAR method", function() {

        expect(function() {
        
            database.call("json_store.create_json", {
                p_content: document
            });
        
        }).to.throw(/./);

    });

    test("Parse huge document via the CLOB method", function() {

        documentId = database.call2("json_parser.parse", {
            p_content: documentJSON
        });
        
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

teardown("Rollback", function() {

    database.rollback();

});



