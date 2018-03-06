Jodus
=====

**Jodus** stands for **J**s**o**n **d**oc**u**ment **s**tore and is a PL/SQL library for parsing, storing and querying JSON data.

Since version 12c, Oracle database supports JSON data type and offers several methods and features for storing and working with textual JSON values in both SQL and PL/SQL. 

Jodus, however, proposes a different aproach and maybe also different use cases for JSON processing withing Oracle databases and PL/SQL environment. Originally the idea of creating this kind of JSON store appeared while developing a semi-structured document metadata processing solution in a big dinosaur-old PL/SQL system. One of the main requirements was an ability to dynamically define the structure of attributes for documents of different types. The system had to both store structured document metadata and retrieve it piecewice (down to single scalar attribute values). First of all, JSON as such perfectly fits the requirements. Secondly, reading and parsing the whole JSON document to get just one attribute value is an overhead, so it was decided to **parse all JSON documents and store them as separate related values**, creating a PL/SQL API sufficient to programmatically control the stored data.

The next view chapters describe the essentials and basic features of the Jodus JSON store as well as provides detailed installation and usage manual with code examples.

Table of contents
=================

* [Prerequisites](#prerequisites)
* [Installation](#installation)
* [Getting started](#getting-started)
* [API reference](#api-reference)
    * [Overview](#overview)
    * [Managing JSON data](#creating-anonymous-values)
        * [Creating anonymous values](#creating-anonymous-values)
        * [Setting object properties](#setting-object-properties)
        * [Deleting stored values](#deleting-stored-values)
        * [Managing arrays](#managing-arrays)
        * [Locking stored values](#locking-stored-values)
    * [Accessing JSON data](#accessing-json-data)
    * [Using the JSON parser](#using-the-json-parser)

Prerequisites
=============

Jodus is dependant on [oraspect](https://github.com/svinniks/oraspect), which is a generic logging and error handling tool for PL/SQL. Please make sure you have installed it first.

Installation
============

1. It is advisable (but not restricted) to create a separate user for the installation to avoid possible object naming conflicts. The user must have privileges to create **TABLES, INDEXES, PACKAGES (and FUNCTIONS), TYPES and SEQUENCES**.

2. To install Jodus open SQL*Plus in the project's root folder, login with your desired user and run 

```
@install.sql
```

3. All API methods are located in the `JSON_STORE` package, so the minimum access requirement is `EXECUTE` privilege on this program unit. To enable using [bind](#todo) variables `EXECUTE` privilege must be also granted on the `BIND` collection type.

```
GRANT EXECUTE ON json_store TO your_desired_user
/
GRANT EXECUTE ON bind TO your_desired_user
/
```

4. You may also want to create a public synonym for the package and the type to make calling statements a little bit shorter.

Getting started
============

The whole JSON store is basically **one huge JSON document** called `root` or `$`. All other values are usually stored somewhere under the root. The example below shows how to create a property of the root named `hello` holding the string value `world`:

```
BEGIN
    json_store.set_string('$.hello', 'world');
END;
```

And here is how to create an empty object `author` in the root:

```
BEGIN
    json_store.set_object('$.author');
END;
```

Now let's create a property `name` under `$.author`:

```
BEGIN
    json_store.set_string('$.author.name'. 'Sergejs');
END;
```

Provided we had a fresh Jodus install in the beginning, our whole stored JSON data should look like this:

```json
{
    "hello": "world",
    "author": {
        "name": "Sergejs"
    }
}
```

Now it's possible to retrieve a string property value by path:

```
SELECT json_store.get_string('$.author.name')
FROM dual
```

should return

|X      |
|-------|
|Sergejs|

There is also an option to serialize any portion of the store into JSON:

```
SELECT json_store.get_json('$.author')
FROM dual
```

should return

|X                 |
|------------------|
|{"name":"Sergejs"}|

The `SET_JSON` routine allows to create a JSON structure of arbitrary complexity in one call:

```
BEGIN
    json_store.set_json('$.author', '{
        "name": "Frank", 
        "surname": "Sinatra"
    }');
END;
```

Now `json_store.get_string('$.auhtor.name')` should return `Frank`.

:exclamation: Please note, that `set_xxx` methods overwrite the old property value regardless it's type. For example you can easily loose a big object by overwriting it with a scalar value, so be carefull! To slightly lower the chances of loosing data by overwriting, it is possible to **lock** selected values against direct modification. Please refer to the [corresponding chapter](#todo) for more information.

---

In addition to one common root object, it is possible to create anonymous unnamed JSON values. These values do not belong to the root or any other element and are only accessible by the automatically generated internal IDs. For example, an anonymous string can be created by executing:

```
DECLARE
    v_id NUMBER;
BEGIN
    v_id := json_store.create_string('Hello, World!');
END;
```

Here is another example, which creates an anonymous object with one property:

```
DECLARE
    v_id NUMBER;
BEGIN
    v_id := json_store.create_json('{"hello":"world"}');
END;
```

Now, provided that the last example has returned `v_id = 12345`, it is possible to get the whole object or to refer to it's property using the statements listed below:

```
SELECT json_store.get_string('#12345.hello')
FROM dual;

SELECT json_store.get_json('#12345')
FROM dual;
```

The aforementioned technique allows to create virtually any number of additional "roots", provided that you store their IDs for future use.

---

Similar to Oracle's [JSON_TABLE](https://docs.oracle.com/database/121/SQLRF/functions092.htm#SQLRF56973) Jodus is capable of presenting data in a relational way, by mapping JSON properties to rows and columns. Imagine there is an array of objects representing superheroes:

```
BEGIN
    json_store.set_json('$.superheroes'. '[
        {
            "name": "Bruce",
            "surname": "Wayne",
            "address": {
                "city": "Gotham"
            }
        },
        {
            "name": "Clark",
            "surname": "Kent",
            "address": {
                "city": "Metropolis"
            }
        },
        {
            "name": "Anthony",
            "surname": "Stark",
            "address": {
                "city": "Malibu"
            }
        }
    ]');
END;
```

Array's elements posess both scalar properties and nested objects. Let's query the array and render it's data as a relational data set:

```
SELECT *
FROM TABLE(json_store.get_value_table('
         $.superheroes[*] (
             .name,
             .surname,
             .address.city
         )
     '));
```

The result of the query above is:

|name   |surname|city      |
|-------|-------|----------|
|Bruce  |Wayne  |Gotham    |
|Clark  |Kent   |Metropolis|
|Anthony|Stark  |Malibu    |

While the functionality of `GET_JSON_TABLE` is quite limited at this moment, it still is a powerfull tool which may serve as the bridge from JSON to PL/SQL. Please refer to the corresponding API reference [chapter](#todo) for further details on this topic.

-----------

Jodus uses it's own JSON parser written completely in PL/SQL. It is located in the separate package called `JSON_PARSER`. If required the parser can be used separately from the store. The parser function receives a JSON value as text (`VARCHAR2` or `CLOB`) and outputs a list of parse events:

```
SELECT *
FROM TABLE(json_parser.parse('{"hello":"world"}'));
```

will output

|name        |value|
|------------|-----|
|START_OBJECT|     |
|NAME        |hello|
|STRING      |world|
|END_OBJECT  |     |

API reference
=============

Overview
--------

The Jodus public API consists of one package and one collection type:

- `PACKAGE json_store`
- `TYPE bind IS TABLE OF VARCHAR2(4000);`

Another package which is safe to use is:

- `PACKAGE json_parser`

:exclamation: All other objects are considered internal API so use them at you own risk! It is recommended to not grant any privileges on these objects to other users.

Managing JSON data
------------------

Creating anonymous values
------------------------

JSON values which don't reside in the common root `$` are called **anonymous**. Each anonymous object or array may serve as an alternative root if it is necessary to separate/hide some data from the generic JSON value tree. Anonymous JSON values do not have names associated with them and can only be accessed by internal IDs which are generated automatically by the system.

`JSON_STORE` subprograms for anonymous value creation are `CREATE_STRING`, `CREATE_NUMBER`, `CREATE_BOOLEAN`, `CREATE_NULL`, `CREATE_OBJECT`, `CREATE_ARRAY`, `CREATE_JSON` and `CREATE_JSON_CLOB`.

`CREATE_STRING`, `CREATE_NUMBER` and `CREATE_BOOLEAN` take one input argument of equivalent PL/SQL type (`VARCHAR2`, `NUMBER` and `BOOLEAN` respectively) and create corresponding scalar values. For example:

```
DECLARE
    v_id NUMBER;
BEGIN
    v_id := json_store.create_string('Hello, World!');
    v_id := json_store.create_number(-123,45);
    v_id := json_store.create_boolean(TRUE);
END;
```

Please note that you do not need to surround the string with double-quotes nor is it necessary to escape any special characters - `CREATE_STRING` will store the string as-is.

To create an anonymous `null` value either call `CREATE_NULL` or pass `NULL` value to one of `CREATE_STRING`, `CREATE_NUMBER` or `CREATE_BOOLEAN`. The next four calls are equivalent:

```
DECLARE
    v_id NUMBER;
BEGIN
    v_id := json_store.create_null;
    v_id := json_store.create_string(NULL);
    v_id := json_store.create_number(NULL);
    v_id := json_store.create_boolean(NULL);
END;
```

`CREATE_OBJECT` and `CREATE_ARRAY` functions create respectively an empty object or an empty array. While initially these structures don't contain any properties or elements, they can be later edited using any of the `SET_*` subprograms.

The most generic way of creating anonymous values is using `CREATE_JSON` or `CREATE_JSON_CLOB` subprograms. Each of these functions takes a JSON string of arbitrary complexity, parses it and saves into the store as the whole JSON structure all in just one call. It is possible to create both scalar and complex values using this subprogram. The next few examples demonstrate creation of anonymous scalar values of different types as well as creation of a null value:

```
DECLARE
    v_id NUMBER;
BEGIN
    v_id := json_store.create_json('"Hello, World!"');
    v_id := json_store.create_json('123.45');
    v_id := json_store.create_json('false');
    v_id := json_store.create_json('null');
END;
```

Please note that you **must surround values with double-quotes** when using `CREATE_JSON` to store strings. It is also required that you escape all special characters according to the JSON specification.

Below is an example of creating an array with complex elements by calling `CREATE_JSON`:

```
DECLARE
    v_id NUMBER;
BEGIN
    v_id := json_store.create_json('[
        {
            "name": "Bruce",
            "surname": "Wayne",
            "address": {
                "city": "Gotham"
            }
        },
        {
            "name": "Clark",
            "surname": "Kent",
            "address": {
                "city": "Metropolis"
            }
        },
        {
            "name": "Anthony",
            "surname": "Stark",
            "address": {
                "city": "Malibu"
            }
        }
    ]');
END;
```

Setting object properties
-------------------------

Anonymous value creation is the only JSON store operation which does not require addressing existing JSON values. All other actions, such as object property creation and modification, array extension and value deletion, require **accessing existing values** using [JSON-PATH](http://goessner.net/articles/JsonPath/)-like query expressions. Query syntax in Jodus conforms neither the complete JSON-PATH specification nor it's subset - more likely it resembles the way object properties are being referenced in JavaScript + some Jodus-unique features described below.

To refer to a property somewhere in the object hierarchy, standard JavaScript dot notation can be used:

```
$.documents.invoice.issuer
```

If property is not a "normal" JavaScript identifier (that is it does not start with a letter, _ or $ and/or contains any characters other than letters, digits, _ or $), it is possible to use the bracket notation with double-quotes:

```
$.documents.["client invoice"].issuer
```

Special characters in quoted property names can be escaped with `\`.

Array elements can be referenced using the usual bracket notation (with positive integer index inside):

```
$.document.invoice.lines[3].amount
```

It is not necessary to always bind the query to the root. It is allowed to start the path with any valid property name or array element index:

```
persons[123].name
```

This, however, is potentially unsafe as parent of the first property in the path is not checked at all which may lead to ambiguous query results in case when there are multiple equally named properties somewhere in the store. For example in the JSON structure 

```json
{
    "members": ["Sergejs"],
    "avengers": {
        "members": ["Anthony"]
    }
}
```

query `members[0]` would fail with the ambiguity error, while `$.members[0]` and `$.avengers.members[0]` would uniquely address each of the different `members` properties.

Jodus allows accessing JSON values by internal IDs:

```
DECLARE
    v_id NUMBER;
BEGIN
    v_id := json_store.create_json('{
        "name": "Sergejs",
        "address": {
            "city": "Riga"
        }
    }');
END;
```

If the example above returned `v_id = 12345`, then the `city` property of the address would be accessible by:

```
#12345.address.city
```

Note that the ID reference must not be bound to `$` when queried, because it is **NOT** located under the root, but rather is the root element itself. It is allowed, however, to include ID reference in any part of a query expression:

```
$.employees.#562736.name
```

However, usually there is no point in doing this since one ID uniquely identifies only one value.

---

`JSON_STORE` subprograms for creating and modifying object properties and array elements are `SET_STRING`, `SET_NUMBER`, `SET_BOOLEAN`, `SET_NULL`, `SET_OBJECT`, `SET_ARRAY`, `SET_JSON` and `SET_JSON_CLOB`.

There are two overloaded versions for each `SET_...` subprogram:

```
PROCEDURE set_...(...);
FUNCTION set_...(...) RETURN NUMBER;
```

`FUNCTION` versions will always return a new genreated internal ID of the property/element being affected.

The first argument of any of the `SET_...` subprograms is a string expression containing a query to the property being created or modified. 

:exclamation: The property itself may or may not exist at the moment of `SET_...` subprogram call. The parent of the property, however, must exist.

The second argument fully resembles the first argument of the `CREATE_...` methods.

Provided, that we have a fresh insallation of Jodus, the next statement will fail, because the property `person` of the root '$' does not exist:

```
BEGIN
    json_store.set_string('$.person.name', 'Sergejs');
END;
```

In order to be able to modify properties of the `person` object we must first create the object itself:

```
BEGIN
    json_store.set_object('$.person');
    json_store.set_string('$.person.name', 'Sergejs');
END;
```

The next few examples demonstrate how to further build-up the `person` object:

```
BEGIN
    json_store.set_boolean('$.person.married', TRUE);
    json_store.set_json('$.person.emails', '["svinniks@email.com", "svinniks@gmail.net"]');
END;
```

By this time the structure of `$.person` should look like this:

```json
{
    "name": "Sergejs",
    "married": true,
    "emails": [
        "svinniks@email.com",
        "svinniks@gmail.net"
    ]
}
```

When executing a `SET_...` subprogram, if the referenced property already exists, it will be **deleted** and a new property will be created with **different internal ID**. It doesn't matter how complex the old property was - the whole value tree will be erased. For example, if we now execute 

```
BEGIN
    json_store.set_string('$.person.emails', 'svinniks@email.com, svinniks@gmail.net');
END;
```

the whole array will be replaced with just one string. To protect a property from accident replacement it can be locked. Please refer to the corresponding [chapter](#todo) for details.

Deleting stored values
----------------------

Deletion of stored JSON values is rather a simple task, which can be accomplished by executing the `DELETE_VALUE` subprogram of `JSON_STORE`. The first argument must specify a valid path to the property to be removed from the store. It doesn't matter how complex the underlying structure of the addressed value is - the whole value tree will be erased. 

Here is how to remove the whole `person` object from the previous examples:

```
BEGIN
    json_store.delete_value('$.person');
END;
```

And here is how to delete an anonymous value with `ID = 54321`:

```
BEGIN
    json_store.delete_value('#54321');
END;
```

Managing arrays
---------------

Array elements can be accessed and modified by using the same set of `SET_...` subprograms. 
However, there are some features which have to be considered when working with array elements:

1. Deletion of an array element will actually replace it with a `null` value instead of complete removal. This is necessary to avoid forming gaps in the sequence of elements. For instance, after running

    ```
    BEGIN
        json_store.set_json('$.numbers', '[1, 2, 3, 4, 5]');
        json_store.delete_value('$.numbers[1]);
    END;
    ```

    the content of `$.numbers` will be

    ```
    [1, null, 3, 4, 5]
    ```

2. When modifying an element with an index which is beyond the upper bound (the length) of the array, the gap from the last existing element to the newly created one will be filled with `null` values. For example, after executing

    ```
    BEGIN
        json_store.set_json('$.numbers', '[1, 2]);
        json_store.set_number('$.numbers[4], 5);
    END;
    ```

    the content of `$.numbers` will be

    ```
    [1, 2, null, nul, 5]
    ```

Additionally there is a set of `JSON_STORE` subprograms, which work only with arrays: `GET_LENGTH`, `PUSH_STRING`, `PUSH_NUMBER`, `PUSH_BOOLEAN`, `PUSH_NULL`, `PUSH_OBJECT`, `PUSH_JSON` and `PUSH_JSON_CLOB`.

`GET_LENGTH` returns the length of an array and raises an exception for any other value. Provided that we have executed

```
BEGIN
    json_store.set_json('$.numbers', '[1, 2, 3, 4, 5]');
    json_store.set_string('$.hello', 'world');
END;
```

`json_store.get_length('$.numbers')` will return `5`, while `json_store.get_length('$.hello')` will result in an exception.

The `PUSH_...` subprograms, similarily to the JavaScript array `push()` method, add an element to the end of an array. Note that the expression in the first argument of `PUSH_...` must refer to the array itself:

```
BEGIN
    json_store.set_json('$.numbers', [1, 2, 3]);
    json_store.push_number('$.numbers', 4);
END;
```


