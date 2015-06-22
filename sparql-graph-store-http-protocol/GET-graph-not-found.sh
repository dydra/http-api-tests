#! /bin/bash
# get for a non-existent graph returns no content given default silent treatment

curl_graph_store_get_code "graph=${STORE_NAMED_GRAPH}-not" \
 | test_ok

