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
    * [Creating named properties](#creating-named-properties)
    * [Creating anonymous values](#creating-anonymous-values)
    * [Relational view of JSON data](#relational-view-of-json-data)
    * [The JSON parser](#the-json-parser)
* [API reference](#api-reference)

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

3. All API methods are located in the `JSON_STORE`, so it is enough to grant access just to this package:

```sql
GRANT EXECUTE ON json_store TO your_desired_user
/
```

4. You may also want to create a public synonym for the package to make calling statements a little bit shorter.

Getting started
============

Creating named properties
-------------------------

The whole JSON store is basically **one huge JSON document** called `root` or `$`. All other values are usually stored somewhere under the root. The example below shows how to create a property of the root named `hello`, which is a string `world`:

```sql
BEGIN
    json_store.set_string('$.hello', 'world');
END;
```

and here is how to create an empty object as a named property of the root:

```sql
BEGIN
    json_store.set_object('$.author');
END;
```

Now let's create a named property `name` under `$.author`:

```sql
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

```sql
SELECT json_store.get_string('$.author.name')
FROM dual
```

should return

|X      |
|-------|
|Sergejs|

There is also an option to serialize any portion of the store into JSON:

```sql
SELECT json_store.get_json('$.author')
FROM dual
```

should return

|X                 |
|------------------|
|{"name":"Sergejs"}|

In a similar way one can create a complex (non-scalar, which is an object or an array) named property:

```sql
BEGIN
    json_store.set_json('$.author', '{
        "name": "Frank", 
        "surname": "Sinatra"
    }');
END;
```

Now `json_store.get_string('$.auhtor.name')` should return `Frank`.

:exclamation: Please note, that `set_xxx` methods overwrite the old property value regardless it's type. For example you can easily loose a big object by overwriting it with a scalar value, so be carefull! To slightly lower the chances of loosing data by overwriting, it is possible to **lock** selected values against direct modification. Please refer to the [corresponding chapter](#todo) for more information.

Creating anonymous values
-------------------------

In addition to one common root object, it is possible to create anonymous unnamed JSON values. These values do not belong to the root or any other element and are only accessible by the automatically generated internal IDs. For example, an anonymous string can be created by executing:

```sql
DECLARE
    v_id NUMBER;
BEGIN
    v_id := json_store.create_string('Hello, World!');
END;
```

Here is another example, which creates an anonymous object with one property:

```sql
DECLARE
    v_id NUMBER;
BEGIN
    v_id := json_store.create_json('{"hello":"world"}');
END;
```

Now, provided that the last example has returned `v_id = 12345`, it is possible to get the whole value or to refer to a property using the syntax shown below:

```sql
SELECT json_store.get_string('#12345.hello')
FROM dual;

SELECT json_store.get_json('#12345')
FROM dual;
```

The aforementioned technique allows to create virtually any number of additional "roots", provided that you store element IDs for future use.

Relational view of JSON data
----------------------------

Similar to Oracle's [JSON_TABLE](https://docs.oracle.com/database/121/SQLRF/functions092.htm#SQLRF56973) Jodus is able to present data in a relational way, by mapping JSON properties to rows and columns. Imagine there is an array of objects representing superheroes:

```sql
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

```sql
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

```sql
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

```sql
BEGIN
    json_store.set_json('$.object', '{"hello":"world"}');
END;
```

the the following call will return the same list of parse events:

```sql
SELECT *
FROM TABLE(json_store.get_parse_events('$.object'));
```

API reference
=============
