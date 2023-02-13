#! /bin/bash

source ../init-revisions-tests.sh

echo "initial test after delete revisions" > ${INFO_OUTPUT}
delete_revisions --repository ${repository} | fgrep -x 200 > ${GREP_OUTPUT}
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

repository_list_revisions --repository ${repository}

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

exit 0

#repository_list_revisions --repository ${repository}

echo "calling DELETE-HISTORY: remove all revisions prior to HEAD~1" > ${INFO_OUTPUT}
delete_revisions --repository ${repository} revision-id=HEAD~1 mode=delete-history | fgrep -x 200 > ${GREP_OUTPUT}
#delete_revisions --repository ${repository} revision-id=HEAD~1 mode=project-history | fgrep -x 200 > ${GREP_OUTPUT}
repository_number_of_revisions --repository ${repository} | fgrep -x "3" > ${GREP_OUTPUT}
echo "have three revisions now: HEAD~1, HEAD, and a new revision from the trim-history command itself" > ${INFO_OUTPUT}

#repository_list_revisions --repository ${repository}



echo "check state after trim-history now" > ${INFO_OUTPUT}
## this part is different in delete-history and project-history

# object-1 is deleted, all other still present:
curl_graph_store_get --repository mem-rdf-revisioned | tr -s '\n' '\t' | fgrep -v "object-1" | fgrep "object-2" | fgrep "object-3" > ${GREP_OUTPUT}

echo "check visibilities of quads in last three revisions again" > ${INFO_OUTPUT}
# the old revision HEAD~2 which introduced object-1 is completely deleted, so object-1 is not present anywhere.
# HEAD~2 just introduces object-2
curl_graph_store_get --repository mem-rdf-revisioned revision-id=HEAD~2 | tr -s '\n' '\t' | fgrep -v "object-1" | fgrep "object-2" | fgrep -v "object-3" > ${GREP_OUTPUT}
# HEAD~1 is the old HEAD, minus object-1
curl_graph_store_get --repository mem-rdf-revisioned revision-id=HEAD~1 | tr -s '\n' '\t' | fgrep -v "object-1" | fgrep "object-2" | fgrep "object-3" > ${GREP_OUTPUT}
# HEAD is just identical to HEAD~1
curl_graph_store_get --repository mem-rdf-revisioned revision-id=HEAD   | tr -s '\n' '\t' | fgrep -v "object-1" | fgrep "object-2" | fgrep "object-3" > ${GREP_OUTPUT}
