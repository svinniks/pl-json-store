function createValue(value) {

    let events = database.call("json_parser.parse", {
        p_content: JSON.stringify(value)
    });

    return database.call(`${implementationPackage}.create_json`, {
        p_content_parse_events: events
    });

}

suite("Parse event method tests", function() {

    let functionName = "F" + randomString(16);

    setup("Create a wrapper function", function() {
    
        database.run(`
            BEGIN
                EXECUTE IMMEDIATE '
                    CREATE OR REPLACE FUNCTION ${functionName} (
                        p_value_id IN NUMBER,
                        p_content_parse_events IN t_varchars
                    )
                    RETURN NUMBER IS
                        v_value ${implementationType};
                    BEGIN

                        v_value := ${implementationType}(p_value_id);
                        v_value.apply_json(p_content_parse_events);

                        RETURN v_value.id;

                    END;
                ';    
            END;
        `);
    
    });

    test("Apply equal anonymous string value", function() {
    
        let value = "Hello, World!";  

        let valueId = createValue(value);

        let appliedValueId = database.call(functionName, {
            p_value_id: valueId,
            p_content_parse_events: [
                "SHello, World!"
            ]
        });

        let appliedValue = JSON.parse(database.selectValue(`
                ${implementationType}(${appliedValueId}).as_json()
            FROM dual
        `));

        expect(appliedValueId).to.be(valueId);
        expect(appliedValue).to.be(value);
    
    });

    test("Apply equal anonymous number value", function() {
    
        let value = 123.456;  

        let valueId = createValue(value);

        let appliedValueId = database.call(functionName, {
            p_value_id: valueId,
            p_content_parse_events: [
                "N123.456"
            ]
        });

        let appliedValue = JSON.parse(database.selectValue(`
                ${implementationType}(${appliedValueId}).as_json()
            FROM dual
        `));

        expect(appliedValueId).to.be(valueId);
        expect(appliedValue).to.be(value);
    
    });

    test("Apply equal anonymous boolean value", function() {
    
        let value = true;  

        let valueId = createValue(value);

        let appliedValueId = database.call(functionName, {
            p_value_id: valueId,
            p_content_parse_events: [
                "Btrue"
            ]
        });

        let appliedValue = JSON.parse(database.selectValue(`
                ${implementationType}(${appliedValueId}).as_json()
            FROM dual
        `));

        expect(appliedValueId).to.be(valueId);
        expect(appliedValue).to.be(value);
    
    });

    test("Apply equal anonymous null value", function() {
    
        let value = null;  

        let valueId = createValue(value);

        let appliedValueId = database.call(functionName, {
            p_value_id: valueId,
            p_content_parse_events: [
                "E"
            ]
        });

        let appliedValue = JSON.parse(database.selectValue(`
                ${implementationType}(${appliedValueId}).as_json()
            FROM dual
        `));

        expect(appliedValueId).to.be(valueId);
        expect(appliedValue).to.be(value);
    
    });

    test("Apply non-equal anonymous string value", function() {
    
        let value = "Hello, World!";  

        let valueId = createValue(value);

        let appliedValueId = database.call(functionName, {
            p_value_id: valueId,
            p_content_parse_events: [
                "SGood bye, World!"
            ]
        });

        let appliedValue = JSON.parse(database.selectValue(`
                ${implementationType}(${appliedValueId}).as_json()
            FROM dual
        `));
        
        expect(appliedValue).to.be("Good bye, World!");
    
    });

    test("Apply number to an anonymous string", function() {
    
        let value = "Hello, World!";  

        let valueId = createValue(value);

        let appliedValueId = database.call(functionName, {
            p_value_id: valueId,
            p_content_parse_events: [
                "N123.456"
            ]
        });

        let appliedValue = JSON.parse(database.selectValue(`
                ${implementationType}(${appliedValueId}).as_json()
            FROM dual
        `));
        
        expect(appliedValue).to.be(123.456);
    
    });

    test("Apply null to an anonymous number", function() {
    
        let value = 123.456;  

        let valueId = createValue(value);

        let appliedValueId = database.call(functionName, {
            p_value_id: valueId,
            p_content_parse_events: [
                "E"
            ]
        });

        let appliedValue = JSON.parse(database.selectValue(`
                ${implementationType}(${appliedValueId}).as_json()
            FROM dual
        `));
        
        expect(appliedValue).to.be(null);
    
    });

    test("Apply equal string property value", function() {
    
        let value = {
            property: "Hello, World!"
        };  

        let valueId = createValue(value);

        let propertyId = database.call(`${implementationPackage}.request_value`, {
            p_anchor_id: valueId,
            p_path: "property",
            p_bind: null
        });

        let appliedValueId = database.call(functionName, {
            p_value_id: propertyId,
            p_content_parse_events: [
                "SHello, World!"
            ]
        });

        let appliedValue = JSON.parse(database.selectValue(`
                ${implementationType}(${valueId}).as_json()
            FROM dual
        `));

        expect(appliedValue).to.eql(value);
    
    });

    test("Apply equal null property value", function() {
    
        let value = {
            property: null
        };  

        let valueId = createValue(value);

        let propertyId = database.call(`${implementationPackage}.request_value`, {
            p_anchor_id: valueId,
            p_path: "property",
            p_bind: null
        });

        let appliedValueId = database.call(functionName, {
            p_value_id: propertyId,
            p_content_parse_events: [
                "E"
            ]
        });

        let appliedValue = JSON.parse(database.selectValue(`
                ${implementationType}(${valueId}).as_json()
            FROM dual
        `));

        expect(appliedValue).to.eql(value);
    
    });

    test("Apply non-equal string object property value", function() {
    
        let value = {
            property: "Hello, World!"
        };  

        let valueId = createValue(value);

        let propertyId = database.call(`${implementationPackage}.request_value`, {
            p_anchor_id: valueId,
            p_path: "property",
            p_bind: null
        });

        let appliedValueId = database.call(functionName, {
            p_value_id: propertyId,
            p_content_parse_events: [
                "SGood bye, World!"
            ]
        });

        let appliedValue = JSON.parse(database.selectValue(`
                ${implementationType}(${valueId}).as_json()
            FROM dual
        `));

        expect(appliedValue).to.eql({
            property: "Good bye, World!"
        });
    
    });

    test("Apply number to a string object property", function() {
    
        let value = {
            property: "Hello, World!"
        };  

        let valueId = createValue(value);

        let propertyId = database.call(`${implementationPackage}.request_value`, {
            p_anchor_id: valueId,
            p_path: "property",
            p_bind: null
        });

        let appliedValueId = database.call(functionName, {
            p_value_id: propertyId,
            p_content_parse_events: [
                "N123.456"
            ]
        });

        let appliedValue = JSON.parse(database.selectValue(`
                ${implementationType}(${valueId}).as_json()
            FROM dual
        `));

        expect(appliedValue).to.eql({
            property: 123.456
        });
    
    });

    test("Apply null to a number object property", function() {
    
        let value = {
            property: 123.456
        };  

        let valueId = createValue(value);

        let propertyId = database.call(`${implementationPackage}.request_value`, {
            p_anchor_id: valueId,
            p_path: "property",
            p_bind: null
        });

        let appliedValueId = database.call(functionName, {
            p_value_id: propertyId,
            p_content_parse_events: [
                "E"
            ]
        });

        let appliedValue = JSON.parse(database.selectValue(`
                ${implementationType}(${valueId}).as_json()
            FROM dual
        `));

        expect(appliedValue).to.eql({
            property: null
        });
    
    });

    test("Apply equal string array element", function() {
    
        let value = [
            123.456,
            "Hello, World!"
        ];  

        let valueId = createValue(value);

        let propertyId = database.call(`${implementationPackage}.request_value`, {
            p_anchor_id: valueId,
            p_path: "[1]",
            p_bind: null
        });

        let appliedValueId = database.call(functionName, {
            p_value_id: propertyId,
            p_content_parse_events: [
                "SHello, World!"
            ]
        });

        let appliedValue = JSON.parse(database.selectValue(`
                ${implementationType}(${valueId}).as_json()
            FROM dual
        `));

        expect(appliedValue).to.eql(value);
    
    });

    test("Apply equal null array element value", function() {
    
        let value = [
            123.456,
            null
        ];  

        let valueId = createValue(value);

        let propertyId = database.call(`${implementationPackage}.request_value`, {
            p_anchor_id: valueId,
            p_path: "[1]",
            p_bind: null
        });

        let appliedValueId = database.call(functionName, {
            p_value_id: propertyId,
            p_content_parse_events: [
                "E"
            ]
        });

        let appliedValue = JSON.parse(database.selectValue(`
                ${implementationType}(${valueId}).as_json()
            FROM dual
        `));

        expect(appliedValue).to.eql(value);
    
    });

    test("Apply non-equal string array element value", function() {
    
        let value = [
            123.456,
            "Hello, World!"
        ];  

        let valueId = createValue(value);

        let propertyId = database.call(`${implementationPackage}.request_value`, {
            p_anchor_id: valueId,
            p_path: "[1]",
            p_bind: null
        });

        let appliedValueId = database.call(functionName, {
            p_value_id: propertyId,
            p_content_parse_events: [
                "SGood bye, World!"
            ]
        });

        let appliedValue = JSON.parse(database.selectValue(`
                ${implementationType}(${valueId}).as_json()
            FROM dual
        `));

        expect(appliedValue).to.eql([
            123.456,
            "Good bye, World!"
        ]);
    
    });

    test("Apply number to a string array element", function() {
    
        let value = [
            123.456,
            "Hello, World!"
        ];  

        let valueId = createValue(value);

        let propertyId = database.call(`${implementationPackage}.request_value`, {
            p_anchor_id: valueId,
            p_path: "[1]",
            p_bind: null
        });

        let appliedValueId = database.call(functionName, {
            p_value_id: propertyId,
            p_content_parse_events: [
                "N654.321"
            ]
        });

        let appliedValue = JSON.parse(database.selectValue(`
                ${implementationType}(${valueId}).as_json()
            FROM dual
        `));

        expect(appliedValue).to.eql([
            123.456,
            654.321
        ]);
    
    });

    test("Apply null to a number array element", function() {
    
        let value = [
            "Hello, World!",
            123.456
        ];  

        let valueId = createValue(value);

        let propertyId = database.call(`${implementationPackage}.request_value`, {
            p_anchor_id: valueId,
            p_path: "[1]",
            p_bind: null
        });

        let appliedValueId = database.call(functionName, {
            p_value_id: propertyId,
            p_content_parse_events: [
                "E"
            ]
        });

        let appliedValue = JSON.parse(database.selectValue(`
                ${implementationType}(${valueId}).as_json()
            FROM dual
        `));

        expect(appliedValue).to.eql([
            "Hello, World!",
            null
        ]);
    
    });

    test("Apply object to an anonymous string", function() {
    
        let value = "Hello, World!";  

        let valueId = createValue(value);

        let appliedValueId = database.call(functionName, {
            p_value_id: valueId,
            p_content_parse_events: [
                "{",
                ":hello",
                "Sworld",
                "}"
            ]
        });

        let appliedValue = JSON.parse(database.selectValue(`
                ${implementationType}(${appliedValueId}).as_json()
            FROM dual
        `));

        expect(appliedValue).to.eql({
            hello: "world"
        });
    
    });

    test("Apply object to an anonymous array", function() {
    
        let value = [
            "hello",
            "world"
        ];  

        let valueId = createValue(value);

        let appliedValueId = database.call(functionName, {
            p_value_id: valueId,
            p_content_parse_events: [
                "{",
                ":hello",
                "Sworld",
                "}"
            ]
        });

        let appliedValue = JSON.parse(database.selectValue(`
                ${implementationType}(${appliedValueId}).as_json()
            FROM dual
        `));

        expect(appliedValue).to.eql({
            hello: "world"
        });
    
    });

    test("Apply array to an anonymous string", function() {
    
        let value = "Hello, World!";  

        let valueId = createValue(value);

        let appliedValueId = database.call(functionName, {
            p_value_id: valueId,
            p_content_parse_events: [
                "[",
                ":0",
                "Shello",
                ":1",
                "Sworld",
                "]"
            ]
        });

        let appliedValue = JSON.parse(database.selectValue(`
                ${implementationType}(${appliedValueId}).as_json()
            FROM dual
        `));

        expect(appliedValue).to.eql([
            "hello",
            "world"
        ]);
    
    });

    test("Apply array to an anonymous object", function() {
    
        let value = {
            hello: "world"
        };  

        let valueId = createValue(value);

        let appliedValueId = database.call(functionName, {
            p_value_id: valueId,
            p_content_parse_events: [
                "[",
                ":0",
                "Shello",
                ":1",
                "Sworld",
                "]"
            ]
        });

        let appliedValue = JSON.parse(database.selectValue(`
                ${implementationType}(${appliedValueId}).as_json()
            FROM dual
        `));

        expect(appliedValue).to.eql([
            "hello",
            "world"
        ]);
    
    });

    test("Apply object to a string object property", function() {
    
        let value = {
            property: "Hello, World!"
        };  

        let valueId = createValue(value);

        let propertyId = database.call(`${implementationPackage}.request_value`, {
            p_anchor_id: valueId,
            p_path: "property",
            p_bind: null
        });

        let appliedValueId = database.call(functionName, {
            p_value_id: propertyId,
            p_content_parse_events: [
                "{",
                ":hello",
                "Sworld",
                "}"
            ]
        });

        let appliedValue = JSON.parse(database.selectValue(`
                ${implementationType}(${valueId}).as_json()
            FROM dual
        `));

        expect(appliedValue).to.eql({
            property: {
                hello: "world"
            }
        });
    
    });

    test("Apply empty object to an object", function() {
    
        let value = {
            property: "Hello, World!"
        };  

        let valueId = createValue(value);

        let appliedValueId = database.call(functionName, {
            p_value_id: valueId,
            p_content_parse_events: [
                "{",
                "}"
            ]
        });

        let appliedValue = JSON.parse(database.selectValue(`
                ${implementationType}(${valueId}).as_json()
            FROM dual
        `));

        expect(appliedValueId).to.be(valueId);

        expect(appliedValue).to.eql({
            property: "Hello, World!"
        });
    
    });

    test("Apply empty array to an array", function() {
    
        let value = [
            "hello",
            "world"
        ];  

        let valueId = createValue(value);

        let appliedValueId = database.call(functionName, {
            p_value_id: valueId,
            p_content_parse_events: [
                "[",
                "]"
            ]
        });

        let appliedValue = JSON.parse(database.selectValue(`
                ${implementationType}(${valueId}).as_json()
            FROM dual
        `));

        expect(appliedValueId).to.be(valueId);

        expect(appliedValue).to.eql([
            "hello",
            "world"
        ]);
    
    });

    test("Apply object with one new string property to an object", function() {
    
        let value = {
            hello: "world"
        };  

        let valueId = createValue(value);

        let appliedValueId = database.call(functionName, {
            p_value_id: valueId,
            p_content_parse_events: [
                "{",
                ":goodBye",
                "Sworld",
                "}"
            ]
        });

        let appliedValue = JSON.parse(database.selectValue(`
                ${implementationType}(${valueId}).as_json()
            FROM dual
        `));

        expect(appliedValueId).to.be(valueId);

        expect(appliedValue).to.eql({
            hello: "world",
            goodBye: "world"
        });
    
    });

    test("Apply object with one new object property to an object", function() {
    
        let value = {
            hello: "world"
        };  

        let valueId = createValue(value);

        let appliedValueId = database.call(functionName, {
            p_value_id: valueId,
            p_content_parse_events: [
                "{",
                ":goodBye",
                "{",
                ":big",
                "Sworld",
                "}",
                "}"
            ]
        });

        let appliedValue = JSON.parse(database.selectValue(`
                ${implementationType}(${valueId}).as_json()
            FROM dual
        `));

        expect(appliedValueId).to.be(valueId);

        expect(appliedValue).to.eql({
            hello: "world",
            goodBye: {
                big: "world"
            }
        });
    
    });

    test("Apply object with multiple new string properties to an object", function() {
    
        let value = {
            hello: "world"
        };  

        let valueId = createValue(value);

        let appliedValueId = database.call(functionName, {
            p_value_id: valueId,
            p_content_parse_events: [
                "{",
                ":goodBye",
                "Sworld",
                ":sveiki",
                "Spasaule",
                ":howMany",
                "N123.456",
                "}"
            ]
        });

        let appliedValue = JSON.parse(database.selectValue(`
                ${implementationType}(${valueId}).as_json()
            FROM dual
        `));

        expect(appliedValueId).to.be(valueId);

        expect(appliedValue).to.eql({
            hello: "world",
            goodBye: "world",
            sveiki: "pasaule",
            howMany: 123.456
        });
    
    });

    test("Apply object with one new object property to an object", function() {
    
        let value = {
            hello: "world"
        };  

        let valueId = createValue(value);

        let appliedValueId = database.call(functionName, {
            p_value_id: valueId,
            p_content_parse_events: [
                "{",
                ":goodBye",
                "{",
                ":big",
                "Sworld",
                "}",
                "}"
            ]
        });

        let appliedValue = JSON.parse(database.selectValue(`
                ${implementationType}(${valueId}).as_json()
            FROM dual
        `));

        expect(appliedValueId).to.be(valueId);

        expect(appliedValue).to.eql({
            hello: "world",
            goodBye: {
                big: "world"
            }
        });
    
    });

    test("Apply object with multiple new simple and complex properties", function() {
    
        let value = {
            hello: "world"
        };  

        let valueId = createValue(value);

        let appliedValueId = database.call(functionName, {
            p_value_id: valueId,
            p_content_parse_events: [
                "{",
                ":goodBye",
                "{",
                ":big",
                "Sworld",
                "}",
                ":howMany",
                "N123.456",
                ":sveiki",
                "{",
                ":liela",
                "Spasaule",
                "}",
                "}"
            ]
        });

        let appliedValue = JSON.parse(database.selectValue(`
                ${implementationType}(${valueId}).as_json()
            FROM dual
        `));

        expect(appliedValueId).to.be(valueId);

        expect(appliedValue).to.eql({
            hello: "world",
            goodBye: {
                big: "world"
            },
            howMany: 123.456,
            sveiki: {
                liela: "pasaule"
            }
        });
    
    });

    test("Apply object with one existing equal string property to an object", function() {
    
        let value = {
            hello: "world"
        };  

        let valueId = createValue(value);

        let appliedValueId = database.call(functionName, {
            p_value_id: valueId,
            p_content_parse_events: [
                "{",
                ":hello",
                "Sworld",
                "}"
            ]
        });

        let appliedValue = JSON.parse(database.selectValue(`
                ${implementationType}(${valueId}).as_json()
            FROM dual
        `));

        expect(appliedValueId).to.be(valueId);

        expect(appliedValue).to.eql({
            hello: "world"
        });
    
    });

    test("Apply object with one existing non-equal string property to an object", function() {
    
        let value = {
            hello: "world"
        };  

        let valueId = createValue(value);

        let appliedValueId = database.call(functionName, {
            p_value_id: valueId,
            p_content_parse_events: [
                "{",
                ":hello",
                "Spasaule",
                "}"
            ]
        });

        let appliedValue = JSON.parse(database.selectValue(`
                ${implementationType}(${valueId}).as_json()
            FROM dual
        `));

        expect(appliedValueId).to.be(valueId);

        expect(appliedValue).to.eql({
            hello: "pasaule"
        });
    
    });

    test("Apply object with one existing non-equal complex property", function() {
    
        let value = {
            hello: "world"
        };  

        let valueId = createValue(value);

        let appliedValueId = database.call(functionName, {
            p_value_id: valueId,
            p_content_parse_events: [
                "{",
                ":hello",
                "{",
                ":big",
                "Sworld",
                "}",
                "}"
            ]
        });

        let appliedValue = JSON.parse(database.selectValue(`
                ${implementationType}(${valueId}).as_json()
            FROM dual
        `));

        expect(appliedValueId).to.be(valueId);

        expect(appliedValue).to.eql({
            hello: {
                big: "world"
            }
        });
    
    });

    teardown("Drop the wrapper funtion", function() {
    
        database.run(`
            BEGIN
                EXECUTE IMMEDIATE 'DROP FUNCTION ${functionName}';    
            END;
        `);    
    
    });
    
});