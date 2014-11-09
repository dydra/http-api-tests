#! /bin/bash


curl -f -s -S -X GET \
     -H "Accept: application/sparql-results+json" \
     ${STORE_URL}/${STORE_ACCOUNT}/${STORE_REPOSITORY}-anon?'query=select%20count(*)%20where%20%7bgraph%20?g%20%7b?s%20?p%20?o%7d%7d' \
 | jq '.results.bindings[] | .[].value' | fgrep -q '"1"'