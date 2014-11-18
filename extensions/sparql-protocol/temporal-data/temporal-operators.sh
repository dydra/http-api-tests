#! /bin/bash

# exercise the query state functions

curl -f -s -S -X POST \
     -H "Content-Type: application/sparql-query" \
     -H "Accept: application/sparql-results+json" \
     --data-binary @- \
     ${STORE_URL}/${STORE_ACCOUNT}/${STORE_REPOSITORY}?auth_token=${STORE_TOKEN} <<EOF \
 | jq '.results.bindings[] | .[].value' | fgrep -q "\"${STORE_ACCOUNT}\""

prefix math: <http://www.w3.org/2005/xpath-functions/math#>

select (math:acos(1) as ?acos)
       (math:asin(1) as ?asin)
       (math:atan(1) as ?atan)
       (math:atan2(1, 0) as ?atan2)
       (math:cos(math:pi()) as ?cos)
       (math:exp(1) as ?exp)
       (math:exp10(1) as ?exp10)
       (math:log(1) as ?log)
       (math:log10(1) as ?log10)
       (math:pi() as ?pi)
       (math:pow(2, 2) as ?pow)
       (math:sin(0) as ?sin)
       (math:sqrt(2) as ?sqrt)
       (math:tan(1) as ?tan)
       (fn:day-from-dateTime(?date) as ?nowDay)
       (fn:hour-from-dateTime(?date) as ?nowHour)
       (fn:minute-from-dateTime(?date) as ?nowMinute)
       (fn:month-from-dateTime(?date) as ?nowMonth)
       (fn:second-from-dateTime(?date) as ?nowSecond)
       (fn:year-from-dateTime(?date) as ?nowYear)
       ((fn:days-from-duration(?date - '2014-01-01T00:00:00Z'^^xsd:dateTime)) as ?dayInYear)
where { bind(xsd:dateTime('2014-01-01T00:00:00Z') as ?date) }
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





