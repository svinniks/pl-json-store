suite("Column name retrieval tests", function() {

    test("One simple property", function() {

        var elements = database.call("json_store.parse_query", {
            p_query: "person"
        });

        var names = database.call("json_store.get_query_column_names", {
            p_query_elements: elements
        });

        expect(names).to.eql([
            "person"
        ]);

    });

    test("One simple property with an alias", function() {

        var elements = database.call("json_store.parse_query", {
            p_query: "person AS person"
        });

        var names = database.call("json_store.get_query_column_names", {
            p_query_elements: elements
        });

        expect(names).to.eql([
            "PERSON"
        ]);

    });

    test("Two branched properties", function() {

        var elements = database.call("json_store.parse_query", {
            p_query: "person(.name, .surname)"
        });

        var names = database.call("json_store.get_query_column_names", {
            p_query_elements: elements
        });

        expect(names).to.eql([
            "name",
            "surname"
        ]);

    });

    test("Two branched properties with aliases", function() {

        var elements = database.call("json_store.parse_query", {
            p_query: "person(.name as person_name, .surname as person_surname)"
        });

        var names = database.call("json_store.get_query_column_names", {
            p_query_elements: elements
        });

        expect(names).to.eql([
            "PERSON_NAME",
            "PERSON_SURNAME"
        ]);

    });

});