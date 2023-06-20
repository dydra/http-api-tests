#! /bin/bash

# should yield all statements in the store independent of graph, but encoded as triples.

curl_graph_store_get -H "Accept: application/n-triples" \
   | rapper -q --input ntriples --output ntriples /dev/stdin - | tr -s '\n' '\t' \
   | fgrep -v "<${STORE_NAMED_GRAPH}>" \
   | fgrep '"default object"' | fgrep -q '"named object"' 
