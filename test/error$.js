suite("Error tests", function() {

    setup("Setup", function() {

        database.call("log$.reset_message_resolver");

        database.call("log$.register_message", {
            p_code: "MSG-00001",
            p_message: "Hello, :1!"
        });

        database.call("log$.register_message", {
            p_code: "MSG-00002",
            p_message: "Good bye, World!"
        });

    });

    test("Raise a formatted message with argument array", function() {

        expect(function() {
        
            var result = database.call("error$.raise", {
                p_message: "MSG-00001",
                p_arguments: ["World"]
            });
        
        }).to.throw(/MSG-00001: Hello, World!/);

    });

    test("Raise a formatted message with one argument overloaded version", function() {

        expect(function() {
        
            var result = database.call2("error$.raise", {
                p_message: "MSG-00001",
                p_argument1: "World"
            });
        
        }).to.throw(/MSG-00001: Hello, World!/);

    });

    test("Raise a formatted message without argumens", function() {

        expect(function() {
        
            var result = database.call("error$.raise", {
                p_message: "MSG-00002"
            });
        
        }).to.throw(/MSG-00002: Good bye, World!/);

    });

});