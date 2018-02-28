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

@@sequences/jsvl_id.seq
/

@@functions/to_index.fnc
/

@@tables/json_values.tab
/

INSERT INTO json_values (
    id,
    type
) VALUES (
    0,
    'R'
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

@@types/t_json_query.tps
/

@@packages/json_store.pks
/

@@types/t_json_query.tpb
/

@@packages/json_store.pkb
/

