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

DROP PACKAGE json_store
/

DROP FUNCTION persistent_json_table
/
DROP TYPE t_persistent_json_table FORCE
/
DROP TYPE t_json_table FORCE
/

DROP TYPE t_persistent_json FORCE
/
DROP TYPE t_transient_json FORCE
/

DROP TYPE t_json_filter FORCE
/
DROP PACKAGE json_filters 
/
DROP TYPE t_json_properties FORCE
/
DROP TYPE t_json_property FORCE
/

DROP TYPE t_json FORCE
/

DROP TYPE t_json_builder FORCE
/
DROP PACKAGE json_builders
/

DROP PACKAGE transient_json_store
/
DROP PACKAGE persistent_json_store
/
DROP PACKAGE persistent_json_writer
/
DROP PACKAGE json_core
/

DROP TABLE json_values
/
DROP SEQUENCE jsvl_id
/

DROP FUNCTION to_index
/

DROP PACKAGE json_parser
/

DROP TYPE t_json_mismatches FORCE
/
DROP TYPE t_json_mismatch FORCE
/

DROP TYPE t_20_value_table FORCE
/ 
DROP TYPE t_15_value_table FORCE
/
DROP TYPE t_10_value_table FORCE
/
DROP TYPE t_5_value_table FORCE
/

DROP TYPE t_20_value_row FORCE
/
DROP TYPE t_15_value_row FORCE
/
DROP TYPE t_10_value_row FORCE
/
DROP TYPE t_5_value_row FORCE
/

DROP TYPE bind FORCE
/
