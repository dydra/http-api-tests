#! /bin/bash

# test as sparql-results+xml, that the the account configuration includes the owner

curl -f -s -S -X GET\
     -H "Accept: application/sparql-results+xml" \
     $STORE_URL/accounts/${STORE_ACCOUNT}/profile?auth_token=${STORE_TOKEN} \
  | xmllint --c14n11 - | tr -s '\t\n\r\f' ' ' | sed 's/ +/ /g' \
  | fgrep 'http://www.w3.org/ns/auth/acl#owner' \
  | fgrep -q "http://dydra.com/users/${STORE_ACCOUNT}"
