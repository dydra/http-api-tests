#! /bin/bash

# validate gYear casting parsing and equality

curl_sparql_request "Accept: application/sparql-results+json" <<EOF \
 | jq '.results.bindings[] | .[].value' | fgrep -q 'true'

prefix xsd: <http://www.w3.org/2001/XMLSchema-datatypes>

select ((( xsd:gYear('1976-05:00') = '1976-05:00'^^xsd:gYear) &&
         ( xsd:gYear('1976Z') = '1976Z'^^xsd:gYear) &&
         ( xsd:gYear('1976Z') != '1976'^^xsd:gYear) &&
         ( xsd:gYear('1976+12:00') = '1976+12:00'^^xsd:gYear) &&

         ( xsd:gYear('2005-12:00') != '2005+12:00'^^xsd:gYear) &&
         ( xsd:gYear('1976-10:00') != '1976Z'^^xsd:gYear) &&

         # no order, but also not incommensurable
         (! ( xsd:gYear('1975') <   xsd:gYear('1976') )) &&
         (! ( xsd:gYear('1976') <   xsd:gYear('1975') )) &&
         (! ( xsd:gYear('1976') <   xsd:gYear('1975') )) &&
         (! ( xsd:gYear('1976') <=   xsd:gYear('1975') )))
       as ?ok)
where {
 }

EOF

