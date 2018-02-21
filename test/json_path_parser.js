suite("Invalid path tests", function() {

    test("Invalid start of the path", function() {
    
        expect(function() {
        
            var result = database.call("json_store.parse_path", {
                p_path: "123"
            });
        
        }).to.throw(/JDOC-00001/);
    
    });

    test("Invalid start of the path with spaces", function() {
    
        expect(function() {
        
            var result = database.call("json_store.parse_path", {
                p_path: "   123"
            });
        
        }).to.throw(/JDOC-00001/);
    
    });
    
    test("Invalid start of the property", function() {
    
        expect(function() {
        
            var result = database.call("json_store.parse_path", {
                p_path: "hello.123"
            });
        
        }).to.throw(/JDOC-00001/);
    
    });

    test("Invalid start of the property with spaces", function() {
    
        expect(function() {
        
            var result = database.call("json_store.parse_path", {
                p_path: "  hello  .  123"
            });
        
        }).to.throw(/JDOC-00001/);
    
    });

    test("Invalid character in simple name", function() {
    
        expect(function() {
        
            var result = database.call("json_store.parse_path", {
                p_path: "hello-123"
            });
        
        }).to.throw(/JDOC-00001/);
    
    });

    test("Invalid start of ID", function() {
    
        expect(function() {
        
            var result = database.call("json_store.parse_path", {
                p_path: "#a"
            });
        
        }).to.throw(/JDOC-00001/);
    
    });

    test("Invalid character in ID", function() {
    
        expect(function() {
        
            var result = database.call("json_store.parse_path", {
                p_path: "#123a"
            });
        
        }).to.throw(/JDOC-00001/);
    
    });

    test(". or [ missing", function() {
    
        expect(function() {
        
            var result = database.call("json_store.parse_path", {
                p_path: "abc abc"
            });
        
        }).to.throw(/JDOC-00001/);
    
    });

    test("Invalid start of array element", function() {
    
        expect(function() {
        
            var result = database.call("json_store.parse_path", {
                p_path: "abc[cda]"
            });
        
        }).to.throw(/JDOC-00001/);
    
    });

    test("Invalid start of array element with spaces", function() {
    
        expect(function() {
        
            var result = database.call("json_store.parse_path", {
                p_path: "  abc  [  cba  ]  "
            });
        
        }).to.throw(/JDOC-00001/);
    
    });

    test("Invalid character in array element", function() {
    
        expect(function() {
        
            var result = database.call("json_store.parse_path", {
                p_path: "abc[123a]"
            });
        
        }).to.throw(/JDOC-00001/);
    
    });

    test("] missing", function() {
    
        expect(function() {
        
            var result = database.call("json_store.parse_path", {
                p_path: "abc[123.cba"
            });
        
        }).to.throw(/JDOC-00001/);
    
    });

    test("Trailing ] missing", function() {
    
        expect(function() {
        
            var result = database.call("json_store.parse_path", {
                p_path: "abc[123"
            });
        
        }).to.throw(/JDOC-00002/);
    
    });

    test("Name closing quote missing", function() {
    
        expect(function() {
        
            var result = database.call("json_store.parse_path", {
                p_path: "\"abc" 
            });
        
        }).to.throw(/JDOC-00002/);
    
    });

    test("Array element closing quote missing", function() {
    
        expect(function() {
        
            var result = database.call("json_store.parse_path", {
                p_path: 'hello["world'
            });
        
        }).to.throw(/JDOC-00002/);
    
    });

    test("Dot in the end", function() {
    
        expect(function() {
        
            var result = database.call("json_store.parse_path", {
                p_path: 'hello.world.'
            });
        
        }).to.throw(/JDOC-00002/);
    
    });

    test("Dot in the end with spaces", function() {
    
        expect(function() {
        
            var result = database.call("json_store.parse_path", {
                p_path: '  hello  .  world  .  '
            });
        
        }).to.throw(/JDOC-00002/);
    
    });

});

suite("Valid path tests", function() {

    test("Empty path", function() {

        var result = database.call("json_store.parse_path", {
            p_path: null
        });

        expect(result).to.eql([]);

    });

    test("Empty path (spaces only)", function() {

        var result = database.call("json_store.parse_path", {
            p_path: "   "
        });

        expect(result).to.eql([]);

    });

    test("Root only", function() {

        var result = database.call("json_store.parse_path", {
            p_path: "$"
        });

        expect(result).to.eql([
            {
                type: 'R',
                value: null
            }
        ]);

    });

    test("Root only with spaces", function() {

        var result = database.call("json_store.parse_path", {
            p_path: "  $    "
        });

        expect(result).to.eql([
            {
                type: 'R',
                value: null
            }
        ]);

    });

    test("Single simple name", function() {

        var result = database.call("json_store.parse_path", {
            p_path: "hello"
        });

        expect(result).to.eql([
            {
                type: 'N',
                value: "hello"
            }
        ]);

    });

    test("Single simple name with spaces", function() {

        var result = database.call("json_store.parse_path", {
            p_path: "   hello   "
        });

        expect(result).to.eql([
            {
                type: 'N',
                value: "hello"
            }
        ]);

    });

    test("Single quoted name", function() {

        var result = database.call("json_store.parse_path", {
            p_path: '" 89 "'
        });

        expect(result).to.eql([
            {
                type: 'N',
                value: " 89 "
            }
        ]);

    });

    test("Single quoted name with spaces", function() {

        var result = database.call("json_store.parse_path", {
            p_path: '   " 89 "   '
        });

        expect(result).to.eql([
            {
                type: 'N',
                value: " 89 "
            }
        ]);

    });

    test("Single quoted name with escaped quote", function() {

        var result = database.call("json_store.parse_path", {
            p_path: '" 89\\" "'
        });

        expect(result).to.eql([
            {
                type: 'N',
                value: " 89\" "
            }
        ]);

    });

    test("Single ID", function() {

        var result = database.call("json_store.parse_path", {
            p_path: '#12345'
        });

        expect(result).to.eql([
            {
                type: 'I',
                value: "12345"
            }
        ]);

    });

    test("Single ID with spaces", function() {

        var result = database.call("json_store.parse_path", {
            p_path: '   #12345   '
        });

        expect(result).to.eql([
            {
                type: 'I',
                value: "12345"
            }
        ]);

    });

    test("Single digit array element of root", function() {

        var result = database.call("json_store.parse_path", {
            p_path: '$[1]'
        });

        expect(result).to.eql([
            {
                type: 'R',
                value: null
            },
            {
                type: 'N',
                value: "1"
            }
        ]);

    });

    test("Single digit array element of root with spaces", function() {

        var result = database.call("json_store.parse_path", {
            p_path: '  $  [  1  ]  '
        });

        expect(result).to.eql([
            {
                type: 'R',
                value: null
            },
            {
                type: 'N',
                value: "1"
            }
        ]);

    });

    test("Multi-digit array element of root", function() {

        var result = database.call("json_store.parse_path", {
            p_path: '$[12345]'
        });

        expect(result).to.eql([
            {
                type: 'R',
                value: null
            },
            {
                type: 'N',
                value: "12345"
            }
        ]);

    });

    test("Multi-digit array element of root with spaces", function() {

        var result = database.call("json_store.parse_path", {
            p_path: '  $  [  12345  ]  '
        });

        expect(result).to.eql([
            {
                type: 'R',
                value: null
            },
            {
                type: 'N',
                value: "12345"
            }
        ]);

    });

    test("Just an array element", function() {

        var result = database.call("json_store.parse_path", {
            p_path: '[12345]'
        });

        expect(result).to.eql([
            {
                type: 'N',
                value: "12345"
            }
        ]);

    });

    test("Quoted array element of root", function() {

        var result = database.call("json_store.parse_path", {
            p_path: '$["hello"]'
        });

        expect(result).to.eql([
            {
                type: 'R',
                value: null
            },
            {
                type: 'N',
                value: "hello"
            }
        ]);

    });

    test("Quoted array element of root with spaces", function() {

        var result = database.call("json_store.parse_path", {
            p_path: '  $  [  "hello"  ]  '
        });

        expect(result).to.eql([
            {
                type: 'R',
                value: null
            },
            {
                type: 'N',
                value: "hello"
            }
        ]);

    });

    test("Array element of simple name", function() {

        var result = database.call("json_store.parse_path", {
            p_path: 'hello[123]'
        });

        expect(result).to.eql([
            {
                type: 'N',
                value: "hello"
            },
            {
                type: 'N',
                value: "123"
            }
        ]);

    });

    test("Array element of simple name with spaces", function() {

        var result = database.call("json_store.parse_path", {
            p_path: '  hello  [  123  ]  '
        });

        expect(result).to.eql([
            {
                type: 'N',
                value: "hello"
            },
            {
                type: 'N',
                value: "123"
            }
        ]);

    });

    test("Array element of quoted name", function() {

        var result = database.call("json_store.parse_path", {
            p_path: '"hello"[123]'
        });

        expect(result).to.eql([
            {
                type: 'N',
                value: "hello"
            },
            {
                type: 'N',
                value: "123"
            }
        ]);

    });

    test("Array element of quoted name with spaces", function() {

        var result = database.call("json_store.parse_path", {
            p_path: '  "hello"  [  123  ]  '
        });

        expect(result).to.eql([
            {
                type: 'N',
                value: "hello"
            },
            {
                type: 'N',
                value: "123"
            }
        ]);

    });

    test("Array element of ID", function() {

        var result = database.call("json_store.parse_path", {
            p_path: '#123[456]'
        });

        expect(result).to.eql([
            {
                type: 'I',
                value: "123"
            },
            {
                type: 'N',
                value: "456"
            }
        ]);

    });

    test("Array element of ID with spaces", function() {

        var result = database.call("json_store.parse_path", {
            p_path: '  #123  [  456  ]  '
        });

        expect(result).to.eql([
            {
                type: 'I',
                value: "123"
            },
            {
                type: 'N',
                value: "456"
            }
        ]);

    });

    test("Multi-dimensional array access", function() {

        var result = database.call("json_store.parse_path", {
            p_path: 'array[123]["321"]'
        });

        expect(result).to.eql([
            {
                type: 'N',
                value: "array"
            },
            {
                type: 'N',
                value: "123"
            },
            {
                type: 'N',
                value: "321"
            }
        ]);

    });

    test("Multi-dimensional array access with spaces", function() {

        var result = database.call("json_store.parse_path", {
            p_path: ' array [123] ["321"] '
        });

        expect(result).to.eql([
            {
                type: 'N',
                value: "array"
            },
            {
                type: 'N',
                value: "123"
            },
            {
                type: 'N',
                value: "321"
            }
        ]);

    });

    test("Multiple mixed elements", function() {

        var result = database.call("json_store.parse_path", {
            p_path: 'hello.world.#12345.#54321."aaa"."bbb"[1]'
        });

        expect(result).to.eql([
            {
                type: 'N',
                value: "hello"
            },
            {
                type: 'N',
                value: "world"
            },
            {
                type: 'I',
                value: "12345"
            },
            {
                type: 'I',
                value: "54321"
            },
            {
                type: 'N',
                value: "aaa"
            },
            {
                type: 'N',
                value: "bbb"
            },
            {
                type: 'N',
                value: "1"
            }
        ]);

    });

    test("Multiple mixed elements with spaces", function() {

        var result = database.call("json_store.parse_path", {
            p_path: '  hello  .  world  .  #12345  .  #54321  .  "aaa"  .  "bbb"  '
        });

        expect(result).to.eql([
            {
                type: 'N',
                value: "hello"
            },
            {
                type: 'N',
                value: "world"
            },
            {
                type: 'I',
                value: "12345"
            },
            {
                type: 'I',
                value: "54321"
            },
            {
                type: 'N',
                value: "aaa"
            },
            {
                type: 'N',
                value: "bbb"
            }
        ]);

    });

    test("Multiple mixed elements starting with root", function() {

        var result = database.call("json_store.parse_path", {
            p_path: '$.hello.world.#12345.#54321."aaa"."bbb"'
        });

        expect(result).to.eql([
            {
                type: 'R',
                value: null
            },
            {
                type: 'N',
                value: "hello"
            },
            {
                type: 'N',
                value: "world"
            },
            {
                type: 'I',
                value: "12345"
            },
            {
                type: 'I',
                value: "54321"
            },
            {
                type: 'N',
                value: "aaa"
            },
            {
                type: 'N',
                value: "bbb"
            }
        ]);

    });

    test("Multiple mixed elements starting with root, with spaces", function() {

        var result = database.call("json_store.parse_path", {
            p_path: '  $  .  hello . world.#12345.#54321."aaa"."bbb"'
        });

        expect(result).to.eql([
            {
                type: 'R',
                value: null
            },
            {
                type: 'N',
                value: "hello"
            },
            {
                type: 'N',
                value: "world"
            },
            {
                type: 'I',
                value: "12345"
            },
            {
                type: 'I',
                value: "54321"
            },
            {
                type: 'N',
                value: "aaa"
            },
            {
                type: 'N',
                value: "bbb"
            }
        ]);

    });

});

