function createValue(value) {

    let events = database.call("json_parser.parse", {
        p_content: JSON.stringify(value)
    });

    return database.call(`${implementationPackage}.create_json`, {
        p_content_parse_events: events
    });

} 

suite("CONTAINS tests", function() {

    let functionName = 'F' + randomString(16);

    setup("Create a wrapper function", function() {
        
        database.run(`
            BEGIN
                EXECUTE IMMEDIATE '
                    CREATE FUNCTION ${functionName} (
                        p_value_id IN NUMBER,
                        p_path IN VARCHAR2,
                        p_bind IN bind
                    )
                    RETURN BOOLEAN IS
                    BEGIN
                        RETURN ${implementationType}(p_value_id).contains(p_path, p_bind);
                    END;
                ';    
            END;
        `);
    
    });
    
    function createValue(value) {

        let events = database.call("json_parser.parse", {
            p_content: JSON.stringify(value)
        });

        return database.call(`${implementationPackage}.create_json`, {
            p_content_parse_events: events
        });

    } 

    test("Find existing property, no bind", function() {
    
        let valueId = createValue({
            name: "Sergejs",
            addresses: {
                home: {
                    city: "Riga"
                }
            }
        });

        let contains = database.call(functionName, {
            p_value_id: valueId,
            p_path: "addresses.home.city",
            p_bind: null
        });

        expect(contains).to.be(true);
    
    });
    
    test("Find existing property, bind", function() {
    
        let valueId = createValue({
            name: "Sergejs",
            addresses: {
                home: {
                    city: "Riga"
                }
            }
        });

        let contains = database.call(functionName, {
            p_value_id: valueId,
            p_path: "addresses.:kind.city",
            p_bind: ["home"]
        });

        expect(contains).to.be(true);
    
    });

    test("Find non-existing property, bind", function() {
    
        let valueId = createValue({
            name: "Sergejs",
            addresses: {
                home: {
                    city: "Riga"
                }
            }
        });

        let contains = database.call(functionName, {
            p_value_id: valueId,
            p_path: "addresses.:kind.city",
            p_bind: ["work"]
        });

        expect(contains).to.be(false);
    
    });

    teardown("Drop the wrapper function", function() {
    
        database.run(`
            BEGIN
                EXECUTE IMMEDIATE 'DROP FUNCTION ${functionName}';    
            END;
        `);
    
    });
    
});

suite("HAS tests", function() {

    let functionName = 'F' + randomString(16);

    setup("Create a wrapper function", function() {
        
        database.run(`
            BEGIN
                EXECUTE IMMEDIATE '
                    CREATE FUNCTION ${functionName} (
                        p_value_id IN NUMBER,
                        p_key IN VARCHAR2
                    )
                    RETURN BOOLEAN IS
                    BEGIN
                        RETURN ${implementationType}(p_value_id).has(p_key);
                    END;
                ';    
            END;
        `);
    
    });
    
    test("Find existing property, non-standard identifier key", function() {
    
        let valueId = createValue([
            1,
            2,
            3
        ]);

        let has = database.call(functionName, {
            p_value_id: valueId,
            p_key: "1"
        });

        expect(has).to.be(true);
    
    });
    
    test("Find non-existing property, non-standard identifier key", function() {
    
        let valueId = createValue([
            1,
            2,
            3
        ]);

        let has = database.call(functionName, {
            p_value_id: valueId,
            p_key: "10"
        });

        expect(has).to.be(false);
    
    });

    teardown("Drop the wrapper function", function() {
    
        database.run(`
            BEGIN
                EXECUTE IMMEDIATE 'DROP FUNCTION ${functionName}';    
            END;
        `);
    
    });
    
});

suite("INDEX_OF tests", function() {

    test("VARCHAR2 version, existing element, default P_FROM_INDEX", function() {
    
        let valueId = createValue([
            1,
            "Hello, World!",
            true,
            "Good bye, World!"
        ]);

        let indexOf = database.selectValue(`
                ${implementationType}(${valueId}).index_of('Good bye, World!')
            FROM dual
        `);

        expect(indexOf).to.be(3);
    
    });

    test("VARCHAR2 version, non-existing element, default P_FROM_INDEX", function() {
    
        let valueId = createValue([
            1,
            "Hello, World!",
            true,
            "Good bye, World!"
        ]);

        let indexOf = database.selectValue(`
                ${implementationType}(${valueId}).index_of('Sergejs')
            FROM dual
        `);

        expect(indexOf).to.be(-1);
    
    });

    test("VARCHAR2 version, non-existing element, P_FROM_INDEX greater than the lenght", function() {
    
        let valueId = createValue([
            1,
            "Hello, World!",
            true,
            "Good bye, World!"
        ]);

        let indexOf = database.selectValue(`
                ${implementationType}(${valueId}).index_of('Good bye, World!', 4)
            FROM dual
        `);

        expect(indexOf).to.be(-1);
    
    });

    test("NUMBER version, existing element, default P_FROM_INDEX", function() {
    
        let valueId = createValue([
            1,
            "Hello, World!",
            true,
            123.456
        ]);

        let indexOf = database.selectValue(`
                ${implementationType}(${valueId}).index_of(123.456)
            FROM dual
        `);

        expect(indexOf).to.be(3);
    
    });

    test("NUMBER version, non-existing element, default P_FROM_INDEX", function() {
    
        let valueId = createValue([
            1,
            "Hello, World!",
            true,
            123.456
        ]);

        let indexOf = database.selectValue(`
                ${implementationType}(${valueId}).index_of(654.321)
            FROM dual
        `);

        expect(indexOf).to.be(-1);
    
    });

    test("NUMBER version, non-existing element, P_FROM_INDEX greater than the lenght", function() {
    
        let valueId = createValue([
            1,
            "Hello, World!",
            true,
            123.456
        ]);

        let indexOf = database.selectValue(`
                ${implementationType}(${valueId}).index_of(123.456, 4)
            FROM dual
        `);

        expect(indexOf).to.be(-1);
    
    });

    test("DATE version, existing element, default P_FROM_INDEX", function() {
    
        let valueId = createValue([
            1,
            "Hello, World!",
            true,
            "2018-12-27"
        ]);

        let indexOf = database.selectValue(`
                ${implementationType}(${valueId}).index_of(DATE '2018-12-27')
            FROM dual
        `);

        expect(indexOf).to.be(3);
    
    });

    test("DATE version, non-existing element, default P_FROM_INDEX", function() {
    
        let valueId = createValue([
            1,
            "Hello, World!",
            true,
            "2018-12-27"
        ]);

        let indexOf = database.selectValue(`
                ${implementationType}(${valueId}).index_of(DATE '2019-12-27')
            FROM dual
        `);

        expect(indexOf).to.be(-1);
    
    });

    test("DATE version, non-existing element, P_FROM_INDEX greater than the lenght", function() {
    
        let valueId = createValue([
            1,
            "Hello, World!",
            true,
            "2018-12-27"
        ]);

        let indexOf = database.selectValue(`
                ${implementationType}(${valueId}).index_of(DATE '2018-12-27', 4)
            FROM dual
        `);

        expect(indexOf).to.be(-1);
    
    });

    let functionName = 'F' + randomString(16);

    setup("Create a wrapper function to call method with a boolean argument", function() {
    
        database.run(`
            BEGIN
                EXECUTE IMMEDIATE '
                    CREATE OR REPLACE FUNCTION ${functionName} (
                        p_value_id IN NUMBER,
                        p_value IN BOOLEAN,
                        p_from_index IN NUMBER
                    )
                    RETURN NUMBER IS
                    BEGIN
                        RETURN ${implementationType}(p_value_id).index_of(p_value, p_from_index);
                    END;
                ';    
            END;
        `);
    
    });
    
    test("BOOLEAN version, existing element, P_FROM_INDEX => 0", function() {
    
        let valueId = createValue([
            1,
            "Hello, World!",
            true,
            "2018-12-27"
        ]);

        let indexOf = database.call(functionName, {
            p_value_id: valueId,
            p_value: true,
            p_from_index: 0
        }); 

        expect(indexOf).to.be(2);
    
    });

    test("BOOLEAN version, non-existing element, P_FROM_INDEX => 0", function() {
    
        let valueId = createValue([
            1,
            "Hello, World!",
            true,
            "2018-12-27"
        ]);

        let indexOf = database.call(functionName, {
            p_value_id: valueId,
            p_value: false,
            p_from_index: 0
        }); 

        expect(indexOf).to.be(-1);
    
    });

    test("BOOLEAN version, non-existing element, P_FROM_INDEX greater than the lenght", function() {
    
        let valueId = createValue([
            1,
            "Hello, World!",
            true,
            "2018-12-27"
        ]);

        let indexOf = database.call(functionName, {
            p_value_id: valueId,
            p_value: true,
            p_from_index: 3
        }); 

        expect(indexOf).to.be(-1);
    
    });

    teardown("Drop the wrapper function", function() {
    
        database.run(`
            BEGIN
                EXECUTE IMMEDIATE 'DROP FUNCTION ${functionName}';    
            END;
        `);
    
    });

    test("NULL version, existing element, default P_FROM_INDEX", function() {
    
        let valueId = createValue([
            1,
            "Hello, World!",
            null,
            "Good bye, World!"
        ]);

        let indexOf = database.selectValue(`
                ${implementationType}(${valueId}).index_of_null()
            FROM dual
        `);

        expect(indexOf).to.be(2);
    
    });

    test("NULL version, non-existing element, default P_FROM_INDEX", function() {
    
        let valueId = createValue([
            1,
            "Hello, World!",
            true,
            "Good bye, World!"
        ]);

        let indexOf = database.selectValue(`
                ${implementationType}(${valueId}).index_of_null()
            FROM dual
        `);

        expect(indexOf).to.be(-1);
    
    });

    test("NULL version, non-existing element, P_FROM_INDEX greater than the lenght", function() {
    
        let valueId = createValue([
            1,
            "Hello, World!",
            null,
            "Good bye, World!"
        ]);

        let indexOf = database.selectValue(`
                ${implementationType}(${valueId}).index_of_null(3)
            FROM dual
        `);

        expect(indexOf).to.be(-1);
    
    });
    
});