#! /bin/bash

curl_tpf_get "p=http%3A%2F%2Fexample.com%2Fnamed-predicate" > result.nq
fgrep -c named-subject result.nq | fgrep -q 1
fgrep -c default-subject result.nq | fgrep -q 0

curl_tpf_get "p=http%3A%2F%2Fexample.com%2Fdefault-predicate" > result.nq
fgrep -c named-subject result.nq | fgrep -q 0
fgrep -c default-subject result.nq | fgrep -q 1

curl_tpf_get "p=http%3A%2F%2Fexample.com%2Fdefault-predicate" --revision "8f0d48c1-5107-9643-8ca1-e8af875ac4b7" > result.nq
fgrep -c default-subject result.nq | fgrep -q 1

curl_tpf_get "p=http%3A%2F%2Fexample.com%2Fdefault-predicate" -H "Accept-Datetime: Sat, 11 Jun 2016 07:01:08 GMT" > result.nq
fgrep -c default-subject result.nq | fgrep -q 1


