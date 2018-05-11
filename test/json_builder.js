suite("JSON builder tests", function() {

    test("Create an empty builder", function() {

        database.run(`
            DECLARE
            BEGIN
                dbms_session.reset_package; 
            END;
        `);

        let builderId = database.call("json_builder.create_builder");

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
        
            database.call("json_builder.destroy_builder", {
                p_id: null
            });    
        
        }).to.throw(/JBLR-00001/);
        
    });

    test("Try to destroy a non-existing builder", function() {

        database.run(`
            DECLARE
            BEGIN
                dbms_session.reset_package; 
            END;
        `);

        expect(function() {
        
            database.call("json_builder.destroy_builder", {
                p_id: 1
            });    
        
        }).to.throw(/JBLR-00002/);
        
    });

    test("Successfully create and destroy a builder", function() {
    
        database.run(`
            DECLARE
            BEGIN
                dbms_session.reset_package; 
            END;
        `);

        let builderId = database.call("json_builder.create_builder");

        expect(builderId).to.not.be(null);
    
        database.call("json_builder.destroy_builder", {
            p_id: builderId
        });

        expect(function() {
        
            database.call("json_builder.destroy_builder", {
                p_id: builderId
            });    
        
        }).to.throw(/JBLR-00002/);

    });
    
    test("Try to build parse events for NULL builder ID", function() {
    
        database.run(`
            DECLARE
            BEGIN
                dbms_session.reset_package; 
            END;
        `);

        expect(function() {
        
            database.call("json_builder.build_parse_events", {
                p_builder_id: null
            });
        
        }).to.throw(/JBLR-00001/);
    
    });
    
    test("Try to build parse events for a non-existing builder", function() {
    
        database.run(`
            DECLARE
            BEGIN
                dbms_session.reset_package; 
            END;
        `);

        expect(function() {
        
            database.call("json_builder.build_parse_events", {
                p_builder_id: 1
            });
        
        }).to.throw(/JBLR-00002/);
    
    });

    test("Try to build parse events for an empty builder", function() {
    
        let builderId = database.call("json_builder.create_builder");

        expect(function() {
        
            database.call("json_builder.build_parse_events", {
                p_builder_id: builderId
            });
        
        }).to.throw(/JBLR-00004/);
    
    });

    test("Try to add a value to a builder with NULL ID", function() {
    
        database.run(`
            DECLARE
            BEGIN
                dbms_session.reset_package; 
            END;
        `);

        expect(function() {
        
            database.call("json_builder.value", {
                p_builder_id: null,
                p_value: "Hello, World!"
            });
        
        }).to.throw(/JBLR-00001/);
    
    });
    
    test("Try to add a value to a non-existing builder", function() {
    
        database.run(`
            DECLARE
            BEGIN
                dbms_session.reset_package; 
            END;
        `);

        expect(function() {
        
            database.call("json_builder.value", {
                p_builder_id: 1,
                p_value: "Hello, World!"
            });
        
        }).to.throw(/JBLR-00002/);
    
    });

    test("Single string value builder", function() {
    
        let builderId = database.call("json_builder.create_builder");

        database.call("json_builder.value", {
            p_builder_id: builderId,
            p_value: "Hello, World!"
        });
    
        let events = database.call("json_builder.build_parse_events", {
            p_builder_id: builderId
        });

        expect(events).to.eql([
            {
                name: "STRING",
                value: "Hello, World!"
            }
        ])

    });

    test("Single NULL string value builder", function() {
    
        let builderId = database.call("json_builder.create_builder");

        database.call("json_builder.value", {
            p_builder_id: builderId,
            p_value: null
        });
    
        let events = database.call("json_builder.build_parse_events", {
            p_builder_id: builderId
        });

        expect(events).to.eql([
            {
                name: "NULL",
                value: null
            }
        ])

    });

    test("Single date value builder", function() {
    
        let builderId = database.call("json_builder.create_builder");

        database.call2("json_builder.value", {
            p_builder_id: builderId,
            p_value: "2018-01-31"
        });
    
        let events = database.call("json_builder.build_parse_events", {
            p_builder_id: builderId
        });

        expect(events).to.eql([
            {
                name: "STRING",
                value: "2018-01-31"
            }
        ])

    });

    test("Single NULL date value builder", function() {
    
        let builderId = database.call("json_builder.create_builder");

        database.call2("json_builder.value", {
            p_builder_id: builderId,
            p_value: null
        });
    
        let events = database.call("json_builder.build_parse_events", {
            p_builder_id: builderId
        });

        expect(events).to.eql([
            {
                name: "NULL",
                value: null
            }
        ])

    });

    test("Single number value builder", function() {
    
        let builderId = database.call("json_builder.create_builder");

        database.call3("json_builder.value", {
            p_builder_id: builderId,
            p_value: 123.321
        });
    
        let events = database.call("json_builder.build_parse_events", {
            p_builder_id: builderId
        });

        expect(events).to.eql([
            {
                name: "NUMBER",
                value: "123.321"
            }
        ])

    });

    test("Single number value builder, zero integer part", function() {
    
        let builderId = database.call("json_builder.create_builder");

        database.call3("json_builder.value", {
            p_builder_id: builderId,
            p_value: 0.321
        });
    
        let events = database.call("json_builder.build_parse_events", {
            p_builder_id: builderId
        });

        expect(events).to.eql([
            {
                name: "NUMBER",
                value: "0.321"
            }
        ])

    });

    test("Single NULL number value builder", function() {
    
        let builderId = database.call("json_builder.create_builder");

        database.call3("json_builder.value", {
            p_builder_id: builderId,
            p_value: null
        });
    
        let events = database.call("json_builder.build_parse_events", {
            p_builder_id: builderId
        });

        expect(events).to.eql([
            {
                name: "NULL",
                value: null
            }
        ])

    });

    test("Single boolean value builder", function() {
    
        let builderId = database.call("json_builder.create_builder");

        database.call4("json_builder.value", {
            p_builder_id: builderId,
            p_value: true
        });
    
        let events = database.call("json_builder.build_parse_events", {
            p_builder_id: builderId
        });

        expect(events).to.eql([
            {
                name: "BOOLEAN",
                value: "true"
            }
        ])

    });

    test("Single NULL boolean value builder", function() {
    
        let builderId = database.call("json_builder.create_builder");

        database.call4("json_builder.value", {
            p_builder_id: builderId,
            p_value: null
        });
    
        let events = database.call("json_builder.build_parse_events", {
            p_builder_id: builderId
        });

        expect(events).to.eql([
            {
                name: "NULL",
                value: null
            }
        ])

    });

    test("Try to build parse events twice in a row", function() {
    
        let builderId = database.call("json_builder.create_builder");

        database.call("json_builder.value", {
            p_builder_id: builderId,
            p_value: "Hello, World!"
        });
    
        let events = database.call("json_builder.build_parse_events", {
            p_builder_id: builderId
        });

        expect(function() {
        
            database.call("json_builder.build_parse_events", {
                p_builder_id: builderId
            });
        
        }).to.throw(/JBLR-00002/);    
    
    });
    
    test("Try to add two values in a row to an empty builder", function() {
    
        let builderId = database.call("json_builder.create_builder");

        database.call("json_builder.value", {
            p_builder_id: builderId,
            p_value: "Hello, World!"
        });

        expect(function() {
        
            database.call("json_builder.value", {
                p_builder_id: builderId,
                p_value: "Hello, World!"
            });
        
        }).to.throw(/JBLR-00003/);
    
    });
    
    test("Try to start an array in a builder with NULL ID", function() {
    
        database.run(`
            DECLARE
            BEGIN
                dbms_session.reset_package; 
            END;
        `);
        
        expect(function() {
        
            database.call("json_builder.array", {
                p_builder_id: null
            });
        
        }).to.throw(/JBLR-00001/);
    
    });
    
    test("Try to start an array in a non-existing builder", function() {
    
        database.run(`
            DECLARE
            BEGIN
                dbms_session.reset_package; 
            END;
        `);
        
        expect(function() {
        
            database.call("json_builder.array", {
                p_builder_id: 1
            });
        
        }).to.throw(/JBLR-00002/);
    
    });

    test("Try to start an array in a builder with an invalid state", function() {
    
        let builderId = database.call("json_builder.create_builder");

        database.call("json_builder.value", {
            p_builder_id: builderId,
            p_value: "Hello, World!"
        });

        expect(function() {
        
            database.call("json_builder.array", {
                p_builder_id: builderId
            });
        
        }).to.throw(/JBLR-00005/);
    
    });

    test("Try to build parse events for a builder with non-closed empty array", function() {
    
        let builderId = database.call("json_builder.create_builder");

        database.call("json_builder.array", {
            p_builder_id: builderId
        });

        expect(function() {
        
            database.call("json_builder.build_parse_events", {
                p_builder_id: builderId
            });
        
        }).to.throw(/JBLR-00004/);
    
    });
    
    test("Try to end composite in a builder with NULL ID", function() {
    
        database.run(`
            DECLARE
            BEGIN
                dbms_session.reset_package; 
            END;
        `);
        
        expect(function() {
        
            database.call("json_builder.close", {
                p_builder_id: null
            });
        
        }).to.throw(/JBLR-00001/);
    
    });
    
    test("Try to end composite in a non-existing builder", function() {
    
        database.run(`
            DECLARE
            BEGIN
                dbms_session.reset_package; 
            END;
        `);
        
        expect(function() {
        
            database.call("json_builder.close", {
                p_builder_id: 1
            });
        
        }).to.throw(/JBLR-00002/);
    
    });

    test("Try to end composite with no composites open", function() {
    
        let builderId = database.call("json_builder.create_builder");

        expect(function() {
        
            database.call("json_builder.close", {
                p_builder_id: builderId
            });
        
        }).to.throw(/JBLR-00006/);
    
    });
    
    test("Build an empty array", function() {
    
        let builderId = database.call("json_builder.create_builder");

        database.call("json_builder.array", {
            p_builder_id: builderId
        });

        database.call("json_builder.close", {
            p_builder_id: builderId
        });

        let events = database.call("json_builder.build_parse_events", {
            p_builder_id: builderId
        });

        expect(events).to.eql([
            {
                name: "START_ARRAY",
                value: null
            },
            {
                name: "END_ARRAY",
                value: null
            }
        ]);
    
    });

    test("Build an array with one string element", function() {
    
        let builderId = database.call("json_builder.create_builder");

        database.call("json_builder.array", {
            p_builder_id: builderId
        });

        database.call("json_builder.value", {
            p_builder_id: builderId,
            p_value: "Hello, World!"
        });

        database.call("json_builder.close", {
            p_builder_id: builderId
        });

        let events = database.call("json_builder.build_parse_events", {
            p_builder_id: builderId
        });

        expect(events).to.eql([
            {
                name: "START_ARRAY",
                value: null
            },
            {
                name: "STRING",
                value: "Hello, World!"
            },
            {
                name: "END_ARRAY",
                value: null
            }
        ]);
    
    });

    test("Build an array with multiple simple elements", function() {
    
        let builderId = database.call("json_builder.create_builder");

        database.call("json_builder.array", {
            p_builder_id: builderId
        });

        database.call("json_builder.value", {
            p_builder_id: builderId,
            p_value: "Hello, World!"
        });

        database.call3("json_builder.value", {
            p_builder_id: builderId,
            p_value: 123.321
        });

        database.call4("json_builder.value", {
            p_builder_id: builderId,
            p_value: true
        });

        database.call("json_builder.close", {
            p_builder_id: builderId
        });

        let events = database.call("json_builder.build_parse_events", {
            p_builder_id: builderId
        });

        expect(events).to.eql([
            {
                name: "START_ARRAY",
                value: null
            },
            {
                name: "STRING",
                value: "Hello, World!"
            },
            {
                name: "NUMBER",
                value: "123.321"
            },
            {
                name: "BOOLEAN",
                value: "true"
            },
            {
                name: "END_ARRAY",
                value: null
            }
        ]);
    
    });

    test("Build multidimensional array", function() {
    
        let builderId = database.call("json_builder.create_builder");

        database.call("json_builder.array", {
            p_builder_id: builderId
        });

        database.call("json_builder.array", {
            p_builder_id: builderId
        });

        database.call("json_builder.value", {
            p_builder_id: builderId,
            p_value: "Hello, World!"
        });

        database.call("json_builder.value", {
            p_builder_id: builderId,
            p_value: "Hello, World!"
        });

        database.call("json_builder.close", {
            p_builder_id: builderId
        });

        database.call("json_builder.array", {
            p_builder_id: builderId
        });

        database.call("json_builder.value", {
            p_builder_id: builderId,
            p_value: "Hello, World!"
        });

        database.call("json_builder.value", {
            p_builder_id: builderId,
            p_value: "Hello, World!"
        });

        database.call("json_builder.close", {
            p_builder_id: builderId
        });

        database.call("json_builder.close", {
            p_builder_id: builderId
        });

        let events = database.call("json_builder.build_parse_events", {
            p_builder_id: builderId
        });

        expect(events).to.eql([
            {
                name: "START_ARRAY",
                value: null
            },
            {
                name: "START_ARRAY",
                value: null
            },
            {
                name: "STRING",
                value: "Hello, World!"
            },
            {
                name: "STRING",
                value: "Hello, World!"
            },
            {
                name: "END_ARRAY",
                value: null
            },
            {
                name: "START_ARRAY",
                value: null
            },
            {
                name: "STRING",
                value: "Hello, World!"
            },
            {
                name: "STRING",
                value: "Hello, World!"
            },
            {
                name: "END_ARRAY",
                value: null
            },
            {
                name: "END_ARRAY",
                value: null
            }
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
        
            database.call("json_builder.object", {
                p_builder_id: null
            });
        
        }).to.throw(/JBLR-00001/);
    
    });
    
    test("Try to start an object in a non-existing builder", function() {
    
        database.run(`
            DECLARE
            BEGIN
                dbms_session.reset_package; 
            END;
        `);
        
        expect(function() {
        
            database.call("json_builder.object", {
                p_builder_id: 1
            });
        
        }).to.throw(/JBLR-00002/);
    
    });

    test("Try to start an object in a builder with an invalid state", function() {
    
        let builderId = database.call("json_builder.create_builder");

        database.call("json_builder.value", {
            p_builder_id: builderId,
            p_value: "Hello, World!"
        });

        expect(function() {
        
            database.call("json_builder.object", {
                p_builder_id: builderId
            });
        
        }).to.throw(/JBLR-00007/);
    
    });

    test("Try to add property without a name", function() {
    
        let builderId = database.call("json_builder.create_builder");

        database.call("json_builder.object", {
            p_builder_id: builderId
        });

        expect(function() {
        
            database.call("json_builder.value", {
                p_builder_id: builderId,
                p_value: "Hello, World!"
            });
        
        }).to.throw(/JBLR-00003/);
    
    });
    
    test("Try to set property name in a builder with NULL ID", function() {
    
        database.run(`
            DECLARE
            BEGIN
                dbms_session.reset_package; 
            END;
        `);
        
        expect(function() {
        
            database.call("json_builder.name", {
                p_builder_id: null,
                p_name: "hello"
            });
        
        }).to.throw(/JBLR-00001/);
    
    });
    
    test("Try to set property name a non-existing builder", function() {
    
        database.run(`
            DECLARE
            BEGIN
                dbms_session.reset_package; 
            END;
        `);
        
        expect(function() {
        
            database.call("json_builder.name", {
                p_builder_id: 1,
                p_name: "hello"
            });
        
        }).to.throw(/JBLR-00002/);
    
    });

    test("Try to set NULL property name", function() {
    
        let builderId = database.call("json_builder.create_builder");

        expect(function() {
        
            database.call("json_builder.name", {
                p_builder_id: builderId,
                p_name: null
            });
        
        }).to.throw(/JBLR-00008/);
    
    });

    test("Try to set property name in an empty builder", function() {
    
        let builderId = database.call("json_builder.create_builder");

        expect(function() {
        
            database.call("json_builder.name", {
                p_builder_id: builderId,
                p_name: "hello"
            });
        
        }).to.throw(/JBLR-00009/);
    
    });

    test("Try to set property name while not in object", function() {
    
        let builderId = database.call("json_builder.create_builder");

        database.call("json_builder.array", {
            p_builder_id: builderId
        });

        expect(function() {
        
            database.call("json_builder.name", {
                p_builder_id: builderId,
                p_name: "hello"
            });
        
        }).to.throw(/JBLR-00009/);
    
    });
    
    test("Try to set property name twice in a row", function() {
    
        let builderId = database.call("json_builder.create_builder");

        database.call("json_builder.object", {
            p_builder_id: builderId
        });

        database.call("json_builder.name", {
            p_builder_id: builderId,
            p_name: "hello"
        });

        expect(function() {
        
            database.call("json_builder.name", {
                p_builder_id: builderId,
                p_name: "hello"
            });
        
        }).to.throw(/JBLR-00009/);
    
    });

    test("Try to end an object without property value", function() {
    
        let builderId = database.call("json_builder.create_builder");

        database.call("json_builder.object", {
            p_builder_id: builderId
        });

        database.call("json_builder.name", {
            p_builder_id: builderId,
            p_name: "hello"
        });

        expect(function() {
        
            database.call("json_builder.close", {
                p_builder_id: builderId
            });
        
        }).to.throw(/JBLR-00010/);
    
    });

    test("Build an empty object", function() {
    
        let builderId = database.call("json_builder.create_builder");

        database.call("json_builder.object", {
            p_builder_id: builderId
        });

        database.call("json_builder.close", {
            p_builder_id: builderId
        });

        let events = database.call("json_builder.build_parse_events", {
            p_builder_id: builderId
        });
    
        expect(events).to.eql([
            {
                name: "START_OBJECT",
                value: null
            },
            {
                name: "END_OBJECT",
                value: null
            }
        ]);
    
    });

    test("Build an object with one simple property", function() {
    
        let builderId = database.call("json_builder.create_builder");

        database.call("json_builder.object", {
            p_builder_id: builderId
        });

        database.call("json_builder.name", {
            p_builder_id: builderId,
            p_name: "hello"
        });

        database.call("json_builder.value", {
            p_builder_id: builderId,
            p_value: "world"
        });

        database.call("json_builder.close", {
            p_builder_id: builderId
        });

        let events = database.call("json_builder.build_parse_events", {
            p_builder_id: builderId
        });
    
        expect(events).to.eql([
            {
                name: "START_OBJECT",
                value: null
            },
            {
                name: "NAME",
                value: "hello"
            },
            {
                name: "STRING",
                value: "world"
            },
            {
                name: "END_OBJECT",
                value: null
            }
        ]);
    
    });

    test("Build an object with multiple simple property", function() {
    
        let builderId = database.call("json_builder.create_builder");

        database.call("json_builder.object", {
            p_builder_id: builderId
        });

        database.call("json_builder.name", {
            p_builder_id: builderId,
            p_name: "hello"
        });

        database.call("json_builder.value", {
            p_builder_id: builderId,
            p_value: "world"
        });

        database.call("json_builder.name", {
            p_builder_id: builderId,
            p_name: "good bye"
        });

        database.call("json_builder.value", {
            p_builder_id: builderId,
            p_value: "life"
        });

        database.call("json_builder.name", {
            p_builder_id: builderId,
            p_name: "number"
        });

        database.call3("json_builder.value", {
            p_builder_id: builderId,
            p_value: 123.321
        });

        database.call("json_builder.close", {
            p_builder_id: builderId
        });

        let events = database.call("json_builder.build_parse_events", {
            p_builder_id: builderId
        });
    
        expect(events).to.eql([
            {
                name: "START_OBJECT",
                value: null
            },
            {
                name: "NAME",
                value: "hello"
            },
            {
                name: "STRING",
                value: "world"
            },
            {
                name: "NAME",
                value: "good bye"
            },
            {
                name: "STRING",
                value: "life"
            },
            {
                name: "NAME",
                value: "number"
            },
            {
                name: "NUMBER",
                value: "123.321"
            },
            {
                name: "END_OBJECT",
                value: null
            }
        ]);
    
    });

    test("Try to build an object with duplicate property names", function() {
    
        let builderId = database.call("json_builder.create_builder");

        database.call("json_builder.object", {
            p_builder_id: builderId
        });

        database.call("json_builder.name", {
            p_builder_id: builderId,
            p_name: "hello"
        });

        database.call("json_builder.value", {
            p_builder_id: builderId,
            p_value: "world"
        });

        expect(function() {
        
            database.call("json_builder.name", {
                p_builder_id: builderId,
                p_name: "hello"
            });            
        
        }).to.throw(/JBLR-00011.*hello/);

    });

    test("Nested objects with equal property names on different levels", function() {
    
        let builderId = database.call("json_builder.create_builder");

        database.call("json_builder.object", {
            p_builder_id: builderId
        });

        database.call("json_builder.name", {
            p_builder_id: builderId,
            p_name: "hello"
        });

        database.call("json_builder.value", {
            p_builder_id: builderId,
            p_value: "world"
        });

        database.call("json_builder.name", {
            p_builder_id: builderId,
            p_name: "child"
        });

        database.call("json_builder.object", {
            p_builder_id: builderId
        });

        database.call("json_builder.name", {
            p_builder_id: builderId,
            p_name: "hello"
        });

        database.call("json_builder.value", {
            p_builder_id: builderId,
            p_value: "world"
        });

        database.call("json_builder.close", {
            p_builder_id: builderId
        });

        database.call("json_builder.close", {
            p_builder_id: builderId
        });

        let events = database.call("json_builder.build_parse_events", {
            p_builder_id: builderId
        });
    
        expect(events).to.eql([
            {
                name: "START_OBJECT",
                value: null
            },
            {
                name: "NAME",
                value: "hello"
            },
            {
                name: "STRING",
                value: "world"
            },
            {
                name: "NAME",
                value: "child"
            },
            {
                name: "START_OBJECT",
                value: null
            },
            {
                name: "NAME",
                value: "hello"
            },
            {
                name: "STRING",
                value: "world"
            },
            {
                name: "END_OBJECT",
                value: null
            },
            {
                name: "END_OBJECT",
                value: null
            }
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
        
            database.call("json_builder.build_json", {
                p_builder_id: null
            });
        
        }).to.throw(/JBLR-00001/);
    
    });
    
    test("Try to build JSON of a non-existing builder", function() {
    
        database.run(`
            DECLARE
            BEGIN
                dbms_session.reset_package; 
            END;
        `);
        
        expect(function() {
        
            database.call("json_builder.build_json", {
                p_builder_id: 1
            });
        
        }).to.throw(/JBLR-00002/);
    
    }); 

    test("Try to build JSON for an empty builder", function() {
    
        let builderId = database.call("json_builder.create_builder");

        expect(function() {
        
            database.call("json_builder.build_json", {
                p_builder_id: builderId
            });
        
        }).to.throw(/JBLR-00004/);
    
    });

    test("Build JSON using the VARCHAR2 method", function() {
    
        let builderId = database.call("json_builder.create_builder");

        database.call("json_builder.object", {
            p_builder_id: builderId
        });

        database.call("json_builder.name", {
            p_builder_id: builderId,
            p_name: "hello"
        });

        database.call("json_builder.value", {
            p_builder_id: builderId,
            p_value: "world"
        });

        database.call("json_builder.close", {
            p_builder_id: builderId
        });

        let json = database.call("json_builder.build_json", {
            p_builder_id: builderId
        });

        expect(json).to.eql({
            hello: "world"
        });
    
    });

    test("Build JSON using the CLOB method", function() {
    
        let builderId = database.call("json_builder.create_builder");

        database.call("json_builder.object", {
            p_builder_id: builderId
        });

        database.call("json_builder.name", {
            p_builder_id: builderId,
            p_name: "hello"
        });

        database.call("json_builder.value", {
            p_builder_id: builderId,
            p_value: "world"
        });

        database.call("json_builder.close", {
            p_builder_id: builderId
        });

        let json = database.call("json_builder.build_json", {
            p_builder_id: builderId
        });

        expect(json).to.eql({
            hello: "world"
        });
    
    });
    
});