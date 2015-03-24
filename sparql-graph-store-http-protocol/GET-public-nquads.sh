#! /bin/bash

curl_graph_store_get -u "" -H "Accept: application/n-quads" --repository "${STORE_REPOSITORY_PUBLIC}" \
   | rapper -q --input nquads --output nquads /dev/stdin - | tr -s '\n' '\t' \
   | fgrep "<${STORE_NAMED_GRAPH}>" \
   | fgrep '"default object"' | fgrep -q '"named object"' 
