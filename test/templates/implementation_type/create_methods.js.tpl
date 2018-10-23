suite("Static CREATE_xxx methods", function() {

    let packageName = "P" + randomString(16);

    setup("Create a package for publishing created values", function() {
    
        database.run(`
            BEGIN
                EXECUTE IMMEDIATE '
                    CREATE PACKAGE ${packageName} IS
                        v_value t_json;
                        FUNCTION get_value_id
                        RETURN NUMBER;
                    END;
                ';
                EXECUTE IMMEDIATE '
                    CREATE PACKAGE BODY ${packageName} IS
                        FUNCTION get_value_id
                        RETURN NUMBER IS
                        BEGIN
                            RETURN v_value.id;
                        END;
                    END;
                ';
            END;
        `);
    
    });

    function getValueId() {
        return database.call(`${packageName}.get_value_id`);
    }

    test("Create a NULL string", function() {
    
        database.run(`
            BEGIN
                ${packageName}.v_value := ${implementationType}.create_string(NULL);   
            END;
        `);

        let events = database.call(`${implementationPackage}.get_parse_events`, {
            p_value_id: getValueId(),
            p_serialize_nulls: true
        });

        expect(events).to.eql([
            "S"
        ]);

    });

    test("Create a string", function() {
    
        database.run(`
            BEGIN
                ${packageName}.v_value := ${implementationType}.create_string('Hello, World!');   
            END;
        `);

        let events = database.call(`${implementationPackage}.get_parse_events`, {
            p_value_id: getValueId(),
            p_serialize_nulls: true
        });

        expect(events).to.eql([
            "SHello, World!"
        ]);

    });

    test("Create a NULL number", function() {
    
        database.run(`
            BEGIN
                ${packageName}.v_value := ${implementationType}.create_number(NULL);   
            END;
        `);

        let events = database.call(`${implementationPackage}.get_parse_events`, {
            p_value_id: getValueId(),
            p_serialize_nulls: true
        });

        expect(events).to.eql([
            "E"
        ]);

    });

    test("Create a number", function() {
    
        database.run(`
            BEGIN
                ${packageName}.v_value := ${implementationType}.create_number(123.456);   
            END;
        `);

        let events = database.call(`${implementationPackage}.get_parse_events`, {
            p_value_id: getValueId(),
            p_serialize_nulls: true
        });

        expect(events).to.eql([
            "N123.456"
        ]);

    });

    test("Create a NULL boolean", function() {
    
        database.run(`
            BEGIN
                ${packageName}.v_value := ${implementationType}.create_boolean(NULL);   
            END;
        `);

        let events = database.call(`${implementationPackage}.get_parse_events`, {
            p_value_id: getValueId(),
            p_serialize_nulls: true
        });

        expect(events).to.eql([
            "E"
        ]);

    });

    test("Create a boolean", function() {
    
        database.run(`
            BEGIN
                ${packageName}.v_value := ${implementationType}.create_boolean(TRUE);   
            END;
        `);

        let events = database.call(`${implementationPackage}.get_parse_events`, {
            p_value_id: getValueId(),
            p_serialize_nulls: true
        });

        expect(events).to.eql([
            "Btrue"
        ]);

    });

    test("Create a NULL date", function() {
    
        database.run(`
            BEGIN
                ${packageName}.v_value := ${implementationType}.create_date(NULL);   
            END;
        `);

        let events = database.call(`${implementationPackage}.get_parse_events`, {
            p_value_id: getValueId(),
            p_serialize_nulls: true
        });

        expect(events).to.eql([
            "E"
        ]);

    });

    test("Create a date", function() {
    
        database.run(`
            BEGIN
                ${packageName}.v_value := ${implementationType}.create_date(DATE '2017-10-25');   
            END;
        `);

        let events = database.call(`${implementationPackage}.get_parse_events`, {
            p_value_id: getValueId(),
            p_serialize_nulls: true
        });

        expect(events).to.eql([
            "S2017-10-25"
        ]);

    });

    test("Create a NULL", function() {
    
        database.run(`
            BEGIN
                ${packageName}.v_value := ${implementationType}.create_null;   
            END;
        `);

        let events = database.call(`${implementationPackage}.get_parse_events`, {
            p_value_id: getValueId(),
            p_serialize_nulls: true
        });

        expect(events).to.eql([
            "E"
        ]);

    });

    test("Create an object", function() {
    
        database.run(`
            BEGIN
                ${packageName}.v_value := ${implementationType}.create_object;   
            END;
        `);

        let events = database.call(`${implementationPackage}.get_parse_events`, {
            p_value_id: getValueId(),
            p_serialize_nulls: true
        });

        expect(events).to.eql([
            "{",
            "}"
        ]);

    });

    test("Create an array", function() {
    
        database.run(`
            BEGIN
                ${packageName}.v_value := ${implementationType}.create_array;   
            END;
        `);

        let events = database.call(`${implementationPackage}.get_parse_events`, {
            p_value_id: getValueId(),
            p_serialize_nulls: true
        });

        expect(events).to.eql([
            "[",
            "]"
        ]);

    });

    test("Create JSON from VARCHAR2", function() {
    
        database.run(`
            BEGIN
                ${packageName}.v_value := ${implementationType}.create_json('
                    {
                        "name": "Sergejs",
                        "surname": "Vinniks"
                    }
                ');   
            END;
        `);

        let events = database.call(`${implementationPackage}.get_parse_events`, {
            p_value_id: getValueId(),
            p_serialize_nulls: true
        });

        expect(events).to.eql([
            "{",
            ":name",
            "SSergejs",
            ":surname",
            "SVinniks",
            "}"
        ]);

    });

    test("Create JSON from CLOB", function() {
    
        database.run(`
            BEGIN
                ${packageName}.v_value := ${implementationType}.create_json(TO_CLOB('
                    {
                        "name": "Sergejs",
                        "surname": "Vinniks"
                    }
                '));   
            END;
        `);

        let events = database.call(`${implementationPackage}.get_parse_events`, {
            p_value_id: getValueId(),
            p_serialize_nulls: true
        });

        expect(events).to.eql([
            "{",
            ":name",
            "SSergejs",
            ":surname",
            "SVinniks",
            "}"
        ]);

    });

    test("Create JSON from another JSON value", function() {
    
        database.run(`
            BEGIN
                ${packageName}.v_value := ${implementationType}.create_json(
                    ${implementationType}.create_json('
                        {
                            "name": "Sergejs",
                            "surname": "Vinniks"
                        }
                    ')
                );
            END;
        `);

        let events = database.call(`${implementationPackage}.get_parse_events`, {
            p_value_id: getValueId(),
            p_serialize_nulls: true
        });

        expect(events).to.eql([
            "{",
            ":name",
            "SSergejs",
            ":surname",
            "SVinniks",
            "}"
        ]);

    });

    test("Create JSON from a JSON builder", function() {
    
        database.run(`
            BEGIN
                ${packageName}.v_value := ${implementationType}.create_json(
                    t_json_builder().object()
                        .name('name').value('Sergejs')
                        .name('surname').value('Vinniks')
                    .close()
                );
            END;
        `);

        let events = database.call(`${implementationPackage}.get_parse_events`, {
            p_value_id: getValueId(),
            p_serialize_nulls: true
        });

        expect(events).to.eql([
            "{",
            ":name",
            "SSergejs",
            ":surname",
            "SVinniks",
            "}"
        ]);

    });

    teardown("Drop the package", function() {
    
        database.run(`
            BEGIN
                EXECUTE IMMEDIATE 'DROP PACKAGE ${packageName}';    
            END;
        `);
    
    });
    
});