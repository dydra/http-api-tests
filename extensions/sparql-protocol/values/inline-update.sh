#! /bin/bash

# exercise the values extension for a query in-line with the request

curl_sparql_update "--data-urlencode" "@-" <<EOF \
 | jq '.results.bindings[] | .[].value' | fgrep -q "BSS84"
update=sinsert { ?name <http://example.org/code> ?code }
where {
  }
&values=($name $code) { ("BUK7Y98-80E" "one") ("PH3330L" "two") ("BSS84" "three") }
EOF

