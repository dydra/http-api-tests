#! /bin/bash

# validate gYear casting parsing and equality

curl -f -s -S -X POST \
     -H "Content-Type: application/sparql-query" \
     -H "Accept: application/sparql-results+json" \
     --data-binary @- \
     ${STORE_URL}/${STORE_ACCOUNT}/${STORE_REPOSITORY}?auth_token=${STORE_TOKEN} <<EOF \
 | jq '.results.bindings[] | .[].value' | fgrep -q 'true'

prefix xsd: <http://www.w3.org/2001/XMLSchema-datatypes>

select ((( xsd:gYear('1976-05:00') = '1976-05:00'^^xsd:gYear) &&
         ( xsd:gYear('1976Z') = '1976Z'^^xsd:gYear) &&
         ( xsd:gYear('1976Z') != '1976'^^xsd:gYear) &&
         ( xsd:gYear('1976+12:00') = '1976+12:00'^^xsd:gYear) &&

         ( xsd:gYear('2005-12:00') != '2005+12:00'^^xsd:gYear) &&
         ( xsd:gYear('1976-10:00') != '1976Z'^^xsd:gYear) &&

         # no order, but also not incommendurable
         (! ( xsd:gYear('1975') <   xsd:gYear('1976') )) &&
         (! ( xsd:gYear('1976') <   xsd:gYear('1975') )) &&
         (! ( xsd:gYear('1975') <=   xsd:gYear('1976') )) &&
         (! ( xsd:gYear('1976') <=   xsd:gYear('1975') )))
       as ?ok)
where {
 }

EOF

