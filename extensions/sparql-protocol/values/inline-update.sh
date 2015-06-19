#! /bin/bash

# exercise the values extension for a query in-line with the request

curl_sparql_request \
   "--data-urlencode" "update@/dev/fd/3" \
   "--data-urlencode" "values@/dev/fd/4" \
   -H "Content-Type: application/x-www-form-urlencoded" \
   --repository "${STORE_REPOSITORY}-write" 3<<EOF3 4<<EOF4 \
 | jq '.boolean' | fgrep -q 'true'
DROP  SILENT  ALL;
insert { ?name <http://example.org/code> ?code }
where { values (?name  ?code) {} }
EOF3
(?name ?code)
        { ("BUK7Y98-80E" "one")
          ("PH3330L" "two")
          ("BSS84" "three") }
EOF4

curl_sparql_request "--data-binary" "@-" \
   --repository "${STORE_REPOSITORY}-write" <<EOF \
 | jq '.results.bindings[] | .[].value' | fgrep -q "BSS84"
select ?name
where { ?name ?p ?o }
EOF
