#! /bin/bash


curl_graph_store_get --url ${STORE_NAMED_GRAPH_URL} \
   | rapper -q --input nquads --output nquads /dev/stdin - | tr -s '\n' '\t' \
   | fgrep '"named object"' | fgrep "${STORE_NAMED_GRAPH}" \
   | tr -s '\t' '\n' | wc -l | fgrep -q 1

    


