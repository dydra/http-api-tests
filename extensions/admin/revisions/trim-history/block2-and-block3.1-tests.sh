#! /bin/bash

source ../init-revisions-tests.sh

for mode in delete-history project-history; do

    echo "testing $0 in mode \"${mode}\"..." > ${INFO_OUTPUT}

echo "initialize repository \"${repository}\" by deleting all revisions" > ${INFO_OUTPUT}
delete_revisions --repository ${repository} | fgrep -x 200 > ${GREP_OUTPUT}
echo "initial test after delete revisions" > ${INFO_OUTPUT}
repository_number_of_revisions --repository ${repository} | fgrep -x "1" > ${GREP_OUTPUT}


add_quad -X POST 3.1
repository_number_of_revisions --repository ${repository} | fgrep -x "2" > ${GREP_OUTPUT}
curl_graph_store_get --repository mem-rdf-revisioned | tr -s '\n' '\t' \
    | fgrep "object-3.1" | fgrep -v "object-3.2" | fgrep -v "object-2.1" | fgrep -v "object-2.2" > ${GREP_OUTPUT}

add_quad -X PUT 3.2 # also delete 3.1
repository_number_of_revisions --repository ${repository} | fgrep -x "3" > ${GREP_OUTPUT}
curl_graph_store_get --repository mem-rdf-revisioned | tr -s '\n' '\t' \
    | fgrep -v "object-3.1" | fgrep "object-3.2" | fgrep -v "object-2.1" | fgrep -v "object-2.2" > ${GREP_OUTPUT}

add_quad -X PUT 2.1 # also deletes 3.2 # will be boundary revision
repository_number_of_revisions --repository ${repository} | fgrep -x "4" > ${GREP_OUTPUT}
curl_graph_store_get --repository mem-rdf-revisioned | tr -s '\n' '\t' \
    | fgrep -v "object-3.1" | fgrep -v "object-3.2" | fgrep "object-2.1" | fgrep -v "object-2.2" > ${GREP_OUTPUT}

add_quad -X POST 2.2
repository_number_of_revisions --repository ${repository} | fgrep -x "5" > ${GREP_OUTPUT}
curl_graph_store_get --repository mem-rdf-revisioned | tr -s '\n' '\t' \
    | fgrep -v "object-3.1" | fgrep -v "object-3.2" | fgrep "object-2.1" | fgrep "object-2.2" > ${GREP_OUTPUT}

# HEAD~1 is boundary revision
# object-3.1 is deleted before boundary and not inserted again
# object-3.2 is deleted at the boundary and not inserted again
# object-2.1 is inserted at the boundary
# object-2.2 is insearted after the boundary

echo "check visibilities of quads in all revisions" > ${INFO_OUTPUT}
echo "check visibilities of quads in revisions HEAD~4: empty revision" > ${INFO_OUTPUT}
# HEAD~4 is tail and gives 404 already
#curl_graph_store_get --repository mem-rdf-revisioned revision-id=HEAD~4| tr -s '\n' '\t' \
    #    | fgrep -v "object-3.1" | fgrep -v "object-3.2" | fgrep -v "object-2.1" | fgrep -v "object-2.2" > ${GREP_OUTPUT}
result=$(curl_graph_store_get_code_nofail --repository mem-rdf-revisioned revision-id=HEAD~4 2>&1 > /dev/null)
test "$result" -eq "404"
echo "check visibilities of quads in revisions HEAD~3" > ${INFO_OUTPUT}
curl_graph_store_get --repository mem-rdf-revisioned revision-id=HEAD~3 | tr -s '\n' '\t' \
    | fgrep    "object-3.1" | fgrep -v "object-3.2" | fgrep -v "object-2.1" | fgrep -v "object-2.2" > ${GREP_OUTPUT}
echo "check visibilities of quads in revisions HEAD~2" > ${INFO_OUTPUT}
curl_graph_store_get --repository mem-rdf-revisioned revision-id=HEAD~2 | tr -s '\n' '\t' \
    | fgrep -v "object-3.1" | fgrep    "object-3.2" | fgrep -v "object-2.1" | fgrep -v "object-2.2" > ${GREP_OUTPUT}
echo "check visibilities of quads in revisions HEAD~1" > ${INFO_OUTPUT}
curl_graph_store_get --repository mem-rdf-revisioned revision-id=HEAD~1 | tr -s '\n' '\t' \
    | fgrep -v "object-3.1" | fgrep -v "object-3.2" | fgrep    "object-2.1" | fgrep -v "object-2.2" > ${GREP_OUTPUT}
echo "check visibilities of quads in revisions HEAD" > ${INFO_OUTPUT}
curl_graph_store_get --repository mem-rdf-revisioned revision-id=HEAD   | tr -s '\n' '\t' \
    | fgrep -v "object-3.1" | fgrep -v "object-3.2" | fgrep    "object-2.1" | fgrep   "object-2.2" > ${GREP_OUTPUT}

#repository_list_revisions --repository ${repository}

echo "calling ${mode}: remove all revisions prior to HEAD~1" > ${INFO_OUTPUT}
delete_revisions --repository ${repository} revision-id=HEAD~1 mode="$mode" | fgrep -x 200 > ${GREP_OUTPUT}
repository_number_of_revisions --repository ${repository} | fgrep -x "3" > ${GREP_OUTPUT}
echo "have three revisions now: HEAD~1, HEAD, and a new revision from the trim-history command itself" > ${INFO_OUTPUT}

# repository_list_revisions --repository ${repository}


echo "check visibilities of quads in all revisions again after trim-history" > ${INFO_OUTPUT}
echo "check visibilities of quads in revisions HEAD~2 - boundary revision" > ${INFO_OUTPUT}
curl_graph_store_get --repository mem-rdf-revisioned revision-id=HEAD~2 | tr -s '\n' '\t' \
    | fgrep -v "object-3.1" | fgrep -v "object-3.2" | fgrep    "object-2.1" | fgrep -v "object-2.2" > ${GREP_OUTPUT}
echo "check visibilities of quads in revisions HEAD~1 - pivot revision" > ${INFO_OUTPUT}
curl_graph_store_get --repository mem-rdf-revisioned revision-id=HEAD~1 | tr -s '\n' '\t' \
    | fgrep -v "object-3.1" | fgrep -v "object-3.2" | fgrep    "object-2.1" | fgrep    "object-2.2" > ${GREP_OUTPUT}
echo "check visibilities of quads in revisions HEAD - trim operation revision (identical to previous)" > ${INFO_OUTPUT}
curl_graph_store_get --repository mem-rdf-revisioned revision-id=HEAD   | tr -s '\n' '\t' \
    | fgrep -v "object-3.1" | fgrep -v "object-3.2" | fgrep    "object-2.1" | fgrep    "object-2.2" > ${GREP_OUTPUT}

done
