#! /bin/bash

# test as json, that the the account authorization for the user's access

${CURL} -f -s -S -X GET\
     -H "Accept: application/sparql-results+json" \
     $STORE_URL/accounts/${STORE_ACCOUNT}/authorization?auth_token=${STORE_TOKEN} \
  | json_reformat -m \
  | fgrep '"value":"http://www.w3.org/ns/auth/acl#agent"'\
  | fgrep '"value":"http://www.w3.org/ns/auth/acl#accessTo"'\
  | fgrep -q "${STORE_ACCOUNT}"


