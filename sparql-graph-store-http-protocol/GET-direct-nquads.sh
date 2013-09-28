#! /bin/bash


curl -f -s -X GET\
     -H "Accept: application/n-quads" \
     ${STORE_NAMED_GRAPH}?auth_token=${STORE_TOKEN} \
   | rapper -q --input nquads --output nquads \ | tr -s '\n' '\t' \
   | fgrep '"named object"' | fgrep "${STORE_NAMED_GRAPH}" \
   | tr -s '\t' '\n' | wc -l | fgrep -q 1

    


