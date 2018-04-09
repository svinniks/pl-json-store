suite("Invalid path tests", function() {

    test("Path with optional elements", function() {

        expect(function() {
        
            database.call("json_core.parse_path", {
                p_path: "person.name?"
            });
        
        }).to.throw(/JDOC-00036/);

    });

    test("Path with branching", function() {

        expect(function() {
        
            database.call("json_core.parse_path", {
                p_path: "person(.name, .surname)"
            });
        
        }).to.throw(/JDOC-00037/);

    });

    test("Path with aliases", function() {

        expect(function() {
        
            database.call("json_core.parse_path", {
                p_path: "person(.name as name)"
            });
        
        }).to.throw(/JDOC-00038/);

    });

    test("Path with reserved field", function() {

        expect(function() {
        
            database.call("json_core.parse_path", {
                p_path: "person._id"
            });
        
        }).to.throw(/JDOC-00039/);

        expect(function() {
        
            database.call("json_core.parse_path", {
                p_path: "person._key"
            });
        
        }).to.throw(/JDOC-00039/);

        expect(function() {
        
            database.call("json_core.parse_path", {
                p_path: "person._value"
            });
        
        }).to.throw(/JDOC-00039/);

    });

});