#! /bin/bash
#
# verify round-trip for valid _and_ invalid basic temporal types
# invalid terms should still be round-tripped

curl_sparql_request \
     -H "Accept: application/n-quads" \
     -H "Content-Type:application/sparql-query" <<EOF \
  | tee $ECHO_OUTPUT | diff -w - /dev/fd/2 2<<TEST
construct {
  [ <http://example.org#value> ?o ]
}
where {
  values ?o {
    '2020-12-03'^^xsd:date
    '2020-12-03-06:00'^^xsd:date
    '2020-12-03+06:00'^^xsd:date
    '2020-12-03Z'^^xsd:date
    '2020-12-03Z+07:00'^^xsd:date #invalid
    '2020-12-03T00:00:00'^^xsd:dateTime
    '2020-12-03T00:00:00Z'^^xsd:dateTime
    '2020-12-03T00:00:00-06:00'^^xsd:dateTime
    '2020-12-03T00:00:00+06:00'^^xsd:dateTime
    '2020-12-03T00:00:00Z-06:00'^^xsd:dateTime  # invalid
    '2020-12-03T00:00:00Z+06:00'^^xsd:dateTime  # invalid
    '00:03:00'^^xsd:time
    '00:03:00-06:00'^^xsd:time
    '00:03:00+06:00'^^xsd:time
    '00:03:00Z'^^xsd:time
    '00:03:00Z+07:00'^^xsd:time
  }
}
EOF
_:g1 <http://example.org#value> "2020-12-03"^^<http://www.w3.org/2001/XMLSchema#date> .
_:g2 <http://example.org#value> "2020-12-03-06:00"^^<http://www.w3.org/2001/XMLSchema#date> .
_:g3 <http://example.org#value> "2020-12-03+06:00"^^<http://www.w3.org/2001/XMLSchema#date> .
_:g4 <http://example.org#value> "2020-12-03"^^<http://www.w3.org/2001/XMLSchema#date> .
_:g5 <http://example.org#value> "2020-12-03Z+07:00"^^<http://www.w3.org/2001/XMLSchema#date> .
_:g6 <http://example.org#value> "2020-12-03T00:00:00"^^<http://www.w3.org/2001/XMLSchema#dateTime> .
_:g7 <http://example.org#value> "2020-12-03T00:00:00Z"^^<http://www.w3.org/2001/XMLSchema#dateTime> .
_:g8 <http://example.org#value> "2020-12-03T06:00:00Z"^^<http://www.w3.org/2001/XMLSchema#dateTime> .
_:g9 <http://example.org#value> "2020-12-02T18:00:00Z"^^<http://www.w3.org/2001/XMLSchema#dateTime> .
_:g10 <http://example.org#value> "2020-12-03T00:00:00Z-06:00"^^<http://www.w3.org/2001/XMLSchema#dateTime> .
_:g11 <http://example.org#value> "2020-12-03T00:00:00Z+06:00"^^<http://www.w3.org/2001/XMLSchema#dateTime> .
_:g12 <http://example.org#value> "00:03:00Z"^^<http://www.w3.org/2001/XMLSchema#time> .
_:g13 <http://example.org#value> "06:03:00Z"^^<http://www.w3.org/2001/XMLSchema#time> .
_:g14 <http://example.org#value> "18:03:00Z"^^<http://www.w3.org/2001/XMLSchema#time> .
_:g15 <http://example.org#value> "00:03:00Z"^^<http://www.w3.org/2001/XMLSchema#time> .
_:g16 <http://example.org#value> "00:03:00Z+07:00"^^<http://www.w3.org/2001/XMLSchema#time> .
TEST
