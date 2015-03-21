#! /bin/bash

set_sparql_url "openrdf-sesame" "collation"

curl_sparql_get 'select%20distinct%20?p%20where%20%7b?s%20?p%20?o%7d' \
 | jq '.results.bindings[] | .p.value' | fgrep -c 'http://example.org/' | fgrep -q "2"
