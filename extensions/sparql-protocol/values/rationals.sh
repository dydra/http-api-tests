#! /bin/bash

# use inline values to test decimal handling
# it should emit 8 triples: the type and seven value with 0.0 de-duplicated

curl_sparql_request --data-binary @- \
   -H "Accept: application/n-triples" \
   -H "Content-Type: application/sparql-query" <<EOF \
 | tee ${ECHO_OUTPUT} | fgrep -c '/sample' | fgrep -q "8"
prefix xsd: <http://www.w3.org/2001/XMLSchema#>
construct {
  <http://example.org/sample> <http://example.org/value> ?value .
  <http://example.org/sample> <http://example.org/type> ?type .
}
where {
 values ?value {
   '-0.0'^^xsd:decimal
   '-0.1'^^xsd:decimal
   '-1.0'^^xsd:decimal
   '-1.1'^^xsd:decimal
   '0.0'^^xsd:decimal
   '0.1'^^xsd:decimal
   '1.0'^^xsd:decimal
   '1.1'^^xsd:decimal
 }
 bind (datatype(?value) as ?type)
}
EOF