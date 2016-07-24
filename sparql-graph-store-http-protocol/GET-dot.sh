#! /bin/bash
# test that both forms work

curl_graph_store_get -H "Accept: text/x-graphviz" \
   | fgrep -q 'digraph' 


curl_graph_store_get -H "Accept: text/vnd.graphviz" \
   | fgrep -q 'digraph' 
