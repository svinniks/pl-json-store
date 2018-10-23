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
        
        }).to.throw(/JSN-00001/);
    
    });
    
    test("Invalid start of an array value", function() {
    
        expect(function() {
        
            database.call("json_parser.parse", {
                p_content: "[1, a]"
            });
        
        }).to.throw(/JSN-00001/);
    
    });

    test("Invalid start of a property value", function() {
    
        expect(function() {
        
            database.call("json_parser.parse", {
                p_content: '{"hello": world}'
            });
        
        }).to.throw(/JSN-00001/);
    
    });

    test("Array value missing", function() {
    
        expect(function() {
        
            database.call("json_parser.parse", {
                p_content: '[1, 2, ]'
            });
        
        }).to.throw(/JSN-00001/);
    
    });

    test("Negative number missing", function() {
    
        expect(function() {
        
            database.call("json_parser.parse", {
                p_content: '-a'
            });
        
        }).to.throw(/JSN-00001/);
    
    });

    test("Invalid integer", function() {
    
        expect(function() {
        
            database.call("json_parser.parse", {
                p_content: '123a'
            });
        
        }).to.throw(/JSN-00001/);
    
    });

    test("Non-zero number starting with zero", function() {
    
        expect(function() {
        
            database.call("json_parser.parse", {
                p_content: '01'
            });
        
        }).to.throw(/JSN-00001/);
    
    });

    test("Zero integer decimal part missing", function() {
    
        expect(function() {
        
            database.call("json_parser.parse", {
                p_content: '0.'
            });
        
        }).to.throw(/JSN-00002/);
    
    });

    test("Non-zero integer decimal part missing", function() {
    
        expect(function() {
        
            database.call("json_parser.parse", {
                p_content: '123.'
            });
        
        }).to.throw(/JSN-00002/);
    
    });

    test("Zero integer decimal part invalid", function() {
    
        expect(function() {
        
            database.call("json_parser.parse", {
                p_content: '0.45a'
            });
        
        }).to.throw(/JSN-00001/);
    
    });

    test("Non-zero integer decimal part invalid", function() {
    
        expect(function() {
        
            database.call("json_parser.parse", {
                p_content: '123.45a'
            });
        
        }).to.throw(/JSN-00001/);
    
    });

    test("Invalid unicode length", function() {
    
        expect(function() {
        
            database.call("json_parser.parse", {
                p_content: '"\\u1"'
            });
        
        }).to.throw(/JSN-00001/);
    
    });

    test("Invalid unicode", function() {
    
        expect(function() {
        
            database.call("json_parser.parse", {
                p_content: '"\\uq"'
            });
        
        }).to.throw(/JSN-00001/);
    
    });

    test("Invalid special value", function() {
    
        expect(function() {
        
            database.call("json_parser.parse", {
                p_content: 'truee'
            });
        
        }).to.throw(/JSN-00001/);
    
    });

    test("Unfinished special value", function() {
    
        expect(function() {
        
            database.call("json_parser.parse", {
                p_content: 'fals'
            });
        
        }).to.throw(/JSN-00002/);
    
    });

    test("Invalid property start", function() {
    
        expect(function() {
        
            database.call("json_parser.parse", {
                p_content: '{1}'
            });
        
        }).to.throw(/JSN-00001/);
    
    });

    test("Property missing", function() {
    
        expect(function() {
        
            database.call("json_parser.parse", {
                p_content: '{"hello": "world",}'
            });
        
        }).to.throw(/JSN-00001/);
    
    });

    test("Colon missing", function() {
    
        expect(function() {
        
            database.call("json_parser.parse", {
                p_content: '{"hello" "world"}'
            });
        
        }).to.throw(/JSN-00001/);
    
    });

    test("Missing comma between array elements", function() {
    
        expect(function() {
        
            database.call("json_parser.parse", {
                p_content: '[123 456]'
            });
        
        }).to.throw(/JSN-00001/);
    
    });

    test("Missing comma between object properties", function() {
    
        expect(function() {
        
            database.call("json_parser.parse", {
                p_content: '{"name": "Sergejs" "age": 35}'
            });
        
        }).to.throw(/JSN-00001/);
    
    });

    test("Missing ]", function() {
    
        expect(function() {
        
            database.call("json_parser.parse", {
                p_content: '[1, 2, 3'
            });
        
        }).to.throw(/JSN-00002/);
    
    });

    test("Missing }", function() {
    
        expect(function() {
        
            database.call("json_parser.parse", {
                p_content: '{"hello": 123'
            });
        
        }).to.throw(/JSN-00002/);
    
    });

    test("Too many ]", function() {
    
        expect(function() {
        
            database.call("json_parser.parse", {
                p_content: '[[{}]]]'
            });
        
        }).to.throw(/JSN-00001/);
    
    });

    test("Too many }", function() {
    
        expect(function() {
        
            database.call("json_parser.parse", {
                p_content: '{"a":[[{}]]}}'
            });
        
        }).to.throw(/JSN-00001/);
    
    });

    test("Non-terminated string", function() {
    
        expect(function() {
        
            database.call("json_parser.parse", {
                p_content: '"Hello'
            });
        
        }).to.throw(/JSN-00002/);
    
    });


});

suite("Scalar value tests", function() {

    test("Empty document", function() {
    
        var events = database.call("json_parser.parse", {
            p_content: null
        });

        expect(events).to.eql([]);

    });

    test("String value", function() {
    
        var events = database.call("json_parser.parse", {
            p_content: '"Hello, World!"'
        });

        expect(events).to.eql([
            "SHello, World!"
        ]);
    
    });

    test("String value with leading/trailing spaces", function() {
    
        var events = database.call("json_parser.parse", {
            p_content: '    "Hello, World!"   '
        });

        expect(events).to.eql([
            "SHello, World!"
        ]);
    
    });

    test("String value with newlines", function() {
    
        var events = database.call("json_parser.parse", {
            p_content: '\n"Hello, World!"\n'
        });

        expect(events).to.eql([
            "SHello, World!"
        ]);
    
    });

    test("String value with tabs", function() {
    
        var events = database.call("json_parser.parse", {
            p_content: '\t"Hello, World!"\t'
        });

        expect(events).to.eql([
            "SHello, World!"
        ]);
    
    });
    
    test("String value with escaped characters (without \\u)", function() {
    
        var events = database.call("json_parser.parse", {
            p_content: '"\\"\\n\\/\\\\\\b\\f\\r\\t\\y"'
        });

        expect(events).to.eql([
            "S\"\n/\\\b\f\r\ty"
        ]);
    
    });

    test("String value with \\u unicode character code", function() {
    
        var events = database.call("json_parser.parse", {
            p_content: '"\\u0041BC"'
        });

        expect(events).to.eql([
            "SABC"
        ]);
    
    });

    test("Zero", function() {
    
        var events = database.call("json_parser.parse", {
            p_content: "0"
        });

        expect(events).to.eql([
            "N0"
        ]);
    
    });

    test("Zero with leading/trailing spaces", function() {
    
        var events = database.call("json_parser.parse", {
            p_content: "   0    "
        });

        expect(events).to.eql([
            "N0"
        ]);
    
    });

    test("Positive integer value", function() {
    
        var events = database.call("json_parser.parse", {
            p_content: "1234567890"
        });

        expect(events).to.eql([
            "N1234567890"
        ]);
    
    });

    test("Positive integer value with leading/trailing spaces", function() {
    
        var events = database.call("json_parser.parse", {
            p_content: "   1234567890   "
        });

        expect(events).to.eql([
            "N1234567890"
        ]);
    
    });
    
    test("Neative integer value", function() {
    
        var events = database.call("json_parser.parse", {
            p_content: "-1234567890"
        });

        expect(events).to.eql([
            "N-1234567890"
        ]);
    
    });

    test("Negative integer value with possible spaces", function() {
    
        var events = database.call("json_parser.parse", {
            p_content: "   -  1234567890   "
        });

        expect(events).to.eql([
            "N-1234567890"
        ]);
    
    });

    test("Positive float value", function() {
    
        var events = database.call("json_parser.parse", {
            p_content: "12345.67890"
        });

        expect(events).to.eql([
            "N12345.67890"
        ]);
    
    });

    test("Positive float value with zero integer part", function() {
    
        var events = database.call("json_parser.parse", {
            p_content: "0.12345"
        });

        expect(events).to.eql([
            "N0.12345"
        ]);
    
    });

    test("Positive float value with leading/trailing spaces", function() {
    
        var events = database.call("json_parser.parse", {
            p_content: "    12345.67890    "
        });

        expect(events).to.eql([
            "N12345.67890"
        ]);
    
    });

    test("Negative float value", function() {
    
        var events = database.call("json_parser.parse", {
            p_content: "-12345.67890"
        });

        expect(events).to.eql([
            "N-12345.67890"
        ]);
    
    });

    test("Negative float value with possible spaces", function() {
    
        var events = database.call("json_parser.parse", {
            p_content: "    -    12345.67890     "
        });

        expect(events).to.eql([
            "N-12345.67890"
        ]);
    
    });

    test("Boolean value (true)", function() {
    
        var events = database.call("json_parser.parse", {
            p_content: "true"
        });

        expect(events).to.eql([
            "Btrue"
        ]);
    
    });

    test("Boolean value (false)", function() {
    
        var events = database.call("json_parser.parse", {
            p_content: "false"
        });

        expect(events).to.eql([
            "Bfalse"
        ]);
    
    });

    test("Boolean value (true) with leadin/trailing spaces", function() {
    
        var events = database.call("json_parser.parse", {
            p_content: "  true  "
        });

        expect(events).to.eql([
            "Btrue"
        ]);
    
    });

    test("Null", function() {
    
        var events = database.call("json_parser.parse", {
            p_content: "null"
        });

        expect(events).to.eql([
            "E"
        ]);
    
    });

    test("Null with leading/trailing spaces", function() {
    
        var events = database.call("json_parser.parse", {
            p_content: "   null   "
        });

        expect(events).to.eql([
            "E"
        ]);
    
    });
        
});

suite("Object tests", function() {

    test("Empty object", function() {
    
        var events = database.call("json_parser.parse", {
            p_content: "{}"
        });

        expect(events).to.eql([
            "{",
            "}"
        ]);
    
    });
    
    test("Empty object with possible spaces", function() {
    
        var events = database.call("json_parser.parse", {
            p_content: "    {     }      "
        });

        expect(events).to.eql([
            "{",
            "}"
        ]);
    
    });

    test("Object with string property", function() {
    
        var events = database.call("json_parser.parse", {
            p_content: '{"hello":"world"}'
        });

        expect(events).to.eql([
            "{",
            ":hello",
            "Sworld",
            "}"
        ]);
    
    });

    test("Object with a property with escaped characters", function() {
    
        var events = database.call("json_parser.parse", {
            p_content: '{"hello\\n\\t":"world"}'
        });

        expect(events).to.eql([
            "{",
            ":hello\n\t",
            "Sworld",
            "}"
        ]);
    
    });

    test("Object with string property and possible spaces", function() {
    
        var events = database.call("json_parser.parse", {
            p_content: '   {   "hello"   :   "world"   }   '
        });

        expect(events).to.eql([
            "{",
            ":hello",
            "Sworld",
            "}"
        ]);
    
    });

    test("Object with multiple string properties", function() {
    
        var events = database.call("json_parser.parse", {
            p_content: '{"name":"Sergejs","surname":"Vinniks","age":"35"}'
        });

        expect(events).to.eql([
            "{",
            ":name",
            "SSergejs",
            ":surname",
            "SVinniks",
            ":age",
            "S35",
            "}"
        ]);
    
    });

    test("Object with multiple string properties with all possible spaces", function() {
    
        var events = database.call("json_parser.parse", {
            p_content: '  {  "name"  :  "Sergejs"  ,  "surname"  :  "Vinniks"  ,  "age"  :  "35"  }  '
        });

        expect(events).to.eql([
            "{",
            ":name",
            "SSergejs",
            ":surname",
            "SVinniks",
            ":age",
            "S35",
            "}"
        ]);
    
    });

    test("Object with a zero property", function() {
    
        var events = database.call("json_parser.parse", {
            p_content: '{"hello":0}'
        });

        expect(events).to.eql([
            "{",
            ":hello",
            "N0",
            "}"
        ]);
    
    });

    test("Object with a zero property and all possible spaces", function() {
    
        var events = database.call("json_parser.parse", {
            p_content: '  {  "hello"  :  0  }  '
        });

        expect(events).to.eql([
            "{",
            ":hello",
            "N0",
            "}"
        ]);
    
    });

    test("Object with a positive integer property", function() {
    
        var events = database.call("json_parser.parse", {
            p_content: '{"hello":1234567890}'
        });

        expect(events).to.eql([
            "{",
            ":hello",
            "N1234567890",
            "}"
        ]);
    
    });

    test("Object with a negative integer property", function() {
    
        var events = database.call("json_parser.parse", {
            p_content: '{"hello":-1234567890}'
        });

        expect(events).to.eql([
            "{",
            ":hello",
            "N-1234567890",
            "}"
        ]);
    
    });

    test("Object with a negative integer property and possible spaces", function() {
    
        var events = database.call("json_parser.parse", {
            p_content: '   {   "hello"   :   -1234567890    }    '
        });

        expect(events).to.eql([
            "{",
            ":hello",
            "N-1234567890",
            "}"
        ]);
    
    });

    test("Object with multiple integer properties", function() {
    
        var events = database.call("json_parser.parse", {
            p_content: '{"a":123,"b":456,"c":-789}'
        });

        expect(events).to.eql([
            "{",
            ":a",
            "N123",
            ":b",
            "N456",
            ":c",
            "N-789",
            "}"
        ]);
    
    });

    test("Object with multiple integer properties and all possible spaces", function() {
    
        var events = database.call("json_parser.parse", {
            p_content: '  {  "a"  :  123  ,  "b"  :  456  ,  "c"  :  -  789  }  '
        });

        expect(events).to.eql([
            "{",
            ":a",
            "N123",
            ":b",
            "N456",
            ":c",
            "N-789",
            "}"
        ]);
    
    });

    test("Object with a positive float property", function() {
    
        var events = database.call("json_parser.parse", {
            p_content: '{"hello":12345.67890}'
        });

        expect(events).to.eql([
            "{",
            ":hello",
            "N12345.67890",
            "}"
        ]);
    
    });

    test("Object with a negative float property", function() {
    
        var events = database.call("json_parser.parse", {
            p_content: '{"hello":-12345.67890}'
        });

        expect(events).to.eql([
            "{",
            ":hello",
            "N-12345.67890",
            "}"
        ]);
    
    });

    test("Object with a multiple float properties", function() {
    
        var events = database.call("json_parser.parse", {
            p_content: '{"a":12.34,"b":34.56,"c":-56.78}'
        });

        expect(events).to.eql([
            "{",
            ":a",
            "N12.34",
            ":b",
            "N34.56",
            ":c",
            "N-56.78",
            "}"
        ]);
    
    });

    test("Object with a multiple float properties and all possible spaces", function() {
    
        var events = database.call("json_parser.parse", {
            p_content: '  {  "a"  :  12.34  ,  "b"  :  34.56  ,  "c"  :  -  56.78  }  '
        });

        expect(events).to.eql([
            "{",
            ":a",
            "N12.34",
            ":b",
            "N34.56",
            ":c",
            "N-56.78",
            "}"
        ]);
    
    });

    test("Object with a boolean (true) property", function() {
    
        var events = database.call("json_parser.parse", {
            p_content: '{"hello":true}'
        });

        expect(events).to.eql([
            "{",
            ":hello",
            "Btrue",
            "}"
        ]);
    
    });

    test("Object with a boolean (false) property", function() {
    
        var events = database.call("json_parser.parse", {
            p_content: '{"hello":false}'
        });

        expect(events).to.eql([
            "{",
            ":hello",
            "Bfalse",
            "}"
        ]);
    
    });

    test("Object with a boolean (true) property and possible spaces", function() {
    
        var events = database.call("json_parser.parse", {
            p_content: '   {   "hello"   :   true   }   '
        });

        expect(events).to.eql([
            "{",
            ":hello",
            "Btrue",
            "}"
        ]);
    
    });

    test("Object with a null property", function() {
    
        var events = database.call("json_parser.parse", {
            p_content: '{"hello":null}'
        });

        expect(events).to.eql([
            "{",
            ":hello",
            "E",
            "}"
        ]);
    
    });

    test("Object with a null property and possible spaces", function() {
    
        var events = database.call("json_parser.parse", {
            p_content: '   {   "hello"   :   null   }   '
        });

        expect(events).to.eql([
            "{",
            ":hello",
            "E",
            "}"
        ]);
    
    });

    test("Object with multiple scalar properties", function() {
    
        var events = database.call("json_parser.parse", {
            p_content: '{"name":"Sergejs","surname":"Vinniks","age":35,"married":true}'
        });
    
        expect(events).to.eql([
            "{",
            ":name",
            "SSergejs",
            ":surname",
            "SVinniks",
            ":age",
            "N35",
            ":married",
            "Btrue",
            "}"
        ]);

    });
    
    test("Object with multiple scalar properties and all possible spaces", function() {
    
        var events = database.call("json_parser.parse", {
            p_content: '   {   "name"   :   "Sergejs"   ,   "surname"   :    "Vinniks",    "age"  :  35 ,   "married"   :   true   }    '
        });
    
        expect(events).to.eql([
            "{",
            ":name",
            "SSergejs",
            ":surname",
            "SVinniks",
            ":age",
            "N35",
            ":married",
            "Btrue",
            "}"
        ]);

    });

});

suite("Array tests", function() {

    test("Empty array", function() {

        var events = database.call("json_parser.parse", {
            p_content: '[]'
        });
    
        expect(events).to.eql([
            "[",
            "]"
        ]);

    });

    test("Empty array with all possible spaces", function() {

        var events = database.call("json_parser.parse", {
            p_content: ' [ ] '
        });
    
        expect(events).to.eql([
            "[",
            "]"
        ]);

    });

    test("Array with a single string value", function() {

        var events = database.call("json_parser.parse", {
            p_content: '["hello"]'
        });
    
        expect(events).to.eql([
            "[",
            ":0",
            "Shello",
            "]"
        ]);

    });

    test("Array with a single string value and all possible spaces", function() {

        var events = database.call("json_parser.parse", {
            p_content: '  [  "hello"  ]  '
        });
    
        expect(events).to.eql([
            "[",
            ":0",
            "Shello",
            "]"
        ]);

    });

    test("Array with multiple string values", function() {

        var events = database.call("json_parser.parse", {
            p_content: '["hello","world","how","are","you"]'
        });
    
        expect(events).to.eql([
            "[",
            ":0",
            "Shello",
            ":1",
            "Sworld",
            ":2",
            "Show",
            ":3",
            "Sare",
            ":4",
            "Syou",
            "]"
        ]);

    });

    test("Array with multiple string values and all possible spaces", function() {

        var events = database.call("json_parser.parse", {
            p_content: '  [  "hello"  ,  "world"  ,  "how"  ,  "are"  ,  "you"  ]  '
        });
    
        expect(events).to.eql([
            "[",
            ":0",
            "Shello",
            ":1",
            "Sworld",
            ":2",
            "Show",
            ":3",
            "Sare",
            ":4",
            "Syou",
            "]"
        ]);

    });

    test("Array with a single number value", function() {

        var events = database.call("json_parser.parse", {
            p_content: '[12345.678]'
        });
    
        expect(events).to.eql([
            "[",
            ":0",
            "N12345.678",
            "]"
        ]);

    });

    test("Array with a single number value and all possible spaces", function() {

        var events = database.call("json_parser.parse", {
            p_content: '  [  12345.678  ]  '
        });
    
        expect(events).to.eql([
            "[",
            ":0",
            "N12345.678",
            "]"
        ]);

    });

    test("Array with multiple number values", function() {

        var events = database.call("json_parser.parse", {
            p_content: '[12345.678,2,-45,0,-0.12]'
        });
    
        expect(events).to.eql([
            "[",
            ":0",
            "N12345.678",
            ":1",
            "N2",
            ":2",
            "N-45",
            ":3",
            "N0",
            ":4",
            "N-0.12",
            "]"
        ]);

    });

    test("Array with multiple number values and all possible spaces", function() {

        var events = database.call("json_parser.parse", {
            p_content: '  [  12345.678  ,  2  ,  -45  ,  0  ,  -0.12  ]   '
        });
    
        expect(events).to.eql([
            "[",
            ":0",
            "N12345.678",
            ":1",
            "N2",
            ":2",
            "N-45",
            ":3",
            "N0",
            ":4",
            "N-0.12",
            "]"
        ]);

    });

    test("Array with multiple zeros", function() {

        var events = database.call("json_parser.parse", {
            p_content: '[0,0,0]'
        });
    
        expect(events).to.eql([
            "[",
            ":0",
            "N0",
            ":1",
            "N0",
            ":2",
            "N0",
            "]"
        ]);

    });

    test("Array with multiple zeros and all possible spaces", function() {

        var events = database.call("json_parser.parse", {
            p_content: '  [  0  ,  0  ,  0  ]  '
        });
    
        expect(events).to.eql([
            "[",
            ":0",
            "N0",
            ":1",
            "N0",
            ":2",
            "N0",
            "]"
        ]);

    });

    test("Array with a single boolean", function() {

        var events = database.call("json_parser.parse", {
            p_content: '[true]'
        });
    
        expect(events).to.eql([
            "[",
            ":0",
            "Btrue",
            "]"
        ]);

    });

    test("Array with a single boolean and all possible spaces", function() {

        var events = database.call("json_parser.parse", {
            p_content: '  [  true  ]  '
        });
    
        expect(events).to.eql([
            "[",
            ":0",
            "Btrue",
            "]"
        ]);

    });

    test("Array with multiple booleans", function() {

        var events = database.call("json_parser.parse", {
            p_content: '[true,true,false,false,true,false]'
        });
    
        expect(events).to.eql([
            "[",
            ":0",
            "Btrue",
            ":1",
            "Btrue",
            ":2",
            "Bfalse",
            ":3",
            "Bfalse",
            ":4",
            "Btrue",
            ":5",
            "Bfalse",
            "]"
        ]);

    });

    test("Array with multiple booleans and all possible spaces", function() {

        var events = database.call("json_parser.parse", {
            p_content: '  [  true  ,  true  ,  false  ,  false  ,  true  ,  false  ]  '
        });
    
        expect(events).to.eql([
            "[",
            ":0",
            "Btrue",
            ":1",
            "Btrue",
            ":2",
            "Bfalse",
            ":3",
            "Bfalse",
            ":4",
            "Btrue",
            ":5",
            "Bfalse",
            "]"
        ]);

    });

    test("Array with a single null value", function() {

        var events = database.call("json_parser.parse", {
            p_content: '[null]'
        });
    
        expect(events).to.eql([
            "[",
            ":0",
            "E",
            "]"
        ]);

    });

    test("Array with a single null value and all possible spaces", function() {

        var events = database.call("json_parser.parse", {
            p_content: '  [  null  ]  '
        });
    
        expect(events).to.eql([
            "[",
            ":0",
            "E",
            "]"
        ]);

    });

    test("Array with multiple null values", function() {

        var events = database.call("json_parser.parse", {
            p_content: '[null,null,null]'
        });
    
        expect(events).to.eql([
            "[",
            ":0",
            "E",
            ":1",
            "E",
            ":2",
            "E",
            "]"
        ]);

    });

    test("Array with multiple null values and all possible spaces", function() {

        var events = database.call("json_parser.parse", {
            p_content: '  [  null  ,  null  ,  null  ]  '
        });
    
        expect(events).to.eql([
            "[",
            ":0",
            "E",
            ":1",
            "E",
            ":2",
            "E",
            "]"
        ]);

    });

    test("Array with mixed values and spaces 1", function() {

        var events = database.call("json_parser.parse", {
            p_content: '["Hello", -12.9 ,  null, "World",false   ,111   ]  '
        });
    
        expect(events).to.eql([
            "[",
            ":0",
            "SHello",
            ":1",
            "N-12.9",
            ":2",
            "E",
            ":3",
            "SWorld",
            ":4",
            "Bfalse",
            ":5",
            "N111",
            "]"
        ]);

    });

    test("Array with mixed values and spaces 2", function() {

        var events = database.call("json_parser.parse", {
            p_content: '["Hello,\\nWorld", null, null, 987654.0000012, "\\"!\\"", true]'
        });
    
        expect(events).to.eql([
            "[",
            ":0",
            "SHello,\nWorld",
            ":1",
            "E",
            ":2",
            "E",
            ":3",
            "N987654.0000012",
            ":4",
            "S\"!\"",
            ":5",
            "Btrue",
            "]"
        ]);

    });

});

suite("Complex object test", function() {

    test("Object with an empty object property", function() {

        var events = database.call("json_parser.parse", {
            p_content: JSON.stringify({
                obj: {}
            }, "    ")
        });
    
        expect(events).to.eql([
            "{",
            ":obj",
            "{",
            "}",
            "}"
        ]);

    });

    test("Object with an object property", function() {

        var events = database.call("json_parser.parse", {
            p_content: JSON.stringify({
                obj: {
                    name: "Sergejs",
                    age: 35
                }
            }, "    ")
        });
    
        expect(events).to.eql([
            "{",
            ":obj",
            "{",
            ":name",
            "SSergejs",
            ":age",
            "N35",
            "}",
            "}"
        ]);

    });

    test("Object with an object property surrounded by other properties", function() {

        var events = database.call("json_parser.parse", {
            p_content: JSON.stringify({
                string: "Hello",
                obj: {
                    name: "Sergejs",
                    age: 35
                },
                number: 123
            }, "    ")
        });
    
        expect(events).to.eql([
            "{",
            ":string",
            "SHello",
            ":obj",
            "{",
            ":name",
            "SSergejs",
            ":age",
            "N35",
            "}",
            ":number",
            "N123",
            "}"
        ]);

    });

    test("Object with multiple object properties", function() {

        var events = database.call("json_parser.parse", {
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
    
        expect(events).to.eql([
            "{",
            ":obj1",
            "{",
            ":name",
            "SSergejs",
            ":age",
            "N35",
            "}",
            ":obj2",
            "{",
            ":name",
            "SJanis",
            ":age",
            "N99",
            "}",
            "}"
        ]);

    });

    test("Object with multi-level nesting", function() {

        var events = database.call("json_parser.parse", {
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
    
        expect(events).to.eql([
            "{", 
            ":l1_obj1", 
            "{", 
            ":l2_obj1", 
            "{", 
            ":l3_obj1", 
            "{", 
            ":Hello", 
            "SWorld", 
            "}", 
            "}", 
            ":l2_obj2", 
            "{", 
            ":Hello", 
            "SWorld", 
            "}", 
            "}", 
            ":l1_obj2", 
            "{", 
            ":l2_obj1", 
            "{", 
            ":l3_obj1", 
            "{", 
            ":Hello", 
            "SWorld", 
            "}",
            "}",
            "}",
            "}"
        ]);

    });

    test("Object with an empty array property", function() {

        var events = database.call("json_parser.parse", {
            p_content: JSON.stringify({
                arr: []
            }, "    ")
        });
    
        expect(events).to.eql([
            "{",
            ":arr",
            "[",
            "]",
            "}"
        ]);

    });

    test("Object with a number array property", function() {

        var events = database.call("json_parser.parse", {
            p_content: JSON.stringify({
                arr: [1, 2, 3, 4, 5]
            }, "    ")
        });
    
        expect(events).to.eql([
            "{",
            ":arr",
            "[",
            ":0",
            "N1",
            ":1",
            "N2",
            ":2",
            "N3",
            ":3",
            "N4",
            ":4",
            "N5",
            "]",
            "}"
        ]);

    });

    test("Object with an array property surrounded by other properties", function() {

        var events = database.call("json_parser.parse", {
            p_content: JSON.stringify({
                string: "Hello",
                arr: [1, 2, 3, 4, 5],
                boolean: true
            }, "    ")
        });
    
        expect(events).to.eql([
            "{",
            ":string",
            "SHello",
            ":arr",
            "[",
            ":0",
            "N1",
            ":1",
            "N2",
            ":2",
            "N3",
            ":3",
            "N4",
            ":4",
            "N5",
            "]",
            ":boolean",
            "Btrue",
            "}"
        ]);

    });

    test("Object with multiple array properties", function() {

        var events = database.call("json_parser.parse", {
            p_content: JSON.stringify({
                arr1: [1, 2, 3],
                arr2: ["a", "b", "c"],
                arr3: [true, false, null],
            }, "    ")
        });
    
        expect(events).to.eql([
            "{",
            ":arr1",
            "[",
            ":0",
            "N1",
            ":1",
            "N2",
            ":2",
            "N3",
            "]",
            ":arr2",
            "[",
            ":0",
            "Sa",
            ":1",
            "Sb",
            ":2",
            "Sc",
            "]",
            ":arr3",
            "[",
            ":0",
            "Btrue",
            ":1",
            "Bfalse",
            ":2",
            "E",
            "]",
            "}"
        ]);

    });

    test("Two-dimensional array", function() {

        var events = database.call("json_parser.parse", {
            p_content: JSON.stringify([
                [1, 2, 3],
                ["a", "b", "c"],
                [true, false, null]
            ], "    ")
        });
    
        expect(events).to.eql([
            "[",
            ":0",
            "[",
            ":0",
            "N1",
            ":1",
            "N2",
            ":2",
            "N3",
            "]",
            ":1",
            "[",
            ":0",
            "Sa",
            ":1",
            "Sb",
            ":2",
            "Sc",
            "]",
            ":2",
            "[",
            ":0",
            "Btrue",
            ":1",
            "Bfalse",
            ":2",
            "E",
            "]",
            "]"
        ]);

    });

    test("Array of objects", function() {

        var events = database.call("json_parser.parse", {
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
    
        expect(events).to.eql([
            "[",
            ":0",
            "{",
            "}",
            ":1",
            "{",
            ":Hello",
            "SWorld",
            "}",
            ":2",
            "{",
            ":zero",
            "N0",
            "}",
            "]"
        ]);

    });

});
