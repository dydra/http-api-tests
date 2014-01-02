#! /bin/bash


# tests that default graph deletion leaves the named graph intact

curl -w "%{http_code}\n" -f -s -S -X DELETE\
     ${STORE_URL}/${STORE_ACCOUNT}/${STORE_REPOSITORY}?auth_token=${STORE_TOKEN}\&graph=default \
   | fgrep -q "${STATUS_NO_CONTENT}"

curl -f -s -S -X GET\
     -H "Accept: application/n-quads" \
     ${STORE_URL}/${STORE_ACCOUNT}/${STORE_REPOSITORY}?auth_token=${STORE_TOKEN} \
   | tr -s '\n' '\t' \
   | fgrep -v '"default object"' | fgrep -q '"named object"' 


initialize_repository | egrep -q "${STATUS_UPDATED}"
