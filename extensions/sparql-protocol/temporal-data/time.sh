#! /bin/bash

# exercise the query state functions

curl_sparql_request <<EOF \
 | jq '.results.bindings[] | .[].value' | fgrep -q 'true'

prefix xsd: <http://www.w3.org/2001/XMLSchema-datatypes>
prefix fn: <http://www.w3.org/2005/xpath-functions#>

select (((hours(?time) = 23) &&
         (minutes(?time) = 59) &&
         (seconds(?time) = 58) &&
         (TZ(?time) = 'Z') &&
         (fn:hours-from-time(?time) = 23) &&
         (fn:minutes-from-time(?time) = 59) &&
         (fn:seconds-from-time(?time) = 58) &&
         (datatype(TIMEZONE(?time)) = xsd:dayTimeDuration) &&
         (datatype(fn:timezone-from-time(?time)) = xsd:dayTimeDuration)
         )
        as ?ok)
where {
 bind(xsd:time('23:59:58Z') as ?time) .
 }
EOF
