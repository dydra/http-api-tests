#! /bin/bash
# test multiple accept headers

curl_graph_store_get "Accept: application/n-quads, application/rdf+xml" "graph=${STORE_NAMED_GRAPH}" \
   | rapper -q --input nquads --output nquads /dev/stdin - | tr -s '\n' '\t' \
   | fgrep "<${STORE_NAMED_GRAPH}>" \
   | fgrep -v '"default object"' | fgrep -q '"named object"' 
