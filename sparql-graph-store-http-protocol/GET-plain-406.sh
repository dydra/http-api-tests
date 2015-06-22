#! /bin/bash

# test invalid ntriples variations

curl_graph_store_get -w '%{http_code}\n' -H "Accept: text/plain" \
   | test_not_acceptable

curl_graph_store_get -w '%{http_code}\n' -H "Accept: application/ntriples" \
   | test_not_acceptable