#! /bin/bash


${CURL} -f -s -S -X GET\
     -H "Accept: application/sparql-results+json" \
     $STORE_URL/accounts/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}/authorization?auth_token=${STORE_TOKEN} \
  | json_reformat -m \
  | fgrep '"value":"http://www.w3.org/ns/auth/acl#mode"' \
  | fgrep '"http://www.w3.org/ns/auth/acl#agent"' \
  | fgrep '"http://www.w3.org/ns/auth/acl#accessTo"' \
  | fgrep -q "/accounts/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}"
