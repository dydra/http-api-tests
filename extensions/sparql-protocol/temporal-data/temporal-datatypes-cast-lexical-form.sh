#! /bin/bash

# exercise the temporal constructors and test the string conversion
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

${CURL} -f -s -S -X POST \
     -H "Content-Type: application/sparql-query" \
     -H "Accept: application/sparql-results+json" \
     --data-binary @- \
     -u "${STORE_TOKEN}:" \
     "${SPARQL_URL}" <<EOF \
  | jq '.results.bindings[] | .[].value' | fgrep -q 'true'

prefix xsd: <http://www.w3.org/2001/XMLSchema-datatypes>

select (((xsd:string(xsd:date('2014-01-01')) = '2014-01-01') &&
         (xsd:string(xsd:dateTime('2014-01-01T23:59:58Z')) = '2014-01-01T23:59:58Z') &&
         (xsd:string(xsd:dayTimeDuration('P1DT2H3M4S')) = 'P1DT2H3M4S') &&
         (xsd:string(xsd:gDay('---12')) = '---12') &&
         (xsd:string(xsd:gMonth('--11')) = '--11') &&
         (xsd:string(xsd:gMonthDay('--11-12')) = '--11-12') &&
         (xsd:string(xsd:gYear('1955')) = '1955') &&
         (xsd:string(xsd:gYearMonth('1955-11')) = '1955-11') &&
         (xsd:string(xsd:time('23:59:58')) = '23:59:58') &&
         (xsd:string(xsd:yearMonthDuration('P10Y1M')) = 'P10Y1M')
         ) as ?ok)
where { }
EOF






