#! /bin/bash

# test that a non-existent repository yields a 404

curl_graph_store_delete --repository  "${STORE_REPOSITORY}-not" \
     -w "%{http_code}\n" \
   | test_not_found_success

