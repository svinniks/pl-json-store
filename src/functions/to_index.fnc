CREATE OR REPLACE FUNCTION to_index
    (p_index IN VARCHAR2) 
RETURN NUMBER DETERMINISTIC IS

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

    v_result NUMBER;

BEGIN

    IF p_index = '0' THEN
        RETURN 0;
    ELSIF NOT REGEXP_LIKE(p_index, '^[1-9][0-9]*$') THEN
        RETURN NULL;
    ELSE
        RETURN TO_NUMBER(p_index);
    END IF;
    
EXCEPTION
    WHEN OTHERS THEN
        RETURN NULL;
END;

