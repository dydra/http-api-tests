#! /bin/bash

# the protocol target is a the repository, the statements include quads and the content type is n-triples:
# - triples are added to the default graph.
# - quads are added to the document graph. ?
# - each operation first clears the repository

initialize_repository --repository "${STORE_REPOSITORY}-write"

curl_graph_store_update -X PUT -o /dev/null \
     -H "Content-Type: text/turtle" \
     --repository "${STORE_REPOSITORY}-write" <<EOF
<http://example.com/default-subject>
    <http://example.com/default-predicate> "default object PUT1" .
EOF


curl_graph_store_get \
     --repository "${STORE_REPOSITORY}-write" \
   | tr -s '\n' '\t' \
   | fgrep -v '"default object"' | fgrep -v '"named object"' | fgrep -v "<${STORE_NAMED_GRAPH}>" \
   | fgrep '"default object PUT1"' \
   | tr -s '\t' '\n' | wc -l | fgrep -q 1

