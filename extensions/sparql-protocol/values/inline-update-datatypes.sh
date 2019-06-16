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
{  'c'^^<http://example.org/datatype> 1 2.0 true 'a'@en 'b' <http://example.org> 'P1Y2M'^^xsd:yearMonthDuration 'P1DT2H'^^xsd:dayTimeDuration '2014-01-02T10:11:12Z'^^xsd:dateTime '2014-01-01'^^xsd:date '10:11:12'^^xsd:time '2014'^^xsd:gYear }
EOF4
#EOF

# see spocq:algepra/operators/basic-operators.lisp#type-sort-precedence
# non-native types are last.
curl_sparql_request <<EOF  \
  --repository "${STORE_REPOSITORY}-write" \
 | jq '.results.bindings[] | .value.value' | diff - sort-precedence.txt 

select ?value
where { ?s <http://example.org/value> ?value }
order by ?value
EOF

cat > /dev/null <<EOFF
-----------
(in-package :spocq.i) (initialize-spocq)
(trace rdfcache:initialize-term rdfcache-intern-field rdfcache:intern-term set-optional-term rdfcache-object-term-number)
curl_sparql_request <<EOF  \
  --repository "${STORE_REPOSITORY}-write" #| jq '.results.bindings[] | .value.value'
select ?value
where { ?s <http://example.org/value> ?value }
#order by ?value
EOF

(parse-sparql "
DROP  SILENT  ALL;
insert { _:test <http://example.org/value> ?value }
where { { values ?value { 1 2.0 true 'a'@en 'b' <http://example.org> 'c'^^<http://example.org/datatype> 'P1Y2M'^^xsd:yearMonthDuration 'P1DT2H'^^xsd:dayTimeDuration '2014-01-02T10:11:12Z'^^xsd:dateTime '2014-01-01'^^xsd:date '10:11:12'^^xsd:time '2014'^^xsd:gYear }
 }
        union { bind ( bnode('blank')  as ?value ) }
      }
")

(in-package :spocq.i) (initialize-spocq)
(trace rdfcache:initialize-term rdfcache-intern-field rdfcache:intern-term set-optional-term rdfcache-object-term-number)
(test-sparql "
DROP  SILENT  ALL;
insert { _:test <http://example.org/value> ?value }
where { { values ?value { 1 2.0 true 'a'@en  'c'^^<http://example.org/datatype> 'b' 'c'^^<http://example.org/datatype> <http://example.org>  'P1Y2M'^^xsd:yearMonthDuration 'P1DT2H'^^xsd:dayTimeDuration '2014-01-02T10:11:12Z'^^xsd:dateTime '2014-01-01'^^xsd:date '10:11:12'^^xsd:time '2014'^^xsd:gYear }
 }
        union { bind ( bnode('blank')  as ?value ) }
      }
" :repository-id "openrdf-sesame/mem-rdf-write")

(in-package :spocq.i) (initialize-spocq)
(trace rdfcache:initialize-term rdfcache-intern-field rdfcache:intern-term set-optional-term rdfcache-object-term-number)
(test-sparql "
DROP  SILENT  ALL;
insert { _:test <http://example.org/value> ?value }
where { values ?value {'c'^^<http://example.org/datatype>  'b' } }
" :repository-id "openrdf-sesame/mem-rdf-write")

(in-package :spocq.i) (initialize-spocq)
(trace rdfcache:initialize-term rdfcache-intern-field rdfcache:intern-term set-optional-term rdfcache-object-term-number)
(test-sparql "
DROP  SILENT  ALL;
insert { _:test <http://example.org/value> ?value }
where { values ?value { 'b' 'c'^^<http://example.org/datatype>  } }
" :repository-id "openrdf-sesame/mem-rdf-write")

(test-sparql "
DROP  SILENT  ALL;
" :repository-id "openrdf-sesame/mem-rdf")
EOFF
