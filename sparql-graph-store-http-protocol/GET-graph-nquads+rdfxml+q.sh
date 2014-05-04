#! /bin/bash
# test multiple accept headers
# quality should invert order

curl -f -s -S -X GET\
     -H "Accept: application/n-quads;q=0.5" \
     -H "Accept: application/n-rdfxml" \
     ${STORE_URL}/${STORE_ACCOUNT}/${STORE_REPOSITORY}?graph=${STORE_NAMED_GRAPH}\&auth_token=${STORE_TOKEN} \
   | rapper -q --input rdfxml --output nquads /dev/stdin - | tr -s '\n' '\t' \
   | fgrep "<${STORE_NAMED_GRAPH}>" \
   | fgrep -v '"default object"' | fgrep -q '"named object"' 