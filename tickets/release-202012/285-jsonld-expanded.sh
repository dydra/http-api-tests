#! /bin/bash
#
# verify json-ld encoding.
# reiterates sparql-protocol/media-types for json-ld

curl_sparql_request \
     -H 'Accept: application/ld+json;profile=http://www.w3.org/ns/json-ld#expanded' \
     -H 'Content-Type:application/sparql-query' <<EOF \
 | tee $ECHO_OUTPUT | json_pp | json_diff /dev/stdin /dev/fd/3 3<<TEST 2>&1 | egrep -q '^\[\]$'
construct {
  [ <http://example.org#value> ?o ]
}
where {
  values ?o {
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
[
   {
      "http://example.org#value" : {
         "@language" : "en",
         "@value" : "langstring"
      },
      "@id" : "_:g1"
   },
   {
      "http://example.org#value" : {
         "@value" : "string"
      },
      "@id" : "_:g2"
   },
   {
      "@id" : "_:g3",
      "http://example.org#value" : {
         "@value" : false,
         "@type" : "http://www.w3.org/2001/XMLSchema#boolean"
      }
   },
   {
      "http://example.org#value" : {
         "@type" : "http://www.w3.org/2001/XMLSchema#boolean",
         "@value" : true
      },
      "@id" : "_:g4"
   },
   {
      "@id" : "_:g5",
      "http://example.org#value" : {
         "@value" : "1",
         "@type" : "http://www.w3.org/2001/XMLSchema#integer"
      }
   },
   {
      "http://example.org#value" : {
         "type" : "literal",
         "value" : "1.1",
         "datatype" : "http://www.w3.org/2001/XMLSchema#decimal"
      },
      "@id" : "_:g6"
   },
   {
      "@id" : "_:g7",
      "http://example.org#value" : {
         "@type" : "http://www.w3.org/2001/XMLSchema#double",
         "@value" : "2.0"
      }
   },
   {
      "http://example.org#value" : {
         "@type" : "http://www.w3.org/2001/XMLSchema#float",
         "@value" : "3.0"
      },
      "@id" : "_:g8"
   },
   {
      "http://example.org#value" : {
         "@value" : "2020-12-01",
         "@type" : "http://www.w3.org/2001/XMLSchema#date"
      },
      "@id" : "_:g9"
   },
   {
      "http://example.org#value" : {
         "@value" : "2020-11-30T18:00:00Z",
         "@type" : "http://www.w3.org/2001/XMLSchema#dateTime"
      },
      "@id" : "_:g10"
   },
   {
      "@id" : "_:g11",
      "http://example.org#value" : {
         "@type" : "http://www.w3.org/2001/XMLSchema#dateTime",
         "@value" : "2020-12-01T00:00:00Z"
      }
   },
   {
      "@id" : "_:g12",
      "http://example.org#value" : {
         "@value" : "2020-12-01T00:00:00",
         "@type" : "http://www.w3.org/2001/XMLSchema#dateTime"
      }
   },
   {
      "@id" : "_:g13",
      "http://example.org#value" : {
         "@value" : "2020-12-01T06:00:00Z",
         "@type" : "http://www.w3.org/2001/XMLSchema#dateTime"
      }
   }
]
TEST
