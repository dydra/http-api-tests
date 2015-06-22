#! /bin/bash

# test that improper authentication yields a 401


curl_graph_store_get -w "%{http_code}\n" -f -s --head \
     -u "" \
   | test_unauthorized_success
