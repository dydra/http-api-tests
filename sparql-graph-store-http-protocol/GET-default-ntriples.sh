#! /bin/bash

curl_graph_store_get "Accept: application/n-triples" "default" \
   | rapper -q --input ntriples --output ntriples /dev/stdin - | tr -s '\n' '\t' \
   | fgrep '"default object"' | fgrep -v -q '"named object"' 
