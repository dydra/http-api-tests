#! /bin/bash

# exercise the query state functions

curl_sparql_request <<EOF \
 | jq '.results.bindings[] | .[].value' | fgrep -q 'ayTimeDuration'

prefix xsd: <http://www.w3.org/2001/XMLSchema-datatypes>
prefix fn: <http://www.w3.org/2005/xpath-functions#>

select (datatype(TIMEZONE(?time)) as ?type) 
where {
 bind(xsd:time('23:59:58Z') as ?time) .
 }
EOF
