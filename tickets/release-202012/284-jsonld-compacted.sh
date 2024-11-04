#! /bin/bash
#
# verify json-ld encoding.
# reiterates sparql-protocol/media-types for json-ld
#
# json_diff:
#     pip install json-delta
# when the documents match, it emit an empty array: []

curl_sparql_request \
     -H "Accept: application/ld+json" \
     -H "Content-Type:application/sparql-query" <<EOF \
 | tee $ECHO_OUTPUT | json_pp | ./json_diff /dev/stdin /dev/fd/3 3<<TEST 2>&1 #| egrep -q '^\[\]$'
construct {
  [ <http://example.org#value> ?o ]
}
where {
  values ?o {
    <http://example.org/aURI>
    '2020-12-01'^^xsd:date
    '2020-12-01T00:00:00'^^xsd:dateTime
    '2020-12-01T00:00:00Z'^^xsd:dateTime
    '2020-12-01T00:00:00-06:00'^^xsd:dateTime
    '2020-12-01T00:00:00+06:00'^^xsd:dateTime
    'true'^^xsd:boolean
    'false'^^xsd:boolean
    '1.1'^^xsd:decimal
    '1'^^xsd:integer
    '2.0'^^xsd:double
    '3.0'^^xsd:float
    'string'
    'langstring'@en
  }
}
order by ?o
EOF
{
   "@graph" : [
      {
         "@id" : "_:g1",
         "http://example.org#value" : "http://example.org/aURI"
      },
      {
         "@id" : "_:g2",
         "http://example.org#value" : {
            "@value" : "langstring",
            "@language" : "en"
         }
      },
      {
         "@id" : "_:g3",
         "http://example.org#value" : "string"
      },
      {
         "@id" : "_:g4",
         "http://example.org#value" : false
      },
      {
         "http://example.org#value" : true,
         "@id" : "_:g5"
      },
      {
         "@id" : "_:g6",
         "http://example.org#value" : 1
      },
      {
         "@id" : "_:g7",
         "http://example.org#value" : 1.1
      },
      {
         "@id" : "_:g8",
         "http://example.org#value" : 2
      },
      {
         "http://example.org#value" : 3,
         "@id" : "_:g9"
      },
      {
         "http://example.org#value" : "2020-12-01",
         "@id" : "_:g10"
      },
      {
         "@id" : "_:g11",
         "http://example.org#value" : "2020-11-30T18:00:00Z"
      },
      {
         "http://example.org#value" : "2020-12-01T00:00:00Z",
         "@id" : "_:g12"
      },
      {
         "@id" : "_:g13",
         "http://example.org#value" : "2020-12-01T00:00:00"
      },
      {
         "@id" : "_:g14",
         "http://example.org#value" : "2020-12-01T06:00:00Z"
      }
   ]
}
TEST
