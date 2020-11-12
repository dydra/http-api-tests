#! /bin/bash

# test that delete with a graph removes just that content and leaves the default graph intact

initialize_repository --repository "${STORE_REPOSITORY}-write"

# -o /tmp/gsp.ttl
curl_graph_store_delete "graph=${STORE_NAMED_GRAPH}" -o /dev/null --repository "${STORE_REPOSITORY}-write"

curl_graph_store_get  --repository "${STORE_REPOSITORY}-write" \
   | tr -s '\n' '\t' \
   | fgrep '"default object"' | fgrep -q -v '"named object"' 

