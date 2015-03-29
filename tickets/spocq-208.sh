#! /bin/bash
#
# test that a graph properly augments a subselect - including the case where the sub-form
# includes its own graph.

curl_graph_store_update -X PATCH \
     -H "Content-Type: application/n-quads" <<EOF
<http://subject1> <http://predicate1> <http://object1> <http://context1> .
<http://subject2> <http://predicate2> <http://subject1> <http://context2> .
<http://subject2> <http://predicate4> "something to bind ?graph" <http://context2> .
<http://subject3> <http://predicate3> <http://subject1> <http://context1> .
EOF

curl_sparql_request \
     --repository "${STORE_REPOSITORY}-write" \
     -H "Accept: application/sparql-results+json" <<EOF \
   | wc -l | fgrep -q 4
select * where { graph ?graph1 { ?subject1 ?predicate ?object1 } }
EOF


curl_sparql_request \
     --repository "${STORE_REPOSITORY}-write" \
     -H "Accept: application/sparql-results+xml" <<EOF \
   | fgrep -q 'http://subject2'
select *
WHERE {
  GRAPH ?graph1 {
        ?subject1 <http://predicate1> ?object1 .
        OPTIONAL {
          SELECT ?subject1 ?subject2
          WHERE {
            GRAPH ?graph2 { ?subject2 <http://predicate2> ?subject1 }
          }
        }
  }
}
EOF

curl_sparql_request \
     --repository "${STORE_REPOSITORY}-write" \
     -H "Accept: application/sparql-results+xml" <<EOF \
   | fgrep -q 'http://subject2'
select *
WHERE {
  GRAPH ?graph1 {
        ?subject1 <http://predicate1> ?object .
        OPTIONAL {
          SELECT ?subject1 ?subject2  # should limit the scope of ?graph1
          WHERE {
            GRAPH ?graph1 { ?subject2 <http://predicate2> ?subject1 }
          }
        }
  }
}
EOF

curl_sparql_request \
     --repository "${STORE_REPOSITORY}-write" \
     -H "Accept: application/sparql-results+xml" <<EOF \
   | fgrep -q 'http://subject2'
select *
WHERE {
  GRAPH ?graph1 {
        ?subject1 <http://predicate1> ?object .
        OPTIONAL {
          SELECT ?subject1 ?subject2  # should limit the scope of ?graph1
          WHERE {
            GRAPH ?graph2 { ?subject2 <http://predicate2> ?subject1 .
                            ?subject2 <http://predicate4> ?graph1 }  # binding should not conflict
          }
        }
  }
}
EOF

curl_sparql_request \
     --repository "${STORE_REPOSITORY}-write" \
     -H "Accept: application/sparql-results+xml"  <<EOF \
   | fgrep -v -q 'http://subject2'
select *
WHERE {
  GRAPH ?graph1 {
        ?subject1 <http://predicate1> ?object .
        OPTIONAL {
          SELECT *  # should extend the scope of ?graph1
          WHERE {
            GRAPH ?graph1 { ?subject2 <http://predicate2> ?subject1 }
          }
        }
  }
}
EOF

curl_sparql_request \
     --repository "${STORE_REPOSITORY}-write" \
     -H "Accept: application/sparql-results+xml" <<EOF \
   | fgrep -q 'http://subject3'
select *
WHERE {
  GRAPH ?graph1 {
        ?subject1 <http://predicate1> ?object .
        OPTIONAL {
          SELECT ?subject1 ?subject2
          WHERE {
            GRAPH ?graph1 { ?subject2 <http://predicate3> ?subject1 }
          }
        }
  }
}
EOF

curl_sparql_request \
     --repository "${STORE_REPOSITORY}-write" \
     -H "Accept: application/sparql-results+xml" <<EOF \
   | fgrep -q 'http://subject3'
select *
WHERE {
  GRAPH ?graph1 {
        ?subject1 <http://predicate1> ?object .
        OPTIONAL {
          SELECT ?subject1 ?subject2
          WHERE {
           ?subject2 <http://predicate3> ?subject1
          }
        }
  }
}
EOF

