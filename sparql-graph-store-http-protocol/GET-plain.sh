#! /bin/bash

curl_graph_store_get -w '%{http_code}\n' -H "Accept: text/plain" \
   | test_not_acceptable_success

#curl_graph_store_get -H "Accept: text/plain" \
#   | rapper -q --input ntriples --output nquads /dev/stdin - | tr -s '\n' '\t' \
#   | fgrep -v "<${STORE_NAMED_GRAPH}>" \
#   | fgrep '"default object"' | fgrep -v -q '"named object"' 
