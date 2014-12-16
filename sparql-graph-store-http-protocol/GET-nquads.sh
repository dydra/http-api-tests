#! /bin/bash

# for now, must ask for the graph explicitly

curl -f -s -S -X GET\
     -H "Accept: application/n-quads" \
     -u "${STORE_TOKEN}:" \
     ${STORE_URL}/${STORE_ACCOUNT}/${STORE_REPOSITORY}/service?graph=${STORE_NAMED_GRAPH} \
   | rapper -q --input nquads --output nquads /dev/stdin - | tr -s '\n' '\t' \
   | fgrep "<${STORE_NAMED_GRAPH}>" \
   | fgrep '"default object"' | fgrep -q '"named object"' 
