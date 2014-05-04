#! /bin/bash

# test as sparql-results+xml, that the the account configuration includes the user's access

${CURL} -f -s -S -X GET\
     -H "Accept: application/sparql-results+xml" \
     $STORE_URL/accounts/${STORE_ACCOUNT}/configuration?auth_token=${STORE_TOKEN} \
  | xmllint --c14n11 - | tr -s '\t\n\r\f' ' ' | sed 's/ +/ /g' \
  | fgrep 'urn:dydra:baseIRI' \
  | fgrep -q "accounts/${STORE_ACCOUNT}"
