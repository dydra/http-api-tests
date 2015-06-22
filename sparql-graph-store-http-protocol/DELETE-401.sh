#! /bin/bash


# test that improper authentication yields a 401

curl_graph_store_delete -w "%{http_code}\n" \
      -u "${STORE_TOKEN}-not:" \
      --repository  "${STORE_REPOSITORY}-write" \
   | test_unauthorized_success

