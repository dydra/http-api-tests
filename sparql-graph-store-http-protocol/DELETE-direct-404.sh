#! /bin/bash

# test that a non-existent repository yields a 404

set_graph_store_url "${STORE_ACCOUNT}" "${STORE_REPOSITORY}-write-not"
curl_graph_store_delete \
   | test_not_found_success

