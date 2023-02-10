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


function add_quad() {
    local object="object-"${1:-0}
    before=$(repository_number_of_revisions --repository ${repository})

    echo "put in ${object}, thus adding revision" > ${INFO_OUTPUT}
    curl_graph_store_update --repository ${repository} -X POST -o /dev/null <<EOF \
        | tee ${ECHO_OUTPUT}
<http://example.com/default-subject> <http://example.com/default-predicate> "${object}" <http://example.com/default-graph> .
EOF

    after=$(repository_number_of_revisions --repository ${repository})
    test $[$before+1] -eq $after
}
