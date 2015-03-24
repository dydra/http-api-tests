#! /bin/bash

curl_graph_store_get -H "Accept: application/trix" \
   | rapper -q --input nquads --output nquads /dev/stdin - | tr -s '\n' '\t' \
   | fgrep -v "<${STORE_NAMED_GRAPH}>" \
   | fgrep '"default object"' | fgrep -q '"named object"' 
