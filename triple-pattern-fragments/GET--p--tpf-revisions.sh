#! /bin/bash

revision=`${CURL} -s -H "Accept: text/plain" --user ":${STORE_TOKEN}" "${STORE_URL}/system/accounts/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}/revisions" | tail -n 1`

curl_tpf_get "p=http%3A%2F%2Fexample.com%2Fdefault-predicate" --revision "${revision}" > result.nq
fgrep -c default-subject result.nq | fgrep -q 1

# (timeline-location-date-time (rlmdb:get-revision-timestamps (repository "openrdf-sesame/mem-rdf")))
# in order not to have to guess, use today
datetime=`env TZ=GMT date '+%a, %d %b %Y %T %Z'`
curl_tpf_get "p=http%3A%2F%2Fexample.com%2Fdefault-predicate" -H "Accept-Datetime: $datetime" > result.nq
fgrep -c default-subject result.nq | fgrep -q 1


