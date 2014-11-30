#! /bin/bash

# exercise the query state functions

curl -f -s -S -X POST \
     -H "Content-Type: application/sparql-query" \
     -H "Accept: application/sparql-results+json" \
     --data-binary @- \
     ${STORE_URL}/${STORE_ACCOUNT}/${STORE_REPOSITORY}?auth_token=${STORE_TOKEN} <<EOF \
 | jq '.results.bindings[] | .[].value' | fgrep -q 'true'

prefix xsd: <http://www.w3.org/2001/XMLSchema-datatypes>
prefix fn: <http://www.w3.org/2005/xpath-functions#>

select (((year(?yearMonthDuration) = 10) &&
         (month(?yearMonthDuration) = 1) &&
         (fn:years-from-duration(?yearMonthDuration) = 10) &&
         (fn:months-from-duration(?yearMonthDuration) = 1))
        as ?ok)
where {
 bind(xsd:yearMonthDuration('P10Y1M') as ?yearMonthDuration) .
 }
EOF


curl -f -s -S -X POST \
     -H "Content-Type: application/sparql-query" \
     -H "Accept: application/sparql-results+json" \
     --data-binary @- \
     ${STORE_URL}/${STORE_ACCOUNT}/${STORE_REPOSITORY}?auth_token=${STORE_TOKEN} <<EOF \
 | jq '.results.bindings[] | .[].value' | fgrep -q 'true'

prefix xsd: <http://www.w3.org/2001/XMLSchema-datatypes>
prefix fn: <http://www.w3.org/2005/xpath-functions#>

select (((year(?yearMonthDuration) = 10) &&
         (month(?yearMonthDuration) = 1) &&
         (fn:years-from-duration(?yearMonthDuration) = 10) &&
         (fn:months-from-duration(?yearMonthDuration) = 1))
        as ?ok)
where {
 bind(xsd:dateTime('1902-01-31T00:00:00Z') as ?baseDate)
 bind(xsd:yearMonthDuration('P10Y1M') as ?yearMonthDuration) .
 }
EOF

