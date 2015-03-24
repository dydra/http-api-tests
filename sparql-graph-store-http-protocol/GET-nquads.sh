#! /bin/bash

# for now, must ask for the graph explicitly

curl_graph_store_get -H "Accept: application/n-quads" \
   | rapper -q --input nquads --output nquads /dev/stdin - | tr -s '\n' '\t' \
   | fgrep "<${STORE_NAMED_GRAPH}>" \
   | fgrep '"default object"' | fgrep -q '"named object"' 
