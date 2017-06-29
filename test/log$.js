suite("Log tests", function() {

    setup("Setup", function() {
    
        var result = database.call("log$.reset_message_resolver", {
            
        });    
    
    });
    
    test("Register a message in the default resolver", function() {

        var result = database.call("log$.register_message", {
            p_code: "MSG-00001",
            p_message: "Hello, :1!"
        });

    });

    test("Resolve registered message", function() {
    
        var result = database.call("log$.resolve_message", {
            p_code: "MSG-00001"
        });

        expect(result).to.be("Hello, :1!");
    
    });

    test("Resolve an unexisting message", function() {
    
        var result = database.call("log$.resolve_message", {
            p_code: "MSG-00002"
        });

        expect(result).to.be.null;
    
    });

    test("Format a resolvable message without arguments", function() {
    
        var result = database.call("log$.format_message", {
            p_message: "MSG-00001"
        });

        expect(result).to.be("MSG-00001: Hello, :1!");
    
    });

    test("Format a resolvable message with argument array", function() {
    
        var result = database.call("log$.format_message", {
            p_message: "MSG-00001",
            p_arguments: ["World"]
        });

        expect(result).to.be("MSG-00001: Hello, World!");
    
    });

    test("Format a resolvable message with a one argument overloaded function", function() {
    
        var result = database.call2("log$.format_message", {
            p_message: "MSG-00001",
            p_argument1: "World"
        });

        expect(result).to.be("MSG-00001: Hello, World!");
    
    });

    test("Format an unresolvable message argument array", function() {
    
        var result = database.call("log$.format_message", {
            p_message: "MSG-00002",
            p_arguments: ["World"]
        });

        expect(result).to.be("MSG-00002 (World)");
    
    });

    test("Format an unresolvable message without arguments", function() {
    
        var result = database.call("log$.format_message", {
            p_message: "MSG-00002"
        });

        expect(result).to.be("MSG-00002");
    
    });
    
});