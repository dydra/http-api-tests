#! /bin/bash

# count the terms, which incidentally exercises the position-based optimizations

curl_sparql_request \
   --repository "collation" \
   'query=select%20distinct%20?s%20where%20%7b?s%20?p%20?o%7d' \
 | jq '.results.bindings[] | .s.type' | fgrep -c 'bnode' | fgrep -q "15"

curl_sparql_request \
   --repository "collation" \
   'query=select%20distinct%20?p%20where%20%7b?s%20?p%20?o%7d' \
 | jq '.results.bindings[] | .p.value' | fgrep -c 'http://example.org/' | fgrep -q "2"

curl_sparql_request \
   --repository "collation" \
   'query=select%20distinct%20?o%20where%20%7b?s%20?p%20?o%7d' \
 | jq '.results.bindings[] | .o.value' | wc -l | fgrep -q "31"
