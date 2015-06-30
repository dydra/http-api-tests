#! /bin/bash

# test pragma to specify describe traversal properties

curl_graph_store_update -X PUT \
      -H "Content-Type: application/turtle" \
      --repository "${STORE_REPOSITORY}-write" default <<EOF
@prefix ex: <http://example.com/> .

ex:subject1 ex:p1 "depth 0" .
ex:subject1 ex:p2 ex:subject2 .
ex:subject1 ex:p3 _:blank .
ex:subject2 ex:p4 "depth 1 by uri" . 
_:blank ex:p5 "depth 1 by blank node" . 
EOF

curl_sparql_request  --repository "${STORE_REPOSITORY}-write" <<EOF \
 | jq '.results.bindings[] | .[].value' \
 | fgrep "\"depth 0\"" \
 | fgrep "\"depth 1 by uri\"" | fgrep -q "\"depth 1 by blank node\""

PREFIX DescribeProperties: <urn:dydra:true> 
DESCRIBE <http://example.com/subject>
EOF

curl_sparql_request  --repository "${STORE_REPOSITORY}-write" <<EOF \
 | jq '.results.bindings[] | .[].value' \
 | fgrep "\"depth 0\"" \
 | fgrep -v "\"depth 1 by uri\"" | fgrep -q "\"depth 1 by blank node\""

PREFIX DescribeProperties: <urn:dydra:false> 
DESCRIBE <http://example.com/subject>
EOF

