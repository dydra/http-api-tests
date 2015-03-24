#! /bin/bash
# test multiple accept headers

curl_graph_store_get -H "Accept: application/rdf+xml, application/n-quads" "graph=${STORE_NAMED_GRAPH}" \
   | rapper -q --input rdfxml --output nquads /dev/stdin - | tr -s '\n' '\t' \
   | fgrep "<${STORE_NAMED_GRAPH}>" \
   | fgrep -v '"default object"' | fgrep -q '"named object"' 
