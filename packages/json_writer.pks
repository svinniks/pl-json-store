CREATE OR REPLACE PACKAGE json_writer IS

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

    PROCEDURE write_json (
        p_parent_id IN NUMBER,
        p_name IN VARCHAR2,
        p_content_parse_events IN json_parser.t_parse_events,
        p_first_event_i IN PLS_INTEGER
    );

    FUNCTION write_json (
        p_parent_id IN NUMBER,
        p_name IN VARCHAR2,
        p_content_parse_events IN json_parser.t_parse_events,
        p_first_event_i IN PLS_INTEGER
    ) 
    RETURN NUMBER;
    
    PROCEDURE flush;
    
    FUNCTION recent_value_id
    RETURN NUMBER;

END;