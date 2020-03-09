#! /bin/bash

# HEAD with a non-existent graph and the default silent setting, this responds with not_found
# ok requires a Silent  header

curl_graph_store_get --head -w "%{http_code}\n" \
     graph=${STORE_NAMED_GRAPH}-not \
   | test_not_found

curl_graph_store_get --head -w "%{http_code}\n" -H "Silent: true" \
     graph=${STORE_NAMED_GRAPH}-not \
   | test_ok
