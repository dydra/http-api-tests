#! /bin/bash

revision=`${CURL} -s -H "Accept: text/plain" --user ":${STORE_TOKEN}" "${STORE_URL}/accounts/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}/revisions" | tail -n 1`

curl_tpf_get "p=http%3A%2F%2Fexample.com%2Fdefault-predicate" --revision "${revision}" > result.nq
fgrep -c default-subject result.nq | fgrep -q 1

curl_tpf_get "p=http%3A%2F%2Fexample.com%2Fdefault-predicate" -H "Accept-Datetime: Sat, 11 Jun 2016 07:01:08 GMT" > result.nq
fgrep -c default-subject result.nq | fgrep -q 1


