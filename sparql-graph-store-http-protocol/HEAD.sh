#! /bin/bash


curl_graph_store_get -w "%{http_code}\n" --head \
   | test_ok

