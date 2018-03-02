Jodus
=====

**Jodus** stands for **J**s**o**n **d**oc**u**ment **s**tore and is a PL/SQL library for parsing, storing and querying JSON data.

Since version 12c, Oracle database supports JSON data type and offers several methods and features for storing and working with textual JSON values in both SQL and PL/SQL. 

Jodus, however, proposes a different aproach and maybe also different use cases for JSON processing withing Oracle databases and PL/SQL environment. Originally the idea of creating this kind of JSON store appeared while developing a semi-structured document metadata processing solution in a big dinosaur-old PL/SQL system. One of the main requirements was an ability to dynamically define the structure of attributes for documents of different types. The system had to both store structured document metadata and retrieve it piecewice (down to single scalar attribute values). First of all, JSON as such perfectly fits the requirements. Secondly, reading and parsing the whole JSON document to get just one attribute value is an overhead, so it was decided to **parse all JSON documents and store them as separate related values**, creating a PL/SQL API sufficient to programmatically control the stored data.

The next view chapters describe the essentials and basic features of the Jodus JSON store as well as provides detailed installation and usage manual with code examples.

Table of contents
=================

<!--ts-->
* [Prerequisites](#prerequisites)
* [Installation](#installation)
* [Jodus basics](#jodus-basics)
    * [Creating named properties](#creating-named-properties)
    * [Creating anonymous values](#creating-anonymous-values)
* [API reference](#api-reference)
<!--te-->

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

Jodus basics
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

Providing we had a fresh Jodus install in the beginning, our whole stored JSON data should look like this:

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

|X|
|-|
|Sergejs|

There is also an option to serialize any portion of the store into a JSON:

```sql
SELECT json_store.get_json('$.author')
FROM dual
```

should return

|X|
|-|
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

:exclamation: Please note, that `set_xxx` methods overwrite the old property value regardless it's type. For example you can easilty loose a big object by overwriting it with a scalar value, so be carefull! To slightly lower the chances of loosing data by overwriting, it is possible to **lock** selected values against direct modification. Please refer to the [corresponding chapter](#aaa) for more information.

Creating anonymous values
-------------------------

In addition to one common root object, it is possible to create anonymous unnamed JSON values. These values do not belong to the root or any other element and are only accessible by the automatically generated internal ID. For example, an anonymous string can be created by executing:

```sql
DECLARE
    v_id NUMBER;
BEGIN
    v_id := json_store.create_string('Hello, World!');
END;
```

Here is another example, which creates an anonymous object with one property in one call:

```sql
DECLARE
    v_id NUMBER;
BEGIN
    v_id := json_store.create_json('{"hello":"world"}');
END;
```

Now, providing that the last example has returned `v_id = 12345`, it is possible to get the whole value or to refer to a property using the syntax shown below:

```sql
SELECT json_store.get_string('#12345.hello')
FROM dual;

SELECT json_store.get_json('#12345')
FROM dual;
```

The aforementioned technique allows to create virtually any number of additional "roots", provided that you store element IDs for further use.

API reference
------------
