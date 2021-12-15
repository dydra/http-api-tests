#! /bin/bash

# use inline values to test decimal handling
# it should emit 8 solutions - one for each,  and all decimal

curl_sparql_request --data-binary @- \
   -H "Accept: application/sparql-results+json" \
   -H "Content-Type: application/sparql-query" <<EOF \
 | tee ${ECHO_OUTPUT} | fgrep -c '#decimal' | fgrep -q "8"
prefix xsd: <http://www.w3.org/2001/XMLSchema#>
select ?value 
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
}
EOF