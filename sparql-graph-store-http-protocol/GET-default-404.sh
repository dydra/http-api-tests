#! /bin/bash

curl_graph_store_get  -w '%{http_code}\n' --repository "${STORE_REPOSITORY}-not" "default" \
   | test_not_found

