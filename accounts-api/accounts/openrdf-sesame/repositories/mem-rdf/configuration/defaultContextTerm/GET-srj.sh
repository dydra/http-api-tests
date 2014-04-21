#! /bin/bash

# verify presence of standard first and last prefix namespace bindings

curl -f -s -S -X GET\
     -H "Accept: application/sparql-results+json" \
     $STORE_URL/accounts/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}/configuration/defaultContextTerm?auth_token=${STORE_TOKEN} \
  | json_reformat -m \
  | fgrep '"value":"urn:dydra:defaultContextTerm"' \
  | fgrep -q "/accounts/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}"
