Jodus
=====

**Jodus** stands for **J**s**o**n **d**oc**u**ment **s**tore and is a PL/SQL library for parsing, storing and querying JSON data.

Since version 12c, Oracle database supports JSON data type and offers several methods and features for storing and working with textual JSON values in both SQL and PL/SQL. 

Jodus, however, proposes a different aproach and maybe also different use cases for JSON processing withing Oracle databases and PL/SQL environment. Originally the idea of creating this kind of JSON store appeared while developing a semi-structured document metadata processing solution in a big dinosaur-old PL/SQL system. One of the main requirements was an ability to dynamically define the structure of attributes for documents of different types. The system had to both store structured document metadata and retrieve it piecewice (down to single scalar attribute values). First of all, JSON as such perfectly fits the requirements. Secondly, reading and parsing the whole JSON document to get just one attribute value is an overhead, so it was decided to **parse all JSON documents and store them as separate related values**, creating a PL/SQL API sufficient to programmatically control the stored data.

The next view chapters describe the essentials and basic features of the Jodus JSON store as well as provides detailed installation and usage manual with code examples.

Table of contents
-----------------

<!--ts-->
* [Prerequisites](#prerequisites)
* [Installation](#installation)
* [Jodus basics](#jodus-basics)
* [API reference](#api-reference)
<!--te-->

Prerequisites
------------

Jodus is dependant on [oraspect](https://github.com/svinniks/oraspect), which is a generic logging and error handling tool for PL/SQL. Please make sure you have installed it first.

Installation
------------

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
------------

The whole JSON store is basically **one huge JSON document** called `root` or `$`. All other values are usually stored somewhere under the root.

API reference
------------
