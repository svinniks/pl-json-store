function createValue(value) {

    let events = database.call("json_parser.parse", {
        p_content: JSON.stringify(value)
    });

    return database.call(`${implementationPackage}.create_json`, {
        p_content_parse_events: events
    });

}

suite("GET_TABLE_5 tests", function() {

    test("Object single property, no bind", function() {
    
        let valueId = createValue({
            name: "Sergejs"
        });

        let table = database.selectRows(`
                *
            FROM TABLE(${implementationType}(${valueId}).get_table_5('
                name
            '))
        `);

        expect(table).to.eql([
            ["Sergejs", null, null, null, null]
        ]);
    
    });
    
    test("Object single property, bind", function() {
    
        let valueId = createValue({
            name: "Sergejs"
        });

        let table = database.selectRows(`
                *
            FROM TABLE(${implementationType}(${valueId}).get_table_5('
                :key
            ', bind('name')))
        `);

        expect(table).to.eql([
            ["Sergejs", null, null, null, null]
        ]);
    
    });

    test("Single array element, no bind", function() {
    
        let valueId = createValue([
            "Sergejs",
            "Vinniks"
        ]);

        let table = database.selectRows(`
                *
            FROM TABLE(${implementationType}(${valueId}).get_table_5('
                [1]
            '))
        `);

        expect(table).to.eql([
            ["Vinniks", null, null, null, null]
        ]);
    
    });

    test("Single array element, bind", function() {
    
        let valueId = createValue([
            "Sergejs",
            "Vinniks"
        ]);

        let table = database.selectRows(`
                *
            FROM TABLE(${implementationType}(${valueId}).get_table_5('
                :i
            ', bind(1)))
        `);

        expect(table).to.eql([
            ["Vinniks", null, null, null, null]
        ]);
    
    });

    test("Object multiple properties, no bind", function() {
    
        let valueId = createValue({
            name: "Sergejs",
            surname: "Vinniks"
        });

        let table = database.selectRows(`
                *
            FROM TABLE(${implementationType}(${valueId}).get_table_5('
                (name, surname)
            '))
        `);

        expect(table).to.eql([
            ["Sergejs", "Vinniks", null, null, null]
        ]);
    
    });
    
    test("Object multiple properties, no bind", function() {
    
        let valueId = createValue({
            name: "Sergejs",
            surname: "Vinniks"
        });

        let table = database.selectRows(`
                *
            FROM TABLE(${implementationType}(${valueId}).get_table_5('
                (:key, surname)
            ', bind('name')))
        `);

        expect(table).to.eql([
            ["Sergejs", "Vinniks", null, null, null]
        ]);
    
    });

    test("Try to not bind all values", function() {
    
        let valueId = createValue({
            name: "Sergejs",
            surname: "Vinniks"
        });

        expect(function() {
        
            database.selectRows(`
                    *
                FROM TABLE(${implementationType}(${valueId}).get_table_5('
                    (:key, surname)
                '))
            `);
        
        }).to.throw(/JDC-00040/);

    });

    test("One property multiple times", function() {
    
        let valueId = createValue({
            name: "Sergejs",
            surname: "Vinniks"
        });

        let table = database.selectRows(`
                *
            FROM TABLE(${implementationType}(${valueId}).get_table_5('
                (name, name)
            '))
        `);

        expect(table).to.eql([
            ["Sergejs", "Sergejs", null, null, null]
        ]);
    
    });

    test("Single wildcard on a single-dimension array", function() {
    
        let valueId = createValue(["Sergejs", "Vinniks"]);

        let table = database.selectRows(`
                *
            FROM TABLE(${implementationType}(${valueId}).get_table_5('
                *
            '))
        `);

        expect(table).to.eql([
            ["Sergejs", null, null, null, null],
            ["Vinniks", null, null, null, null]
        ]);
    
    });

    test("Single wildcard on a single-dimension array, check order of elements", function() {
    
        let valueId = createValue([1, 2, 3, 4, 5, 6, 7, 8, 9, 10]);

        let table = database.selectRows(`
                *
            FROM TABLE(${implementationType}(${valueId}).get_table_5('
                *
            '))
        `);

        expect(table).to.eql([
            [1, null, null, null, null],
            [2, null, null, null, null],
            [3, null, null, null, null],
            [4, null, null, null, null],
            [5, null, null, null, null],
            [6, null, null, null, null],
            [7, null, null, null, null],
            [8, null, null, null, null],
            [9, null, null, null, null],
            [10, null, null, null, null]
        ]);
    
    });

    test("Special fields for a single value", function() {
    
        let valueId = createValue("Hello, World!");

        let table = database.selectRows(`
                *
            FROM TABLE(${implementationType}(${valueId}).get_table_5('
                (_id, _type, _key, _value)
            '))
        `);

        expect(table).to.eql([
            [`${valueId}`, "S", null, "Hello, World!", null]
        ]);
    
    });

    test("Single wildcard on a simple object", function() {
    
        let valueId = createValue({
            married: true,
            name: "Sergejs",
            surname: "Vinniks"
        });

        let table = database.selectRows(`
                *
            FROM TABLE(${implementationType}(${valueId}).get_table_5('
                *
            '))
        `);

        expect(table).to.eql([
            ["true", null, null, null, null],
            ["Sergejs", null, null, null, null],
            ["Vinniks", null, null, null, null]
        ]);
    
    });

    test("Properties from different levels", function() {
    
        let valueId = createValue({
            name: "Sergejs",
            surname: "Vinniks",
            address: {
                city: "Riga",
                street: "Raunas"
            },
            phones: ["1234567", "7654321"]
        });

        let table = database.selectRows(`
                *
            FROM TABLE(${implementationType}(${valueId}).get_table_5('
                (name, address.city, phones[0])
            '))
        `);

        expect(table).to.eql([
            ["Sergejs", "Riga", "1234567", null, null]
        ]);
    
    });

    test("Properties from different levels, branching", function() {
    
        let valueId = createValue({
            name: "Sergejs",
            surname: "Vinniks",
            addresses: {
                home: {
                    city: "Riga",
                    street: "Raunas"
                }
            },
            phones: ["1234567", "7654321"]
        });

        let table = database.selectRows(`
                *
            FROM TABLE(${implementationType}(${valueId}).get_table_5('
                (name, addresses.home(.city, .street))
            '))
        `);

        expect(table).to.eql([
            ["Sergejs", "Riga", "Raunas", null, null]
        ]);
    
    });

    test("Properties from different levels, branching, \"tailing\"", function() {
    
        let valueId = createValue({
            name: "Sergejs",
            surname: "Vinniks",
            addresses: {
                home: {
                    city: "Riga",
                    street: "Raunas"
                }
            },
            phones: ["1234567", "7654321"]
        });

        let table = database.selectRows(`
                *
            FROM TABLE(${implementationType}(${valueId}).get_table_5('
                (name, addresses.home(.city, .street), surname)
            '))
        `);

        expect(table).to.eql([
            ["Sergejs", "Riga", "Raunas", "Vinniks", null]
        ]);
    
    });

    test("Cartesian product", function() {
    
        let valueId = createValue({
            letters: ["A", "B", "C"],
            digits: [1, 2, 3]
        });

        let table = database.selectRows(`
                *
            FROM TABLE(${implementationType}(${valueId}).get_table_5('
                (letters.*, digits.*)
            '))
        `);

        expect(table).to.eql([
            ["A", "1", null, null, null],
            ["A", "2", null, null, null],
            ["A", "3", null, null, null],
            ["B", "1", null, null, null],
            ["B", "2", null, null, null],
            ["B", "3", null, null, null],
            ["C", "1", null, null, null],
            ["C", "2", null, null, null],
            ["C", "3", null, null, null],
        ]);
    
    });

    test("Select table from an array of objects", function() {
    
        let valueId = createValue([
            {
                name: "Sergejs",
                surname: "Vinniks",
                address: {
                    city: "Riga",
                    street: "Raunas"
                },
                email: "s.vinniks@email.lv"
            },
            {
                name: "Janis",
                surname: "Kalnins",
                address: {
                    city: "Aluksne",
                    street: "Rigas"
                },
                email: "j.kalnins@email.lv"
            },
            {
                name: "Peteris",
                surname: "Berzins",
                address: {
                    city: "Rezekne",
                    street: "Brivibas"
                },
                email: "p.berzins@email.lv"
            },
        ]);

        let table = database.selectRows(`
                *
            FROM TABLE(${implementationType}(${valueId}).get_table_5('
                *(
                    .name,
                    .surname,
                    .address(
                        .city,
                        .street
                    ),
                    .email
                )
            '))
        `);

        expect(table).to.eql([
            ["Sergejs", "Vinniks", "Riga", "Raunas", "s.vinniks@email.lv"],
            ["Janis", "Kalnins", "Aluksne", "Rigas", "j.kalnins@email.lv"],
            ["Peteris", "Berzins", "Rezekne", "Brivibas", "p.berzins@email.lv"]
        ]);
    
    });

    test("Query more columns than in the return type", function() {
    
        let valueId = createValue({
            name: "Sergejs"
        });

        let table = database.selectRows(`
                *
            FROM TABLE(${implementationType}(${valueId}).get_table_5('
                (name, name, name, name, name, name, name)
            '))
        `);

        expect(table).to.eql([
            ["Sergejs", "Sergejs", "Sergejs", "Sergejs", "Sergejs"]
        ]);
    
    });

    test("Single optional existing object property", function() {
    
        let valueId = createValue({
            name: "Sergejs"
        });

        let table = database.selectRows(`
                *
            FROM TABLE(${implementationType}(${valueId}).get_table_5('
                name?
            '))
        `);

        expect(table).to.eql([
            ["Sergejs", null, null, null, null,]
        ]);
    
    });

    test("Single optional non-existing object property", function() {
    
        let valueId = createValue({
            name: "Sergejs"
        });

        let table = database.selectRows(`
                *
            FROM TABLE(${implementationType}(${valueId}).get_table_5('
                suname?
            '))
        `);

        expect(table).to.eql([
            [null, null, null, null, null,]
        ]);
    
    });
    
    test("Single mandatory non-existing object property", function() {
    
        let valueId = createValue({
            name: "Sergejs"
        });

        let table = database.selectRows(`
                *
            FROM TABLE(${implementationType}(${valueId}).get_table_5('
                suname
            '))
        `);

        expect(table).to.eql([
        ]);
    
    });

    test("Single optional non-existing array element", function() {
    
        let valueId = createValue([
            "Hello, World!",
            "Good bye, World!"
        ]);

        let table = database.selectRows(`
                *
            FROM TABLE(${implementationType}(${valueId}).get_table_5('
                [10]?
            '))
        `);

        expect(table).to.eql([
            [null, null, null, null, null,]
        ]);
    
    });

    test("Two levels of optional non-existing object properties", function() {
    
        let valueId = createValue({
            name: "Sergejs"
        });

        let table = database.selectRows(`
                *
            FROM TABLE(${implementationType}(${valueId}).get_table_5('
                address?.city?
            '))
        `);

        expect(table).to.eql([
            [null, null, null, null, null,]
        ]);
    
    });

    test("Optional non-existing object property with a mandatory child", function() {
    
        let valueId = createValue({
            name: "Sergejs"
        });

        let table = database.selectRows(`
                *
            FROM TABLE(${implementationType}(${valueId}).get_table_5('
                address?.city
            '))
        `);

        expect(table).to.eql([]);
    
    });

    test("Special fields of a non-existing optional value", function() {
    
        let valueId = createValue({
            name: "Sergejs"
        });

        let table = database.selectRows(`
                *
            FROM TABLE(${implementationType}(${valueId}).get_table_5('
                surname?(._id, ._type, ._key, ._value)
            '))
        `);

        expect(table).to.eql([
            [null, null, null, null, null]
        ]);
    
    });

    test("Existing", function() {
    
        let valueId = createValue({
            name: "Sergejs"
        });

        let table = database.selectRows(`
                *
            FROM TABLE(${implementationType}(${valueId}).get_table_5('
                surname?(._id, ._type, ._key, ._value)
            '))
        `);

        expect(table).to.eql([
            [null, null, null, null, null]
        ]);
    
    });

});