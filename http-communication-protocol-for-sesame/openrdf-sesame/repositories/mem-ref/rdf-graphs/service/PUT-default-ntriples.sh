#! /bin/bash

# the protocol target the default graph, the statements include quads and the content type is n-triples:
# - triples are added to the protocol (default) graph.
# - quads are added to the protocol (default) graph.
# - statements are removed from the default graph

curl -w "%{http_code}\n" -f -s -S -X PUT \
     -H "Content-Type: application/n-triples" \
     --data-binary @- \
     ${STORE_URL}/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}/rdf-graphs/service?default\&auth_token=${STORE_TOKEN} <<EOF \
  | egrep -q "${PUT_SUCCESS}"
<http://example.com/default-subject> <http://example.com/default-predicate> "default object PUT1" .
<http://example.com/named-subject> <http://example.com/named-predicate> "named object PUT1" <${STORE_NAMED_GRAPH}-two> .
EOF

# should replace the default and either add two there or one plus a new graph
curl -f -s -S -X GET\
     -H "Accept: application/n-quads" \
     ${STORE_URL}/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}/statements?auth_token=${STORE_TOKEN} \
   | tr -s '\n' '\t' \
   | fgrep -v '"default object"' | fgrep '"named object"' | fgrep "<${STORE_NAMED_GRAPH}>" \
   | fgrep '"default object PUT1"' | fgrep '"named object PUT1"' \
   | if ($QUAD_DISPOSITION_BY_REQUEST) then fgrep -v "<${STORE_NAMED_GRAPH}-two>"; else fgrep "<${STORE_NAMED_GRAPH}-two>"; fi \
   | tr -s '\t' '\n' | wc -l | fgrep -q 3


curl -w "%{http_code}\n" -f -s -S -X PUT \
     -H "Content-Type: application/n-triples" \
     --data-binary @- \
     ${STORE_URL}/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}/rdf-graphs/service?default\&auth_token=${STORE_TOKEN} <<EOF \
  | egrep -q "${PUT_SUCCESS}"
<http://example.com/default-subject> <http://example.com/default-predicate> "default object PUT2" .
<http://example.com/named-subject> <http://example.com/named-predicate> "named object PUT2" <${STORE_NAMED_GRAPH}-two> .
EOF

# should replace the default and either add two there or one plus a new graph - with the addition above still present
curl -f -s -S -X GET\
     -H "Accept: application/n-quads" \
     ${STORE_URL}/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}/statements?auth_token=${STORE_TOKEN} \
   | tr -s '\n' '\t' \
   | fgrep -v '"default object"' | fgrep '"named object"' | fgrep "<${STORE_NAMED_GRAPH}>" \
   | fgrep '"default object PUT2"' | fgrep '"named object PUT2"' \
   | if ($QUAD_DISPOSITION_BY_REQUEST) then fgrep -v "<${STORE_NAMED_GRAPH}-two>"; else fgrep "<${STORE_NAMED_GRAPH}-two>"; fi \
   | tr -s '\t' '\n' | wc -l \
   | if ($QUAD_DISPOSITION_BY_REQUEST) then fgrep -q 3; else fgrep -q 4; fi


initialize_repository | egrep -q "${PUT_SUCCESS}"
