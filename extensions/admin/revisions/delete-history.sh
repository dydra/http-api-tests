#! /bin/bash

source init-revisions-tests.sh

echo "initial test after delete revisions" > ${INFO_OUTPUT}
delete_revisions --repository ${repository} | fgrep -x 200 > ${GREP_OUTPUT}
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

echo "calling DELETE-HISTORY: remove all revisions prior to HEAD~1" > ${INFO_OUTPUT}
delete_revisions --repository ${repository} revision-id=HEAD~1 mode=delete-history | fgrep -x 200 > ${GREP_OUTPUT}
#delete_revisions --repository ${repository} revision-id=HEAD~1 mode=project-history | fgrep -x 200 > ${GREP_OUTPUT}
repository_number_of_revisions --repository ${repository} | fgrep -qx "3"
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
