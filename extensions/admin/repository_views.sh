#! /bin/sh

# test retrieving a repository's view list
# see alsi extensions/sparql-protocol/views/materialized.sh

# GET <repository>/views yields the view list
$CURL -s -L -X GET -H "Accept: application/sparql-results+json" \
  -u ":${AUTH_TOKEN}" \
  "https://${STORE_HOST}/system/accounts/test/repositories/test/views" \
 | fgrep -q "first-10"


# GET <repository>/view/<view> yields the single view 
$CURL -s -L -X GET -H "Accept: application/sparql-results+json" \
  -u ":${AUTH_TOKEN}" \
  "https://${STORE_HOST}/system/accounts/test/repositories/test/views/first-10" \
 | fgrep -q "first-10"
