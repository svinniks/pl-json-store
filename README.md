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
    * [Named JSON properties](#named-json-properties)
    * [Anonymous JSON values](#anonymous-json_values)
    * [Relational view of JSON data](#relational-view-of-json-data)
    * [The JSON parser](#the-json-parser)
* [API reference](#api-reference)
    * [Overview](#overview)

Prerequisites
=============

Jodus is dependant on [oraspect](https://github.com/svinniks/oraspect), which is a generic logging and error handling tool for PL/SQL. Please make sure you have installed it first.

Installation
============

1. It is advisable (but not restricted) to create a separate user for the installation to avoid possible object naming conflicts. The user, however, must have privileges to create **TABLES, INDEXES, PACKAGES (and FUNCTIONS), TYPES and SEQUENCES**.

2. To install Jodus open SQL*Plus in the project's root folder, login with your desired user and run 

```
@install.sql
```

3. All API methods are located in the `JSON_STORE` package, do the minimum access requirement is `EXECUTE` privilege on this program unit. To enable using [bind](#todo) variables `EXECUTE` privilege must be also granted on the `BIND` collection type.

```
GRANT EXECUTE ON json_store TO your_desired_user
/
GRANT EXECUTE ON bind TO your_desired_user
/
```

4. You may also want to create a public synonym for the package and the type to make calling statements a little bit shorter.

Getting started
============

Named JSON properties
-------------------------

The whole JSON store is basically **one huge JSON document** called `root` or `$`. All other values are usually stored somewhere under the root. The example below shows how to create a property of the root named `hello`, which is a string `world`:

```
BEGIN
    json_store.set_string('$.hello', 'world');
END;
```

and here is how to create an empty object as a named property of the root:

```
BEGIN
    json_store.set_object('$.author');
END;
```

Now let's create a named property `name` under `$.author`:

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

In a similar way one can create a complex (non-scalar, which is an object or an array) named property:

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

Anonymous JSON values
-------------------------

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

Now, provided that the last example has returned `v_id = 12345`, it is possible to get the whole value or to refer to a property using the syntax shown below:

```
SELECT json_store.get_string('#12345.hello')
FROM dual;

SELECT json_store.get_json('#12345')
FROM dual;
```

The aforementioned technique allows to create virtually any number of additional "roots", provided that you store element IDs for future use.

Relational view of JSON data
----------------------------

Similar to Oracle's [JSON_TABLE](https://docs.oracle.com/database/121/SQLRF/functions092.htm#SQLRF56973) Jodus is able to present data in a relational way, by mapping JSON properties to rows and columns. Imagine there is an array of objects representing superheroes:

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

The array consists of objects with properties `name`, `surname` and `address` of which `address` is a nested object with it's own properties. Let's query the array and render it's data as a relational data set:

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

The JSON parser
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

It is also possible to generate a list of parse events from a stored JSON value. If we create and store the object from the previos example:

```
BEGIN
    json_store.set_json('$.object', '{"hello":"world"}');
END;
```

the the following call will return identical list of parse events:

```
SELECT *
FROM TABLE(json_store.get_parse_events('$.object'));
```

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

Anonymous value creation
------------------------

JSON values which don't reside in the common root `$` are called **anonymous**. Each  anonymous object or array may serve as an alternative root if it is necessary to separate/hide some data from the generic JSON value tree. Anonymous JSON values do not have names associated with them and can only be accessed by internal IDs which are generated automatically by the system.

Below is the summary of anonymous value management subprograms of `JSON_STORE`:

Subprogram|Description
-|-
[`CREATE_STRING`](#create_string)|Creates an anonymous string value
[`CREATE_NUMBER`](#create_number)|Creates an anonymous number value
[`CREATE_BOOLEAN`](#create_boolean)|Creates an anonymous boolean value
[`CREATE_NULL`](#create_null)|Creates an anonymous null value
[`CREATE_OBJECT`](#create_object)|Creates an anonymous empty object value
[`CREATE_ARRAY`](#create_array)|Creates an anonymous array value
[`CREATE_JSON`](#create_json)|Creates an anonymous value represented by the supplied JSON string
[`CREATE_JSON_CLOB`](#create_json_clob)|Creates an anonymous value represented by the supplied JSON string

All of the anonymous value creation subprograms are functions, which create a value of the requested type and return a newly generated internal ID of the stored value. Below is the detailed description of the listed subprograms.

CREATE_STRING
-------------

```
FUNCTION create_string (
    p_value IN VARCHAR2
)
RETURN NUMBER;
```

Creates an anonymous string in the JSON store. All characters of `p_value` will be stored as-is, there is no need for quting the whole value or for escaping special characters. In case of `NULL` argument value, a new JSON null value will be created.

Returns an automatically genrated internal ID of the created value.

Example:

```
DECLARE
    v_id NUMBER;
BEGIN
    v_id := json_store.create_string('Hello, World!');
END;
```

CREATE_NUMBER
--------------

```
FUNCTION create_number (
    p_value IN NUMBER
)
RETURN NUMBER;
```

Creates an anonymous number in the JSON store. In case of `NULL` argument value, a new JSON `null` value will be created.

Returns an automatically genrated internal ID of the created value.

Example:

```
DECLARE
    v_id NUMBER;
BEGIN
    v_id := json_store.create_number(-123.45);
END;
```

CREATE_BOOLEAN
--------------

```
FUNCTION create_number (
    p_value IN BOOLEAN
)
RETURN NUMBER;
```

Creates an anonymous boolean in the JSON store. In case of `NULL` argument value, a new JSON `null` value will be created.

Returns an automatically genrated internal ID of the created value.

Example:

```
DECLARE
    v_id NUMBER;
BEGIN
    v_id := json_store.create_boolean(TRUE);
END;
```

CREATE_OBJECT
--------------

```
FUNCTION create_object
RETURN NUMBER;
```

Creates an anonymous empty object.

Returns an automatically genrated internal ID of the created value. Despite the fact that the object is initially empty, it can be further complemented using one of the `SET_*` subprograms.

Example:

```
DECLARE
    v_id NUMBER;
BEGIN
    v_id := json_store.create_object;
END;
```

CREATE_ARRAY
--------------

```
FUNCTION create_array
RETURN NUMBER;
```

Creates an anonymous empty array.

Returns an automatically genrated internal ID of the created value. Despite the fact that the array is initially empty, it can be further complemented using one of the `SET_*` subprograms.

Example:

```
DECLARE
    v_id NUMBER;
BEGIN
    v_id := json_store.create_array;
END;
```

CREATE_JSON
--------------

```
FUNCTION create_json (
    p_content IN VARCHAR2
)
RETURN NUMBER;
```

Creates an anonymous JSON value, which is represented by the supplied JSON string.
Any valid JSON may be passed through `p_content`, including arrays and objects with complex nested structure. Thus, to create a string using `CREATE_JSON`, the value must be surrounded with double-quotes and all special characters must be correctly escaped.

If JSON size exceeds 32K, [`CREATE_JSON_CLOB`](#create_json_clob) must be used.

Returns an automatically genrated internal ID of the created value.

Example:

```
DECLARE
    v_string_id NUMBER;
    v_object_id NUMBER;
BEGIN

    v_string_id := json_store.create_json('"Hello, World!"');

    v_object_id := json_store.create_json('{"hello":"world"}');

END;
```

CREATE_JSON_CLOB
--------------

```
FUNCTION create_json_clob (
    p_content IN CLOB
)
RETURN NUMBER;
```

A CLOB version of [`CREATE_JSON`](#create_json).

Almost all `JSON_STORE` subprograms take a [JSON-PATH](http://goessner.net/articles/JsonPath/)-like query string as the first argument. This query defines the location of the JSON values being addresses within the store. Currently the syntax of the Jodus JSON query conforms neither the complete JSON-PATH specification nor it's subset - more likely it resembles the way object properties are being referenced in JavaScript + some Jodus-unique features described below.

To refer a property somewhere deep in the object hierarchy, standard JavaScript dot notation can be used:

```
$.documents.invoice.issuer
```

If property is not a "normal" JavaScript identifier (that is does not start with a letter, _ or $ and/or contains any character other than a letter, a digit, _ or $), it is possible to use the bracket notation with double-quotes:

```
$.documents.["client invoice"].issuer
```

Array elements can be referenced using the usual bracket notation (with positive integer index inside the brackets):

```
$.document.invoice.lines[3].amount
```

It is not necessary to always bind the query to the root `$`. It is allowed to start the path with any valid property name or array element index:

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

Named JSON value creation
------------------------

Normally, the complete JSON store is one huge object called `root` or `$`. All other stored JSON structures are placed somewhere under the root. For example, if you were going to store some document metadata in the JSON store, you would create an object property `documents` in the root and place all you document metadata as nested objects of `$.documents`:

```json
{
    "documents": {
        "1": {
            "mimetype": "text/plain",
            "filename": "readme.txt",
            ...
        },
        "2": {
            "mimetype": "image/jpeg",
            "filename": "photo.jpg",
            ...
        },
        ...
    }
}
```

There is a set of `JSON_STORE` subprograms for creating and altering named properties anywhere in the store:

```
set_string
set_number
set_boolean
set_null
set_object
set_array
set_json
set_json_clob
```

There is both a `PROCEDURE` and a `FUNCTION` version of each method. The procedure version just creates a new value in the store, while the function version additionally returnes the internal ID of the created value record.

All of the methods accepts a path of the value being created
