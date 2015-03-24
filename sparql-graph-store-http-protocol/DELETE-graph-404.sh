#! /bin/bash

# test that a non-existent named graph yields a 404

set_graph_store_url "${STORE_ACCOUNT}" "${STORE_REPOSITORY}-write"
initialize_repository | egrep -q "$STATUS_PUT_SUCCESS"

curl_graph_store_delete "graph=${STORE_NAMED_GRAPH}-not" \
  | test_not_found_success
