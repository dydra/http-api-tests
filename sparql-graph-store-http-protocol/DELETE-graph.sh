#! /bin/bash

# test that delete with a graph removes just that content and leaves the default graph intact


curl -w "%{http_code}\n" -f -s -X DELETE\
     -H "Accept: application/n-quads" \
     $STORE_URL/${STORE_ACCOUNT}/${STORE_REPOSITORY}?auth_token=${STORE_TOKEN}\&graph=${STORE_NAMED_GRAPH} \
 | fgrep -q "${STATUS_NO_CONTENT}"


curl -f -s -S -X GET\
     -H "Accept: application/n-quads" \
     $STORE_URL/${STORE_ACCOUNT}/${STORE_REPOSITORY}?auth_token=${STORE_TOKEN} \
   | tr -s '\n' '\t' \
   | fgrep '"default object"' | fgrep -q -v '"named object"' 
