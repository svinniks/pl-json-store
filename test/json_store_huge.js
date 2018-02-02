suite("Huge JSON document handling", function() {

    var document;
    var documentJSON;
    var documentId;

    setup("Create a huge array", function() {
        
        document = [];

        for (var i = 0; i < 100000; i++)
            document[i] = i;

        documentJSON = JSON.stringify(document);

    });

    test("Save anonymous huge document via the VARCHAR method", function() {

        expect(function() {
        
            database.call("json_store.create_json", {
                p_content: document
            });
        
        }).to.throw(/./);

    });

    test("Parse huge document via the CLOB method", function() {

        documentId = database.call2("json_parser.parse", {
            p_content: documentJSON
        });
        
    });

    test("Save anonymous huge document via the CLOB method", function() {

        documentId = database.call("json_store.create_json_clob", {
            p_content: document
        });
        
    });

    test("Retrieve anonymous huge document via the VARCHAR method", function() {

        expect(function() {
        
            database.call("json_store.get_json", {
                p_path: `#${documentId}`
            });
        
        }).to.throw(/./);
        
    });

    test("Retrieve anonymous huge document via the CLOB method", function() {
    
        var savedDocument = database.call("json_store.get_json_clob", {
            p_path: `#${documentId}`
        });

        expect(savedDocument).to.eql(document);
    
    });
    
    teardown("Rollback", function() {
        database.rollback();
    });

});