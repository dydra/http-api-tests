#! /bin/bash

curl_sparql_request \
   --repository "collation" \
   'query=select%20distinct%20?p%20where%20%7b?s%20?p%20?o%7d' \
  | jq '.results.bindings[] | .p.value' | fgrep -q 'http://example.org/'


