#! /bin/bash

curl_graph_store_get -H "Accept: text/vnd.graphviz" \
   | fgrep -q 'digraph' 
