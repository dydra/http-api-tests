#! /bin/bash


curl_graph_store_get -w "%{http_code}\n" --head \
     graph=${STORE_NAMED_GRAPH}-not \
   | test_not_found_success
