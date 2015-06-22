#! /bin/bash
# test multiple accept headers
# rdfxml should have the named graph object, but neither the graph name nor the default graph object

curl_graph_store_get -H "Accept: application/rdf+xml, application/n-quads" "graph=${STORE_NAMED_GRAPH}" \
   | rapper -q --input rdfxml --output nquads /dev/stdin - | tr -s '\n' '\t' \
   | fgrep -v "<${STORE_NAMED_GRAPH}>" \
   | fgrep -v '"default object"' | fgrep -q '"named object"' 
