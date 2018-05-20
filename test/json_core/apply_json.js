suite("JSON applying tests", function() {

    suite("Applying to anonymous scalars", function() {

        test("Try to apply to an anonymous string", function() {
        
            let valueId = database.call("json_store.create_string", {
                p_value: "Hello, World!"
            });

            let parseEvents = database.call("json_parser.parse", {
                p_content: JSON.stringify("Good bye, World!")
            }).p_parse_events;

            expect(function() {
            
                database.call("json_core.apply_json", {
                    p_value_id: valueId,
                    p_content_parse_events: parseEvents,
                    p_check_types: true
                });
            
            }).to.throw(/JDOC-00042/);
        
        });

        test("Try to apply to an anonymous number", function() {
        
            let valueId = database.call("json_store.create_number", {
                p_value: 123.321
            });

            let parseEvents = database.call("json_parser.parse", {
                p_content: JSON.stringify("Good bye, World!")
            }).p_parse_events;

            expect(function() {
            
                database.call("json_core.apply_json", {
                    p_value_id: valueId,
                    p_content_parse_events: parseEvents,
                    p_check_types: true
                });
            
            }).to.throw(/JDOC-00042/);
        
        });

        test("Try to apply to an anonymous boolean", function() {
        
            let valueId = database.call("json_store.create_boolean", {
                p_value: true
            });

            let parseEvents = database.call("json_parser.parse", {
                p_content: JSON.stringify("Good bye, World!")
            }).p_parse_events;

            expect(function() {
            
                database.call("json_core.apply_json", {
                    p_value_id: valueId,
                    p_content_parse_events: parseEvents,
                    p_check_types: true
                });
            
            }).to.throw(/JDOC-00042/);
        
        });

        test("Try to apply to an anonymous null", function() {
        
            let valueId = database.call("json_store.create_null");

            let parseEvents = database.call("json_parser.parse", {
                p_content: JSON.stringify("Good bye, World!")
            }).p_parse_events;

            expect(function() {
            
                database.call("json_core.apply_json", {
                    p_value_id: valueId,
                    p_content_parse_events: parseEvents,
                    p_check_types: true
                });
            
            }).to.throw(/JDOC-00042/);
        
        });

    });

    suite("Applying strings", function() {
    
        test("Try to apply string property to the root", function() {
        
            let parseEvents = database.call("json_parser.parse", {
                p_content: JSON.stringify("Hello, World!")
            }).p_parse_events;

            expect(function() {
            
                database.call("json_core.apply_json", {
                    p_value_id: 0,
                    p_content_parse_events: parseEvents,
                    p_check_types: false
                });
            
            }).to.throw(/JDOC-00044/);
            
        });

        test("Try to apply string property to an anonymous object", function() {
        
            let objectId = database.call("json_store.create_object");

            let parseEvents = database.call("json_parser.parse", {
                p_content: JSON.stringify("Hello, World!")
            }).p_parse_events;

            expect(function() {
            
                database.call("json_core.apply_json", {
                    p_value_id: objectId,
                    p_content_parse_events: parseEvents,
                    p_check_types: false
                });
            
            }).to.throw(/JDOC-00043/);
            
        });

        test("Try to apply string property to an anonymous array", function() {
        
            let objectId = database.call("json_store.create_array");

            let parseEvents = database.call("json_parser.parse", {
                p_content: JSON.stringify("Hello, World!")
            }).p_parse_events;

            expect(function() {
            
                database.call("json_core.apply_json", {
                    p_value_id: objectId,
                    p_content_parse_events: parseEvents,
                    p_check_types: false
                });
            
            }).to.throw(/JDOC-00043/);
            
        });

        test("Try to apply string property to a locked string property with different value", function() {
        
            let objectId = database.call("json_store.create_object");

            let valueId = database.call("json_store.set_string", {
                p_path: "#id.hello",
                p_value: "world",
                p_bind: [objectId]
            });

            database.call('json_core.pin', {
                p_value_id: valueId,
                p_pin_tree: false
            });

            let parseEvents = database.call("json_parser.parse", {
                p_content: JSON.stringify("people")
            }).p_parse_events;

            expect(function() {
            
                database.call("json_core.apply_json", {
                    p_value_id: valueId,
                    p_content_parse_events: parseEvents,
                    p_check_types: true
                });                
            
            }).to.throw(/JDOC-00024/);

        });

        test("Apply non-NULL string property to a non-NULL string property with the same value", function() {
        
            let objectId = database.call("json_store.create_object");

            let valueId = database.call("json_store.set_string", {
                p_path: "#id.hello",
                p_value: "world",
                p_bind: [objectId]
            });

            let parseEvents = database.call("json_parser.parse", {
                p_content: JSON.stringify("world")
            }).p_parse_events;

            let applyValueId = database.call("json_core.apply_json", {
                p_value_id: valueId,
                p_content_parse_events: parseEvents,
                p_check_types: true
            });

            expect(applyValueId).to.be(valueId);

            let newValueId = database.call("json_core.request_value", {
                p_path: "#id.hello",
                p_bind: [objectId]
            });

            expect(newValueId).to.be(valueId);
        
        });
        
        test("Apply NULL string property to a NULL string property", function() {
        
            let objectId = database.call("json_store.create_object");

            let valueId = database.call("json_store.set_string", {
                p_path: "#id.hello",
                p_value: "",
                p_bind: [objectId]
            });

            let parseEvents = database.call("json_parser.parse", {
                p_content: JSON.stringify("")
            }).p_parse_events;

            let applyValueId = database.call("json_core.apply_json", {
                p_value_id: valueId,
                p_content_parse_events: parseEvents,
                p_check_types: true
            });

            expect(applyValueId).to.be(valueId);

            let newValueId = database.call("json_core.request_value", {
                p_path: "#id.hello",
                p_bind: [objectId]
            });

            expect(newValueId).to.be(valueId);
        
        });

        test("Apply NULL string property to a non-NULL string property", function() {
        
            let objectId = database.call("json_store.create_object");

            let valueId = database.call("json_store.set_string", {
                p_path: "#id.hello",
                p_value: "world",
                p_bind: [objectId]
            });

            let parseEvents = database.call("json_parser.parse", {
                p_content: JSON.stringify("")
            }).p_parse_events;

            let applyValueId = database.call("json_core.apply_json", {
                p_value_id: valueId,
                p_content_parse_events: parseEvents,
                p_check_types: true
            });

            valueId = database.call2("json_core.request_value", {
                p_parent_value_id: objectId,
                p_path: "hello",
                p_bind: null
            });

            expect(applyValueId).to.be(valueId);

            let object = database.call("json_store.get_json", {
                p_path: "#id",
                p_bind: [objectId]
            });

            expect(object).to.eql({
                hello: ""
            });
        
        });

        test("Apply non-NULL string property to a NULL string property", function() {
        
            let objectId = database.call("json_store.create_object");

            let valueId = database.call("json_store.set_string", {
                p_path: "#id.hello",
                p_value: "",
                p_bind: [objectId]
            });

            let parseEvents = database.call("json_parser.parse", {
                p_content: JSON.stringify("world")
            }).p_parse_events;

            let applyValueId = database.call("json_core.apply_json", {
                p_value_id: valueId,
                p_content_parse_events: parseEvents,
                p_check_types: true
            });

            valueId = database.call2("json_core.request_value", {
                p_parent_value_id: objectId,
                p_path: "hello",
                p_bind: null
            });

            expect(applyValueId).to.be(valueId);

            let object = database.call("json_store.get_json", {
                p_path: "#id",
                p_bind: [objectId]
            });

            expect(object).to.eql({
                hello: "world"
            });
        
        });

        test("Apply non-NULL string property to a non-NULL string property with a different value", function() {
        
            let objectId = database.call("json_store.create_object");

            let valueId = database.call("json_store.set_string", {
                p_path: "#id.hello",
                p_value: "world",
                p_bind: [objectId]
            });

            let parseEvents = database.call("json_parser.parse", {
                p_content: JSON.stringify("people")
            }).p_parse_events;

            let applyValueId = database.call("json_core.apply_json", {
                p_value_id: valueId,
                p_content_parse_events: parseEvents,
                p_check_types: true
            });

            valueId = database.call2("json_core.request_value", {
                p_parent_value_id: objectId,
                p_path: "hello",
                p_bind: null
            });

            expect(applyValueId).to.be(valueId);

            let object = database.call("json_store.get_json", {
                p_path: "#id",
                p_bind: [objectId]
            });

            expect(object).to.eql({
                hello: "people"
            });
        
        });

        test("Apply non-NULL string property to a null property, check types", function() {
        
            let objectId = database.call("json_store.create_object");

            let valueId = database.call("json_store.set_null", {
                p_path: "#id.hello",
                p_bind: [objectId]
            });

            let parseEvents = database.call("json_parser.parse", {
                p_content: JSON.stringify("world")
            }).p_parse_events;

            let applyValueId = database.call("json_core.apply_json", {
                p_value_id: valueId,
                p_content_parse_events: parseEvents,
                p_check_types: true
            });

            valueId = database.call2("json_core.request_value", {
                p_parent_value_id: objectId,
                p_path: "hello",
                p_bind: null
            });

            expect(applyValueId).to.be(valueId);

            let object = database.call("json_store.get_json", {
                p_path: "#id",
                p_bind: [objectId]
            });

            expect(object).to.eql({
                hello: "world"
            });
        
        });

        test("Apply non-NULL string property to a null property", function() {
        
            let objectId = database.call("json_store.create_object");

            let valueId = database.call("json_store.set_null", {
                p_path: "#id.hello",
                p_bind: [objectId]
            });

            let parseEvents = database.call("json_parser.parse", {
                p_content: JSON.stringify("world")
            }).p_parse_events;

            let applyValueId = database.call("json_core.apply_json", {
                p_value_id: valueId,
                p_content_parse_events: parseEvents,
                p_check_types: true
            });

            valueId = database.call2("json_core.request_value", {
                p_parent_value_id: objectId,
                p_path: "hello",
                p_bind: null
            });

            expect(applyValueId).to.be(valueId);

            let object = database.call("json_store.get_json", {
                p_path: "#id",
                p_bind: [objectId]
            });

            expect(object).to.eql({
                hello: "world"
            });
        
        });

        test("Try to apply non-NULL string property to a number property, check types", function() {
        
            let objectId = database.call("json_store.create_object");

            let valueId = database.call("json_store.set_number", {
                p_path: "#id.hello",
                p_value: 123.321,
                p_bind: [objectId]
            });

            let parseEvents = database.call("json_parser.parse", {
                p_content: JSON.stringify("world")
            }).p_parse_events;

            expect(function() {
            
                database.call("json_core.apply_json", {
                    p_value_id: valueId,
                    p_content_parse_events: parseEvents,
                    p_check_types: true
                });
            
            }).to.throw(/JDOC-00011.*hello/);
            
        });

        test("Apply non-NULL string property to a number property", function() {
        
            let objectId = database.call("json_store.create_object");

            let valueId = database.call("json_store.set_number", {
                p_path: "#id.hello",
                p_value: 123.321,
                p_bind: [objectId]
            });

            let parseEvents = database.call("json_parser.parse", {
                p_content: JSON.stringify("world")
            }).p_parse_events;

            let applyValueId = database.call("json_core.apply_json", {
                p_value_id: valueId,
                p_content_parse_events: parseEvents,
                p_check_types: false
            });

            valueId = database.call2("json_core.request_value", {
                p_parent_value_id: objectId,
                p_path: "hello",
                p_bind: null
            });

            expect(applyValueId).to.be(valueId);

            let object = database.call("json_store.get_json", {
                p_path: "#id",
                p_bind: [objectId]
            });

            expect(object).to.eql({
                hello: "world"
            });
        
        });

        test("Apply non-NULL string property to an empty object property", function() {
        
            let objectId = database.call("json_store.create_object");

            let valueId = database.call("json_store.set_json", {
                p_path: "#id.hello",
                p_content: {},
                p_bind: [objectId]
            });

            let parseEvents = database.call("json_parser.parse", {
                p_content: JSON.stringify("world")
            }).p_parse_events;

            let applyValueId = database.call("json_core.apply_json", {
                p_value_id: valueId,
                p_content_parse_events: parseEvents,
                p_check_types: false
            });

            valueId = database.call2("json_core.request_value", {
                p_parent_value_id: objectId,
                p_path: "hello",
                p_bind: null
            });

            expect(applyValueId).to.be(valueId);

            let object = database.call("json_store.get_json", {
                p_path: "#id",
                p_bind: [objectId]
            });

            expect(object).to.eql({
                hello: "world"
            });
        
        });

        test("Apply non-NULL string property to a complex object property", function() {
        
            let objectId = database.call("json_store.create_object");

            let valueId = database.call("json_store.set_json", {
                p_path: "#id.hello",
                p_content: {
                    name: "Sergejs",
                    address: {
                        city: "Riga"
                    }
                },
                p_bind: [objectId]
            });

            let parseEvents = database.call("json_parser.parse", {
                p_content: JSON.stringify("world")
            }).p_parse_events;

            let applyValueId = database.call("json_core.apply_json", {
                p_value_id: valueId,
                p_content_parse_events: parseEvents,
                p_check_types: false
            });

            valueId = database.call2("json_core.request_value", {
                p_parent_value_id: objectId,
                p_path: "hello",
                p_bind: null
            });

            expect(applyValueId).to.be(valueId);

            let object = database.call("json_store.get_json", {
                p_path: "#id",
                p_bind: [objectId]
            });

            expect(object).to.eql({
                hello: "world"
            });
        
        });

    });

    suite("Applying numbers", function() {
    
        test("Try to apply number property to the root", function() {
        
            let parseEvents = database.call("json_parser.parse", {
                p_content: JSON.stringify(123.321)
            }).p_parse_events;

            expect(function() {
            
                database.call("json_core.apply_json", {
                    p_value_id: 0,
                    p_content_parse_events: parseEvents,
                    p_check_types: false
                });
            
            }).to.throw(/JDOC-00044/);
            
        });

        test("Try to apply number property to an anonymous object", function() {
        
            let objectId = database.call("json_store.create_object");

            let parseEvents = database.call("json_parser.parse", {
                p_content: JSON.stringify(123.321)
            }).p_parse_events;

            expect(function() {
            
                database.call("json_core.apply_json", {
                    p_value_id: objectId,
                    p_content_parse_events: parseEvents,
                    p_check_types: false
                });
            
            }).to.throw(/JDOC-00043/);
            
        });

        test("Try to apply number property to an anonymous array", function() {
        
            let objectId = database.call("json_store.create_array");

            let parseEvents = database.call("json_parser.parse", {
                p_content: JSON.stringify(123.321)
            }).p_parse_events;

            expect(function() {
            
                database.call("json_core.apply_json", {
                    p_value_id: objectId,
                    p_content_parse_events: parseEvents,
                    p_check_types: false
                });
            
            }).to.throw(/JDOC-00043/);
            
        });

        test("Try to apply number property to a locked number property with different value", function() {
        
            let objectId = database.call("json_store.create_object");

            let valueId = database.call("json_store.set_number", {
                p_path: "#id.hello",
                p_value: 123.321,
                p_bind: [objectId]
            });

            database.call('json_core.pin', {
                p_value_id: valueId,
                p_pin_tree: false
            });

            let parseEvents = database.call("json_parser.parse", {
                p_content: JSON.stringify(321.123)
            }).p_parse_events;

            expect(function() {
            
                database.call("json_core.apply_json", {
                    p_value_id: valueId,
                    p_content_parse_events: parseEvents,
                    p_check_types: true
                });                
            
            }).to.throw(/JDOC-00024/);

        });

        test("Apply number property to a number property whith the same value", function() {
        
            let objectId = database.call("json_store.create_object");

            let valueId = database.call("json_store.set_number", {
                p_path: "#id.hello",
                p_value: 123.321,
                p_bind: [objectId]
            });

            let parseEvents = database.call("json_parser.parse", {
                p_content: JSON.stringify(123.321)
            }).p_parse_events;

            database.call("json_core.apply_json", {
                p_value_id: valueId,
                p_content_parse_events: parseEvents,
                p_check_types: true
            });

            let newValueId = database.call("json_core.request_value", {
                p_path: "#id.hello",
                p_bind: [objectId]
            });

            expect(newValueId).to.be(valueId);
        
        });

        test("Apply number property to a number property with a different value", function() {
        
            let objectId = database.call("json_store.create_object");

            let valueId = database.call("json_store.set_number", {
                p_path: "#id.hello",
                p_value: 123.321,
                p_bind: [objectId]
            });

            let parseEvents = database.call("json_parser.parse", {
                p_content: JSON.stringify(321.123)
            }).p_parse_events;

            let applyValueId = database.call("json_core.apply_json", {
                p_value_id: valueId,
                p_content_parse_events: parseEvents,
                p_check_types: true
            });

            valueId = database.call2("json_core.request_value", {
                p_parent_value_id: objectId,
                p_path: "hello",
                p_bind: null
            });

            expect(applyValueId).to.be(valueId);

            let object = database.call("json_store.get_json", {
                p_path: "#id",
                p_bind: [objectId]
            });

            expect(object).to.eql({
                hello: 321.123
            });
        
        });

        test("Apply number property to a null property, check types", function() {
        
            let objectId = database.call("json_store.create_object");

            let valueId = database.call("json_store.set_null", {
                p_path: "#id.hello",
                p_bind: [objectId]
            });

            let parseEvents = database.call("json_parser.parse", {
                p_content: JSON.stringify(321.123)
            }).p_parse_events;

            let applyValueId = database.call("json_core.apply_json", {
                p_value_id: valueId,
                p_content_parse_events: parseEvents,
                p_check_types: true
            });

            valueId = database.call2("json_core.request_value", {
                p_parent_value_id: objectId,
                p_path: "hello",
                p_bind: null
            });

            expect(applyValueId).to.be(valueId);

            let object = database.call("json_store.get_json", {
                p_path: "#id",
                p_bind: [objectId]
            });

            expect(object).to.eql({
                hello: 321.123
            });
        
        });

        test("Apply number property to a null property", function() {
        
            let objectId = database.call("json_store.create_object");

            let valueId = database.call("json_store.set_null", {
                p_path: "#id.hello",
                p_bind: [objectId]
            });

            let parseEvents = database.call("json_parser.parse", {
                p_content: JSON.stringify(321.123)
            }).p_parse_events;

            let applyValueId = database.call("json_core.apply_json", {
                p_value_id: valueId,
                p_content_parse_events: parseEvents,
                p_check_types: false
            });

            valueId = database.call2("json_core.request_value", {
                p_parent_value_id: objectId,
                p_path: "hello",
                p_bind: null
            });

            expect(applyValueId).to.be(valueId);

            let object = database.call("json_store.get_json", {
                p_path: "#id",
                p_bind: [objectId]
            });

            expect(object).to.eql({
                hello: 321.123
            });
        
        });

        test("Try to apply number property to a string property, check types", function() {
        
            let objectId = database.call("json_store.create_object");

            let valueId = database.call("json_store.set_string", {
                p_path: "#id.hello",
                p_value: "world",
                p_bind: [objectId]
            });

            let parseEvents = database.call("json_parser.parse", {
                p_content: JSON.stringify(123.321)
            }).p_parse_events;

            expect(function() {
            
                database.call("json_core.apply_json", {
                    p_value_id: valueId,
                    p_content_parse_events: parseEvents,
                    p_check_types: true
                });
            
            }).to.throw(/JDOC-00011.*hello/);
        
        });

        test("Apply number property to a string property", function() {
        
            let objectId = database.call("json_store.create_object");

            let valueId = database.call("json_store.set_string", {
                p_path: "#id.hello",
                p_value: "world",
                p_bind: [objectId]
            });

            let parseEvents = database.call("json_parser.parse", {
                p_content: JSON.stringify(123.321)
            }).p_parse_events;

            let applyValueId = database.call("json_core.apply_json", {
                p_value_id: valueId,
                p_content_parse_events: parseEvents,
                p_check_types: false
            });

            valueId = database.call2("json_core.request_value", {
                p_parent_value_id: objectId,
                p_path: "hello",
                p_bind: null
            });

            expect(applyValueId).to.be(valueId);

            let object = database.call("json_store.get_json", {
                p_path: "#id",
                p_bind: [objectId]
            });

            expect(object).to.eql({
                hello: 123.321
            });
        
        });

    });

    suite("Applying booleans", function() {
    
        test("Try to apply boolean property to the root", function() {
        
            let parseEvents = database.call("json_parser.parse", {
                p_content: JSON.stringify(true)
            }).p_parse_events;

            expect(function() {
            
                database.call("json_core.apply_json", {
                    p_value_id: 0,
                    p_content_parse_events: parseEvents,
                    p_check_types: false
                });
            
            }).to.throw(/JDOC-00044/);
            
        });

        test("Try to apply boolean property to an anonymous object", function() {
        
            let objectId = database.call("json_store.create_object");

            let parseEvents = database.call("json_parser.parse", {
                p_content: JSON.stringify(true)
            }).p_parse_events;

            expect(function() {
            
                database.call("json_core.apply_json", {
                    p_value_id: objectId,
                    p_content_parse_events: parseEvents,
                    p_check_types: false
                });
            
            }).to.throw(/JDOC-00043/);
            
        });

        test("Try to apply boolean property to an anonymous array", function() {
        
            let objectId = database.call("json_store.create_array");

            let parseEvents = database.call("json_parser.parse", {
                p_content: JSON.stringify(true)
            }).p_parse_events;

            expect(function() {
            
                database.call("json_core.apply_json", {
                    p_value_id: objectId,
                    p_content_parse_events: parseEvents,
                    p_check_types: false
                });
            
            }).to.throw(/JDOC-00043/);
            
        });

        test("Try to apply boolean property to a locked boolean property with different value", function() {
        
            let objectId = database.call("json_store.create_object");

            let valueId = database.call("json_store.set_boolean", {
                p_path: "#id.hello",
                p_value: true,
                p_bind: [objectId]
            });

            database.call('json_core.pin', {
                p_value_id: valueId,
                p_pin_tree: false
            });

            let parseEvents = database.call("json_parser.parse", {
                p_content: JSON.stringify(false)
            }).p_parse_events;

            expect(function() {
            
                database.call("json_core.apply_json", {
                    p_value_id: valueId,
                    p_content_parse_events: parseEvents,
                    p_check_types: true
                });                
            
            }).to.throw(/JDOC-00024/);

        });

        test("Apply boolean property to a boolean property whith the same value", function() {
        
            let objectId = database.call("json_store.create_object");

            let valueId = database.call("json_store.set_boolean", {
                p_path: "#id.hello",
                p_value: true,
                p_bind: [objectId]
            });

            let parseEvents = database.call("json_parser.parse", {
                p_content: JSON.stringify(true)
            }).p_parse_events;

            database.call("json_core.apply_json", {
                p_value_id: valueId,
                p_content_parse_events: parseEvents,
                p_check_types: true
            });

            let newValueId = database.call("json_core.request_value", {
                p_path: "#id.hello",
                p_bind: [objectId]
            });

            expect(newValueId).to.be(valueId);
        
        });

        test("Apply boolean property to a boolean property with a different value", function() {
        
            let objectId = database.call("json_store.create_object");

            let valueId = database.call("json_store.set_boolean", {
                p_path: "#id.hello",
                p_value: true,
                p_bind: [objectId]
            });

            let parseEvents = database.call("json_parser.parse", {
                p_content: JSON.stringify(false)
            }).p_parse_events;

            let applyValueId = database.call("json_core.apply_json", {
                p_value_id: valueId,
                p_content_parse_events: parseEvents,
                p_check_types: true
            });

            valueId = database.call2("json_core.request_value", {
                p_parent_value_id: objectId,
                p_path: "hello",
                p_bind: null
            });

            expect(applyValueId).to.be(valueId);

            let object = database.call("json_store.get_json", {
                p_path: "#id",
                p_bind: [objectId]
            });

            expect(object).to.eql({
                hello: false
            });
        
        });

        test("Apply boolean property to a null property, check types", function() {
        
            let objectId = database.call("json_store.create_object");

            let valueId = database.call("json_store.set_null", {
                p_path: "#id.hello",
                p_bind: [objectId]
            });

            let parseEvents = database.call("json_parser.parse", {
                p_content: JSON.stringify(false)
            }).p_parse_events;

            let applyValueId = database.call("json_core.apply_json", {
                p_value_id: valueId,
                p_content_parse_events: parseEvents,
                p_check_types: true
            });

            valueId = database.call2("json_core.request_value", {
                p_parent_value_id: objectId,
                p_path: "hello",
                p_bind: null
            });

            expect(applyValueId).to.be(valueId);

            let object = database.call("json_store.get_json", {
                p_path: "#id",
                p_bind: [objectId]
            });

            expect(object).to.eql({
                hello: false
            });
        
        });

        test("Apply boolean property to a null property", function() {
        
            let objectId = database.call("json_store.create_object");

            let valueId = database.call("json_store.set_null", {
                p_path: "#id.hello",
                p_bind: [objectId]
            });

            let parseEvents = database.call("json_parser.parse", {
                p_content: JSON.stringify(false)
            }).p_parse_events;

            let applyValueId = database.call("json_core.apply_json", {
                p_value_id: valueId,
                p_content_parse_events: parseEvents,
                p_check_types: false
            });

            valueId = database.call2("json_core.request_value", {
                p_parent_value_id: objectId,
                p_path: "hello",
                p_bind: null
            });

            expect(applyValueId).to.be(valueId);

            let object = database.call("json_store.get_json", {
                p_path: "#id",
                p_bind: [objectId]
            });

            expect(object).to.eql({
                hello: false
            });
        
        });

        test("Try to apply boolean property to a string property, check types", function() {
        
            let objectId = database.call("json_store.create_object");

            let valueId = database.call("json_store.set_string", {
                p_path: "#id.hello",
                p_value: "world",
                p_bind: [objectId]
            });

            let parseEvents = database.call("json_parser.parse", {
                p_content: JSON.stringify(true)
            }).p_parse_events;

            expect(function() {
            
                database.call("json_core.apply_json", {
                    p_value_id: valueId,
                    p_content_parse_events: parseEvents,
                    p_check_types: true
                });
            
            }).to.throw(/JDOC-00011.*hello/);

        });

        test("Apply boolean property to a string property", function() {
        
            let objectId = database.call("json_store.create_object");

            let valueId = database.call("json_store.set_string", {
                p_path: "#id.hello",
                p_value: "world",
                p_bind: [objectId]
            });

            let parseEvents = database.call("json_parser.parse", {
                p_content: JSON.stringify(true)
            }).p_parse_events;

            let applyValueId = database.call("json_core.apply_json", {
                p_value_id: valueId,
                p_content_parse_events: parseEvents,
                p_check_types: false
            });

            valueId = database.call2("json_core.request_value", {
                p_parent_value_id: objectId,
                p_path: "hello",
                p_bind: null
            });

            expect(applyValueId).to.be(valueId);

            let object = database.call("json_store.get_json", {
                p_path: "#id",
                p_bind: [objectId]
            });

            expect(object).to.eql({
                hello: true
            });
        
        });

    });

    suite("Applying nulls", function() {
    
        test("Try to apply null property to the root", function() {
        
            let parseEvents = database.call("json_parser.parse", {
                p_content: JSON.stringify(null)
            }).p_parse_events;

            expect(function() {
            
                database.call("json_core.apply_json", {
                    p_value_id: 0,
                    p_content_parse_events: parseEvents,
                    p_check_types: false
                });
            
            }).to.throw(/JDOC-00044/);
            
        });

        test("Try to apply null property to an anonymous object", function() {
        
            let objectId = database.call("json_store.create_object");

            let parseEvents = database.call("json_parser.parse", {
                p_content: JSON.stringify(null)
            }).p_parse_events;

            expect(function() {
            
                database.call("json_core.apply_json", {
                    p_value_id: objectId,
                    p_content_parse_events: parseEvents,
                    p_check_types: false
                });
            
            }).to.throw(/JDOC-00043/);
            
        });

        test("Try to apply null property to an anonymous array", function() {
        
            let objectId = database.call("json_store.create_array");

            let parseEvents = database.call("json_parser.parse", {
                p_content: JSON.stringify(null)
            }).p_parse_events;

            expect(function() {
            
                database.call("json_core.apply_json", {
                    p_value_id: objectId,
                    p_content_parse_events: parseEvents,
                    p_check_types: false
                });
            
            }).to.throw(/JDOC-00043/);
            
        });

        test("Try to apply null property to a locked string property", function() {
        
            let objectId = database.call("json_store.create_object");

            let valueId = database.call("json_store.set_string", {
                p_path: "#id.hello",
                p_value: "world",
                p_bind: [objectId]
            });

            database.call('json_core.pin', {
                p_value_id: valueId,
                p_pin_tree: false
            });

            let parseEvents = database.call("json_parser.parse", {
                p_content: JSON.stringify(null)
            }).p_parse_events;

            expect(function() {
            
                database.call("json_core.apply_json", {
                    p_value_id: valueId,
                    p_content_parse_events: parseEvents,
                    p_check_types: true
                });                
            
            }).to.throw(/JDOC-00024/);

        });

        test("Apply null property to a null property", function() {
        
            let objectId = database.call("json_store.create_object");

            let valueId = database.call("json_store.set_null", {
                p_path: "#id.hello",
                p_bind: [objectId]
            });

            let parseEvents = database.call("json_parser.parse", {
                p_content: JSON.stringify(null)
            }).p_parse_events;

            database.call("json_core.apply_json", {
                p_value_id: valueId,
                p_content_parse_events: parseEvents,
                p_check_types: true
            });

            let newValueId = database.call("json_core.request_value", {
                p_path: "#id.hello",
                p_bind: [objectId]
            });

            expect(newValueId).to.be(valueId);
        
        });

        test("Apply null property to a string property", function() {
        
            let objectId = database.call("json_store.create_object");

            let valueId = database.call("json_store.set_string", {
                p_path: "#id.hello",
                p_value: "world",
                p_bind: [objectId]
            });

            let parseEvents = database.call("json_parser.parse", {
                p_content: JSON.stringify(null)
            }).p_parse_events;

            let applyValueId = database.call("json_core.apply_json", {
                p_value_id: valueId,
                p_content_parse_events: parseEvents,
                p_check_types: true
            });

            valueId = database.call2("json_core.request_value", {
                p_parent_value_id: objectId,
                p_path: "hello",
                p_bind: null
            });

            expect(applyValueId).to.be(valueId);

            let object = database.call("json_store.get_json", {
                p_path: "#id",
                p_bind: [objectId]
            });

            expect(object).to.eql({
                hello: null
            });
        
        });

    });

    suite("Applying objects", function() {

        test("Try to apply object property to an anonymous array", function() {
        
            let objectId = database.call("json_store.create_array");

            let parseEvents = database.call("json_parser.parse", {
                p_content: JSON.stringify({})
            }).p_parse_events;

            expect(function() {
            
                database.call("json_core.apply_json", {
                    p_value_id: objectId,
                    p_content_parse_events: parseEvents,
                    p_check_types: false
                });
            
            }).to.throw(/JDOC-00043/);
            
        });

        test("Try to apply object property to a locked string property", function() {
        
            let objectId = database.call("json_store.create_object");

            let valueId = database.call("json_store.set_string", {
                p_path: "#id.hello",
                p_value: "world",
                p_bind: [objectId]
            });

            database.call('json_core.pin', {
                p_value_id: valueId,
                p_pin_tree: false
            });

            let parseEvents = database.call("json_parser.parse", {
                p_content: JSON.stringify({})
            }).p_parse_events;

            expect(function() {
            
                database.call("json_core.apply_json", {
                    p_value_id: valueId,
                    p_content_parse_events: parseEvents,
                    p_check_types: false
                });                
            
            }).to.throw(/JDOC-00024/);

        });

        test("Try to apply empty object property to a string property, check types", function() {
        
            let objectId = database.call("json_store.create_object");

            let valueId = database.call("json_store.set_string", {
                p_path: "#id.hello",
                p_value: "world",
                p_bind: [objectId]
            });

            let parseEvents = database.call("json_parser.parse", {
                p_content: JSON.stringify({})
            }).p_parse_events;

            expect(function() {
            
                database.call("json_core.apply_json", {
                    p_value_id: valueId,
                    p_content_parse_events: parseEvents,
                    p_check_types: true
                });
            
            }).to.throw(/JDOC-00011/);
        
        });

        test("Apply empty object property to a string property", function() {
        
            let objectId = database.call("json_store.create_object");

            let valueId = database.call("json_store.set_string", {
                p_path: "#id.hello",
                p_value: "world",
                p_bind: [objectId]
            });

            let parseEvents = database.call("json_parser.parse", {
                p_content: JSON.stringify({})
            }).p_parse_events;

            let applyValueId = database.call("json_core.apply_json", {
                p_value_id: valueId,
                p_content_parse_events: parseEvents,
                p_check_types: false
            });

            valueId = database.call2("json_core.request_value", {
                p_parent_value_id: objectId,
                p_path: "hello",
                p_bind: null
            });

            expect(applyValueId).to.be(valueId);

            let object = database.call("json_store.get_json", {
                p_path: "#id",
                p_bind: [objectId]
            });

            expect(object).to.eql({
                hello: {}
            });
        
        });

        test("Apply empty object property to an object property", function() {
        
            let objectId = database.call("json_store.create_object");

            let valueId = database.call("json_store.set_object", {
                p_path: "#id.hello",
                p_bind: [objectId]
            });

            let parseEvents = database.call("json_parser.parse", {
                p_content: JSON.stringify({})
            }).p_parse_events;

            let applyValueId = database.call("json_core.apply_json", {
                p_value_id: valueId,
                p_content_parse_events: parseEvents,
                p_check_types: true
            });

            expect(applyValueId).to.be(valueId);

            let newValueId = database.call("json_core.request_value", {
                p_path: "#id.hello",
                p_bind: [objectId]
            });

            expect(newValueId).to.be(valueId);
        
        });

        test("Apply one string property to an empty object", function() {
        
            let objectId = database.call("json_store.create_json", {
                p_content: {
                }
            });

            let parseEvents = database.call("json_parser.parse", {
                p_content: JSON.stringify({
                    hello: "world"
                })
            }).p_parse_events;

            let applyValueId = database.call("json_core.apply_json", {
                p_value_id: objectId,
                p_content_parse_events: parseEvents,
                p_check_types: false
            });

            expect(applyValueId).to.be(objectId);

            let object = database.call("json_store.get_json", {
                p_path: "#id",
                p_bind: [objectId]
            });

            expect(object).to.eql({
                hello: "world"
            });
        
        });

        test("Apply several scalar properties to an empty object", function() {
        
            let objectId = database.call("json_store.create_json", {
                p_content: {
                }
            });

            let parseEvents = database.call("json_parser.parse", {
                p_content: JSON.stringify({
                    hello: "world",
                    number: 123.321,
                    boolean: true
                })
            }).p_parse_events;

            database.call("json_core.apply_json", {
                p_value_id: objectId,
                p_content_parse_events: parseEvents,
                p_check_types: false
            });

            let object = database.call("json_store.get_json", {
                p_path: "#id",
                p_bind: [objectId]
            });

            expect(object).to.eql({
                hello: "world",
                number: 123.321,
                boolean: true
            });
        
        });

        test("Apply several scalar properties to an empty object", function() {
        
            let objectId = database.call("json_store.create_json", {
                p_content: {
                }
            });

            let parseEvents = database.call("json_parser.parse", {
                p_content: JSON.stringify({
                    hello: "world",
                    number: 123.321,
                    boolean: true
                })
            }).p_parse_events;

            database.call("json_core.apply_json", {
                p_value_id: objectId,
                p_content_parse_events: parseEvents,
                p_check_types: false
            });

            let object = database.call("json_store.get_json", {
                p_path: "#id",
                p_bind: [objectId]
            });

            expect(object).to.eql({
                hello: "world",
                number: 123.321,
                boolean: true
            });
        
        });

        test("Apply several scalar properties to an empty object", function() {
        
            let objectId = database.call("json_store.create_json", {
                p_content: {
                }
            });

            let parseEvents = database.call("json_parser.parse", {
                p_content: JSON.stringify({
                    hello: "world",
                    number: 123.321,
                    boolean: true
                })
            }).p_parse_events;

            database.call("json_core.apply_json", {
                p_value_id: objectId,
                p_content_parse_events: parseEvents,
                p_check_types: false
            });

            let object = database.call("json_store.get_json", {
                p_path: "#id",
                p_bind: [objectId]
            });

            expect(object).to.eql({
                hello: "world",
                number: 123.321,
                boolean: true
            });
        
        });

        test("Apply object with one property to an object with one property with the same value", function() {
        
            let objectId = database.call("json_store.create_json", {
                p_content: {
                    hello: "world"
                }
            });

            let parseEvents = database.call("json_parser.parse", {
                p_content: JSON.stringify({
                    hello: "world"
                })
            }).p_parse_events;

            database.call("json_core.apply_json", {
                p_value_id: objectId,
                p_content_parse_events: parseEvents,
                p_check_types: false
            });

            let object = database.call("json_store.get_json", {
                p_path: "#id",
                p_bind: [objectId]
            });

            expect(object).to.eql({
                hello: "world"
            });
        
        });

        test("Apply single-level multi-property object to a completely equal object", function() {
        
            let objectId = database.call("json_store.create_json", {
                p_content: {
                    name: "Sergejs",
                    surname: "Vinniks",
                    birthYear: 1982,
                    married: true
                }
            });

            let originalRows = database.selectRows(`
                    *
                FROM json_values
                START WITH id = ${objectId}
                CONNECT BY PRIOR id = parent_id
                ORDER SIBLINGS BY id
            `);

            let parseEvents = database.call("json_parser.parse", {
                p_content: JSON.stringify({
                    name: "Sergejs",
                    surname: "Vinniks",
                    birthYear: 1982,
                    married: true
                })
            }).p_parse_events;

            database.call("json_core.apply_json", {
                p_value_id: objectId,
                p_content_parse_events: parseEvents,
                p_check_types: false
            });

            let object = database.call("json_store.get_json", {
                p_path: "#id",
                p_bind: [objectId]
            });

            expect(object).to.eql({
                name: "Sergejs",
                surname: "Vinniks",
                birthYear: 1982,
                married: true
            });

            let finalRows = database.selectRows(`
                    *
                FROM json_values
                START WITH id = ${objectId}
                CONNECT BY PRIOR id = parent_id
                ORDER SIBLINGS BY id
            `);

            expect(finalRows).to.eql(originalRows);
        
        });

        test("Apply multi-level multi-property object to a completely equal object", function() {
        
            let objectId = database.call("json_store.create_json", {
                p_content: {
                    name: "Sergejs",
                    surname: "Vinniks",
                    birthYear: 1982,
                    married: true,
                    addresses: {
                        home: {
                            city: "Riga",
                            street: "Raunas",
                            house: 41
                        }
                    },
                    phones: {
                        mobile: "1234567",
                        fixed: "7654321"
                    }
                }
            });

            let originalRows = database.selectRows(`
                    *
                FROM json_values
                START WITH id = ${objectId}
                CONNECT BY PRIOR id = parent_id
                ORDER SIBLINGS BY id
            `);

            let parseEvents = database.call("json_parser.parse", {
                p_content: JSON.stringify({
                    name: "Sergejs",
                    surname: "Vinniks",
                    birthYear: 1982,
                    married: true,
                    addresses: {
                        home: {
                            city: "Riga",
                            street: "Raunas",
                            house: 41
                        }
                    },
                    phones: {
                        mobile: "1234567",
                        fixed: "7654321"
                    }
                })
            }).p_parse_events;

            database.call("json_core.apply_json", {
                p_value_id: objectId,
                p_content_parse_events: parseEvents,
                p_check_types: false
            });

            let object = database.call("json_store.get_json", {
                p_path: "#id",
                p_bind: [objectId]
            });

            expect(object).to.eql({
                name: "Sergejs",
                surname: "Vinniks",
                birthYear: 1982,
                married: true,
                addresses: {
                    home: {
                        city: "Riga",
                        street: "Raunas",
                        house: 41
                    }
                },
                phones: {
                    mobile: "1234567",
                    fixed: "7654321"
                }
            });

            let finalRows = database.selectRows(`
                    *
                FROM json_values
                START WITH id = ${objectId}
                CONNECT BY PRIOR id = parent_id
                ORDER SIBLINGS BY id
            `);

            expect(finalRows).to.eql(originalRows);
        
        });

        test("Apply single-property object to a same single-property object with different property value", function() {
        
            let objectId = database.call("json_store.create_json", {
                p_content: {
                    hello: "world"
                }
            });

            let parseEvents = database.call("json_parser.parse", {
                p_content: JSON.stringify({
                    hello: "people"
                })
            }).p_parse_events;

            database.call("json_core.apply_json", {
                p_value_id: objectId,
                p_content_parse_events: parseEvents,
                p_check_types: false
            });

            let object = database.call("json_store.get_json", {
                p_path: "#id",
                p_bind: [objectId]
            });

            expect(object).to.eql({
                hello: "people"
            });

        });

        test("Apply multi-level multi-property object to an object, change or add some properties", function() {
        
            let objectId = database.call("json_store.create_json", {
                p_content: {
                    name: "Sergejs",
                    surname: "Vinniks",
                    birthYear: 1982,
                    married: true,
                    addresses: {
                        home: {
                            city: "Riga",
                            street: "Raunas",
                            house: 41
                        }
                    },
                    phones: {
                        mobile: "1234567",
                        fixed: "7654321"
                    }
                }
            });
            
            let parseEvents = database.call("json_parser.parse", {
                p_content: JSON.stringify({
                    name: "Janis",
                    children: 2,
                    addresses: {
                        home: {
                            city: "Riga",
                            street: "Raunas",
                            house: 41
                        },
                        work: {
                            city: "Cesis"
                        }
                    },
                    phones: {
                        mobile: "7654321",
                        work: "7777777"
                    }
                })
            }).p_parse_events;

            database.call("json_core.apply_json", {
                p_value_id: objectId,
                p_content_parse_events: parseEvents,
                p_check_types: false
            });

            let object = database.call("json_store.get_json", {
                p_path: "#id",
                p_bind: [objectId]
            });

            expect(object).to.eql({
                name: "Janis",
                surname: "Vinniks",
                birthYear: 1982,
                married: true,
                children: 2,
                addresses: {
                    home: {
                        city: "Riga",
                        street: "Raunas",
                        house: 41
                    },
                    work: {
                        city: "Cesis"
                    }
                },
                phones: {
                    mobile: "7654321",
                    fixed: "7654321",
                    work: "7777777"
                }
            });
        
        });

        test("Apply object to the root", function() {
        
            let propertyName = randomString(16);

            database.call("json_store.set_string", {
                p_path: "$.:name",
                p_value: "Hello, World!",
                p_bind: [propertyName]
            });

            let object = {};
            object[propertyName] = "Hello, People!";

            let parseEvents = database.call("json_parser.parse", {
                p_content: JSON.stringify(object)
            }).p_parse_events;

            database.call("json_core.apply_json", {
                p_value_id: 0,
                p_content_parse_events: parseEvents,
                p_check_types: false
            });

            let value = database.call("json_store.get_json", {
                p_path: "$.:name",
                p_bind: [propertyName]
            });

            expect(value).to.be("Hello, People!");
        
        });

    });

    suite("Applying arrays", function() {
    
        test("Try to apply array property to the root", function() {
        
            let parseEvents = database.call("json_parser.parse", {
                p_content: JSON.stringify([])
            }).p_parse_events;

            expect(function() {
            
                database.call("json_core.apply_json", {
                    p_value_id: 0,
                    p_content_parse_events: parseEvents,
                    p_check_types: false
                });
            
            }).to.throw(/JDOC-00044/);
            
        });

        test("Try to apply array property to an anonymous object", function() {
        
            let objectId = database.call("json_store.create_object");

            let parseEvents = database.call("json_parser.parse", {
                p_content: JSON.stringify([])
            }).p_parse_events;

            expect(function() {
            
                database.call("json_core.apply_json", {
                    p_value_id: objectId,
                    p_content_parse_events: parseEvents,
                    p_check_types: false
                });
            
            }).to.throw(/JDOC-00043/);
            
        });

        test("Try to apply array property to a locked string property", function() {
        
            let objectId = database.call("json_store.create_object");

            let valueId = database.call("json_store.set_string", {
                p_path: "#id.hello",
                p_value: "world",
                p_bind: [objectId]
            });

            database.call('json_core.pin', {
                p_value_id: valueId,
                p_pin_tree: false
            });

            let parseEvents = database.call("json_parser.parse", {
                p_content: JSON.stringify([])
            }).p_parse_events;

            expect(function() {
            
                database.call("json_core.apply_json", {
                    p_value_id: valueId,
                    p_content_parse_events: parseEvents,
                    p_check_types: false
                });                
            
            }).to.throw(/JDOC-00024/);

        });

        test("Try to apply empty array property to a string property, check types", function() {
        
            let objectId = database.call("json_store.create_object");

            let valueId = database.call("json_store.set_string", {
                p_path: "#id.hello",
                p_value: "world",
                p_bind: [objectId]
            });

            let parseEvents = database.call("json_parser.parse", {
                p_content: JSON.stringify([])
            }).p_parse_events;

            expect(function() {
            
                database.call("json_core.apply_json", {
                    p_value_id: valueId,
                    p_content_parse_events: parseEvents,
                    p_check_types: true
                });
            
            }).to.throw(/JDOC-00011/);
        
        });

        test("Add one scalar element to an empty array", function() {
        
            let objectId = database.call("json_store.create_json", {
                p_content: [
                ]
            });

            let parseEvents = database.call("json_parser.parse", {
                p_content: JSON.stringify([
                    "Hello, World!"
                ])
            }).p_parse_events;

            let applyValueId = database.call("json_core.apply_json", {
                p_value_id: objectId,
                p_content_parse_events: parseEvents,
                p_check_types: false
            });

            expect(applyValueId).to.be(objectId);

            let object = database.call("json_store.get_json", {
                p_path: "#id",
                p_bind: [objectId]
            });

            expect(object).to.eql([
                "Hello, World!"
            ]);
        
        });

        test("Add multiple scalar elements to an empty array", function() {
        
            let objectId = database.call("json_store.create_json", {
                p_content: [
                ]
            });

            let parseEvents = database.call("json_parser.parse", {
                p_content: JSON.stringify([
                    "Hello, World!",
                    123.321,
                    true
                ])
            }).p_parse_events;

            database.call("json_core.apply_json", {
                p_value_id: objectId,
                p_content_parse_events: parseEvents,
                p_check_types: false
            });

            let object = database.call("json_store.get_json", {
                p_path: "#id",
                p_bind: [objectId]
            });

            expect(object).to.eql([
                "Hello, World!",
                123.321,
                true
            ]);
        
        });

        test("Apply single-level array to a completely equal array", function() {
        
            let objectId = database.call("json_store.create_json", {
                p_content: [
                    "Hello, World!",
                    123.321,
                    true
                ]
            });

            let originalRows = database.selectRows(`
                    *
                FROM json_values
                START WITH id = ${objectId}
                CONNECT BY PRIOR id = parent_id
                ORDER SIBLINGS BY id
            `);

            let parseEvents = database.call("json_parser.parse", {
                p_content: JSON.stringify([
                    "Hello, World!",
                    123.321,
                    true
                ])
            }).p_parse_events;

            database.call("json_core.apply_json", {
                p_value_id: objectId,
                p_content_parse_events: parseEvents,
                p_check_types: false
            });

            let object = database.call("json_store.get_json", {
                p_path: "#id",
                p_bind: [objectId]
            });

            expect(object).to.eql([
                "Hello, World!",
                123.321,
                true
            ]);

            let finalRows = database.selectRows(`
                    *
                FROM json_values
                START WITH id = ${objectId}
                CONNECT BY PRIOR id = parent_id
                ORDER SIBLINGS BY id
            `);

            expect(finalRows).to.eql(originalRows);
        
        });

        test("Add multiple scalar element array to an equally long array", function() {
        
            let objectId = database.call("json_store.create_json", {
                p_content: [
                    "Hello, World!",
                    123.321,
                    true
                ]
            });

            let parseEvents = database.call("json_parser.parse", {
                p_content: JSON.stringify([
                    "Hello, People!",
                    123.321,
                    false
                ])
            }).p_parse_events;

            database.call("json_core.apply_json", {
                p_value_id: objectId,
                p_content_parse_events: parseEvents,
                p_check_types: false
            });

            let object = database.call("json_store.get_json", {
                p_path: "#id",
                p_bind: [objectId]
            });

            expect(object).to.eql([
                "Hello, People!",
                123.321,
                false
            ]);
        
        });

        test("Add multiple scalar element array to a shorter array", function() {
        
            let objectId = database.call("json_store.create_json", {
                p_content: [
                    "Hello, World!",
                    123.321,
                    true,
                ]
            });

            let parseEvents = database.call("json_parser.parse", {
                p_content: JSON.stringify([
                    "Hello, People!",
                    123.321,
                    false,
                    111,
                    "Good bye, World!"
                ])
            }).p_parse_events;

            database.call("json_core.apply_json", {
                p_value_id: objectId,
                p_content_parse_events: parseEvents,
                p_check_types: false
            });

            let object = database.call("json_store.get_json", {
                p_path: "#id",
                p_bind: [objectId]
            });

            expect(object).to.eql([
                "Hello, People!",
                123.321,
                false,
                111,
                "Good bye, World!"
            ]);
        
        });

        test("Complex apply example", function() {
        
            let objectId = database.call("json_store.create_json", {
                p_content: {
                    name: "Sergejs",
                    surname: "Vinniks",
                    addresses: {
                        home: {
                            city: "Riga",
                            street: "Raunas",
                            house: 41
                        }
                    },
                    phones: [
                        {
                            type: "mobile",
                            number: "1234567"
                        },
                        {
                            type: "fixed",
                            number: "7654321"
                        }
                    ]
                }
            });

            let parseEvents = database.call("json_parser.parse", {
                p_content: JSON.stringify({
                    surname: "Stark",
                    addresses: {
                        home: {
                            house: 14,
                            flat: 11
                        },
                        work: "Brivibas gatve 1, Riga, Latvija"
                    },
                    phones: [
                        {},
                        {
                            number: "1234567"
                        },
                        {
                            type: "work",
                            number: "7777777"
                        }
                    ]
                })
            }).p_parse_events;

            database.call("json_core.apply_json", {
                p_value_id: objectId,
                p_content_parse_events: parseEvents,
                p_check_types: false
            });

            let object = database.call("json_store.get_json", {
                p_path: "#id",
                p_bind: [objectId]
            });

            expect(object).to.eql({
                name: "Sergejs",
                surname: "Stark",
                addresses: {
                    home: {
                        city: "Riga",
                        street: "Raunas",
                        house: 14,
                        flat: 11
                    },
                    work: "Brivibas gatve 1, Riga, Latvija"
                },
                phones: [
                    {
                        type: "mobile",
                        number: "1234567"
                    },
                    {
                        type: "fixed",
                        number: "1234567"
                    },
                    {
                        type: "work",
                        number: "7777777"
                    }
                ]
            });
        
        });

    });

});