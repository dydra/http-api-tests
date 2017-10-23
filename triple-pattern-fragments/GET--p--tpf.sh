#! /bin/bash

curl_tpf_get "p=http%3A%2F%2Fexample.com%2Fnamed-predicate" > result.nq
fgrep -c named-subject result.nq | fgrep -q 1
fgrep -c default-subject result.nq | fgrep -q 0

curl_tpf_get "p=http%3A%2F%2Fexample.com%2Fdefault-predicate" > result.nq
fgrep -c named-subject result.nq | fgrep -q 0
fgrep -c default-subject result.nq | fgrep -q 1
