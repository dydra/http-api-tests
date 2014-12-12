#! /bin/bash

# validate gDay casting parsing and equality

${CURL} -f -s -S -X POST \
     -H "Content-Type: application/sparql-query" \
     -H "Accept: application/sparql-results+json" \
     --data-binary @- \
     -u ":${STORE_TOKEN}" \
     ${CURL_URL} <<EOF \
 | jq '.results.bindings[] | .[].value' | fgrep -q 'true'

prefix xsd: <http://www.w3.org/2001/XMLSchema-datatypes>

select ((( xsd:gDay('---12') = '---12'^^xsd:gDay) &&
         ( xsd:gDay('---12Z') = '---12Z'^^xsd:gDay) &&
         ( xsd:gDay('---12Z') != '---12'^^xsd:gDay) &&
         ( xsd:gDay('---12+12:00') = '---12+12:00'^^xsd:gDay) &&

         ( xsd:gDay('---12Z') != '---13Z'^^xsd:gDay) &&
         # no order, but also not incommendurable
         (! ( xsd:gDay('---11') <   xsd:gDay('---12') )) &&
         (! ( xsd:gDay('---12') <   xsd:gDay('---11') )) &&
         (! ( xsd:gDay('---11') <=   xsd:gDay('---12') )) &&
         (! ( xsd:gDay('---12') <=   xsd:gDay('---11') )))
       as ?ok)
where {
 }
EOF


