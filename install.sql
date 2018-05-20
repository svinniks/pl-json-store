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

@@packages/json_writer.pks
/
@@packages/json_writer.pkb
/

@@packages/json_core.pks
/
@@packages/json_core.pkb
/

@@packages/json_builder.pks
/
@@packages/json_builder.pkb
/

@@types/t_json_builder.tps
/
@@types/t_json_builder.tpb
/

@@types/t_json_value.tps
/
@@types/t_json_value.tpb
/

@@types/t_value_table_query.tps
/
@@types/t_value_table_query.tpb
/

@@packages/json_store.pks
/
@@packages/json_store.pkb
/

@@functions/json_table.fnc
/
@@functions/json_table_5.fnc
/
@@functions/json_table_10.fnc
/
@@functions/json_table_15.fnc
/
@@functions/json_table_20.fnc
/

@@packages/json_data_generator.pks
/
@@views/json_data_registered_types.vw
/
@@packages/json_data_generator.pkb
/

@@public_synonyms.sql
