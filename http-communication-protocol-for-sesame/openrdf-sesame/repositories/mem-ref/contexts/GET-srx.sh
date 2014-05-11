#! /bin/bash

# verify the presence of a single named graph in the response

curl -f -s -S -X GET \
     -H "Accept: application/sparql-results+xml" \
     ${STORE_URL}/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}/contexts?auth_token=${STORE_TOKEN} \
   | xmllint  --c14n11 - \
   | tr -s '\t\n\r\f' ' ' | sed 's/ +/ /g' \
   | fgrep "<binding name=\"contextID\"> <uri>${STORE_NAMED_GRAPH}</uri>" \
   | tr -s '=' '\n' | fgrep -c 'contextID' | fgrep -q '2'

