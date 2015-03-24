#! /bin/bash


curl_graph_store_get -H "Accept: application/n-quads" "graph=${STORE_NAMED_GRAPH}" \
   | rapper -q --input nquads --output nquads /dev/stdin - | tr -s '\n' '\t' \
   | fgrep "<${STORE_NAMED_GRAPH}>" \
   | fgrep -v '"default object"' | fgrep -q '"named object"' 


#curl -L -v -f -s -S -X GET\
#     -H "Accept: application/nquads" \
#     -u "${STORE_TOKEN}:" \
#     "${STORE_URL}/${STORE_ACCOUNT}/${STORE_REPOSITORY}?graph=${STORE_NAMED_GRAPH}"
