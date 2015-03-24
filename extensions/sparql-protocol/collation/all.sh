#! /bin/bash

set_sparql_url "${STORE_ACCOUNT}" "collation"

curl_sparql_get 'select%20distinct%20?p%20where%20%7b?s%20?p%20?o%7d' \
  | cat # jq '.results.bindings[] | .p.value' | fgrep -q 'http://example.org/'


