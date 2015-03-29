#! /bin/bash

curl_sparql_request \
     -H "Accept: application/sparql-results+json" \
     'query=select%20(count(*)%20as%20%3Fcount)%20where%20%7B%3Fs%20%3Fp%20%3Fo%7D' \
   | jq '.results.bindings | .[].count.value' \
   | fgrep -q '"1"'

