#! /bin/bash


curl -f -s -S -X POST \
     -H "Accept: application/sparql-results+json" \
     --data-binary @- \
     -u "${STORE_TOKEN}:" \
     "${SPARQL_URL}"  <<EOF \
 | jq '.results.bindings[] | .[].value' | fgrep -q '"1"'
query=select%20count(*)%20where%20%7b?s%20?p%20?o%7d
EOF
