#! /bin/bash

repository=${STORE_REPOSITORY_REVISIONED}
# repository=unrevisioned

if [[ "" == "${INFO_OUTPUT:-}" ]]
then
  export INFO_OUTPUT=${ECHO_OUTPUT} # /dev/null # /dev/tty
fi

if [[ "" == "${GREP_OUTPUT:-}" ]]
then
  export GREP_OUTPUT=${ECHO_OUTPUT} # /dev/null # /dev/tty
fi

if ( repository_is_revisioned --repository ${repository})
then
  echo
  echo "    ${0}: ${STORE_ACCOUNT}/${repository} is revisioned" # > ${INFO_OUTPUT}
else
  echo
  echo "    ${0}: ${STORE_ACCOUNT}/${repository} is not revisioned" # > ${INFO_OUTPUT}
  exit 1
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

echo "initial test after delete revisions" > ${INFO_OUTPUT}
delete_revisions --repository ${repository}
repository_number_of_revisions --repository ${repository} | fgrep -qx "1"

add_quad 1
repository_number_of_revisions --repository ${repository} | fgrep -qx "2"
curl_graph_store_get --repository mem-rdf-revisioned | tr -s '\n' '\t' | fgrep "object-1" > ${GREP_OUTPUT}

add_quad 2
repository_number_of_revisions --repository ${repository} | fgrep -qx "3"
curl_graph_store_get --repository mem-rdf-revisioned | tr -s '\n' '\t' | fgrep "object-1" | fgrep "object-2" > ${GREP_OUTPUT}

add_quad 3
repository_number_of_revisions --repository ${repository} | fgrep -qx "4"
curl_graph_store_get --repository mem-rdf-revisioned | tr -s '\n' '\t' | fgrep "object-1" | fgrep "object-2" | fgrep "object-3" > ${GREP_OUTPUT}


echo "check visibilities of quads in last three revisions" > ${INFO_OUTPUT}
curl_graph_store_get --repository mem-rdf-revisioned revision-id=HEAD~2 | tr -s '\n' '\t' | fgrep "object-1" | fgrep -v "object-2" | fgrep -v "object-3" > ${GREP_OUTPUT}
curl_graph_store_get --repository mem-rdf-revisioned revision-id=HEAD~1 | tr -s '\n' '\t' | fgrep "object-1" | fgrep "object-2" | fgrep -v "object-3" > ${GREP_OUTPUT}
curl_graph_store_get --repository mem-rdf-revisioned revision-id=HEAD   | tr -s '\n' '\t' | fgrep "object-1" | fgrep "object-2" | fgrep "object-3" > ${GREP_OUTPUT}

#repository_list_revisions --repository ${repository}

echo "calling PROJECT-HISTORY: remove all revisions prior to HEAD~1" > ${INFO_OUTPUT}
#delete_revisions --repository ${repository} revision-id=HEAD~1 mode=delete-history
delete_revisions --repository ${repository} revision-id=HEAD~1 mode=project-history
repository_number_of_revisions --repository ${repository} | fgrep -qx "3"
echo "have three revisions now: HEAD~1, HEAD, and a new revision from the trim-history command itself" > ${INFO_OUTPUT}

#repository_list_revisions --repository ${repository}



echo "check state after trim-history now" > ${INFO_OUTPUT}
## this part is different in delete-history and project-history

# object-1 is still present, all other also present:
curl_graph_store_get --repository mem-rdf-revisioned | tr -s '\n' '\t' | fgrep "object-1" | fgrep "object-2" | fgrep "object-3" > ${GREP_OUTPUT}

echo "check visibilities of quads in last three revisions again" > ${INFO_OUTPUT}
# HEAD~2 now introduces also object-1 in addition to object-2 -> phantom insert
curl_graph_store_get --repository mem-rdf-revisioned revision-id=HEAD~2 | tr -s '\n' '\t' | fgrep "object-1" | fgrep "object-2" | fgrep -v "object-3" > ${GREP_OUTPUT}
# HEAD~1 is the old HEAD
curl_graph_store_get --repository mem-rdf-revisioned revision-id=HEAD~1 | tr -s '\n' '\t' | fgrep "object-1" | fgrep "object-2" | fgrep "object-3" > ${GREP_OUTPUT}
# HEAD is just identical to HEAD~1
curl_graph_store_get --repository mem-rdf-revisioned revision-id=HEAD   | tr -s '\n' '\t' | fgrep "object-1" | fgrep "object-2" | fgrep "object-3" > ${GREP_OUTPUT}
