#! /bin/bash

# exercise aggregation over temporal data

curl_graph_store_update -X PUT -o /dev/null \
      -H "Content-Type: text/turtle" \
      --repository "${STORE_REPOSITORY}-write" default <<EOF
@prefix ex: <http://example.com/> .
@prefix xsd: <http://www.w3.org/2001/XMLSchema-datatypes#> .

_:a ex:start "2014-01-01T00:00:00Z"^^xsd:dateTime ;
  ex:end "2014-01-01T06:00:00Z"^^xsd:dateTime .

_:b ex:start "2014-01-01T00:00:00Z"^^xsd:dateTime ;
  ex:end "2014-01-02T00:00:00Z"^^xsd:dateTime .

_:c ex:start "2014-01-01T00:00:00Z"^^xsd:dateTime ;
  ex:end "2014-02-01T00:00:00Z"^^xsd:dateTime .

_:d ex:start "2014-01-01T00:00:00Z"^^xsd:dateTime ;
  ex:end "2015-01-01T00:00:00Z"^^xsd:dateTime .
EOF

curl_sparql_request \
     -H "Accept: application/sparql-results+json" \
     --repository "${STORE_REPOSITORY}-write" <<EOF \
   | jq '.results.bindings[] | .[].value'  | fgrep -q 'true'

prefix xsd: <http://www.w3.org/2001/XMLSchema-datatypes>
prefix ex: <http://example.com/>

select (( (min(?endDate) = '2014-01-01T06:00:00Z'^^xsd:dateTime)
       && (max(?endDate) = '2015-01-01T00:00:00Z'^^xsd:dateTime)
       #  not possible to add dates
       ## && (avg(?startDate) = '2014-01-01T00:00:00Z'^^xsd:dateTime) 
       && (sum(?duration) = xsd:dayTimeDuration('P397DT6H'))
       && (min(?duration) = xsd:dayTimeDuration('PT6H')) 
       && (max(?duration) = xsd:dayTimeDuration('P365D'))
       && (avg(?duration) = xsd:dayTimeDuration('P99DT7H30M'))
         )
        as ?ok)
where {
  ?s ex:start ?startDate ;
    ex:end ?endDate .
  bind ((?endDate - ?startDate) as ?duration)
}
EOF

# this would signal an error
# (spocq.e:+ ({xsd}dateTime "2014-01-01T00:00:00Z") ({xsd}dateTime "2014-01-01T00:00:00Z"))
