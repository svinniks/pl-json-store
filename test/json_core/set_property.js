suite("Named property creation", function() {

    test("Try setting property of a non-existing container", function() {
    
        let valueId = database.call("json_store.create_object");

        expect(function() {
        
            database.call("json_core.set_property", {
                p_path: `#${valueId}.address.city`,
                p_bind: null,
                p_content_parse_events: [{
                    name: "NULL",
                    value: null
                }]
            });
        
        }).to.throw(/JDOC-00007/);
    
    });
    
    test("Try setting property of a non-existing container, use bind variables", function() {
    
        let valueId = database.call("json_store.create_object");

        expect(function() {
        
            database.call("json_core.set_property", {
                p_path: `#id.address.city`,
                p_bind: [valueId],
                p_content_parse_events: [{
                    name: "NULL",
                    value: null
                }]
            });
        
        }).to.throw(/JDOC-00007/);
    
    });

    test("Try modifying a locked property", function() {
    
        let valueId = database.call("json_store.create_json", {
            p_content: {
                name: "Sergejs"
            }
        });

        database.update(`json_values
            SET locked = 'T'
            WHERE id = ${valueId + 1}
        `);

        expect(function() {
        
            database.call("json_core.set_property", {
                p_path: `#${valueId}.name`,
                p_bind: null,
                p_content_parse_events: [{
                    name: "NULL",
                    value: null
                }]
            });
        
        }).to.throw(/JDOC-00024/);
    
    });

    test("Try modifying property of a string", function() {
    
        let valueId = database.call("json_store.create_json", {
            p_content: {
                property: "Hello, World!"
            }
        });

        expect(function() {
        
            database.call("json_core.set_property", {
                p_path: `#${valueId}.property.property`,
                p_bind: null,
                p_content_parse_events: [{
                    name: "NULL",
                    value: null
                }]
            });
        
        }).to.throw(/JDOC-00008/);
    
    });

    test("Try modifying property of a number", function() {
    
        let valueId = database.call("json_store.create_json", {
            p_content: {
                property: 123.456
            }
        });

        expect(function() {
        
            database.call("json_core.set_property", {
                p_path: `#${valueId}.property.property`,
                p_bind: null,
                p_content_parse_events: [{
                    name: "NULL",
                    value: null
                }]
            });
        
        }).to.throw(/JDOC-00008/);
    
    });

    test("Try modifying property of a boolean", function() {
    
        let valueId = database.call("json_store.create_json", {
            p_content: {
                property: true
            }
        });

        expect(function() {
        
            database.call("json_core.set_property", {
                p_path: `#${valueId}.property.property`,
                p_bind: null,
                p_content_parse_events: [{
                    name: "NULL",
                    value: null
                }]
            });
        
        }).to.throw(/JDOC-00008/);
    
    });

    test("Try modifying property of a null", function() {
    
        let valueId = database.call("json_store.create_json", {
            p_content: {
                property: null
            }
        });

        expect(function() {
        
            database.call("json_core.set_property", {
                p_path: `#${valueId}.property.property`,
                p_bind: null,
                p_content_parse_events: [{
                    name: "NULL",
                    value: null
                }]
            });
        
        }).to.throw(/JDOC-00008/);
    
    });

    test("Set non-existing property of an object", function() {
    
        let valueId = database.call("json_store.create_object");

        database.call("json_core.set_property", {
            p_path: `#${valueId}.property`,
            p_bind: null,
            p_content_parse_events: [{
                name: "STRING",
                value: "Hello, World!"
            }]
        });

        let rows = database.selectRows(`
            type, name, value
            FROM json_values
            START WITH id = ${valueId}
            CONNECT BY PRIOR id = parent_id
        `);

        expect(rows).to.eql([
            ["O", null, null],
            ["S", "property", "Hello, World!"]
        ])
        
    });

    test("Modify existing property of an object", function() {
    
        let valueId = database.call("json_store.create_json", {
            p_content: {
                property: "Sveiki, Pasaule!"
            }
        });

        database.call("json_core.set_property", {
            p_path: `#${valueId}.property`,
            p_bind: null,
            p_content_parse_events: [{
                name: "STRING",
                value: "Hello, World!"
            }]
        });

        let rows = database.selectRows(`
            type, name, value
            FROM json_values
            START WITH id = ${valueId}
            CONNECT BY PRIOR id = parent_id
        `);

        expect(rows).to.eql([
            ["O", null, null],
            ["S", "property", "Hello, World!"]
        ])

        let dummy = database.selectValue(`
            1
            FROM json_values
            WHERE id = ${valueId + 1}
        `);

        expect(dummy).to.be(null);
        
    });

    test("Try setting array element with an invalid index", function() {
    
        let valueId = database.call("json_store.create_json", {
            p_content: []
        });

        expect(function() {
            
            let propertyId = database.call("json_core.set_property", {
                p_path: `#${valueId}["-1"]`,
                p_bind: null,
                p_content_parse_events: [{
                    name: "STRING",
                    value: "Hello, World!"
                }]
            });        
        
        }).to.throw(/JDOC-00013/);
    
    });
    
    test("Modify existing element of an array", function() {
    
        let valueId = database.call("json_store.create_json", {
            p_content: [1, 2, 3, 4, 5]
        });

        let propertyId = database.call("json_core.set_property", {
            p_path: `#${valueId}[2]`,
            p_bind: null,
            p_content_parse_events: [{
                name: "STRING",
                value: "Hello, World!"
            }]
        });
        
        let property = database.selectObject(`
            parent_id, type, name, value
            FROM json_values
            WHERE id = ${propertyId}
        `);

        expect(property).to.eql({
            parent_id: valueId,
            type: "S",
            name: "2",
            value: "Hello, World!"
        })
        
    });

    test("Add element to the end of an array", function() {
    
        let valueId = database.call("json_store.create_json", {
            p_content: [1, 2, 3, 4, 5]
        });

        let propertyId = database.call("json_core.set_property", {
            p_path: `#${valueId}[5]`,
            p_bind: null,
            p_content_parse_events: [{
                name: "NUMBER",
                value: "6"
            }]
        });
        
        let elements = database.selectRows(`
            type, name, value
            FROM json_values
            WHERE parent_id = ${valueId}
            ORDER BY TO_NUMBER(name)
        `);

        expect(elements).to.eql([
            ["N", "0", "1"],
            ["N", "1", "2"],
            ["N", "2", "3"],
            ["N", "3", "4"],
            ["N", "4", "5"],
            ["N", "5", "6"],
        ])
        
    });

    test("Add element further than the end of an array, fill the gap with nulls", function() {
    
        let valueId = database.call("json_store.create_json", {
            p_content: [1, 2, 3, 4, 5]
        });

        let propertyId = database.call("json_core.set_property", {
            p_path: `#${valueId}[8]`,
            p_bind: null,
            p_content_parse_events: [{
                name: "NUMBER",
                value: "9"
            }]
        });
        
        let elements = database.selectRows(`
            type, name, value
            FROM json_values
            WHERE parent_id = ${valueId}
            ORDER BY TO_NUMBER(name)
        `);

        expect(elements).to.eql([
            ["N", "0", "1"],
            ["N", "1", "2"],
            ["N", "2", "3"],
            ["N", "3", "4"],
            ["N", "4", "5"],
            ["E", "5", null],
            ["E", "6", null],
            ["E", "7", null],
            ["N", "8", "9"],
        ])
        
    });

    test("Modify existing property of an object, use P_PARENT_VALUE_ID version.", function() {
    
        let valueId = database.call("json_store.create_json", {
            p_content: {
                property: "Sveiki, Pasaule!"
            }
        });

        database.call2("json_core.set_property", {
            p_parent_value_id: valueId,
            p_path: `property`,
            p_bind: null,
            p_content_parse_events: [{
                name: "STRING",
                value: "Hello, World!"
            }]
        });

        let rows = database.selectRows(`
            type, name, value
            FROM json_values
            START WITH id = ${valueId}
            CONNECT BY PRIOR id = parent_id
        `);

        expect(rows).to.eql([
            ["O", null, null],
            ["S", "property", "Hello, World!"]
        ])

        let dummy = database.selectValue(`
            1
            FROM json_values
            WHERE id = ${valueId + 1}
        `);

        expect(dummy).to.be(null);
        
    });

});