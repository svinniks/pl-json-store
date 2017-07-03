CREATE TABLE json_values (
    id NUMBER NOT NULL
   ,parent_id NUMBER
   ,type CHAR
   ,name VARCHAR2(4000)
   ,value VARCHAR2(4000)
   ,CONSTRAINT jsvl_pk PRIMARY KEY(id)
   ,CONSTRAINT jsvl_jsvl_fk FOREIGN KEY(parent_id) REFERENCES json_values(id) ON DELETE CASCADE
)
/

CREATE INDEX jsvl_i1 ON json_values(parent_id)
/

CREATE INDEX jsvl_i2 ON json_values(name, parent_id)

