const VALUE_QUERY = 'V';
const PROPERTY_QUERY = 'P';
const TABLE_QUERY = 'T';

function resetPackage() {
    database.run(`
        BEGIN
            dbms_session.reset_package;
        END;
    `);
}

suite("Value query statement generation", function() {

    test("One property name", function() {
    
        resetPackage();

        let elementI = database.call("json_core.parse_query", {
            p_query: "person"
        });

        let statement = database.call("persistent_json_store.get_query_statement", {
            p_query_element_i: elementI,
            p_query_type: VALUE_QUERY
        });

        expect(statement.statement).to.be("SELECT /*+ FIRST_ROWS ORDERED */ j1.* FROM json_values j1 WHERE j1.name=:const1");
    
    });

    test("One variable", function() {
    
        resetPackage();

        let elementI = database.call("json_core.parse_query", {
            p_query: ":name"
        });

        let statement = database.call("persistent_json_store.get_query_statement", {
            p_query_element_i: elementI,
            p_query_type: VALUE_QUERY
        });

        expect(statement.statement).to.be("SELECT /*+ FIRST_ROWS ORDERED */ j1.* FROM json_values j1 WHERE j1.name=:var1");
    
    });
    
    test("One ID reference", function() {
    
        resetPackage();

        let elementI = database.call("json_core.parse_query", {
            p_query: "#123"
        });

        let statement = database.call("persistent_json_store.get_query_statement", {
            p_query_element_i: elementI,
            p_query_type: VALUE_QUERY
        });

        expect(statement.statement).to.be("SELECT /*+ FIRST_ROWS ORDERED */ j1.* FROM json_values j1 WHERE j1.id=TO_NUMBER(:const1)");
    
    });

    test("One ID variable", function() {
    
        resetPackage();

        let elementI = database.call("json_core.parse_query", {
            p_query: "#id"
        });

        let statement = database.call("persistent_json_store.get_query_statement", {
            p_query_element_i: elementI,
            p_query_type: VALUE_QUERY
        });

        expect(statement.statement).to.be("SELECT /*+ FIRST_ROWS ORDERED */ j1.* FROM json_values j1 WHERE j1.id=TO_NUMBER(:var1)");
    
    });

    test("One root", function() {
    
        resetPackage();

        let elementI = database.call("json_core.parse_query", {
            p_query: "$"
        });

        let statement = database.call("persistent_json_store.get_query_statement", {
            p_query_element_i: elementI,
            p_query_type: VALUE_QUERY
        });

        expect(statement.statement).to.be("SELECT /*+ FIRST_ROWS ORDERED */ j1.* FROM json_values j1 WHERE j1.id=TO_NUMBER(:const1)");
    
    });

    test("One wildcard", function() {
    
        resetPackage();

        let elementI = database.call("json_core.parse_query", {
            p_query: "*"
        });

        let statement = database.call("persistent_json_store.get_query_statement", {
            p_query_element_i: elementI,
            p_query_type: VALUE_QUERY
        });

        expect(statement.statement).to.be("SELECT /*+ FIRST_ROWS ORDERED */ j1.* FROM json_values j1");
    
    });

    test("Anchor with one property name", function() {
    
        resetPackage();

        let elementI = database.call("json_core.parse_query", {
            p_query: "person",
            p_anchored: true
        });

        let statement = database.call("persistent_json_store.get_query_statement", {
            p_query_element_i: elementI,
            p_query_type: VALUE_QUERY
        });

        expect(statement.statement).to.be("SELECT /*+ FIRST_ROWS ORDERED */ j2.* FROM json_values j1,json_values j2 WHERE j1.id=TO_NUMBER(:anchor) AND j2.parent_id=j1.id AND j2.name=:const1");
    
    });

    test("Two different property names", function() {
    
        resetPackage();

        let elementI = database.call("json_core.parse_query", {
            p_query: "person.name"
        });

        let statement = database.call("persistent_json_store.get_query_statement", {
            p_query_element_i: elementI,
            p_query_type: VALUE_QUERY
        });

        expect(statement.statement).to.be("SELECT /*+ FIRST_ROWS ORDERED */ j2.* FROM json_values j1,json_values j2 WHERE j1.name=:const1 AND j2.parent_id=j1.id AND j2.name=:const2");
    
    });

    test("Two equal property names", function() {
    
        resetPackage();

        let elementI = database.call("json_core.parse_query", {
            p_query: "person.person"
        });

        let statement = database.call("persistent_json_store.get_query_statement", {
            p_query_element_i: elementI,
            p_query_type: VALUE_QUERY
        });

        expect(statement.statement).to.be("SELECT /*+ FIRST_ROWS ORDERED */ j2.* FROM json_values j1,json_values j2 WHERE j1.name=:const1 AND j2.parent_id=j1.id AND j2.name=:const2");
    
    });

    test("Two different name variables", function() {
    
        resetPackage();

        let elementI = database.call("json_core.parse_query", {
            p_query: ":name1.:name2"
        });

        let statement = database.call("persistent_json_store.get_query_statement", {
            p_query_element_i: elementI,
            p_query_type: VALUE_QUERY
        });

        expect(statement.statement).to.be("SELECT /*+ FIRST_ROWS ORDERED */ j2.* FROM json_values j1,json_values j2 WHERE j1.name=:var1 AND j2.parent_id=j1.id AND j2.name=:var2");
    
    });

    test("Two equal name variables", function() {
    
        resetPackage();

        let elementI = database.call("json_core.parse_query", {
            p_query: ":name1.:name1"
        });

        let statement = database.call("persistent_json_store.get_query_statement", {
            p_query_element_i: elementI,
            p_query_type: VALUE_QUERY
        });

        expect(statement.statement).to.be("SELECT /*+ FIRST_ROWS ORDERED */ j2.* FROM json_values j1,json_values j2 WHERE j1.name=:var1 AND j2.parent_id=j1.id AND j2.name=:var1");
    
    });

    test("Two different ID variables", function() {
    
        resetPackage();

        let elementI = database.call("json_core.parse_query", {
            p_query: "#id1.#id2"
        });

        let statement = database.call("persistent_json_store.get_query_statement", {
            p_query_element_i: elementI,
            p_query_type: VALUE_QUERY
        });

        expect(statement.statement).to.be("SELECT /*+ FIRST_ROWS ORDERED */ j2.* FROM json_values j1,json_values j2 WHERE j1.id=TO_NUMBER(:var1) AND j2.parent_id=j1.id AND j2.id=TO_NUMBER(:var2)");
    
    });

    test("Two equal ID variables", function() {
    
        resetPackage();

        let elementI = database.call("json_core.parse_query", {
            p_query: "#id1.#id1"
        });

        let statement = database.call("persistent_json_store.get_query_statement", {
            p_query_element_i: elementI,
            p_query_type: VALUE_QUERY
        });

        expect(statement.statement).to.be("SELECT /*+ FIRST_ROWS ORDERED */ j2.* FROM json_values j1,json_values j2 WHERE j1.id=TO_NUMBER(:var1) AND j2.parent_id=j1.id AND j2.id=TO_NUMBER(:var1)");
    
    });

    test("Two different name and ID variables", function() {
    
        resetPackage();

        let elementI = database.call("json_core.parse_query", {
            p_query: "#id1.:id2"
        });

        let statement = database.call("persistent_json_store.get_query_statement", {
            p_query_element_i: elementI,
            p_query_type: VALUE_QUERY
        });

        expect(statement.statement).to.be("SELECT /*+ FIRST_ROWS ORDERED */ j2.* FROM json_values j1,json_values j2 WHERE j1.id=TO_NUMBER(:var1) AND j2.parent_id=j1.id AND j2.name=:var2");
    
    });

    test("Complex combination of property names, ID references, name and ID variables", function() {
    
        resetPackage();

        let elementI = database.call("json_core.parse_query", {
            p_query: "$.persons.*.:property.subproperty"
        });

        let statement = database.call("persistent_json_store.get_query_statement", {
            p_query_element_i: elementI,
            p_query_type: VALUE_QUERY
        });

        expect(statement.statement).to.be("SELECT /*+ FIRST_ROWS ORDERED */ j5.* FROM json_values j1,json_values j2,json_values j3,json_values j4,json_values j5 WHERE j1.id=TO_NUMBER(:const1) AND j2.parent_id=j1.id AND j2.name=:const2 AND j3.parent_id=j2.id AND j4.parent_id=j3.id AND j4.name=:var1 AND j5.parent_id=j4.id AND j5.name=:const3");
    
    });

});

suite("Property query statement generation", function() {

    test("Two property names", function() {
    
        resetPackage();

        let elementI = database.call("json_core.parse_query", {
            p_query: "person.name"
        });

        let statement = database.call("persistent_json_store.get_query_statement", {
            p_query_element_i: elementI,
            p_query_type: PROPERTY_QUERY
        });

        expect(statement.statement).to.be("SELECT /*+ FIRST_ROWS ORDERED */ j1.id,j1.type,j2.id,j2.type,:const2 AS name,j2.locked FROM json_values j1,json_values j2 WHERE j1.name=:const1 AND j2.parent_id(+)=j1.id AND j2.name(+)=:const2");
    
    });

    test("Property name and property variable", function() {
    
        resetPackage();

        let elementI = database.call("json_core.parse_query", {
            p_query: "person.:name"
        });

        let statement = database.call("persistent_json_store.get_query_statement", {
            p_query_element_i: elementI,
            p_query_type: PROPERTY_QUERY
        });

        expect(statement.statement).to.be("SELECT /*+ FIRST_ROWS ORDERED */ j1.id,j1.type,j2.id,j2.type,:var1 AS name,j2.locked FROM json_values j1,json_values j2 WHERE j1.name=:const1 AND j2.parent_id(+)=j1.id AND j2.name(+)=:var1");
    
    });

    test("ID variable and property variable", function() {
    
        resetPackage();

        let elementI = database.call("json_core.parse_query", {
            p_query: "$.:name"
        });

        let statement = database.call("persistent_json_store.get_query_statement", {
            p_query_element_i: elementI,
            p_query_type: PROPERTY_QUERY
        });

        expect(statement.statement).to.be("SELECT /*+ FIRST_ROWS ORDERED */ j1.id,j1.type,j2.id,j2.type,:var1 AS name,j2.locked FROM json_values j1,json_values j2 WHERE j1.id=TO_NUMBER(:const1) AND j2.parent_id(+)=j1.id AND j2.name(+)=:var1");
    
    });

    test("Longer property query", function() {
    
        resetPackage();

        let elementI = database.call("json_core.parse_query", {
            p_query: "$.persons[:i].:property"
        });

        let statement = database.call("persistent_json_store.get_query_statement", {
            p_query_element_i: elementI,
            p_query_type: PROPERTY_QUERY
        });

        expect(statement.statement).to.be("SELECT /*+ FIRST_ROWS ORDERED */ j3.id,j3.type,j4.id,j4.type,:var2 AS name,j4.locked FROM json_values j1,json_values j2,json_values j3,json_values j4 WHERE j1.id=TO_NUMBER(:const1) AND j2.parent_id=j1.id AND j2.name=:const2 AND j3.parent_id=j2.id AND j3.name=:var1 AND j4.parent_id(+)=j3.id AND j4.name(+)=:var2");
    
    });

});

suite("Value table query statement generation", function() {

    test("Single property name", function() {
    
        resetPackage();

        let elementI = database.call("json_core.parse_query", {
            p_query: "name"
        });

        let statement = database.call("persistent_json_store.get_query_statement", {
            p_query_element_i: elementI,
            p_query_type: TABLE_QUERY
        });

        expect(statement.statement).to.be("SELECT /*+ FIRST_ROWS ORDERED */ j1.value FROM json_values j1 WHERE j1.name=:const1");
    
    });

    test("Single name variable", function() {
    
        resetPackage();

        let elementI = database.call("json_core.parse_query", {
            p_query: ":name"
        });

        let statement = database.call("persistent_json_store.get_query_statement", {
            p_query_element_i: elementI,
            p_query_type: TABLE_QUERY
        });

        expect(statement.statement).to.be("SELECT /*+ FIRST_ROWS ORDERED */ j1.value FROM json_values j1 WHERE j1.name=:var1");
    
    });

    test("Single wildcard", function() {
    
        resetPackage();

        let elementI = database.call("json_core.parse_query", {
            p_query: "*"
        });

        let statement = database.call("persistent_json_store.get_query_statement", {
            p_query_element_i: elementI,
            p_query_type: TABLE_QUERY
        });

        expect(statement.statement).to.be("SELECT /*+ FIRST_ROWS ORDERED */ j1.value FROM json_values j1");
    
    });

    test("Two property names in depth", function() {
    
        resetPackage();

        let elementI = database.call("json_core.parse_query", {
            p_query: "person.name"
        });

        let statement = database.call("persistent_json_store.get_query_statement", {
            p_query_element_i: elementI,
            p_query_type: TABLE_QUERY
        });

        expect(statement.statement).to.be("SELECT /*+ FIRST_ROWS ORDERED */ j2.value FROM json_values j1,json_values j2 WHERE j1.name=:const1 AND j2.parent_id=j1.id AND j2.name=:const2");
    
    });

    test("Two property names in depth, optional second property", function() {
    
        resetPackage();

        let elementI = database.call("json_core.parse_query", {
            p_query: "person.name?"
        });

        let statement = database.call("persistent_json_store.get_query_statement", {
            p_query_element_i: elementI,
            p_query_type: TABLE_QUERY
        });

        expect(statement.statement).to.be("SELECT /*+ FIRST_ROWS ORDERED */ j2.value FROM json_values j1,json_values j2 WHERE j1.name=:const1 AND j2.parent_id(+)=j1.id AND j2.name(+)=:const2");
    
    });

    test("Reserved field _key of a property", function() {
    
        resetPackage();

        let elementI = database.call("json_core.parse_query", {
            p_query: "person._key"
        });

        let statement = database.call("persistent_json_store.get_query_statement", {
            p_query_element_i: elementI,
            p_query_type: TABLE_QUERY
        });

        expect(statement.statement).to.be("SELECT /*+ FIRST_ROWS ORDERED */ j1.name FROM json_values j1 WHERE j1.name=:const1");
    
    });

    test("Reserved field _id of a property", function() {
    
        resetPackage();

        let elementI = database.call("json_core.parse_query", {
            p_query: "person._id"
        });

        let statement = database.call("persistent_json_store.get_query_statement", {
            p_query_element_i: elementI,
            p_query_type: TABLE_QUERY
        });

        expect(statement.statement).to.be("SELECT /*+ FIRST_ROWS ORDERED */ j1.id FROM json_values j1 WHERE j1.name=:const1");
    
    });

    test("Reserved field _value of a property", function() {
    
        resetPackage();

        let elementI = database.call("json_core.parse_query", {
            p_query: "person._value"
        });

        let statement = database.call("persistent_json_store.get_query_statement", {
            p_query_element_i: elementI,
            p_query_type: TABLE_QUERY
        });

        expect(statement.statement).to.be("SELECT /*+ FIRST_ROWS ORDERED */ j1.value FROM json_values j1 WHERE j1.name=:const1");
    
    });

    test("Branching root with two property names", function() {
    
        resetPackage();

        let elementI = database.call("json_core.parse_query", {
            p_query: "(name, surname)"
        });

        let statement = database.call("persistent_json_store.get_query_statement", {
            p_query_element_i: elementI,
            p_query_type: TABLE_QUERY
        });

        expect(statement.statement).to.be("SELECT /*+ FIRST_ROWS ORDERED */ j1.value,j2.value FROM json_values j1,json_values j2 WHERE j1.name=:const1 AND j2.name=:const2");
    
    });

    test("Branched property with two sibling subproperties", function() {
    
        resetPackage();

        let elementI = database.call("json_core.parse_query", {
            p_query: "person(.name, .surname)"
        });

        let statement = database.call("persistent_json_store.get_query_statement", {
            p_query_element_i: elementI,
            p_query_type: TABLE_QUERY
        });

        expect(statement.statement).to.be("SELECT /*+ FIRST_ROWS ORDERED */ j2.value,j3.value FROM json_values j1,json_values j2,json_values j3 WHERE j1.name=:const1 AND j2.parent_id=j1.id AND j2.name=:const2 AND j3.parent_id=j1.id AND j3.name=:const3");
    
    });

    test("Branched property with two sibling subproperties, one subproperty optional", function() {
    
        resetPackage();

        let elementI = database.call("json_core.parse_query", {
            p_query: "person(.name?, .surname)"
        });

        let statement = database.call("persistent_json_store.get_query_statement", {
            p_query_element_i: elementI,
            p_query_type: TABLE_QUERY
        });

        expect(statement.statement).to.be("SELECT /*+ FIRST_ROWS ORDERED */ j2.value,j3.value FROM json_values j1,json_values j2,json_values j3 WHERE j1.name=:const1 AND j2.parent_id(+)=j1.id AND j2.name(+)=:const2 AND j3.parent_id=j1.id AND j3.name=:const3");
    
    });

    test("Branched property with one subproperty and one reserved field", function() {
    
        resetPackage();

        let elementI = database.call("json_core.parse_query", {
            p_query: "person(.name, ._id)"
        });

        let statement = database.call("persistent_json_store.get_query_statement", {
            p_query_element_i: elementI,
            p_query_type: TABLE_QUERY
        });

        expect(statement.statement).to.be("SELECT /*+ FIRST_ROWS ORDERED */ j2.value,j1.id FROM json_values j1,json_values j2 WHERE j1.name=:const1 AND j2.parent_id=j1.id AND j2.name=:const2");
    
    });

    test("Branched property with just reserved fields", function() {
    
        resetPackage();

        let elementI = database.call("json_core.parse_query", {
            p_query: "person(._key, ._value)"
        });

        let statement = database.call("persistent_json_store.get_query_statement", {
            p_query_element_i: elementI,
            p_query_type: TABLE_QUERY
        });

        expect(statement.statement).to.be("SELECT /*+ FIRST_ROWS ORDERED */ j1.name,j1.value FROM json_values j1 WHERE j1.name=:const1");
    
    });

    test("Complex query with different elements", function() {
    
        resetPackage();

        let elementI = database.call("json_core.parse_query", {
            p_query: `
                $.persons.*(
                    .name,
                    .surname,
                    .address(
                        .street,
                        .house?,
                        .city
                    ),
                    .:property?,
                    ._id
                )
            `
        });

        let statement = database.call("persistent_json_store.get_query_statement", {
            p_query_element_i: elementI,
            p_query_type: TABLE_QUERY
        });

        expect(statement.statement).to.be("SELECT /*+ FIRST_ROWS ORDERED */ j4.value,j5.value,j7.value,j8.value,j9.value,j10.value,j3.id FROM json_values j1,json_values j2,json_values j3,json_values j4,json_values j5,json_values j6,json_values j7,json_values j8,json_values j9,json_values j10 WHERE j1.id=TO_NUMBER(:const1) AND j2.parent_id=j1.id AND j2.name=:const2 AND j3.parent_id=j2.id AND j4.parent_id=j3.id AND j4.name=:const3 AND j5.parent_id=j3.id AND j5.name=:const4 AND j6.parent_id=j3.id AND j6.name=:const5 AND j7.parent_id=j6.id AND j7.name=:const6 AND j8.parent_id(+)=j6.id AND j8.name(+)=:const7 AND j9.parent_id=j6.id AND j9.name=:const8 AND j10.parent_id(+)=j3.id AND j10.name(+)=:var1");
    
    });

    test("Huge query generation test", function() {
    
        let query = "property";

        for (let i = 1; i <= 500; i++) {
            query = query + ".property";
        }

        let elementI = database.call("json_core.parse_query", {
            p_query: query
        });

        let statement = database.call("persistent_json_store.get_query_statement", {
            p_query_element_i: elementI,
            p_query_type: TABLE_QUERY
        });

        expect(statement.statement_clob).to.not.be(null);
    
    });
    

});

