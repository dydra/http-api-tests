#! /bin/bash

# exercise the temporal constructors
# see also the xpath specifications' sections on casting:
#  http://www.w3.org/TR/xpath-functions/#casting
#  http://www.w3.org/TR/xpath-functions-30/#casting
#  http://www.w3.org/TR/xpath-functions-30/#dates-times

# xs:date
# xs:gDay
# xs:dateTime
# xs:dayTimeDuration
# xs:duration
# xs:gMonthDay
# xs:gMonth
# xs:time
# xs:gYearMonth
# xs:yearMonthDuration
# xs:gYear

curl -f -s -S -X POST \
     -H "Content-Type: application/sparql-query" \
     -H "Accept: application/sparql-results+json" \
     --data-binary @- \
     ${STORE_URL}/${STORE_ACCOUNT}/${STORE_REPOSITORY}?auth_token=${STORE_TOKEN} <<EOF \
 | jq '.results.bindings[] | .[].value' # | fgrep -q "\"${STORE_ACCOUNT}\""

prefix math: <http://www.w3.org/2005/xpath-functions/math#>

select (NOW() as ?NOW)
       (now() as ?now)
       # date
       (xsd:date(?date) as ?dateDate)
       (xsd:string(?date) as ?dateString)
       (YEAR(?date) as ?dateYear)
       (MONTH(?date) as ?dateMonth)
       (DAY(?date) as ?dateDay)
       (TIMEZONE(?date) as ?dateTimezone)  # supported as for dateTime
       (TZ(?date) as ?dateTZ)
       # dateTime
       (xsd:date(?dateTime) as ?dateTimeDate)
       (xsd:string(?dateTime) as ?dateTimeString)
       (YEAR(?dateTime) as ?dateTimeYear)
       (MONTH(?dateTime) as ?dateTimeMonth)
       (DAY(?dateTime) as ?dateTimeDay)
       (HOURS(?dateTime) as ?dateTimeHours)
       (MINUTES(?dateTime) as ?dateTimeMinutes)
       (SECONDS(?dateTime) as ?dateTimeSeconds)
       (TIMEZONE(?dateTime) as ?dateTimeTimezone)
       (TZ(?dateTime) as ?dateTimeTZ)
where {
 bind(xsd:dateTime('2014-01-01T23:59:58Z') as ?dateTime) .
 bind(xsd:date('2014-01-01') as ?date) .
 bind(xsd:time('23:59:58') as ?time) .
 }
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





