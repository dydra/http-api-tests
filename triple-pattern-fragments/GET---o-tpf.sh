#! /bin/bash

curl_tpf_get "o=%22named%20object%22" > result.nq

fgrep -c named-subject result.nq | fgrep -q 1
fgrep -c default-subject result.nq | fgrep -q 0
