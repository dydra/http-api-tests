#! /bin/bash

# exercise yearMonthDuration accessors

curl_sparql_request "Accept: application/sparql-results+json" <<EOF \
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

# excercise the yearMonthDuration comparison operators

curl_sparql_request "Accept: application/sparql-results+json" <<EOF \
 | jq '.results.bindings[] | .[].value' | fgrep -q 'true'

prefix xsd: <http://www.w3.org/2001/XMLSchema-datatypes>
prefix fn: <http://www.w3.org/2005/xpath-functions#>

select (((xsd:yearMonthDuration('P1Y') < xsd:yearMonthDuration('P1Y1M')) &&
         (xsd:yearMonthDuration('P1Y') < xsd:yearMonthDuration('P13M')) &&
         (!(xsd:yearMonthDuration('P1Y') < xsd:yearMonthDuration('P1M'))) &&
         (!(xsd:yearMonthDuration('P1M') < xsd:yearMonthDuration('P1M'))) &&
         (xsd:yearMonthDuration('P1Y') > xsd:yearMonthDuration('P1M')) &&
         (xsd:yearMonthDuration('P13M') > xsd:yearMonthDuration('P1Y')) &&
         (!(xsd:yearMonthDuration('P1M') > xsd:yearMonthDuration('P1Y'))) &&
         (!(xsd:yearMonthDuration('P1M') > xsd:yearMonthDuration('P1M'))))
        as ?ok)
where {
 }
EOF

