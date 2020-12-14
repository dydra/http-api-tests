#! /bin/bash
#
# test that rational unit values round-trip
# - they should have all been included in the sum
# - the result datatype should be decimal

curl_sparql_request \
     -H "Accept: application/sparql-results+json" \
     -H "Content-Type:application/sparql-query" <<EOF \
 | tee $ECHO_OUTPUT | tr '\n' '=' | fgrep '"-1.0"' | fgrep -c decimal | fgrep -q 1
prefix xsd: <http://www.w3.org/2001/XMLSchema#>
select (sum(?value) as ?sum)
where {
  VALUES (?label ?value) {
    ( '-2.0' '-2.0'^^xsd:decimal )
    ( '0.0' '0.0'^^xsd:decimal )
    ( '1.0' '1.0'^^xsd:decimal )
  }        
}
EOF
