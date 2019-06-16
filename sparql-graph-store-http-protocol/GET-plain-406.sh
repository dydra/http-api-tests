#! /bin/bash

# test invalid accept variations
# the first is a know media type - thus not acceptable
# the second is not a valid type - thus bad request

curl_graph_store_get -w '%{http_code}\n' -H "Accept: text/plain" \
   | test_not_acceptable

curl_graph_store_get -w '%{http_code}\n' -H "Accept: application/ntriples" \
   | test_bad_request