suite("TO_JSON CHAR tests", function() {

    test("NULL number conversion", function() {
    
        let value = database.call("json_core.to_json_char", {
            p_value: null
        });

        expect(value).to.be(null);
    
    });
    
    test("Zero conversion", function() {
    
        let value = database.call("json_core.to_json_char", {
            p_value: 0
        });

        expect(value).to.be("0");
    
    });
    
    test("Positive integer conversion", function() {
    
        let value = database.call("json_core.to_json_char", {
            p_value: 123
        });

        expect(value).to.be("123");
    
    });

    test("Negative integer conversion", function() {
    
        let value = database.call("json_core.to_json_char", {
            p_value: -123
        });

        expect(value).to.be("-123");
    
    });

    test("Positive decimal conversion", function() {
    
        let value = database.call("json_core.to_json_char", {
            p_value: 123.321
        });

        expect(value).to.be("123.321");
    
    });

    test("Negative decimal conversion", function() {
    
        let value = database.call("json_core.to_json_char", {
            p_value: -123.321
        });

        expect(value).to.be("-123.321");
    
    });

    test("Positive decimal conversion, zero integer part", function() {
    
        let value = database.call("json_core.to_json_char", {
            p_value: 0.321
        });

        expect(value).to.be("0.321");
    
    });

    test("Negative decimal conversion, zero integer part", function() {
    
        let value = database.call("json_core.to_json_char", {
            p_value: -0.321
        });

        expect(value).to.be("-0.321");
    
    });

    test("NULL date conversion", function() {
    
        let value = database.call2("json_core.to_json_char", {
            p_value: null
        });

        expect(value).to.be(null);
    
    });

    test("Date conversion", function() {
    
        let value = database.call2("json_core.to_json_char", {
            p_value: "2018-06-28"
        });

        expect(value).to.be("2018-06-28");
    
    });

    test("NULL boolean conversion", function() {
    
        let value = database.call3("json_core.to_json_char", {
            p_value: null
        });

        expect(value).to.be(null);
    
    });

    test("TRUE conversion", function() {
    
        let value = database.call3("json_core.to_json_char", {
            p_value: true
        });

        expect(value).to.be("true");
    
    });

    test("FALSE conversion", function() {
    
        let value = database.call3("json_core.to_json_char", {
            p_value: false
        });

        expect(value).to.be("false");
    
    });

});