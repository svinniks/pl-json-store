CREATE OR REPLACE TYPE BODY t_json_table IS

    /* 
        Copyright 2018 Sergejs Vinniks

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
    
    STATIC FUNCTION odcitabledescribe (
        p_return_type OUT ANYTYPE,
        p_query IN VARCHAR2,
        p_bind IN bind := NULL
    ) 
    RETURN PLS_INTEGER IS
        
        v_query_element_i PLS_INTEGER;
        v_query_column_names t_varchars;
        
        v_row_type ANYTYPE;
        
    BEGIN
        
        v_query_element_i := json_core.parse_query(p_query);
        v_query_column_names := json_core.get_query_column_names(v_query_element_i);
        
        ANYTYPE.begincreate(DBMS_TYPES.TYPECODE_OBJECT, v_row_type);
        
        FOR v_i IN 1..v_query_column_names.COUNT LOOP
            v_row_type.addattr(v_query_column_names(v_i), DBMS_TYPES.TYPECODE_VARCHAR2, NULL, NULL, 4000, NULL, NULL);
        END LOOP;
            
        v_row_type.endcreate;
            
        ANYTYPE.begincreate(DBMS_TYPES.TYPECODE_NAMEDCOLLECTION, p_return_type);
        p_return_type.setinfo(NULL, NULL, NULL, NULL, NULL, v_row_type, DBMS_TYPES.TYPECODE_OBJECT, 0);
        p_return_type.endcreate;
    
        RETURN odciconst.success;
    
    END;
    
    STATIC FUNCTION get_row_type (
        p_table_function_info IN sys.odcitabfuncinfo
    )
    RETURN ANYTYPE IS
    
        v_return NUMBER;
        v_precision PLS_INTEGER;
        v_scale PLS_INTEGER;
        v_length PLS_INTEGER;
        v_cs_id PLS_INTEGER;
        v_cs_frm PLS_INTEGER;
        v_row_type ANYTYPE;    
        v_name VARCHAR2(30);
    
    BEGIN
    
        v_return := p_table_function_info.rettype.getattreleminfo(
            1
           ,v_precision
           ,v_scale
           ,v_length
           ,v_cs_id
           ,v_cs_frm
           ,v_row_type
           ,v_name
        );
        RETURN v_row_type;
    
    END;
    
END;
