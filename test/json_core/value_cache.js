suite("JSON value LRU cache tests", function() {

    let values = [];

    setup("Reset value cache, check cache content", function() {

        database.call("json_core.reset_value_cache");

        let cache = database.call("json_core.get_cached_values");

        expect(cache).to.eql([]);

    });

    test("Try setting NULL cache capacity", function() {
    
        expect(function() {
        
            database.call("json_core.set_value_cache_capacity", {
                p_capacity: null
            });
        
        }).to.throw(/JDOC-00032.*NULL/);
    
    });
    
    test("Try setting invalid cache capacity", function() {
    
        expect(function() {
        
            database.call("json_core.set_value_cache_capacity", {
                p_capacity: 0
            });
        
        }).to.throw(/JDOC-00032.*0/);
    
    });

    setup("Create several anonymous values, set cache capacity", function() {
    
        for (let i = 1; i <= 6; i++) {

            let valueId = database.call("json_store.create_string", {
                p_value: `value_${i}`
            });

            values.push(
                database.selectObject(`*
                    FROM json_values
                    WHERE id = ${valueId}
                `)
            );

        }

        database.call("json_core.set_value_cache_capacity", {
            p_capacity: 4
        });
    
    });
    
    test("Try getting a value with NULL ID", function() {
    
        expect(function() {
        
            let value = database.call("json_core.get_value", {
                p_id: null
            });
        
        }).to.throw(/JDOC-00031/);
    
    });

    test("Try getting a non-existing value", function() {
    
        expect(function() {
        
            let value = database.call("json_core.get_value", {
                p_id: -1
            });
        
        }).to.throw(/JDOC-00009/);
    
    });
    
    test("Retrieve a value, check cache content", function() {
    
        database.call("json_core.get_value", {
            p_id: values[0].id
        });

        let cache = database.call("json_core.get_cached_values");
    
        expect(cache).to.eql([values[0]]);

    });
    
    test("Retrieve the same value, check cache content", function() {
    
        database.call("json_core.get_value", {
            p_id: values[0].id
        });

        let cache = database.call("json_core.get_cached_values");
    
        expect(cache).to.eql([values[0]]);

    });

    test("Clear the cache, check cache content", function() {
    
        database.call("json_core.reset_value_cache");
    
        let cache = database.call("json_core.get_cached_values");
    
        expect(cache).to.eql([]);

    });
    
    test("Retrieve three different values, check cache content", function() {

        for (let i = 0; i < 3; i++) {
            database.call("json_core.get_value", {
                p_id: values[i].id
            });
        }

        let cache = database.call("json_core.get_cached_values");
    
        expect(cache).to.eql([
            values[2],
            values[1],
            values[0]
        ]);

    });

    test("Retrieve the oldest cached value, check cache content", function() {

        database.call("json_core.get_value", {
            p_id: values[0].id
        });
        
        let cache = database.call("json_core.get_cached_values");
    
        expect(cache).to.eql([
            values[0],
            values[2],
            values[1]
        ]);

    });

    setup("Reset the cache", function() {
    
        database.call("json_core.reset_value_cache");

        let cache = database.call("json_core.get_cached_values");
    
        expect(cache).to.eql([]);
    
    });
    
    test("Retrieve more values than the cache can hold, check cache content", function() {

        for (let i = 0; i < 6; i++) {
            database.call("json_core.get_value", {
                p_id: values[i].id
            });
        }

        let cache = database.call("json_core.get_cached_values");
    
        expect(cache).to.eql([
            values[5],
            values[4],
            values[3],
            values[2]
        ]);

    });

    test("Decrease cache capacity when the cache is full, check cache content", function() {
    
        database.call("json_core.set_value_cache_capacity", {
            p_capacity: 2
        });

        let cache = database.call("json_core.get_cached_values");
    
        expect(cache).to.eql([
            values[5],
            values[4]
        ]);
    
    });
    
    test("Value cache stability test", function() {
    
        const operationCount = 1000;
        let valueIds = [];

        for (let i = 1; i <= operationCount; i++) {
            valueIds.push(values[Math.floor(Math.random() * 6)].id);
        }

        database.call("json_core.set_value_cache_capacity", {
            p_capacity: 4
        });

        for (let i = 0; i < operationCount; i++) {
            database.call("json_core.get_value", {
                p_id: valueIds[i]
            });
        }

        let lastValueIds = [];
        let i = operationCount;

        while (lastValueIds.length < 4) {
            if (lastValueIds.indexOf(valueIds[--i]) == -1) {
                lastValueIds.push(valueIds[i]);
            }
        }

        let valueMap = {};

        for (i = 0; i < values.length; i++) {
            valueMap[values[i].id] = values[i];
        }

        let lastValues = [];

        for (let id of lastValueIds) {
            lastValues.push(valueMap[id]);
        }

        let cache = database.call("json_core.get_cached_values");
    
        expect(cache).to.eql(lastValues);

    });
    

    teardown("Rollback", function() {
        database.rollback();
    });
    
});