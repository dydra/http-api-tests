#! /bin/bash
# test kleene-star paths across and within graphs

echo "# test kleene-star paths across and within graphs" > $ECHO_OUTPUT

curl_graph_store_update -X PUT -o /dev/null \
      -H "Content-Type: application/n-quads" \
      --repository "${STORE_REPOSITORY}-write" <<EOF
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

echo "test ex:kleene-predicate+ multi-graph dataset from constant subject" > $ECHO_OUTPUT
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

echo "test ex:kleene-predicate+ multi-graph graph form from constant subject" > $ECHO_OUTPUT
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

echo "test ex:kleene-predicate+ single graph form from constant subject" > $ECHO_OUTPUT
curl_sparql_request \
 --repository "${STORE_REPOSITORY}-write" \
 --account "test" \
 -H "Content-Type: application/sparql-query" \
 -H "Accept: application/sparql-results+json" <<EOF \
 | tee $ECHO_OUTPUT | egrep -c '/node(1|2|3)' | fgrep -q 1
prefix ex: <http://example.com/>
select * # count(*)
where {
  graph <http://example.org/node1> {
    <http://example.org/node1> ex:kleene-predicate+ ?Leaf .
  }
}
EOF

echo "test ex:kleene-predicate+ single graph form from constant subject in service clause" > $ECHO_OUTPUT
curl_sparql_request \
 --repository "${STORE_REPOSITORY}-write" \
 --account "test" \
 -H "Content-Type: application/sparql-query" \
 -H "Accept: application/sparql-results+json" <<EOF \
 | tee $ECHO_OUTPUT | egrep -c '/node(1|2|3)' | fgrep -q 1
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

echo "test ex:kleene-predicate+ all graph form from constant subject in service clause" > $ECHO_OUTPUT
curl_sparql_request \
 --repository "${STORE_REPOSITORY}-write" \
 --account "test" \
 -H "Content-Type: application/sparql-query" \
 -H "Accept: application/sparql-results+json" <<EOF \
 | tee $ECHO_OUTPUT | egrep -c '/node(1|2|3)' | fgrep -q 2
prefix ex: <http://example.com/>
select * # count(*)
where {
  service <http://localhost/test/${STORE_REPOSITORY}-write> {
    graph <urn:dydra:all> {
      <http://example.org/node1> ex:kleene-predicate+ ?Leaf .
    }
  }
}
EOF

echo "test ex:kleene-predicate+ all graph multiple patterns form from variable subject in service clause" > $ECHO_OUTPUT
curl_sparql_request '$name=%22kleene%20leaf%201%22' \
 --repository "${STORE_REPOSITORY}-write" \
 --account "test" \
 -H "Content-Type: application/sparql-query" \
 -H "Accept: application/sparql-results+json" <<EOF \
 | tee $ECHO_OUTPUT | egrep -c '/node(1|2|3)' | fgrep -q 4
prefix ex: <http://example.com/>
select * # count(*)
where {
  service <http://localhost/test/${STORE_REPOSITORY}-write> {
    graph <urn:dydra:all> {
      ?node ex:kleene-name ?name .
      ?node ex:kleene-predicate+ ?Leaf .
    }
  }
}
EOF

echo "import 4-node dataset" > $ECHO_OUTPUT
curl_graph_store_update -X PUT -o /dev/null \
      -H "Content-Type: application/n-quads" \
      --repository "${STORE_REPOSITORY}-write" <<EOF
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

echo "test ex:kleene-predicate+ default graph form from variable subject in service clause" > $ECHO_OUTPUT
curl_sparql_request \
 --repository "${STORE_REPOSITORY}-write" \
 --account "test" \
 -H "Content-Type: application/sparql-query" \
 -H "Accept: application/sparql-results+json" <<EOF \
 | tee $ECHO_OUTPUT | egrep -c '/node(1|2|3)' | fgrep -q 4
prefix ex: <http://example.com/>
select * # count(*)
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
 -H "Accept: application/sparql-results+json" <<EOF \
 | tee $ECHO_OUTPUT | egrep -c '/node(1|2|3)' | fgrep -q 6
prefix ex: <http://example.com/>
select * # count(*)
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
 -H "Accept: application/sparql-results+json" <<EOF \
 | tee $ECHO_OUTPUT | egrep -c '/node(1|2|3)' | fgrep -q 20
prefix ex: <http://example.com/>
select * # count(*)
where {
  service <http://localhost/test/${STORE_REPOSITORY}-write> {
    graph <urn:dydra:all> {
      ?node ex:kleene-name ?name .
      ?node ex:kleene-predicate+ ?Leaf .
    }
  }
}
EOF

echo "test ex:kleene-predicate+ no graph form from variable subject in service clause" > $ECHO_OUTPUT
curl_sparql_request \
 --repository "${STORE_REPOSITORY}-write" \
 --account "test" \
 -H "Content-Type: application/sparql-query" \
 -H "Accept: application/sparql-results+json" <<EOF \
 | tee $ECHO_OUTPUT | egrep -c '/node(1|2|3)' | fgrep -q 4
prefix ex: <http://example.com/>
select * # count(*)
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
 -H "Accept: application/sparql-results+json" <<EOF \
 | tee $ECHO_OUTPUT | egrep -c '/node(1|2|3)' | fgrep -q 2
prefix ex: <http://example.com/>
select * # count(*)
where {
  graph <http://example.org/node1> {
    ?node ex:kleene-name ?name .
    ?node ex:kleene-predicate+ ?Leaf .
  }
}
EOF
