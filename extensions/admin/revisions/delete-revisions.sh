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

if [[ "" == "${INFO_OUTPUT:-}" ]]
then
  export INFO_OUTPUT=${ECHO_OUTPUT} # /dev/null # /dev/tty
fi

if [[ "" == "${GREP_OUTPUT:-}" ]]
then
  export GREP_OUTPUT=${ECHO_OUTPUT} # /dev/null # /dev/tty
fi

echo "initial test after delete revisions" > ${INFO_OUTPUT}
delete_revisions --repository ${repository} | fgrep -x 200 > ${GREP_OUTPUT}
repository_number_of_revisions --repository ${repository} | fgrep -x "1" > ${GREP_OUTPUT}

echo "put something in, thus creating a second revision" > ${INFO_OUTPUT}
curl_graph_store_update --repository ${repository} -X PUT -o /dev/null <<EOF \
 | tee ${ECHO_OUTPUT}
<http://example.com/default-subject> <http://example.com/default-predicate> "default object" .
EOF

repository_number_of_revisions --repository ${repository} | fgrep -x "2" > ${GREP_OUTPUT}

echo "delete revisions again and test" > ${INFO_OUTPUT}
delete_revisions --repository ${repository} | fgrep -x 200 > ${GREP_OUTPUT}
repository_number_of_revisions --repository ${repository} | fgrep -x "1" > ${GREP_OUTPUT}