#! /bin/bash

curl_graph_store_get "Accept: application/n-quads" "default" \
   | rapper -q --input nquads --output nquads /dev/stdin - | tr -s '\n' '\t' \
   | fgrep '"default object"' | fgrep -v -q '"named object"' 

