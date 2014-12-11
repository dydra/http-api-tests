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

select ( (((?baseDate + xsd:dayTimeDuration('P0D')) = "1902-01-31T00:00:00Z"^^xsd:dateTime) &&
          ((?baseDate + xsd:dayTimeDuration('P1D')) = "1902-02-01T00:00:00Z"^^xsd:dateTime) &&
          ((?baseDate + xsd:dayTimeDuration('-P1D')) = "1902-01-30T00:00:00Z"^^xsd:dateTime) &&
          ((?baseDate - xsd:dayTimeDuration('P1D')) = "1902-01-30T00:00:00Z"^^xsd:dateTime) &&
          ((?baseDate + xsd:dayTimeDuration('PT0H')) = "1902-01-31T00:00:00Z"^^xsd:dateTime) &&
          ((?baseDate + xsd:dayTimeDuration('PT1H')) = "1902-01-31T01:00:00Z"^^xsd:dateTime) &&
          ((?baseDate + xsd:dayTimeDuration('PT24H')) = "1902-02-01T00:00:00Z"^^xsd:dateTime) &&
          ((?baseDate + xsd:dayTimeDuration('-PT1H')) = "1902-01-30T23:00:00Z"^^xsd:dateTime) &&
          ((?baseDate - xsd:dayTimeDuration('PT1H')) = "1902-01-30T23:00:00Z"^^xsd:dateTime) &&
          ((?baseDate + xsd:dayTimeDuration('PT0M')) = "1902-01-31T00:00:00Z"^^xsd:dateTime) &&
          ((?baseDate + xsd:dayTimeDuration('PT1M')) = "1902-01-31T00:01:00Z"^^xsd:dateTime) &&
          ((?baseDate + xsd:dayTimeDuration('PT120M')) = "1902-01-31T02:00:00Z"^^xsd:dateTime) &&
          ((?baseDate + xsd:dayTimeDuration('-PT2M')) = "1902-01-30T23:58:00Z"^^xsd:dateTime) &&
          ((?baseDate - xsd:dayTimeDuration('PT2M')) = "1902-01-30T23:58:00Z"^^xsd:dateTime) &&
          ((?baseDate + xsd:dayTimeDuration('PT0S')) = "1902-01-31T00:00:00Z"^^xsd:dateTime) &&
          ((?baseDate + xsd:dayTimeDuration('PT1S')) = "1902-01-31T00:00:01Z"^^xsd:dateTime) &&
          ((?baseDate + xsd:dayTimeDuration('PT60S')) = "1902-01-31T00:01:00Z"^^xsd:dateTime) &&
          ((?baseDate + xsd:dayTimeDuration('PT3600S')) = "1902-01-31T01:00:00Z"^^xsd:dateTime) &&
          ((?baseDate + xsd:dayTimeDuration('-PT1S')) = "1902-01-30T23:59:59Z"^^xsd:dateTime) &&
          ((?baseDate - xsd:dayTimeDuration('PT1S')) = "1902-01-30T23:59:59Z"^^xsd:dateTime) &&
          ((?baseDate + xsd:dayTimeDuration('PT0.001S')) = "1902-01-31T00:00:00.001Z"^^xsd:dateTime) &&
          ((?baseDate + xsd:dayTimeDuration('P4DT3H2M1S')) = "1902-02-04T03:02:01Z"^^xsd:dateTime))
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

select # ( ?baseDate as ?bd )
       # (   (?baseDate + xsd:dayTimeDuration('P0D')) as ?ed )
       (  (((?baseDate + xsd:dayTimeDuration('P0D')) = "1902-04-30T00:00:00Z"^^xsd:dateTime) &&
          ((?baseDate + xsd:dayTimeDuration('P1D')) = "1902-05-01T00:00:00Z"^^xsd:dateTime) &&
          ((?baseDate + xsd:dayTimeDuration('-P1D')) = "1902-04-29T00:00:00Z"^^xsd:dateTime) &&
          ((?baseDate - xsd:dayTimeDuration('P1D')) = "1902-04-29T00:00:00Z"^^xsd:dateTime) &&
          ((?baseDate + xsd:dayTimeDuration('PT0H')) = "1902-04-30T00:00:00Z"^^xsd:dateTime) &&
          ((?baseDate + xsd:dayTimeDuration('PT1H')) = "1902-04-30T01:00:00Z"^^xsd:dateTime) &&
          ((?baseDate + xsd:dayTimeDuration('PT24H')) = "1902-05-01T00:00:00Z"^^xsd:dateTime) &&
          ((?baseDate + xsd:dayTimeDuration('-PT1H')) = "1902-04-29T23:00:00Z"^^xsd:dateTime) &&
          ((?baseDate - xsd:dayTimeDuration('PT1H')) = "1902-04-29T23:00:00Z"^^xsd:dateTime) &&
          ((?baseDate + xsd:dayTimeDuration('PT0M')) = "1902-04-30T00:00:00Z"^^xsd:dateTime) &&
          ((?baseDate + xsd:dayTimeDuration('PT1M')) = "1902-04-30T00:01:00Z"^^xsd:dateTime) &&
          ((?baseDate + xsd:dayTimeDuration('PT120M')) = "1902-04-30T02:00:00Z"^^xsd:dateTime) &&
          ((?baseDate + xsd:dayTimeDuration('-PT2M')) = "1902-04-29T23:58:00Z"^^xsd:dateTime) &&
          ((?baseDate - xsd:dayTimeDuration('PT2M')) = "1902-04-29T23:58:00Z"^^xsd:dateTime) &&
          ((?baseDate + xsd:dayTimeDuration('PT0S')) = "1902-04-30T00:00:00Z"^^xsd:dateTime) &&
          ((?baseDate + xsd:dayTimeDuration('PT1S')) = "1902-04-30T00:00:01Z"^^xsd:dateTime) &&
          ((?baseDate + xsd:dayTimeDuration('PT60S')) = "1902-04-30T00:01:00Z"^^xsd:dateTime) &&
          ((?baseDate + xsd:dayTimeDuration('PT3600S')) = "1902-04-30T01:00:00Z"^^xsd:dateTime) &&
          ((?baseDate + xsd:dayTimeDuration('-PT1S')) = "1902-04-29T23:59:59Z"^^xsd:dateTime) &&
          ((?baseDate - xsd:dayTimeDuration('PT1S')) = "1902-04-29T23:59:59Z"^^xsd:dateTime) &&
          ((?baseDate + xsd:dayTimeDuration('PT0.001S')) = "1902-04-30T00:00:00.001Z"^^xsd:dateTime) &&
          ((?baseDate + xsd:dayTimeDuration('P4DT3H2M1S')) = "1902-05-04T03:02:01Z"^^xsd:dateTime))
        as ?ok)
where {
 bind(xsd:dateTime('1902-04-30T00:00:00Z') as ?baseDate)
 }
EOF

