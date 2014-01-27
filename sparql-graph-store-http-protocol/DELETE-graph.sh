#! /bin/bash
set -o errexit

# test that delete with a graph removes just that content and leaves the default graph intact


$CURL -w "%{http_code}\n" -f -s -X DELETE\
     -H "Accept: application/n-quads" \
     $STORE_URL/${STORE_ACCOUNT}/${STORE_REPOSITORY}?auth_token=${STORE_TOKEN}\&graph=${STORE_NAMED_GRAPH} \
 | egrep -q "$STATUS_DELETE_SUCCESS"


$CURL -f -s -S -X GET\
     -H "Accept: application/n-quads" \
     $STORE_URL/${STORE_ACCOUNT}/${STORE_REPOSITORY}?auth_token=${STORE_TOKEN} \
   | tr -s '\n' '\t' \
   | fgrep '"default object"' | fgrep -q -v '"named object"' 

initialize_repository | egrep -q "$STATUS_PUT_SUCCESS"
