suite("Invalid path tests", function() {

    test("Path with optional elements", function() {

        expect(function() {
        
            database.call("json_core.parse_path", {
                p_path: "person.name?",
                p_anchored: true
            });
        
        }).to.throw(/JDC-00036/);

    });

    test("Path with branching", function() {

        expect(function() {
        
            database.call("json_core.parse_path", {
                p_path: "person(.name, .surname)",
                p_anchored: true
            });
        
        }).to.throw(/JDC-00037/);

    });

    test("Path with aliases", function() {

        expect(function() {
        
            database.call("json_core.parse_path", {
                p_path: "person(.name as name)",
                p_anchored: true
            });
        
        }).to.throw(/JDC-00038/);

    });

    test("Path with a wildcard", function() {

        expect(function() {
        
            database.call("json_core.parse_path", {
                p_path: "person(.name.*)",
                p_anchored: true
            });
        
        }).to.throw(/JDC-00047/);

    });

    test("Path with reserved field", function() {

        expect(function() {
        
            database.call("json_core.parse_path", {
                p_path: "person._id",
                p_anchored: true
            });
        
        }).to.throw(/JDC-00039/);

        expect(function() {
        
            database.call("json_core.parse_path", {
                p_path: "person._key",
                p_anchored: true
            });
        
        }).to.throw(/JDC-00039/);

        expect(function() {
        
            database.call("json_core.parse_path", {
                p_path: "person._value",
                p_anchored: true
            });
        
        }).to.throw(/JDC-00039/);

    });

    test("Path which starts with a name or with a name variable", function() {

        expect(function() {
        
            database.call("json_core.parse_path", {
                p_path: "name"
            });
        
        }).to.throw(/JDC-00046/);

        expect(function() {
        
            database.call("json_core.parse_path", {
                p_path: ":name"
            });
        
        }).to.throw(/JDC-00046/);

    });

});

suite("Valid path tests", function() {

    test("Path which starts with ID", function() {
    
        database.call("json_core.parse_path", {
            p_path: "#123.name"
        });
    
    });
    
    test("Path which starts with ID variable ", function() {
    
        database.call("json_core.parse_path", {
            p_path: "#id.name"
        });
    
    });

    test("Path which starts with anchor", function() {
    
        database.call("json_core.parse_path", {
            p_path: "name",
            p_anchored: true
        });
    
    });

});