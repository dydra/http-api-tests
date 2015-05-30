#! /bin/bash

# exercise the values extension for a query in-line with the request

curl_sparql_update "--data-urlencode" "@-" <<EOF \
 | jq '.boolean' | fgrep -q 'true'
update=insert { ?name <http://example.org/code> ?code }
where {
  }
&values=($name $code)
        { ("BUK7Y98-80E" "one")
          ("PH3330L" "two")
          ("BSS84" "three") }
EOF

curl_sparql_request "--data-urlencode" "@-" <<EOF \
 | jq '.results.bindings[] | .[].value' | fgrep -q "BSS84"
query=select ?name
where { ?name ?p ?o }
EOF
