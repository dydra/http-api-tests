#! /bin/bash

# the request includes no graph, which means the protocol target coincides with the repository, 
# if the content type is n-quads:
# - each operation first clears the repository
# - triples are added to the default graph.
# - quads are added to the document graph.
# otherwise it fails

initialize_repository --repository "${STORE_REPOSITORY}-write"


curl_graph_store_update -X PATCH  -w "%{http_code}\n" \
   -H "Content-Type: application/sparql-update" \
   -H "Accept: application/sparql-results+json" \
   --repository "${STORE_REPOSITORY}-write" default <<EOF  \
   | test_ok
PREFIX     : <http://example.org/> 
INSERT { GRAPH :g2 { ?s ?p 'r' } } WHERE { ?s ?p ?o }
EOF

curl_graph_store_get \
     --repository "${STORE_REPOSITORY}-write"  \
   | tr -s '\n' '\t' \
   | fgrep '"default object"' | fgrep '"named object"' | fgrep "<${STORE_NAMED_GRAPH}>" \
   | fgrep '<http://example.org/g2> ' \
   | tr -s '\t' '\n' | wc -l | fgrep -q 3
