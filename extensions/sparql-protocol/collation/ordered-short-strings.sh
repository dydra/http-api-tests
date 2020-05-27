#! /bin/bash
#
# test the ordering of short strings.

curl_sparql_request  \
     --repository "collation" <<EOF \
   | jq '.results.bindings[] | .ok.value' | fgrep -q true 

select ((?values = '1,2,3,4,5,6,7,8,9,10,11') as ?ok)
where {
  select (group_concat(?tag; separator=',') as ?values)
  where {
    select (floor(?value) as ?tag) ?string
    where {
      values (?string ?value)
                 {('74AHC00D' 11)
                  ('1N5352BG+' 8)
                  ('1N5352BG' 7)
                  ('666aaa011+666aaa011' 9)
                  ('666aaa012+' 10)
                  ('006aaa011+' 5)
                  ('006aaa012' 6)
                  (<http://test-url2> 2)
                  (<http://test-url1> 1)
                  ('ls1'@en 3)
                  ('ls2'@en 4) }
    } order by (?string)
  }  
}
EOF
