#! /bin/bash

# test as sparql-results+xml, that the the account configuration includes the user's access

curl -f -s -S -X GET\
     -H "Accept: application/sparql-results+xml" \
     $STORE_URL/accounts/${STORE_ACCOUNT}/profile?auth_token=${STORE_TOKEN} \
  | xmllint --c14n11 - | tr -s '\t\n\r\f' ' ' | sed 's/ +/ /g' \
  | fgrep 'http://purl.org/dc/elements/1.1/title' \
  | fgrep 'http://xmlns.com/foaf/0.1/mbox' \
  | fgrep 'http://purl.org/dc/elements/1.1/description' \
  | fgrep 'http://www.w3.org/ns/auth/acl#owner' \
  | fgrep -q "<literal>${STORE_ACCOUNT}</literal>"
