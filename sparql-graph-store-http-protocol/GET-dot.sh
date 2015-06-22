#! /bin/bash

curl_graph_store_get -H "Accept: text/x-graphviz" \
   | fgrep -q 'digraph' 
