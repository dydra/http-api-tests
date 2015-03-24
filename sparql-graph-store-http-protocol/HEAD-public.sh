#! /bin/bash


curl_graph_store_get -w "%{http_code}\n" --head \
     --repository "${STORE_REPOSITORY_PUBLIC}" \
   | test_ok_success

