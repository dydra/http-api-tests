#! /bin/bash

# exercise the query state functions

curl_sparql_request <<EOF \
 | jq '.results.bindings[] | .[].value' | fgrep -q 'true'

# prefix xsd: <http://www.w3.org/2001/XMLSchema-datatypes>

select ((( xsd:gYearMonth('1976-02-05:00') = '1976-02-05:00'^^xsd:gYearMonth) &&
         ( xsd:gYearMonth('1976-02Z') = '1976-02Z'^^xsd:gYearMonth) &&
         ( xsd:gYearMonth('1976-02Z') != '1976-02'^^xsd:gYearMonth) &&
         ( xsd:gYearMonth('1976-02+12:00') = '1976-02+12:00'^^xsd:gYearMonth) &&

         ( xsd:gYearMonth('1976-02-12:00') != '1976-02+12:00'^^xsd:gYearMonth) &&
         ( xsd:gYearMonth('1976-02-10:00') != '1976-02Z'^^xsd:gYearMonth) &&

         # test coercion
         ( xsd:gYearMonth(xsd:dateTime('2014-12-31T23:59:58Z')) = '2014-12Z'^^xsd:gYearMonth ) &&
         ( xsd:gYearMonth(xsd:date('2014-12-31')) = '2014-12Z'^^xsd:gYearMonth ) &&

         # no order, but also not incommensurable
         ( xsd:gYearMonth('1975-02') <   xsd:gYearMonth('1976-02') ) &&
         (! ( xsd:gYearMonth('1976-02') <   xsd:gYearMonth('1975-02') )) &&
         ( xsd:gYearMonth('1975-02') <=   xsd:gYearMonth('1975-03') ) &&
         (! ( xsd:gYearMonth('1976-02') <=   xsd:gYearMonth('1975-03') ))
          )
       as ?ok)
where {
 }

EOF
