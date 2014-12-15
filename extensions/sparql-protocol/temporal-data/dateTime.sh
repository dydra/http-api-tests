#! /bin/bash

# exercise the query state functions

curl_sparql_request "Accept: application/sparql-results+json"  <<EOF \
 | jq '.results.bindings[] | .[].value' | fgrep -q 'true'

prefix xsd: <http://www.w3.org/2001/XMLSchema-datatypes>
prefix fn: <http://www.w3.org/2005/xpath-functions#>

select (((year(?dateTime) = 2014) &&
         (month(?dateTime) = 12) &&
         (day(?dateTime) = 31) &&
         (hours(?dateTime) = 23) &&
         (minutes(?dateTime) = 59) &&
         (seconds(?dateTime) = 58) &&
         (TZ(?dateTime) = 'Z') &&
         (fn:year-from-dateTime(?dateTime) = 2014) &&
         (fn:month-from-dateTime(?dateTime) = 12) &&
         (fn:day-from-dateTime(?dateTime) = 31) &&
         (fn:hours-from-dateTime(?dateTime) = 23) &&
         (fn:minutes-from-dateTime(?dateTime) = 59) &&
         (fn:seconds-from-dateTime(?dateTime) = 58) &&
         
         (datatype(TIMEZONE(?dateTime)) = xsd:dayTimeDuration) &&
         (datatype(fn:timezone-from-dateTime(?dateTime)) = xsd:dayTimeDuration))
        as ?ok)
where {
 bind(xsd:dateTime('2014-12-31T23:59:58Z') as ?dateTime) .
 }
EOF
