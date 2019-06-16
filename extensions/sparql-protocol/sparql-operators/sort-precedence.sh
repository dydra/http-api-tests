#! /bin/bash

# test sort precedence for full complement of datatypes

curl_sparql_request <<EOF  \
 | jq '.results.bindings[] | .value.value' | diff - sort-precedence.txt 

select ?value
 where {
  {  values ?value
         { 1 2.0 true
           'plain'@en
           'string'
           <http://example.org>
           'non-native'^^<http://example.org/datatype>
           'P1Y2M'^^<http://www.w3.org/2001/XMLSchema#yearMonthDuration>
           'P1DT2H'^^<http://www.w3.org/2001/XMLSchema#dayTimeDuration>
           '2014-01-02T10:11:12Z'^^<http://www.w3.org/2001/XMLSchema#dateTime>
           '2014-01-01Z'^^<http://www.w3.org/2001/XMLSchema#date>
           '10:11:12'^^<http://www.w3.org/2001/XMLSchema#time>
           '2014'^^<http://www.w3.org/2001/XMLSchema#gYear>
         } }
  union {
   bind ( bnode('blank')  as ?value )
 }
}
order by ?value
EOF

