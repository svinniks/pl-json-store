CREATE OR REPLACE TYPE t_json_mismatch FORCE IS OBJECT (
    path t_varchars,
    mismatch VARCHAR2(2)
)
