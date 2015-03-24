#! /bin/bash


curl_graph_store_get "Accept: application/n-triples" "graph=${STORE_NAMED_GRAPH}" \
   | rapper -q --input nquads --output nquads /dev/stdin - | tr -s '\n' '\t' \
   | fgrep -v "<${STORE_NAMED_GRAPH}>" \
   | fgrep -v '"default object"' | fgrep -q '"named object"' 

