#! /bin/bash

# test that a non-existent named graph yields a 404

initialize_repository  --repository "${STORE_REPOSITORY}-write"

curl_graph_store_delete  -w "%{http_code}\n" --repository "${STORE_REPOSITORY}-write" "graph=${STORE_NAMED_GRAPH}-not" \
  | test_not_found_success
