#! /bin/bash

# exercise the values extension for a query in-line with the request
# note the distinct input redirections

curl_sparql_request \
  "--data-urlencode" "query@/dev/fd/3" \
  "--data-urlencode" "values@/dev/fd/4" \
  -H "Content-Type: application/x-www-form-urlencoded"  3<<EOF3  4<<EOF4 \
 | jq '.results.bindings[] | .[].value' | fgrep -q "BSS84"
select ?name
where { values ?name {} }
#where { values ?name {'test'} }
EOF3
?name { 'BUK7Y98-80E' 'PH3330L' "BSS84" }
EOF4

