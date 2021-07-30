#! /bin/bash
# test path matching with "from all"
# see the paths README

curl_graph_store_update -X PUT -o /dev/null \
      -H "Content-Type: application/n-quads" \
      --repository "${STORE_REPOSITORY}-write" <<EOF
<http://example.com/s1> <http://example.com/p> <http://example.com/s2> .
<http://example.com/s2> <http://example.com/p> <http://example.com/s3> <http://example.com/g1> .
<http://example.com/s3> <http://example.com/p> <http://example.com/s4> <http://example.com/g2> .
<http://example.com/s4> <http://example.com/p> <http://example.com/s5> <http://example.com/g3> .
EOF


# simple enumeration of all statements merged into the default graph
# should yield all paths, as all graphs are in the datasset
curl_sparql_request \
     --repository "${STORE_REPOSITORY}-write" \
     -H "Content-Type: application/sparql-query" \
     -H "Accept: application/sparql-results+json" <<EOF \
   | jq '.results.bindings[] | .[].value' | fgrep 'example' | wc -l | fgrep -q "4"
prefix    : <http://example.com/> 
select ?o
from <urn:dydra:all>
where {?s :p ?o}
order by ?o
EOF

# should yield no result, as no named graph is in the dataset
curl_sparql_request \
     --repository "${STORE_REPOSITORY}-write" \
     -H "Content-Type: application/sparql-query" \
     -H "Accept: application/sparql-results+json" <<EOF \
   | jq '.results.bindings[] | .[].value' | fgrep -q "0"
prefix : <http://example.com/>
select (count (?o) as ?count)
from <urn:dydra:all>
where {graph ?g {?s :p ?o} }
EOF

# simple elementary path in either direction
curl_sparql_request \
     --repository "${STORE_REPOSITORY}-write" \
     -H "Content-Type: application/sparql-query" \
     -H "Accept: application/sparql-results+json" <<EOF \
   | jq '.results.bindings[] | .[].value' | fgrep -q '2'
prefix    : <http://example.com/> 
select (count (?o) as ?count)
from <urn:dydra:all>
where { 
  { <http://example.com/s1> :p ?o . }
  union
  { <http://example.com/s2> :p ?o . }
}
EOF

curl_sparql_request \
     --repository "${STORE_REPOSITORY}-write" \
     -H "Content-Type: application/sparql-query" \
     -H "Accept: application/sparql-results+json" <<EOF \
   | jq '.results.bindings[] | .[].value' | fgrep -q '2'
prefix    : <http://example.com/> 
select (count (?s) as ?count)
from <urn:dydra:all>
where { 
  { ?s :p <http://example.com/s2> . }
  union
  { ?s :p <http://example.com/s3> . }
}
EOF

echo "simple sequence path in either direction" > ${ECHO_OUTPUT}
curl_sparql_request \
     --repository "${STORE_REPOSITORY}-write" \
     -H "Content-Type: application/sparql-query" \
     -H "Accept: application/sparql-results+json" <<EOF \
   | jq '.results.bindings[] | .[].value' | fgrep -q '2'
prefix    : <http://example.com/> 
select (count (?o) as ?count)
from <urn:dydra:all>
where { 
  { <http://example.com/s1> :p/:p ?o . }
  union
  { <http://example.com/s2> :p/:p ?o . }
}
EOF

echo "union constant & 2x-sequence" > ${ECHO_OUTPUT}
curl_sparql_request \
     --repository "${STORE_REPOSITORY}-write" \
     -H "Content-Type: application/sparql-query" \
     -H "Accept: application/sparql-results+json" <<EOF \
   | jq '.results.bindings[] | .[].value' | fgrep -q '2'
prefix    : <http://example.com/> 
select (count (?s) as ?count)
from <urn:dydra:all>
where { 
  { ?s :p/:p <http://example.com/s3> . }
  union
  { ?s :p/:p <http://example.com/s4> . }
}
EOF

echo "union constant & 3x-sequence" > ${ECHO_OUTPUT}
curl_sparql_request \
     --repository "${STORE_REPOSITORY}-write" \
     -H "Content-Type: application/sparql-query" \
     -H "Accept: application/sparql-results+json" <<EOF \
   | jq '.results.bindings[] | .[].value' | fgrep -q '2'
prefix    : <http://example.com/> 
select (count (*) as ?count)
from <urn:dydra:all>
where { 
  { <http://example.com/s1> :p/:p/:p ?o . }
  union
  { ?s :p/:p/:p <http://example.com/s5> . }
}
EOF

echo "union constant & 4x-sequence" > ${ECHO_OUTPUT}
curl_sparql_request \
     --repository "${STORE_REPOSITORY}-write" \
     -H "Content-Type: application/sparql-query" \
     -H "Accept: application/sparql-results+json" <<EOF \
   | jq '.results.bindings[] | .[].value' | fgrep -q '2'
prefix    : <http://example.com/> 
select (count (*) as ?count)
from <urn:dydra:all>
where { 
  { <http://example.com/s1> :p/:p/:p/:p ?o . }
  union
  { ?s :p/:p/:p/:p <http://example.com/s5> . }
}
EOF

echo "variant sequence paths" > ${ECHO_OUTPUT}
curl_sparql_request \
     --repository "${STORE_REPOSITORY}-write" \
     -H "Content-Type: application/sparql-query" \
     -H "Accept: application/sparql-results+json" <<EOF \
   | jq '.results.bindings[] | .[].value' | fgrep -q '3'
prefix    : <http://example.com/> 
select ?s ?o
from <urn:dydra:all>
where {?s :p/:p ?o}
order by ?s ?o
EOF

curl_sparql_request \
     --repository "${STORE_REPOSITORY}-write" \
     -H "Content-Type: application/sparql-query" \
     -H "Accept: application/sparql-results+json" <<EOF \
   | jq '.results.bindings[] | .[].value' | fgrep -q '2'
prefix    : <http://example.com/> 
select ?s ?o
from <urn:dydra:all>
where {?s :p/:p/:p ?o}
order by ?s ?o
EOF

curl_sparql_request \
     --repository "${STORE_REPOSITORY}-write" \
     -H "Content-Type: application/sparql-query" \
     -H "Accept: application/sparql-results+json" <<EOF \
   | jq '.results.bindings[] | .[].value' | fgrep -q '1'
prefix    : <http://example.com/> 
select ?s (count(?s) as ?count)
from <urn:dydra:all>
where {?s :p/:p/:p/:p ?o}
EOF

curl_sparql_request \
     --repository "${STORE_REPOSITORY}-write" \
     -H "Content-Type: application/sparql-query" \
     -H "Accept: application/sparql-results+json" <<EOF \
   | jq '.results.bindings[] | .[].value' | fgrep -q '0'
prefix    : <http://example.com/> 
select ?s (count(?s) as ?count)
from <urn:dydra:all>
where {?s :p/:p/:p/:p/:p ?o}
EOF

curl_sparql_request \
     --repository "${STORE_REPOSITORY}-write" \
     -H "Content-Type: application/sparql-query" \
     -H "Accept: application/sparql-results+json" <<EOF \
   | jq '.results.bindings[] | .count | .value' | tr -s '\n' ',' | fgrep -q '"5","4","3","2","1"'
prefix    : <http://example.com/> 
select ?s (count(?s) as ?count)
from <urn:dydra:all>
where {?s :p* ?o}
group by ?s
order by ?s
EOF


curl_sparql_request \
     --repository "${STORE_REPOSITORY}-write" \
     -H "Content-Type: application/sparql-query" \
     -H "Accept: application/sparql-results+json" <<EOF \
   | jq '.results.bindings[] | .count | .value' | tr -s '\n' ',' | fgrep -q '"4","3","2","1"'
prefix    : <http://example.com/> 
select ?s (count(?s) as ?count)
from <urn:dydra:all>
where {?s :p+ ?o}
group by ?s
order by ?s
EOF

