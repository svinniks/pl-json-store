function createValue(value) {

    let events = database.call("json_parser.parse", {
        p_content: JSON.stringify(value)
    });

    return database.call(`${implementationPackage}.create_json`, {
        p_content_parse_events: events
    });

}

suite("PUSH_STRING tests", function() {

    let functionName = 'F' + randomString(16);

    setup("Create a wrapper function to test function methods", function() {
    
        database.run(`
            BEGIN
                EXECUTE IMMEDIATE '
                    CREATE OR REPLACE FUNCTION ${functionName} (
                        p_value_id IN NUMBER,
                        p_value IN VARCHAR2
                    )
                    RETURN NUMBER IS
                    BEGIN
                        RETURN ${implementationType}(p_value_id).push_string(p_value).id;
                    END;
                ';    
            END;
        `);    
    
    });
    
    test("Try to push string to a non-existing value, function version", function() {
    
        expect(function() {
        
            database.run(`
                DECLARE
                    v_dummy t_json;
                BEGIN
                    v_dummy := ${implementationType}(-1).push_string('Hello, World!');
                END;
            `);
        
        }).to.throw(/JDC-00009/);
    
    });

    test("Try to push string to a non-existing value, procedure version", function() {
    
        expect(function() {
        
            database.run(`
                BEGIN
                    ${implementationType}(-1).push_string('Hello, World!');
                END;
            `);
        
        }).to.throw(/JDC-00009/);
    
    });

    test("Try to push string to a non-array, function version", function() {
    
        let valueId = createValue("Hello, World!");

        expect(function() {
        
            database.run(`
                DECLARE
                    v_dummy t_json;
                BEGIN
                    v_dummy := ${implementationType}(${valueId}).push_string('Hello, World!');
                END;
            `);
        
        }).to.throw(/JDC-00012/);
    
    });

    test("Try to push string to a non-array, procedure version", function() {

        let valueId = createValue("Hello, World!");

        expect(function() {
        
            database.run(`
                BEGIN
                    ${implementationType}(${valueId}).push_string('Hello, World!');
                END;
            `);
        
        }).to.throw(/JDC-00012/);
    
    });

    test("Push string to an array, function version", function() {
    
        let valueId = createValue([
            "Hello, World!",
            123.456
        ]);

        let elementId = database.call(functionName, {
            p_value_id: valueId,
            p_value: "Good bye, World!"
        });

        let parentId = database.selectValue(`
                ${implementationType}(${elementId}).get_parent().id
            FROM dual
        `);

        expect(parentId).to.be(valueId);

        let events = database.call(`${implementationPackage}.get_parse_events`, {
            p_value_id: valueId,
            p_serialize_nulls: true
        });

        expect(events).to.eql([
            "[",
            ":0",
            "SHello, World!",
            ":1",
            "N123.456",
            ":2",
            "SGood bye, World!",
            "]"
        ]);
        
    });
    
    test("Push string to an array, procedure version", function() {
    
        let valueId = createValue([
            "Hello, World!",
            123.456
        ]);

        database.run(`
            BEGIN
                ${implementationType}(${valueId}).push_string('Good bye, World!');
            END;
        `);

        let events = database.call(`${implementationPackage}.get_parse_events`, {
            p_value_id: valueId,
            p_serialize_nulls: true
        });

        expect(events).to.eql([
            "[",
            ":0",
            "SHello, World!",
            ":1",
            "N123.456",
            ":2",
            "SGood bye, World!",
            "]"
        ]);
        
    });

    teardown("Drop the wrapper function", function() {
        
        database.run(`
            BEGIN
                EXECUTE IMMEDIATE 'DROP FUNCTION ${functionName}';                
            END;
        `);
    
    });
    
});

suite("PUSH_NUMBER tests", function() {

    let functionName = 'F' + randomString(16);

    setup("Create a wrapper function to test function methods", function() {
    
        database.run(`
            BEGIN
                EXECUTE IMMEDIATE '
                    CREATE OR REPLACE FUNCTION ${functionName} (
                        p_value_id IN NUMBER,
                        p_value IN NUMBER
                    )
                    RETURN NUMBER IS
                    BEGIN
                        RETURN ${implementationType}(p_value_id).push_number(p_value).id;
                    END;
                ';    
            END;
        `);    
    
    });
    
    test("Try to push number to a non-existing value, function version", function() {
    
        expect(function() {
        
            database.run(`
                DECLARE
                    v_dummy t_json;
                BEGIN
                    v_dummy := ${implementationType}(-1).push_number(123.456);
                END;
            `);
        
        }).to.throw(/JDC-00009/);
    
    });

    test("Try to push number to a non-existing value, procedure version", function() {
    
        expect(function() {
        
            database.run(`
                BEGIN
                    ${implementationType}(-1).push_number(123.456);
                END;
            `);
        
        }).to.throw(/JDC-00009/);
    
    });

    test("Try to push number to a non-array, function version", function() {
    
        let valueId = createValue("Hello, World!");

        expect(function() {
        
            database.run(`
                DECLARE
                    v_dummy t_json;
                BEGIN
                    v_dummy := ${implementationType}(${valueId}).push_number(123.456);
                END;
            `);
        
        }).to.throw(/JDC-00012/);
    
    });

    test("Try to push number to a non-array, procedure version", function() {

        let valueId = createValue("Hello, World!");

        expect(function() {
        
            database.run(`
                BEGIN
                    ${implementationType}(${valueId}).push_number(123.456);
                END;
            `);
        
        }).to.throw(/JDC-00012/);
    
    });

    test("Push number to an array, function version", function() {
    
        let valueId = createValue([
            "Hello, World!",
            123.456
        ]);

        let elementId = database.call(functionName, {
            p_value_id: valueId,
            p_value: 123.456
        });

        let parentId = database.selectValue(`
                ${implementationType}(${elementId}).get_parent().id
            FROM dual
        `);

        expect(parentId).to.be(valueId);

        let events = database.call(`${implementationPackage}.get_parse_events`, {
            p_value_id: valueId,
            p_serialize_nulls: true
        });

        expect(events).to.eql([
            "[",
            ":0",
            "SHello, World!",
            ":1",
            "N123.456",
            ":2",
            "N123.456",
            "]"
        ]);
        
    });
    
    test("Push number to an array, procedure version", function() {
    
        let valueId = createValue([
            "Hello, World!",
            123.456
        ]);

        database.run(`
            BEGIN
                ${implementationType}(${valueId}).push_number(123.456);
            END;
        `);

        let events = database.call(`${implementationPackage}.get_parse_events`, {
            p_value_id: valueId,
            p_serialize_nulls: true
        });

        expect(events).to.eql([
            "[",
            ":0",
            "SHello, World!",
            ":1",
            "N123.456",
            ":2",
            "N123.456",
            "]"
        ]);
        
    });

    teardown("Drop the wrapper function", function() {
        
        database.run(`
            BEGIN
                EXECUTE IMMEDIATE 'DROP FUNCTION ${functionName}';                
            END;
        `);
    
    });
    
});

suite("PUSH_DATE tests", function() {

    let functionName = 'F' + randomString(16);

    setup("Create a wrapper function to test function methods", function() {
    
        database.run(`
            BEGIN
                EXECUTE IMMEDIATE '
                    CREATE OR REPLACE FUNCTION ${functionName} (
                        p_value_id IN NUMBER,
                        p_value IN DATE
                    )
                    RETURN NUMBER IS
                    BEGIN
                        RETURN ${implementationType}(p_value_id).push_date(p_value).id;
                    END;
                ';    
            END;
        `);    
    
    });
    
    test("Try to push date to a non-existing value, function version", function() {
    
        expect(function() {
        
            database.run(`
                DECLARE
                    v_dummy t_json;
                BEGIN
                    v_dummy := ${implementationType}(-1).push_date(DATE '2018-12-27');
                END;
            `);
        
        }).to.throw(/JDC-00009/);
    
    });

    test("Try to push date to a non-existing value, procedure version", function() {
    
        expect(function() {
        
            database.run(`
                BEGIN
                    ${implementationType}(-1).push_date(DATE '2018-12-27');
                END;
            `);
        
        }).to.throw(/JDC-00009/);
    
    });

    test("Try to push date to a non-array, function version", function() {
    
        let valueId = createValue("Hello, World!");

        expect(function() {
        
            database.run(`
                DECLARE
                    v_dummy t_json;
                BEGIN
                    v_dummy := ${implementationType}(${valueId}).push_date(DATE '2018-12-27');
                END;
            `);
        
        }).to.throw(/JDC-00012/);
    
    });

    test("Try to push date to a non-array, procedure version", function() {

        let valueId = createValue("Hello, World!");

        expect(function() {
        
            database.run(`
                BEGIN
                    ${implementationType}(${valueId}).push_date(DATE '2018-12-27');
                END;
            `);
        
        }).to.throw(/JDC-00012/);
    
    });

    test("Push date to an array, function version", function() {
    
        let valueId = createValue([
            "Hello, World!",
            123.456
        ]);

        let elementId = database.call(functionName, {
            p_value_id: valueId,
            p_value: "2018-12-27"
        });

        let parentId = database.selectValue(`
                ${implementationType}(${elementId}).get_parent().id
            FROM dual
        `);

        expect(parentId).to.be(valueId);

        let events = database.call(`${implementationPackage}.get_parse_events`, {
            p_value_id: valueId,
            p_serialize_nulls: true
        });

        expect(events).to.eql([
            "[",
            ":0",
            "SHello, World!",
            ":1",
            "N123.456",
            ":2",
            "S2018-12-27",
            "]"
        ]);
        
    });
    
    test("Push date to an array, procedure version", function() {
    
        let valueId = createValue([
            "Hello, World!",
            123.456
        ]);

        database.run(`
            BEGIN
                ${implementationType}(${valueId}).push_date(DATE '2018-12-27');
            END;
        `);

        let events = database.call(`${implementationPackage}.get_parse_events`, {
            p_value_id: valueId,
            p_serialize_nulls: true
        });

        expect(events).to.eql([
            "[",
            ":0",
            "SHello, World!",
            ":1",
            "N123.456",
            ":2",
            "S2018-12-27",
            "]"
        ]);
        
    });

    teardown("Drop the wrapper function", function() {
        
        database.run(`
            BEGIN
                EXECUTE IMMEDIATE 'DROP FUNCTION ${functionName}';                
            END;
        `);
    
    });
    
});

suite("PUSH_BOOLEAN tests", function() {

    let functionName = 'F' + randomString(16);

    setup("Create a wrapper function to test function methods", function() {
    
        database.run(`
            BEGIN
                EXECUTE IMMEDIATE '
                    CREATE OR REPLACE FUNCTION ${functionName} (
                        p_value_id IN NUMBER,
                        p_value IN BOOLEAN
                    )
                    RETURN NUMBER IS
                    BEGIN
                        RETURN ${implementationType}(p_value_id).push_boolean(p_value).id;
                    END;
                ';    
            END;
        `);    
    
    });
    
    test("Try to push boolean to a non-existing value, function version", function() {
    
        expect(function() {
        
            database.run(`
                DECLARE
                    v_dummy t_json;
                BEGIN
                    v_dummy := ${implementationType}(-1).push_boolean(true);
                END;
            `);
        
        }).to.throw(/JDC-00009/);
    
    });

    test("Try to push boolean to a non-existing value, procedure version", function() {
    
        expect(function() {
        
            database.run(`
                BEGIN
                    ${implementationType}(-1).push_boolean(true);
                END;
            `);
        
        }).to.throw(/JDC-00009/);
    
    });

    test("Try to push boolean to a non-array, function version", function() {
    
        let valueId = createValue("Hello, World!");

        expect(function() {
        
            database.run(`
                DECLARE
                    v_dummy t_json;
                BEGIN
                    v_dummy := ${implementationType}(${valueId}).push_boolean(true);
                END;
            `);
        
        }).to.throw(/JDC-00012/);
    
    });

    test("Try to push boolean to a non-array, procedure version", function() {

        let valueId = createValue("Hello, World!");

        expect(function() {
        
            database.run(`
                BEGIN
                    ${implementationType}(${valueId}).push_boolean(true);
                END;
            `);
        
        }).to.throw(/JDC-00012/);
    
    });

    test("Push boolean to an array, function version", function() {
    
        let valueId = createValue([
            "Hello, World!",
            123.456
        ]);

        let elementId = database.call(functionName, {
            p_value_id: valueId,
            p_value: true
        });

        let parentId = database.selectValue(`
                ${implementationType}(${elementId}).get_parent().id
            FROM dual
        `);

        expect(parentId).to.be(valueId);

        let events = database.call(`${implementationPackage}.get_parse_events`, {
            p_value_id: valueId,
            p_serialize_nulls: true
        });

        expect(events).to.eql([
            "[",
            ":0",
            "SHello, World!",
            ":1",
            "N123.456",
            ":2",
            "Btrue",
            "]"
        ]);
        
    });
    
    test("Push boolean to an array, procedure version", function() {
    
        let valueId = createValue([
            "Hello, World!",
            123.456
        ]);

        database.run(`
            BEGIN
                ${implementationType}(${valueId}).push_boolean(true);
            END;
        `);

        let events = database.call(`${implementationPackage}.get_parse_events`, {
            p_value_id: valueId,
            p_serialize_nulls: true
        });

        expect(events).to.eql([
            "[",
            ":0",
            "SHello, World!",
            ":1",
            "N123.456",
            ":2",
            "Btrue",
            "]"
        ]);
        
    });

    teardown("Drop the wrapper function", function() {
        
        database.run(`
            BEGIN
                EXECUTE IMMEDIATE 'DROP FUNCTION ${functionName}';                
            END;
        `);
    
    });
    
});

suite("PUSH_NULL tests", function() {

    let functionName = 'F' + randomString(16);

    setup("Create a wrapper function to test function methods", function() {
    
        database.run(`
            BEGIN
                EXECUTE IMMEDIATE '
                    CREATE OR REPLACE FUNCTION ${functionName} (
                        p_value_id IN NUMBER
                    )
                    RETURN NUMBER IS
                    BEGIN
                        RETURN ${implementationType}(p_value_id).push_null().id;
                    END;
                ';    
            END;
        `);    
    
    });
    
    test("Try to push null to a non-existing value, function version", function() {
    
        expect(function() {
        
            database.run(`
                DECLARE
                    v_dummy t_json;
                BEGIN
                    v_dummy := ${implementationType}(-1).push_null;
                END;
            `);
        
        }).to.throw(/JDC-00009/);
    
    });

    test("Try to push null to a non-existing value, procedure version", function() {
    
        expect(function() {
        
            database.run(`
                BEGIN
                    ${implementationType}(-1).push_null;
                END;
            `);
        
        }).to.throw(/JDC-00009/);
    
    });

    test("Try to push null to a non-array, function version", function() {
    
        let valueId = createValue("Hello, World!");

        expect(function() {
        
            database.run(`
                DECLARE
                    v_dummy t_json;
                BEGIN
                    v_dummy := ${implementationType}(${valueId}).push_null;
                END;
            `);
        
        }).to.throw(/JDC-00012/);
    
    });

    test("Try to push null to a non-array, procedure version", function() {

        let valueId = createValue("Hello, World!");

        expect(function() {
        
            database.run(`
                BEGIN
                    ${implementationType}(${valueId}).push_null;
                END;
            `);
        
        }).to.throw(/JDC-00012/);
    
    });

    test("Push null to an array, function version", function() {
    
        let valueId = createValue([
            "Hello, World!",
            123.456
        ]);

        let elementId = database.call(functionName, {
            p_value_id: valueId
        });

        let parentId = database.selectValue(`
                ${implementationType}(${elementId}).get_parent().id
            FROM dual
        `);

        expect(parentId).to.be(valueId);

        let events = database.call(`${implementationPackage}.get_parse_events`, {
            p_value_id: valueId,
            p_serialize_nulls: true
        });

        expect(events).to.eql([
            "[",
            ":0",
            "SHello, World!",
            ":1",
            "N123.456",
            ":2",
            "E",
            "]"
        ]);
        
    });
    
    test("Push boolean to an array, procedure version", function() {
    
        let valueId = createValue([
            "Hello, World!",
            123.456
        ]);

        database.run(`
            BEGIN
                ${implementationType}(${valueId}).push_null;
            END;
        `);

        let events = database.call(`${implementationPackage}.get_parse_events`, {
            p_value_id: valueId,
            p_serialize_nulls: true
        });

        expect(events).to.eql([
            "[",
            ":0",
            "SHello, World!",
            ":1",
            "N123.456",
            ":2",
            "E",
            "]"
        ]);
        
    });

    teardown("Drop the wrapper function", function() {
        
        database.run(`
            BEGIN
                EXECUTE IMMEDIATE 'DROP FUNCTION ${functionName}';                
            END;
        `);
    
    });
    
});

suite("PUSH_OBJECT tests", function() {

    let functionName = 'F' + randomString(16);

    setup("Create a wrapper function to test function methods", function() {
    
        database.run(`
            BEGIN
                EXECUTE IMMEDIATE '
                    CREATE OR REPLACE FUNCTION ${functionName} (
                        p_value_id IN NUMBER
                    )
                    RETURN NUMBER IS
                    BEGIN
                        RETURN ${implementationType}(p_value_id).push_object().id;
                    END;
                ';    
            END;
        `);    
    
    });
    
    test("Try to push object to a non-existing value, function version", function() {
    
        expect(function() {
        
            database.run(`
                DECLARE
                    v_dummy t_json;
                BEGIN
                    v_dummy := ${implementationType}(-1).push_object;
                END;
            `);
        
        }).to.throw(/JDC-00009/);
    
    });

    test("Try to push object to a non-existing value, procedure version", function() {
    
        expect(function() {
        
            database.run(`
                BEGIN
                    ${implementationType}(-1).push_object;
                END;
            `);
        
        }).to.throw(/JDC-00009/);
    
    });

    test("Try to push object to a non-array, function version", function() {
    
        let valueId = createValue("Hello, World!");

        expect(function() {
        
            database.run(`
                DECLARE
                    v_dummy t_json;
                BEGIN
                    v_dummy := ${implementationType}(${valueId}).push_object;
                END;
            `);
        
        }).to.throw(/JDC-00012/);
    
    });

    test("Try to push object to a non-array, procedure version", function() {

        let valueId = createValue("Hello, World!");

        expect(function() {
        
            database.run(`
                BEGIN
                    ${implementationType}(${valueId}).push_object;
                END;
            `);
        
        }).to.throw(/JDC-00012/);
    
    });

    test("Push object to an array, function version", function() {
    
        let valueId = createValue([
            "Hello, World!",
            123.456
        ]);

        let elementId = database.call(functionName, {
            p_value_id: valueId
        });

        let parentId = database.selectValue(`
                ${implementationType}(${elementId}).get_parent().id
            FROM dual
        `);

        expect(parentId).to.be(valueId);

        let events = database.call(`${implementationPackage}.get_parse_events`, {
            p_value_id: valueId,
            p_serialize_nulls: true
        });

        expect(events).to.eql([
            "[",
            ":0",
            "SHello, World!",
            ":1",
            "N123.456",
            ":2",
            "{",
            "}",
            "]"
        ]);
        
    });
    
    test("Push object to an array, procedure version", function() {
    
        let valueId = createValue([
            "Hello, World!",
            123.456
        ]);

        database.run(`
            BEGIN
                ${implementationType}(${valueId}).push_object;
            END;
        `);

        let events = database.call(`${implementationPackage}.get_parse_events`, {
            p_value_id: valueId,
            p_serialize_nulls: true
        });

        expect(events).to.eql([
            "[",
            ":0",
            "SHello, World!",
            ":1",
            "N123.456",
            ":2",
            "{",
            "}",
            "]"
        ]);
        
    });

    teardown("Drop the wrapper function", function() {
        
        database.run(`
            BEGIN
                EXECUTE IMMEDIATE 'DROP FUNCTION ${functionName}';                
            END;
        `);
    
    });
    
});

suite("PUSH_ARRAY tests", function() {

    let functionName = 'F' + randomString(16);

    setup("Create a wrapper function to test function methods", function() {
    
        database.run(`
            BEGIN
                EXECUTE IMMEDIATE '
                    CREATE OR REPLACE FUNCTION ${functionName} (
                        p_value_id IN NUMBER
                    )
                    RETURN NUMBER IS
                    BEGIN
                        RETURN ${implementationType}(p_value_id).push_array().id;
                    END;
                ';    
            END;
        `);    
    
    });
    
    test("Try to push array to a non-existing value, function version", function() {
    
        expect(function() {
        
            database.run(`
                DECLARE
                    v_dummy t_json;
                BEGIN
                    v_dummy := ${implementationType}(-1).push_array;
                END;
            `);
        
        }).to.throw(/JDC-00009/);
    
    });

    test("Try to push array to a non-existing value, procedure version", function() {
    
        expect(function() {
        
            database.run(`
                BEGIN
                    ${implementationType}(-1).push_array;
                END;
            `);
        
        }).to.throw(/JDC-00009/);
    
    });

    test("Try to push array to a non-array, function version", function() {
    
        let valueId = createValue("Hello, World!");

        expect(function() {
        
            database.run(`
                DECLARE
                    v_dummy t_json;
                BEGIN
                    v_dummy := ${implementationType}(${valueId}).push_array;
                END;
            `);
        
        }).to.throw(/JDC-00012/);
    
    });

    test("Try to push array to a non-array, procedure version", function() {

        let valueId = createValue("Hello, World!");

        expect(function() {
        
            database.run(`
                BEGIN
                    ${implementationType}(${valueId}).push_array;
                END;
            `);
        
        }).to.throw(/JDC-00012/);
    
    });

    test("Push array to an array, function version", function() {
    
        let valueId = createValue([
            "Hello, World!",
            123.456
        ]);

        let elementId = database.call(functionName, {
            p_value_id: valueId
        });

        let parentId = database.selectValue(`
                ${implementationType}(${elementId}).get_parent().id
            FROM dual
        `);

        expect(parentId).to.be(valueId);

        let events = database.call(`${implementationPackage}.get_parse_events`, {
            p_value_id: valueId,
            p_serialize_nulls: true
        });

        expect(events).to.eql([
            "[",
            ":0",
            "SHello, World!",
            ":1",
            "N123.456",
            ":2",
            "[",
            "]",
            "]"
        ]);
        
    });
    
    test("Push array to an array, procedure version", function() {
    
        let valueId = createValue([
            "Hello, World!",
            123.456
        ]);

        database.run(`
            BEGIN
                ${implementationType}(${valueId}).push_array;
            END;
        `);

        let events = database.call(`${implementationPackage}.get_parse_events`, {
            p_value_id: valueId,
            p_serialize_nulls: true
        });

        expect(events).to.eql([
            "[",
            ":0",
            "SHello, World!",
            ":1",
            "N123.456",
            ":2",
            "[",
            "]",
            "]"
        ]);
        
    });

    teardown("Drop the wrapper function", function() {
        
        database.run(`
            BEGIN
                EXECUTE IMMEDIATE 'DROP FUNCTION ${functionName}';                
            END;
        `);
    
    });
    
});

suite("PUSH_JSON VARCHAR2 version tests", function() {

    let functionName = 'F' + randomString(16);

    setup("Create a wrapper function to test function methods", function() {
    
        database.run(`
            BEGIN
                EXECUTE IMMEDIATE '
                    CREATE OR REPLACE FUNCTION ${functionName} (
                        p_value_id IN NUMBER,
                        p_content IN VARCHAR2
                    )
                    RETURN NUMBER IS
                    BEGIN
                        RETURN ${implementationType}(p_value_id).push_json(p_content).id;
                    END;
                ';    
            END;
        `);    
    
    });
    
    test("Try to push json to a non-existing value, function version", function() {
    
        expect(function() {
        
            database.run(`
                DECLARE
                    v_dummy t_json;
                BEGIN
                    v_dummy := ${implementationType}(-1).push_json('"Good bye, World!"');
                END;
            `);
        
        }).to.throw(/JDC-00009/);
    
    });

    test("Try to push json to a non-existing value, procedure version", function() {
    
        expect(function() {
        
            database.run(`
                BEGIN
                    ${implementationType}(-1).push_json('"Good bye, World!"');
                END;
            `);
        
        }).to.throw(/JDC-00009/);
    
    });

    test("Try to push json to a non-array, function version", function() {
    
        let valueId = createValue("Hello, World!");

        expect(function() {
        
            database.run(`
                DECLARE
                    v_dummy t_json;
                BEGIN
                    v_dummy := ${implementationType}(${valueId}).push_json('"Good bye, World!"');
                END;
            `);
        
        }).to.throw(/JDC-00012/);
    
    });

    test("Try to push json to a non-array, procedure version", function() {

        let valueId = createValue("Hello, World!");

        expect(function() {
        
            database.run(`
                BEGIN
                    ${implementationType}(${valueId}).push_json('"Good bye, World!"');
                END;
            `);
        
        }).to.throw(/JDC-00012/);
    
    });

    test("Push json to an array, function version", function() {
    
        let valueId = createValue([
            "Hello, World!",
            123.456
        ]);

        let elementId = database.call(functionName, {
            p_value_id: valueId,
            p_content: "\"Good bye, World!\""
        });

        let parentId = database.selectValue(`
                ${implementationType}(${elementId}).get_parent().id
            FROM dual
        `);

        expect(parentId).to.be(valueId);

        let events = database.call(`${implementationPackage}.get_parse_events`, {
            p_value_id: valueId,
            p_serialize_nulls: true
        });

        expect(events).to.eql([
            "[",
            ":0",
            "SHello, World!",
            ":1",
            "N123.456",
            ":2",
            "SGood bye, World!",
            "]"
        ]);
        
    });
    
    test("Push json to an array, procedure version", function() {
    
        let valueId = createValue([
            "Hello, World!",
            123.456
        ]);

        database.run(`
            BEGIN
                ${implementationType}(${valueId}).push_json('"Good bye, World!"');
            END;
        `);

        let events = database.call(`${implementationPackage}.get_parse_events`, {
            p_value_id: valueId,
            p_serialize_nulls: true
        });

        expect(events).to.eql([
            "[",
            ":0",
            "SHello, World!",
            ":1",
            "N123.456",
            ":2",
            "SGood bye, World!",
            "]"
        ]);
        
    });

    teardown("Drop the wrapper function", function() {
        
        database.run(`
            BEGIN
                EXECUTE IMMEDIATE 'DROP FUNCTION ${functionName}';                
            END;
        `);
    
    });
    
});

suite("PUSH_JSON CLOB version tests", function() {

    let functionName = 'F' + randomString(16);

    setup("Create a wrapper function to test function methods", function() {
    
        database.run(`
            BEGIN
                EXECUTE IMMEDIATE '
                    CREATE OR REPLACE FUNCTION ${functionName} (
                        p_value_id IN NUMBER,
                        p_content IN CLOB
                    )
                    RETURN NUMBER IS
                    BEGIN
                        RETURN ${implementationType}(p_value_id).push_json(p_content).id;
                    END;
                ';    
            END;
        `);    
    
    });
    
    test("Try to push json to a non-existing value, function version", function() {
    
        expect(function() {
        
            database.run(`
                DECLARE
                    v_dummy t_json;
                BEGIN
                    v_dummy := ${implementationType}(-1).push_json(TO_CLOB('"Good bye, World!"'));
                END;
            `);
        
        }).to.throw(/JDC-00009/);
    
    });

    test("Try to push json to a non-existing value, procedure version", function() {
    
        expect(function() {
        
            database.run(`
                BEGIN
                    ${implementationType}(-1).push_json(TO_CLOB('"Good bye, World!"'));
                END;
            `);
        
        }).to.throw(/JDC-00009/);
    
    });

    test("Try to push json to a non-array, function version", function() {
    
        let valueId = createValue("Hello, World!");

        expect(function() {
        
            database.run(`
                DECLARE
                    v_dummy t_json;
                BEGIN
                    v_dummy := ${implementationType}(${valueId}).push_json(TO_CLOB('"Good bye, World!"'));
                END;
            `);
        
        }).to.throw(/JDC-00012/);
    
    });

    test("Try to push json to a non-array, procedure version", function() {

        let valueId = createValue("Hello, World!");

        expect(function() {
        
            database.run(`
                BEGIN
                    ${implementationType}(${valueId}).push_json(TO_CLOB('"Good bye, World!"'));
                END;
            `);
        
        }).to.throw(/JDC-00012/);
    
    });

    test("Push json to an array, function version", function() {
    
        let valueId = createValue([
            "Hello, World!",
            123.456
        ]);

        let elementId = database.call(functionName, {
            p_value_id: valueId,
            p_content: "\"Good bye, World!\""
        });

        let parentId = database.selectValue(`
                ${implementationType}(${elementId}).get_parent().id
            FROM dual
        `);

        expect(parentId).to.be(valueId);

        let events = database.call(`${implementationPackage}.get_parse_events`, {
            p_value_id: valueId,
            p_serialize_nulls: true
        });

        expect(events).to.eql([
            "[",
            ":0",
            "SHello, World!",
            ":1",
            "N123.456",
            ":2",
            "SGood bye, World!",
            "]"
        ]);
        
    });
    
    test("Push json to an array, procedure version", function() {
    
        let valueId = createValue([
            "Hello, World!",
            123.456
        ]);

        database.run(`
            BEGIN
                ${implementationType}(${valueId}).push_json(TO_CLOB('"Good bye, World!"'));
            END;
        `);

        let events = database.call(`${implementationPackage}.get_parse_events`, {
            p_value_id: valueId,
            p_serialize_nulls: true
        });

        expect(events).to.eql([
            "[",
            ":0",
            "SHello, World!",
            ":1",
            "N123.456",
            ":2",
            "SGood bye, World!",
            "]"
        ]);
        
    });

    teardown("Drop the wrapper function", function() {
        
        database.run(`
            BEGIN
                EXECUTE IMMEDIATE 'DROP FUNCTION ${functionName}';                
            END;
        `);
    
    });
    
});

suite("PUSH_JSON JSON builder version tests", function() {

    let functionName = 'F' + randomString(16);

    setup("Create a wrapper function to test function methods", function() {
    
        database.run(`
            BEGIN
                EXECUTE IMMEDIATE '
                    CREATE OR REPLACE FUNCTION ${functionName} (
                        p_value_id IN NUMBER,
                        p_builder_id IN NUMBER
                    )
                    RETURN NUMBER IS
                    BEGIN
                        RETURN ${implementationType}(p_value_id).push_json(t_json_builder(p_builder_id)).id;
                    END;
                ';    
            END;
        `);    
    
    });
    
    test("Try to push builder to a non-existing value, function version", function() {
    
        let builderId = database.selectValue(`
                t_json_builder().value('Good bye, World!').id
            FROM dual
        `);

        expect(function() {
        
            database.run(`
                DECLARE
                    v_dummy t_json;
                BEGIN
                    v_dummy := ${implementationType}(-1).push_json(t_json_builder(${builderId}));
                END;
            `);
        
        }).to.throw(/JDC-00009/);
    
    });

    test("Try to push builder to a non-existing value, procedure version", function() {
    
        let builderId = database.selectValue(`
                t_json_builder().value('Good bye, World!').id
            FROM dual
        `);

        expect(function() {
        
            database.run(`
                BEGIN
                    ${implementationType}(-1).push_json(t_json_builder(${builderId}));
                END;
            `);
        
        }).to.throw(/JDC-00009/);
    
    });

    test("Try to push builder to a non-array, function version", function() {
    
        let builderId = database.selectValue(`
                t_json_builder().value('Good bye, World!').id
            FROM dual
        `);

        let valueId = createValue("Hello, World!");

        expect(function() {
        
            database.run(`
                DECLARE
                    v_dummy t_json;
                BEGIN
                    v_dummy := ${implementationType}(${valueId}).push_json(t_json_builder(${builderId}));
                END;
            `);
        
        }).to.throw(/JDC-00012/);
    
    });

    test("Try to push builder to a non-array, procedure version", function() {

        let builderId = database.selectValue(`
                t_json_builder().value('Good bye, World!').id
            FROM dual
        `);

        let valueId = createValue("Hello, World!");

        expect(function() {
        
            database.run(`
                BEGIN
                    ${implementationType}(${valueId}).push_json(t_json_builder(${builderId}));
                END;
            `);
        
        }).to.throw(/JDC-00012/);
    
    });

    test("Push builder to an array, function version", function() {
    
        let builderId = database.selectValue(`
                t_json_builder().value('Good bye, World!').id
            FROM dual
        `);

        let valueId = createValue([
            "Hello, World!",
            123.456
        ]);

        let elementId = database.call(functionName, {
            p_value_id: valueId,
            p_builder_id: builderId
        });

        let parentId = database.selectValue(`
                ${implementationType}(${elementId}).get_parent().id
            FROM dual
        `);

        expect(parentId).to.be(valueId);

        let events = database.call(`${implementationPackage}.get_parse_events`, {
            p_value_id: valueId,
            p_serialize_nulls: true
        });

        expect(events).to.eql([
            "[",
            ":0",
            "SHello, World!",
            ":1",
            "N123.456",
            ":2",
            "SGood bye, World!",
            "]"
        ]);
        
    });
    
    test("Push builder to an array, procedure version", function() {
    
        let builderId = database.selectValue(`
                t_json_builder().value('Good bye, World!').id
            FROM dual
        `);

        let valueId = createValue([
            "Hello, World!",
            123.456
        ]);

        database.run(`
            BEGIN
                ${implementationType}(${valueId}).push_json(t_json_builder(${builderId}));
            END;
        `);

        let events = database.call(`${implementationPackage}.get_parse_events`, {
            p_value_id: valueId,
            p_serialize_nulls: true
        });

        expect(events).to.eql([
            "[",
            ":0",
            "SHello, World!",
            ":1",
            "N123.456",
            ":2",
            "SGood bye, World!",
            "]"
        ]);
        
    });

    teardown("Drop the wrapper function", function() {
        
        database.run(`
            BEGIN
                EXECUTE IMMEDIATE 'DROP FUNCTION ${functionName}';                
            END;
        `);
    
    });
    
});

suite("PUSH_JSON T_JSON version tests", function() {

    let functionName = 'F' + randomString(16);

    setup("Create a wrapper function to test function methods", function() {
    
        database.run(`
            BEGIN
                EXECUTE IMMEDIATE '
                    CREATE OR REPLACE FUNCTION ${functionName} (
                        p_value_id IN NUMBER,
                        p_element_id IN NUMBER
                    )
                    RETURN NUMBER IS
                    BEGIN
                        RETURN ${implementationType}(p_value_id).push_json(${implementationType}(p_element_id)).id;
                    END;
                ';    
            END;
        `);    
    
    });
    
    test("Try to push json value to a non-existing value, function version", function() {
    
        let elementId = createValue("Good bye, World!");

        expect(function() {
        
            database.run(`
                DECLARE
                    v_dummy t_json;
                BEGIN
                    v_dummy := ${implementationType}(-1).push_json(${implementationType}(${elementId}));
                END;
            `);
        
        }).to.throw(/JDC-00009/);
    
    });

    test("Try to push json value to a non-existing value, procedure version", function() {
    
        let elementId = createValue("Good bye, World!");

        expect(function() {
        
            database.run(`
                BEGIN
                    ${implementationType}(-1).push_json(${implementationType}(${elementId}));
                END;
            `);
        
        }).to.throw(/JDC-00009/);
    
    });

    test("Try to push json to a non-array, function version", function() {
    
        let valueId = createValue("Hello, World!");
        let elementId = createValue("Good bye, World!");

        expect(function() {
        
            database.run(`
                DECLARE
                    v_dummy t_json;
                BEGIN
                    v_dummy := ${implementationType}(${valueId}).push_json(${implementationType}(${elementId}));
                END;
            `);
        
        }).to.throw(/JDC-00012/);
    
    });

    test("Try to push json value to a non-array, procedure version", function() {

        let valueId = createValue("Hello, World!");
        let elementId = createValue("Good bye, World!");

        expect(function() {
        
            database.run(`
                BEGIN
                    ${implementationType}(${valueId}).push_json(${implementationType}(${elementId}));
                END;
            `);
        
        }).to.throw(/JDC-00012/);
    
    });

    test("Push json value to an array, function version", function() {
    
        let valueId = createValue([
            "Hello, World!",
            123.456
        ]);

        let newElementId = createValue("Good bye, World!");

        let elementId = database.call(functionName, {
            p_value_id: valueId,
            p_element_id: newElementId
        });

        let parentId = database.selectValue(`
                ${implementationType}(${elementId}).get_parent().id
            FROM dual
        `);

        expect(parentId).to.be(valueId);

        let events = database.call(`${implementationPackage}.get_parse_events`, {
            p_value_id: valueId,
            p_serialize_nulls: true
        });

        expect(events).to.eql([
            "[",
            ":0",
            "SHello, World!",
            ":1",
            "N123.456",
            ":2",
            "SGood bye, World!",
            "]"
        ]);
        
    });
    
    test("Push json value to an array, procedure version", function() {
    
        let valueId = createValue([
            "Hello, World!",
            123.456
        ]);

        let elementId = createValue("Good bye, World!");

        database.run(`
            BEGIN
                ${implementationType}(${valueId}).push_json(${implementationType}(${elementId}));
            END;
        `);

        let events = database.call(`${implementationPackage}.get_parse_events`, {
            p_value_id: valueId,
            p_serialize_nulls: true
        });

        expect(events).to.eql([
            "[",
            ":0",
            "SHello, World!",
            ":1",
            "N123.456",
            ":2",
            "SGood bye, World!",
            "]"
        ]);
        
    });

    teardown("Drop the wrapper function", function() {
        
        database.run(`
            BEGIN
                EXECUTE IMMEDIATE 'DROP FUNCTION ${functionName}';                
            END;
        `);
    
    });
    
});