#! /bin/bash


curl_sparql_request \
     -H "Content-Type: application/x-www-form-urlencoded" \
     -H "Accept: application/sparql-results+xml" <<EOF \
   | xmllint  --c14n11 - \
   | tr -s '\t\n\r\f' ' ' | sed 's/ +/ /g' \
   | fgrep -i 'variable name="count1"' \
   | egrep -i -q -s '<binding name="count1">.*<literal .*>1</literal>'
query=select%20count(*)%20where%20%7b?s%20?p%20?o%7d
EOF

