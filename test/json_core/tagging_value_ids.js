suite("TAG", function() {

    test("No tag specified", function() {
    
        expect(function() {
        
            database.call("json_core.tag", {
                p_tag: null,
                p_value_id: null
            });
        
        }).to.throw(/JDOC-00042/);
    
    });
    
    test("No value ID specified", function() {
    
        expect(function() {
        
            database.call("json_core.tag", {
                p_tag: "A",
                p_value_id: null
            });
        
        }).to.throw(/JDOC-00031/);
    
    });

    test("Successfully tag a valud ID", function() {
    
        database.call("json_core.tag", {
            p_tag: "A",
            p_value_id: 123
        });
    
    });
    
});

suite("GET_TAG_ID", function() {

    test("No tag specified", function() {
    
        expect(function() {
        
            database.call("json_core.get_tag_id", {
                p_tag: null
            });
        
        }).to.throw(/JDOC-00042/);
    
    });
    
    test("Non-existing tag", function() {
    
        expect(function() {
        
            database.call("json_core.get_tag_id", {
                p_tag: "B"
            });
        
        }).to.throw(/JDOC-00043/);
    
    });

    test("Successfully tag/get a value", function() {
    
        database.call("json_core.tag", {
            p_tag: "AAA",
            p_value_id: 123123
        });

        let id = database.call("json_core.get_tag_id", {
            p_tag: "AAA"
        });

        expect(id).to.be(123123);
    
    });

});

suite("UNTAG", function() {

    test("No tag specified", function() {
    
        expect(function() {
        
            database.call("json_core.untag", {
                p_tag: null
            });
        
        }).to.throw(/JDOC-00042/);
    
    });
    
    test("Successfully tag/untag a value", function() {
    
        database.call("json_core.tag", {
            p_tag: "AAA",
            p_value_id: 123123
        });

        let id = database.call("json_core.get_tag_id", {
            p_tag: "AAA"
        });

        expect(id).to.be(123123);
    
        database.call("json_core.untag", {
            p_tag: "AAA"
        });

        expect(function() {
        
            database.call("json_core.get_tag_id", {
                p_tag: "AAA"
            });
        
        }).to.throw(/JDOC-00043/);

    });

});

