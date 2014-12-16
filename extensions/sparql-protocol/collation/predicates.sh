#! /bin/bash

# test collation for the location strings

set_sparql_url "openrdf-sesame" "collation"

curl_sparql_request "Accept: application/sparql-results+json" <<EOF \
 | jq '.results.bindings[] | .[].value' | fgrep -q 'true'

prefix : <http://example.org/> 
select (((str(?location) = 'Aabybro') &&
         (?location < 'Åkirkeby'@da) &&
         (?location <= 'Åkirkeby'@da) &&
         (?location > 'Ølgod'@da) &&
         (?location >= 'Ølgod'@da) &&
         (!(?location = 'Ølgod'@da)))
        as ?ok)
 where {
  ?s :value 3.0 .
  ?s :location ?location .
}
EOF

