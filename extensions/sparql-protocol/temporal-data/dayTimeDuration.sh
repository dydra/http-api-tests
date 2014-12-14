#! /bin/bash

# exercise the query state functions

${CURL} -f -s -S -X POST \
     -H "Content-Type: application/sparql-query" \
     -H "Accept: application/sparql-results+json" \
     --data-binary @- \
     -u "${STORE_TOKEN}:" \
     "${SPARQL_URL}" <<EOF \
 | jq '.results.bindings[] | .[].value' | fgrep -q 'true'

prefix xsd: <http://www.w3.org/2001/XMLSchema-datatypes>
prefix fn: <http://www.w3.org/2005/xpath-functions#>

select (((year(?dayTimeDuration) = 0) &&
         (fn:years-from-duration(?dayTimeDuration) = 0) &&
         (fn:months-from-duration(?dayTimeDuration) = 0) &&
         (fn:days-from-duration(?dayTimeDuration) = 1) &&
         (fn:hours-from-duration(?dayTimeDuration) = 2) &&
         (fn:minutes-from-duration(?dayTimeDuration) = 3) &&
         (fn:seconds-from-duration(?dayTimeDuration) = 4))
        as ?ok)
where {
 bind(xsd:dayTimeDuration('P1DT2H3M4S') as ?dayTimeDuration) .
 }
EOF

# excercise the dayTimeDuration comparison operators

curl -f -s -S -X POST \
     -H "Content-Type: application/sparql-query" \
     -H "Accept: application/sparql-results+json" \
     --data-binary @- \
     -u "${STORE_TOKEN}:" \
     "${SPARQL_URL}" <<EOF \
 | jq '.results.bindings[] | .[].value' | fgrep -q 'true'

prefix xsd: <http://www.w3.org/2001/XMLSchema-datatypes>
prefix fn: <http://www.w3.org/2005/xpath-functions#>

select (((xsd:dayTimeDuration('P1D') < xsd:dayTimeDuration('P1DT12H')) &&
         (xsd:dayTimeDuration('P1D') < xsd:dayTimeDuration('PT36H')) &&
         (!(xsd:dayTimeDuration('P1D') < xsd:dayTimeDuration('PT12H'))) &&
         (!(xsd:dayTimeDuration('P1D') < xsd:dayTimeDuration('P1D'))) &&
         (xsd:dayTimeDuration('P1D') > xsd:dayTimeDuration('PT12H')) &&
         (xsd:dayTimeDuration('PT36H') > xsd:dayTimeDuration('P1D')) &&
         (!(xsd:dayTimeDuration('PT12H') > xsd:dayTimeDuration('P1D'))) &&
         (!(xsd:dayTimeDuration('P1D') > xsd:dayTimeDuration('PT2160M'))))
        as ?ok)
where {
 }
EOF

