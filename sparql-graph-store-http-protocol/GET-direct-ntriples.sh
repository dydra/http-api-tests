#! /bin/bash

curl_graph_store_get --url ${STORE_NAMED_GRAPH_URL} "-H" "Accept: application/n-triples" \
   | rapper -q --input ntriples --output ntriples /dev/stdin - | tr -s '\n' '\t' \
   | fgrep '"named object"' | fgrep -v "${STORE_NAMED_GRAPH}" \
   | tr -s '\t' '\n' | wc -l | fgrep -q 1

    


