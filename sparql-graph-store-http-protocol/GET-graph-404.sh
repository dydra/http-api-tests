#! /bin/bash


curl_graph_store_get_code "graph=${STORE_NAMED_GRAPH}-not" \
 | test_not_found_success

