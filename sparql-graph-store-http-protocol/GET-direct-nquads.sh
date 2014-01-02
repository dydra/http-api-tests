#! /bin/bash


${CURL} -f -s -X GET \
     -H "Accept: application/n-quads" \
     ${STORE_NAMED_GRAPH_URL}?auth_token=${STORE_TOKEN} \
   | rapper -q --input nquads --output nquads /dev/stdin - | tr -s '\n' '\t' \
   | fgrep '"named object"' | fgrep "${STORE_NAMED_GRAPH}" \
   | tr -s '\t' '\n' | wc -l | fgrep -q 1

    


