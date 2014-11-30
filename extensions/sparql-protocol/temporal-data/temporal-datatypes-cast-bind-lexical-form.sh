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
 | jq '.results.bindings[] #| .[].value' # | fgrep -v null #| wc -l | fgrep -q '14'

prefix xsd: <http://www.w3.org/2001/XMLSchema-datatypes>

select (((xsd:string(?date) = '2014-01-01') &&
         (xsd:string(?dateTime) = '2014-01-01T23:59:58Z') &&
         (xsd:string(?dayTimeDuration) = 'P1D2H3M4S') &&
         (xsd:string(?gDay) = '---12') &&
         (xsd:string(?gMonth) = '--11') = &&
         (xsd:string(?gMonthDay) = '--11-12') &&
         (xsd:string(?gYear) = '1955') &&
         (xsd:string(?gYearMonth) = '195511') &&
         (xsd:string(?time) = '23:59:58') &&
         (xsd:string(?yearMonthDuration) = 'P10Y1M')
         ) as ?ok)
where {
 bind(xsd:dateTime('2014-01-01T23:59:58Z') as ?dateTime) .
 bind(xsd:date('2014-01-01') as ?date) .
 bind(xsd:dayTimeDuration('P1D2H3M4S') as ?dayTimeDuration) .
 bind(xsd:gDay('---12') as ?gDay) .
 bind(xsd:gMonth('--11') as ?gMonth) .
 bind(xsd:gMonthDay('--11-12') as ?gMonthDay) .
 bind(xsd:gYear('1955') as ?gYear) .
 bind(xsd:gYearMonth('195511') as ?gYearMonth) .
 bind(xsd:time('23:59:58') as ?time) .
 bind(xsd:yearMonthDuration('P10Y1M') as ?yearMonthDuration) .
 }
EOF






