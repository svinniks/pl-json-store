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

@@types/bind.tps
/

@@sequences/jsvl_id.seq
/

@@functions/to_index.fnc
/

@@tables/json_values.tab
/

INSERT INTO json_values (
    id,
    type,
    locked
) VALUES (
    0,
    'R',
    'T'
)    
/

COMMIT
/

@@indexes/jsvl_i1.idx
/
@@indexes/jsvl_i2.idx
/

@@packages/json_parser.pks
/
@@packages/json_parser.pkb
/

@@types/t_json_value.tps
/
@@types/t_value_table_query.tps
/

@@packages/json_core.pks
/
@@packages/json_store.pks
/

@@types/t_json_value.tpb
/
@@types/t_value_table_query.tpb
/

@@packages/json_core.pkb
/
@@packages/json_store.pkb
/

@@packages/json_data_generator.pks
/
@@views/json_data_registered_types.vw
/
@@packages/json_data_generator.pkb
/


