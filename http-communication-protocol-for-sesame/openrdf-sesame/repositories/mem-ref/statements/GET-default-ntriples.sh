#! /bin/bash


curl -f -s -S -X GET\
     -H "Accept: application/n-triples" \
     $STORE_URL/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}/statements?context=null\&auth_token=${STORE_TOKEN} \
   | fgrep '"default object"' \
   | fgrep -v '"named object"' \
   | fgrep -v ${STORE_NAMED_GRAPH} \
   | wc -l | fgrep -q 1
