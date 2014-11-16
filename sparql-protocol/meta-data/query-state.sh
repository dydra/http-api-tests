#! /bin/bash

# exercise the query state functions

curl -f -s -S -X POST \
     -H "Content-Type: application/sparql-query" \
     -H "Accept: application/sparql-results+json" \
     --data-binary @- \
     ${STORE_URL}/${STORE_ACCOUNT}/${STORE_REPOSITORY}?auth_token=${STORE_TOKEN} <<EOF \
 | jq '.results.bindings[] | .[].value' | fgrep -q "\"${STORE_ACCOUNT}\""

PREFIX dydra: <http://dydra.com/> 
SELECT ( dydra#account-name() as ?result )
WHERE {}
EOF


curl -f -s -S -X POST \
     -H "Content-Type: application/sparql-query" \
     -H "Accept: application/sparql-results+json" \
     --data-binary @- \
     ${STORE_URL}/${STORE_ACCOUNT}/${STORE_REPOSITORY}?auth_token=${STORE_TOKEN} <<EOF \
 | jq '.results.bindings[] | .[].value' | fgrep -q "\"${STORE_ACCOUNT}\""

PREFIX dydra: <http://dydra.com/> 
SELECT ( dydra#agent-location() as ?result )
WHERE {}
EOF

curl -f -s -S -X POST \
     -H "Content-Type: application/sparql-query" \
     -H "Accept: application/sparql-results+json" \
     --data-binary @- \
     ${STORE_URL}/${STORE_ACCOUNT}/${STORE_REPOSITORY}?auth_token=${STORE_TOKEN} <<EOF \
 | jq '.results.bindings[] | .[].value' | fgrep -q "\"${STORE_ACCOUNT}\""

PREFIX dydra: <http://dydra.com/> 
SELECT ( dydra#repository-name() as ?result )
WHERE {}
EOF

curl -f -s -S -X POST \
     -H "Content-Type: application/sparql-query" \
     -H "Accept: application/sparql-results+json" \
     --data-binary @- \
     ${STORE_URL}/${STORE_ACCOUNT}/${STORE_REPOSITORY}?auth_token=${STORE_TOKEN} <<EOF \
 | jq '.results.bindings[] | .[].value' | fgrep -q "\"${STORE_ACCOUNT}\""

PREFIX dydra: <http://dydra.com/> 
SELECT ( dydra#repository-uri() as ?result )
WHERE {}
EOF

curl -f -s -S -X POST \
     -H "Content-Type: application/sparql-query" \
     -H "Accept: application/sparql-results+json" \
     --data-binary @- \
     ${STORE_URL}/${STORE_ACCOUNT}/${STORE_REPOSITORY}?auth_token=${STORE_TOKEN}&user_tag=test <<EOF \
 | jq '.results.bindings[] | .[].value' | fgrep -q "\"test\""

PREFIX dydra: <http://dydra.com/> 
SELECT ( dydra#user-tag() as ?result )
WHERE {}
EOF





