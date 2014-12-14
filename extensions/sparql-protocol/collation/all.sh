#! /bin/bash

set_sparql_url "openrdf-sesame" "collation"

${CURL} -f -s -S -X GET \
     -H "Accept: application/sparql-results+json" \
     -u "${STORE_TOKEN}:" \
     "${SPARQL_URL}"?'query=select%20distinct%20?p%20where%20%7b?s%20?p%20?o%7d' \
  | jq '.results.bindings[] | .p.value' | fgrep -q 'http://example.org/'


