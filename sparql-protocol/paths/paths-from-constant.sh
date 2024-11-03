#! /bin/bash
# test path queries which enumerate constant default graphs
# see the paths README
# 20160311: spocq#240: kleene star paths need to test both directions

curl_graph_store_update -X PUT -o /dev/null \
      -H "Content-Type: application/n-quads" \
      --repository "${STORE_REPOSITORY}-write" <<EOF
<http://example.com/s1> <http://example.com/p> <http://example.com/s2> .
<http://example.com/s2> <http://example.com/p> <http://example.com/s3> <http://example.com/g1> .
<http://example.com/s3> <http://example.com/p> <http://example.com/s4> <http://example.com/g2> .
<http://example.com/s4> <http://example.com/p> <http://example.com/s5> <http://example.com/g3> .
EOF


# simple enumeration of all statements merged into the default graph
# should yield all present paths, as all graphs are in the datasset
curl_sparql_request \
     --repository "${STORE_REPOSITORY}-write" \
     -H "Content-Type: application/sparql-query" \
     -H "Accept: application/sparql-results+json" <<EOF \
   | jq '.results.bindings[] | .[].value' | fgrep 'example' | wc -l | fgrep -q "2"
prefix    : <http://example.com/> 
select ?o
from :g1
from :g2
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
from :g1
from :g2
where {graph ?g {?s :p ?o} }
EOF

echo "simple elementary path in either direction" > ${ECHO_OUTPUT}
curl_sparql_request \
     --repository "${STORE_REPOSITORY}-write" \
     -H "Content-Type: application/sparql-query" \
     -H "Accept: application/sparql-results+json" <<EOF \
   | jq '.results.bindings[] | .[].value' | fgrep -q '2'
prefix    : <http://example.com/> 
select (count (?o) as ?count)
from :g1
from :g2
where { 
  { <http://example.com/s1> :p ?o . }
  union
  { <http://example.com/s2> :p ?o . }
  union
  { <http://example.com/s3> :p ?o . }
}
EOF

echo "test union of paths with constant object" > $ECHO_OUTPUT
curl_sparql_request \
     --repository "${STORE_REPOSITORY}-write" \
     -H "Content-Type: application/sparql-query" \
     -H "Accept: application/sparql-results+json" <<EOF \
   | tee $ECHO_OUTPUT | jq '.results.bindings[] | .[].value' | fgrep -q '2'
prefix    : <http://example.com/> 
select (count (?s) as ?count)
from :g1
from :g2
where { 
  { ?s :p <http://example.com/s2> . }
  union
  { ?s :p <http://example.com/s3> . }
  union
  { ?s :p <http://example.com/s4> . }
}
EOF

echo "sequence paths with single constant anchor should travers boundary" > $ECHO_OUTPUT
curl_sparql_request \
     --repository "${STORE_REPOSITORY}-write" \
     -H "Content-Type: application/sparql-query" \
     -H "Accept: application/sparql-results+json" <<EOF \
   | tee $ECHO_OUTPUT | jq '.results.bindings[] | .[].value' | fgrep -q '2'
prefix    : <http://example.com/> 
select * # (count (*) as ?count)
from :g1
from :g2
where { 
  { <http://example.com/s2> :p/:p ?o . }
  union
  { ?s :p/:p <http://example.com/s4> . }
}
EOF


echo "sequence path variants with variable anchors should yield one path across boundary" > $ECHO_OUTPUT
curl_sparql_request \
     --repository "${STORE_REPOSITORY}-write" \
     -H "Content-Type: application/sparql-query" \
     -H "Accept: application/sparql-results+json" <<EOF \
   | tee $ECHO_OUTPUT | jq '.results.bindings[] | .[].value' | fgrep -q '1'
prefix    : <http://example.com/> 
select (count (?s) as ?count)
from :g1
from :g2
where {?s :p/:p ?o}
EOF

echo "unrolled path variants with variable anchors should yield the same endpoints as the path" > $ECHO_OUTPUT
curl_sparql_request \
     --repository "${STORE_REPOSITORY}-write" \
     -H "Content-Type: application/sparql-query" \
     -H "Accept: application/sparql-results+json" <<EOF \
   | tee $ECHO_OUTPUT | jq '.results.bindings[] | .[].value' | fgrep -q '1'
prefix    : <http://example.com/> 
select (count (?s) as ?count)
from :g1
from :g2
where {?s :p ?x . ?x :p ?o}
EOF


echo "sequence beyond dataset boundaries yields no result" > $ECHO_OUTPUT
curl_sparql_request \
     --repository "${STORE_REPOSITORY}-write" \
     -H "Content-Type: application/sparql-query" \
     -H "Accept: application/sparql-results+json" <<EOF \
   | tee $ECHO_OUTPUT | jq '.results.bindings[] | .[].value' | fgrep -q '0'
prefix    : <http://example.com/> 
select (count (?s) as ?count)
from :g1
from :g2
where {?s :p/:p/:p ?o}
EOF

echo "test * traversal from merged default graph" > $ECHO_OUTPUT
curl_sparql_request \
     --repository "${STORE_REPOSITORY}-write" \
     -H "Content-Type: application/sparql-query" \
     -H "Accept: application/sparql-results+json" <<EOF \
   | tee $ECHO_OUTPUT | jq '.results.bindings[] | .count | .value' | tr -s '\n' ',' | fgrep -q '"3","2","1"'
prefix : <http://example.com/> 
select ?s (count(?s) as ?count)
from :g1
from :g2
where {?s :p* ?o}
group by ?s
order by ?s
EOF

echo "test + traversal from merged default graph" > $ECHO_OUTPUT
curl_sparql_request \
     --repository "${STORE_REPOSITORY}-write" \
     -H "Content-Type: application/sparql-query" \
     -H "Accept: application/sparql-results+json" <<EOF \
   | tee $ECHO_OUTPUT | jq '.results.bindings[] | .count | .value' | tr -s '\n' ',' | fgrep -q '"2","1"'
prefix    : <http://example.com/> 
select ?s (count(?s) as ?count)
from :g1
from :g2
where {?s :p+ ?o}
group by ?s
order by ?s
EOF


