CREATE OR REPLACE FUNCTION to_index
    (p_index IN VARCHAR2) 
RETURN NUMBER DETERMINISTIC IS

    v_result NUMBER;

BEGIN

    IF p_index = '0' THEN
    
        RETURN 0;
        
    ELSIF NOT REGEXP_LIKE(p_index, '^[1-9][0-9]*$') THEN
    
        RETURN NULL;
        
    ELSE

        v_result := TO_NUMBER(p_index);
        
        IF v_result < 0 OR TRUNC(v_result) != v_result THEN
            RETURN NULL;
        END IF;
        
        RETURN v_result;
        
    END IF;
    
EXCEPTION
    WHEN OTHERS THEN
        RETURN NULL;
END;
