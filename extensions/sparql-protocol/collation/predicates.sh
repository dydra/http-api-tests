#! /bin/bash

# test collation for the location strings

curl_sparql_request  \
     -H "Accept: application/sparql-results+json" \
     --repository "collation" <<EOF \
   | jq '.results.bindings[] | .[].value' | fgrep -q 'true'

prefix : <http://example.org/> 
select (((str(?location) = 'Aabybro')
         && (?location < 'Åkirkeby'@da)
         && (?location <= 'Åkirkeby'@da)
         && (?location > 'Ølgod'@da)
         && (?location >= 'Ølgod'@da)
         && (!(?location = 'Ølgod'@da))
         )
        as ?ok)
 where {
  ?s :value 3.0 .
  ?s :location ?location .
}
EOF

