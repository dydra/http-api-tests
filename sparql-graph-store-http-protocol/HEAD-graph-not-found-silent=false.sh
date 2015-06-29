#! /bin/bash

# with the silent false, this responds with a 404

curl_graph_store_get -w "%{http_code}\n" -H "Silent:false" --head \
     graph=${STORE_NAMED_GRAPH}-not \
   | test_not_found
