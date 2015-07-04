#! /bin/bash

# exercise the values extension for a query in-line with the request
# verify multiple arguments

curl_sparql_request -w '%{http_code}\n' \
  "--data-urlencode" "query@/dev/fd/3" \
  "--data-urlencode" "values@/dev/fd/4" \
  "--data-urlencode" "values@/dev/fd/5" \
  -H "Content-Type: application/x-www-form-urlencoded"  3<<EOF3  4<<EOF4 5<<EOF5 \
 | jq '.results.bindings[] | .[].value' | fgrep "blue" | fgrep -q "BSS84"
select ?value1 ?value2
where { 
 values (?name ?value1) {} 
 values (?name ?value2) {} 
}
EOF3
(?name ?value1) { (<http://example.org/one> 'BUK7Y98-80E')
                  (<http://example.org/two> 'PH3330L')
                  (<http://example.org/three> 'BSS84') }
EOF4
(?name ?value2) { (<http://example.org/one> 'red')
                  (<http://example.org/two> 'green')
                  (<http://example.org/three> 'blue') }
EOF5
