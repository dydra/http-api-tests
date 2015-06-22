#! /bin/bash


curl_graph_store_get -w "%{http_code}\n" --head default \
   | fgrep -q "${STATUS_OK}"