function createValue(value) {

    let events = database.call("json_parser.parse", {
        p_content: JSON.stringify(value)
    });

    return database.call(`${implementationPackage}.create_json`, {
        p_content_parse_events: events
    });

}

suite("SET_STRING tests", function() {

    let pathFunctionName = 'F' + randomString(16);
    let indexFunctionName = 'F' + randomString(16);

    setup("Create wrapper functions for function methods", function() {
    
        database.run(`
            BEGIN
                EXECUTE IMMEDIATE '
                    CREATE OR REPLACE FUNCTION ${pathFunctionName} (
                        p_value_id IN NUMBER,
                        p_path IN VARCHAR2,
                        p_value IN VARCHAR2,
                        p_bind IN bind
                    )
                    RETURN NUMBER IS
                    BEGIN
                        RETURN ${implementationType}(p_value_id).set_string(p_path, p_value, p_bind).id;
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
                        p_value IN VARCHAR2
                    )
                    RETURN NUMBER IS
                    BEGIN
                        RETURN ${implementationType}(p_value_id).set_string(p_index, p_value).id;
                    END;
                ';    
            END;
        `);
    
    });
    

    test("Try to set property to invalid path, function version", function() {
    
        let valueId = createValue({
            name: "Sergejs"
        });

        expect(function() {
        
            database.call(pathFunctionName, {
                p_value_id: valueId,
                p_path: "address.city",
                p_value: "Riga",
                p_bind: null
            });
        
        }).to.throw(/JDC-00007/);
    
    });

    test("Try to set property to invalid path, procedure version", function() {
    
        let valueId = createValue({
            name: "Sergejs"
        });

        expect(function() {
        
            database.run(`
                BEGIN
                    ${implementationType}(${valueId}).set_string('address.city', 'Riga');   
                END;
            `);
        
        }).to.throw(/JDC-00007/);
    
    });

    test("Set property, function version, no bind", function() {
    
        let valueId = createValue({
            name: "Sergejs"
        });

        let propertyId = database.call(pathFunctionName, {
            p_value_id: valueId,
            p_path: "surname",
            p_value: "Vinniks",
            p_bind: null
        });
    
        let parentId = database.selectValue(`
                ${implementationType}(${propertyId}).get_parent().id
            FROM dual
        `);

        expect(parentId).to.be(valueId);

        let value = JSON.parse(
            database.selectValue(`
                    ${implementationType}(${valueId}).as_json()
                FROM dual
            `)
        );

        expect(value).to.eql({
            name: "Sergejs",
            surname: "Vinniks"
        })

    });
    
    test("Set property, function version, bind", function() {
    
        let valueId = createValue({
            name: "Sergejs"
        });

        let propertyId = database.call(pathFunctionName, {
            p_value_id: valueId,
            p_path: ":name",
            p_value: "Vinniks",
            p_bind: ["surname"]
        });
    
        let parentId = database.selectValue(`
                ${implementationType}(${propertyId}).get_parent().id
            FROM dual
        `);

        expect(parentId).to.be(valueId);

        let value = JSON.parse(
            database.selectValue(`
                    ${implementationType}(${valueId}).as_json()
                FROM dual
            `)
        );

        expect(value).to.eql({
            name: "Sergejs",
            surname: "Vinniks"
        })

    });

    test("Set property, procedure version, no bind", function() {
    
        let valueId = createValue({
            name: "Sergejs"
        });

        database.run(`
            BEGIN
                ${implementationType}(${valueId}).set_string('surname', 'Vinniks');            
            END;
        `);
    
        let value = JSON.parse(
            database.selectValue(`
                    ${implementationType}(${valueId}).as_json()
                FROM dual
            `)
        );

        expect(value).to.eql({
            name: "Sergejs",
            surname: "Vinniks"
        })

    });

    test("Set property, procedure version, bind", function() {
    
        let valueId = createValue({
            name: "Sergejs"
        });

        database.run(`
            BEGIN
                ${implementationType}(${valueId}).set_string(':name', 'Vinniks', bind('surname'));            
            END;
        `);
    
        let value = JSON.parse(
            database.selectValue(`
                    ${implementationType}(${valueId}).as_json()
                FROM dual
            `)
        );

        expect(value).to.eql({
            name: "Sergejs",
            surname: "Vinniks"
        })

    });

    test("Set property, index function version", function() {
    
        let valueId = createValue([
            "hello"
        ]);

        let propertyId = database.call(indexFunctionName, {
            p_value_id: valueId,
            p_index: 1,
            p_value: "world"
        });
    
        let parentId = database.selectValue(`
                ${implementationType}(${propertyId}).get_parent().id
            FROM dual
        `);

        expect(parentId).to.be(valueId);

        let value = JSON.parse(
            database.selectValue(`
                    ${implementationType}(${valueId}).as_json()
                FROM dual
            `)
        );

        expect(value).to.eql([
            "hello",
            "world"
        ])

    });

    test("Set property, index procedure version", function() {
    
        let valueId = createValue([
            "hello"
        ]);

        database.run(`
            BEGIN
                ${implementationType}(${valueId}).set_string(1, 'world');
            END;
        `);
    
        let value = JSON.parse(
            database.selectValue(`
                    ${implementationType}(${valueId}).as_json()
                FROM dual
            `)
        );

        expect(value).to.eql([
            "hello",
            "world"
        ])

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

suite("SET_NUMBER tests", function() {

    let pathFunctionName = 'F' + randomString(16);
    let indexFunctionName = 'F' + randomString(16);

    setup("Create wrapper functions for function methods", function() {
    
        database.run(`
            BEGIN
                EXECUTE IMMEDIATE '
                    CREATE OR REPLACE FUNCTION ${pathFunctionName} (
                        p_value_id IN NUMBER,
                        p_path IN VARCHAR2,
                        p_value IN NUMBER,
                        p_bind IN bind
                    )
                    RETURN NUMBER IS
                    BEGIN
                        RETURN ${implementationType}(p_value_id).set_number(p_path, p_value, p_bind).id;
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
                        p_value IN NUMBER
                    )
                    RETURN NUMBER IS
                    BEGIN
                        RETURN ${implementationType}(p_value_id).set_number(p_index, p_value).id;
                    END;
                ';    
            END;
        `);
    
    });
    
    test("Try to set property to invalid path, function version", function() {
    
        let valueId = createValue({
            name: "Sergejs"
        });

        expect(function() {
        
            database.call(pathFunctionName, {
                p_value_id: valueId,
                p_path: "address.house",
                p_value: 41,
                p_bind: null
            });
        
        }).to.throw(/JDC-00007/);
    
    });

    test("Try to set property to invalid path, procedure version", function() {
    
        let valueId = createValue({
            name: "Sergejs"
        });

        expect(function() {
        
            database.run(`
                BEGIN
                    ${implementationType}(${valueId}).set_number('address.house', 41);   
                END;
            `);
        
        }).to.throw(/JDC-00007/);
    
    });

    test("Set property, function version, no bind", function() {
    
        let valueId = createValue({
            name: "Sergejs"
        });

        let propertyId = database.call(pathFunctionName, {
            p_value_id: valueId,
            p_path: "children",
            p_value: 1,
            p_bind: null
        });
    
        let parentId = database.selectValue(`
                ${implementationType}(${propertyId}).get_parent().id
            FROM dual
        `);

        expect(parentId).to.be(valueId);

        let value = JSON.parse(
            database.selectValue(`
                    ${implementationType}(${valueId}).as_json()
                FROM dual
            `)
        );

        expect(value).to.eql({
            name: "Sergejs",
            children: 1
        })

    });
    
    test("Set property, function version, bind", function() {
    
        let valueId = createValue({
            name: "Sergejs"
        });

        let propertyId = database.call(pathFunctionName, {
            p_value_id: valueId,
            p_path: ":name",
            p_value: 1,
            p_bind: ["children"]
        });
    
        let parentId = database.selectValue(`
                ${implementationType}(${propertyId}).get_parent().id
            FROM dual
        `);

        expect(parentId).to.be(valueId);

        let value = JSON.parse(
            database.selectValue(`
                    ${implementationType}(${valueId}).as_json()
                FROM dual
            `)
        );

        expect(value).to.eql({
            name: "Sergejs",
            children: 1
        })

    });

    test("Set property, procedure version, no bind", function() {
    
        let valueId = createValue({
            name: "Sergejs"
        });

        database.run(`
            BEGIN
                ${implementationType}(${valueId}).set_number('children', 1);            
            END;
        `);
    
        let value = JSON.parse(
            database.selectValue(`
                    ${implementationType}(${valueId}).as_json()
                FROM dual
            `)
        );

        expect(value).to.eql({
            name: "Sergejs",
            children: 1
        })

    });

    test("Set property, procedure version, bind", function() {
    
        let valueId = createValue({
            name: "Sergejs"
        });

        database.run(`
            BEGIN
                ${implementationType}(${valueId}).set_number(':name', 1, bind('children'));            
            END;
        `);
    
        let value = JSON.parse(
            database.selectValue(`
                    ${implementationType}(${valueId}).as_json()
                FROM dual
            `)
        );

        expect(value).to.eql({
            name: "Sergejs",
            children: 1
        })

    });

    test("Set property, index function version", function() {
    
        let valueId = createValue([
            123.456
        ]);

        let propertyId = database.call(indexFunctionName, {
            p_value_id: valueId,
            p_index: 1,
            p_value: 654.321
        });
    
        let parentId = database.selectValue(`
                ${implementationType}(${propertyId}).get_parent().id
            FROM dual
        `);

        expect(parentId).to.be(valueId);

        let value = JSON.parse(
            database.selectValue(`
                    ${implementationType}(${valueId}).as_json()
                FROM dual
            `)
        );

        expect(value).to.eql([
            123.456,
            654.321
        ])

    });

    test("Set property, index procedure version", function() {
    
        let valueId = createValue([
            123.456
        ]);

        database.run(`
            BEGIN
                ${implementationType}(${valueId}).set_number(1, 654.321);
            END;
        `);
    
        let value = JSON.parse(
            database.selectValue(`
                    ${implementationType}(${valueId}).as_json()
                FROM dual
            `)
        );

        expect(value).to.eql([
            123.456,
            654.321
        ])

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

suite("SET_DATE tests", function() {

    let pathFunctionName = 'F' + randomString(16);
    let indexFunctionName = 'F' + randomString(16);

    setup("Create wrapper functions for function methods", function() {
    
        database.run(`
            BEGIN
                EXECUTE IMMEDIATE '
                    CREATE OR REPLACE FUNCTION ${pathFunctionName} (
                        p_value_id IN NUMBER,
                        p_path IN VARCHAR2,
                        p_value IN DATE,
                        p_bind IN bind
                    )
                    RETURN NUMBER IS
                    BEGIN
                        RETURN ${implementationType}(p_value_id).set_date(p_path, p_value, p_bind).id;
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
                        p_value IN DATE
                    )
                    RETURN NUMBER IS
                    BEGIN
                        RETURN ${implementationType}(p_value_id).set_date(p_index, p_value).id;
                    END;
                ';    
            END;
        `);
    
    });
    
    test("Try to set property to invalid path, function version", function() {
    
        let valueId = createValue({
            name: "Sergejs"
        });

        expect(function() {
        
            database.call(pathFunctionName, {
                p_value_id: valueId,
                p_path: "address.since",
                p_value: "2017-07-12",
                p_bind: null
            });
        
        }).to.throw(/JDC-00007/);
    
    });

    test("Try to set property to invalid path, procedure version", function() {
    
        let valueId = createValue({
            name: "Sergejs"
        });

        expect(function() {
        
            database.run(`
                BEGIN
                    ${implementationType}(${valueId}).set_date('address.since', DATE '2017-07-12');   
                END;
            `);
        
        }).to.throw(/JDC-00007/);
    
    });

    test("Set property, function version, no bind", function() {
    
        let valueId = createValue({
            name: "Sergejs"
        });

        let propertyId = database.call(pathFunctionName, {
            p_value_id: valueId,
            p_path: "birthDate",
            p_value: "1982-08-06",
            p_bind: null
        });
    
        let parentId = database.selectValue(`
                ${implementationType}(${propertyId}).get_parent().id
            FROM dual
        `);

        expect(parentId).to.be(valueId);

        let value = JSON.parse(
            database.selectValue(`
                    ${implementationType}(${valueId}).as_json()
                FROM dual
            `)
        );

        expect(value).to.eql({
            name: "Sergejs",
            birthDate: "1982-08-06"
        })

    });
    
    test("Set property, function version, bind", function() {
    
        let valueId = createValue({
            name: "Sergejs"
        });

        let propertyId = database.call(pathFunctionName, {
            p_value_id: valueId,
            p_path: ":name",
            p_value: "1982-08-06",
            p_bind: ["birthDate"]
        });
    
        let parentId = database.selectValue(`
                ${implementationType}(${propertyId}).get_parent().id
            FROM dual
        `);

        expect(parentId).to.be(valueId);

        let value = JSON.parse(
            database.selectValue(`
                    ${implementationType}(${valueId}).as_json()
                FROM dual
            `)
        );

        expect(value).to.eql({
            name: "Sergejs",
            birthDate: "1982-08-06"
        })

    });

    test("Set property, procedure version, no bind", function() {
    
        let valueId = createValue({
            name: "Sergejs"
        });

        database.run(`
            BEGIN
                ${implementationType}(${valueId}).set_date('birthDate', DATE '1982-08-06');            
            END;
        `);
    
        let value = JSON.parse(
            database.selectValue(`
                    ${implementationType}(${valueId}).as_json()
                FROM dual
            `)
        );

        expect(value).to.eql({
            name: "Sergejs",
            birthDate: "1982-08-06"
        })

    });

    test("Set property, procedure version, bind", function() {
    
        let valueId = createValue({
            name: "Sergejs"
        });

        database.run(`
            BEGIN
                ${implementationType}(${valueId}).set_date(':name', DATE '1982-08-06', bind('birthDate'));            
            END;
        `);
    
        let value = JSON.parse(
            database.selectValue(`
                    ${implementationType}(${valueId}).as_json()
                FROM dual
            `)
        );

        expect(value).to.eql({
            name: "Sergejs",
            birthDate: "1982-08-06"
        })

    });

    test("Set property, index function version", function() {
    
        let valueId = createValue([
            "1984-08-08"
        ]);

        let propertyId = database.call(indexFunctionName, {
            p_value_id: valueId,
            p_index: 1,
            p_value: "1982-08-06"
        });
    
        let parentId = database.selectValue(`
                ${implementationType}(${propertyId}).get_parent().id
            FROM dual
        `);

        expect(parentId).to.be(valueId);

        let value = JSON.parse(
            database.selectValue(`
                    ${implementationType}(${valueId}).as_json()
                FROM dual
            `)
        );

        expect(value).to.eql([
            "1984-08-08",
            "1982-08-06"
        ])

    });

    test("Set property, index procedure version", function() {
    
        let valueId = createValue([
            "1984-08-08"
        ]);

        database.run(`
            BEGIN
                ${implementationType}(${valueId}).set_date(1, DATE '1982-08-06');
            END;
        `);
    
        let value = JSON.parse(
            database.selectValue(`
                    ${implementationType}(${valueId}).as_json()
                FROM dual
            `)
        );

        expect(value).to.eql([
            "1984-08-08",
            "1982-08-06"
        ])

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

suite("SET_BOOLEAN tests", function() {

    let pathFunctionName = 'F' + randomString(16);
    let indexFunctionName = 'F' + randomString(16);

    setup("Create wrapper functions for function methods", function() {
    
        database.run(`
            BEGIN
                EXECUTE IMMEDIATE '
                    CREATE OR REPLACE FUNCTION ${pathFunctionName} (
                        p_value_id IN NUMBER,
                        p_path IN VARCHAR2,
                        p_value IN BOOLEAN,
                        p_bind IN bind
                    )
                    RETURN NUMBER IS
                    BEGIN
                        RETURN ${implementationType}(p_value_id).set_boolean(p_path, p_value, p_bind).id;
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
                        p_value IN BOOLEAN
                    )
                    RETURN NUMBER IS
                    BEGIN
                        RETURN ${implementationType}(p_value_id).set_boolean(p_index, p_value).id;
                    END;
                ';    
            END;
        `);
    
    });
    
    test("Try to set property to invalid path, function version", function() {
    
        let valueId = createValue({
            name: "Sergejs"
        });

        expect(function() {
        
            database.call(pathFunctionName, {
                p_value_id: valueId,
                p_path: "address.domestic",
                p_value: true,
                p_bind: null
            });
        
        }).to.throw(/JDC-00007/);
    
    });

    test("Try to set property to invalid path, procedure version", function() {
    
        let valueId = createValue({
            name: "Sergejs"
        });

        expect(function() {
        
            database.run(`
                BEGIN
                    ${implementationType}(${valueId}).set_boolean('address.domestic', TRUE);   
                END;
            `);
        
        }).to.throw(/JDC-00007/);
    
    });

    test("Set property, function version, no bind", function() {
    
        let valueId = createValue({
            name: "Sergejs"
        });

        let propertyId = database.call(pathFunctionName, {
            p_value_id: valueId,
            p_path: "married",
            p_value: true,
            p_bind: null
        });
    
        let parentId = database.selectValue(`
                ${implementationType}(${propertyId}).get_parent().id
            FROM dual
        `);

        expect(parentId).to.be(valueId);

        let value = JSON.parse(
            database.selectValue(`
                    ${implementationType}(${valueId}).as_json()
                FROM dual
            `)
        );

        expect(value).to.eql({
            name: "Sergejs",
            married: true
        })

    });
    
    test("Set property, function version, bind", function() {
    
        let valueId = createValue({
            name: "Sergejs"
        });

        let propertyId = database.call(pathFunctionName, {
            p_value_id: valueId,
            p_path: ":name",
            p_value: true,
            p_bind: ["married"]
        });
    
        let parentId = database.selectValue(`
                ${implementationType}(${propertyId}).get_parent().id
            FROM dual
        `);

        expect(parentId).to.be(valueId);

        let value = JSON.parse(
            database.selectValue(`
                    ${implementationType}(${valueId}).as_json()
                FROM dual
            `)
        );

        expect(value).to.eql({
            name: "Sergejs",
            married: true
        })

    });

    test("Set property, procedure version, no bind", function() {
    
        let valueId = createValue({
            name: "Sergejs"
        });

        database.run(`
            BEGIN
                ${implementationType}(${valueId}).set_boolean('married', true);            
            END;
        `);
    
        let value = JSON.parse(
            database.selectValue(`
                    ${implementationType}(${valueId}).as_json()
                FROM dual
            `)
        );

        expect(value).to.eql({
            name: "Sergejs",
            married: true
        })

    });

    test("Set property, procedure version, bind", function() {
    
        let valueId = createValue({
            name: "Sergejs"
        });

        database.run(`
            BEGIN
                ${implementationType}(${valueId}).set_boolean(':name', TRUE, bind('married'));            
            END;
        `);
    
        let value = JSON.parse(
            database.selectValue(`
                    ${implementationType}(${valueId}).as_json()
                FROM dual
            `)
        );

        expect(value).to.eql({
            name: "Sergejs",
            married: true
        })

    });

    test("Set property, index function version", function() {
    
        let valueId = createValue([
            false
        ]);

        let propertyId = database.call(indexFunctionName, {
            p_value_id: valueId,
            p_index: 1,
            p_value: true
        });
    
        let parentId = database.selectValue(`
                ${implementationType}(${propertyId}).get_parent().id
            FROM dual
        `);

        expect(parentId).to.be(valueId);

        let value = JSON.parse(
            database.selectValue(`
                    ${implementationType}(${valueId}).as_json()
                FROM dual
            `)
        );

        expect(value).to.eql([
            false,
            true
        ])

    });

    test("Set property, index procedure version", function() {
    
        let valueId = createValue([
            false
        ]);

        database.run(`
            BEGIN
                ${implementationType}(${valueId}).set_boolean(1, TRUE);
            END;
        `);
    
        let value = JSON.parse(
            database.selectValue(`
                    ${implementationType}(${valueId}).as_json()
                FROM dual
            `)
        );

        expect(value).to.eql([
            false,
            true
        ])

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

suite("SET_NULL tests", function() {

    let pathFunctionName = 'F' + randomString(16);
    let indexFunctionName = 'F' + randomString(16);

    setup("Create wrapper functions for function methods", function() {
    
        database.run(`
            BEGIN
                EXECUTE IMMEDIATE '
                    CREATE OR REPLACE FUNCTION ${pathFunctionName} (
                        p_value_id IN NUMBER,
                        p_path IN VARCHAR2,
                        p_bind IN bind
                    )
                    RETURN NUMBER IS
                    BEGIN
                        RETURN ${implementationType}(p_value_id).set_null(p_path, p_bind).id;
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
                    RETURN NUMBER IS
                    BEGIN
                        RETURN ${implementationType}(p_value_id).set_null(p_index).id;
                    END;
                ';    
            END;
        `);
    
    });
    
    test("Try to set property to invalid path, function version", function() {
    
        let valueId = createValue({
            name: "Sergejs"
        });

        expect(function() {
        
            database.call(pathFunctionName, {
                p_value_id: valueId,
                p_path: "address.street2",
                p_bind: null
            });
        
        }).to.throw(/JDC-00007/);
    
    });

    test("Try to set property to invalid path, procedure version", function() {
    
        let valueId = createValue({
            name: "Sergejs"
        });

        expect(function() {
        
            database.run(`
                BEGIN
                    ${implementationType}(${valueId}).set_null('address.street2');   
                END;
            `);
        
        }).to.throw(/JDC-00007/);
    
    });

    test("Set property, function version, no bind", function() {
    
        let valueId = createValue({
            name: "Sergejs"
        });

        let propertyId = database.call(pathFunctionName, {
            p_value_id: valueId,
            p_path: "title",
            p_bind: null
        });
    
        let parentId = database.selectValue(`
                ${implementationType}(${propertyId}).get_parent().id
            FROM dual
        `);

        expect(parentId).to.be(valueId);

        let value = JSON.parse(
            database.selectValue(`
                    ${implementationType}(${valueId}).as_json()
                FROM dual
            `)
        );

        expect(value).to.eql({
            name: "Sergejs",
            title: null
        })

    });
    
    test("Set property, function version, bind", function() {
    
        let valueId = createValue({
            name: "Sergejs"
        });

        let propertyId = database.call(pathFunctionName, {
            p_value_id: valueId,
            p_path: ":name",
            p_bind: ["title"]
        });
    
        let parentId = database.selectValue(`
                ${implementationType}(${propertyId}).get_parent().id
            FROM dual
        `);

        expect(parentId).to.be(valueId);

        let value = JSON.parse(
            database.selectValue(`
                    ${implementationType}(${valueId}).as_json()
                FROM dual
            `)
        );

        expect(value).to.eql({
            name: "Sergejs",
            title: null
        })

    });

    test("Set property, procedure version, no bind", function() {
    
        let valueId = createValue({
            name: "Sergejs"
        });

        database.run(`
            BEGIN
                ${implementationType}(${valueId}).set_null('title');            
            END;
        `);
    
        let value = JSON.parse(
            database.selectValue(`
                    ${implementationType}(${valueId}).as_json()
                FROM dual
            `)
        );

        expect(value).to.eql({
            name: "Sergejs",
            title: null
        })

    });

    test("Set property, procedure version, bind", function() {
    
        let valueId = createValue({
            name: "Sergejs"
        });

        database.run(`
            BEGIN
                ${implementationType}(${valueId}).set_null(':name', bind('title'));            
            END;
        `);
    
        let value = JSON.parse(
            database.selectValue(`
                    ${implementationType}(${valueId}).as_json()
                FROM dual
            `)
        );

        expect(value).to.eql({
            name: "Sergejs",
            title: null
        })

    });

    test("Set property, index function version", function() {
    
        let valueId = createValue([
            "Hello, World!"
        ]);

        let propertyId = database.call(indexFunctionName, {
            p_value_id: valueId,
            p_index: 1
        });
    
        let parentId = database.selectValue(`
                ${implementationType}(${propertyId}).get_parent().id
            FROM dual
        `);

        expect(parentId).to.be(valueId);

        let value = JSON.parse(
            database.selectValue(`
                    ${implementationType}(${valueId}).as_json()
                FROM dual
            `)
        );

        expect(value).to.eql([
            "Hello, World!",
            null
        ])

    });

    test("Set property, index procedure version", function() {
    
        let valueId = createValue([
            "Hello, World!"
        ]);

        database.run(`
            BEGIN
                ${implementationType}(${valueId}).set_null(1);
            END;
        `);
    
        let value = JSON.parse(
            database.selectValue(`
                    ${implementationType}(${valueId}).as_json()
                FROM dual
            `)
        );

        expect(value).to.eql([
            "Hello, World!",
            null
        ])

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

suite("SET_OBJECT tests", function() {

    let pathFunctionName = 'F' + randomString(16);
    let indexFunctionName = 'F' + randomString(16);

    setup("Create wrapper functions for function methods", function() {
    
        database.run(`
            BEGIN
                EXECUTE IMMEDIATE '
                    CREATE OR REPLACE FUNCTION ${pathFunctionName} (
                        p_value_id IN NUMBER,
                        p_path IN VARCHAR2,
                        p_bind IN bind
                    )
                    RETURN NUMBER IS
                    BEGIN
                        RETURN ${implementationType}(p_value_id).set_object(p_path, p_bind).id;
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
                    RETURN NUMBER IS
                    BEGIN
                        RETURN ${implementationType}(p_value_id).set_object(p_index).id;
                    END;
                ';    
            END;
        `);
    
    });
    
    test("Try to set property to invalid path, function version", function() {
    
        let valueId = createValue({
            name: "Sergejs"
        });

        expect(function() {
        
            database.call(pathFunctionName, {
                p_value_id: valueId,
                p_path: "address.coordinates",
                p_bind: null
            });
        
        }).to.throw(/JDC-00007/);
    
    });

    test("Try to set property to invalid path, procedure version", function() {
    
        let valueId = createValue({
            name: "Sergejs"
        });

        expect(function() {
        
            database.run(`
                BEGIN
                    ${implementationType}(${valueId}).set_null('address.coordinates');   
                END;
            `);
        
        }).to.throw(/JDC-00007/);
    
    });

    test("Set property, function version, no bind", function() {
    
        let valueId = createValue({
            name: "Sergejs"
        });

        let propertyId = database.call(pathFunctionName, {
            p_value_id: valueId,
            p_path: "phones",
            p_bind: null
        });
    
        let parentId = database.selectValue(`
                ${implementationType}(${propertyId}).get_parent().id
            FROM dual
        `);

        expect(parentId).to.be(valueId);

        let value = JSON.parse(
            database.selectValue(`
                    ${implementationType}(${valueId}).as_json()
                FROM dual
            `)
        );

        expect(value).to.eql({
            name: "Sergejs",
            phones: {}
        })

    });
    
    test("Set property, function version, bind", function() {
    
        let valueId = createValue({
            name: "Sergejs"
        });

        let propertyId = database.call(pathFunctionName, {
            p_value_id: valueId,
            p_path: ":name",
            p_bind: ["phones"]
        });
    
        let parentId = database.selectValue(`
                ${implementationType}(${propertyId}).get_parent().id
            FROM dual
        `);

        expect(parentId).to.be(valueId);

        let value = JSON.parse(
            database.selectValue(`
                    ${implementationType}(${valueId}).as_json()
                FROM dual
            `)
        );

        expect(value).to.eql({
            name: "Sergejs",
            phones: {}
        })

    });

    test("Set property, procedure version, no bind", function() {
    
        let valueId = createValue({
            name: "Sergejs"
        });

        database.run(`
            BEGIN
                ${implementationType}(${valueId}).set_object('phones');            
            END;
        `);
    
        let value = JSON.parse(
            database.selectValue(`
                    ${implementationType}(${valueId}).as_json()
                FROM dual
            `)
        );

        expect(value).to.eql({
            name: "Sergejs",
            phones: {}
        })

    });

    test("Set property, procedure version, bind", function() {
    
        let valueId = createValue({
            name: "Sergejs"
        });

        database.run(`
            BEGIN
                ${implementationType}(${valueId}).set_object(':name', bind('phones'));            
            END;
        `);
    
        let value = JSON.parse(
            database.selectValue(`
                    ${implementationType}(${valueId}).as_json()
                FROM dual
            `)
        );

        expect(value).to.eql({
            name: "Sergejs",
            phones: {}
        })

    });

    test("Set property, index function version", function() {
    
        let valueId = createValue([
            "Hello, World!"
        ]);

        let propertyId = database.call(indexFunctionName, {
            p_value_id: valueId,
            p_index: 1
        });
    
        let parentId = database.selectValue(`
                ${implementationType}(${propertyId}).get_parent().id
            FROM dual
        `);

        expect(parentId).to.be(valueId);

        let value = JSON.parse(
            database.selectValue(`
                    ${implementationType}(${valueId}).as_json()
                FROM dual
            `)
        );

        expect(value).to.eql([
            "Hello, World!",
            {}
        ])

    });

    test("Set property, index procedure version", function() {
    
        let valueId = createValue([
            "Hello, World!"
        ]);

        database.run(`
            BEGIN
                ${implementationType}(${valueId}).set_object(1);
            END;
        `);
    
        let value = JSON.parse(
            database.selectValue(`
                    ${implementationType}(${valueId}).as_json()
                FROM dual
            `)
        );

        expect(value).to.eql([
            "Hello, World!",
            {}
        ])

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

suite("SET_ARRAY tests", function() {

    let pathFunctionName = 'F' + randomString(16);
    let indexFunctionName = 'F' + randomString(16);

    setup("Create wrapper functions for function methods", function() {
    
        database.run(`
            BEGIN
                EXECUTE IMMEDIATE '
                    CREATE OR REPLACE FUNCTION ${pathFunctionName} (
                        p_value_id IN NUMBER,
                        p_path IN VARCHAR2,
                        p_bind IN bind
                    )
                    RETURN NUMBER IS
                    BEGIN
                        RETURN ${implementationType}(p_value_id).set_array(p_path, p_bind).id;
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
                    RETURN NUMBER IS
                    BEGIN
                        RETURN ${implementationType}(p_value_id).set_array(p_index).id;
                    END;
                ';    
            END;
        `);
    
    });
    
    test("Try to set property to invalid path, function version", function() {
    
        let valueId = createValue({
            name: "Sergejs"
        });

        expect(function() {
        
            database.call(pathFunctionName, {
                p_value_id: valueId,
                p_path: "address.coordinates",
                p_bind: null
            });
        
        }).to.throw(/JDC-00007/);
    
    });

    test("Try to set property to invalid path, procedure version", function() {
    
        let valueId = createValue({
            name: "Sergejs"
        });

        expect(function() {
        
            database.run(`
                BEGIN
                    ${implementationType}(${valueId}).set_null('address.coordinates');   
                END;
            `);
        
        }).to.throw(/JDC-00007/);
    
    });

    test("Set property, function version, no bind", function() {
    
        let valueId = createValue({
            name: "Sergejs"
        });

        let propertyId = database.call(pathFunctionName, {
            p_value_id: valueId,
            p_path: "phones",
            p_bind: null
        });
    
        let parentId = database.selectValue(`
                ${implementationType}(${propertyId}).get_parent().id
            FROM dual
        `);

        expect(parentId).to.be(valueId);

        let value = JSON.parse(
            database.selectValue(`
                    ${implementationType}(${valueId}).as_json()
                FROM dual
            `)
        );

        expect(value).to.eql({
            name: "Sergejs",
            phones: []
        })

    });
    
    test("Set property, function version, bind", function() {
    
        let valueId = createValue({
            name: "Sergejs"
        });

        let propertyId = database.call(pathFunctionName, {
            p_value_id: valueId,
            p_path: ":name",
            p_bind: ["phones"]
        });
    
        let parentId = database.selectValue(`
                ${implementationType}(${propertyId}).get_parent().id
            FROM dual
        `);

        expect(parentId).to.be(valueId);

        let value = JSON.parse(
            database.selectValue(`
                    ${implementationType}(${valueId}).as_json()
                FROM dual
            `)
        );

        expect(value).to.eql({
            name: "Sergejs",
            phones: []
        })

    });

    test("Set property, procedure version, no bind", function() {
    
        let valueId = createValue({
            name: "Sergejs"
        });

        database.run(`
            BEGIN
                ${implementationType}(${valueId}).set_array('phones');            
            END;
        `);
    
        let value = JSON.parse(
            database.selectValue(`
                    ${implementationType}(${valueId}).as_json()
                FROM dual
            `)
        );

        expect(value).to.eql({
            name: "Sergejs",
            phones: []
        })

    });

    test("Set property, procedure version, bind", function() {
    
        let valueId = createValue({
            name: "Sergejs"
        });

        database.run(`
            BEGIN
                ${implementationType}(${valueId}).set_array(':name', bind('phones'));            
            END;
        `);
    
        let value = JSON.parse(
            database.selectValue(`
                    ${implementationType}(${valueId}).as_json()
                FROM dual
            `)
        );

        expect(value).to.eql({
            name: "Sergejs",
            phones: []
        })

    });

    test("Set property, index function version", function() {
    
        let valueId = createValue([
            "Hello, World!"
        ]);

        let propertyId = database.call(indexFunctionName, {
            p_value_id: valueId,
            p_index: 1
        });
    
        let parentId = database.selectValue(`
                ${implementationType}(${propertyId}).get_parent().id
            FROM dual
        `);

        expect(parentId).to.be(valueId);

        let value = JSON.parse(
            database.selectValue(`
                    ${implementationType}(${valueId}).as_json()
                FROM dual
            `)
        );

        expect(value).to.eql([
            "Hello, World!",
            []
        ])

    });

    test("Set property, index procedure version", function() {
    
        let valueId = createValue([
            "Hello, World!"
        ]);

        database.run(`
            BEGIN
                ${implementationType}(${valueId}).set_array(1);
            END;
        `);
    
        let value = JSON.parse(
            database.selectValue(`
                    ${implementationType}(${valueId}).as_json()
                FROM dual
            `)
        );

        expect(value).to.eql([
            "Hello, World!",
            []
        ])

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

suite("SET_JSON VARCHAR2 version tests", function() {

    let pathFunctionName = 'F' + randomString(16);
    let indexFunctionName = 'F' + randomString(16);

    setup("Create wrapper functions for function methods", function() {
    
        database.run(`
            BEGIN
                EXECUTE IMMEDIATE '
                    CREATE OR REPLACE FUNCTION ${pathFunctionName} (
                        p_value_id IN NUMBER,
                        p_path IN VARCHAR2,
                        p_content IN VARCHAR2,
                        p_bind IN bind
                    )
                    RETURN NUMBER IS
                    BEGIN
                        RETURN ${implementationType}(p_value_id).set_json(p_path, p_content, p_bind).id;
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
                        p_content IN VARCHAR2
                    )
                    RETURN NUMBER IS
                    BEGIN
                        RETURN ${implementationType}(p_value_id).set_json(p_index, p_content).id;
                    END;
                ';    
            END;
        `);
    
    });
    

    test("Try to set property to invalid path, function version", function() {
    
        let valueId = createValue({
            name: "Sergejs"
        });

        expect(function() {
        
            database.call(pathFunctionName, {
                p_value_id: valueId,
                p_path: "address.city",
                p_content: JSON.stringify("Riga"),
                p_bind: null
            });
        
        }).to.throw(/JDC-00007/);
    
    });

    test("Try to set property to invalid path, procedure version", function() {
    
        let valueId = createValue({
            name: "Sergejs"
        });

        expect(function() {
        
            database.run(`
                BEGIN
                    ${implementationType}(${valueId}).set_json('address.city', '"Riga"');   
                END;
            `);
        
        }).to.throw(/JDC-00007/);
    
    });

    test("Set property, function version, no bind", function() {
    
        let valueId = createValue({
            name: "Sergejs"
        });

        let propertyId = database.call(pathFunctionName, {
            p_value_id: valueId,
            p_path: "address",
            p_content: JSON.stringify({
                city: "Riga"
            }),
            p_bind: null
        });
    
        let parentId = database.selectValue(`
                ${implementationType}(${propertyId}).get_parent().id
            FROM dual
        `);

        expect(parentId).to.be(valueId);

        let value = JSON.parse(
            database.selectValue(`
                    ${implementationType}(${valueId}).as_json()
                FROM dual
            `)
        );

        expect(value).to.eql({
            name: "Sergejs",
            address: {
                city: "Riga"
            }
        })

    });
    
    test("Set property, function version, bind", function() {
    
        let valueId = createValue({
            name: "Sergejs"
        });

        let propertyId = database.call(pathFunctionName, {
            p_value_id: valueId,
            p_path: ":name",
            p_content: JSON.stringify({
                city: "Riga"
            }),
            p_bind: ["address"]
        });
    
        let parentId = database.selectValue(`
                ${implementationType}(${propertyId}).get_parent().id
            FROM dual
        `);

        expect(parentId).to.be(valueId);

        let value = JSON.parse(
            database.selectValue(`
                    ${implementationType}(${valueId}).as_json()
                FROM dual
            `)
        );

        expect(value).to.eql({
            name: "Sergejs",
            address: {
                city: "Riga"
            }
        })

    });

    test("Set property, procedure version, no bind", function() {
    
        let valueId = createValue({
            name: "Sergejs"
        });

        database.run(`
            BEGIN
                ${implementationType}(${valueId}).set_json('address', '{"city":"Riga"}');            
            END;
        `);
    
        let value = JSON.parse(
            database.selectValue(`
                    ${implementationType}(${valueId}).as_json()
                FROM dual
            `)
        );

        expect(value).to.eql({
            name: "Sergejs",
            address: {
                city: "Riga"
            }
        })

    });

    test("Set property, procedure version, bind", function() {
    
        let valueId = createValue({
            name: "Sergejs"
        });

        database.run(`
            BEGIN
                ${implementationType}(${valueId}).set_json(':name', '{"city":"Riga"}', bind('address'));            
            END;
        `);
    
        let value = JSON.parse(
            database.selectValue(`
                    ${implementationType}(${valueId}).as_json()
                FROM dual
            `)
        );

        expect(value).to.eql({
            name: "Sergejs",
            address: {
                city: "Riga"
            }
        })

    });

    test("Set property, index function version", function() {
    
        let valueId = createValue([
            "hello"
        ]);

        let propertyId = database.call(indexFunctionName, {
            p_value_id: valueId,
            p_index: 1,
            p_content: JSON.stringify({
                city: "Riga"
            })
        });
    
        let parentId = database.selectValue(`
                ${implementationType}(${propertyId}).get_parent().id
            FROM dual
        `);

        expect(parentId).to.be(valueId);

        let value = JSON.parse(
            database.selectValue(`
                    ${implementationType}(${valueId}).as_json()
                FROM dual
            `)
        );

        expect(value).to.eql([
            "hello",
            {
                city: "Riga"
            }
        ])

    });

    test("Set property, index procedure version", function() {
    
        let valueId = createValue([
            "hello"
        ]);

        database.run(`
            BEGIN
                ${implementationType}(${valueId}).set_json(1, '{"city":"Riga"}');
            END;
        `);
    
        let value = JSON.parse(
            database.selectValue(`
                    ${implementationType}(${valueId}).as_json()
                FROM dual
            `)
        );

        expect(value).to.eql([
            "hello",
            {
                city: "Riga"
            }
        ])

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

suite("SET_JSON CLOB version tests", function() {

    let pathFunctionName = 'F' + randomString(16);
    let indexFunctionName = 'F' + randomString(16);

    setup("Create wrapper functions for function methods", function() {
    
        database.run(`
            BEGIN
                EXECUTE IMMEDIATE '
                    CREATE OR REPLACE FUNCTION ${pathFunctionName} (
                        p_value_id IN NUMBER,
                        p_path IN VARCHAR2,
                        p_content IN CLOB,
                        p_bind IN bind
                    )
                    RETURN NUMBER IS
                    BEGIN
                        RETURN ${implementationType}(p_value_id).set_json(p_path, p_content, p_bind).id;
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
                        p_content IN CLOB
                    )
                    RETURN NUMBER IS
                    BEGIN
                        RETURN ${implementationType}(p_value_id).set_json(p_index, p_content).id;
                    END;
                ';    
            END;
        `);
    
    });
    

    test("Try to set property to invalid path, function version", function() {
    
        let valueId = createValue({
            name: "Sergejs"
        });

        expect(function() {
        
            database.call(pathFunctionName, {
                p_value_id: valueId,
                p_path: "address.city",
                p_content: JSON.stringify("Riga"),
                p_bind: null
            });
        
        }).to.throw(/JDC-00007/);
    
    });

    test("Try to set property to invalid path, procedure version", function() {
    
        let valueId = createValue({
            name: "Sergejs"
        });

        expect(function() {
        
            database.run(`
                BEGIN
                    ${implementationType}(${valueId}).set_json('address.city', TO_CLOB('"Riga"'));   
                END;
            `);
        
        }).to.throw(/JDC-00007/);
    
    });

    test("Set property, function version, no bind", function() {
    
        let valueId = createValue({
            name: "Sergejs"
        });

        let propertyId = database.call(pathFunctionName, {
            p_value_id: valueId,
            p_path: "address",
            p_content: JSON.stringify({
                city: "Riga"
            }),
            p_bind: null
        });
    
        let parentId = database.selectValue(`
                ${implementationType}(${propertyId}).get_parent().id
            FROM dual
        `);

        expect(parentId).to.be(valueId);

        let value = JSON.parse(
            database.selectValue(`
                    ${implementationType}(${valueId}).as_json()
                FROM dual
            `)
        );

        expect(value).to.eql({
            name: "Sergejs",
            address: {
                city: "Riga"
            }
        })

    });
    
    test("Set property, function version, bind", function() {
    
        let valueId = createValue({
            name: "Sergejs"
        });

        let propertyId = database.call(pathFunctionName, {
            p_value_id: valueId,
            p_path: ":name",
            p_content: JSON.stringify({
                city: "Riga"
            }),
            p_bind: ["address"]
        });
    
        let parentId = database.selectValue(`
                ${implementationType}(${propertyId}).get_parent().id
            FROM dual
        `);

        expect(parentId).to.be(valueId);

        let value = JSON.parse(
            database.selectValue(`
                    ${implementationType}(${valueId}).as_json()
                FROM dual
            `)
        );

        expect(value).to.eql({
            name: "Sergejs",
            address: {
                city: "Riga"
            }
        })

    });

    test("Set property, procedure version, no bind", function() {
    
        let valueId = createValue({
            name: "Sergejs"
        });

        database.run(`
            BEGIN
                ${implementationType}(${valueId}).set_json('address', TO_CLOB('{"city":"Riga"}'));            
            END;
        `);
    
        let value = JSON.parse(
            database.selectValue(`
                    ${implementationType}(${valueId}).as_json()
                FROM dual
            `)
        );

        expect(value).to.eql({
            name: "Sergejs",
            address: {
                city: "Riga"
            }
        })

    });

    test("Set property, procedure version, bind", function() {
    
        let valueId = createValue({
            name: "Sergejs"
        });

        database.run(`
            BEGIN
                ${implementationType}(${valueId}).set_json(':name', TO_CLOB('{"city":"Riga"}'), bind('address'));            
            END;
        `);
    
        let value = JSON.parse(
            database.selectValue(`
                    ${implementationType}(${valueId}).as_json()
                FROM dual
            `)
        );

        expect(value).to.eql({
            name: "Sergejs",
            address: {
                city: "Riga"
            }
        })

    });

    test("Set property, index function version", function() {
    
        let valueId = createValue([
            "hello"
        ]);

        let propertyId = database.call(indexFunctionName, {
            p_value_id: valueId,
            p_index: 1,
            p_content: JSON.stringify({
                city: "Riga"
            })
        });
    
        let parentId = database.selectValue(`
                ${implementationType}(${propertyId}).get_parent().id
            FROM dual
        `);

        expect(parentId).to.be(valueId);

        let value = JSON.parse(
            database.selectValue(`
                    ${implementationType}(${valueId}).as_json()
                FROM dual
            `)
        );

        expect(value).to.eql([
            "hello",
            {
                city: "Riga"
            }
        ])

    });

    test("Set property, index procedure version", function() {
    
        let valueId = createValue([
            "hello"
        ]);

        database.run(`
            BEGIN
                ${implementationType}(${valueId}).set_json(1, TO_CLOB('{"city":"Riga"}'));
            END;
        `);
    
        let value = JSON.parse(
            database.selectValue(`
                    ${implementationType}(${valueId}).as_json()
                FROM dual
            `)
        );

        expect(value).to.eql([
            "hello",
            {
                city: "Riga"
            }
        ])

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

suite("SET_JSON builder version tests", function() {

    let pathFunctionName = 'F' + randomString(16);
    let indexFunctionName = 'F' + randomString(16);

    setup("Create wrapper functions for functio methods", function() {
    
        database.run(`
            BEGIN
                EXECUTE IMMEDIATE '
                    CREATE OR REPLACE FUNCTION ${pathFunctionName} (
                        p_value_id IN NUMBER,
                        p_path IN VARCHAR2,
                        p_builder_id IN NUMBER,
                        p_bind IN bind
                    )
                    RETURN NUMBER IS
                    BEGIN
                        RETURN ${implementationType}(p_value_id).set_json(
                            p_path,
                            t_json_builder(p_builder_id),
                            p_bind
                        ).id;
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
                        p_builder_id IN NUMBER
                    )
                    RETURN NUMBER IS
                    BEGIN
                        RETURN ${implementationType}(p_value_id).set_json(
                            p_index,
                            t_json_builder(p_builder_id)
                        ).id;
                    END;
                ';    
            END;
        `);
    
    });
    
    test("Try to pass NULL builder to the function version", function() {
    
        let valueId = createValue({
            name: "Sergejs"
        });

        expect(function() {
        
            database.selectValue(`
                    ${implementationType}(${valueId}).set_json('address', CAST(NULL AS t_json_builder)).id
                FROM dual
            `);
        
        }).to.throw(/JDC-00048/);
    
    });
    
    test("Try to pass NULL builder to the procedure version", function() {
    
        let valueId = createValue({
            name: "Sergejs"
        });

        expect(function() {
        
            database.run(`
                BEGIN
                    ${implementationType}(${valueId}).set_json('address', CAST(NULL AS t_json_builder));
                END;
            `);
            
        }).to.throw(/JDC-00048/);
    
    });

    test("Try to pass NULL builder to the index function version", function() {
    
        let valueId = createValue([
            "Hello, World!"
        ]);

        expect(function() {
        
            database.selectValue(`
                    ${implementationType}(${valueId}).set_json(1, CAST(NULL AS t_json_builder)).id
                FROM dual
            `);
        
        }).to.throw(/JDC-00048/);
    
    });
    
    test("Try to pass NULL builder to the index procedure version", function() {
    
        let valueId = createValue([
            "Hello, World!"
        ]);

        expect(function() {
        
            database.run(`
                BEGIN
                    ${implementationType}(${valueId}).set_json(1, CAST(NULL AS t_json_builder));
                END;
            `);
            
        }).to.throw(/JDC-00048/);
    
    });

    test("Set property with path function version, no bind", function() {
    
        let valueId = createValue({
            name: "Sergejs"
        });

        let builderId = database.selectValue(`
                t_json_builder().object()
                    .name('city').value('Riga')
                .close().id
            FROM dual
        `);

        let propertyId = database.call(pathFunctionName, {
            p_value_id: valueId,
            p_path: "address",
            p_builder_id: builderId,
            p_bind: null
        });
    
        let parentId = database.selectValue(`
                ${implementationType}(${propertyId}).get_parent().id
            FROM dual
        `);

        expect(parentId).to.be(valueId);

        let value = JSON.parse(
            database.selectValue(`
                    ${implementationType}(${valueId}).as_json()
                FROM dual
            `)
        );

        expect(value).to.eql({
            name: "Sergejs",
            address: {
                city: "Riga"
            }
        });
    
    });
    
    test("Set property with path function version, bind", function() {
    
        let valueId = createValue({
            name: "Sergejs"
        });

        let builderId = database.selectValue(`
                t_json_builder().object()
                    .name('city').value('Riga')
                .close().id
            FROM dual
        `);

        let propertyId = database.call(pathFunctionName, {
            p_value_id: valueId,
            p_path: ":name",
            p_builder_id: builderId,
            p_bind: ["address"]
        });
    
        let parentId = database.selectValue(`
                ${implementationType}(${propertyId}).get_parent().id
            FROM dual
        `);

        expect(parentId).to.be(valueId);

        let value = JSON.parse(
            database.selectValue(`
                    ${implementationType}(${valueId}).as_json()
                FROM dual
            `)
        );

        expect(value).to.eql({
            name: "Sergejs",
            address: {
                city: "Riga"
            }
        });
    
    });

    test("Set property with path procedure version, no bind", function() {
    
        let valueId = createValue({
            name: "Sergejs"
        });

        let builderId = database.selectValue(`
                t_json_builder().object()
                    .name('city').value('Riga')
                .close().id
            FROM dual
        `);

        database.run(`
            BEGIN
                ${implementationType}(${valueId}).set_json(
                    'address',
                    t_json_builder(${builderId})
                );    
            END;
        `);

        let value = JSON.parse(
            database.selectValue(`
                    ${implementationType}(${valueId}).as_json()
                FROM dual
            `)
        );

        expect(value).to.eql({
            name: "Sergejs",
            address: {
                city: "Riga"
            }
        });
    
    });

    test("Set property with path procedure version, bind", function() {
    
        let valueId = createValue({
            name: "Sergejs"
        });

        let builderId = database.selectValue(`
                t_json_builder().object()
                    .name('city').value('Riga')
                .close().id
            FROM dual
        `);

        database.run(`
            BEGIN
                ${implementationType}(${valueId}).set_json(
                    ':name',
                    t_json_builder(${builderId}),
                    bind('address')
                );    
            END;
        `);

        let value = JSON.parse(
            database.selectValue(`
                    ${implementationType}(${valueId}).as_json()
                FROM dual
            `)
        );

        expect(value).to.eql({
            name: "Sergejs",
            address: {
                city: "Riga"
            }
        });
    
    });

    test("Set property with index function version", function() {
    
        let valueId = createValue([
            "Hello, World!"
        ]);

        let builderId = database.selectValue(`
                t_json_builder().object()
                    .name('city').value('Riga')
                .close().id
            FROM dual
        `);

        let propertyId = database.call(indexFunctionName, {
            p_value_id: valueId,
            p_index: 1,
            p_builder_id: builderId
        });
    
        let parentId = database.selectValue(`
                ${implementationType}(${propertyId}).get_parent().id
            FROM dual
        `);

        expect(parentId).to.be(valueId);

        let value = JSON.parse(
            database.selectValue(`
                    ${implementationType}(${valueId}).as_json()
                FROM dual
            `)
        );

        expect(value).to.eql([
            "Hello, World!",
            {
                city: "Riga"
            }
        ]);
    
    });

    test("Set property with index procedure version", function() {
    
        let valueId = createValue([
            "Hello, World!"
        ]);

        let builderId = database.selectValue(`
                t_json_builder().object()
                    .name('city').value('Riga')
                .close().id
            FROM dual
        `);

        database.run(`
            BEGIN
                ${implementationType}(${valueId}).set_json(
                    1,
                    t_json_builder(${builderId})
                );
            END;
        `);

        let value = JSON.parse(
            database.selectValue(`
                    ${implementationType}(${valueId}).as_json()
                FROM dual
            `)
        );

        expect(value).to.eql([
            "Hello, World!",
            {
                city: "Riga"
            }
        ]);
    
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

suite("SET_JSON T_JSON version tests", function() {

    let pathFunctionName = 'F' + randomString(16);
    let indexFunctionName = 'F' + randomString(16);

    setup("Create wrapper functions for functio methods", function() {
    
        database.run(`
            BEGIN
                EXECUTE IMMEDIATE '
                    CREATE OR REPLACE FUNCTION ${pathFunctionName} (
                        p_value_id IN NUMBER,
                        p_path IN VARCHAR2,
                        p_child_value_id IN NUMBER,
                        p_bind IN bind
                    )
                    RETURN NUMBER IS
                    BEGIN
                        RETURN ${implementationType}(p_value_id).set_json(
                            p_path,
                            ${implementationType}(p_child_value_id),
                            p_bind
                        ).id;
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
                        p_child_value_id IN NUMBER
                    )
                    RETURN NUMBER IS
                    BEGIN
                        RETURN ${implementationType}(p_value_id).set_json(
                            p_index,
                            ${implementationType}(p_child_value_id)
                        ).id;
                    END;
                ';    
            END;
        `);
    
    });
    
    test("Try to pass NULL builder to the function version", function() {
    
        let valueId = createValue({
            name: "Sergejs"
        });

        expect(function() {
        
            database.selectValue(`
                    ${implementationType}(${valueId}).set_json('address', CAST(NULL AS ${implementationType})).id
                FROM dual
            `);
        
        }).to.throw(/JDC-00049/);
    
    });
    
    test("Try to pass NULL builder to the procedure version", function() {
    
        let valueId = createValue({
            name: "Sergejs"
        });

        expect(function() {
        
            database.run(`
                BEGIN
                    ${implementationType}(${valueId}).set_json('address', CAST(NULL AS ${implementationType}));
                END;
            `);
            
        }).to.throw(/JDC-00049/);
    
    });

    test("Try to pass NULL builder to the index function version", function() {
    
        let valueId = createValue([
            "Hello, World!"
        ]);

        expect(function() {
        
            database.selectValue(`
                    ${implementationType}(${valueId}).set_json(1, CAST(NULL AS ${implementationType})).id
                FROM dual
            `);
        
        }).to.throw(/JDC-00049/);
    
    });
    
    test("Try to pass NULL builder to the index procedure version", function() {
    
        let valueId = createValue([
            "Hello, World!"
        ]);

        expect(function() {
        
            database.run(`
                BEGIN
                    ${implementationType}(${valueId}).set_json(1, CAST(NULL AS ${implementationType}));
                END;
            `);
            
        }).to.throw(/JDC-00049/);
    
    });

    test("Set property with path function version, no bind", function() {
    
        let valueId = createValue({
            name: "Sergejs"
        });

        let childValueId = createValue({
            city: "Riga"
        });

        let propertyId = database.call(pathFunctionName, {
            p_value_id: valueId,
            p_path: "address",
            p_child_value_id: childValueId,
            p_bind: null
        });
    
        let parentId = database.selectValue(`
                ${implementationType}(${propertyId}).get_parent().id
            FROM dual
        `);

        expect(parentId).to.be(valueId);

        let value = JSON.parse(
            database.selectValue(`
                    ${implementationType}(${valueId}).as_json()
                FROM dual
            `)
        );

        expect(value).to.eql({
            name: "Sergejs",
            address: {
                city: "Riga"
            }
        });
    
    });
    
    test("Set property with path function version, bind", function() {
    
        let valueId = createValue({
            name: "Sergejs"
        });

        let childValueId = createValue({
            city: "Riga"
        });

        let propertyId = database.call(pathFunctionName, {
            p_value_id: valueId,
            p_path: ":name",
            p_child_value_id: childValueId,
            p_bind: ["address"]
        });
    
        let parentId = database.selectValue(`
                ${implementationType}(${propertyId}).get_parent().id
            FROM dual
        `);

        expect(parentId).to.be(valueId);

        let value = JSON.parse(
            database.selectValue(`
                    ${implementationType}(${valueId}).as_json()
                FROM dual
            `)
        );

        expect(value).to.eql({
            name: "Sergejs",
            address: {
                city: "Riga"
            }
        });
    
    });

    test("Set property with path procedure version, no bind", function() {
    
        let valueId = createValue({
            name: "Sergejs"
        });

        let childValueId = createValue({
            city: "Riga"
        });

        database.run(`
            BEGIN
                ${implementationType}(${valueId}).set_json(
                    'address',
                    ${implementationType}(${childValueId})
                );    
            END;
        `);

        let value = JSON.parse(
            database.selectValue(`
                    ${implementationType}(${valueId}).as_json()
                FROM dual
            `)
        );

        expect(value).to.eql({
            name: "Sergejs",
            address: {
                city: "Riga"
            }
        });
    
    });

    test("Set property with path procedure version, bind", function() {
    
        let valueId = createValue({
            name: "Sergejs"
        });

        let childValueId = createValue({
            city: "Riga"
        });

        database.run(`
            BEGIN
                ${implementationType}(${valueId}).set_json(
                    ':name',
                    ${implementationType}(${childValueId}),
                    bind('address')
                );    
            END;
        `);

        let value = JSON.parse(
            database.selectValue(`
                    ${implementationType}(${valueId}).as_json()
                FROM dual
            `)
        );

        expect(value).to.eql({
            name: "Sergejs",
            address: {
                city: "Riga"
            }
        });
    
    });

    test("Set property with index function version", function() {
    
        let valueId = createValue([
            "Hello, World!"
        ]);

        let childValueId = createValue({
            city: "Riga"
        });

        let propertyId = database.call(indexFunctionName, {
            p_value_id: valueId,
            p_index: 1,
            p_child_value_id: childValueId
        });
    
        let parentId = database.selectValue(`
                ${implementationType}(${propertyId}).get_parent().id
            FROM dual
        `);

        expect(parentId).to.be(valueId);

        let value = JSON.parse(
            database.selectValue(`
                    ${implementationType}(${valueId}).as_json()
                FROM dual
            `)
        );

        expect(value).to.eql([
            "Hello, World!",
            {
                city: "Riga"
            }
        ]);
    
    });

    test("Set property with index procedure version", function() {
    
        let valueId = createValue([
            "Hello, World!"
        ]);

        let childValueId = createValue({
            city: "Riga"
        });

        database.run(`
            BEGIN
                ${implementationType}(${valueId}).set_json(
                    1,
                    ${implementationType}(${childValueId})
                );
            END;
        `);

        let value = JSON.parse(
            database.selectValue(`
                    ${implementationType}(${valueId}).as_json()
                FROM dual
            `)
        );

        expect(value).to.eql([
            "Hello, World!",
            {
                city: "Riga"
            }
        ]);
    
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