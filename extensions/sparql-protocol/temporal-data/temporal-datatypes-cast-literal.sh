#! /bin/bash

# exercise the temporal constructors and literal parsing
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

curl_sparql_request "Accept: application/sparql-results+json" <<EOF \
 | jq '.results.bindings[] | .[].value' | fgrep -q 'true'

prefix xsd: <http://www.w3.org/2001/XMLSchema-datatypes>

select (((xsd:date('2014-01-01') = '2014-01-01'^^xsd:date)  &&
         (xsd:dateTime('2014-01-01T23:59:58Z') = '2014-01-01T23:59:58Z'^^xsd:dateTime) &&
         (xsd:dayTimeDuration('P1DT2H3M4S') = 'P1DT2H3M4S'^^xsd:dayTimeDuration) &&
         (xsd:gDay('---12') = '---12'^^xsd:gDay) &&
         (xsd:gMonth('--11') = '--11'^^xsd:gMonth) &&
         (xsd:gMonthDay('--11-12') = '--11-12'^^xsd:gMonthDay) &&
         (xsd:gYear('1955') = '1955'^^xsd:gYear) &&
         (xsd:gYearMonth('1955-11') = '1955-11'^^xsd:gYearMonth) &&
         (xsd:time('23:59:58') = '23:59:58'^^xsd:time) &&
         (xsd:yearMonthDuration('P10Y1M') = 'P10Y1M'^^xsd:yearMonthDuration)
         ) as ?ok)
where { }
EOF






