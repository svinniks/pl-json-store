function createValue(value) {

    let events = database.call("json_parser.parse", {
        p_content: JSON.stringify(value)
    });

    return database.call(`${implementationPackage}.create_json`, {
        p_content_parse_events: events
    });

}

suite("PIN tests", function() {

    test("Pin non-existing property", function() {
    
        let valueId = createValue({
            name: "Sergejs"
        });

        database.run(`
            BEGIN
                ${implementationType}(${valueId}).pin('surname');
            END;
        `);

        let values = database.call(`${implementationPackage}.dump_value`, {
            p_id: valueId
        });

        expect(values[0].locked).to.be(null);
        expect(values[1].locked).to.be(null);
    
    });
    
    test("Pin object property, default P_PIN_TREE, no bind", function() {
    
        let valueId = createValue({
            name: "Sergejs",
            address: {
                city: "Riga"
            }
        });

        database.run(`
            BEGIN
                ${implementationType}(${valueId}).pin('address');
            END;
        `);

        let values = database.call(`${implementationPackage}.dump_value`, {
            p_id: valueId
        });

        expect(values[0].locked).to.be('T');
        expect(values[1].locked).to.be('T');
        expect(values[2].locked).to.be(null);
        expect(values[3].locked).to.be(null);
    
    });

    test("Pin object property, default P_PIN_TREE, bind", function() {
    
        let valueId = createValue({
            name: "Sergejs",
            address: {
                city: "Riga"
            }
        });

        database.run(`
            BEGIN
                ${implementationType}(${valueId}).pin(':name', bind('address'));
            END;
        `);

        let values = database.call(`${implementationPackage}.dump_value`, {
            p_id: valueId
        });

        expect(values[0].locked).to.be('T');
        expect(values[1].locked).to.be('T');
        expect(values[2].locked).to.be(null);
        expect(values[3].locked).to.be(null);
    
    });
    
    test("Pin object property, P_PIN_TREE => FALSE, no bind", function() {
    
        let valueId = createValue({
            name: "Sergejs",
            address: {
                city: "Riga"
            }
        });

        database.run(`
            BEGIN
                ${implementationType}(${valueId}).pin('address', FALSE);
            END;
        `);

        let values = database.call(`${implementationPackage}.dump_value`, {
            p_id: valueId
        });

        expect(values[0].locked).to.be('T');
        expect(values[1].locked).to.be('T');
        expect(values[2].locked).to.be(null);
        expect(values[3].locked).to.be(null);
    
    });

    test("Pin object property, P_PIN_TREE => FALSE, bind", function() {
    
        let valueId = createValue({
            name: "Sergejs",
            address: {
                city: "Riga"
            }
        });

        database.run(`
            BEGIN
                ${implementationType}(${valueId}).pin(':name', FALSE, bind('address'));
            END;
        `);

        let values = database.call(`${implementationPackage}.dump_value`, {
            p_id: valueId
        });

        expect(values[0].locked).to.be('T');
        expect(values[1].locked).to.be('T');
        expect(values[2].locked).to.be(null);
        expect(values[3].locked).to.be(null);
    
    });

    test("Pin object property, P_PIN_TREE => TRUE, bind", function() {
    
        let valueId = createValue({
            name: "Sergejs",
            address: {
                city: "Riga"
            }
        });

        database.run(`
            BEGIN
                ${implementationType}(${valueId}).pin(':name', TRUE, bind('address'));
            END;
        `);

        let values = database.call(`${implementationPackage}.dump_value`, {
            p_id: valueId
        });

        expect(values[0].locked).to.be('T');
        expect(values[1].locked).to.be('T');
        expect(values[2].locked).to.be('T');
        expect(values[3].locked).to.be(null);
    
    });

    test("Pin array element, default P_PIN_TREE", function() {
    
        let valueId = createValue([
            "Sergejs",
            {
                city: "Riga"
            }
        ]);

        database.run(`
            BEGIN
                ${implementationType}(${valueId}).pin(1);
            END;
        `);

        let values = database.call(`${implementationPackage}.dump_value`, {
            p_id: valueId
        });

        expect(values[0].locked).to.be('T');
        expect(values[1].locked).to.be(null);
        expect(values[2].locked).to.be('T');
        expect(values[3].locked).to.be(null);
    
    });

    test("Pin array element, P_PIN_TREE => FALSE", function() {
    
        let valueId = createValue([
            "Sergejs",
            {
                city: "Riga"
            }
        ]);

        database.run(`
            BEGIN
                ${implementationType}(${valueId}).pin(1, FALSE);
            END;
        `);

        let values = database.call(`${implementationPackage}.dump_value`, {
            p_id: valueId
        });

        expect(values[0].locked).to.be('T');
        expect(values[1].locked).to.be(null);
        expect(values[2].locked).to.be('T');
        expect(values[3].locked).to.be(null);
    
    });

    test("Pin array element, P_PIN_TREE => TRUE", function() {
    
        let valueId = createValue([
            "Sergejs",
            {
                city: "Riga"
            }
        ]);

        database.run(`
            BEGIN
                ${implementationType}(${valueId}).pin(1, TRUE);
            END;
        `);

        let values = database.call(`${implementationPackage}.dump_value`, {
            p_id: valueId
        });

        expect(values[0].locked).to.be('T');
        expect(values[1].locked).to.be(null);
        expect(values[2].locked).to.be('T');
        expect(values[3].locked).to.be('T');
    
    });

});

suite("UNPIN tests", function() {

    test("Unpin non-existing property", function() {
    
        let valueId = createValue({
            name: "Sergejs"
        });

        database.run(`
            BEGIN
                ${implementationType}(${valueId}).pin(TRUE);
                ${implementationType}(${valueId}).unpin('surname');
            END;
        `);

        let values = database.call(`${implementationPackage}.dump_value`, {
            p_id: valueId
        });

        expect(values[0].locked).to.be('T');
        expect(values[1].locked).to.be('T');
    
    });
    
    test("Unpin object property, default P_UNPIN_TREE, no bind", function() {
    
        let valueId = createValue({
            name: "Sergejs",
            address: {
                city: "Riga"
            }
        });

        expect(function() {
        
            database.run(`
                BEGIN
                    ${implementationType}(${valueId}).pin('address', TRUE);
                    ${implementationType}(${valueId}).unpin('address');
                END;
            `);            
        
        }).to.throw(/JDC-00033/);
    
    });

    test("Unpin object property, default P_UNPIN_TREE, bind", function() {
    
        let valueId = createValue({
            name: "Sergejs",
            address: {
                city: "Riga"
            }
        });

        expect(function() {
        
            database.run(`
                BEGIN
                    ${implementationType}(${valueId}).pin(':name', TRUE, bind('address'));
                    ${implementationType}(${valueId}).unpin(':name', bind('address'));
                END;
            `);            
        
        }).to.throw(/JDC-00033/);
    
    });
    
    test("Unpin object property, P_UNPIN_TREE => FALSE, no bind", function() {
    
        let valueId = createValue({
            name: "Sergejs",
            address: {
                city: "Riga"
            }
        });

        expect(function() {
        
            database.run(`
                BEGIN
                    ${implementationType}(${valueId}).pin('address', TRUE);
                    ${implementationType}(${valueId}).unpin('address', FALSE);
                END;
            `);            
        
        }).to.throw(/JDC-00033/);
    
    });

    test("Unpin object property, P_UNPIN_TREE => FALSE, bind", function() {
    
        let valueId = createValue({
            name: "Sergejs",
            address: {
                city: "Riga"
            }
        });

        expect(function() {
        
            database.run(`
                BEGIN
                    ${implementationType}(${valueId}).pin(':name', TRUE, bind('address'));
                    ${implementationType}(${valueId}).unpin(':name', FALSE, bind('address'));
                END;
            `);            
        
        }).to.throw(/JDC-00033/);

    });

    test("Unpin object property, P_UNPIN_TREE => TRUE, bind", function() {
    
        let valueId = createValue({
            name: "Sergejs",
            address: {
                city: "Riga"
            }
        });

        database.run(`
            BEGIN
                ${implementationType}(${valueId}).pin(':name', TRUE, bind('address'));
                ${implementationType}(${valueId}).unpin(':name', TRUE, bind('address'));
            END;
        `);

        let values = database.call(`${implementationPackage}.dump_value`, {
            p_id: valueId
        });

        expect(values[0].locked).to.be('T');
        expect(values[1].locked).to.be(null);
        expect(values[2].locked).to.be(null);
        expect(values[3].locked).to.be(null);
    
    });

    test("Unpin array element, default P_UNPIN_TREE", function() {
    
        let valueId = createValue([
            "Sergejs",
            {
                city: "Riga"
            }
        ]);

        expect(function() {
            
            database.run(`
                BEGIN
                    ${implementationType}(${valueId}).pin(1, TRUE);
                    ${implementationType}(${valueId}).unpin(1, FALSE);
                END;
            `);
        
        }).to.throw(/JDC-00033/);
    
    });

    test("Unpin array element, P_UNPIN_TREE => FALSE", function() {
    
        let valueId = createValue([
            "Sergejs",
            {
                city: "Riga"
            }
        ]);

        expect(function() {
            
            database.run(`
                BEGIN
                    ${implementationType}(${valueId}).pin(1, TRUE);
                    ${implementationType}(${valueId}).unpin(1, FALSE);
                END;
            `);
        
        }).to.throw(/JDC-00033/);
    
    });

    test("Unpin array element, P_UNPIN_TREE => TRUE", function() {
    
        let valueId = createValue([
            "Sergejs",
            {
                city: "Riga"
            }
        ]);

        database.run(`
            BEGIN
                ${implementationType}(${valueId}).pin(1, TRUE);
                ${implementationType}(${valueId}).unpin(1, TRUE);
            END;
        `);

        let values = database.call(`${implementationPackage}.dump_value`, {
            p_id: valueId
        });

        expect(values[0].locked).to.be('T');
        expect(values[1].locked).to.be(null);
        expect(values[2].locked).to.be(null);
        expect(values[3].locked).to.be(null);
    
    });

});