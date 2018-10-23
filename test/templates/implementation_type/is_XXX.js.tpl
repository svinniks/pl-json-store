suite("Value type check tests", function() {

    suite("IS_STRING tests", function() {
    
        test("Check if a string is string", function() {
        
            let valueId = database.call(`${implementationPackage}.create_json`, {
                p_content_parse_events: [
                    "SHello, World!"
                ]
            });

            database.run(`
                BEGIN
                    IF ${implementationType}(${valueId}).is_string IS NULL
                       OR NOT ${implementationType}(${valueId}).is_string
                    THEN
                        raise_application_error(-20000, 'String reported as non-string!');
                    END IF;
                END;
            `);
        
        });

        test("Check if a non-string is string", function() {
        
            let valueId = database.call(`${implementationPackage}.create_json`, {
                p_content_parse_events: [
                    "{",
                    "}"
                ]
            });

            database.run(`
                BEGIN
                    IF ${implementationType}(${valueId}).is_string IS NULL
                       OR ${implementationType}(${valueId}).is_string
                    THEN
                        raise_application_error(-20000, 'Non-string reported as string!');
                    END IF;
                END;
            `);
        
        });
        
    });
    
    suite("IS_NUMBER tests", function() {
    
        test("Check if a number is number", function() {
        
            let valueId = database.call(`${implementationPackage}.create_json`, {
                p_content_parse_events: [
                    "N123.456"
                ]
            });

            database.run(`
                BEGIN
                    IF ${implementationType}(${valueId}).is_number IS NULL
                       OR NOT ${implementationType}(${valueId}).is_number
                    THEN
                        raise_application_error(-20000, 'Number reported as non-number!');
                    END IF;
                END;
            `);
        
        });

        test("Check if a non-number is number", function() {
        
            let valueId = database.call(`${implementationPackage}.create_json`, {
                p_content_parse_events: [
                    "{",
                    "}"
                ]
            });

            database.run(`
                BEGIN
                    IF ${implementationType}(${valueId}).is_number IS NULL
                       OR ${implementationType}(${valueId}).is_number
                    THEN
                        raise_application_error(-20000, 'Non-number reported as number!');
                    END IF;
                END;
            `);
        
        });
        
    });

    suite("IS_DATE tests", function() {
    
        test("Check if a date is date", function() {
        
            let valueId = database.call(`${implementationPackage}.create_json`, {
                p_content_parse_events: [
                    "S2018-12-28"
                ]
            });

            database.run(`
                BEGIN
                    IF ${implementationType}(${valueId}).is_date IS NULL
                       OR NOT ${implementationType}(${valueId}).is_date
                    THEN
                        raise_application_error(-20000, 'Date reported as non-date!');
                    END IF;
                END;
            `);
        
        });

        test("Check if a non-string is date", function() {
        
            let valueId = database.call(`${implementationPackage}.create_json`, {
                p_content_parse_events: [
                    "{",
                    "}"
                ]
            });

            database.run(`
                BEGIN
                    IF ${implementationType}(${valueId}).is_date IS NULL
                       OR ${implementationType}(${valueId}).is_date
                    THEN
                        raise_application_error(-20000, 'Non-string reported as date!');
                    END IF;
                END;
            `);
        
        });

        test("Check if a string with invalid format is date", function() {
        
            let valueId = database.call(`${implementationPackage}.create_json`, {
                p_content_parse_events: [
                    "SHello, World!"
                ]
            });

            database.run(`
                BEGIN
                    IF ${implementationType}(${valueId}).is_date IS NULL
                       OR ${implementationType}(${valueId}).is_date
                    THEN
                        raise_application_error(-20000, 'Incorrectly formatted date reported as date!');
                    END IF;
                END;
            `);
        
        });
        
    });

    suite("IS_BOOLEAN tests", function() {
    
        test("Check if a boolean is boolean", function() {
        
            let valueId = database.call(`${implementationPackage}.create_json`, {
                p_content_parse_events: [
                    "Btrue"
                ]
            });

            database.run(`
                BEGIN
                    IF ${implementationType}(${valueId}).is_boolean IS NULL
                       OR NOT ${implementationType}(${valueId}).is_boolean
                    THEN
                        raise_application_error(-20000, 'Boolean reported as non-boolean!');
                    END IF;
                END;
            `);
        
        });

        test("Check if a non-boolean is boolean", function() {
        
            let valueId = database.call(`${implementationPackage}.create_json`, {
                p_content_parse_events: [
                    "{",
                    "}"
                ]
            });

            database.run(`
                BEGIN
                    IF ${implementationType}(${valueId}).is_boolean IS NULL
                       OR ${implementationType}(${valueId}).is_boolean
                    THEN
                        raise_application_error(-20000, 'Non-boolean reported as boolean!');
                    END IF;
                END;
            `);
        
        });
        
    });

    suite("IS_NULL tests", function() {
    
        test("Check if a null is null", function() {
        
            let valueId = database.call(`${implementationPackage}.create_json`, {
                p_content_parse_events: [
                    "E"
                ]
            });

            database.run(`
                BEGIN
                    IF ${implementationType}(${valueId}).is_null IS NULL
                       OR NOT ${implementationType}(${valueId}).is_null
                    THEN
                        raise_application_error(-20000, 'Null reported as non-null!');
                    END IF;
                END;
            `);
        
        });

        test("Check if a non-null is null", function() {
        
            let valueId = database.call(`${implementationPackage}.create_json`, {
                p_content_parse_events: [
                    "{",
                    "}"
                ]
            });

            database.run(`
                BEGIN
                    IF ${implementationType}(${valueId}).is_null IS NULL
                       OR ${implementationType}(${valueId}).is_null
                    THEN
                        raise_application_error(-20000, 'Non-null reported as null!');
                    END IF;
                END;
            `);
        
        });
        
    });

    suite("IS_OBJECT tests", function() {
    
        test("Check if an object is object", function() {
        
            let valueId = database.call(`${implementationPackage}.create_json`, {
                p_content_parse_events: [
                    "{",
                    "}"
                ]
            });

            database.run(`
                BEGIN
                    IF ${implementationType}(${valueId}).is_object IS NULL
                       OR NOT ${implementationType}(${valueId}).is_object
                    THEN
                        raise_application_error(-20000, 'Object reported as non-object!');
                    END IF;
                END;
            `);
        
        });

        test("Check if the root is object", function() {
        
            database.run(`
                BEGIN
                    IF ${implementationType}('$').is_object IS NULL
                       OR NOT ${implementationType}('$').is_object
                    THEN
                        raise_application_error(-20000, 'Root reported as non-object!');
                    END IF;
                END;
            `);
        
        });

        test("Check if a non-object is object", function() {
        
            let valueId = database.call(`${implementationPackage}.create_json`, {
                p_content_parse_events: [
                    "[",
                    "]"
                ]
            });

            database.run(`
                BEGIN
                    IF ${implementationType}(${valueId}).is_object IS NULL
                       OR ${implementationType}(${valueId}).is_object
                    THEN
                        raise_application_error(-20000, 'Non-object reported as object!');
                    END IF;
                END;
            `);
        
        });
        
    });

    suite("IS_ARRAY tests", function() {
    
        test("Check if a null is null", function() {
        
            let valueId = database.call(`${implementationPackage}.create_json`, {
                p_content_parse_events: [
                    "[",
                    "]"
                ]
            });

            database.run(`
                BEGIN
                    IF ${implementationType}(${valueId}).is_array IS NULL
                       OR NOT ${implementationType}(${valueId}).is_array
                    THEN
                        raise_application_error(-20000, 'Array reported as non-array!');
                    END IF;
                END;
            `);
        
        });

        test("Check if a non-array is array", function() {
        
            let valueId = database.call(`${implementationPackage}.create_json`, {
                p_content_parse_events: [
                    "{",
                    "}"
                ]
            });

            database.run(`
                BEGIN
                    IF ${implementationType}(${valueId}).is_array IS NULL
                       OR ${implementationType}(${valueId}).is_array
                    THEN
                        raise_application_error(-20000, 'Non-array reported as array!');
                    END IF;
                END;
            `);
        
        });
        
    });

});