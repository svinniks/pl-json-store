database.call("json_store.set_json", {
    p_path: "$.person",
    p_content: {
        name: "Sergejs",
        age: 35
    }
});

var value = database.call("json_store.get_json", {
    p_path: `$.person`
});

info(JSON.stringify(value));

database.call("json_store.set_json", {
    p_path: '$.person.phones',
    p_content: [
        {
            type: "fixed",
            number: 1234567
        }
    ]
});

var value = database.call("json_store.get_json", {
    p_path: `$.person`
});

info(JSON.stringify(value));

database.call("json_store.set_json", {
    p_path: '$.person.phones[1]',
    p_content: {
        type: "mobile",
        number: null
    }
});

var value = database.call("json_store.get_string", {
    p_path: `$.person.phones[1].number`
});

info(JSON.stringify(value));

database.commit();