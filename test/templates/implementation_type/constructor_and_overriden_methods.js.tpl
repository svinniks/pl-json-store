function createValue(value) {

    let events = database.call("json_parser.parse", {
        p_content: JSON.stringify(value)
    });

    return database.call(`${implementationPackage}.create_json`, {
        p_content_parse_events: events
    });

}

suite("Constructor tests", function() {

    test("Try to create a value using NULL path", function() {
    
        expect(function() {
        
            database.run(`
                DECLARE
                    v_json t_json;
                BEGIN
                    v_json := ${implementationType}(NULL, NULL);
                END;
            `);
        
        }).to.throw(/JDC-00002/);
    
    });
    
    test("Try to create a non-existing value", function() {
    
        expect(function() {
        
            database.run(`
                DECLARE
                    v_json t_json;
                BEGIN
                    v_json := ${implementationType}('#999999999', NULL);
                END;
            `);
        
        }).to.throw(/JDC-00009/);
    
    });

    test("Create an existing value without bind", function() {
    
        let name = 'N' + randomString(16);

        let rootId = database.call(`${implementationPackage}.request_value`, {
            p_anchor_id: null,
            p_path: '$',
            p_bind: null
        });

        let createdId = database.call(`${implementationPackage}.set_property`, {
            p_anchor_id: rootId,
            p_path: name,
            p_bind: null,
            p_content_parse_events: [
                "{",
                ":name",
                "SSergejs",
                "}"
            ]
        });

        let requestedId = database.selectValue(`
                ${implementationType}('$.${name}').id
            FROM dual
        `);

        expect(requestedId).to.be(createdId);
    
    });
    
    test("Create an existing value with bind", function() {
    
        let name = 'N' + randomString(16);

        let rootId = database.call(`${implementationPackage}.request_value`, {
            p_anchor_id: null,
            p_path: '$',
            p_bind: null
        });

        let createdId = database.call(`${implementationPackage}.set_property`, {
            p_anchor_id: rootId,
            p_path: name,
            p_bind: null,
            p_content_parse_events: [
                "{",
                ":name",
                "SSergejs",
                "}"
            ]
        });

        let requestedId = database.selectValue(`
                ${implementationType}('$.:name', bind('${name}')).id
            FROM dual
        `);

        expect(requestedId).to.be(createdId);
    
    });

});

suite("DUMP tests", function() {
    
    let procedureName = 'P' + randomString(16);

    setup("Create a DUMP wrapper procedure", function() {
    
        database.run(`
            BEGIN
                EXECUTE IMMEDIATE '
                    CREATE OR REPLACE PROCEDURE ${procedureName} (
                        p_value_id IN NUMBER,
                        p_parent_id OUT NUMBER,
                        p_type OUT VARCHAR2,
                        p_name OUT VARCHAR2,
                        p_value OUT VARCHAR2
                    ) IS
                        v_parent_id NUMBER;
                        v_type CHAR;
                        v_name VARCHAR2(4000);
                        v_value VARCHAR2(4000);
                    BEGIN
                        ${implementationType}(p_value_id).dump(v_parent_id, v_type, v_name, v_value);
                        p_parent_id := v_parent_id;
                        p_type := v_type;
                        p_name := v_name;
                        p_value := v_value;
                    END;
                ';    
            END;
        `);
    
    });
    
    test("Try to dump a non-existing value", function() {
    
        expect(function() {
        
            database.call(procedureName, {
                p_value_id: -1                
            });
        
        }).to.throw(/JDC-00009/);
    
    });

    test("Dump an existing value", function() {
    
        let valueId = database.call(`${implementationPackage}.create_json`, {
            p_content_parse_events: [
                "SHello, World!"
            ]
        });

        let value = database.call(procedureName, {
            p_value_id: valueId
        });

        expect(value).to.eql({
            p_parent_id: null,
            p_type: "S",
            p_name: null,
            p_value: "Hello, World!"
        });
        
    });

    teardown("Drop the wrapped procedure", function() {
    
        database.run(`
            BEGIN
                EXECUTE IMMEDIATE 'DROP PROCEDURE ${procedureName}';    
            END;
        `);
    
    });
    
});

suite("GET_PARSE_EVENTS tests", function() {

    let functionName = "P" + randomString(16);

    setup("Create a wrapper function to get parse events", function() {
    
        database.run(`
            BEGIN
                EXECUTE IMMEDIATE '
                    CREATE OR REPLACE FUNCTION ${functionName} (
                        p_value_id IN NUMBER,
                        p_serialize_nulls IN BOOLEAN
                    )
                    RETURN t_varchars IS
                    BEGIN
                        RETURN ${implementationType}(p_value_id).get_parse_events(p_serialize_nulls);
                    END;
                ';    
            END;
        `);
    
    });

    test("Try to get parse events of a non-existing value", function() {
    
        expect(function() {
        
            database.call(functionName, {
                p_value_id: -1,
                p_serialize_nulls: true
            });
        
        }).to.throw(/JDC-00009/);
    
    });
    
    test("Get parse events of an existing value, P_SERIALIZE_NULLS => TRUE", function() {
    
        let valueId = database.call(`${implementationPackage}.create_json`, {
            p_content_parse_events: [
                "{",
                ":name",
                "SSergejs",
                ":surname",
                "E",
                "}"
            ]
        });

        let events = database.call(functionName, {
            p_value_id: valueId,
            p_serialize_nulls: true
        });
        
        expect(events).to.eql([
            "{",
            ":name",
            "SSergejs",
            ":surname",
            "E",
            "}"
        ]);

    });

    test("Get parse events, P_SERIALIZE_NULLS => FALSE", function() {
    
        let valueId = database.call(`${implementationPackage}.create_json`, {
            p_content_parse_events: [
                "{",
                ":name",
                "SSergejs",
                ":surname",
                "E",
                "}"
            ]
        });

        let events = database.call(functionName, {
            p_value_id: valueId,
            p_serialize_nulls: false
        });
        
        expect(events).to.eql([
            "{",
            ":name",
            "SSergejs",
            "}"
        ]);

    });

    teardown("Drop the wrapper function", function() {
    
        database.run(`
            BEGIN
                EXECUTE IMMEDIATE '
                    DROP FUNCTION ${functionName}
                ';    
            END;
        `);
    
    });
    
});

suite("GET_PARENT tests", function() {

    test("Try to get parent from a non-existing value", function() {
    
        expect(function() {
        
            database.selectValue(`
                    ${implementationType}(-1).get_parent().id
                FROM dual
            `);
        
        }).to.throw(/JDC-00009/);
    
    });

    test("Get a NULL parent", function() {
    
        let parentId = database.selectValue(`
                ${implementationType}('$').get_parent().id
            FROM dual
        `);

        expect(parentId).to.be(null);
        
    });
    
    test("Get a non-NULL parent", function() {
    
        let objectId = database.call(`${implementationPackage}.create_json`, {
            p_content_parse_events: [
                "{",
                "}"
            ]
        });

        let propertyId = database.call(`${implementationPackage}.set_property`, {
            p_anchor_id: objectId,
            p_path: "hello",
            p_bind: null,
            p_content_parse_events: [
                "Sworld"
            ]
        });

        let parentId = database.selectValue(`
                ${implementationType}(${propertyId}).get_parent().id
            FROM dual
        `);

        expect(parentId).to.be(objectId);
        
    });

});

suite("GET tests", function() {

    test("Get property of a non-existing value", function() {
    
        let valueId = database.selectValue(`
                ${implementationType}(-1).get('name').id
            FROM dual
        `);
    
        expect(valueId).to.be(null);

    });
    
    test("Get a non-existing property", function() {
    
        let objectId = database.call(`${implementationPackage}.create_json`, {
            p_content_parse_events: [
                "{",
                "}"
            ]
        });

        let propertyId = database.selectValue(`
                ${implementationType}(${objectId}).get('surname').id
            FROM dual
        `);
    
        expect(propertyId).to.be(null);

    });

    test("Get an existing property, no bind", function() {
    
        let objectId = database.call(`${implementationPackage}.create_json`, {
            p_content_parse_events: [
                "{",
                "}"
            ]
        });

        let propertyId = database.call(`${implementationPackage}.set_property`, {
            p_anchor_id: objectId,
            p_path: "name",
            p_bind: null,
            p_content_parse_events: [
                "SSergejs"
            ]
        });

        let requestedPropertyId = database.selectValue(`
                ${implementationType}(${objectId}).get('name').id
            FROM dual
        `);
    
        expect(requestedPropertyId).to.be(propertyId);

    });

    test("Get an existing property, bind", function() {
    
        let objectId = database.call(`${implementationPackage}.create_json`, {
            p_content_parse_events: [
                "{",
                "}"
            ]
        });

        let propertyId = database.call(`${implementationPackage}.set_property`, {
            p_anchor_id: objectId,
            p_path: "name",
            p_bind: null,
            p_content_parse_events: [
                "SSergejs"
            ]
        });

        let requestedPropertyId = database.selectValue(`
                ${implementationType}(${objectId}).get(':name', bind('name')).id
            FROM dual
        `);
    
        expect(requestedPropertyId).to.be(propertyId);

    });
    
});

suite("GET_KEYS tests", function() {

    test("Try to get keys of a non-existing value", function() {
    
        expect(function() {
        
            database.selectValues(`
                    *
                FROM TABLE(${implementationType}(-1).get_keys())
            `);
        
        }).to.throw(/JDC-00009/);
    
    });
    
    test("Get keys of an existing value", function() {

        let valueId = database.call(`${implementationPackage}.create_json`, {
            p_content_parse_events: [
                "{",
                ":surname",
                "SVinniks",
                ":name",
                "SSergejs",
                "}",
            ]
        });

        let keys = database.selectValues(`
                *
            FROM TABLE(${implementationType}(${valueId}).get_keys())
        `);
    
        expect(keys).to.eql([
            "name",
            "surname"
        ])

    });

});

suite("GET_LENGTH tests", function() {

    test("Try to get length of a non-existing array", function() {
    
        expect(function() {
        
            database.selectValue(`
                    ${implementationType}(-1).get_length()
                FROM dual
            `);
        
        }).to.throw(/JDC-00009/);
    
    });
    
    test("Get length of an existing array", function() {

        let valueId = database.call(`${implementationPackage}.create_json`, {
            p_content_parse_events: [
                "[",
                ":0",
                "SVinniks",
                ":1",
                "SSergejs",
                "]",
            ]
        });

        let length = database.selectValue(`
                ${implementationType}(${valueId}).get_length()
            FROM dual
        `);
    
        expect(length).to.be(2);

    });

});

suite("INDEX_OF tests", function() {

    test("Try to get index of an element of a non-existing array", function() {
    
        expect(function() {
        
            database.selectValue(`
                    ${implementationType}(-1).index_of('S', 'Hello, World!', 0)
                FROM dual
            `);
        
        }).to.throw(/JDC-00009/);
    
    });

    test("Get index of element starting with 0", function() {
    
        let valueId = database.call(`${implementationPackage}.create_json`, {
            p_content_parse_events: [
                "[",
                ":0",
                "SHello, World!",
                ":1",
                "SGood bye, World!",
                ":2",
                "SHello, World!",
                "]"
            ]
        });

        let index = database.selectValue(`
                ${implementationType}(${valueId}).index_of('S', 'Hello, World!', 0)
            FROM dual
        `);
    
        expect(index).to.be(0);

    });
    
    test("Get index of element starting with 1", function() {
    
        let valueId = database.call(`${implementationPackage}.create_json`, {
            p_content_parse_events: [
                "[",
                ":0",
                "SHello, World!",
                ":1",
                "SGood bye, World!",
                ":2",
                "SHello, World!",
                "]"
            ]
        });

        let index = database.selectValue(`
                ${implementationType}(${valueId}).index_of('S', 'Hello, World!', 1)
            FROM dual
        `);
    
        expect(index).to.be(2);

    });

});

suite("SET_JSON (with parse events) function tests", function() {

    let functionName = 'F' + randomString(16);

    setup("Create a wrapper function to call SET_JSON", function() {
    
        database.run(`
            BEGIN
                EXECUTE IMMEDIATE '
                    CREATE OR REPLACE FUNCTION ${functionName} (
                        p_value_id IN NUMBER,
                        p_path IN VARCHAR2,
                        p_bind IN bind,
                        p_content_parse_events IN t_varchars
                    )
                    RETURN NUMBER IS
                    BEGIN
                        RETURN ${implementationType}(p_value_id).set_json(
                            p_path,
                            p_content_parse_events,
                            p_bind
                        ).id;
                    END;
                ';    
            END;
        `);
    
    });

    test("Set property to an object, no bind", function() {
    
        let objectId = database.call(`${implementationPackage}.create_json`, {
            p_content_parse_events: [
                "{",
                ":name",
                "SSergejs",
                "}"
            ]
        });

        let propertyId = database.call(functionName, {
            p_value_id: objectId,
            p_path: "surname",
            p_bind: null,
            p_content_parse_events: [
                "SVinniks"
            ]
        });

        expect(propertyId).to.not.be(null);

        let events = database.call(`${implementationPackage}.get_parse_events`, {
            p_value_id: propertyId,
            p_serialize_nulls: true
        });

        expect(events).to.eql([
            "SVinniks"
        ]);

        let parentId = database.selectValue(`
                ${implementationType}(${propertyId}).get_parent().id
            FROM dual
        `);

        expect(parentId).to.be(objectId);

        let object = JSON.parse(
            database.selectValue(`
                    ${implementationType}(${objectId}).as_json()
                FROM dual
            `)
        );

        expect(object).to.eql({
            name: "Sergejs",
            surname: "Vinniks"
        });
    
    });
    
    test("Set property to an object, bind", function() {
    
        let objectId = database.call(`${implementationPackage}.create_json`, {
            p_content_parse_events: [
                "{",
                ":name",
                "SSergejs",
                "}"
            ]
        });

        let propertyId = database.call(functionName, {
            p_value_id: objectId,
            p_path: ":name",
            p_bind: ["surname"],
            p_content_parse_events: [
                "SVinniks"
            ]
        });

        expect(propertyId).to.not.be(null);

        let events = database.call(`${implementationPackage}.get_parse_events`, {
            p_value_id: propertyId,
            p_serialize_nulls: true
        });

        expect(events).to.eql([
            "SVinniks"
        ]);

        let parentId = database.selectValue(`
                ${implementationType}(${propertyId}).get_parent().id
            FROM dual
        `);

        expect(parentId).to.be(objectId);

        let object = JSON.parse(
            database.selectValue(`
                    ${implementationType}(${objectId}).as_json()
                FROM dual
            `)
        );

        expect(object).to.eql({
            name: "Sergejs",
            surname: "Vinniks"
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

suite("PIN tests", function() {

    test("Try to pin non-existing value", function() {
    
        expect(function() {
        
            database.run(`
                BEGIN
                    ${implementationType}(-1).pin;                    
                END;
            `);
        
        }).to.throw(/JDC-00009/);
    
    });
    
    test("Pin an object, default P_PIN_TREE", function() {
    
        let valueId = createValue({
            name: "Sergejs",
            surname: "Vinniks"
        });

        database.run(`
            BEGIN
                ${implementationType}(${valueId}).pin;    
            END;
        `);

        let values = database.call(`${implementationPackage}.dump_value`, {
            p_id: valueId
        });

        expect(values[0].locked).to.be('T');
        expect(values[1].locked).to.be(null);
        expect(values[2].locked).to.be(null);
        
    });
    
    test("Pin an object, P_PIN_TREE => FALSE", function() {
    
        let valueId = createValue({
            name: "Sergejs",
            surname: "Vinniks"
        });

        database.run(`
            BEGIN
                ${implementationType}(${valueId}).pin(FALSE);    
            END;
        `);

        let values = database.call(`${implementationPackage}.dump_value`, {
            p_id: valueId
        });

        expect(values[0].locked).to.be('T');
        expect(values[1].locked).to.be(null);
        expect(values[2].locked).to.be(null);

    });

    test("Pin an object, P_PIN_TREE => NULL", function() {
    
        let valueId = createValue({
            name: "Sergejs",
            surname: "Vinniks"
        });

        database.run(`
            BEGIN
                ${implementationType}(${valueId}).pin(NULL);    
            END;
        `);

        let values = database.call(`${implementationPackage}.dump_value`, {
            p_id: valueId
        });

        expect(values[0].locked).to.be('T');
        expect(values[1].locked).to.be(null);
        expect(values[2].locked).to.be(null);

    });

    test("Pin an object, P_PIN_TREE => TRUE", function() {
    
        let valueId = createValue({
            name: "Sergejs",
            surname: "Vinniks"
        });

        database.run(`
            BEGIN
                ${implementationType}(${valueId}).pin(TRUE);    
            END;
        `);

        let values = database.call(`${implementationPackage}.dump_value`, {
            p_id: valueId
        });

        expect(values[0].locked).to.be('T');
        expect(values[1].locked).to.be('T');
        expect(values[2].locked).to.be('T');

    });
    
});

suite("UNPIN tests", function() {

    test("Try to unpin non-existing value", function() {
    
        expect(function() {
        
            database.run(`
                BEGIN
                    ${implementationType}(-1).unpin;                    
                END;
            `);
        
        }).to.throw(/JDC-00009/);
    
    });
    
    test("Unpin an object, default P_UNPIN_TREE", function() {
    
        let valueId = createValue({
            name: "Sergejs",
            surname: "Vinniks"
        });

        database.run(`
            BEGIN
                ${implementationType}(${valueId}).pin(TRUE);    
            END;
        `);

        expect(function() {
        
            database.run(`
                BEGIN
                    ${implementationType}(${valueId}).unpin;    
                END;
            `); 
        
        }).to.throw(/JDC-00033/);

    });
    
    test("Unpin an object, P_UNPIN_TREE => FALSE", function() {
    
        let valueId = createValue({
            name: "Sergejs",
            surname: "Vinniks"
        });

        database.run(`
            BEGIN
                ${implementationType}(${valueId}).pin(TRUE);    
            END;
        `);

        expect(function() {
        
            database.run(`
                BEGIN
                    ${implementationType}(${valueId}).unpin(FALSE);    
                END;
            `); 
        
        }).to.throw(/JDC-00033/);

    });

    test("Unpin an object, P_UNPIN_TREE => NULL", function() {
    
        let valueId = createValue({
            name: "Sergejs",
            surname: "Vinniks"
        });

        database.run(`
            BEGIN
                ${implementationType}(${valueId}).pin(TRUE);    
            END;
        `);

        expect(function() {
        
            database.run(`
                BEGIN
                    ${implementationType}(${valueId}).unpin(NULL);    
                END;
            `); 
        
        }).to.throw(/JDC-00033/);

    });

    test("Unpin an object, P_UNPIN_TREE => TRUE", function() {
    
        let valueId = createValue({
            name: "Sergejs",
            surname: "Vinniks"
        });

        database.run(`
            BEGIN
                ${implementationType}(${valueId}).pin(TRUE);    
            END;
        `);

        database.run(`
            BEGIN
                ${implementationType}(${valueId}).unpin(TRUE);    
            END;
        `); 
        
        let values = database.call(`${implementationPackage}.dump_value`, {
            p_id: valueId
        });

        expect(values[0].locked).to.be(null);
        expect(values[1].locked).to.be(null);
        expect(values[2].locked).to.be(null);
    });

});

suite("REMOVE tests", function() {

    test("Try to delete non-existing value", function() {
    
        expect(function() {
        
            database.run(`
                DECLARE
                    v_value t_json;
                BEGIN
                    v_value := ${implementationType}(-1);                    
                    v_value.remove;
                END;
            `);
        
        }).to.throw(/JDC-00009/);
    
    });

    test("Delete a value", function() {
    
        let valueId = createValue("Hello, World!");

        database.run(`
            DECLARE
                v_value t_json;
            BEGIN

                v_value := ${implementationType}(${valueId});    
                v_value.remove;

                IF v_value.id IS NOT NULL THEN
                    raise_application_error(-20000, 'Expecting value ID to be set to NULL after deletion!');
                END IF;

            END;
        `);

        expect(function() {
        
            database.call(`${implementationPackage}.get_value`, {
                p_id: valueId
            });
        
        }).to.throw(/JDC-00009/);
    
    });
   
});