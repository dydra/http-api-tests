#! /bin/bash

# exercise the values extension for a query in-line with the request

curl_sparql_request "--data-urlencode" "@-" <<EOF \
 | jq '.results.bindings[] | .[].value' | fgrep -q "BSS84"
query=select ?name
where {
}&values=$name { "BUK7Y98-80E" "PH3330L" "BSS84" }
EOF
