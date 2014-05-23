#! /bin/bash


curl -f -s -S -X GET\
     -H "Accept: application/sparql-results+xml" \
     ${STORE_URL}/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}/namespaces?auth_token=${STORE_TOKEN}\&auth_token=${STORE_TOKEN} \
   | xmllint  --c14n11 - \
   | tr -s '\t\n\r\f' ' '  \
   | fgrep -i '<variable name="PREFIX"/>' \
   | fgrep -q -i '<variable name="NAMESPACE"/>'
