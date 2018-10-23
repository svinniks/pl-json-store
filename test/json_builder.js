suite("JSON builder tests", function() {

    test("Create an empty builder", function() {

        database.run(`
            DECLARE
            BEGIN
                dbms_session.reset_package; 
            END;
        `);

        let builderId = database.call("json_builders.create_builder");

        expect(builderId).to.not.be(null);
    
    });
    
    test("Try to destroy a builder with NULL ID", function() {

        database.run(`
            DECLARE
            BEGIN
                dbms_session.reset_package; 
            END;
        `);

        expect(function() {
        
            database.call("json_builders.destroy_builder", {
                p_id: null
            });    
        
        }).to.throw(/JBR-00001/);
        
    });

    test("Try to destroy a non-existing builder", function() {

        database.run(`
            DECLARE
            BEGIN
                dbms_session.reset_package; 
            END;
        `);

        expect(function() {
        
            database.call("json_builders.destroy_builder", {
                p_id: 1
            });    
        
        }).to.throw(/JBR-00002/);
        
    });

    test("Successfully create and destroy a builder", function() {
    
        database.run(`
            DECLARE
            BEGIN
                dbms_session.reset_package; 
            END;
        `);

        let builderId = database.call("json_builders.create_builder");

        expect(builderId).to.not.be(null);
    
        database.call("json_builders.destroy_builder", {
            p_id: builderId
        });

        expect(function() {
        
            database.call("json_builders.destroy_builder", {
                p_id: builderId
            });    
        
        }).to.throw(/JBR-00002/);

    });
    
    test("Try to build parse events for NULL builder ID", function() {
    
        database.run(`
            DECLARE
            BEGIN
                dbms_session.reset_package; 
            END;
        `);

        expect(function() {
        
            database.call("json_builders.build_parse_events", {
                p_builder_id: null
            });
        
        }).to.throw(/JBR-00001/);
    
    });
    
    test("Try to build parse events for a non-existing builder", function() {
    
        database.run(`
            DECLARE
            BEGIN
                dbms_session.reset_package; 
            END;
        `);

        expect(function() {
        
            database.call("json_builders.build_parse_events", {
                p_builder_id: 1
            });
        
        }).to.throw(/JBR-00002/);
    
    });

    test("Try to build parse events for an empty builder", function() {
    
        let builderId = database.call("json_builders.create_builder");

        expect(function() {
        
            database.call("json_builders.build_parse_events", {
                p_builder_id: builderId
            });
        
        }).to.throw(/JBR-00004/);
    
    });

    test("Try to add a value to a builder with NULL ID", function() {
    
        database.run(`
            DECLARE
            BEGIN
                dbms_session.reset_package; 
            END;
        `);

        expect(function() {
        
            database.call("json_builders.value", {
                p_builder_id: null,
                p_value: "Hello, World!"
            });
        
        }).to.throw(/JBR-00001/);
    
    });
    
    test("Try to add a value to a non-existing builder", function() {
    
        database.run(`
            DECLARE
            BEGIN
                dbms_session.reset_package; 
            END;
        `);

        expect(function() {
        
            database.call("json_builders.value", {
                p_builder_id: 1,
                p_value: "Hello, World!"
            });
        
        }).to.throw(/JBR-00002/);
    
    });

    test("Single string value builder", function() {
    
        let builderId = database.call("json_builders.create_builder");

        database.call("json_builders.value", {
            p_builder_id: builderId,
            p_value: "Hello, World!"
        });
    
        let events = database.call("json_builders.build_parse_events", {
            p_builder_id: builderId
        });

        expect(events).to.eql([
            "SHello, World!"
        ])

    });

    test("Single NULL string value builder", function() {
    
        let builderId = database.call("json_builders.create_builder");

        database.call("json_builders.value", {
            p_builder_id: builderId,
            p_value: null
        });
    
        let events = database.call("json_builders.build_parse_events", {
            p_builder_id: builderId
        });

        expect(events).to.eql([
            "S"
        ])

    });

    test("Single date value builder", function() {
    
        let builderId = database.call("json_builders.create_builder");

        database.call2("json_builders.value", {
            p_builder_id: builderId,
            p_value: "2018-01-31"
        });
    
        let events = database.call("json_builders.build_parse_events", {
            p_builder_id: builderId
        });

        expect(events).to.eql([
            "S2018-01-31"
        ])

    });

    test("Single NULL date value builder", function() {
    
        let builderId = database.call("json_builders.create_builder");

        database.call2("json_builders.value", {
            p_builder_id: builderId,
            p_value: null
        });
    
        let events = database.call("json_builders.build_parse_events", {
            p_builder_id: builderId
        });

        expect(events).to.eql([
            "E"
        ])

    });

    test("Single number value builder", function() {
    
        let builderId = database.call("json_builders.create_builder");

        database.call3("json_builders.value", {
            p_builder_id: builderId,
            p_value: 123.321
        });
    
        let events = database.call("json_builders.build_parse_events", {
            p_builder_id: builderId
        });

        expect(events).to.eql([
            "N123.321"
        ])

    });

    test("Single number value builder, zero integer part", function() {
    
        let builderId = database.call("json_builders.create_builder");

        database.call3("json_builders.value", {
            p_builder_id: builderId,
            p_value: 0.321
        });
    
        let events = database.call("json_builders.build_parse_events", {
            p_builder_id: builderId
        });

        expect(events).to.eql([
            "N0.321"
        ])

    });

    test("Single negative number value builder, zero integer part", function() {
    
        let builderId = database.call("json_builders.create_builder");

        database.call3("json_builders.value", {
            p_builder_id: builderId,
            p_value: -0.321
        });
    
        let events = database.call("json_builders.build_parse_events", {
            p_builder_id: builderId
        });

        expect(events).to.eql([
            "N-0.321"
        ])

    });

    test("Single NULL number value builder", function() {
    
        let builderId = database.call("json_builders.create_builder");

        database.call3("json_builders.value", {
            p_builder_id: builderId,
            p_value: null
        });
    
        let events = database.call("json_builders.build_parse_events", {
            p_builder_id: builderId
        });

        expect(events).to.eql([
            "E"
        ])

    });

    test("Single boolean value builder", function() {
    
        let builderId = database.call("json_builders.create_builder");

        database.call4("json_builders.value", {
            p_builder_id: builderId,
            p_value: true
        });
    
        let events = database.call("json_builders.build_parse_events", {
            p_builder_id: builderId
        });

        expect(events).to.eql([
            "Btrue"
        ])

    });

    test("Single NULL boolean value builder", function() {
    
        let builderId = database.call("json_builders.create_builder");

        database.call4("json_builders.value", {
            p_builder_id: builderId,
            p_value: null
        });
    
        let events = database.call("json_builders.build_parse_events", {
            p_builder_id: builderId
        });

        expect(events).to.eql([
            "E"
        ])

    });

    test("Single NULL value builder", function() {
    
        let builderId = database.call("json_builders.create_builder");

        database.call("json_builders.null_value", {
            p_builder_id: builderId
        });
    
        let events = database.call("json_builders.build_parse_events", {
            p_builder_id: builderId
        });

        expect(events).to.eql([
            "E"
        ])

    });

    test("Single JSON value builder", function() {
    
        let builderId = database.call("json_builders.create_builder");

        database.call("json_builders.json", {
            p_builder_id: builderId,
            p_content: {
                hello: "world"
            }
        });
    
        let events = database.call("json_builders.build_parse_events", {
            p_builder_id: builderId
        });

        expect(events).to.eql([
            "{",
            ":hello",
            "Sworld",
            "}"
        ])

    });

    test("Single JSON value builder, CLOB version", function() {
    
        let builderId = database.call("json_builders.create_builder");

        database.call2("json_builders.json", {
            p_builder_id: builderId,
            p_content: {
                hello: "world"
            }
        });
    
        let events = database.call("json_builders.build_parse_events", {
            p_builder_id: builderId
        });

        expect(events).to.eql([
            "{",
            ":hello",
            "Sworld",
            "}"
        ])

    });

    test("Single JSON value builder, builder version", function() {
    
        let builderId = database.call("json_builders.create_builder");

        let contentBuilderId = database.call("json_builders.create_builder");

        database.call("json_builders.object", {
            p_builder_id: contentBuilderId
        });

        database.call("json_builders.name", {
            p_builder_id: contentBuilderId,
            p_name: "hello"
        });

        database.call("json_builders.value", {
            p_builder_id: contentBuilderId,
            p_value: "world"
        });

        database.call("json_builders.close", {
            p_builder_id: contentBuilderId
        });

        database.call3("json_builders.json", {
            p_builder_id: builderId,
            p_content_builder_id: contentBuilderId
        });
    
        let events = database.call("json_builders.build_parse_events", {
            p_builder_id: builderId
        });

        expect(events).to.eql([
            "{",
            ":hello",
            "Sworld",
            "}"
        ])

    });

    test("Try to build parse events twice in a row", function() {
    
        let builderId = database.call("json_builders.create_builder");

        database.call("json_builders.value", {
            p_builder_id: builderId,
            p_value: "Hello, World!"
        });
    
        let events = database.call("json_builders.build_parse_events", {
            p_builder_id: builderId
        });

        expect(function() {
        
            database.call("json_builders.build_parse_events", {
                p_builder_id: builderId
            });
        
        }).to.throw(/JBR-00002/);    
    
    });
    
    test("Try to add two values in a row to an empty builder", function() {
    
        let builderId = database.call("json_builders.create_builder");

        database.call("json_builders.value", {
            p_builder_id: builderId,
            p_value: "Hello, World!"
        });

        expect(function() {
        
            database.call("json_builders.value", {
                p_builder_id: builderId,
                p_value: "Hello, World!"
            });
        
        }).to.throw(/JBR-00003/);
    
    });
    
    test("Try to start an array in a builder with NULL ID", function() {
    
        database.run(`
            DECLARE
            BEGIN
                dbms_session.reset_package; 
            END;
        `);
        
        expect(function() {
        
            database.call("json_builders.array", {
                p_builder_id: null
            });
        
        }).to.throw(/JBR-00001/);
    
    });
    
    test("Try to start an array in a non-existing builder", function() {
    
        database.run(`
            DECLARE
            BEGIN
                dbms_session.reset_package; 
            END;
        `);
        
        expect(function() {
        
            database.call("json_builders.array", {
                p_builder_id: 1
            });
        
        }).to.throw(/JBR-00002/);
    
    });

    test("Try to start an array in a builder with an invalid state", function() {
    
        let builderId = database.call("json_builders.create_builder");

        database.call("json_builders.value", {
            p_builder_id: builderId,
            p_value: "Hello, World!"
        });

        expect(function() {
        
            database.call("json_builders.array", {
                p_builder_id: builderId
            });
        
        }).to.throw(/JBR-00005/);
    
    });

    test("Try to build parse events for a builder with non-closed empty array", function() {
    
        let builderId = database.call("json_builders.create_builder");

        database.call("json_builders.array", {
            p_builder_id: builderId
        });

        expect(function() {
        
            database.call("json_builders.build_parse_events", {
                p_builder_id: builderId
            });
        
        }).to.throw(/JBR-00004/);
    
    });
    
    test("Try to end composite in a builder with NULL ID", function() {
    
        database.run(`
            DECLARE
            BEGIN
                dbms_session.reset_package; 
            END;
        `);
        
        expect(function() {
        
            database.call("json_builders.close", {
                p_builder_id: null
            });
        
        }).to.throw(/JBR-00001/);
    
    });
    
    test("Try to end composite in a non-existing builder", function() {
    
        database.run(`
            DECLARE
            BEGIN
                dbms_session.reset_package; 
            END;
        `);
        
        expect(function() {
        
            database.call("json_builders.close", {
                p_builder_id: 1
            });
        
        }).to.throw(/JBR-00002/);
    
    });

    test("Try to end composite with no composites open", function() {
    
        let builderId = database.call("json_builders.create_builder");

        expect(function() {
        
            database.call("json_builders.close", {
                p_builder_id: builderId
            });
        
        }).to.throw(/JBR-00006/);
    
    });
    
    test("Build an empty array", function() {
    
        let builderId = database.call("json_builders.create_builder");

        database.call("json_builders.array", {
            p_builder_id: builderId
        });

        database.call("json_builders.close", {
            p_builder_id: builderId
        });

        let events = database.call("json_builders.build_parse_events", {
            p_builder_id: builderId
        });

        expect(events).to.eql([
            "[",
            "]"
        ]);
    
    });

    test("Build an array with one string element", function() {
    
        let builderId = database.call("json_builders.create_builder");

        database.call("json_builders.array", {
            p_builder_id: builderId
        });

        database.call("json_builders.value", {
            p_builder_id: builderId,
            p_value: "Hello, World!"
        });

        database.call("json_builders.close", {
            p_builder_id: builderId
        });

        let events = database.call("json_builders.build_parse_events", {
            p_builder_id: builderId
        });

        expect(events).to.eql([
            "[",
            ":0",
            "SHello, World!",
            "]"
        ]);
    
    });

    test("Build an array with multiple simple elements", function() {
    
        let builderId = database.call("json_builders.create_builder");

        database.call("json_builders.array", {
            p_builder_id: builderId
        });

        database.call("json_builders.value", {
            p_builder_id: builderId,
            p_value: "Hello, World!"
        });

        database.call3("json_builders.value", {
            p_builder_id: builderId,
            p_value: 123.321
        });

        database.call4("json_builders.value", {
            p_builder_id: builderId,
            p_value: true
        });

        database.call("json_builders.close", {
            p_builder_id: builderId
        });

        let events = database.call("json_builders.build_parse_events", {
            p_builder_id: builderId
        });

        expect(events).to.eql([
            "[",
            ":0",
            "SHello, World!",
            ":1",
            "N123.321",
            ":2",
            "Btrue",
            "]"
        ]);
    
    });

    test("Build multidimensional array", function() {
    
        let builderId = database.call("json_builders.create_builder");

        database.call("json_builders.array", {
            p_builder_id: builderId
        });

        database.call("json_builders.array", {
            p_builder_id: builderId
        });

        database.call("json_builders.value", {
            p_builder_id: builderId,
            p_value: "Hello, World!"
        });

        database.call("json_builders.value", {
            p_builder_id: builderId,
            p_value: "Hello, World!"
        });

        database.call("json_builders.close", {
            p_builder_id: builderId
        });

        database.call("json_builders.array", {
            p_builder_id: builderId
        });

        database.call("json_builders.value", {
            p_builder_id: builderId,
            p_value: "Hello, World!"
        });

        database.call("json_builders.value", {
            p_builder_id: builderId,
            p_value: "Hello, World!"
        });

        database.call("json_builders.close", {
            p_builder_id: builderId
        });

        database.call("json_builders.close", {
            p_builder_id: builderId
        });

        let events = database.call("json_builders.build_parse_events", {
            p_builder_id: builderId
        });

        expect(events).to.eql([
            "[",
            ":0",
            "[",
            ":0",
            "SHello, World!",
            ":1",
            "SHello, World!",
            "]",
            ":1",
            "[",
            ":0",
            "SHello, World!",
            ":1",
            "SHello, World!",
            "]",
            "]"
        ]);
    
    });

    test("Try to start an object in a builder with NULL ID", function() {
    
        database.run(`
            DECLARE
            BEGIN
                dbms_session.reset_package; 
            END;
        `);
        
        expect(function() {
        
            database.call("json_builders.object", {
                p_builder_id: null
            });
        
        }).to.throw(/JBR-00001/);
    
    });
    
    test("Try to start an object in a non-existing builder", function() {
    
        database.run(`
            DECLARE
            BEGIN
                dbms_session.reset_package; 
            END;
        `);
        
        expect(function() {
        
            database.call("json_builders.object", {
                p_builder_id: 1
            });
        
        }).to.throw(/JBR-00002/);
    
    });

    test("Try to start an object in a builder with an invalid state", function() {
    
        let builderId = database.call("json_builders.create_builder");

        database.call("json_builders.value", {
            p_builder_id: builderId,
            p_value: "Hello, World!"
        });

        expect(function() {
        
            database.call("json_builders.object", {
                p_builder_id: builderId
            });
        
        }).to.throw(/JBR-00007/);
    
    });

    test("Try to add property without a name", function() {
    
        let builderId = database.call("json_builders.create_builder");

        database.call("json_builders.object", {
            p_builder_id: builderId
        });

        expect(function() {
        
            database.call("json_builders.value", {
                p_builder_id: builderId,
                p_value: "Hello, World!"
            });
        
        }).to.throw(/JBR-00003/);
    
    });
    
    test("Try to set property name in a builder with NULL ID", function() {
    
        database.run(`
            DECLARE
            BEGIN
                dbms_session.reset_package; 
            END;
        `);
        
        expect(function() {
        
            database.call("json_builders.name", {
                p_builder_id: null,
                p_name: "hello"
            });
        
        }).to.throw(/JBR-00001/);
    
    });
    
    test("Try to set property name a non-existing builder", function() {
    
        database.run(`
            DECLARE
            BEGIN
                dbms_session.reset_package; 
            END;
        `);
        
        expect(function() {
        
            database.call("json_builders.name", {
                p_builder_id: 1,
                p_name: "hello"
            });
        
        }).to.throw(/JBR-00002/);
    
    });

    test("Try to set NULL property name", function() {
    
        let builderId = database.call("json_builders.create_builder");

        expect(function() {
        
            database.call("json_builders.name", {
                p_builder_id: builderId,
                p_name: null
            });
        
        }).to.throw(/JBR-00008/);
    
    });

    test("Try to set property name in an empty builder", function() {
    
        let builderId = database.call("json_builders.create_builder");

        expect(function() {
        
            database.call("json_builders.name", {
                p_builder_id: builderId,
                p_name: "hello"
            });
        
        }).to.throw(/JBR-00009/);
    
    });

    test("Try to set property name while not in object", function() {
    
        let builderId = database.call("json_builders.create_builder");

        database.call("json_builders.array", {
            p_builder_id: builderId
        });

        expect(function() {
        
            database.call("json_builders.name", {
                p_builder_id: builderId,
                p_name: "hello"
            });
        
        }).to.throw(/JBR-00009/);
    
    });
    
    test("Try to set property name twice in a row", function() {
    
        let builderId = database.call("json_builders.create_builder");

        database.call("json_builders.object", {
            p_builder_id: builderId
        });

        database.call("json_builders.name", {
            p_builder_id: builderId,
            p_name: "hello"
        });

        expect(function() {
        
            database.call("json_builders.name", {
                p_builder_id: builderId,
                p_name: "hello"
            });
        
        }).to.throw(/JBR-00009/);
    
    });

    test("Try to end an object without property value", function() {
    
        let builderId = database.call("json_builders.create_builder");

        database.call("json_builders.object", {
            p_builder_id: builderId
        });

        database.call("json_builders.name", {
            p_builder_id: builderId,
            p_name: "hello"
        });

        expect(function() {
        
            database.call("json_builders.close", {
                p_builder_id: builderId
            });
        
        }).to.throw(/JBR-00010/);
    
    });

    test("Build an empty object", function() {
    
        let builderId = database.call("json_builders.create_builder");

        database.call("json_builders.object", {
            p_builder_id: builderId
        });

        database.call("json_builders.close", {
            p_builder_id: builderId
        });

        let events = database.call("json_builders.build_parse_events", {
            p_builder_id: builderId
        });
    
        expect(events).to.eql([
            "{",
            "}"
        ]);
    
    });

    test("Build an object with one simple property", function() {
    
        let builderId = database.call("json_builders.create_builder");

        database.call("json_builders.object", {
            p_builder_id: builderId
        });

        database.call("json_builders.name", {
            p_builder_id: builderId,
            p_name: "hello"
        });

        database.call("json_builders.value", {
            p_builder_id: builderId,
            p_value: "world"
        });

        database.call("json_builders.close", {
            p_builder_id: builderId
        });

        let events = database.call("json_builders.build_parse_events", {
            p_builder_id: builderId
        });
    
        expect(events).to.eql([
            "{",
            ":hello",
            "Sworld",
            "}"
        ]);
    
    });

    test("Build an object with multiple simple property", function() {
    
        let builderId = database.call("json_builders.create_builder");

        database.call("json_builders.object", {
            p_builder_id: builderId
        });

        database.call("json_builders.name", {
            p_builder_id: builderId,
            p_name: "hello"
        });

        database.call("json_builders.value", {
            p_builder_id: builderId,
            p_value: "world"
        });

        database.call("json_builders.name", {
            p_builder_id: builderId,
            p_name: "good bye"
        });

        database.call("json_builders.value", {
            p_builder_id: builderId,
            p_value: "life"
        });

        database.call("json_builders.name", {
            p_builder_id: builderId,
            p_name: "number"
        });

        database.call3("json_builders.value", {
            p_builder_id: builderId,
            p_value: 123.321
        });

        database.call("json_builders.close", {
            p_builder_id: builderId
        });

        let events = database.call("json_builders.build_parse_events", {
            p_builder_id: builderId
        });
    
        expect(events).to.eql([
            "{",
            ":hello",
            "Sworld",
            ":good bye",
            "Slife",
            ":number",
            "N123.321",
            "}"
        ]);
           
    });

    test("Try to build an object with duplicate property names", function() {
    
        let builderId = database.call("json_builders.create_builder");

        database.call("json_builders.object", {
            p_builder_id: builderId
        });

        database.call("json_builders.name", {
            p_builder_id: builderId,
            p_name: "hello"
        });

        database.call("json_builders.value", {
            p_builder_id: builderId,
            p_value: "world"
        });

        expect(function() {
        
            database.call("json_builders.name", {
                p_builder_id: builderId,
                p_name: "hello"
            });            
        
        }).to.throw(/JBR-00011.*hello/);

    });

    test("Two subobjects with equal property names", function() {
    
        let builderId = database.call("json_builders.create_builder");
    
        database.call("json_builders.object", {
            p_builder_id: builderId
        });

        database.call("json_builders.name", {
            p_builder_id: builderId,
            p_name: "object1"
        });

        database.call("json_builders.object", {
            p_builder_id: builderId
        });

        database.call("json_builders.name", {
            p_builder_id: builderId,
            p_name: "hello"
        });

        database.call("json_builders.value", {
            p_builder_id: builderId,
            p_value: "world"
        });

        database.call("json_builders.close", {
            p_builder_id: builderId
        });

        database.call("json_builders.name", {
            p_builder_id: builderId,
            p_name: "object2"
        });

        database.call("json_builders.object", {
            p_builder_id: builderId
        });

        database.call("json_builders.name", {
            p_builder_id: builderId,
            p_name: "hello"
        });

        database.call("json_builders.value", {
            p_builder_id: builderId,
            p_value: "world"
        });

        database.call("json_builders.close", {
            p_builder_id: builderId
        });

        database.call("json_builders.close", {
            p_builder_id: builderId
        });

        let events = database.call("json_builders.build_parse_events", {
            p_builder_id: builderId
        });

    });
    
    test("Nested objects with equal property names on different levels", function() {
    
        let builderId = database.call("json_builders.create_builder");

        database.call("json_builders.object", {
            p_builder_id: builderId
        });

        database.call("json_builders.name", {
            p_builder_id: builderId,
            p_name: "hello"
        });

        database.call("json_builders.value", {
            p_builder_id: builderId,
            p_value: "world"
        });

        database.call("json_builders.name", {
            p_builder_id: builderId,
            p_name: "child"
        });

        database.call("json_builders.object", {
            p_builder_id: builderId
        });

        database.call("json_builders.name", {
            p_builder_id: builderId,
            p_name: "hello"
        });

        database.call("json_builders.value", {
            p_builder_id: builderId,
            p_value: "world"
        });

        database.call("json_builders.close", {
            p_builder_id: builderId
        });

        database.call("json_builders.close", {
            p_builder_id: builderId
        });

        let events = database.call("json_builders.build_parse_events", {
            p_builder_id: builderId
        });
    
        expect(events).to.eql([
            "{",
            ":hello",
            "Sworld",
            ":child",
            "{",
            ":hello",
            "Sworld",
            "}",
            "}"
        ]);
    
    });

    test("Try to build JSON of a builder with NULL ID", function() {
    
        database.run(`
            DECLARE
            BEGIN
                dbms_session.reset_package; 
            END;
        `);
        
        expect(function() {
        
            database.call("json_builders.build_json", {
                p_builder_id: null
            });
        
        }).to.throw(/JBR-00001/);
    
    });
    
    test("Try to build JSON of a non-existing builder", function() {
    
        database.run(`
            DECLARE
            BEGIN
                dbms_session.reset_package; 
            END;
        `);
        
        expect(function() {
        
            database.call("json_builders.build_json", {
                p_builder_id: 1
            });
        
        }).to.throw(/JBR-00002/);
    
    }); 

    test("Try to build JSON for an empty builder", function() {
    
        let builderId = database.call("json_builders.create_builder");

        expect(function() {
        
            database.call("json_builders.build_json", {
                p_builder_id: builderId
            });
        
        }).to.throw(/JBR-00004/);
    
    });

    test("Build JSON using the VARCHAR2 method", function() {
    
        let builderId = database.call("json_builders.create_builder");

        database.call("json_builders.object", {
            p_builder_id: builderId
        });

        database.call("json_builders.name", {
            p_builder_id: builderId,
            p_name: "hello"
        });

        database.call("json_builders.value", {
            p_builder_id: builderId,
            p_value: "world"
        });

        database.call("json_builders.close", {
            p_builder_id: builderId
        });

        let json = database.call("json_builders.build_json", {
            p_builder_id: builderId
        });

        expect(json).to.eql({
            hello: "world"
        });
    
    });

    test("Build JSON using the CLOB method", function() {
    
        let builderId = database.call("json_builders.create_builder");

        database.call("json_builders.object", {
            p_builder_id: builderId
        });

        database.call("json_builders.name", {
            p_builder_id: builderId,
            p_name: "hello"
        });

        database.call("json_builders.value", {
            p_builder_id: builderId,
            p_value: "world"
        });

        database.call("json_builders.close", {
            p_builder_id: builderId
        });

        let json = database.call("json_builders.build_json", {
            p_builder_id: builderId
        });

        expect(json).to.eql({
            hello: "world"
        });
    
    });

    test("Don't serialize single NULL property of an object", function() {
    
        let builderId = database.call("json_builders.create_builder");

        database.call("json_builders.object", {
            p_builder_id: builderId
        });

        database.call("json_builders.name", {
            p_builder_id: builderId,
            p_name: "hello"
        });

        database.call("json_builders.null_value", {
            p_builder_id: builderId
        });

        database.call("json_builders.close", {
            p_builder_id: builderId
        });

        let parseEvents = database.call("json_builders.build_parse_events", {
            p_builder_id: builderId,
            p_serialize_nulls: false
        });

        expect(parseEvents).to.eql([
            "{",
            "}"
        ]);

    });

    test("Don't serialize multiple NULL properties of an object", function() {
    
        let builderId = database.call("json_builders.create_builder");

        database.call("json_builders.object", {
            p_builder_id: builderId
        });

        database.call("json_builders.name", {
            p_builder_id: builderId,
            p_name: "hello"
        });

        database.call("json_builders.null_value", {
            p_builder_id: builderId
        });

        database.call("json_builders.name", {
            p_builder_id: builderId,
            p_name: "goodBye"
        });

        database.call("json_builders.null_value", {
            p_builder_id: builderId
        });

        database.call("json_builders.name", {
            p_builder_id: builderId,
            p_name: "orly"
        });

        database.call("json_builders.null_value", {
            p_builder_id: builderId
        });

        database.call("json_builders.close", {
            p_builder_id: builderId
        });

        let parseEvents = database.call("json_builders.build_parse_events", {
            p_builder_id: builderId,
            p_serialize_nulls: false
        });

        expect(parseEvents).to.eql([
            "{",
            "}"
        ]);

    });

    test("Don't serialize some NULL properties of an object", function() {
    
        let builderId = database.call("json_builders.create_builder");

        database.call("json_builders.object", {
            p_builder_id: builderId
        });

        database.call("json_builders.name", {
            p_builder_id: builderId,
            p_name: "hello"
        });

        database.call("json_builders.value", {
            p_builder_id: builderId,
            p_value: "world"
        });

        database.call("json_builders.name", {
            p_builder_id: builderId,
            p_name: "goodBye"
        });

        database.call("json_builders.null_value", {
            p_builder_id: builderId
        });

        database.call("json_builders.name", {
            p_builder_id: builderId,
            p_name: "orly"
        });

        database.call("json_builders.null_value", {
            p_builder_id: builderId
        });

        database.call("json_builders.name", {
            p_builder_id: builderId,
            p_name: "yarly"
        });

        database.call("json_builders.value", {
            p_builder_id: builderId,
            p_value: "yeah"
        });

        database.call("json_builders.close", {
            p_builder_id: builderId
        });

        let parseEvents = database.call("json_builders.build_parse_events", {
            p_builder_id: builderId,
            p_serialize_nulls: false
        });

        expect(parseEvents).to.eql([
            "{",
            ":hello",
            "Sworld",
            ":yarly",
            "Syeah",
            "}"
        ]);

    });

    test("Don't serialize single NULL value", function() {
    
        let builderId = database.call("json_builders.create_builder");

        database.call("json_builders.null_value", {
            p_builder_id: builderId
        });

        let parseEvents = database.call("json_builders.build_parse_events", {
            p_builder_id: builderId,
            p_serialize_nulls: false
        });

        expect(parseEvents).to.eql([
            "E"
        ]);

    });

    test("Don't serialize single array NULL elements", function() {
    
        let builderId = database.call("json_builders.create_builder");

        database.call("json_builders.array", {
            p_builder_id: builderId
        });

        database.call("json_builders.null_value", {
            p_builder_id: builderId
        });

        database.call("json_builders.value", {
            p_builder_id: builderId,
            p_value: "Hello, World!"
        });

        database.call("json_builders.close", {
            p_builder_id: builderId
        });

        let parseEvents = database.call("json_builders.build_parse_events", {
            p_builder_id: builderId,
            p_serialize_nulls: false
        });

        expect(parseEvents).to.eql([
            "[",
            ":1",
            "SHello, World!",
            "]"
        ]);

    });

    test("Don't serialize some NULL properties of an object, builder's SERIALIZE_NULLS option", function() {
    
        let builderId = database.call("json_builders.create_builder", {
            p_serialize_nulls: false
        });

        database.call("json_builders.object", {
            p_builder_id: builderId
        });

        database.call("json_builders.name", {
            p_builder_id: builderId,
            p_name: "hello"
        });

        database.call("json_builders.value", {
            p_builder_id: builderId,
            p_value: "world"
        });

        database.call("json_builders.name", {
            p_builder_id: builderId,
            p_name: "goodBye"
        });

        database.call("json_builders.null_value", {
            p_builder_id: builderId
        });

        database.call("json_builders.name", {
            p_builder_id: builderId,
            p_name: "orly"
        });

        database.call("json_builders.null_value", {
            p_builder_id: builderId
        });

        database.call("json_builders.name", {
            p_builder_id: builderId,
            p_name: "yarly"
        });

        database.call("json_builders.value", {
            p_builder_id: builderId,
            p_value: "yeah"
        });

        database.call("json_builders.close", {
            p_builder_id: builderId
        });

        let parseEvents = database.call("json_builders.build_parse_events", {
            p_builder_id: builderId
        });

        expect(parseEvents).to.eql([
            "{",
            ":hello",
            "Sworld",
            ":yarly",
            "Syeah",
            "}"
        ]);

    });

});