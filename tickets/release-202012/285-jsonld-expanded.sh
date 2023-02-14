#! /bin/bash
#
# verify json-ld encoding.
# reiterates sparql-protocol/media-types for json-ld as expanded

curl_sparql_request \
     -H 'Accept: application/ld+json;profile=http://www.w3.org/ns/json-ld#expanded' \
     -H 'Content-Type:application/sparql-query' <<EOF  \
 | tee $ECHO_OUTPUT > tmp.json
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

json_diff tmp.json <<EOF 2>&1 | tee $ECHO_OUTPUT | egrep -q '^\[\]$'
[
   {
      "@id" : "_:g1",
      "http://example.org#value" : {
         "@id" : "http://example.org/aURI"
      }
   },
   {
      "@id" : "_:g2",
      "http://example.org#value" : {
         "@language" : "en",
         "@value" : "langstring"
      }
   },
   {
      "@id" : "_:g3",
      "http://example.org#value" : {
         "@value" : "string"
      }
   },
   {
      "@id" : "_:g4",
      "http://example.org#value" : {
         "@type" : "http://www.w3.org/2001/XMLSchema#boolean",
         "@value" : false
      }
   },
   {
      "@id" : "_:g5",
      "http://example.org#value" : {
         "@type" : "http://www.w3.org/2001/XMLSchema#boolean",
         "@value" : true
      }
   },
   {
      "@id" : "_:g6",
      "http://example.org#value" : {
         "@type" : "http://www.w3.org/2001/XMLSchema#integer",
         "@value" : "1"
      }
   },
   {
      "@id" : "_:g7",
      "http://example.org#value" : {
         "@type" : "http://www.w3.org/2001/XMLSchema#decimal",
         "@value" : "1.1"
      }
   },
   {
      "@id" : "_:g8",
      "http://example.org#value" : {
         "@type" : "http://www.w3.org/2001/XMLSchema#double",
         "@value" : "2.0"
      }
   },
   {
      "@id" : "_:g9",
      "http://example.org#value" : {
         "@type" : "http://www.w3.org/2001/XMLSchema#float",
         "@value" : "3.0"
      }
   },
   {
      "@id" : "_:g10",
      "http://example.org#value" : {
         "@type" : "http://www.w3.org/2001/XMLSchema#date",
         "@value" : "2020-12-01"
      }
   },
   {
      "@id" : "_:g11",
      "http://example.org#value" : {
         "@type" : "http://www.w3.org/2001/XMLSchema#dateTime",
         "@value" : "2020-11-30T18:00:00Z"
      }
   },
   {
      "@id" : "_:g12",
      "http://example.org#value" : {
         "@type" : "http://www.w3.org/2001/XMLSchema#dateTime",
         "@value" : "2020-12-01T00:00:00Z"
      }
   },
   {
      "@id" : "_:g13",
      "http://example.org#value" : {
         "@type" : "http://www.w3.org/2001/XMLSchema#dateTime",
         "@value" : "2020-12-01T00:00:00"
      }
   },
   {
      "@id" : "_:g14",
      "http://example.org#value" : {
         "@type" : "http://www.w3.org/2001/XMLSchema#dateTime",
         "@value" : "2020-12-01T06:00:00Z"
      }
   }
]
EOF



