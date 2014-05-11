#! /bin/bash

# test that a registered user has access only if explicitly provided

${CURL} -f -s -S -X GET\
     -H "Accept: application/sparql-results+json" \
     ${STORE_URL}/accounts/${STORE_ACCOUNT}/profile?auth_token=${STORE_TOKEN} \
  | json_reformat -m \
  | fgrep '"http://www.w3.org/ns/auth/acl#owner"' \
  | fgrep -q "${STORE_ACCOUNT}"


