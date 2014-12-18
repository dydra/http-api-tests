#! /bin/bash

# test cumulative duration accessors

curl_sparql_request "Accept: application/sparql-results+json" <<EOF \
 | jq '.results.bindings[] | .[].value' | fgrep -q 'true'

prefix xsd: <http://www.w3.org/2001/XMLSchema-datatypes>
prefix fn: <http://www.w3.org/2005/xpath-functions#>

select (((fn:duration-in-seconds(xsd:yearMonthDuration('P1Y1M')) = 0) &&
         (fn:duration-in-minutes(xsd:yearMonthDuration('P1Y1M')) = 0) &&
         (fn:duration-in-hours(xsd:yearMonthDuration('P1Y1M')) = 0) &&
         (fn:duration-in-days(xsd:yearMonthDuration('P1Y1M')) = 0) &&
         (fn:duration-in-months(xsd:yearMonthDuration('P1Y1M')) = 13) &&
         (fn:duration-in-years(xsd:yearMonthDuration('P1Y1M')) = (13 / 12)) &&

         (fn:duration-in-seconds(xsd:dayTimeDuration('P1D')) = 86400) &&
         (fn:duration-in-minutes(xsd:dayTimeDuration('P1D')) = 1440) &&
         (fn:duration-in-hours(xsd:dayTimeDuration('P1D')) = 24) &&
         (fn:duration-in-days(xsd:dayTimeDuration('P1D')) = 1) &&
         (fn:duration-in-months(xsd:dayTimeDuration('P1D')) = 0) &&
         (fn:duration-in-years(xsd:dayTimeDuration('P1D')) = 0)
         )
        as ?ok)
where {
 }
EOF
