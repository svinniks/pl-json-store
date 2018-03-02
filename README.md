Jodus
=====

**Jodus** stands for **J**s**o**n **d**oc**u**ment **s**tore and is a PL/SQL library for parsing, storing and querying JSON data.

Since version 12c, Oracle database supports JSON data type and offers several methods and features for storing and working with textual JSON values in both SQL and PL/SQL. 

Jodus, however, proposes a different aproach and maybe also different use cases for JSON processing withing Oracle databases and PL/SQL environment. Originally the idea of creating such sort of JSON store appeared while developing a semi-structured document metadata processing solution in one big dinosaur-old pure PL/SQL system. One of the main requirements was an ability to dynamically define the structure of attributes for documents of different types. The system had to both store structured document metadata and retrieve it piecewice (down to single scalar attribute values). Reading and parsing the whole JSON document to get just one attribute value is an overhead, so it was decided to **parse all JSON documents and store them as separate related values**.

The next view chapters describe the essentials and basic features of the Jodus JSON store as well as provides detailed installation and usage manual with code examples.

Table of contents
-----------------

<!--ts-->
* [Prerequisites](#prerequisites)
* [Installation](#installation)
* [Jodus basics](#basics)
* [API reference](#reference)
<!--te-->

Prerequisites
------------

Installation
------------

Jodus basics
------------

API reference
------------
