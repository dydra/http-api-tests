#! /bin/bash

# exercise the values extension for a stored query
# nb. the query "values-update-test" must exist in the account

SPARQL_URL="${STORE_URL}/${STORE_ACCOUNT}/${STORE_REPOSITORY}-write/values-update-test" \
curl_sparql_update "--data-urlencode" "@-" <<EOF \
 | jq '.boolean' | fgrep -q 'true'
values=values=($name $code) { ("BUK7Y98-80E" "one") ("PH3330L" "two") ("BSS84" "three") }
EOF

curl_sparql_request "--data-urlencode" "@-" <<EOF \
 | jq '.results.bindings[] | .[].value' | fgrep -q "BSS84"
query=select ?name
where { ?name ?p ?o }
EOF
