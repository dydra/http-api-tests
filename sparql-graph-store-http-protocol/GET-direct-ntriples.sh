#! /bin/bash


curl -f -s -X GET\
     -H "Accept: application/n-triples" \
     ${STORE_NAMED_GRAPH}?auth_token=${STORE_TOKEN} \
   | rapper -q --input ntriples --output ntriples \ | tr -s '\n' '\t' \
   | fgrep '"named object"' | -v fgrep "${STORE_NAMED_GRAPH}" \
   | tr -s '\t' '\n' | wc -l | fgrep -q 1

    


