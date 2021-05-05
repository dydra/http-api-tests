#! /bin/bash

# validate gMonth casting parsing and equality

curl_sparql_request <<EOF \
 | jq '.results.bindings[] | .[].value' | fgrep -q 'true'

prefix xsd: <http://www.w3.org/2001/XMLSchema-datatypes>

select ((( xsd:gMonth('--12') = '--12'^^xsd:gMonth) &&
         ( xsd:gMonth('--12Z') = '--12Z'^^xsd:gMonth) &&
         ( xsd:gMonth('--12Z') != '--12'^^xsd:gMonth) &&
         ( xsd:gMonth('--12+12:00') = '--12+12:00'^^xsd:gMonth) &&

         ( xsd:gMonth('--12Z') != '--11Z'^^xsd:gMonth) &&
         ( xsd:gMonth('--12-14:00') != '--12+10:00'^^xsd:gMonth) &&
         ( xsd:gMonth('--12-10:00') != '--12Z'^^xsd:gMonth) &&

         # yes order
         ( xsd:gMonth('--11') <=   xsd:gMonth('--12') ) &&
         (! ( xsd:gMonth('--12') <=   xsd:gMonth('--11') )))
       as ?ok)
where {
 }
EOF
