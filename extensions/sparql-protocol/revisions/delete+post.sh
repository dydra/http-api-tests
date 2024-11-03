#! /bin/bash
# verify that the cardinality statistics correctly reflect the repository state
# after in a delete+post+sparql sequence
#
# in the particular failure mode:
#    delete, post, query
# returns the expected result, but
#    delete, query, post, query
# yields an empty result.

set -e
host="$STORE_HOST"
repository="test__rev"
account="test"

echo "create repository: ${repository} $STORE_REVISIONED_REPOSITORY_CLASS" > $ECHO_OUTPUT
create_repository --repository ${repository} --class $STORE_REVISIONED_REPOSITORY_CLASS  \
  | test_success

echo "clear revisions" > $ECHO_OUTPUT
curl --ipv4 --http1.1 -X DELETE \
  -H Accept:application/n-quads -u ":${STORE_TOKEN}" -s -o $ECHO_OUTPUT \
  https://${host}/system/accounts/${account}/repositories/${repository}/revisions

echo "run query on empty repository" > $ECHO_OUTPUT
curl_sparql_request --account ${account} --repository ${repository} \
  revision-id="*--*" -s -o $ECHO_OUTPUT \
  -H "Content-Type: application/sparql-query" -H "Accept: application/json" <<EOF
select * where { { graph ?g {?s ?p ?o} } union {?s ?p ?o} }
EOF

echo "import data" > $ECHO_OUTPUT
curl --ipv4 --http1.1 -X POST -s -o $ECHO_OUTPUT \
  -H Content-Type:application/n-quads --data-binary @-  -u ":${STORE_TOKEN}" \
  https://${host}/${account}/${repository}/service << EOF
<http://example.com/default-subject> <http://example.com/default-predicate> "object" <http://example.com/default-graph> .
EOF

echo "run query on repository content" > $ECHO_OUTPUT
curl_sparql_request --account ${account} --repository ${repository} \
  revision-id="*--*" \
  -H "Content-Type: application/sparql-query" -H "Accept: application/json" <<EOF \
  | tee ${ECHO_OUTPUT} | fgrep -q graph
select * where { { graph ?g {?s ?p ?o} } union {?s ?p ?o} }
EOF

echo "delete repository" > $ECHO_OUTPUT
delete_repository --repository ${repository} | egrep -q "${STATUS_POST_SUCCESS}"
