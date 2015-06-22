#! /bin/bash


curl_graph_store_get -H "Accept: application/n-triples" "graph=${STORE_NAMED_GRAPH}" \
   | rapper -q --input ntriples --output ntriples /dev/stdin - | tr -s '\n' '\t' \
   | fgrep -v "<${STORE_NAMED_GRAPH}>" \
   | fgrep -v '"default object"' | fgrep -q '"named object"' 

