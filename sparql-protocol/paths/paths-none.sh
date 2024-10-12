#! /bin/bash
# test path queries which specify no graphs, leaving the default dataset in place
# see the paths README

echo "test path queries which specify no graphs, leaving the default dataset in place" > $ECHO_OUTPUT


curl_graph_store_update -X PUT -o /dev/null \
      -H "Content-Type: application/n-quads" \
      --repository "${STORE_REPOSITORY}-write" <<EOF
<http://example.com/s1> <http://example.com/p> <http://example.com/s2> .
<http://example.com/s2> <http://example.com/p> <http://example.com/s3> <http://example.com/g1> .
<http://example.com/s3> <http://example.com/p> <http://example.com/s4> <http://example.com/g2> .
<http://example.com/s4> <http://example.com/p> <http://example.com/s5> <http://example.com/g3> .
EOF


# simple enumeration of all statements merged into the default graph
# should yield no result, as no named graph is in the dataset
curl_sparql_request \
     --repository "${STORE_REPOSITORY}-write" \
     -H "Content-Type: application/sparql-query" \
     -H "Accept: application/sparql-results+json" <<EOF \
   | jq '.results.bindings[] | .[].value' | fgrep -q '"1"'
prefix    : <http://example.com/> 
select (count (?o) as ?count)
where {?s :p ?o}
EOF

# should yield all present paths, as all graphs are in the datasset
curl_sparql_request \
     --repository "${STORE_REPOSITORY}-write" \
     -H "Content-Type: application/sparql-query" \
     -H "Accept: application/sparql-results+json" <<EOF \
   | jq '.results.bindings[] | .[].value' | fgrep -q '"3"'
prefix : <http://example.com/>
select (count (?o) as ?count)
where {graph ?g {?s :p ?o} }
EOF

# simple elementary path in either direction in a _named_ graph
curl_sparql_request \
     --repository "${STORE_REPOSITORY}-write" \
     -H "Content-Type: application/sparql-query" \
     -H "Accept: application/sparql-results+json" <<EOF \
   | jq '.results.bindings[] | .[].value' | fgrep -q '"3"'
prefix    : <http://example.com/> 
select (count (?o) as ?count)
where {
  { <http://example.com/s1> :p ?o . }
  union
  { graph ?g { 
    { <http://example.com/s2> :p ?o . }
    union
    { <http://example.com/s3> :p ?o . }
    }
  }
}
EOF

curl_sparql_request \
     --repository "${STORE_REPOSITORY}-write" \
     -H "Content-Type: application/sparql-query" \
     -H "Accept: application/sparql-results+json" <<EOF \
   | jq '.results.bindings[] | .[].value' | fgrep -q '"3"'
prefix    : <http://example.com/> 
select (count (?s) as ?count)
where { 
  { ?s :p <http://example.com/s2> . }
  union
  { graph ?g { 
    { ?s :p <http://example.com/s3> . }
    union
    { ?s :p <http://example.com/s4> . }
    }
  }
}
EOF


curl_sparql_request \
     --repository "${STORE_REPOSITORY}-write" \
     -H "Content-Type: application/sparql-query" \
     -H "Accept: application/sparql-results+json" <<EOF \
   | jq '.results.bindings[] | .[].value' | fgrep -q '"0"'
prefix    : <http://example.com/> 
select (count (*) as ?count)
where { 
 graph ?g { 
  { <http://example.com/s2> :p/:p ?o . }
  union
  { ?s :p/:p <http://example.com/s4> . }
 }
}
EOF


# no such path among the named graphs given "from named"
curl_sparql_request \
     --repository "${STORE_REPOSITORY}-write" \
     -H "Content-Type: application/sparql-query" \
     -H "Accept: application/sparql-results+json" <<EOF \
   | jq '.results.bindings[] | .[].value' | fgrep -q '"0"'
prefix    : <http://example.com/> 
select (count (?s) as ?count)
where { graph ?g {?s :p/:p ?o} }
EOF

curl_sparql_request \
     --repository "${STORE_REPOSITORY}-write" \
     -H "Content-Type: application/sparql-query" \
     -H "Accept: application/sparql-results+json" <<EOF \
   | jq '.results.bindings[] | .[].value' | fgrep -q '"0"'
prefix    : <http://example.com/> 
select (count (?s) as ?count)
where { graph ?g { ?s :p/:p/:p ?o} }
EOF

# no such path within the three graphs
curl_sparql_request \
     --repository "${STORE_REPOSITORY}-write" \
     -H "Content-Type: application/sparql-query" \
     -H "Accept: application/sparql-results+json" <<EOF \
   | jq '.results.bindings[] | .[].value' | fgrep -q '"0"'
prefix    : <http://example.com/> 
select (count (?s) as ?count)
where { graph ?g { ?s :p/:p/:p/:p ?o} }
EOF

# for the test dataset, nodes which appear as both subject and object inter-graph
# introduce a duplicate solution
echo "intergraph kleen paths yield 12 total results" > $ECHO_OUTPUT
curl_sparql_request \
     --repository "${STORE_REPOSITORY}-write" \
     -H "Content-Type: application/sparql-query" \
     -H "Accept: application/sparql-results+json" <<EOF \
   | jq '.results.bindings | length' | fgrep -q '12'
prefix : <http://example.com/> 
select ?s ?o
where { graph ?g {?s :p* ?o} }
EOF

echo "intergraph kleen paths yield 10 total results" > $ECHO_OUTPUT
curl_sparql_request \
     --repository "${STORE_REPOSITORY}-write" \
     -H "Content-Type: application/sparql-query" \
     -H "Accept: application/sparql-results+json" <<EOF \
   | jq '.results.bindings | length' | fgrep -q '10'
prefix : <http://example.com/> 
select distinct ?s ?o
where { graph ?g {?s :p* ?o} }
order by ?s
EOF


curl_sparql_request \
     --repository "${STORE_REPOSITORY}-write" \
     -H "Content-Type: application/sparql-query" \
     -H "Accept: application/sparql-results+json" <<EOF \
   | jq '.results.bindings | length' | fgrep -q '6'
prefix    : <http://example.com/> 
select ?s ?o
where { graph ?g {?s :p+ ?o} }
EOF


