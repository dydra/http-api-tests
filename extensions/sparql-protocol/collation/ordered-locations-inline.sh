#! /bin/bash
#
# test the ordering based on in-line values
# nb. decimal values canoncalize to integers.

curl_sparql_request  \
     --repository "collation" <<EOF \
   | jq '.results.bindings[] | .ok.value' | fgrep -q true 

select ((?values = '1,1,2,2,3,3,4,4,5,6,7,8,9.0,10.0,11') as ?ok)
where {
  select (group_concat(?value; separator=',') as ?values)
  where {
    select ?value ?location
    where {
      values (?location ?value) {
        ( 'Allinge'@da 11.0 )
        ( 'Aulum'@da '10.0'^^xsd:float )
        ( 'Broager'@da   '9.0'^^xsd:double )
        ( 'Br\u00E6dstrup'@da  '8.0'^^xsd:decimal )
        ( 'B\u00F8rkop'@da  7.0 )
        ( 'Wandsbek'@da   6.0 )
        ( '\u00C6r\u00F8sk\u00F8bing'@da  5.0 )
        ( '\u00D8lgod'@da  4.0 )
        ( 'Aabybro'@da  3.0 )
        ( '\u00C5kirkeby'@da  2.0 )
        ( 'Aalborg'@da  1.0 )
        ( 'Barcelona'^^xsd:string  4 )
        ( 'Berlin' 3 )
        ( 'New York' 2 )
        ( 'Paris'^^xsd:string  1 )
      }
    } order by (?value)
  }  
}
EOF
