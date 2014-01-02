#! /bin/bash
set -o errexit

# test that delete leaves an empty repository

$CURL -w "%{http_code}\n" -f -s -X DELETE\
     -H "Accept: application/n-quads" \
     $STORE_URL/${STORE_ACCOUNT}/${STORE_REPOSITORY}?auth_token=${STORE_TOKEN} \
 | egrep -q "$STATUS_DELETE_SUCCESS"

$CURL -w "%{http_code}\n" -f -s -X GET\
     -H "Accept: application/n-quads" \
     $STORE_URL/${STORE_ACCOUNT}/${STORE_REPOSITORY}?auth_token=${STORE_TOKEN} \
  | fgrep -q "${STATUS_NOT_FOUND}"

initialize_repository | egrep -q "$STATUS_PUT_SUCCESS"
