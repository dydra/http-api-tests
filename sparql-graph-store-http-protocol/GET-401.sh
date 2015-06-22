#! /bin/bash

curl_graph_store_get -w '%{http_code}\n' -u "${STORE_TOKEN}-not:" \
   | test_unauthorized_success

