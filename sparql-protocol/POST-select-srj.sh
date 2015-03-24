#! /bin/bash


curl_sparql_request -H "Accept: application/sparql-results+json" <<EOF \
   | jq '.results.bindings[] | .[].value' | fgrep -q '"1"'
query=select%20count(*)%20where%20%7b?s%20?p%20?o%7d
EOF
