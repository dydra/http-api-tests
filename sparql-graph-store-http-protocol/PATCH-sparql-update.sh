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
     --repository "${STORE_REPOSITORY}-write" default <<EOF  \
   | test_unsupported_media
PREFIX     : <http://example.org/> 
INSERT { GRAPH :g2 { ?s ?p 'r' } } WHERE { ?s ?p ?o }
EOF
