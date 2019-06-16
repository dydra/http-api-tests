#! /bin/bash
#
# test the ordering based on in-line values
# nb. decimal values are reduced to integers.

curl_sparql_request  \
     --repository "collation" <<EOF \
   | jq '.results.bindings[] | .ok.value' | fgrep -q true 

select ((?values = '1,1,2,2,3,3,4,4,5,6,7,8,9,10,11') as ?ok)
where {
  select (group_concat(?tag; separator=',') as ?values)
  where {
    select (floor(?value) as ?tag) ?location (datatype(?value) as ?type)
    where {
      values (?location ?value) {
        ( 'Allinge'@da 11 )
        ( 'Aulum'@da 10 )
        ( 'Broager'@da   9 )
        ( 'Br\u00E6dstrup'@da  8 )
        ( 'B\u00F8rkop'@da  7 )
        ( 'Wandsbek'@da   6 )
        ( '\u00C6r\u00F8sk\u00F8bing'@da  5 )
        ( '\u00D8lgod'@da  4 )
        ( 'Aabybro'@da  3 )
        ( '\u00C5kirkeby'@da  2 )
        ( 'Aalborg'@da  1 )
        ( 'Barcelona'^^xsd:string  4 )
        ( 'Berlin' 3 )
        ( 'New York' 2 )
        ( 'Paris'^^xsd:string  1 )
      }
    } order by (?tag)
  }  
}
EOF
