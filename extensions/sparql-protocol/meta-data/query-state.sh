#! /bin/bash

# exercise the query state functions

${CURL} -f -s -S -X POST \
     -H "Content-Type: application/sparql-query" \
     -H "Accept: application/sparql-results+json" \
     --data-binary @- \
     -u "${STORE_TOKEN}:" \
     "${SPARQL_URL}" <<EOF \
 | jq '.results.bindings[] | .[].value' | fgrep -q "\"${STORE_ACCOUNT}\""

PREFIX dydra: <http://dydra.com#> 
SELECT ( dydra:account-name() as ?result )
WHERE {}
EOF


${CURL} -f -s -S -X POST \
     -H "Content-Type: application/sparql-query" \
     -H "Accept: application/sparql-results+json" \
     --data-binary @- \
     -u "${STORE_TOKEN}:" \
     "${SPARQL_URL}" <<EOF \
 | jq '.results.bindings[] | .[].value' | egrep -q '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+'

PREFIX dydra: <http://dydra.com#> 
SELECT ( dydra:agent-location() as ?result )
WHERE {}
EOF

${CURL} -f -s -S -X POST \
     -H "Content-Type: application/sparql-query" \
     -H "Accept: application/sparql-results+json" \
     --data-binary @- \
     -u "${STORE_TOKEN}:" \
     "${SPARQL_URL}" <<EOF \
 | jq '.results.bindings[] | .[].value' | fgrep -q "\"${STORE_REPOSITORY}\""

PREFIX dydra: <http://dydra.com#> 
SELECT ( dydra:repository-name() as ?result )
WHERE {}
EOF

${CURL} -f -s -S -X POST \
     -H "Content-Type: application/sparql-query" \
     -H "Accept: application/sparql-results+json" \
     --data-binary @- \
     -u "${STORE_TOKEN}:" \
     "${SPARQL_URL}" <<EOF \
 | jq '.results.bindings[] | .[].value' | fgrep -q "${STORE_ACCOUNT}/${STORE_REPOSITORY}"

PREFIX dydra: <http://dydra.com#> 
SELECT ( dydra:repository-uri() as ?result )
WHERE {}
EOF

${CURL} -f -s -S -X POST \
     -H "Content-Type: application/sparql-query" \
     -H "Accept: application/sparql-results+json" \
     --data-binary @- \
     -u "${STORE_TOKEN}:" \
     "${SPARQL_URL}"'?user_id=test' <<EOF \
 | jq '.results.bindings[] | .[].value' | fgrep -q "\"test\""

PREFIX dydra: <http://dydra.com#> 
SELECT ( dydra:user-tag() as ?result )
WHERE {}
EOF





