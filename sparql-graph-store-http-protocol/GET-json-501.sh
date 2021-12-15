#! /bin/bash

curl_graph_store_get  -w "%{http_code}\n" -H "Accept: application/json" \
   | test_not_implemented

