#! /bin/bash
# test kleene-star paths across and within graphs

echo "# test kleene-star paths across and within graphs" > $ECHO_OUTPUT

echo "import 7-statement dataset" > $ECHO_OUTPUT
curl_graph_store_update -X PUT -o /dev/null \
      -H "Content-Type: application/n-quads" \
      --account "test" --repository "${STORE_REPOSITORY}-write" <<EOF
<http://example.org/node0> <http://example.com/kleene-name> "kleene leaf 0" .
<http://example.org/node1> <http://example.com/kleene-name> "kleene leaf 1" <http://example.org/node1> .
<http://example.org/node1> <http://example.com/kleene-predicate> <http://example.org/node2> <http://example.org/node1> .
<http://example.org/node2> <http://example.com/kleene-name> "kleene leaf 2" <http://example.org/node2> .
<http://example.org/node2> <http://example.com/kleene-predicate> <http://example.org/node3> <http://example.org/node2> .
<http://example.org/node3> <http://example.com/kleene-name> "kleene leaf 3" <http://example.org/node3> .
<http://example.org/node4> <http://example.com/kleene-name> "kleene leaf 4" <http://example.org/node4> .
EOF

curl_graph_store_get --repository "${STORE_REPOSITORY}-write" --account "test" \
  | wc | fgrep -q 7

curl_sparql_request \
 --repository "${STORE_REPOSITORY}-write" \
 --account "test" \
 -H "Content-Type: application/sparql-query" \
 -H "Accept: text/csv" <<EOF \
 | tee $ECHO_OUTPUT | tail -n +2 | wc | fgrep -q 2
select ?s ?p ?o ?g
where {
  { graph ?g { ?s ?p ?o} }
  union
  { ?s ?p ?o }
  filter (datatype(?o) != xsd:string)
}
order by ?s
EOF



echo "test ex:kleene-predicate+" > $ECHO_OUTPUT
curl_sparql_request \
 --repository "${STORE_REPOSITORY}-write" \
 --account "test" \
 -H "Content-Type: application/sparql-query" \
 -H "Accept: application/sparql-results+json" <<EOF \
 | tee $ECHO_OUTPUT | fgrep -c '"node":' | fgrep -q 3
prefix ex: <http://example.com/>
select * # count(*)
from  <urn:dydra:all>
where {
  ?node ex:kleene-predicate+ ?Leaf .
}
EOF

echo "test ex:kleene-predicate+ w/ second variable pattern" > $ECHO_OUTPUT
curl_sparql_request\
 --repository "${STORE_REPOSITORY}-write" \
 --account "test" \
 -H "Content-Type: application/sparql-query" \
 -H "Accept: application/sparql-results+json" <<EOF \
 | tee $ECHO_OUTPUT | fgrep -c '"node":' | fgrep -q 3
prefix ex: <http://example.com/>
select * # count(*)
from  <urn:dydra:all>
where {
  ?node ex:kleene-name ?name .
  ?node ex:kleene-predicate+ ?Leaf .
}
EOF

# (url-decode "%229353%20608%2098178%22")

echo "test ex:kleene-predicate+ w/ second constant pattern" > $ECHO_OUTPUT
curl_sparql_request \
 --repository "${STORE_REPOSITORY}-write" \
 --account "test" \
 -H "Content-Type: application/sparql-query" \
 -H "Accept: application/sparql-results+json" <<EOF \
 | tee $ECHO_OUTPUT | egrep -c '/node(1|2|3)' | fgrep -q 4
prefix ex: <http://example.com/>
select * # count(*)
from  <urn:dydra:all>
where {
  ?node ex:kleene-name 'kleene leaf 1' .
  ?node ex:kleene-predicate+ ?Leaf .
}
EOF


curl_sparql_request '$name=%22kleene%20leaf%201%22' \
 --repository "${STORE_REPOSITORY}-write" \
 --account "test" \
 -H "Content-Type: application/sparql-query" \
 -H "Accept: application/sparql-results+json" <<EOF \
 | tee $ECHO_OUTPUT | egrep -c '/node(1|2|3)' | fgrep -q 4
prefix ex: <http://example.com/>
select * # count(*)
from  <urn:dydra:all>
where {
  ?node ex:kleene-name ?name .
  ?node ex:kleene-predicate+ ?Leaf .
}
EOF

echo "test ex:kleene-predicate+ across graphs" > $ECHO_OUTPUT
curl_sparql_request '$node=%3chttp%3a%2f%2fexample.org%2fnode1%3e' \
 --repository "${STORE_REPOSITORY}-write" \
 --account "test" \
 -H "Content-Type: application/sparql-query" \
 -H "Accept: application/sparql-results+json" <<EOF \
 | tee $ECHO_OUTPUT | egrep -c '/node(1|2|3)' | fgrep -q 4
prefix ex: <http://example.com/>
select * # count(*)
from  <urn:dydra:all>
where {
  ?node ex:kleene-name ?name .
  ?node ex:kleene-predicate+ ?Leaf .
}
EOF

echo "test ex:kleene-predicate+ multi-graph dataset from constant subject, with all graphs in dataset, graph clause, or service clause" > $ECHO_OUTPUT
curl_sparql_request \
 --repository "${STORE_REPOSITORY}-write" \
 --account "test" \
 -H "Content-Type: application/sparql-query" \
 -H "Accept: application/sparql-results+json" <<EOF \
 | tee $ECHO_OUTPUT | egrep -c '/node(1|2|3)' | fgrep -q 2
prefix ex: <http://example.com/>
select * # count(*)
from  <urn:dydra:all>
where {
  <http://example.org/node1> ex:kleene-predicate+ ?Leaf .
}
EOF

curl_sparql_request \
 --repository "${STORE_REPOSITORY}-write" \
 --account "test" \
 -H "Content-Type: application/sparql-query" \
 -H "Accept: application/sparql-results+json" <<EOF \
 | tee $ECHO_OUTPUT | egrep -c '/node(1|2|3)' | fgrep -q 2
prefix ex: <http://example.com/>
select * # count(*)
where {
  graph <urn:dydra:all> {
    <http://example.org/node1> ex:kleene-predicate+ ?Leaf .
  }
}
EOF

curl_sparql_request \
 --repository "${STORE_REPOSITORY}-write" \
 --account "test" \
 -H "Content-Type: application/sparql-query" \
 -H "Accept: text/csv" <<EOF \
 | tee $ECHO_OUTPUT | tail -n +2 | wc | fgrep -q 2
prefix ex: <http://example.com/>
select *
where {
  service <http://localhost/test/${STORE_REPOSITORY}-write> {
    graph <urn:dydra:all> {
      <http://example.org/node1> ex:kleene-predicate+ ?Leaf .
    }
  }
}
EOF


echo "test ex:kleene-predicate+ single graph dataset from constant subject, with graph in dataset, graph clause, or service clause" > $ECHO_OUTPUT
curl_sparql_request \
 --repository "${STORE_REPOSITORY}-write" \
 --account "test" \
 -H "Content-Type: application/sparql-query" \
 -H "Accept: text/csv" <<EOF \
 | tee $ECHO_OUTPUT | tail -n +2 | wc | fgrep -q 1
prefix ex: <http://example.com/>
select * # count(*)
from  <http://example.org/node1>
where {
  <http://example.org/node1> ex:kleene-predicate+ ?Leaf .
}
EOF

curl_sparql_request \
 --repository "${STORE_REPOSITORY}-write" \
 --account "test" \
 -H "Content-Type: application/sparql-query" \
 -H "Accept: text/csv" <<EOF \
 | tee $ECHO_OUTPUT | tail -n +2 | wc | fgrep -q 1
prefix ex: <http://example.com/>
select * # count(*)
where {
  graph <http://example.org/node1> {
    <http://example.org/node1> ex:kleene-predicate+ ?Leaf .
  }
}
EOF

curl_sparql_request \
 --repository "${STORE_REPOSITORY}-write" \
 --account "test" \
 -H "Content-Type: application/sparql-query" \
 -H "Accept: text/csv" <<EOF \
 | tee $ECHO_OUTPUT | tail -n +2 | wc | fgrep -q 1
prefix ex: <http://example.com/>
select * # count(*)
where {
  service <http://localhost/test/${STORE_REPOSITORY}-write> {
    graph <http://example.org/node1> {
      <http://example.org/node1> ex:kleene-predicate+ ?Leaf .
    }
  }
}
EOF


echo "test ex:kleene-predicate+, multiple pattern bgp, variable subject, variable objects, with all graphs in dataset, graph clause, or service clause" > $ECHO_OUTPUT

curl_sparql_request \
 --repository "${STORE_REPOSITORY}-write" \
 --account "test" \
 -H "Content-Type: application/sparql-query" \
 -H "Accept: text/csv" <<EOF \
 | tee $ECHO_OUTPUT | tail -n +2 | wc | fgrep -q 3
prefix ex: <http://example.com/>
select ?node ?name ?Leaf
from <urn:dydra:all> 
where {
  ?node ex:kleene-name ?name .
  ?node ex:kleene-predicate+ ?Leaf
}
order by ?node
EOF

curl_sparql_request \
 --repository "${STORE_REPOSITORY}-write" \
 --account "test" \
 -H "Content-Type: application/sparql-query" \
 -H "Accept: text/csv" <<EOF \
 | tee $ECHO_OUTPUT | tail -n +2 | wc | fgrep -q 3
prefix ex: <http://example.com/>
select ?node ?name ?Leaf
where {
  graph <urn:dydra:all> {
    ?node ex:kleene-name ?name .
    ?node ex:kleene-predicate+ ?Leaf .
  }
}
EOF

curl_sparql_request \
 --repository "${STORE_REPOSITORY}-write" \
 --account "test" \
 -H "Content-Type: application/sparql-query" \
 -H "Accept: text/csv" <<EOF \
 | tee $ECHO_OUTPUT | tail -n +2 | wc | fgrep -q 3
prefix ex: <http://example.com/>
select ?node ?name ?Leaf
where {
  service <http://localhost/test/${STORE_REPOSITORY}-write> {
    graph <urn:dydra:all> {
      ?node ex:kleene-name ?name .
      ?node ex:kleene-predicate+ ?Leaf .
    }
  }
}
EOF


echo "test ex:kleene-predicate+, multiple pattern bgp, variable subject, constant name parameter, all graphs in dataset, clause, or service clause" > $ECHO_OUTPUT

curl_sparql_request '$name=%22kleene%20leaf%201%22' \
 --repository "${STORE_REPOSITORY}-write" \
 --account "test" \
 -H "Content-Type: application/sparql-query" \
 -H "Accept: text/csv" <<EOF \
 | tee $ECHO_OUTPUT | tail -n +2 | wc | fgrep -q 2
prefix ex: <http://example.com/>
select ?node ?name ?Leaf
from <urn:dydra:all> 
where {
  ?node ex:kleene-name ?name .
  ?node ex:kleene-predicate+ ?Leaf
}
EOF

curl_sparql_request '$name=%22kleene%20leaf%201%22' \
 --repository "${STORE_REPOSITORY}-write" \
 --account "test" \
 -H "Content-Type: application/sparql-query" \
 -H "Accept: text/csv" <<EOF \
 | tee $ECHO_OUTPUT | tail -n +2 | wc | fgrep -q 2
prefix ex: <http://example.com/>
select ?node ?name ?Leaf
where {
  graph <urn:dydra:all> {
    ?node ex:kleene-name ?name .
    ?node ex:kleene-predicate+ ?Leaf .
  }
}
EOF

curl_sparql_request '$name=%22kleene%20leaf%201%22' \
 --repository "${STORE_REPOSITORY}-write" \
 --account "test" \
 -H "Content-Type: application/sparql-query" \
 -H "Accept: text/csv" <<EOF \
 | tee $ECHO_OUTPUT | tail -n +2 | wc | fgrep -q 1
prefix ex: <http://example.com/>
select ?node ?name ?Leaf
where {
  service <http://localhost/test/${STORE_REPOSITORY}-write> {
    graph <urn:dydra:all> {
      ?node ex:kleene-name ?name .
      ?node ex:kleene-predicate+ ?Leaf .
    }
  }
}
EOF



echo "import 11-statement dataset" > $ECHO_OUTPUT
curl_graph_store_update -X PUT -o /dev/null \
      -H "Content-Type: application/n-quads" \
      --account "test" --repository "${STORE_REPOSITORY}-write" <<EOF
<http://example.org/node0> <http://example.com/kleene-name> "default node 0" .
<http://example.org/node0> <http://example.com/kleene-predicate> <http://example.org/node1> .
<http://example.org/node1> <http://example.com/kleene-name> "default node 1" .
<http://example.org/node1> <http://example.com/kleene-predicate> <http://example.org/node2> .
<http://example.org/node2> <http://example.com/kleene-name> "default node 2" .
<http://example.org/node1> <http://example.com/kleene-name> "graph node 1" <http://example.org/node1> .
<http://example.org/node1> <http://example.com/kleene-predicate> <http://example.org/node2> <http://example.org/node1> .
<http://example.org/node2> <http://example.com/kleene-name> "graph node 2" <http://example.org/node2> .
<http://example.org/node2> <http://example.com/kleene-predicate> <http://example.org/node3> <http://example.org/node2> .
<http://example.org/node3> <http://example.com/kleene-name> "graph node 3" <http://example.org/node3> .
<http://example.org/node4> <http://example.com/kleene-name> "graph node 4" <http://example.org/node4> .
EOF

curl_graph_store_get --repository "${STORE_REPOSITORY}-write" --account "test" \
  | wc | fgrep -q 11

echo "test ex:kleene-predicate+ default graph form from variable subject in service clause" > $ECHO_OUTPUT
curl_sparql_request \
 --repository "${STORE_REPOSITORY}-write" \
 --account "test" \
 -H "Content-Type: application/sparql-query" \
 -H "Accept: text/csv" <<EOF \
 | tee $ECHO_OUTPUT | tail -n +2 | wc | fgrep -q 3
prefix ex: <http://example.com/>
select ?node ?name ?Leaf
where {
  service <http://localhost/test/${STORE_REPOSITORY}-write> {
    graph <urn:dydra:default> {
      ?node ex:kleene-name ?name .
      ?node ex:kleene-predicate+ ?Leaf .
    }
  }
}
EOF

echo "test ex:kleene-predicate+ named graph form from variable subject in service clause" > $ECHO_OUTPUT
curl_sparql_request \
 --repository "${STORE_REPOSITORY}-write" \
 --account "test" \
 -H "Content-Type: application/sparql-query" \
 -H "Accept: text/csv" <<EOF \
 | tee $ECHO_OUTPUT | tail -n +2 | wc | fgrep -q 3
prefix ex: <http://example.com/>
select ?node ?name ?Leaf
where {
  service <http://localhost/test/${STORE_REPOSITORY}-write> {
    graph <urn:dydra:named> {
      ?node ex:kleene-name ?name .
      ?node ex:kleene-predicate+ ?Leaf .
    }
  }
}
EOF

echo "test ex:kleene-predicate+ all graph form from variable subject in service clause" > $ECHO_OUTPUT
curl_sparql_request \
 --repository "${STORE_REPOSITORY}-write" \
 --account "test" \
 -H "Content-Type: application/sparql-query" \
 -H "Accept: text/csv" <<EOF \
 | tee $ECHO_OUTPUT | tail -n +2 | wc | fgrep -q 15
prefix ex: <http://example.com/>
select ?node ?name ?Leaf
where {
  service <http://localhost/test/${STORE_REPOSITORY}-write> {
    graph <urn:dydra:all> {
      ?node ex:kleene-name ?name .
      ?node ex:kleene-predicate+ ?Leaf .
    }
  }
} order by ?node
EOF

echo "test ex:kleene-predicate+ no graph form from variable subject in service clause" > $ECHO_OUTPUT
curl_sparql_request \
 --repository "${STORE_REPOSITORY}-write" \
 --account "test" \
 -H "Content-Type: application/sparql-query" \
 -H "Accept: text/csv" <<EOF \
 | tee $ECHO_OUTPUT | tail -n +2 | wc | fgrep -q 3
prefix ex: <http://example.com/>
select * 
where {
  service <http://localhost/test/${STORE_REPOSITORY}-write> {
    ?node ex:kleene-name ?name .
    ?node ex:kleene-predicate+ ?Leaf .
  }
}
EOF

echo "test ex:kleene-predicate+ constant graph form from variable subject" > $ECHO_OUTPUT
curl_sparql_request \
 --repository "${STORE_REPOSITORY}-write" \
 --account "test" \
 -H "Content-Type: application/sparql-query" \
 -H "Accept: text/csv" <<EOF \
 | tee $ECHO_OUTPUT | tail -n +2 | wc | fgrep -q 1
prefix ex: <http://example.com/>
select *
where {
  graph <http://example.org/node1> {
    ?node ex:kleene-name ?name .
    ?node ex:kleene-predicate+ ?Leaf .
  }
}
EOF
