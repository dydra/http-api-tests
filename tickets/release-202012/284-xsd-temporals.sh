#! /bin/bash
#
# verify round-trip for valid _and_ invalid basic temporal types

curl_sparql_request \
     -H "Accept: application/n-quads" \
     -H "Content-Type:application/sparql-query" <<EOF \
  | sort | tee $ECHO_OUTPUT | diff -w - /dev/fd/2 2<<TEST
construct {
  [ <http://example.org#value> ?o ]
}
where {
  values ?o {
    '2020-12-01'^^xsd:date
    '2020-12-01-06:00'^^xsd:date
    '2020-12-01+06:00'^^xsd:date
    '2020-12-01Z'^^xsd:date
    '2020-12-01Z+06:00'^^xsd:date
    '2020-12-01T00:00:00'^^xsd:dateTime
    '2020-12-01T00:00:00Z'^^xsd:dateTime
    '2020-12-01T00:00:00-06:00'^^xsd:dateTime
    '2020-12-01T00:00:00+06:00'^^xsd:dateTime
    '2020-12-01T00:00:00Z-06:00'^^xsd:dateTime
    '2020-12-01T00:00:00Z+06:00'^^xsd:dateTime
    '00:00:00'^^xsd:time
    '00:00:00Z+06:00'^^xsd:time
  }
}
order by ?o
EOF

TEST
