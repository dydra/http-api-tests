#! /bin/bash

# validate gDay casting parsing and equality

curl_sparql_request <<EOF \
 | jq '.results.bindings[] | .[].value' | fgrep -q 'true'

prefix xsd: <http://www.w3.org/2001/XMLSchema-datatypes>

select ((( xsd:gDay('---12') = '---12'^^xsd:gDay) &&
         ( xsd:gDay('---12Z') = '---12Z'^^xsd:gDay) &&
         ( xsd:gDay('---12Z') != '---12'^^xsd:gDay) &&
         ( xsd:gDay('---12+12:00') = '---12+12:00'^^xsd:gDay) &&

         ( xsd:gDay('---12Z') != '---13Z'^^xsd:gDay) &&
         # no order, but also not incommensurable
         (! ( xsd:gDay('---11') <   xsd:gDay('---12') )) &&
         (! ( xsd:gDay('---12') <   xsd:gDay('---11') )) &&
         (! ( xsd:gDay('---11') <=   xsd:gDay('---12') )) &&
         (! ( xsd:gDay('---12') <=   xsd:gDay('---11') )))
       as ?ok)
where {
 }
EOF


