#! /bin/bash


${CURL} -f -s -S -X GET \
     -H "Accept: application/sparql-results+json" \
     ${STORE_URL}/${STORE_ACCOUNT}/${STORE_REPOSITORY}/sparql?'query=select%20distinct%20?p%20where%20%7b?s%20?p%20?o%7d' \
 | jq '.results.bindings[] | .p.value' | fgrep -c 'http://example.org/' | fgrep -q "2"

