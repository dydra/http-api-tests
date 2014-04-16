#! /bin/bash

# test as json, that the the account configuration includes the user's access

${CURL} -f -s -S -X GET\
     -H "Accept: application/sparql-results+json" \
     ${STORE_URL}/accounts/${STORE_ACCOUNT}/profile?auth_token=${STORE_TOKEN} \
  | json_reformat -m \
  | fgrep '"http://purl.org/dc/elements/1.1/title"' \
  | fgrep '"http://xmlns.com/foaf/0.1/mbox"' \
  | fgrep '"http://purl.org/dc/elements/1.1/description"' \
  | fgrep '"http://www.w3.org/ns/auth/acl#owner"' \
  | fgrep -q "${STORE_ACCOUNT}"


