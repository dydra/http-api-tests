#! /bin/bash

# exercise the values extension for a query in-line with the request
# note the distinct input redirections
# should yield a 400 as there is no match for the values argument

curl_sparql_request -w '%{http_code}\n' "--data-urlencode" "query@/dev/fd/3" "values@/dev/fd/4" \
  -H "Content-Type: application/x-www-form-urlencoded" 3<<EOF3 4<<EOF4
 | test_bad_request
select ?name
where { ?ss ?p ?o .
 values ?name1 {} 
}
EOF3
$name2 { "BUK7Y98-80E" "PH3330L" "BSS84" }
EOF4
