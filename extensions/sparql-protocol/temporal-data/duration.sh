#! /bin/bash

# excercise the duration comparison operators

curl -f -s -S -X POST \
     -H "Content-Type: application/sparql-query" \
     -H "Accept: application/sparql-results+json" \
     --data-binary @- \
     ${STORE_URL}/${STORE_ACCOUNT}/${STORE_REPOSITORY}?auth_token=${STORE_TOKEN} <<EOF \
 | jq '.results.bindings[] | .[].value' | fgrep -q 'true'

prefix xsd: <http://www.w3.org/2001/XMLSchema-datatypes>
prefix fn: <http://www.w3.org/2005/xpath-functions#>

select (((xsd:yearMonthDuration('P0Y') = xsd:dayTimeDuration('P0D')) &&
         (!(xsd:yearMonthDuration('P1Y') = xsd:dayTimeDuration('P365D'))) &&
         (xsd:duration('P2Y0M0DT0H0M0S') = xsd:yearMonthDuration('P24M')) &&
         (xsd:duration('P0Y0M10D') = xsd:dayTimeDuration('PT240H')))
        as ?ok)
where {
 }
EOF

