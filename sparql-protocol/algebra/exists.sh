#! /bin/bash
# test exists implementation in combinations beyond w3c dawg

#
curl_graph_store_update -X PUT \
      -H "Content-Type: application/n-quads" \
      --repository "${STORE_REPOSITORY}-write" <<EOF
<http://example.com/s1> <http://example.com/p> "first" .
<http://example.com/s1> <http://example.com/q> "first" .
<http://example.com/s1> <http://example.com/r> "first" .
<http://example.com/s2> <http://example.com/p> "first" .
<http://example.com/s2> <http://example.com/p> "second" .
<http://example.com/s2> <http://example.com/p> "third" .
<http://example.com/s3> <http://example.com/p> "first" .
<http://example.com/s3> <http://example.com/q> "second" .
<http://example.com/s3> <http://example.com/r> "third" .
EOF


# simple exist constraint implemented as bgp sip
curl_sparql_request \
     --repository "${STORE_REPOSITORY}-write" \
     -H "Content-Type: application/sparql-query" \
     -H "Accept: application/sparql-results+json" <<EOF \
   | jq '.results.bindings[] | .[].value' | fgrep -q 'third' 
prefix    : <http://example.com/> 
select ?o
where {
  ?s1 :p ?o .
  filter not exists { ?s2 :q ?o }
}
EOF

# where the filter references variables not in the bgp, the
# implementation will be a sub-ask
curl_sparql_request \
     --repository "${STORE_REPOSITORY}-write" \
     -H "Content-Type: application/sparql-query" \
     -H "Accept: application/sparql-results+json" <<EOF \
   | jq '.results.bindings[] | .[].value' | fgrep -q 'third' 
prefix    : <http://example.com/> 
select ?o
where {
  ?s1 :p ?o .
  filter not exists { ?s2 :q ?o2 . filter (?o = ?o2) }
}
EOF

#
# the exists pattern requires some tailoring in order to allow for the
# select aggragate's effect on the scope of the outer variables
curl_sparql_request \
     --repository "${STORE_REPOSITORY}-write" \
     -H "Content-Type: application/sparql-query" \
     -H "Accept: application/sparql-results+json" <<EOF \
   | jq '.results.bindings[] | .[].value' | wc | fgrep -q '2' 
prefix    : <http://example.com/> 
select ?s1
where {
  ?s1 :p ?o .
  filter not exists { 
    ?s1 :p ?o2 .
    { select ?s1 { ?s1 :p ?o2 } group by ?s1 having(count(?o2) > 1) }
  }
}

EOF

curl_sparql_request \
     --repository "${STORE_REPOSITORY}-write" \
     -H "Content-Type: application/sparql-query" \
     -H "Accept: application/sparql-results+json" <<EOF \
   | jq '.results.bindings[] | .[].value' | fgrep -q 's2' 
prefix    : <http://example.com/> 
select ?s1 { ?s1 :p ?o2 } group by ?s1 having(count(?o2) > 1)

EOF

