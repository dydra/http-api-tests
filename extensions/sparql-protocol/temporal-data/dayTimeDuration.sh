#! /bin/bash

# exercise the query state functions

curl -f -s -S -X POST \
     -H "Content-Type: application/sparql-query" \
     -H "Accept: application/sparql-results+json" \
     --data-binary @- \
     ${STORE_URL}/${STORE_ACCOUNT}/${STORE_REPOSITORY}?auth_token=${STORE_TOKEN} <<EOF \
 | jq '.results.bindings[] | fgrep -v null | wc -l | fgrep -q '14'

prefix xsd: <http://www.w3.org/2001/XMLSchema-datatypes>
prefix fn: <http://www.w3.org/2005/xpath-functions#>

select (((year(?dayTimeDuration) = 0) &&
         (fn:years-from-duration(?dayTimeDuration) = 0) &&
         (fn:months-from-duration(?dayTimeDuration) = 0))
        as ?ok)
where {
 bind(xsd:dayTimeDuration('P1DT2H3M4S') as ?dayTimeDuration) .
 }
EOF
