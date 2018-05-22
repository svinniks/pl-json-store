CREATE OR REPLACE TYPE t_json_value IS OBJECT (

    id NUMBER,
    
    /* Anonymous JSON value creation static methods */
    
    STATIC FUNCTION create_string (
        p_value IN VARCHAR2
    )
    RETURN t_json_value,
    
    STATIC FUNCTION create_date (
        p_value IN DATE
    )
    RETURN t_json_value,
    
    STATIC FUNCTION create_number (
        p_value IN NUMBER
    )
    RETURN t_json_value,
    
    STATIC FUNCTION create_boolean (
        p_value IN BOOLEAN
    )
    RETURN t_json_value,
    
    STATIC FUNCTION create_null
    RETURN t_json_value,
    
    STATIC FUNCTION create_object
    RETURN t_json_value,
    
    STATIC FUNCTION create_array
    RETURN t_json_value,
    
    STATIC FUNCTION create_json (
        p_content IN VARCHAR2
    )
    RETURN t_json_value,
    
    STATIC FUNCTION create_json (
        p_content IN CLOB
    )
    RETURN t_json_value,
    
    STATIC FUNCTION create_json (
        p_builder IN t_json_builder
    )
    RETURN t_json_value,
    
    STATIC FUNCTION create_copy (
        p_value IN t_json_value
    )
    RETURN t_json_value,
    
    /* Constructors for retrieving JSON values by path */
    
    CONSTRUCTOR FUNCTION t_json_value (
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    ) RETURN self AS RESULT,
    
    /* Self casting to the scalar types and JSON */
    
    MEMBER FUNCTION as_string
    RETURN VARCHAR2,
    
    MEMBER FUNCTION as_date
    RETURN DATE,
    
    MEMBER FUNCTION as_number
    RETURN NUMBER,
    
    MEMBER FUNCTION as_boolean
    RETURN BOOLEAN,
    
    MEMBER FUNCTION as_json
    RETURN VARCHAR2,
    
    MEMBER FUNCTION as_json_clob
    RETURN CLOB,
     
    /* Some usefull generic methods */
    
    MEMBER FUNCTION get_parent
    RETURN t_json_value,
    
    MEMBER FUNCTION is_string
    RETURN BOOLEAN,
    
    MEMBER FUNCTION is_date
    RETURN BOOLEAN,
    
    MEMBER FUNCTION is_number
    RETURN BOOLEAN,
    
    MEMBER FUNCTION is_boolean
    RETURN BOOLEAN,
    
    MEMBER FUNCTION is_null
    RETURN BOOLEAN,
    
    MEMBER FUNCTION is_object
    RETURN BOOLEAN,
    
    MEMBER FUNCTION is_array
    RETURN BOOLEAN,
    
    /* Special object methods */

    MEMBER FUNCTION get_keys
    RETURN t_varchars,
    
    MEMBER FUNCTION has (
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    ) 
    RETURN BOOLEAN,
    
    /* Special array methods */
    
    MEMBER FUNCTION get_length
    RETURN PLS_INTEGER,
    
    MEMBER FUNCTION index_of (
        p_value IN VARCHAR2
       ,p_from_index IN NUMBER := 0
    )
    RETURN NUMBER,
    
    MEMBER FUNCTION index_of (
        p_value IN DATE
       ,p_from_index IN NUMBER := 0
    )
    RETURN NUMBER,
    
    MEMBER FUNCTION index_of (
        p_value IN NUMBER
       ,p_from_index IN NUMBER := 0
    )
    RETURN NUMBER,
    
    MEMBER FUNCTION index_of (
        p_value IN BOOLEAN
       ,p_from_index IN NUMBER := 0
    )
    RETURN NUMBER,
    
    MEMBER FUNCTION index_of_null (
        p_from_index IN NUMBER := 0
    )
    RETURN NUMBER,
    
    /* Child value retrieval methods */
        
    MEMBER FUNCTION get (
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    )
    RETURN t_json_value,
    
    MEMBER FUNCTION get (
        p_index IN NUMBER
    )
    RETURN t_json_value,
    
    MEMBER FUNCTION get_string (
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    )
    RETURN VARCHAR2,
    
    MEMBER FUNCTION get_string (
        p_index IN NUMBER
    )
    RETURN VARCHAR2,
    
    MEMBER FUNCTION get_date (
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    )
    RETURN DATE,
    
    MEMBER FUNCTION get_date (
        p_index IN NUMBER
    )
    RETURN DATE,
    
    MEMBER FUNCTION get_number (
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    )
    RETURN NUMBER,
    
    MEMBER FUNCTION get_number (
        p_index IN NUMBER
    )
    RETURN NUMBER,
    
    MEMBER FUNCTION get_boolean (
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    )
    RETURN BOOLEAN,
    
    MEMBER FUNCTION get_boolean (
        p_index IN NUMBER
    )
    RETURN BOOLEAN,
    
    MEMBER FUNCTION get_json (
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    )
    RETURN VARCHAR2,
    
    MEMBER FUNCTION get_json (
        p_index IN NUMBER
    )
    RETURN VARCHAR2,
    
    MEMBER FUNCTION get_json_clob (
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    )
    RETURN CLOB,
    
    MEMBER FUNCTION get_json_clob (
        p_index IN NUMBER
    )
    RETURN CLOB,
    
    /* Property modification methods */
    
    MEMBER FUNCTION set_string (
        p_path IN VARCHAR2,
        p_value IN VARCHAR2,
        p_bind IN bind := NULL
    ) 
    RETURN t_json_value,
    
    MEMBER PROCEDURE set_string (
        self IN t_json_value,
        p_path IN VARCHAR2,
        p_value IN VARCHAR2,
        p_bind IN bind := NULL
    ),
    
    MEMBER FUNCTION set_string (
        p_index IN NUMBER,
        p_value IN VARCHAR2
    ) 
    RETURN t_json_value,
    
    MEMBER PROCEDURE set_string (
        self IN t_json_value,
        p_index IN NUMBER,
        p_value IN VARCHAR2
    ),
    
    MEMBER FUNCTION set_date (
        p_path IN VARCHAR2,
        p_value IN DATE,
        p_bind IN bind := NULL
    ) 
    RETURN t_json_value,
    
    MEMBER PROCEDURE set_date (
        self IN t_json_value,
        p_path IN VARCHAR2,
        p_value IN DATE,
        p_bind IN bind := NULL
    ),
    
    MEMBER FUNCTION set_date (
        p_index IN NUMBER,
        p_value IN DATE
    ) 
    RETURN t_json_value,
    
    MEMBER PROCEDURE set_date (
        self IN t_json_value,
        p_index IN NUMBER,
        p_value IN DATE
    ),
    
    MEMBER FUNCTION set_number (
        p_path IN VARCHAR2,
        p_value IN NUMBER,
        p_bind IN bind := NULL
    ) 
    RETURN t_json_value,
    
    MEMBER PROCEDURE set_number (
        self IN t_json_value,
        p_path IN VARCHAR2,
        p_value IN NUMBER,
        p_bind IN bind := NULL
    ),
    
    MEMBER FUNCTION set_number (
        p_index IN NUMBER,
        p_value IN NUMBER
    ) 
    RETURN t_json_value,
    
    MEMBER PROCEDURE set_number (
        self IN t_json_value,
        p_index IN NUMBER,
        p_value IN NUMBER
    ),
    
    MEMBER FUNCTION set_boolean (
        p_path IN VARCHAR2,
        p_value IN BOOLEAN,
        p_bind IN bind := NULL
    ) 
    RETURN t_json_value,
    
    MEMBER PROCEDURE set_boolean (
        self IN t_json_value,
        p_path IN VARCHAR2,
        p_value IN BOOLEAN,
        p_bind IN bind := NULL
    ),
    
    MEMBER FUNCTION set_boolean (
        p_index IN NUMBER,
        p_value IN BOOLEAN
    ) 
    RETURN t_json_value,
    
    MEMBER PROCEDURE set_boolean (
        self IN t_json_value,
        p_index IN NUMBER,
        p_value IN BOOLEAN
    ),
    
    MEMBER FUNCTION set_null (
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    ) 
    RETURN t_json_value,
    
    MEMBER PROCEDURE set_null (
        self IN t_json_value,
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    ),
    
    MEMBER FUNCTION set_null (
        p_index IN NUMBER
    ) 
    RETURN t_json_value,
    
    MEMBER PROCEDURE set_null (
        self IN t_json_value,
        p_index IN NUMBER
    ),
    
    MEMBER FUNCTION set_object (
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    ) 
    RETURN t_json_value,
    
    MEMBER PROCEDURE set_object (
        self IN t_json_value,
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    ),
    
    MEMBER FUNCTION set_object (
        p_index IN NUMBER
    ) 
    RETURN t_json_value,
    
    MEMBER PROCEDURE set_object (
        self IN t_json_value,
        p_index IN NUMBER
    ),
    
    MEMBER FUNCTION set_array (
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    ) 
    RETURN t_json_value,
    
    MEMBER PROCEDURE set_array (
        self IN t_json_value,
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    ),
    
    MEMBER FUNCTION set_array (
        p_index IN NUMBER
    ) 
    RETURN t_json_value,
    
    MEMBER PROCEDURE set_array (
        self IN t_json_value,
        p_index IN NUMBER
    ),
    
    MEMBER FUNCTION set_json (
        p_path IN VARCHAR2,
        p_content IN VARCHAR2,
        p_bind IN bind := NULL
    ) 
    RETURN t_json_value,
    
    MEMBER PROCEDURE set_json (
        self IN t_json_value,
        p_path IN VARCHAR2,
        p_content IN VARCHAR2,
        p_bind IN bind := NULL
    ),
    
    MEMBER FUNCTION set_json (
        p_index IN NUMBER,
        p_content IN VARCHAR2
    ) 
    RETURN t_json_value,
    
    MEMBER PROCEDURE set_json (
        self IN t_json_value,
        p_index IN NUMBER,
        p_content IN VARCHAR2
    ),
    
    MEMBER FUNCTION set_json (
        p_path IN VARCHAR2,
        p_content IN CLOB,
        p_bind IN bind := NULL
    ) 
    RETURN t_json_value,
    
    MEMBER PROCEDURE set_json (
        self IN t_json_value,
        p_path IN VARCHAR2,
        p_content IN CLOB,
        p_bind IN bind := NULL
    ),
    
    MEMBER FUNCTION set_json (
        p_index IN NUMBER,
        p_content IN CLOB
    ) 
    RETURN t_json_value,
    
    MEMBER PROCEDURE set_json (
        self IN t_json_value,
        p_index IN NUMBER,
        p_content IN CLOB
    ),
    
    MEMBER FUNCTION set_json (
        p_path IN VARCHAR2,
        p_builder IN t_json_builder,
        p_bind IN bind := NULL
    ) 
    RETURN t_json_value,
    
    MEMBER PROCEDURE set_json (
        self IN t_json_value,
        p_path IN VARCHAR2,
        p_builder IN t_json_builder,
        p_bind IN bind := NULL
    ),
    
    MEMBER FUNCTION set_json (
        p_index IN NUMBER,
        p_builder IN t_json_builder
    ) 
    RETURN t_json_value,
    
    MEMBER PROCEDURE set_json (
        self IN t_json_value,
        p_index IN NUMBER,
        p_builder IN t_json_builder
    ),
    
    MEMBER FUNCTION set_copy (
        p_path IN VARCHAR2,
        p_value IN t_json_value,
        p_bind IN bind := NULL
    ) 
    RETURN t_json_value,
    
    MEMBER PROCEDURE set_copy (
        self IN t_json_value,
        p_path IN VARCHAR2,
        p_value IN t_json_value,
        p_bind IN bind := NULL
    ),
    
    MEMBER FUNCTION set_copy (
        p_index IN NUMBER,
        p_value IN t_json_value
    ) 
    RETURN t_json_value,
    
    MEMBER PROCEDURE set_copy (
        self IN t_json_value,
        p_index IN NUMBER,
        p_value IN t_json_value
    ),
    
    /* Array push methods */
    
    MEMBER FUNCTION push_string (
        p_path IN VARCHAR2,
        p_value IN VARCHAR2,
        p_bind IN bind := NULL
    ) 
    RETURN t_json_value,
    
    MEMBER PROCEDURE push_string (
        self IN t_json_value,
        p_path IN VARCHAR2,
        p_value IN VARCHAR2,
        p_bind IN bind := NULL
    ),
    
    MEMBER FUNCTION push_string (
        p_value IN VARCHAR2
    ) 
    RETURN t_json_value,
    
    MEMBER PROCEDURE push_string (
        self IN t_json_value,
        p_value IN VARCHAR2
    ),
    
    MEMBER FUNCTION push_number (
        p_path IN VARCHAR2,
        p_value IN NUMBER,
        p_bind IN bind := NULL
    ) 
    RETURN t_json_value,
    
    MEMBER PROCEDURE push_number (
        self IN t_json_value,
        p_path IN VARCHAR2,
        p_value IN NUMBER,
        p_bind IN bind := NULL
    ),
    
    MEMBER FUNCTION push_number (
        p_value IN NUMBER
    ) 
    RETURN t_json_value,
    
    MEMBER PROCEDURE push_number (
        self IN t_json_value,
        p_value IN NUMBER
    ),
    
    MEMBER FUNCTION push_boolean (
        p_path IN VARCHAR2,
        p_value IN BOOLEAN,
        p_bind IN bind := NULL
    ) 
    RETURN t_json_value,
    
    MEMBER PROCEDURE push_boolean (
        self IN t_json_value,
        p_path IN VARCHAR2,
        p_value IN BOOLEAN,
        p_bind IN bind := NULL
    ),
    
    MEMBER FUNCTION push_boolean (
        p_value IN BOOLEAN
    ) 
    RETURN t_json_value,
    
    MEMBER PROCEDURE push_boolean (
        self IN t_json_value,
        p_value IN BOOLEAN
    ),
    
    MEMBER FUNCTION push_null (
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    ) 
    RETURN t_json_value,
    
    MEMBER PROCEDURE push_null (
        self IN t_json_value,
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    ),
    
    MEMBER FUNCTION push_null
    RETURN t_json_value,
    
    MEMBER PROCEDURE push_null (
        self IN t_json_value
    ),
    
    MEMBER FUNCTION push_object (
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    ) 
    RETURN t_json_value,
    
    MEMBER PROCEDURE push_object (
        self IN t_json_value,
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    ),
    
    MEMBER FUNCTION push_object
    RETURN t_json_value,
    
    MEMBER PROCEDURE push_object (
        self IN t_json_value
    ),
    
    MEMBER FUNCTION push_array (
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    ) 
    RETURN t_json_value,
    
    MEMBER PROCEDURE push_array (
        self IN t_json_value,
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    ),
    
    MEMBER FUNCTION push_array
    RETURN t_json_value,
    
    MEMBER PROCEDURE push_array (
        self IN t_json_value
    ),
    
    MEMBER FUNCTION push_json (
        p_path IN VARCHAR2,
        p_content IN VARCHAR2,
        p_bind IN bind := NULL
    ) 
    RETURN t_json_value,
    
    MEMBER PROCEDURE push_json (
        self IN t_json_value,
        p_path IN VARCHAR2,
        p_content IN VARCHAR2,
        p_bind IN bind := NULL
    ),
    
    MEMBER FUNCTION push_json (
        p_content IN VARCHAR2
    )
    RETURN t_json_value,
    
    MEMBER PROCEDURE push_json (
        self IN t_json_value,
        p_content IN VARCHAR2
    ),
    
    MEMBER FUNCTION push_json (
        p_path IN VARCHAR2,
        p_content IN CLOB,
        p_bind IN bind := NULL
    ) 
    RETURN t_json_value,
    
    MEMBER PROCEDURE push_json (
        self IN t_json_value,
        p_path IN VARCHAR2,
        p_content IN CLOB,
        p_bind IN bind := NULL
    ),
    
    MEMBER FUNCTION push_json (
        p_content IN CLOB
    )
    RETURN t_json_value,
    
    MEMBER PROCEDURE push_json (
        self IN t_json_value,
        p_content IN CLOB
    ),
    
    MEMBER FUNCTION push_json (
        p_builder IN t_json_builder
    )
    RETURN t_json_value,
    
    MEMBER PROCEDURE push_json (
        self IN t_json_value,
        p_builder IN t_json_builder
    ),
    
    /* JSON applying methods */
    
    MEMBER FUNCTION apply_string (
        p_path IN VARCHAR2,
        p_value IN VARCHAR2,
        p_bind IN bind := NULL
    )
    RETURN t_json_value,
    
    MEMBER PROCEDURE apply_string (
        self IN t_json_value,
        p_path IN VARCHAR2,
        p_value IN VARCHAR2,
        p_bind IN bind := NULL
    ),
    
    MEMBER FUNCTION apply_date (
        p_path IN VARCHAR2,
        p_value IN DATE,
        p_bind IN bind := NULL
    )
    RETURN t_json_value,
    
    MEMBER PROCEDURE apply_date (
        self IN t_json_value,
        p_path IN VARCHAR2,
        p_value IN DATE,
        p_bind IN bind := NULL
    ),
    
    MEMBER FUNCTION apply_number (
        p_path IN VARCHAR2,
        p_value IN NUMBER,
        p_bind IN bind := NULL
    )
    RETURN t_json_value,
    
    MEMBER PROCEDURE apply_number (
        self IN t_json_value,
        p_path IN VARCHAR2,
        p_value IN NUMBER,
        p_bind IN bind := NULL
    ),
    
    MEMBER FUNCTION apply_boolean (
        p_path IN VARCHAR2,
        p_value IN BOOLEAN,
        p_bind IN bind := NULL
    )
    RETURN t_json_value,
    
    MEMBER PROCEDURE apply_boolean (
        self IN t_json_value,
        p_path IN VARCHAR2,
        p_value IN BOOLEAN,
        p_bind IN bind := NULL
    ),
    
    MEMBER FUNCTION apply_object (
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    )
    RETURN t_json_value,
    
    MEMBER PROCEDURE apply_object (
        self IN t_json_value,
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    ),
    
    MEMBER FUNCTION apply_array (
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    )
    RETURN t_json_value,
    
    MEMBER PROCEDURE apply_array (
        self IN t_json_value,
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    ),
    
    MEMBER FUNCTION apply_json (
        p_path IN VARCHAR2,
        p_content IN VARCHAR2,
        p_bind IN bind := NULL
    )
    RETURN t_json_value,
    
    MEMBER FUNCTION apply_json (
        p_path IN VARCHAR2,
        p_content IN VARCHAR2,
        p_check_types IN BOOLEAN,
        p_bind IN bind := NULL
    )
    RETURN t_json_value,
    
    MEMBER PROCEDURE apply_json (
        self IN t_json_value,
        p_path IN VARCHAR2,
        p_content IN VARCHAR2,
        p_bind IN bind := NULL
    ),
    
    MEMBER PROCEDURE apply_json (
        self IN t_json_value,
        p_path IN VARCHAR2,
        p_content IN VARCHAR2,
        p_check_types IN BOOLEAN,
        p_bind IN bind := NULL
    ),
    
    MEMBER FUNCTION apply_json (
        p_path IN VARCHAR2,
        p_content IN CLOB,
        p_bind IN bind := NULL
    )
    RETURN t_json_value,
    
    MEMBER FUNCTION apply_json (
        p_path IN VARCHAR2,
        p_content IN CLOB,
        p_check_types IN BOOLEAN,
        p_bind IN bind := NULL
    )
    RETURN t_json_value,
    
    MEMBER PROCEDURE apply_json (
        self IN t_json_value,
        p_path IN VARCHAR2,
        p_content IN CLOB,
        p_bind IN bind := NULL
    ),
    
    MEMBER PROCEDURE apply_json (
        self IN t_json_value,
        p_path IN VARCHAR2,
        p_content IN CLOB,
        p_check_types IN BOOLEAN,
        p_bind IN bind := NULL
    ),
    
    MEMBER FUNCTION apply_json (
        p_path IN VARCHAR2,
        p_builder IN t_json_builder,
        p_bind IN bind := NULL
    )
    RETURN t_json_value,
    
    MEMBER FUNCTION apply_json (
        p_path IN VARCHAR2,
        p_builder IN t_json_builder,
        p_check_types IN BOOLEAN,
        p_bind IN bind := NULL
    )
    RETURN t_json_value,
    
    MEMBER PROCEDURE apply_json (
        self IN t_json_value,
        p_path IN VARCHAR2,
        p_builder IN t_json_builder,
        p_bind IN bind := NULL
    ),
    
    MEMBER PROCEDURE apply_json (
        self IN t_json_value,
        p_path IN VARCHAR2,
        p_builder IN t_json_builder,
        p_check_types IN BOOLEAN,
        p_bind IN bind := NULL
    ),
    
    MEMBER PROCEDURE apply_json (
        self IN t_json_value,
        p_content IN VARCHAR2
    ),
    
    MEMBER PROCEDURE apply_json (
        self IN t_json_value,
        p_content IN VARCHAR2,
        p_check_types IN BOOLEAN
    ),
    
    MEMBER PROCEDURE apply_json (
        self IN t_json_value,
        p_content IN CLOB
    ),
    
    MEMBER PROCEDURE apply_json (
        self IN t_json_value,
        p_content IN CLOB,
        p_check_types IN BOOLEAN
    ),
    
    MEMBER PROCEDURE apply_json (
        self IN t_json_value,
        p_builder IN t_json_builder
    ),
    
    MEMBER PROCEDURE apply_json (
        self IN t_json_value,
        p_builder IN t_json_builder,
        p_check_types IN BOOLEAN
    ),
    
    /* Property deletion */
    
    MEMBER PROCEDURE remove (
        self IN t_json_value,
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    ),
    
    /* Value pinning */
    
    MEMBER PROCEDURE pin (
        self IN t_json_value,
        p_pin_tree IN BOOLEAN := FALSE
    ),
    
    MEMBER PROCEDURE pin (
        self IN t_json_value,
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    ),
    
    MEMBER PROCEDURE pin (
        self IN t_json_value,
        p_path IN VARCHAR2,
        p_pin_tree IN BOOLEAN,
        p_bind IN bind := NULL
    ),
    
    MEMBER PROCEDURE unpin (
        self IN t_json_value,
        p_unpin_tree IN BOOLEAN := FALSE
    ),
    
    MEMBER PROCEDURE unpin (
        self IN t_json_value,
        p_path IN VARCHAR2,
        p_bind IN bind := NULL
    ),
    
    MEMBER PROCEDURE unpin (
        self IN t_json_value,
        p_path IN VARCHAR2,
        p_unpin_tree IN BOOLEAN,
        p_bind IN bind := NULL
    ),
    
    /* JSON builder instantiation methods */
  
    STATIC FUNCTION value (
        p_value IN VARCHAR2
    )
    RETURN t_json_builder,
    
    STATIC FUNCTION value (
        p_value IN DATE
    )
    RETURN t_json_builder,
    
    STATIC FUNCTION value (
        p_value IN NUMBER
    )
    RETURN t_json_builder,
    
    STATIC FUNCTION value (
        p_value IN BOOLEAN
    )
    RETURN t_json_builder,
    
    STATIC FUNCTION object
    RETURN t_json_builder,
    
    STATIC FUNCTION array
    RETURN t_json_builder
        
);