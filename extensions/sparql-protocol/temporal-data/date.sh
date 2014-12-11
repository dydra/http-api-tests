#! /bin/bash

# exercise the query state functions

${CURL} -f -s -S -X POST \
     -H "Content-Type: application/sparql-query" \
     -H "Accept: application/sparql-results+json" \
     --data-binary @- \
     -u ":${STORE_TOKEN}" \
     ${STORE_URL}/${STORE_ACCOUNT}/${STORE_REPOSITORY} <<EOF \
 | jq '.results.bindings[] | .[].value' | fgrep -q 'true'

prefix xsd: <http://www.w3.org/2001/XMLSchema-datatypes>
prefix fn: <http://www.w3.org/2005/xpath-functions#>

select (((year(?date) = 2014) &&
         (month(?date) = 12) &&
         (day(?date) = 31) &&
         (TZ(?date) = 'Z') &&
         (fn:year-from-date(?date) = 2014) &&
         (fn:month-from-date(?date) = 12) &&
         (fn:day-from-date(?date) = 31) &&
         
         (datatype(TIMEZONE(?date)) = xsd:dayTimeDuration) &&
         (datatype(fn:timezone-from-date(?date)) = xsd:dayTimeDuration))
        as ?ok)
where {
 bind(xsd:date('2014-12-31') as ?date) .
 }
EOF
