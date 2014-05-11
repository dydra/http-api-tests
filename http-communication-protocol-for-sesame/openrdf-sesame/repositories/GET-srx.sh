#! /bin/sh

# verify just that the response is intact.
# see GET-srj for validation

curl -f -s -S -X GET\
     -H "Accept: application/sparql-results+xml" \
     $STORE_URL/${STORE_ACCOUNT}/repositories?auth_token=${STORE_TOKEN} \
   | xmllint --c14n11 - | fgrep -q "${STORE_ACCOUNT}"



