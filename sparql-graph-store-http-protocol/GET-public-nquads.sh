#! /bin/bash

# test just that the repository is accessible; content does not matter

curl_graph_store_get -w '%{http_code}\n' -u "" -H "Accept: application/n-quads" \
   -H 'Silent: true' \
   --repository "$STORE_REPOSITORY_PUBLIC" \
   | test_ok
