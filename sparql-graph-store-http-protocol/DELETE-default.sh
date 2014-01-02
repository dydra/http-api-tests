#! /bin/bash
set -o errexit


# tests that default graph deletion leaves the named graph intact

$CURL -w "%{http_code}\n" -f -s -S -X DELETE\
     ${STORE_URL}/${STORE_ACCOUNT}/${STORE_REPOSITORY}?auth_token=${STORE_TOKEN}\&graph=default \
   | egrep -q "$STATUS_DELETE_SUCCESS"

$CURL -f -s -S -X GET\
     -H "Accept: application/n-quads" \
     ${STORE_URL}/${STORE_ACCOUNT}/${STORE_REPOSITORY}?auth_token=${STORE_TOKEN} \
   | tr -s '\n' '\t' \
   | fgrep -v '"default object"' | fgrep -q '"named object"' 


initialize_repository | egrep -q "$STATUS_PUT_SUCCESS"
