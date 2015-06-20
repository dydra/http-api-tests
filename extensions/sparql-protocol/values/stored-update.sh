#! /bin/bash

# exercise the values extension for a stored query
# nb. the query "values-update-test" must exist in the account

$CURL  -f -s -u "${STORE_TOKEN}:" "${STORE_URL}/${STORE_ACCOUNT}/${STORE_REPOSITORY}-write/values-update-test.srj?values=(%24name%20%24code)%20%7B%20(%22BUK7Y98-80E%22%20%22one%22)%20(%22PH3330L%22%20%22two%22)%20(%22BSS84%22%20%22three%22)%20%7D" \
 | jq '.boolean' | fgrep -q 'true'


curl_sparql_request "--data-binary" "@-" \
   --repository "${STORE_REPOSITORY}-write" <<EOF \
 | jq '.results.bindings[] | .[].value' | fgrep -q "BSS84"
select ?name
where { ?name ?p ?o }
EOF
