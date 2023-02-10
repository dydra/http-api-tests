#! /bin/bash

repository=${STORE_REPOSITORY_REVISIONED}
# repository=unrevisioned

if ( repository_is_revisioned --repository ${repository})
then
  echo
  echo "    ${0}: ${STORE_ACCOUNT}/${repository} is revisioned" # > ${ECHO_OUTPUT}
else
  echo
  echo "    ${0}: ${STORE_ACCOUNT}/${repository} is not revisioned" # > ${ECHO_OUTPUT}
  exit 1
fi

echo "initial test after delete revisions" > ${ECHO_OUTPUT}
delete_revisions --repository ${repository} | fgrep -xq 200
repository_number_of_revisions --repository ${repository} | fgrep -qx "1"

echo "put something in, thus creating a second revision" > ${ECHO_OUTPUT}
curl_graph_store_update --repository ${repository} -X PUT -o /dev/null <<EOF \
 | tee ${ECHO_OUTPUT}
<http://example.com/default-subject> <http://example.com/default-predicate> "default object" .
EOF

repository_number_of_revisions --repository ${repository} | fgrep -qx "2"

echo "delete revisions again and test" > ${ECHO_OUTPUT}
delete_revisions --repository ${repository} | fgrep -xq 200
repository_number_of_revisions --repository ${repository} | fgrep -qx "1"
