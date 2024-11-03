#! /bin/bash

# test queries against intended authorizations
#
# import the test authorization list.
# check that the direct and indirect links are found

set -e
queryURL="${STORE_URL}/system/accounts/${STORE_ACCOUNT}/authorization"


${CURL} -s -w "%{http_code}\n" -f -s -S -X PATCH --user ":${STORE_TOKEN}" \
  --data-binary @authorization.trig \
  -H "Content-Type: application/trig" \
  "${STORE_URL}/${STORE_ACCOUNT}/system/service" \
  | test_patch_success


${CURL} -s -H "Accept: application/sparql-results+json"  --user ":${STORE_TOKEN}" \
  "${queryURL}?role=http://dydra.com/account/other&target=http://dydra.com/jhacker/request-repository" \
  | fgrep -q Read

${CURL} -s -H "Accept: application/sparql-results+json"  --user ":${STORE_TOKEN}" \
  "${queryURL}?role=http://dydra.com/user/authenticated&target=http://dydra.com/jhacker/request-repository" \
  | fgrep -q Read

## anonymous access to the anonymous repository only
${CURL} -s -H "Accept: application/sparql-results+json"  --user ":${STORE_TOKEN}" \
  "${queryURL}?role=http://xmlns.com/foaf/0.1/Agent&target=http://dydra.com/jhacker/request-repository" \
  | fgrep -q "[ ]"
${CURL} -s -H "Accept: application/sparql-results+json"  --user ":${STORE_TOKEN}" \
  "${queryURL}?role=http://xmlns.com/foaf/0.1/Agent&target=http://dydra.com/jhacker/anonymous-repository" \
  | fgrep -q Read

## access through a view
${CURL} -s -H "Accept: application/sparql-results+json"  --user ":${STORE_TOKEN}" \
  "${queryURL}?role=http://xmlns.com/foaf/0.1/Agent&target=http://dydra.com/jhacker/request-repository/anonview&mode=Execute" \
  | fgrep -q Execute

${CURL} -s -H "Accept: application/sparql-results+json"  --user ":${STORE_TOKEN}" \
  "${queryURL}?role=http://dydra.com/jhacker/request-repository/anonview&target=http://dydra.com/jhacker/request-repository" \
  | fgrep -q Read

## access via a repository
${CURL} -s -H "Accept: application/sparql-results+json"  --user ":${STORE_TOKEN}" \
  "${queryURL}?role=http://dydra.com/other/other&target=http://dydra.com/jhacker/request-repository" \
  | fgrep -q Read

## access via another view
${CURL} -s -H "Accept: application/sparql-results+json"  --user ":${STORE_TOKEN}" \
  "${queryURL}?role=http://dydra.com/jhacker/request-repository/view&target=http://dydra.com/jhacker/request-repository" \
  | fgrep -q Read
