#! /bin/bash

# validate gMonthDay casting parsing and equality

${CURL} -f -s -S -X POST \
     -H "Content-Type: application/sparql-query" \
     -H "Accept: application/sparql-results+json" \
     --data-binary @- \
     -u "${STORE_TOKEN}:" \
     "${SPARQL_URL}" <<EOF \
 | jq '.results.bindings[] | .[].value' | fgrep -q 'true'

prefix xsd: <http://www.w3.org/2001/XMLSchema-datatypes>

select ((( xsd:gMonthDay('--12-25') = '--12-25'^^xsd:gMonthDay) &&
         ( xsd:gMonthDay('--12-25Z') = '--12-25Z'^^xsd:gMonthDay) &&
         ( xsd:gMonthDay('--12-25Z') != '--12-25'^^xsd:gMonthDay) &&
         ( xsd:gMonthDay('--12-25+12:00') = '--12-25+12:00'^^xsd:gMonthDay) &&

         ( xsd:gMonthDay('--12-25Z') != '--12-24Z'^^xsd:gMonthDay) &&
         ( xsd:gMonthDay('--12-25-14:00') = '--12-26+10:00'^^xsd:gMonthDay) &&
         ( xsd:gMonthDay('--12-25-10:00') != '--12-26Z'^^xsd:gMonthDay) &&

         # no order, but also not incommendurable
         (! ( xsd:gMonthDay('--11-25') <   xsd:gMonthDay('--12-25') )) &&
         (! ( xsd:gMonthDay('--12-25') <   xsd:gMonthDay('--11-25') )) &&
         (! ( xsd:gMonthDay('--11-25') <=   xsd:gMonthDay('--12-25') )) &&
         (! ( xsd:gMonthDay('--12-25') <=   xsd:gMonthDay('--11-25') )))
       as ?ok)
where {
 }
EOF


