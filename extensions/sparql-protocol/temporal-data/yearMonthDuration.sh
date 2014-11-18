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

select (((year(?yearMonthDuration) = 10) &&
         (fn:years-from-duration(?yearMonthDuration) = 10) &&
         (fn:months-from-duration(?yearMonthDuration) = 1))
        as ?ok)
where {
 bind(xsd:yearMonthDuration('P10Y1M') as ?yearMonthDuration) .
 }
EOF
