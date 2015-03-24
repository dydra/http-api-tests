#! /bin/bash

curl_graph_store_get -H "Accept: application/rdf+json" \
   | rapper -q --input json --output nquads /dev/stdin - | tr -s '\n' '\t' \
   | fgrep -v "<${STORE_NAMED_GRAPH}>" \
   | fgrep '"default object"' | fgrep -q '"named object"' 
