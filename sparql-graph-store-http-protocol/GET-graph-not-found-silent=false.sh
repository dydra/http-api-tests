#! /bin/bash
# get for a non-existent graph returns a 404 given silent=false


curl_graph_store_get_code -H "Silent:false" "graph=${STORE_NAMED_GRAPH}-not" \
 | test_not_found_success

