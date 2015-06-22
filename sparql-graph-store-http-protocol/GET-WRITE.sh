#! /bin/bash

# verify NO read access for user with write access only

curl_graph_store_get -w "%{http_code}\n" -u "${STORE_TOKEN}_WRITE:" \
   | test_unauthorized_success
