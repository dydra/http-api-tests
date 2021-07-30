#! /bin/bash
# check text/tab-separated-values

curl_sparql_request \
     -H "Content-Type: application/x-www-form-urlencoded" \
     -H "Accept: text/tab-separated-values" <<EOF \
   | tee ${ECHO_OUTPUT} \
   | tr '\n' ' ' | fgrep 1 | fgrep -qi 'count'
query=select%20(count(*)%20as%20?count)%20where%20%7b?s%20?p%20?o%7d
EOF
