#! /bin/bash


${CURL} -f -s -S -X GET\
     -H "Accept: application/sparql-results+xml" \
     $STORE_URL/accounts/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}/authorization?auth_token=${STORE_TOKEN} \
  | xmllint --c14n11 - | tr -s '\t\n\r\f' ' ' | sed 's/ +/ /g' \
  | fgrep 'http://www.w3.org/ns/auth/acl#mode' \
  | fgrep 'http://www.w3.org/ns/auth/acl#agent' \
  | fgrep 'http://www.w3.org/ns/auth/acl#accessTo' \
  | fgrep -q "/accounts/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}"
