#! /bin/bash


curl_graph_store_get -w "%{http_code}\n" --head \
     --repository "${STORE_REPOSITORY}-not" \
   | test_not_found
