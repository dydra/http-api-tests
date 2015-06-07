#! /bin/bash

# exercise the values extension for a stored query
# nb. the query "values-query-test" must exist in the account

# idealy it should be a post, but the stored queries require a get
# SPARQL_URL="${STORE_URL}/${STORE_ACCOUNT}/${STORE_REPOSITORY}/values-query-test.srj" \
# curl_sparql_request "--data-urlencode" "values@-" <<EOF \
#  | jq '.results.bindings[] | .[].value' | fgrep -q "BSS84"
# $name { 'BUK7Y98-80E' 'PH3330L' 'BSS84' }
# EOF

curl -u "${STORE_TOKEN}:" "${STORE_URL}/${STORE_ACCOUNT}/${STORE_REPOSITORY}-write/values-query-test.srj?values=%24name%20%7B%20%27BUK7Y98-80E%27%20%27PH3330L%27%20%27BSS84%27%20%7D" \
 | jq '.results.bindings[] | .[].value' | fgrep -q "BSS84"
