#! /bin/bash

curl_graph_store_get "Accept: text/x-graphviz" "" \
   | fgrep -q 'digraph' 
