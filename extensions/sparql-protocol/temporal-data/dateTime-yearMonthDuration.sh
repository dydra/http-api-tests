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

select ( (((?baseDate + xsd:yearMonthDuration('P0Y')) = "1902-01-31T00:00:00Z"^^xsd:dateTime) &&
          ((?baseDate + xsd:yearMonthDuration('P1M')) = "1902-02-28T00:00:00Z"^^xsd:dateTime) &&
          ((?baseDate + xsd:yearMonthDuration('P2M')) = "1902-03-31T00:00:00Z"^^xsd:dateTime) &&
          ((?baseDate + xsd:yearMonthDuration('P3M')) = "1902-04-30T00:00:00Z"^^xsd:dateTime) &&
          ((?baseDate + xsd:yearMonthDuration('P4M')) = "1902-05-31T00:00:00Z"^^xsd:dateTime) &&
          ((?baseDate + xsd:yearMonthDuration('P5M')) = "1902-06-30T00:00:00Z"^^xsd:dateTime) &&
          ((?baseDate + xsd:yearMonthDuration('P6M')) = "1902-07-31T00:00:00Z"^^xsd:dateTime) &&
          ((?baseDate + xsd:yearMonthDuration('P7M')) = "1902-08-31T00:00:00Z"^^xsd:dateTime) &&
          ((?baseDate + xsd:yearMonthDuration('P8M')) = "1902-09-30T00:00:00Z"^^xsd:dateTime) &&
          ((?baseDate + xsd:yearMonthDuration('P9M')) = "1902-10-31T00:00:00Z"^^xsd:dateTime) &&
          ((?baseDate + xsd:yearMonthDuration('P10M')) = "1902-11-30T00:00:00Z"^^xsd:dateTime) &&
          ((?baseDate + xsd:yearMonthDuration('P11M')) = "1902-12-31T00:00:00Z"^^xsd:dateTime) &&
          ((?baseDate + xsd:yearMonthDuration('P1Y')) = "1903-01-31T00:00:00Z"^^xsd:dateTime) &&
          ((?baseDate + xsd:yearMonthDuration('P2Y')) = "1904-01-31T00:00:00Z"^^xsd:dateTime) &&
          ((?baseDate + xsd:yearMonthDuration('P2Y1M')) = "1904-02-29T00:00:00Z"^^xsd:dateTime))
        as ?ok)
where {
 bind(xsd:dateTime('1902-01-31T00:00:00Z') as ?baseDate)
 }
EOF

curl -f -s -S -X POST \
     -H "Content-Type: application/sparql-query" \
     -H "Accept: application/sparql-results+json" \
     --data-binary @- \
     ${STORE_URL}/${STORE_ACCOUNT}/${STORE_REPOSITORY}?auth_token=${STORE_TOKEN} <<EOF \
 | jq '.results.bindings[] | .[].value' | fgrep -q 'true'

prefix xsd: <http://www.w3.org/2001/XMLSchema-datatypes>

select ( (((?baseDate + xsd:yearMonthDuration('P0Y')) = '1902-04-30T00:00:00Z'^^xsd:dateTime) &&
          ((?baseDate + xsd:yearMonthDuration('P1M')) = '1902-05-31T00:00:00Z'^^xsd:dateTime) &&
          ((?baseDate + xsd:yearMonthDuration('P2M')) = '1902-06-30T00:00:00Z'^^xsd:dateTime) &&
          ((?baseDate + xsd:yearMonthDuration('P3M')) = '1902-07-31T00:00:00Z'^^xsd:dateTime) &&
          ((?baseDate + xsd:yearMonthDuration('P4M')) = '1902-08-31T00:00:00Z'^^xsd:dateTime) &&
          ((?baseDate + xsd:yearMonthDuration('P5M')) = '1902-09-30T00:00:00Z'^^xsd:dateTime) &&
          ((?baseDate + xsd:yearMonthDuration('P6M')) = '1902-10-31T00:00:00Z'^^xsd:dateTime) &&
          ((?baseDate + xsd:yearMonthDuration('P7M')) = '1902-11-30T00:00:00Z'^^xsd:dateTime) &&
          ((?baseDate + xsd:yearMonthDuration('P8M')) = '1902-12-31T00:00:00Z'^^xsd:dateTime) &&
          ((?baseDate + xsd:yearMonthDuration('P9M')) = '1903-01-31T00:00:00Z'^^xsd:dateTime) &&
          ((?baseDate + xsd:yearMonthDuration('P10M')) = '1903-02-28T00:00:00Z'^^xsd:dateTime) &&
          ((?baseDate + xsd:yearMonthDuration('P11M')) = '1903-03-31T00:00:00Z'^^xsd:dateTime) &&
          ((?baseDate + xsd:yearMonthDuration('P1Y')) = '1903-04-30T00:00:00Z'^^xsd:dateTime) &&
          ((?baseDate + xsd:yearMonthDuration('P1Y10M')) = '1904-02-29T00:00:00Z'^^xsd:dateTime) &&
          ((?baseDate + xsd:yearMonthDuration('P1Y11M')) = '1904-03-31T00:00:00Z'^^xsd:dateTime) &&
          ((?baseDate + xsd:yearMonthDuration('P2Y')) = '1904-04-30T00:00:00Z'^^xsd:dateTime) &&
          ((?baseDate + xsd:yearMonthDuration('P2Y1M')) = '1904-02-29T00:00:00Z'^^xsd:dateTime))
        as ?ok)
where {
 bind(xsd:dateTime('1902-04-30T00:00:00Z') as ?baseDate)
 }
EOF

