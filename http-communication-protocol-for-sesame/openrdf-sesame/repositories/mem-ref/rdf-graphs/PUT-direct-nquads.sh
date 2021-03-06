#! /bin/bash

# the protocol target is a direct graph, which is not present in the repository, the content is n-quads:
# - triples are added to the _default_ graph.
# - quads are added to the document graph.
# - statements would be removed from the target graph only, but there are none
# that is, the effect is the same as for POST

curl -w "%{http_code}\n" -f -s -S -X PUT \
     -H "Content-Type: application/n-quads" \
     --data-binary @- \
     ${STORE_URL}/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}/rdf-graphs/sesame?auth_token=${STORE_TOKEN} <<EOF \
   | grep_put_success
<http://example.com/default-subject> <http://example.com/default-predicate> "default object PUT1" .
<http://example.com/named-subject> <http://example.com/named-predicate> "named object PUT1" <${STORE_NAMED_GRAPH}-two> .
EOF


curl -f -s -S -X GET\
     -H "Accept: application/n-quads" \
     ${STORE_URL}/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}/statements?auth_token=${STORE_TOKEN} \
   | tr -s '\n' '\t' \
   | fgrep '"default object"' | fgrep '"named object"' | fgrep  "<${STORE_NAMED_GRAPH}>" \
   | fgrep '"default object PUT1"' | fgrep '"named object PUT1"' | fgrep  "<${STORE_NAMED_GRAPH}-two>" \
   | tr -s '\t' '\n' | wc -l | fgrep -q 4


curl -w "%{http_code}\n" -f -s -S -X PUT \
     -H "Content-Type: application/n-quads" \
     --data-binary @- \
     ${STORE_URL}/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}/rdf-graphs/sesame?auth_token=${STORE_TOKEN} <<EOF \
   | grep_put_success
<http://example.com/default-subject> <http://example.com/default-predicate> "default object PUT2" .
<http://example.com/named-subject> <http://example.com/named-predicate> "named object PUT2" <${STORE_NAMED_GRAPH}-two> .
EOF


curl -f -s -S -X GET\
     -H "Accept: application/n-quads" \
     ${STORE_URL}/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}/statements?auth_token=${STORE_TOKEN} \
   | tr -s '\n' '\t' \
   | fgrep '"default object"' | fgrep '"named object"' | fgrep  "<${STORE_NAMED_GRAPH}>" \
   | fgrep '"default object PUT1"' | fgrep '"named object PUT1"' \
   | fgrep '"default object PUT2"' | fgrep '"named object PUT2"' | fgrep  "<${STORE_NAMED_GRAPH}-two>" \
   | tr -s '\t' '\n' | wc -l | fgrep -q 6

initialize_repository | grep_put_success
