#! /bin/bash



curl_graph_store_get -w "%{http_code}\n" --head graph=${STORE_NAMED_GRAPH} \
   | test_ok_success

