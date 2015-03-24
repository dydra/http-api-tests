#! /bin/bash

set_sparql_url ${STORE_ACCOUNT} "${STORE_REPOSITORY}-public"

curl_sparql_request --repository "${STORE_REPOSITORY}-public" \
     -H "Accept: application/sparql-results+json" \
     'query=select%20count(*)%20where%20%7bgraph%20?g%20%7b?s%20?p%20?o%7d%7d' \
 | jq '.results.bindings[] | .[].value' | fgrep -q '"1"'
