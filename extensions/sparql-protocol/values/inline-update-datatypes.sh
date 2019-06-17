#! /bin/bash

# test update with a values argument

#cat > /dev/null <<EOF

# unsupported type first, in order to avoid rdfcache import bug

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
{ 'abcdefg'^^<http://example.org/datatype> 1 2.0 true 'a'@en  'b' <http://example.org>  'P1Y2M'^^xsd:yearMonthDuration 'P1DT2H'^^xsd:dayTimeDuration '2014-01-02T10:11:12Z'^^xsd:dateTime '2014-01-01'^^xsd:date '10:11:12'^^xsd:time '2014'^^xsd:gYear }
EOF4
#EOF

cat > sort-precedence.txt <<EOF
"blank"
"http://example.org"
"a"
"b"
"true"
"1"
"2.0"
"2014"
"P1DT2H"
"P1Y2M"
"2014-01-01"
"10:11:12Z"
"2014-01-02T10:11:12Z"
"abcdefg"
EOF

# see spocq:algepra/operators/basic-operators.lisp#type-sort-precedence
# non-native types are last.
curl_sparql_request <<EOF  \
  --repository "${STORE_REPOSITORY}-write" \
 | tee /dev/tty | jq '.results.bindings[] | .value.value' | tee /dev/tty | diff --strip-trailing-cr - sort-precedence.txt 

select ?value
where { ?s <http://example.org/value> ?value }
order by ?value
EOF

rm sort-precedence.txt
