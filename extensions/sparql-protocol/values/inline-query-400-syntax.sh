#! /bin/bash

# exercise the values extension for a query in-line with the request
# should yield a 400 as there is a syntax error in the argument

curl_sparql_request -w '%{http_code}\n' \
  "--data-urlencode" "query@/dev/fd/3" \
  "--data-urlencode" "values@/dev/fd/4" \
  -H "Content-Type: application/x-www-form-urlencoded"  3<<EOF3  4<<EOF4 \
 | test_bad_request
select ?name
where { ?s ?p ?o .
 values ?name1 {} 
}
EOF3
?name2 { "BUK7Y98-80E" "PH3330L" "BSS84 }
EOF4
