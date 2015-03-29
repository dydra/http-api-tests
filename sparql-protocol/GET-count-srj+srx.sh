#! /bin/bash

# verify the accept order is observed

curl_sparql_request \
     -H 'Accept: application/sparql-results+json,application/sparql-results+xml,*/*;q=0.9' \
     'query=select%20count(*)%20where%20%7b?s%20?p%20?o%7d' \
   | jq '.results.bindings[] | .[].value' | fgrep -q '"1"'
