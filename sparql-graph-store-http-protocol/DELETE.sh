#! /bin/bash

# test that delete leaves an empty repository
initialize_repository --repository "${STORE_REPOSITORY}-write"

curl_graph_store_delete --repository "${STORE_REPOSITORY}-write" graph=

curl_graph_store_get -w "%{http_code}\n" --repository "${STORE_REPOSITORY}-write" graph= \
   | test_not_found_success
