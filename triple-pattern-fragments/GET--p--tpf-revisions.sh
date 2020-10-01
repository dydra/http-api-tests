#! /bin/bash

function list_revisions() {
  ${CURL} -s -H "Accept: text/plain" --user ":${STORE_TOKEN}" "${STORE_URL}/system/accounts/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}/revisions"
}

revision=`list_revisions | tail -n 1`
revisionCount=`list_revisions | wc -l`

curl_tpf_get "p=http%3A%2F%2Fexample.com%2Fdefault-predicate" --revision "${revision}" > result.nq
fgrep -c default-subject result.nq | fgrep -q 1
exit $?

# (timeline-location-date-time (rlmdb:get-revision-timestamps (repository "openrdf-sesame/mem-rdf")))
# in order not to have to guess, use today
if (( $revisionCount > 1 )) 
then
  datetime=`env TZ=GMT date '+%a, %d %b %Y %T %Z'`
  curl_tpf_get "p=http%3A%2F%2Fexample.com%2Fdefault-predicate" -H "Accept-Datetime: $datetime" > result.nq
  fgrep -c default-subject result.nq | fgrep -q 1
fi


