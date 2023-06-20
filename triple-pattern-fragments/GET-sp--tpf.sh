#! /bin/bash

curl_tpf_get "s=http%3A%2F%2Fexample.com%2Fnamed-subject&p=http%3A%2F%2Fexample.com%2Fnamed-predicate" \
  | tee $ECHO_OUTPUT > result.nq

fgrep -c named-subject result.nq | fgrep -q 1
fgrep -c default-subject result.nq | fgrep -q 0
