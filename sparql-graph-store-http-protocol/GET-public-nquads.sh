#! /bin/bash

# test should be read-only
# initialize_repository --repository "${STORE_REPOSITORY}-public"

curl_graph_store_get -u "" -H "Accept: application/n-quads" --repository "${STORE_REPOSITORY}-public" \
   | rapper -q --input nquads --output nquads /dev/stdin - | tr -s '\n' '\t' \
   | fgrep "<${STORE_NAMED_GRAPH}>" \
   | fgrep '"default object"' | fgrep -q '"named object"' 
