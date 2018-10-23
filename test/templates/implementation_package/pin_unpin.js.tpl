function createValue(value) {

    let events = database.call("json_parser.parse", {
        p_content: JSON.stringify(value)
    });

    return database.call(`${implementationPackage}.create_json`, {
        p_content_parse_events: events
    });

}

suite("PIN tests", function() {

    test("Try to pin a non-existing value", function() {
    
        expect(function() {
        
            database.call(`${implementationPackage}.pin_value`, {
                p_id: -1,
                p_pin_tree: false
            });
        
        }).to.throw(/JDC-00009/);
    
    });
    
    test("Pin a scalar value", function() {
    
        let valueId = createValue("Hello, World!");

        database.call(`${implementationPackage}.pin_value`, {
            p_id: valueId,
            p_pin_tree: false
        });

        let values = database.call(`${implementationPackage}.dump_value`, {
            p_id: valueId
        });

        expect(values[0].locked).to.be('T');
    
    });

    test("Pin a scalar value, pin tree", function() {
    
        let valueId = createValue("Hello, World!");

        database.call(`${implementationPackage}.pin_value`, {
            p_id: valueId,
            p_pin_tree: true
        });

        let values = database.call(`${implementationPackage}.dump_value`, {
            p_id: valueId
        });

        expect(values[0].locked).to.be('T');
    
    });

    test("Pin a property of an object", function() {
    
        let valueId = createValue({
            name: "Sergejs"
        });

        let propertyId = database.call(`${implementationPackage}.set_property`, {
            p_anchor_id: valueId,
            p_path: "surname",
            p_bind: null,
            p_content_parse_events: [
                "SVinniks"
            ]
        });

        database.call(`${implementationPackage}.pin_value`, {
            p_id: propertyId,
            p_pin_tree: false
        });

        let values = database.call(`${implementationPackage}.dump_value`, {
            p_id: valueId
        });

        expect(values[0].locked).to.be('T');
        expect(values[1].locked).to.be(null);
        expect(values[2].locked).to.be('T');
    
    });

    test("Pin a property of an object, pin tree", function() {
    
        let valueId = createValue({
            name: "Sergejs"
        });

        let propertyId = database.call(`${implementationPackage}.set_property`, {
            p_anchor_id: valueId,
            p_path: "surname",
            p_bind: null,
            p_content_parse_events: [
                "SVinniks"
            ]
        });

        database.call(`${implementationPackage}.pin_value`, {
            p_id: propertyId,
            p_pin_tree: true
        });

        let values = database.call(`${implementationPackage}.dump_value`, {
            p_id: valueId
        });

        expect(values[0].locked).to.be('T');
        expect(values[1].locked).to.be(null);
        expect(values[2].locked).to.be('T');
    
    });

    test("Pin an object with properties", function() {
    
        let valueId = createValue({
            name: "Sergejs",
            surname: "Vinniks"
        });

        database.call(`${implementationPackage}.pin_value`, {
            p_id: valueId,
            p_pin_tree: false
        });

        let values = database.call(`${implementationPackage}.dump_value`, {
            p_id: valueId
        });

        expect(values[0].locked).to.be('T');
        expect(values[1].locked).to.be(null);
        expect(values[2].locked).to.be(null);
    
    });

    test("Pin an object with properties, pin tree", function() {
    
        let valueId = createValue({
            name: "Sergejs",
            surname: "Vinniks"
        });

        database.call(`${implementationPackage}.pin_value`, {
            p_id: valueId,
            p_pin_tree: true
        });

        let values = database.call(`${implementationPackage}.dump_value`, {
            p_id: valueId
        });

        expect(values[0].locked).to.be('T');
        expect(values[1].locked).to.be('T');
        expect(values[2].locked).to.be('T');
    
    });

    test("Pin an object with multiple property levels, pin tree", function() {
    
        let valueId = createValue({
            name: "Sergejs",
            phones: [
                {
                    type: "home"
                }
            ]
        });

        database.call(`${implementationPackage}.pin_value`, {
            p_id: valueId,
            p_pin_tree: true
        });

        let values = database.call(`${implementationPackage}.dump_value`, {
            p_id: valueId
        });

        expect(values[0].locked).to.be('T');
        expect(values[1].locked).to.be('T');
        expect(values[2].locked).to.be('T');
        expect(values[1].locked).to.be('T');
        expect(values[2].locked).to.be('T');
    
    });

    test("Pin already pinned object with multiple property levels, pin tree", function() {
    
        let valueId = createValue({
            name: "Sergejs",
            phones: [
                {
                    type: "home"
                }
            ]
        });

        database.call(`${implementationPackage}.pin_value`, {
            p_id: valueId,
            p_pin_tree: false
        });

        database.call(`${implementationPackage}.pin_value`, {
            p_id: valueId,
            p_pin_tree: true
        });

        let values = database.call(`${implementationPackage}.dump_value`, {
            p_id: valueId
        });

        expect(values[0].locked).to.be('T');
        expect(values[1].locked).to.be('T');
        expect(values[2].locked).to.be('T');
        expect(values[1].locked).to.be('T');
        expect(values[2].locked).to.be('T');
    
    });
    
});

suite("UNPIN tests", function() {

    test("Try to unpin a non-existing value", function() {
    
        expect(function() {
        
            database.call(`${implementationPackage}.unpin_value`, {
                p_id: -1,
                p_unpin_tree: false
            });
        
        }).to.throw(/JDC-00009/);
    
    });

    test("Try to unpin the root", function() {
    
        let rootId = database.call(`${implementationPackage}.request_value `, {
            p_anchor_id: null,
            p_path: '$',
            p_bind: null
        });
    
        expect(function() {
        
            database.call(`${implementationPackage}.unpin_value`, {
                p_id: rootId,
                p_unpin_tree: false
            });
        
        }).to.throw(/JDC-00034/);

    });
    
    test("Unpin a scalar value", function() {
    
        let valueId = createValue("Hello, World!");

        database.call(`${implementationPackage}.pin_value`, {
            p_id: valueId,
            p_pin_tree: false
        });

        database.call(`${implementationPackage}.unpin_value`, {
            p_id: valueId,
            p_unpin_tree: false
        });

        let values = database.call(`${implementationPackage}.dump_value`, {
            p_id: valueId
        });

        expect(values[0].locked).to.be(null);
    
    });

    test("Unpin an object with all properties unpinned", function() {
    
        let valueId = createValue({
            name: "Sergejs",
            surname: "Vinniks"
        });

        database.call(`${implementationPackage}.pin_value`, {
            p_id: valueId,
            p_pin_tree: false
        });

        database.call(`${implementationPackage}.unpin_value`, {
            p_id: valueId,
            p_unpin_tree: false
        });

        let values = database.call(`${implementationPackage}.dump_value`, {
            p_id: valueId
        });

        expect(values[0].locked).to.be(null);
        expect(values[1].locked).to.be(null);
        expect(values[2].locked).to.be(null);
    
    });

    test("Try to unpin an object with a pinned property", function() {
    
        let valueId = createValue({
            name: "Sergejs"
        });

        let propertyId = database.call(`${implementationPackage}.set_property`, {
            p_anchor_id: valueId,
            p_path: "surname",
            p_bind: null,
            p_content_parse_events: [
                "SVinniks"
            ]
        });

        database.call(`${implementationPackage}.pin_value`, {
            p_id: propertyId,
            p_pin_tree: false
        });

        expect(function() {
        
            database.call(`${implementationPackage}.unpin_value`, {
                p_id: valueId,
                p_unpin_tree: false
            });
        
        }).to.throw(/JDC-00033/);
    
    });

    test("Unpin an object with all properties pinned, unpin tree", function() {
    
        let valueId = createValue({
            name: "Sergejs",
            surname: "Vinniks"
        });

        database.call(`${implementationPackage}.pin_value`, {
            p_id: valueId,
            p_pin_tree: true
        });

        database.call(`${implementationPackage}.unpin_value`, {
            p_id: valueId,
            p_unpin_tree: true
        });

        let values = database.call(`${implementationPackage}.dump_value`, {
            p_id: valueId
        });

        expect(values[0].locked).to.be(null);
        expect(values[1].locked).to.be(null);
        expect(values[2].locked).to.be(null);
    
    });

    test("Unpin an complex structure", function() {
    
        let valueId = createValue({
            name: "Sergejs",
            surname: "Vinniks",
            phones: [
                {
                    "type": "mobile",
                    "number": "1234567"
                }
            ]
        });

        database.call(`${implementationPackage}.pin_value`, {
            p_id: valueId,
            p_pin_tree: true
        });

        database.call(`${implementationPackage}.unpin_value`, {
            p_id: valueId,
            p_unpin_tree: true
        });

        let values = database.call(`${implementationPackage}.dump_value`, {
            p_id: valueId
        });

        expect(values[0].locked).to.be(null);
        expect(values[1].locked).to.be(null);
        expect(values[2].locked).to.be(null);
        expect(values[3].locked).to.be(null);
        expect(values[4].locked).to.be(null);
        expect(values[5].locked).to.be(null);
        expect(values[6].locked).to.be(null);
    
    });
    
});