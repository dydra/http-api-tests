#! /bin/bash

# test sort precedence for full complement of datatypes

curl_sparql_request \
   "--data-urlencode" "update@/dev/fd/3" \
   "--data-urlencode" "values@/dev/fd/4" \
   -H "Content-Type: application/x-www-form-urlencoded" \
   --repository "${STORE_REPOSITORY}-write" 3<<EOF3 4<<EOF4 \
 | jq '.boolean' | fgrep -q 'true'
DROP  SILENT  ALL;
insert { _:test <http://example.org/value> ?value }
where { { values (?value) { } }
        union { bind ( bnode('blank')  as ?value ) }
      }
EOF3
?value
{ 1 2.0 true 'a'@en 'b' <http://example.org> 'c'^^<http://example.org/datatype> 'P1Y2M'^^xsd:yearMonthDuration 'P1DT2H'^^xsd:dayTimeDuration '2014-01-02T10:11:12Z'^^xsd:dateTime '2014-01-01'^^xsd:date '10:11:12'^^xsd:time '2014'^^xsd:gYear }
EOF4


curl_sparql_request <<EOF  \
  --repository "${STORE_REPOSITORY}-write" \
 | jq '.results.bindings[] | .value.value' | diff - sort-precedence.txt 

select ?value
where { ?s <http://example.org/value> ?value }
order by ?value
EOF

