#! /bin/bash


curl_graph_store_get -w "%{http_code}\n" --head graph= \
   | test_ok_success

