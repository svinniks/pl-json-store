function createValue(value) {

    let events = database.call("json_parser.parse", {
        p_content: JSON.stringify(value)
    });

    return database.call(`${implementationPackage}.create_json`, {
        p_content_parse_events: events
    });

}

suite("Property value requests", function() {

    test("Request property of a NULL parent ID", function() {
    
        let propertyId = database.call(`${implementationPackage}.request_property_value`, {
            p_parent_id: null,
            p_name: "name"
        });

        expect(propertyId).to.be(null);
    
    });

    test("Request property of a non-existing parent", function() {
    
        let propertyId = database.call(`${implementationPackage}.request_property_value`, {
            p_parent_id: -1,
            p_name: "name"
        });

        expect(propertyId).to.be(null);
    
    });
    
    test("Request property of a scalar", function() {
    
        let valueId = createValue("Hello, World!");

        let propertyId = database.call(`${implementationPackage}.request_property_value`, {
            p_parent_id: -1,
            p_name: "name"
        });

        expect(propertyId).to.be(null);
    
    });

    test("Request non-existing property of an object", function() {
    
        let valueId = createValue({
            name: "Sergejs"
        });

        let propertyId = database.call(`${implementationPackage}.request_property_value`, {
            p_parent_id: valueId,
            p_name: "surname"
        });

        expect(propertyId).to.be(null);
    
    });

    test("Request existing property of an object", function() {
    
        let valueId = createValue({
            name: "Sergejs"
        });

        let propertyId = database.call(`${implementationPackage}.request_property_value`, {
            p_parent_id: valueId,
            p_name: "name"
        });

        expect(propertyId).to.be(valueId + 1);
    
    });

    test("Request non-existing element of an array", function() {
    
        let valueId = createValue([
            "Hello, World!",
            123.456
        ]);

        let propertyId = database.call(`${implementationPackage}.request_property_value`, {
            p_parent_id: valueId,
            p_name: "3"
        });

        expect(propertyId).to.be(null);
    
    });

    test("Request existing property element of an array", function() {
    
        let valueId = createValue([
            "Hello, World!",
            123.456
        ]);


        let propertyId = database.call(`${implementationPackage}.request_property_value`, {
            p_parent_id: valueId,
            p_name: 1
        });

        expect(propertyId).to.be(valueId + 2);
    
    });

});