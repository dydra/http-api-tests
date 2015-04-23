#! /bin/bash

# exercise the values extension for a stored query
# nb. the query "values-update-test" must exist in the account

SPARQL_URL="${STORE_URL}/${STORE_ACCOUNT}/${STORE_REPOSITORY}-write/values-update-test" \
curl_sparql_request "--data-urlencode" "@-" -X ECHO <<EOF \
 | jq '.results.bindings[] | .[].value' | fgrep -q "BSS84"
values=values=($name $code) { ("BUK7Y98-80E" "one") ("PH3330L" "two") ("BSS84" "three") }
EOF
