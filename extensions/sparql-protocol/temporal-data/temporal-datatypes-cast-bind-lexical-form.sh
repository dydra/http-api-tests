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

curl_sparql_request <<EOF \
 | tee ${ECHO_OUTPUT} | jq '.results.bindings[] | .[].value' | fgrep -q 'true'

prefix xsd: <http://www.w3.org/2001/XMLSchema-datatypes>

select (((xsd:string(?date) = '2014-01-01') &&
         (xsd:string(?dateTime) = '2014-01-01T23:59:58Z') &&
         (xsd:string(?dayTimeDuration) = 'P1DT2H3M4S') &&
         (xsd:string(?gDay) = '---12') &&
         (xsd:string(?gMonth) = '--11') &&
         (xsd:string(?gMonthDay) = '--11-12') &&
         (xsd:string(?gYear) = '1955') &&
         (xsd:string(?gYearMonth) = '1955-11') &&
         (xsd:string(?time) = '23:59:58Z') &&
         (xsd:string(?yearMonthDuration) = 'P10Y1M')
         ) as ?ok)
where {
 # exercise care with the xsd:date('2014-01-01').
 # older versions appended a 'Z' which did not round-trip.
 bind(xsd:dateTime('2014-01-01T23:59:58Z') as ?dateTime) .
 bind(xsd:date('2014-01-01') as ?date) .
 bind(xsd:dayTimeDuration('P1DT2H3M4S') as ?dayTimeDuration) .
 bind(xsd:gDay('---12') as ?gDay) .
 bind(xsd:gMonth('--11') as ?gMonth) .
 bind(xsd:gMonthDay('--11-12') as ?gMonthDay) .
 bind(xsd:gYear('1955') as ?gYear) .
 bind(xsd:gYearMonth('1955-11') as ?gYearMonth) .
 bind(xsd:time('23:59:58Z') as ?time) .
 bind(xsd:yearMonthDuration('P10Y1M') as ?yearMonthDuration) .
 }
EOF

cat > /dev/null <<EOF
(test-sparql "prefix xsd: <http://www.w3.org/2001/XMLSchema-datatypes>

select (((xsd:string(?date) = '2014-01-01') ) as ?ok)
?date
(xsd:string(?date) as ?string)
where {
 # exercise care with the zone as xsd:date('2014-01-01') does not
 # round-trip through the store: it is canoncialzed to zulu
 bind(xsd:date('2014-01-01') as ?date) .
 }"
             :repository-id "james/test")
EOF
