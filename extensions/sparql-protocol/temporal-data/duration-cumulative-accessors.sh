#! /bin/bash

# test cumulative duration accessors

curl_sparql_request <<EOF \
 | jq '.results.bindings[] | .[].value' | fgrep -q 'true'

prefix xsd: <http://www.w3.org/2001/XMLSchema-datatypes>
prefix fn: <http://www.w3.org/2005/xpath-functions#>

select (((fn:duration-in-seconds(xsd:yearMonthDuration('P1Y1M')) = 0) &&
         (fn:duration-in-minutes(xsd:yearMonthDuration('P1Y1M')) = 0) &&
         (fn:duration-in-hours(xsd:yearMonthDuration('P1Y1M')) = 0) &&
         (fn:duration-in-days(xsd:yearMonthDuration('P1Y1M')) = 0) &&
         (fn:duration-in-months(xsd:yearMonthDuration('P1Y1M')) = 13) &&
         (fn:duration-in-years(xsd:yearMonthDuration('P1Y1M')) = (13 / 12)) &&

         (fn:duration-in-seconds(xsd:dayTimeDuration('P1DT1H')) = 90000) &&
         (fn:duration-in-minutes(xsd:dayTimeDuration('P1DT1H')) = 1500) &&
         (fn:duration-in-hours(xsd:dayTimeDuration('P1DT1H')) = 25) &&
         (fn:duration-in-days(xsd:dayTimeDuration('P1DT1H')) = (25 / 24)) &&
         (fn:duration-in-months(xsd:dayTimeDuration('P1DT1H')) = 0) &&
         (fn:duration-in-years(xsd:dayTimeDuration('P1DT1H')) = 0)
         )
        as ?ok)
where {
 }
EOF

# ({fn}duration-in-seconds "P1DT1H")
