#! /bin/bash
#
# verify that consolidated filters have the intended effect

curl_sparql_request \
     -H "Accept: application/sparql-results+json" \
     -H "Content-Type:application/sparql-query" <<EOF \
 | tee $ECHO_OUTPUT | jq '.results.bindings[] | .[] | "\(.type),\(.datatype),\(.value)"' | sort | diff -w - /dev/fd/2 2<<TEST
# select basic types updated after `$date` (xsd:dateTime)
PREFIX plm: <http://www.data.nexperia.com/def/plm/>
PREFIX nxp: <http://purl.org/nxp/schema/v1/>

SELECT DISTINCT *
FROM <urn:dydra:all>
WHERE {
    VALUES (?id) {
   ( 'one' )
   ( 'two' )
  }
  OPTIONAL {
     VALUES (?id ?label) {
      ( 'one' '1')
      ( 'one' '2')
      ( 'two' 'A')
      ( 'two' 'B')
      ( 'two' 'C')
    }
  }
  FILTER (?label in ('1', 'C'))

  {
     VALUES (?id ?time ?place) {
      ( 'one' "1970-01-01T00:00:00Z"^^xsd:dateTime <http://example.org>)
      ( 'one' "1970-01-01T00:00:01Z"^^xsd:dateTime <http://example.org>)
      ( 'two' "1970-01-01T00:00:00Z"^^xsd:dateTime <http://example.org>)
      ( 'two' "1970-01-01T00:00:01Z"^^xsd:dateTime <http://example.org>)
    }
  }
  FILTER (?time >= "1970-01-01T00:00:01Z"^^xsd:dateTime)
}
EOF
"literal,http://www.w3.org/2001/XMLSchema#dateTime,1970-01-01T00:00:01Z"
"literal,http://www.w3.org/2001/XMLSchema#dateTime,1970-01-01T00:00:01Z"
"literal,null,1"
"literal,null,C"
"literal,null,one"
"literal,null,two"
"uri,null,http://example.org"
"uri,null,http://example.org"
TEST