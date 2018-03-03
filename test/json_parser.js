/* 
    Copyright 2017 Sergejs Vinniks

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at
 
      http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
*/

suite("Invalid JSON handling", function() {

    test("Invalid start of JSON", function() {
    
        expect(function() {
        
            database.call("json_parser.parse", {
                p_content: "a"
            });
        
        }).to.throw(/JSON-00001/);
    
    });
    
    test("Invalid start of an array value", function() {
    
        expect(function() {
        
            database.call("json_parser.parse", {
                p_content: "[1, a]"
            });
        
        }).to.throw(/JSON-00001/);
    
    });

    test("Invalid start of a property value", function() {
    
        expect(function() {
        
            database.call("json_parser.parse", {
                p_content: '{"hello": world}'
            });
        
        }).to.throw(/JSON-00001/);
    
    });

    test("Array value missing", function() {
    
        expect(function() {
        
            database.call("json_parser.parse", {
                p_content: '[1, 2, ]'
            });
        
        }).to.throw(/JSON-00001/);
    
    });

    test("Negative number missing", function() {
    
        expect(function() {
        
            database.call("json_parser.parse", {
                p_content: '-a'
            });
        
        }).to.throw(/JSON-00001/);
    
    });

    test("Invalid integer", function() {
    
        expect(function() {
        
            database.call("json_parser.parse", {
                p_content: '123a'
            });
        
        }).to.throw(/JSON-00001/);
    
    });

    test("Non-zero number starting with zero", function() {
    
        expect(function() {
        
            database.call("json_parser.parse", {
                p_content: '01'
            });
        
        }).to.throw(/JSON-00001/);
    
    });

    test("Zero integer decimal part missing", function() {
    
        expect(function() {
        
            database.call("json_parser.parse", {
                p_content: '0.'
            });
        
        }).to.throw(/JSON-00002/);
    
    });

    test("Non-zero integer decimal part missing", function() {
    
        expect(function() {
        
            database.call("json_parser.parse", {
                p_content: '123.'
            });
        
        }).to.throw(/JSON-00002/);
    
    });

    test("Zero integer decimal part invalid", function() {
    
        expect(function() {
        
            database.call("json_parser.parse", {
                p_content: '0.45a'
            });
        
        }).to.throw(/JSON-00001/);
    
    });

    test("Non-zero integer decimal part invalid", function() {
    
        expect(function() {
        
            database.call("json_parser.parse", {
                p_content: '123.45a'
            });
        
        }).to.throw(/JSON-00001/);
    
    });

    test("Invalid unicode length", function() {
    
        expect(function() {
        
            database.call("json_parser.parse", {
                p_content: '"\\u1"'
            });
        
        }).to.throw(/JSON-00001/);
    
    });

    test("Invalid unicode", function() {
    
        expect(function() {
        
            database.call("json_parser.parse", {
                p_content: '"\\uq"'
            });
        
        }).to.throw(/JSON-00001/);
    
    });

    test("Invalid special value", function() {
    
        expect(function() {
        
            database.call("json_parser.parse", {
                p_content: 'truee'
            });
        
        }).to.throw(/JSON-00001/);
    
    });

    test("Unfinished special value", function() {
    
        expect(function() {
        
            database.call("json_parser.parse", {
                p_content: 'fals'
            });
        
        }).to.throw(/JSON-00002/);
    
    });

    test("Invalid property start", function() {
    
        expect(function() {
        
            database.call("json_parser.parse", {
                p_content: '{1}'
            });
        
        }).to.throw(/JSON-00001/);
    
    });

    test("Property missing", function() {
    
        expect(function() {
        
            database.call("json_parser.parse", {
                p_content: '{"hello": "world",}'
            });
        
        }).to.throw(/JSON-00001/);
    
    });

    test("Colon missing", function() {
    
        expect(function() {
        
            database.call("json_parser.parse", {
                p_content: '{"hello" "world"}'
            });
        
        }).to.throw(/JSON-00001/);
    
    });

    test("Missing comma between array elements", function() {
    
        expect(function() {
        
            database.call("json_parser.parse", {
                p_content: '[123 456]'
            });
        
        }).to.throw(/JSON-00001/);
    
    });

    test("Missing comma between object properties", function() {
    
        expect(function() {
        
            database.call("json_parser.parse", {
                p_content: '{"name": "Sergejs" "age": 35}'
            });
        
        }).to.throw(/JSON-00001/);
    
    });

    test("Missing ]", function() {
    
        expect(function() {
        
            database.call("json_parser.parse", {
                p_content: '[1, 2, 3'
            });
        
        }).to.throw(/JSON-00002/);
    
    });

    test("Missing }", function() {
    
        expect(function() {
        
            database.call("json_parser.parse", {
                p_content: '{"hello": 123'
            });
        
        }).to.throw(/JSON-00002/);
    
    });

    test("Too many ]", function() {
    
        expect(function() {
        
            database.call("json_parser.parse", {
                p_content: '[[{}]]]'
            });
        
        }).to.throw(/JSON-00001/);
    
    });

    test("Too many }", function() {
    
        expect(function() {
        
            database.call("json_parser.parse", {
                p_content: '{"a":[[{}]]}}'
            });
        
        }).to.throw(/JSON-00001/);
    
    });

    test("Non-terminated string", function() {
    
        expect(function() {
        
            database.call("json_parser.parse", {
                p_content: '"Hello'
            });
        
        }).to.throw(/JSON-00002/);
    
    });


});

suite("Scalar value tests", function() {

    test("Empty document", function() {
    
        var result = database.call("json_parser.parse", {
            p_content: null
        });

        expect(result.p_parse_events).to.eql([]);

    });

    test("String value", function() {
    
        var result = database.call("json_parser.parse", {
            p_content: '"Hello, World!"'
        });

        expect(result.p_parse_events).to.eql([
            {name: "STRING", value: "Hello, World!"}
        ]);
    
    });

    test("String value with leading/trailing spaces", function() {
    
        var result = database.call("json_parser.parse", {
            p_content: '    "Hello, World!"   '
        });

        expect(result.p_parse_events).to.eql([
            {name: "STRING", value: "Hello, World!"}
        ]);
    
    });

    test("String value with newlines", function() {
    
        var result = database.call("json_parser.parse", {
            p_content: '\n"Hello, World!"\n'
        });

        expect(result.p_parse_events).to.eql([
            {name: "STRING", value: "Hello, World!"}
        ]);
    
    });

    test("String value with tabs", function() {
    
        var result = database.call("json_parser.parse", {
            p_content: '\t"Hello, World!"\t'
        });

        expect(result.p_parse_events).to.eql([
            {name: "STRING", value: "Hello, World!"}
        ]);
    
    });
    
    test("String value with escaped characters (without \\u)", function() {
    
        var result = database.call("json_parser.parse", {
            p_content: '"\\"\\n\\/\\\\\\b\\f\\r\\t\\y"'
        });

        expect(result.p_parse_events).to.eql([
            {name: "STRING", value: '"\n/\\\b\f\r\ty'}
        ]);
    
    });

    test("String value with \\u unicode character code", function() {
    
        var result = database.call("json_parser.parse", {
            p_content: '"\\u0041BC"'
        });

        expect(result.p_parse_events).to.eql([
            {name: "STRING", value: 'ABC'}
        ]);
    
    });

    test("Zero", function() {
    
        var result = database.call("json_parser.parse", {
            p_content: "0"
        });

        expect(result.p_parse_events).to.eql([
            {name: "NUMBER", value: "0"}
        ]);
    
    });

    test("Zero with leading/trailing spaces", function() {
    
        var result = database.call("json_parser.parse", {
            p_content: "   0    "
        });

        expect(result.p_parse_events).to.eql([
            {name: "NUMBER", value: "0"}
        ]);
    
    });

    test("Positive integer value", function() {
    
        var result = database.call("json_parser.parse", {
            p_content: "1234567890"
        });

        expect(result.p_parse_events).to.eql([
            {name: "NUMBER", value: "1234567890"}
        ]);
    
    });

    test("Positive integer value with leading/trailing spaces", function() {
    
        var result = database.call("json_parser.parse", {
            p_content: "   1234567890   "
        });

        expect(result.p_parse_events).to.eql([
            {name: "NUMBER", value: "1234567890"}
        ]);
    
    });
    
    test("Neative integer value", function() {
    
        var result = database.call("json_parser.parse", {
            p_content: "-1234567890"
        });

        expect(result.p_parse_events).to.eql([
            {name: "NUMBER", value: "-1234567890"}
        ]);
    
    });

    test("Negative integer value with possible spaces", function() {
    
        var result = database.call("json_parser.parse", {
            p_content: "   -  1234567890   "
        });

        expect(result.p_parse_events).to.eql([
            {name: "NUMBER", value: "-1234567890"}
        ]);
    
    });

    test("Positive float value", function() {
    
        var result = database.call("json_parser.parse", {
            p_content: "12345.67890"
        });

        expect(result.p_parse_events).to.eql([
            {name: "NUMBER", value: "12345.67890"}
        ]);
    
    });

    test("Positive float value with zero integer part", function() {
    
        var result = database.call("json_parser.parse", {
            p_content: "0.12345"
        });

        expect(result.p_parse_events).to.eql([
            {name: "NUMBER", value: "0.12345"}
        ]);
    
    });

    test("Positive float value with leading/trailing spaces", function() {
    
        var result = database.call("json_parser.parse", {
            p_content: "    12345.67890    "
        });

        expect(result.p_parse_events).to.eql([
            {name: "NUMBER", value: "12345.67890"}
        ]);
    
    });

    test("Negative float value", function() {
    
        var result = database.call("json_parser.parse", {
            p_content: "-12345.67890"
        });

        expect(result.p_parse_events).to.eql([
            {name: "NUMBER", value: "-12345.67890"}
        ]);
    
    });

    test("Negative float value with possible spaces", function() {
    
        var result = database.call("json_parser.parse", {
            p_content: "    -    12345.67890     "
        });

        expect(result.p_parse_events).to.eql([
            {name: "NUMBER", value: "-12345.67890"}
        ]);
    
    });

    test("Boolean value (true)", function() {
    
        var result = database.call("json_parser.parse", {
            p_content: "true"
        });

        expect(result.p_parse_events).to.eql([
            {name: "BOOLEAN", value: "true"}
        ]);
    
    });

    test("Boolean value (false)", function() {
    
        var result = database.call("json_parser.parse", {
            p_content: "false"
        });

        expect(result.p_parse_events).to.eql([
            {name: "BOOLEAN", value: "false"}
        ]);
    
    });

    test("Boolean value (true) with leadin/trailing spaces", function() {
    
        var result = database.call("json_parser.parse", {
            p_content: "  true  "
        });

        expect(result.p_parse_events).to.eql([
            {name: "BOOLEAN", value: "true"}
        ]);
    
    });

    test("Null", function() {
    
        var result = database.call("json_parser.parse", {
            p_content: "null"
        });

        expect(result.p_parse_events).to.eql([
            {name: "NULL", value: null}
        ]);
    
    });

    test("Null with leading/trailing spaces", function() {
    
        var result = database.call("json_parser.parse", {
            p_content: "   null   "
        });

        expect(result.p_parse_events).to.eql([
            {name: "NULL", value: null}
        ]);
    
    });
        
});

suite("Object tests", function() {

    test("Empty object", function() {
    
        var result = database.call("json_parser.parse", {
            p_content: "{}"
        });

        expect(result.p_parse_events).to.eql([
            {name: "START_OBJECT", value: null},
            {name: "END_OBJECT", value: null}
        ]);
    
    });
    
    test("Empty object with possible spaces", function() {
    
        var result = database.call("json_parser.parse", {
            p_content: "    {     }      "
        });

        expect(result.p_parse_events).to.eql([
            {name: "START_OBJECT", value: null},
            {name: "END_OBJECT", value: null}
        ]);
    
    });

    test("Object with string property", function() {
    
        var result = database.call("json_parser.parse", {
            p_content: '{"hello":"world"}'
        });

        expect(result.p_parse_events).to.eql([
            {name: "START_OBJECT", value: null},
            {name: "NAME", value: "hello"},
            {name: "STRING", value: "world"},
            {name: "END_OBJECT", value: null}
        ]);
    
    });

    test("Object with a property with escaped characters", function() {
    
        var result = database.call("json_parser.parse", {
            p_content: '{"hello\\n\\t":"world"}'
        });

        expect(result.p_parse_events).to.eql([
            {name: "START_OBJECT", value: null},
            {name: "NAME", value: "hello\n\t"},
            {name: "STRING", value: "world"},
            {name: "END_OBJECT", value: null}
        ]);
    
    });

    test("Object with string property and possible spaces", function() {
    
        var result = database.call("json_parser.parse", {
            p_content: '   {   "hello"   :   "world"   }   '
        });

        expect(result.p_parse_events).to.eql([
            {name: "START_OBJECT", value: null},
            {name: "NAME", value: "hello"},
            {name: "STRING", value: "world"},
            {name: "END_OBJECT", value: null}
        ]);
    
    });

    test("Object with multiple string properties", function() {
    
        var result = database.call("json_parser.parse", {
            p_content: '{"name":"Sergejs","surname":"Vinniks","age":"35"}'
        });

        expect(result.p_parse_events).to.eql([
            {name: "START_OBJECT", value: null},
            {name: "NAME", value: "name"},
            {name: "STRING", value: "Sergejs"},
            {name: "NAME", value: "surname"},
            {name: "STRING", value: "Vinniks"},
            {name: "NAME", value: "age"},
            {name: "STRING", value: "35"},
            {name: "END_OBJECT", value: null}
        ]);
    
    });

    test("Object with multiple string properties with all possible spaces", function() {
    
        var result = database.call("json_parser.parse", {
            p_content: '  {  "name"  :  "Sergejs"  ,  "surname"  :  "Vinniks"  ,  "age"  :  "35"  }  '
        });

        expect(result.p_parse_events).to.eql([
            {name: "START_OBJECT", value: null},
            {name: "NAME", value: "name"},
            {name: "STRING", value: "Sergejs"},
            {name: "NAME", value: "surname"},
            {name: "STRING", value: "Vinniks"},
            {name: "NAME", value: "age"},
            {name: "STRING", value: "35"},
            {name: "END_OBJECT", value: null}
        ]);
    
    });

    test("Object with a zero property", function() {
    
        var result = database.call("json_parser.parse", {
            p_content: '{"hello":0}'
        });

        expect(result.p_parse_events).to.eql([
            {name: "START_OBJECT", value: null},
            {name: "NAME", value: "hello"},
            {name: "NUMBER", value: "0"},
            {name: "END_OBJECT", value: null}
        ]);
    
    });

    test("Object with a zero property and all possible spaces", function() {
    
        var result = database.call("json_parser.parse", {
            p_content: '  {  "hello"  :  0  }  '
        });

        expect(result.p_parse_events).to.eql([
            {name: "START_OBJECT", value: null},
            {name: "NAME", value: "hello"},
            {name: "NUMBER", value: "0"},
            {name: "END_OBJECT", value: null}
        ]);
    
    });

    test("Object with a positive integer property", function() {
    
        var result = database.call("json_parser.parse", {
            p_content: '{"hello":1234567890}'
        });

        expect(result.p_parse_events).to.eql([
            {name: "START_OBJECT", value: null},
            {name: "NAME", value: "hello"},
            {name: "NUMBER", value: "1234567890"},
            {name: "END_OBJECT", value: null}
        ]);
    
    });

    test("Object with a negative integer property", function() {
    
        var result = database.call("json_parser.parse", {
            p_content: '{"hello":-1234567890}'
        });

        expect(result.p_parse_events).to.eql([
            {name: "START_OBJECT", value: null},
            {name: "NAME", value: "hello"},
            {name: "NUMBER", value: "-1234567890"},
            {name: "END_OBJECT", value: null}
        ]);
    
    });

    test("Object with a negative integer property and possible spaces", function() {
    
        var result = database.call("json_parser.parse", {
            p_content: '   {   "hello"   :   -1234567890    }    '
        });

        expect(result.p_parse_events).to.eql([
            {name: "START_OBJECT", value: null},
            {name: "NAME", value: "hello"},
            {name: "NUMBER", value: "-1234567890"},
            {name: "END_OBJECT", value: null}
        ]);
    
    });

    test("Object with multiple integer properties", function() {
    
        var result = database.call("json_parser.parse", {
            p_content: '{"a":123,"b":456,"c":-789}'
        });

        expect(result.p_parse_events).to.eql([
            {name: "START_OBJECT", value: null},
            {name: "NAME", value: "a"},
            {name: "NUMBER", value: "123"},
            {name: "NAME", value: "b"},
            {name: "NUMBER", value: "456"},
            {name: "NAME", value: "c"},
            {name: "NUMBER", value: "-789"},
            {name: "END_OBJECT", value: null}
        ]);
    
    });

    test("Object with multiple integer properties and all possible spaces", function() {
    
        var result = database.call("json_parser.parse", {
            p_content: '  {  "a"  :  123  ,  "b"  :  456  ,  "c"  :  -  789  }  '
        });

        expect(result.p_parse_events).to.eql([
            {name: "START_OBJECT", value: null},
            {name: "NAME", value: "a"},
            {name: "NUMBER", value: "123"},
            {name: "NAME", value: "b"},
            {name: "NUMBER", value: "456"},
            {name: "NAME", value: "c"},
            {name: "NUMBER", value: "-789"},
            {name: "END_OBJECT", value: null}
        ]);
    
    });

    test("Object with a positive float property", function() {
    
        var result = database.call("json_parser.parse", {
            p_content: '{"hello":12345.67890}'
        });

        expect(result.p_parse_events).to.eql([
            {name: "START_OBJECT", value: null},
            {name: "NAME", value: "hello"},
            {name: "NUMBER", value: "12345.67890"},
            {name: "END_OBJECT", value: null}
        ]);
    
    });

    test("Object with a negative float property", function() {
    
        var result = database.call("json_parser.parse", {
            p_content: '{"hello":-12345.67890}'
        });

        expect(result.p_parse_events).to.eql([
            {name: "START_OBJECT", value: null},
            {name: "NAME", value: "hello"},
            {name: "NUMBER", value: "-12345.67890"},
            {name: "END_OBJECT", value: null}
        ]);
    
    });

    test("Object with a multiple float properties", function() {
    
        var result = database.call("json_parser.parse", {
            p_content: '{"a":12.34,"b":34.56,"c":-56.78}'
        });

        expect(result.p_parse_events).to.eql([
            {name: "START_OBJECT", value: null},
            {name: "NAME", value: "a"},
            {name: "NUMBER", value: "12.34"},
            {name: "NAME", value: "b"},
            {name: "NUMBER", value: "34.56"},
            {name: "NAME", value: "c"},
            {name: "NUMBER", value: "-56.78"},
            {name: "END_OBJECT", value: null}
        ]);
    
    });

    test("Object with a multiple float properties and all possible spaces", function() {
    
        var result = database.call("json_parser.parse", {
            p_content: '  {  "a"  :  12.34  ,  "b"  :  34.56  ,  "c"  :  -  56.78  }  '
        });

        expect(result.p_parse_events).to.eql([
            {name: "START_OBJECT", value: null},
            {name: "NAME", value: "a"},
            {name: "NUMBER", value: "12.34"},
            {name: "NAME", value: "b"},
            {name: "NUMBER", value: "34.56"},
            {name: "NAME", value: "c"},
            {name: "NUMBER", value: "-56.78"},
            {name: "END_OBJECT", value: null}
        ]);
    
    });

    test("Object with a boolean (true) property", function() {
    
        var result = database.call("json_parser.parse", {
            p_content: '{"hello":true}'
        });

        expect(result.p_parse_events).to.eql([
            {name: "START_OBJECT", value: null},
            {name: "NAME", value: "hello"},
            {name: "BOOLEAN", value: "true"},
            {name: "END_OBJECT", value: null}
        ]);
    
    });

    test("Object with a boolean (false) property", function() {
    
        var result = database.call("json_parser.parse", {
            p_content: '{"hello":false}'
        });

        expect(result.p_parse_events).to.eql([
            {name: "START_OBJECT", value: null},
            {name: "NAME", value: "hello"},
            {name: "BOOLEAN", value: "false"},
            {name: "END_OBJECT", value: null}
        ]);
    
    });

    test("Object with a boolean (true) property and possible spaces", function() {
    
        var result = database.call("json_parser.parse", {
            p_content: '   {   "hello"   :   true   }   '
        });

        expect(result.p_parse_events).to.eql([
            {name: "START_OBJECT", value: null},
            {name: "NAME", value: "hello"},
            {name: "BOOLEAN", value: "true"},
            {name: "END_OBJECT", value: null}
        ]);
    
    });

    test("Object with a null property", function() {
    
        var result = database.call("json_parser.parse", {
            p_content: '{"hello":null}'
        });

        expect(result.p_parse_events).to.eql([
            {name: "START_OBJECT", value: null},
            {name: "NAME", value: "hello"},
            {name: "NULL", value: null},
            {name: "END_OBJECT", value: null}
        ]);
    
    });

    test("Object with a null property and possible spaces", function() {
    
        var result = database.call("json_parser.parse", {
            p_content: '   {   "hello"   :   null   }   '
        });

        expect(result.p_parse_events).to.eql([
            {name: "START_OBJECT", value: null},
            {name: "NAME", value: "hello"},
            {name: "NULL", value: null},
            {name: "END_OBJECT", value: null}
        ]);
    
    });

    test("Object with multiple scalar properties", function() {
    
        var result = database.call("json_parser.parse", {
            p_content: '{"name":"Sergejs","surname":"Vinniks","age":35,"married":true}'
        });
    
        expect(result.p_parse_events).to.eql([
            {name: "START_OBJECT", value: null},
            {name: "NAME", value: "name"},
            {name: "STRING", value: "Sergejs"},
            {name: "NAME", value: "surname"},
            {name: "STRING", value: "Vinniks"},
            {name: "NAME", value: "age"},
            {name: "NUMBER", value: "35"},
            {name: "NAME", value: "married"},
            {name: "BOOLEAN", value: "true"},
            {name: "END_OBJECT", value: null}
        ]);

    });
    
    test("Object with multiple scalar properties and all possible spaces", function() {
    
        var result = database.call("json_parser.parse", {
            p_content: '   {   "name"   :   "Sergejs"   ,   "surname"   :    "Vinniks",    "age"  :  35 ,   "married"   :   true   }    '
        });
    
        expect(result.p_parse_events).to.eql([
            {name: "START_OBJECT", value: null},
            {name: "NAME", value: "name"},
            {name: "STRING", value: "Sergejs"},
            {name: "NAME", value: "surname"},
            {name: "STRING", value: "Vinniks"},
            {name: "NAME", value: "age"},
            {name: "NUMBER", value: "35"},
            {name: "NAME", value: "married"},
            {name: "BOOLEAN", value: "true"},
            {name: "END_OBJECT", value: null}
        ]);

    });

});

suite("Array tests", function() {

    test("Empty array", function() {

        var result = database.call("json_parser.parse", {
            p_content: '[]'
        });
    
        expect(result.p_parse_events).to.eql([
            {name: "START_ARRAY", value: null},
            {name: "END_ARRAY", value: null}
        ]);

    });

    test("Empty array with all possible spaces", function() {

        var result = database.call("json_parser.parse", {
            p_content: ' [ ] '
        });
    
        expect(result.p_parse_events).to.eql([
            {name: "START_ARRAY", value: null},
            {name: "END_ARRAY", value: null}
        ]);

    });

    test("Array with a single string value", function() {

        var result = database.call("json_parser.parse", {
            p_content: '["hello"]'
        });
    
        expect(result.p_parse_events).to.eql([
            {name: "START_ARRAY", value: null},
            {name: "STRING", value: "hello"},
            {name: "END_ARRAY", value: null}
        ]);

    });

    test("Array with a single string value and all possible spaces", function() {

        var result = database.call("json_parser.parse", {
            p_content: '  [  "hello"  ]  '
        });
    
        expect(result.p_parse_events).to.eql([
            {name: "START_ARRAY", value: null},
            {name: "STRING", value: "hello"},
            {name: "END_ARRAY", value: null}
        ]);

    });

    test("Array with multiple string values", function() {

        var result = database.call("json_parser.parse", {
            p_content: '["hello","world","how","are","you"]'
        });
    
        expect(result.p_parse_events).to.eql([
            {name: "START_ARRAY", value: null},
            {name: "STRING", value: "hello"},
            {name: "STRING", value: "world"},
            {name: "STRING", value: "how"},
            {name: "STRING", value: "are"},
            {name: "STRING", value: "you"},
            {name: "END_ARRAY", value: null}
        ]);

    });

    test("Array with multiple string values and all possible spaces", function() {

        var result = database.call("json_parser.parse", {
            p_content: '  [  "hello"  ,  "world"  ,  "how"  ,  "are"  ,  "you"  ]  '
        });
    
        expect(result.p_parse_events).to.eql([
            {name: "START_ARRAY", value: null},
            {name: "STRING", value: "hello"},
            {name: "STRING", value: "world"},
            {name: "STRING", value: "how"},
            {name: "STRING", value: "are"},
            {name: "STRING", value: "you"},
            {name: "END_ARRAY", value: null}
        ]);

    });

    test("Array with a single number value", function() {

        var result = database.call("json_parser.parse", {
            p_content: '[12345.678]'
        });
    
        expect(result.p_parse_events).to.eql([
            {name: "START_ARRAY", value: null},
            {name: "NUMBER", value: "12345.678"},
            {name: "END_ARRAY", value: null}
        ]);

    });

    test("Array with a single number value and all possible spaces", function() {

        var result = database.call("json_parser.parse", {
            p_content: '  [  12345.678  ]  '
        });
    
        expect(result.p_parse_events).to.eql([
            {name: "START_ARRAY", value: null},
            {name: "NUMBER", value: "12345.678"},
            {name: "END_ARRAY", value: null}
        ]);

    });

    test("Array with multiple number values", function() {

        var result = database.call("json_parser.parse", {
            p_content: '[12345.678,2,-45,0,-0.12]'
        });
    
        expect(result.p_parse_events).to.eql([
            {name: "START_ARRAY", value: null},
            {name: "NUMBER", value: "12345.678"},
            {name: "NUMBER", value: "2"},
            {name: "NUMBER", value: "-45"},
            {name: "NUMBER", value: "0"},
            {name: "NUMBER", value: "-0.12"},
            {name: "END_ARRAY", value: null}
        ]);

    });

    test("Array with multiple number values and all possible spaces", function() {

        var result = database.call("json_parser.parse", {
            p_content: '  [  12345.678  ,  2  ,  -45  ,  0  ,  -0.12  ]   '
        });
    
        expect(result.p_parse_events).to.eql([
            {name: "START_ARRAY", value: null},
            {name: "NUMBER", value: "12345.678"},
            {name: "NUMBER", value: "2"},
            {name: "NUMBER", value: "-45"},
            {name: "NUMBER", value: "0"},
            {name: "NUMBER", value: "-0.12"},
            {name: "END_ARRAY", value: null}
        ]);

    });

    test("Array with multiple zeros", function() {

        var result = database.call("json_parser.parse", {
            p_content: '[0,0,0]'
        });
    
        expect(result.p_parse_events).to.eql([
            {name: "START_ARRAY", value: null},
            {name: "NUMBER", value: "0"},
            {name: "NUMBER", value: "0"},
            {name: "NUMBER", value: "0"},
            {name: "END_ARRAY", value: null}
        ]);

    });

    test("Array with multiple zeros and all possible spaces", function() {

        var result = database.call("json_parser.parse", {
            p_content: '  [  0  ,  0  ,  0  ]  '
        });
    
        expect(result.p_parse_events).to.eql([
            {name: "START_ARRAY", value: null},
            {name: "NUMBER", value: "0"},
            {name: "NUMBER", value: "0"},
            {name: "NUMBER", value: "0"},
            {name: "END_ARRAY", value: null}
        ]);

    });

    test("Array with a single boolean", function() {

        var result = database.call("json_parser.parse", {
            p_content: '[true]'
        });
    
        expect(result.p_parse_events).to.eql([
            {name: "START_ARRAY", value: null},
            {name: "BOOLEAN", value: "true"},
            {name: "END_ARRAY", value: null}
        ]);

    });

    test("Array with a single boolean and all possible spaces", function() {

        var result = database.call("json_parser.parse", {
            p_content: '  [  true  ]  '
        });
    
        expect(result.p_parse_events).to.eql([
            {name: "START_ARRAY", value: null},
            {name: "BOOLEAN", value: "true"},
            {name: "END_ARRAY", value: null}
        ]);

    });

    test("Array with multiple booleans", function() {

        var result = database.call("json_parser.parse", {
            p_content: '[true,true,false,false,true,false]'
        });
    
        expect(result.p_parse_events).to.eql([
            {name: "START_ARRAY", value: null},
            {name: "BOOLEAN", value: "true"},
            {name: "BOOLEAN", value: "true"},
            {name: "BOOLEAN", value: "false"},
            {name: "BOOLEAN", value: "false"},
            {name: "BOOLEAN", value: "true"},
            {name: "BOOLEAN", value: "false"},
            {name: "END_ARRAY", value: null}
        ]);

    });

    test("Array with multiple booleans and all possible spaces", function() {

        var result = database.call("json_parser.parse", {
            p_content: '  [  true  ,  true  ,  false  ,  false  ,  true  ,  false  ]  '
        });
    
        expect(result.p_parse_events).to.eql([
            {name: "START_ARRAY", value: null},
            {name: "BOOLEAN", value: "true"},
            {name: "BOOLEAN", value: "true"},
            {name: "BOOLEAN", value: "false"},
            {name: "BOOLEAN", value: "false"},
            {name: "BOOLEAN", value: "true"},
            {name: "BOOLEAN", value: "false"},
            {name: "END_ARRAY", value: null}
        ]);

    });

    test("Array with a single null value", function() {

        var result = database.call("json_parser.parse", {
            p_content: '[null]'
        });
    
        expect(result.p_parse_events).to.eql([
            {name: "START_ARRAY", value: null},
            {name: "NULL", value: null},
            {name: "END_ARRAY", value: null}
        ]);

    });

    test("Array with a single null value and all possible spaces", function() {

        var result = database.call("json_parser.parse", {
            p_content: '  [  null  ]  '
        });
    
        expect(result.p_parse_events).to.eql([
            {name: "START_ARRAY", value: null},
            {name: "NULL", value: null},
            {name: "END_ARRAY", value: null}
        ]);

    });

    test("Array with multiple null values", function() {

        var result = database.call("json_parser.parse", {
            p_content: '[null,null,null]'
        });
    
        expect(result.p_parse_events).to.eql([
            {name: "START_ARRAY", value: null},
            {name: "NULL", value: null},
            {name: "NULL", value: null},
            {name: "NULL", value: null},
            {name: "END_ARRAY", value: null}
        ]);

    });

    test("Array with multiple null values and all possible spaces", function() {

        var result = database.call("json_parser.parse", {
            p_content: '  [  null  ,  null  ,  null  ]  '
        });
    
        expect(result.p_parse_events).to.eql([
            {name: "START_ARRAY", value: null},
            {name: "NULL", value: null},
            {name: "NULL", value: null},
            {name: "NULL", value: null},
            {name: "END_ARRAY", value: null}
        ]);

    });

    test("Array with mixed values and spaces 1", function() {

        var result = database.call("json_parser.parse", {
            p_content: '["Hello", -12.9 ,  null, "World",false   ,111   ]  '
        });
    
        expect(result.p_parse_events).to.eql([
            {name: "START_ARRAY", value: null},
            {name: "STRING", value: "Hello"},
            {name: "NUMBER", value: "-12.9"},
            {name: "NULL", value: null},
            {name: "STRING", value: "World"},
            {name: "BOOLEAN", value: "false"},
            {name: "NUMBER", value: "111"},
            {name: "END_ARRAY", value: null}
        ]);

    });

    test("Array with mixed values and spaces 2", function() {

        var result = database.call("json_parser.parse", {
            p_content: '["Hello,\\nWorld", null, null, 987654.0000012, "\\"!\\"", true]'
        });
    
        expect(result.p_parse_events).to.eql([
            {name: "START_ARRAY", value: null},
            {name: "STRING", value: "Hello,\nWorld"},
            {name: "NULL", value: null},
            {name: "NULL", value: null},
            {name: "NUMBER", value: "987654.0000012"},
            {name: "STRING", value: '"!"'},
            {name: "BOOLEAN", value: "true"},
            {name: "END_ARRAY", value: null}
        ]);

    });

});

suite("Complex object test", function() {

    test("Object with an empty object property", function() {

        var result = database.call("json_parser.parse", {
            p_content: JSON.stringify({
                obj: {}
            }, "    ")
        });
    
        expect(result.p_parse_events).to.eql([
            {name: "START_OBJECT", value: null},
            {name: "NAME", value: "obj"},
            {name: "START_OBJECT", value: null},
            {name: "END_OBJECT", value: null},
            {name: "END_OBJECT", value: null}
        ]);

    });

    test("Object with an object property", function() {

        var result = database.call("json_parser.parse", {
            p_content: JSON.stringify({
                obj: {
                    name: "Sergejs",
                    age: 35
                }
            }, "    ")
        });
    
        expect(result.p_parse_events).to.eql([
            {name: "START_OBJECT", value: null},
            {name: "NAME", value: "obj"},
            {name: "START_OBJECT", value: null},
            {name: "NAME", value: "name"},
            {name: "STRING", value: "Sergejs"},
            {name: "NAME", value: "age"},
            {name: "NUMBER", value: "35"},
            {name: "END_OBJECT", value: null},
            {name: "END_OBJECT", value: null}
        ]);

    });

    test("Object with an object property surrounded by other properties", function() {

        var result = database.call("json_parser.parse", {
            p_content: JSON.stringify({
                string: "Hello",
                obj: {
                    name: "Sergejs",
                    age: 35
                },
                number: 123
            }, "    ")
        });
    
        expect(result.p_parse_events).to.eql([
            {name: "START_OBJECT", value: null},
            {name: "NAME", value: "string"},
            {name: "STRING", value: "Hello"},
            {name: "NAME", value: "obj"},
            {name: "START_OBJECT", value: null},
            {name: "NAME", value: "name"},
            {name: "STRING", value: "Sergejs"},
            {name: "NAME", value: "age"},
            {name: "NUMBER", value: "35"},
            {name: "END_OBJECT", value: null},
            {name: "NAME", value: "number"},
            {name: "NUMBER", value: "123"},
            {name: "END_OBJECT", value: null}
        ]);

    });

    test("Object with multiple object properties", function() {

        var result = database.call("json_parser.parse", {
            p_content: JSON.stringify({
                obj1: {
                    name: "Sergejs",
                    age: 35
                },
                obj2: {
                    name: "Janis",
                    age: 99
                }
            }, "    ")
        });
    
        expect(result.p_parse_events).to.eql([
            {name: "START_OBJECT", value: null},
            {name: "NAME", value: "obj1"},
            {name: "START_OBJECT", value: null},
            {name: "NAME", value: "name"},
            {name: "STRING", value: "Sergejs"},
            {name: "NAME", value: "age"},
            {name: "NUMBER", value: "35"},
            {name: "END_OBJECT", value: null},
            {name: "NAME", value: "obj2"},
            {name: "START_OBJECT", value: null},
            {name: "NAME", value: "name"},
            {name: "STRING", value: "Janis"},
            {name: "NAME", value: "age"},
            {name: "NUMBER", value: "99"},
            {name: "END_OBJECT", value: null},
            {name: "END_OBJECT", value: null}
        ]);

    });

    test("Object with multi-level nesting", function() {

        var result = database.call("json_parser.parse", {
            p_content: JSON.stringify({
                l1_obj1: {
                    l2_obj1: {
                        l3_obj1: {
                            Hello: "World"
                        }
                    },
                    l2_obj2: {
                        Hello: "World"
                    }
                },
                l1_obj2: {
                    l2_obj1: {
                        l3_obj1: {
                            Hello: "World"
                        }
                    }
                }
            }, "    ")
        });
    
        expect(result.p_parse_events).to.eql([
            {name: "START_OBJECT", value: null},
            {name: "NAME", value: "l1_obj1"},
            {name: "START_OBJECT", value: null},
            {name: "NAME", value: "l2_obj1"},
            {name: "START_OBJECT", value: null},
            {name: "NAME", value: "l3_obj1"},
            {name: "START_OBJECT", value: null},
            {name: "NAME", value: "Hello"},
            {name: "STRING", value: "World"},
            {name: "END_OBJECT", value: null},
            {name: "END_OBJECT", value: null},
            {name: "NAME", value: "l2_obj2"},
            {name: "START_OBJECT", value: null},
            {name: "NAME", value: "Hello"},
            {name: "STRING", value: "World"},
            {name: "END_OBJECT", value: null},
            {name: "END_OBJECT", value: null},
            {name: "NAME", value: "l1_obj2"},
            {name: "START_OBJECT", value: null},
            {name: "NAME", value: "l2_obj1"},
            {name: "START_OBJECT", value: null},
            {name: "NAME", value: "l3_obj1"},
            {name: "START_OBJECT", value: null},
            {name: "NAME", value: "Hello"},
            {name: "STRING", value: "World"},
            {name: "END_OBJECT", value: null},
            {name: "END_OBJECT", value: null},
            {name: "END_OBJECT", value: null},
            {name: "END_OBJECT", value: null}
        ]);

    });

    test("Object with an empty array property", function() {

        var result = database.call("json_parser.parse", {
            p_content: JSON.stringify({
                arr: []
            }, "    ")
        });
    
        expect(result.p_parse_events).to.eql([
            {name: "START_OBJECT", value: null},
            {name: "NAME", value: "arr"},
            {name: "START_ARRAY", value: null},
            {name: "END_ARRAY", value: null},
            {name: "END_OBJECT", value: null}
        ]);

    });

    test("Object with a number array property", function() {

        var result = database.call("json_parser.parse", {
            p_content: JSON.stringify({
                arr: [1, 2, 3, 4, 5]
            }, "    ")
        });
    
        expect(result.p_parse_events).to.eql([
            {name: "START_OBJECT", value: null},
            {name: "NAME", value: "arr"},
            {name: "START_ARRAY", value: null},
            {name: "NUMBER", value: 1},
            {name: "NUMBER", value: 2},
            {name: "NUMBER", value: 3},
            {name: "NUMBER", value: 4},
            {name: "NUMBER", value: 5},
            {name: "END_ARRAY", value: null},
            {name: "END_OBJECT", value: null}
        ]);

    });

    test("Object with an array property surrounded by other properties", function() {

        var result = database.call("json_parser.parse", {
            p_content: JSON.stringify({
                string: "Hello",
                arr: [1, 2, 3, 4, 5],
                boolean: true
            }, "    ")
        });
    
        expect(result.p_parse_events).to.eql([
            {name: "START_OBJECT", value: null},
            {name: "NAME", value: "string"},
            {name: "STRING", value: "Hello"},
            {name: "NAME", value: "arr"},
            {name: "START_ARRAY", value: null},
            {name: "NUMBER", value: 1},
            {name: "NUMBER", value: 2},
            {name: "NUMBER", value: 3},
            {name: "NUMBER", value: 4},
            {name: "NUMBER", value: 5},
            {name: "END_ARRAY", value: null},
            {name: "NAME", value: "boolean"},
            {name: "BOOLEAN", value: "true"},
            {name: "END_OBJECT", value: null}
        ]);

    });

    test("Object with multiple array properties", function() {

        var result = database.call("json_parser.parse", {
            p_content: JSON.stringify({
                arr1: [1, 2, 3],
                arr2: ["a", "b", "c"],
                arr3: [true, false, null],
            }, "    ")
        });
    
        expect(result.p_parse_events).to.eql([
            {name: "START_OBJECT", value: null},
            {name: "NAME", value: "arr1"},
            {name: "START_ARRAY", value: null},
            {name: "NUMBER", value: 1},
            {name: "NUMBER", value: 2},
            {name: "NUMBER", value: 3},
            {name: "END_ARRAY", value: null},
            {name: "NAME", value: "arr2"},
            {name: "START_ARRAY", value: null},
            {name: "STRING", value: "a"},
            {name: "STRING", value: "b"},
            {name: "STRING", value: "c"},
            {name: "END_ARRAY", value: null},
            {name: "NAME", value: "arr3"},
            {name: "START_ARRAY", value: null},
            {name: "BOOLEAN", value: "true"},
            {name: "BOOLEAN", value: "false"},
            {name: "NULL", value: null},
            {name: "END_ARRAY", value: null},
            {name: "END_OBJECT", value: null}
        ]);

    });

    test("Two-dimensional array", function() {

        var result = database.call("json_parser.parse", {
            p_content: JSON.stringify([
                [1, 2, 3],
                ["a", "b", "c"],
                [true, false, null]
            ], "    ")
        });
    
        expect(result.p_parse_events).to.eql([
            {name: "START_ARRAY", value: null},
            {name: "START_ARRAY", value: null},
            {name: "NUMBER", value: 1},
            {name: "NUMBER", value: 2},
            {name: "NUMBER", value: 3},
            {name: "END_ARRAY", value: null},
            {name: "START_ARRAY", value: null},
            {name: "STRING", value: "a"},
            {name: "STRING", value: "b"},
            {name: "STRING", value: "c"},
            {name: "END_ARRAY", value: null},
            {name: "START_ARRAY", value: null},
            {name: "BOOLEAN", value: "true"},
            {name: "BOOLEAN", value: "false"},
            {name: "NULL", value: null},
            {name: "END_ARRAY", value: null},
            {name: "END_ARRAY", value: null}
        ]);

    });

    test("Array of objects", function() {

        var result = database.call("json_parser.parse", {
            p_content: JSON.stringify([
                { },
                {
                    Hello: "World"
                },
                {
                    zero: 0
                }
            ])
        });
    
        expect(result.p_parse_events).to.eql([
            {name: "START_ARRAY", value: null},
            {name: "START_OBJECT", value: null},
            {name: "END_OBJECT", value: null},
            {name: "START_OBJECT", value: null},
            {name: "NAME", value: "Hello"},
            {name: "STRING", value: "World"},
            {name: "END_OBJECT", value: null},
            {name: "START_OBJECT", value: null},
            {name: "NAME", value: "zero"},
            {name: "NUMBER", value: "0"},
            {name: "END_OBJECT", value: null},
            {name: "END_ARRAY", value: null}
        ]);

    });

});
