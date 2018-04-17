CREATE OR REPLACE FUNCTION json_table (
    p_query IN VARCHAR2,
    p_bind IN bind := NULL
)
RETURN ANYDATASET PIPELINED 
USING t_value_table_query;