#! /bin/bash

# validate gMonthDay casting parsing and equality

curl_sparql_request <<EOF \
 | jq '.results.bindings[] | .[].value' | fgrep -q 'true'

# prefix xsd: <http://www.w3.org/2001/XMLSchema-datatypes>

select ((( xsd:gMonthDay('--12-25') = '--12-25'^^xsd:gMonthDay) &&
         ( xsd:gMonthDay('--12-25Z') = '--12-25Z'^^xsd:gMonthDay) &&
         ( xsd:gMonthDay('--12-25Z') != '--12-25'^^xsd:gMonthDay) &&
         ( xsd:gMonthDay('--12-25+12:00') = '--12-25+12:00'^^xsd:gMonthDay) &&

         ( xsd:gMonthDay('--12-25Z') != '--12-24Z'^^xsd:gMonthDay) &&
         ( xsd:gMonthDay('--12-25-14:00') = '--12-26+10:00'^^xsd:gMonthDay) &&
         ( xsd:gMonthDay('--12-25-10:00') != '--12-26Z'^^xsd:gMonthDay) &&

         # test coercion
         ( xsd:gMonthDay(xsd:dateTime('2014-12-31T23:59:58Z')) = '--12-31Z'^^xsd:gMonthDay ) &&
         ( xsd:gMonthDay(xsd:date('2014-12-31')) = '--12-31Z'^^xsd:gMonthDay ) &&

         # no order, but also not incommensurable
         ( xsd:gMonthDay('--11-25') <   xsd:gMonthDay('--12-25') ) &&
         (! ( xsd:gMonthDay('--12-25') <   xsd:gMonthDay('--11-25') )) &&
         ( xsd:gMonthDay('--11-25') <=   xsd:gMonthDay('--11-26') ) &&
         (! ( xsd:gMonthDay('--11-26') <=   xsd:gMonthDay('--11-25') )))
       as ?ok)
where {
 }
EOF


