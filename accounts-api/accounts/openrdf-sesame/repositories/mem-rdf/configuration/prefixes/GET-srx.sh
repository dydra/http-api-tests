#! /bin/bash

# environment :
# STORE_ACCOUNT : account name
# STORE_URL : host http url 

${CURL}  -f -s -S -X GET\
     -H "Accept: application/sparql-results+xml" \
     $STORE_URL/accounts/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}/configuration/prefixes?auth_token=${STORE_TOKEN} \
  | xmllint --c14n11 - | tr -s '\t\n\r\f' ' ' | sed 's/ +/ /g' \
  | fgrep 'urn:dydra:prefixes' \
  | fgrep -q "/accounts/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}"
