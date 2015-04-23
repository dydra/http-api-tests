#! /bin/bash

# exercise the values extension for a stored query
# nb. the query "values-query-test" must exist in the account

SPARQL_URL="${STORE_URL}/${STORE_ACCOUNT}/${STORE_REPOSITORY}/values-query-test" \
curl_sparql_request "--data-urlencode" "@-" <<EOF \
 | jq '.results.bindings[] | .[].value' | fgrep -q "BSS84"
values=$name { "BUK7Y98-80E" "PH3330L" "BSS84" }
EOF
