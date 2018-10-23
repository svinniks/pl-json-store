function createValue(value) {

    let events = database.call("json_parser.parse", {
        p_content: JSON.stringify(value)
    });

    return database.call(`${implementationPackage}.create_json`, {
        p_content_parse_events: events
    });

}

suite("GET with numeric key tests", function() {

    test("Get an existing element", function() {
    
        let valueId = createValue(["Hello, World!", "Good bye, World!"]);

        let element = database.selectValue(`
                ${implementationType}(${valueId}).get(1).as_string()
            FROM dual
        `);

        expect(element).to.be("Good bye, World!");
    
    });

    test("Get a non-existing element", function() {
    
        let valueId = createValue(["Hello, World!", "Good bye, World!"]);

        let element = database.selectValue(`
                ${implementationType}(${valueId}).get(2).as_string()
            FROM dual
        `);

        expect(element).to.be(null);
    
    });
    
});

suite("GET_STRING tests", function() {

    test("Try to get an existing non-string property", function() {
    
        let valueId = createValue([
            {
                string: "Hello, World!",
                number: 123.456,
                date: "2018-12-27",
                boolean: true
            }
        ]);

        expect(function() {
        
            let value = database.selectValue(`
                    ${implementationType}(${valueId}).get_string('[0].boolean')
                FROM dual
            `);            
        
        }).to.throw(/JDC-00010/);

    });

    test("Get existing property, no bind", function() {
    
        let valueId = createValue([
            {
                string: "Hello, World!",
                number: 123.456,
                date: "2018-12-27",
                boolean: true
            }
        ]);

        let value = database.selectValue(`
                ${implementationType}(${valueId}).get_string('[0].string')
            FROM dual
        `);
    
        expect(value).to.be("Hello, World!");

    });

    test("Get existing property, bind", function() {
    
        let valueId = createValue([
            {
                string: "Hello, World!",
                number: 123.456,
                date: "2018-12-27",
                boolean: true
            }
        ]);

        let value = database.selectValue(`
                ${implementationType}(${valueId}).get_string('[:i].string', bind(0))
            FROM dual
        `);
    
        expect(value).to.be("Hello, World!");

    });

    test("Get non-existing property, bind", function() {
    
        let valueId = createValue([
            {
                string: "Hello, World!",
                number: 123.456,
                date: "2018-12-27",
                boolean: true
            }
        ]);

        let value = database.selectValue(`
                ${implementationType}(${valueId}).get_string('[:i].string', bind(1))
            FROM dual
        `);
    
        expect(value).to.be(null);

    });

    test("Try to get an existing non-string property using P_INDEX overload", function() {
    
        let valueId = createValue([
            true
        ]);

        expect(function() {
        
            let value = database.selectValue(`
                    ${implementationType}(${valueId}).get_string(0)
                FROM dual
            `);            
        
        }).to.throw(/JDC-00010/);

    });

    test("Get existing property using P_INDEX overload", function() {
    
        let valueId = createValue([
            "Hello, World!"
        ]);

        let value = database.selectValue(`
                ${implementationType}(${valueId}).get_string(0)
            FROM dual
        `);
    
        expect(value).to.be("Hello, World!");

    });

    test("Get non-existing property using P_INDEX overload", function() {
    
        let valueId = createValue([
            "Hello, World!"
        ]);

        let value = database.selectValue(`
                ${implementationType}(${valueId}).get_string(10)
            FROM dual
        `);
    
        expect(value).to.be(null);

    });
    
});

suite("GET_NUMBER tests", function() {

    test("Try to get an existing non-number property", function() {
    
        let valueId = createValue([
            {
                string: "Hello, World!",
                number: 123.456,
                date: "2018-12-27",
                boolean: true
            }
        ]);

        expect(function() {
        
            let value = database.selectValue(`
                    ${implementationType}(${valueId}).get_number('[0].boolean')
                FROM dual
            `);            
        
        }).to.throw(/JDC-00010/);

    });

    test("Get existing property, no bind", function() {
    
        let valueId = createValue([
            {
                string: "Hello, World!",
                number: 123.456,
                date: "2018-12-27",
                boolean: true
            }
        ]);

        let value = database.selectValue(`
                ${implementationType}(${valueId}).get_number('[0].number')
            FROM dual
        `);
    
        expect(value).to.be(123.456);

    });

    test("Get existing property, bind", function() {
    
        let valueId = createValue([
            {
                string: "Hello, World!",
                number: 123.456,
                date: "2018-12-27",
                boolean: true
            }
        ]);

        let value = database.selectValue(`
                ${implementationType}(${valueId}).get_number('[:i].number', bind(0))
            FROM dual
        `);
    
        expect(value).to.be(123.456);

    });

    test("Get non-existing property, bind", function() {
    
        let valueId = createValue([
            {
                string: "Hello, World!",
                number: 123.456,
                date: "2018-12-27",
                boolean: true
            }
        ]);

        let value = database.selectValue(`
                ${implementationType}(${valueId}).get_number('[:i].number', bind(1))
            FROM dual
        `);
    
        expect(value).to.be(null);

    });

    test("Try to get an existing non-number property using P_INDEX overload", function() {
    
        let valueId = createValue([
            true
        ]);

        expect(function() {
        
            let value = database.selectValue(`
                    ${implementationType}(${valueId}).get_number(0)
                FROM dual
            `);            
        
        }).to.throw(/JDC-00010/);

    });

    test("Get existing property using P_INDEX overload", function() {
    
        let valueId = createValue([
            123.456
        ]);

        let value = database.selectValue(`
                ${implementationType}(${valueId}).get_number(0)
            FROM dual
        `);
    
        expect(value).to.be(123.456);

    });

    test("Get non-existing property using P_INDEX overload", function() {
    
        let valueId = createValue([
            123.456
        ]);

        let value = database.selectValue(`
                ${implementationType}(${valueId}).get_number(10)
            FROM dual
        `);
    
        expect(value).to.be(null);

    });
    
});

suite("GET_DATE tests", function() {

    test("Try to get an existing non-date property", function() {
    
        let valueId = createValue([
            {
                string: "Hello, World!",
                number: 123.456,
                date: "2018-12-27",
                boolean: true
            }
        ]);

        expect(function() {
        
            let value = database.selectValue(`
                    ${implementationType}(${valueId}).get_date('[0].boolean')
                FROM dual
            `);            
        
        }).to.throw(/JDC-00010/);

    });

    test("Get existing property, no bind", function() {
    
        let valueId = createValue([
            {
                string: "Hello, World!",
                number: 123.456,
                date: "2018-12-27",
                boolean: true
            }
        ]);

        let value = database.selectValue(`
                ${implementationType}(${valueId}).get_date('[0].date')
            FROM dual
        `);
    
        expect(value).to.be("2018-12-27");

    });

    test("Get existing property, bind", function() {
    
        let valueId = createValue([
            {
                string: "Hello, World!",
                number: 123.456,
                date: "2018-12-27",
                boolean: true
            }
        ]);

        let value = database.selectValue(`
                ${implementationType}(${valueId}).get_date('[:i].date', bind(0))
            FROM dual
        `);
    
        expect(value).to.be("2018-12-27");

    });

    test("Get non-existing property, bind", function() {
    
        let valueId = createValue([
            {
                string: "Hello, World!",
                number: 123.456,
                date: "2018-12-27",
                boolean: true
            }
        ]);

        let value = database.selectValue(`
                ${implementationType}(${valueId}).get_date('[:i].date', bind(1))
            FROM dual
        `);
    
        expect(value).to.be(null);

    });

    test("Try to get an existing non-number property using P_INDEX overload", function() {
    
        let valueId = createValue([
            true
        ]);

        expect(function() {
        
            let value = database.selectValue(`
                    ${implementationType}(${valueId}).get_date(0)
                FROM dual
            `);            
        
        }).to.throw(/JDC-00010/);

    });

    test("Get existing property using P_INDEX overload", function() {
    
        let valueId = createValue([
            "2018-12-27"
        ]);

        let value = database.selectValue(`
                ${implementationType}(${valueId}).get_date(0)
            FROM dual
        `);
    
        expect(value).to.be("2018-12-27");

    });

    test("Get non-existing property using P_INDEX overload", function() {
    
        let valueId = createValue([
            "2018-12-27"
        ]);

        let value = database.selectValue(`
                ${implementationType}(${valueId}).get_date(10)
            FROM dual
        `);
    
        expect(value).to.be(null);

    });
    
});

suite("GET_BOOLEAN tests", function() {

    let pathFunctionName = 'F' + randomString(16);
    let indexFunctionName = 'F' + randomString(16);

    setup("Create a wrapper functions to call BOOLEAN methods", function() {

        database.run(`
            BEGIN
                EXECUTE IMMEDIATE '
                    CREATE OR REPLACE FUNCTION ${pathFunctionName} (
                        p_value_id IN NUMBER,
                        p_path IN VARCHAR2,
                        p_bind IN BIND 
                    )
                    RETURN BOOLEAN IS
                    BEGIN
                        RETURN ${implementationType}(p_value_id).get_boolean(p_path, p_bind);
                    END;
                ';
            END;
        `);

        database.run(`
            BEGIN
                EXECUTE IMMEDIATE '
                    CREATE OR REPLACE FUNCTION ${indexFunctionName} (
                        p_value_id IN NUMBER,
                        p_index IN NUMBER
                    )
                    RETURN BOOLEAN IS
                    BEGIN
                        RETURN ${implementationType}(p_value_id).get_boolean(p_index);
                    END;
                ';
            END;
        `);

    });

    test("Try to get an existing non-boolean property", function() {
    
        let valueId = createValue([
            {
                string: "Hello, World!",
                number: 123.456,
                date: "2018-12-27",
                boolean: true
            }
        ]);

        expect(function() {
        
            database.call(pathFunctionName, {
                p_value_id: valueId,
                p_path: "[0].string",
                p_bind: null
            });
        
        }).to.throw(/JDC-00010/);

    });

    test("Get existing property, no bind", function() {
    
        let valueId = createValue([
            {
                string: "Hello, World!",
                number: 123.456,
                date: "2018-12-27",
                boolean: true
            }
        ]);

        let value = database.call(pathFunctionName, {
            p_value_id: valueId,
            p_path: "[0].boolean",
            p_bind: null
        });
    
        expect(value).to.be(true);

    });

    test("Get existing property, bind", function() {
    
        let valueId = createValue([
            {
                string: "Hello, World!",
                number: 123.456,
                date: "2018-12-27",
                boolean: true
            }
        ]);

        let value = database.call(pathFunctionName, {
            p_value_id: valueId,
            p_path: "[:i].boolean",
            p_bind: ["0"]
        });
    
        expect(value).to.be(true);

    });

    test("Get non-existing property, bind", function() {
    
        let valueId = createValue([
            {
                string: "Hello, World!",
                number: 123.456,
                date: "2018-12-27",
                boolean: true
            }
        ]);

        let value = database.call(pathFunctionName, {
            p_value_id: valueId,
            p_path: "[:i].boolean",
            p_bind: ["1"]
        });
    
        expect(value).to.be(null);

    });

    test("Try to get an existing non-number property using P_INDEX overload", function() {
    
        let valueId = createValue([
            123.456
        ]);

        expect(function() {
        
            let value = database.call(indexFunctionName, {
                p_value_id: valueId,
                p_index: 0
            });           
        
        }).to.throw(/JDC-00010/);

    });

    test("Get existing property using P_INDEX overload", function() {
    
        let valueId = createValue([
            true
        ]);

        let value = database.call(indexFunctionName, {
            p_value_id: valueId,
            p_index: 0
        });
    
        expect(value).to.be(true);

    });

    test("Get non-existing property using P_INDEX overload", function() {
    
        let valueId = createValue([
            true
        ]);

        let value = database.call(indexFunctionName, {
            p_value_id: valueId,
            p_index: 10
        });
    
        expect(value).to.be(null);

    });

    teardown("Drop the wrapper functions", function() {
    
        database.run(`
            BEGIN
                EXECUTE IMMEDIATE 'DROP FUNCTION ${pathFunctionName}';
                EXECUTE IMMEDIATE 'DROP FUNCTION ${indexFunctionName}';    
            END;
        `);
    
    });
    
});

suite("GET_JSON tests", function() {

    let pathFunctionName = 'F' + randomString(16);
    let indexFunctionName = 'F' + randomString(16);

    setup("Create wrapper functions to call methods with BOOLEAN arguments", function() {
    
        database.run(`
            BEGIN
                EXECUTE IMMEDIATE '
                    CREATE OR REPLACE FUNCTION ${pathFunctionName} (
                        p_value_id IN NUMBER,
                        p_path IN VARCHAR2,
                        p_serialize_nulls IN BOOLEAN,
                        p_bind IN bind
                    )
                    RETURN VARCHAR2 IS
                    BEGIN
                        RETURN ${implementationType}(p_value_id).get_json(p_path, p_serialize_nulls, p_bind);
                    END;
                ';                
            END;
        `);

        database.run(`
            BEGIN
                EXECUTE IMMEDIATE '
                    CREATE OR REPLACE FUNCTION ${indexFunctionName} (
                        p_value_id IN NUMBER,
                        p_index IN NUMBER,
                        p_serialize_nulls IN BOOLEAN
                    )
                    RETURN VARCHAR2 IS
                    BEGIN
                        RETURN ${implementationType}(p_value_id).get_json(p_index, p_serialize_nulls);
                    END;
                ';                
            END;
        `);
    
    });
    
    test("Get existing property, no bind", function() {
    
        let valueId = createValue([
            {
                string: "Hello, World!",
                number: 123.456,
                date: "2018-12-27",
                boolean: true,
                json: {
                    name: "Sergejs",
                    surname: "Vinniks"
                }
            }
        ]);

        let value = database.selectValue(`
                ${implementationType}(${valueId}).get_json('[0].json')
            FROM dual
        `);
    
        expect(JSON.parse(value)).to.eql({
            name: "Sergejs",
            surname: "Vinniks"
        });

    });

    test("Get existing property, no bind, don't serialize nulls", function() {
    
        let valueId = createValue([
            {
                string: "Hello, World!",
                number: 123.456,
                date: "2018-12-27",
                boolean: true,
                json: {
                    name: "Sergejs",
                    surname: "Vinniks",
                    birthDate: null
                }
            }
        ]);

        let value = database.call(pathFunctionName, {
            p_value_id: valueId,
            p_path: "[0].json",
            p_serialize_nulls: false,
            p_bind: null
        });
    
        expect(JSON.parse(value)).to.eql({
            name: "Sergejs",
            surname: "Vinniks"
        });

    });

    test("Get existing property, bind", function() {
    
        let valueId = createValue([
            {
                string: "Hello, World!",
                number: 123.456,
                date: "2018-12-27",
                boolean: true,
                json: {
                    name: "Sergejs",
                    surname: "Vinniks"
                }
            }
        ]);

        let value = database.selectValue(`
                ${implementationType}(${valueId}).get_json('[:i].json', bind(0))
            FROM dual
        `);
    
        expect(JSON.parse(value)).to.eql({
            name: "Sergejs",
            surname: "Vinniks"
        });

    });

    test("Get non-existing property, bind", function() {
    
        let valueId = createValue([
            {
                string: "Hello, World!",
                number: 123.456,
                date: "2018-12-27",
                boolean: true,
                json: {
                    name: "Sergejs",
                    surname: "Vinniks"
                }
            }
        ]);

        let value = database.selectValue(`
                ${implementationType}(${valueId}).get_json('[:i].json', bind(1))
            FROM dual
        `);
    
        expect(value).to.be(null);

    });

    test("Get existing property using P_INDEX overload", function() {
    
        let valueId = createValue([
            {
                name: "Sergejs",
                surname: "Vinniks"
            }
        ]);

        let value = database.selectValue(`
                ${implementationType}(${valueId}).get_json(0)
            FROM dual
        `);
    
        expect(JSON.parse(value)).to.eql({
            name: "Sergejs",
            surname: "Vinniks"
        });

    });

    test("Get existing property using P_INDEX overload, don't serialize nulls", function() {
    
        let valueId = createValue([
            {
                name: "Sergejs",
                surname: "Vinniks",
                birthDate: null
            }
        ]);

        let value = database.call(indexFunctionName, {
            p_value_id: valueId,
            p_index: 0,
            p_serialize_nulls: false
        });
    
        expect(JSON.parse(value)).to.eql({
            name: "Sergejs",
            surname: "Vinniks"
        });

    });

    test("Get non-existing property using P_INDEX overload", function() {
    
        let valueId = createValue([
            {
                name: "Sergejs",
                surname: "Vinniks"
            }
        ]);

        let value = database.selectValue(`
                ${implementationType}(${valueId}).get_json(10)
            FROM dual
        `);
    
        expect(value).to.be(null);

    });

    teardown("Drop the wrapper functions", function() {
    
        database.run(`
            BEGIN
                EXECUTE IMMEDIATE 'DROP FUNCTION ${pathFunctionName}';    
                EXECUTE IMMEDIATE 'DROP FUNCTION ${indexFunctionName}';    
            END;
        `);        
    
    });
    
    
});

suite("GET_JSON_CLOB tests", function() {

    let pathFunctionName = 'F' + randomString(16);
    let indexFunctionName = 'F' + randomString(16);

    setup("Create wrapper functions to call methods with BOOLEAN arguments", function() {
    
        database.run(`
            BEGIN
                EXECUTE IMMEDIATE '
                    CREATE OR REPLACE FUNCTION ${pathFunctionName} (
                        p_value_id IN NUMBER,
                        p_path IN VARCHAR2,
                        p_serialize_nulls IN BOOLEAN,
                        p_bind IN bind
                    )
                    RETURN VARCHAR2 IS
                    BEGIN
                        RETURN ${implementationType}(p_value_id).get_json_clob(p_path, p_serialize_nulls, p_bind);
                    END;
                ';                
            END;
        `);

        database.run(`
            BEGIN
                EXECUTE IMMEDIATE '
                    CREATE OR REPLACE FUNCTION ${indexFunctionName} (
                        p_value_id IN NUMBER,
                        p_index IN NUMBER,
                        p_serialize_nulls IN BOOLEAN
                    )
                    RETURN VARCHAR2 IS
                    BEGIN
                        RETURN ${implementationType}(p_value_id).get_json_clob(p_index, p_serialize_nulls);
                    END;
                ';                
            END;
        `);
    
    });
    
    test("Get existing property, no bind", function() {
    
        let valueId = createValue([
            {
                string: "Hello, World!",
                number: 123.456,
                date: "2018-12-27",
                boolean: true,
                json: {
                    name: "Sergejs",
                    surname: "Vinniks"
                }
            }
        ]);

        let value = database.selectValue(`
                ${implementationType}(${valueId}).get_json_clob('[0].json')
            FROM dual
        `);
    
        expect(JSON.parse(value)).to.eql({
            name: "Sergejs",
            surname: "Vinniks"
        });

    });

    test("Get existing property, no bind, don't serialize nulls", function() {
    
        let valueId = createValue([
            {
                string: "Hello, World!",
                number: 123.456,
                date: "2018-12-27",
                boolean: true,
                json: {
                    name: "Sergejs",
                    surname: "Vinniks",
                    birthDate: null
                }
            }
        ]);

        let value = database.call(pathFunctionName, {
            p_value_id: valueId,
            p_path: "[0].json",
            p_serialize_nulls: false,
            p_bind: null
        });
    
        expect(JSON.parse(value)).to.eql({
            name: "Sergejs",
            surname: "Vinniks"
        });

    });

    test("Get existing property, bind", function() {
    
        let valueId = createValue([
            {
                string: "Hello, World!",
                number: 123.456,
                date: "2018-12-27",
                boolean: true,
                json: {
                    name: "Sergejs",
                    surname: "Vinniks"
                }
            }
        ]);

        let value = database.selectValue(`
                ${implementationType}(${valueId}).get_json_clob('[:i].json', bind(0))
            FROM dual
        `);
    
        expect(JSON.parse(value)).to.eql({
            name: "Sergejs",
            surname: "Vinniks"
        });

    });

    test("Get non-existing property, bind", function() {
    
        let valueId = createValue([
            {
                string: "Hello, World!",
                number: 123.456,
                date: "2018-12-27",
                boolean: true,
                json: {
                    name: "Sergejs",
                    surname: "Vinniks"
                }
            }
        ]);

        let value = database.selectValue(`
                ${implementationType}(${valueId}).get_json_clob('[:i].json', bind(1))
            FROM dual
        `);
    
        expect(value).to.be(null);

    });

    test("Get existing property using P_INDEX overload", function() {
    
        let valueId = createValue([
            {
                name: "Sergejs",
                surname: "Vinniks"
            }
        ]);

        let value = database.selectValue(`
                ${implementationType}(${valueId}).get_json(0)
            FROM dual
        `);
    
        expect(JSON.parse(value)).to.eql({
            name: "Sergejs",
            surname: "Vinniks"
        });

    });

    test("Get existing property using P_INDEX overload, don't serialize nulls", function() {
    
        let valueId = createValue([
            {
                name: "Sergejs",
                surname: "Vinniks",
                birthDate: null
            }
        ]);

        let value = database.call(indexFunctionName, {
            p_value_id: valueId,
            p_index: 0,
            p_serialize_nulls: false
        });
    
        expect(JSON.parse(value)).to.eql({
            name: "Sergejs",
            surname: "Vinniks"
        });

    });

    test("Get non-existing property using P_INDEX overload", function() {
    
        let valueId = createValue([
            {
                name: "Sergejs",
                surname: "Vinniks"
            }
        ]);

        let value = database.selectValue(`
                ${implementationType}(${valueId}).get_json_clob(10)
            FROM dual
        `);
    
        expect(value).to.be(null);

    });

    teardown("Drop the wrapper functions", function() {
    
        database.run(`
            BEGIN
                EXECUTE IMMEDIATE 'DROP FUNCTION ${pathFunctionName}';    
                EXECUTE IMMEDIATE 'DROP FUNCTION ${indexFunctionName}';    
            END;
        `);        
    
    });
    
    
});