#! /bin/bash
# check text/csv

curl_sparql_request \
     -H "Content-Type: application/x-www-form-urlencoded" \
     -H "Accept: text/csv" <<EOF \
   | tr '\n' ' ' | egrep -e '[[:digit:]]' | fgrep -qi 'count'
query=select%20(count(*)%20as%20?count)%20where%20%7b?s%20?p%20?o%7d
EOF
