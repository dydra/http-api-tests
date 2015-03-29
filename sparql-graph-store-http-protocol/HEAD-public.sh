#! /bin/bash


curl_graph_store_get \
     -w "%{http_code}\n" --head -u "" --repository "${STORE_REPOSITORY}-public" \
   | test_ok_success

