#! /bin/bash
#
# verify round-trip for valid _and_ invalid basic temporal types

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
    '2020-12-03Z+06:00'^^xsd:date
    '2020-12-03T00:00:00'^^xsd:dateTime
    '2020-12-03T00:00:00Z'^^xsd:dateTime
    '2020-12-03T00:00:00-06:00'^^xsd:dateTime
    '2020-12-03T00:00:00+06:00'^^xsd:dateTime
    '2020-12-03T00:00:00Z-06:00'^^xsd:dateTime
    '2020-12-03T00:00:00Z+06:00'^^xsd:dateTime
    '00:03:00'^^xsd:time
    '00:03:00-06:00'^^xsd:time
    '00:03:00+06:00'^^xsd:time
    '00:03:00Z'^^xsd:time
    '00:03:00Z+06:00'^^xsd:time
  }
}
EOF

TEST
