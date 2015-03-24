#! /bin/bash


# test that improper authentication yields a 401

curl_graph_store_delete --repository  "${STORE_REPOSITORY}-write" \
      -w "%{http_code}\n" \
      -u "${STORE_TOKEN}-not:" \
   | test_unauthorized_success

