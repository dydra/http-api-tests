#! /bin/bash
# test multiple accept headers
# quality should invert apparent order

curl_graph_store_get -H "Accept: application/n-quads;q=0.5, application/rdf+xml" "graph=${STORE_NAMED_GRAPH}" \
   | rapper -q --input rdfxml --output nquads /dev/stdin - | tr -s '\n' '\t' \
   | fgrep -v '"default object"' | fgrep -q '"named object"' 
