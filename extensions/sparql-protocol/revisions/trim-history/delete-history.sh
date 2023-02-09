#! /bin/bash

repository=${STORE_REPOSITORY_REVISIONED}
# repository=unrevisioned

if [[ "" == "${INFO_OUTPUT:-}" ]]
then
  export INFO_OUTPUT=${ECHO_OUTPUT} # /dev/null # /dev/tty
fi

# q option for grep
q=-q
#q=""

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
curl_graph_store_get --repository mem-rdf-revisioned | tr -s '\n' '\t' | fgrep $q "object-1"

add_quad 2
repository_number_of_revisions --repository ${repository} | fgrep -qx "3"
curl_graph_store_get --repository mem-rdf-revisioned | tr -s '\n' '\t' | fgrep "object-1" | fgrep $q "object-2"

add_quad 3
repository_number_of_revisions --repository ${repository} | fgrep -qx "4"
curl_graph_store_get --repository mem-rdf-revisioned | tr -s '\n' '\t' | fgrep "object-1" | fgrep "object-2" | fgrep $q "object-3"

repository_list_revisions --repository ${repository}

echo "delete revisions again and test" > ${INFO_OUTPUT}
delete_revisions --repository ${repository} revision-id=HEAD~1 mode=delete-history
#delete_revisions --repository ${repository} revision-id=HEAD~1 mode=project-history
repository_number_of_revisions --repository ${repository} | fgrep -qx "3" # still 3 as delete-history adds one revision itself

repository_list_revisions --repository ${repository}

# object-1 is deleted, all other still present:
curl_graph_store_get --repository mem-rdf-revisioned | tr -s '\n' '\t' | fgrep -v "object-1" | fgrep "object-2" | fgrep $q "object-3"
