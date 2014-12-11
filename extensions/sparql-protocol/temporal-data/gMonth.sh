#! /bin/bash

# validate gMonth casting parsing and equality

${CURL} -f -s -S -X POST \
     -H 'Content-Type: application/sparql-query' \
     -H 'Accept: application/sparql-results+json' \
     --data-binary @- \
     -u ":${STORE_TOKEN}" \
     ${STORE_URL}/${STORE_ACCOUNT}/${STORE_REPOSITORY} <<EOF \
 | jq '.results.bindings[] | .[].value' | fgrep -q 'true'

prefix xsd: <http://www.w3.org/2001/XMLSchema-datatypes>

select ((( xsd:gMonth('--12') = '--12'^^xsd:gMonth) &&
         ( xsd:gMonth('--12Z') = '--12Z'^^xsd:gMonth) &&
         ( xsd:gMonth('--12Z') != '--12'^^xsd:gMonth) &&
         ( xsd:gMonth('--12+12:00') = '--12+12:00'^^xsd:gMonth) &&

         ( xsd:gMonth('--12Z') != '--11Z'^^xsd:gMonth) &&
         ( xsd:gMonth('--12-14:00') != '--12+10:00'^^xsd:gMonth) &&
         ( xsd:gMonth('--12-10:00') != '--12Z'^^xsd:gMonth) &&

         # no order, but also not incommendurable
         (! ( xsd:gMonth('--11') <   xsd:gMonth('--12') )) &&
         (! ( xsd:gMonth('--12') <   xsd:gMonth('--11') )) &&
         (! ( xsd:gMonth('--11') <=   xsd:gMonth('--12') )) &&
         (! ( xsd:gMonth('--12') <=   xsd:gMonth('--11') )))
       as ?ok)
where {
 }
EOF
