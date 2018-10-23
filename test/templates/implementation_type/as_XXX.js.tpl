suite("AS_STRING tests", function() {

    test("Try to convert to string a non-existing value", function() {
    
        expect(function() {
        
            database.selectValue(`
                    ${implementationType}(-1).as_string()
                FROM dual
            `);
        
        }).to.throw(/JDC-00009/);
    
    });

    test("Try to convert object to string", function() {

        let valueId = database.call(`${implementationPackage}.create_json`, {
            p_content_parse_events: [
                "{",
                "}"
            ]
        });
    
        expect(function() {
        
            database.selectValue(`
                    ${implementationType}(${valueId}).as_string()
                FROM dual
            `);
        
        }).to.throw(/JDC-00010/);
    
    });
    
    test("Convert string value to string", function() {
    
        let valueId = database.call(`${implementationPackage}.create_json`, {
            p_content_parse_events: [
                "SHello, World!"
            ]
        });

        let value = database.selectValue(`
                ${implementationType}(${valueId}).as_string()
            FROM dual
        `);

        expect(value).to.be("Hello, World!");
    
    });
    
    test("Convert number value to string", function() {
    
        let valueId = database.call(`${implementationPackage}.create_json`, {
            p_content_parse_events: [
                "N123.456"
            ]
        });

        let value = database.selectValue(`
                ${implementationType}(${valueId}).as_string()
            FROM dual
        `);

        expect(value).to.be("123.456");
    
    });

    test("Convert null value to string", function() {
    
        let valueId = database.call(`${implementationPackage}.create_json`, {
            p_content_parse_events: [
                "E"
            ]
        });

        let value = database.selectValue(`
                ${implementationType}(${valueId}).as_string()
            FROM dual
        `);

        expect(value).to.be(null);
    
    });

});

suite("AS_NUMBER tests", function() {

    test("Try to convert to number a non-existing value", function() {
    
        expect(function() {
        
            database.selectValue(`
                    ${implementationType}(-1).as_number()
                FROM dual
            `);
        
        }).to.throw(/JDC-00009/);
    
    });

    test("Try to convert object to number", function() {

        let valueId = database.call(`${implementationPackage}.create_json`, {
            p_content_parse_events: [
                "{",
                "}"
            ]
        });
    
        expect(function() {
        
            database.selectValue(`
                    ${implementationType}(${valueId}).as_number()
                FROM dual
            `);
        
        }).to.throw(/JDC-00010/);
    
    });
    
    test("Convert number value to number", function() {
    
        let valueId = database.call(`${implementationPackage}.create_json`, {
            p_content_parse_events: [
                "N123.456"
            ]
        });

        let value = database.selectValue(`
                ${implementationType}(${valueId}).as_number()
            FROM dual
        `);

        expect(value).to.be(123.456);
    
    });
    
    test("Convert valid string value to number", function() {
    
        let valueId = database.call(`${implementationPackage}.create_json`, {
            p_content_parse_events: [
                "S123.456"
            ]
        });

        let value = database.selectValue(`
                ${implementationType}(${valueId}).as_number()
            FROM dual
        `);

        expect(value).to.be(123.456);
    
    });

    test("Try to convert invalid string value to number", function() {

        let valueId = database.call(`${implementationPackage}.create_json`, {
            p_content_parse_events: [
                "SHello, World!"
            ]
        });
    
        expect(function() {
        
            database.selectValue(`
                    ${implementationType}(${valueId}).as_number()
                FROM dual
            `);
        
        }).to.throw(/JDC-00010/);
    
    });

    test("Convert null value to number", function() {
    
        let valueId = database.call(`${implementationPackage}.create_json`, {
            p_content_parse_events: [
                "E"
            ]
        });

        let value = database.selectValue(`
                ${implementationType}(${valueId}).as_number()
            FROM dual
        `);

        expect(value).to.be(null);
    
    });

});

suite("AS_DATE tests", function() {

    test("Try to convert to date a non-existing value", function() {
    
        expect(function() {
        
            database.selectValue(`
                    ${implementationType}(-1).as_date()
                FROM dual
            `);
        
        }).to.throw(/JDC-00009/);
    
    });

    test("Try to convert object to date", function() {

        let valueId = database.call(`${implementationPackage}.create_json`, {
            p_content_parse_events: [
                "{",
                "}"
            ]
        });
    
        expect(function() {
        
            database.selectValue(`
                    ${implementationType}(${valueId}).as_date()
                FROM dual
            `);
        
        }).to.throw(/JDC-00010/);
    
    });
    
    test("Convert valid string value to date", function() {
    
        let valueId = database.call(`${implementationPackage}.create_json`, {
            p_content_parse_events: [
                "S2018-10-22"
            ]
        });

        let value = database.selectValue(`
                ${implementationType}(${valueId}).as_date()
            FROM dual
        `);

        expect(value).to.be("2018-10-22");
    
    });
    
    test("Try to convert invalid string value to date", function() {

        let valueId = database.call(`${implementationPackage}.create_json`, {
            p_content_parse_events: [
                "SHello, World!"
            ]
        });
    
        expect(function() {
        
            database.selectValue(`
                    ${implementationType}(${valueId}).as_date()
                FROM dual
            `);
        
        }).to.throw(/JDC-00010/);
    
    });

    test("Convert null value to date", function() {
    
        let valueId = database.call(`${implementationPackage}.create_json`, {
            p_content_parse_events: [
                "E"
            ]
        });

        let value = database.selectValue(`
                ${implementationType}(${valueId}).as_date()
            FROM dual
        `);

        expect(value).to.be(null);
    
    });

});

suite("AS_BOOLEAN tests", function() {

    test("Try to convert object to boolean", function() {

        let valueId = database.call(`${implementationPackage}.create_json`, {
            p_content_parse_events: [
                "{",
                "}"
            ]
        });
    
        expect(function() {
        
            database.run(`
                DECLARE
                    v_value BOOLEAN;
                BEGIN
                    v_value := ${implementationType}(${valueId}).as_boolean();
                END;
            `);
        
        }).to.throw(/JDC-00010/);
    
    });
    
    test("Convert TRUE booelan value to boolean", function() {
    
        let valueId = database.call(`${implementationPackage}.create_json`, {
            p_content_parse_events: [
                "Btrue"
            ]
        });

        database.run(`
            DECLARE
                v_value BOOLEAN;
            BEGIN
                v_value := ${implementationType}(${valueId}).as_boolean();
                IF v_value IS NULL OR NOT v_value THEN
                    raise_application_error(-20000, 'Expected TRUE!');
                END IF;
            END;
        `);
    
    });

    test("Convert FALSE booelan value to boolean", function() {
    
        let valueId = database.call(`${implementationPackage}.create_json`, {
            p_content_parse_events: [
                "Bfalse"
            ]
        });

        database.run(`
            DECLARE
                v_value BOOLEAN;
            BEGIN
                v_value := ${implementationType}(${valueId}).as_boolean();
                IF v_value IS NULL OR v_value THEN
                    raise_application_error(-20000, 'Expected FALSE!');
                END IF;
            END;
        `);
    
    });
    
    test("Convert null value to boolean", function() {
    
        let valueId = database.call(`${implementationPackage}.create_json`, {
            p_content_parse_events: [
                "E"
            ]
        });

        database.run(`
            DECLARE
                v_value BOOLEAN;
            BEGIN
                v_value := ${implementationType}(${valueId}).as_boolean();
                IF v_value IS NOT NULL THEN
                    raise_application_error(-20000, 'Expected NULL!');
                END IF;
            END;
        `);
    
    });

});

suite("AS_JSON tests", function() {

    let functionName = 'F' + randomString(16);

    setup("Create a wrapper function to call AS_JSON with BOOLEAN argument", function() {
    
        database.run(`
            BEGIN
                EXECUTE IMMEDIATE '
                    CREATE OR REPLACE FUNCTION ${functionName} (
                        p_value_id IN NUMBER,
                        p_serialize_nulls IN BOOLEAN
                    )
                    RETURN VARCHAR2 IS
                    BEGIN
                        RETURN ${implementationType}(p_value_id).as_json(p_serialize_nulls);
                    END;
                ';    
            END;
        `);
    
    });
    

    test("Try to serialize a non-existing value", function() {
    
        expect(function() {
        
            database.selectValue(`
                    ${implementationType}(-1).as_json()
                FROM dual
            `);

        }).to.throw(/JDC-00009/);
    
    });

    function createValue(value) {

        let events = database.call("json_parser.parse", {
            p_content: JSON.stringify(value)
        });

        return database.call(`${implementationPackage}.create_json`, {
            p_content_parse_events: events
        });

    }

    test("Serialize a simle object", function() {
    
        let value = {
            name: "Sergejs"
        };

        let valueId = createValue(value);

        let storedValue = JSON.parse(
            database.selectValue(`
                    ${implementationType}(${valueId}).as_json()
                FROM dual
            `)
        );

        expect(storedValue).to.eql(value);
    
    });

    test("Serialize object with nulls, default P_SERIALIZE_NULLS", function() {
    
        let value = {
            name: "Sergejs",
            surname: null,
            phones: [null, "29463756", null]
        };

        let valueId = createValue(value);

        let storedValue = JSON.parse(
            database.selectValue(`
                    ${implementationType}(${valueId}).as_json()
                FROM dual
            `)
        );

        expect(storedValue).to.eql(value);
    
    });

    test("Serialize object with nulls, P_SERIALIZE_NULLS => TRUE", function() {
    
        let value = {
            name: "Sergejs",
            surname: null,
            phones: [null, "29463756", null]
        };

        let valueId = createValue(value);

        let storedValue = JSON.parse(
            database.call(functionName, {
                p_value_id: valueId,
                p_serialize_nulls: true
            })
        );

        expect(storedValue).to.eql(value);
    
    });

    test("Serialize object with nulls, P_SERIALIZE_NULLS => FALSE", function() {
    
        let value = {
            name: "Sergejs",
            surname: null,
            phones: [null, "29463756", null]
        };

        let valueId = createValue(value);

        let result = database.call(`${implementationPackage}.get_parse_events`, {
            p_value_id: valueId,
            p_serialize_nulls: false
        });

        let storedValue = JSON.parse(
            database.call(functionName, {
                p_value_id: valueId,
                p_serialize_nulls: false
            })
        );

        expect(storedValue).to.eql({
            name: "Sergejs",
            phones: [null, "29463756"]
        });
    
    });

    teardown("Drop the wrapper function", function() {
    
        database.run(`
            BEGIN
                EXECUTE IMMEDIATE 'DROP FUNCTION ${functionName}';                
            END;
        `);
    
    });
    
});

suite("AS_JSON_CLOB tests", function() {

    let functionName = 'F' + randomString(16);

    setup("Create a wrapper function to call AS_JSON with BOOLEAN argument", function() {
    
        database.run(`
            BEGIN
                EXECUTE IMMEDIATE '
                    CREATE OR REPLACE FUNCTION ${functionName} (
                        p_value_id IN NUMBER,
                        p_serialize_nulls IN BOOLEAN
                    )
                    RETURN CLOB IS
                    BEGIN
                        RETURN ${implementationType}(p_value_id).as_json_clob(p_serialize_nulls);
                    END;
                ';    
            END;
        `);
    
    });
    
    test("Try to serialize a non-existing value", function() {
    
        expect(function() {
        
            database.selectValue(`
                    ${implementationType}(-1).as_json_clob()
                FROM dual
            `);

        }).to.throw(/JDC-00009/);
    
    });

    function createValue(value) {

        let events = database.call("json_parser.parse", {
            p_content: JSON.stringify(value)
        });

        return database.call(`${implementationPackage}.create_json`, {
            p_content_parse_events: events
        });

    }

    test("Serialize a simle object", function() {
    
        let value = {
            name: "Sergejs"
        };

        let valueId = createValue(value);

        let storedValue = JSON.parse(
            database.selectValue(`
                    ${implementationType}(${valueId}).as_json()
                FROM dual
            `)
        );

        expect(storedValue).to.eql(value);
    
    });

    test("Serialize object with nulls, default P_SERIALIZE_NULLS", function() {
    
        let value = {
            name: "Sergejs",
            surname: null,
            phones: [null, "29463756", null]
        };

        let valueId = createValue(value);

        let storedValue = JSON.parse(
            database.selectValue(`
                    ${implementationType}(${valueId}).as_json_clob()
                FROM dual
            `)
        );

        expect(storedValue).to.eql(value);
    
    });

    test("Serialize object with nulls, P_SERIALIZE_NULLS => TRUE", function() {
    
        let value = {
            name: "Sergejs",
            surname: null,
            phones: [null, "29463756", null]
        };

        let valueId = createValue(value);

        let storedValue = JSON.parse(
            database.call(functionName, {
                p_value_id: valueId,
                p_serialize_nulls: true
            })
        );

        expect(storedValue).to.eql(value);
    
    });

    test("Serialize object with nulls, P_SERIALIZE_NULLS => FALSE", function() {
    
        let value = {
            name: "Sergejs",
            surname: null,
            phones: [null, "29463756", null]
        };

        let valueId = createValue(value);

        let storedValue = JSON.parse(
            database.call(functionName, {
                p_value_id: valueId,
                p_serialize_nulls: false
            })
        );

        expect(storedValue).to.eql({
            name: "Sergejs",
            phones: [null, "29463756"]
        });
    
    });

    teardown("Drop the wrapper function", function() {
    
        database.run(`
            BEGIN
                EXECUTE IMMEDIATE 'DROP FUNCTION ${functionName}';                
            END;
        `);
    
    });
    
});