#! /bin/bash

# with the default silent setting, this responds with ok

curl_graph_store_get -w "%{http_code}\n" --head \
     graph=${STORE_NAMED_GRAPH}-not \
   | test_ok
