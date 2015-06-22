#! /bin/bash

# test that a non-existent repository yields a 404

curl_graph_store_delete  -w "%{http_code}\n" --repository "${STORE_REPOSITORY}-write-not" \
   | test_not_found_success

