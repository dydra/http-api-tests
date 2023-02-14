#! /bin/bash

source init-revisions-tests.sh

echo "initial test after delete revisions" > ${INFO_OUTPUT}
delete_revisions --repository ${repository} | fgrep -x 200 > ${GREP_OUTPUT}
repository_number_of_revisions --repository ${repository} | fgrep -x "1" > ${GREP_OUTPUT}

add_quad 1
repository_number_of_revisions --repository ${repository} | fgrep -x "2" > ${GREP_OUTPUT}
curl_graph_store_get --repository ${repository} | tr -s '\n' '\t' | fgrep "object-1" > ${GREP_OUTPUT}

add_quad 2
repository_number_of_revisions --repository ${repository} | fgrep -x "3" > ${GREP_OUTPUT}
curl_graph_store_get --repository ${repository} | tr -s '\n' '\t' | fgrep "object-1" | fgrep "object-2" > ${GREP_OUTPUT}

add_quad 3
repository_number_of_revisions --repository ${repository} | fgrep -x "4" > ${GREP_OUTPUT}
curl_graph_store_get --repository ${repository} | tr -s '\n' '\t' | fgrep "object-1" | fgrep "object-2" | fgrep "object-3" > ${GREP_OUTPUT}


echo "check visibilities of quads in last three revisions" > ${INFO_OUTPUT}
curl_graph_store_get --repository ${repository} revision-id=HEAD~2 | tr -s '\n' '\t' | fgrep "object-1" | fgrep -v "object-2" | fgrep -v "object-3" > ${GREP_OUTPUT}
curl_graph_store_get --repository ${repository} revision-id=HEAD~1 | tr -s '\n' '\t' | fgrep "object-1" | fgrep "object-2" | fgrep -v "object-3" > ${GREP_OUTPUT}
curl_graph_store_get --repository ${repository} revision-id=HEAD   | tr -s '\n' '\t' | fgrep "object-1" | fgrep "object-2" | fgrep "object-3" > ${GREP_OUTPUT}

#repository_list_revisions --repository ${repository}

echo "calling PROJECT-HISTORY: remove all revisions prior to HEAD~1" > ${INFO_OUTPUT}
#delete_revisions --repository ${repository} revision-id=HEAD~1 mode=delete-history | fgrep -x 200 > ${GREP_OUTPUT}
delete_revisions --repository ${repository} revision-id=HEAD~1 mode=project-history | fgrep -x 200 > ${GREP_OUTPUT}
repository_number_of_revisions --repository ${repository} | fgrep -x "3" > ${GREP_OUTPUT}
echo "have three revisions now: HEAD~1, HEAD, and a new revision from the trim-history command itself" > ${INFO_OUTPUT}

#repository_list_revisions --repository ${repository}



echo "check state after trim-history now" > ${INFO_OUTPUT}
## this part is different in delete-history and project-history

# object-1 is still present, all other also present:
curl_graph_store_get --repository ${repository} | tr -s '\n' '\t' | fgrep "object-1" | fgrep "object-2" | fgrep "object-3" > ${GREP_OUTPUT}

echo "check visibilities of quads in last three revisions again" > ${INFO_OUTPUT}
# HEAD~2 now introduces also object-1 in addition to object-2 -> phantom insert
curl_graph_store_get --repository ${repository} revision-id=HEAD~2 | tr -s '\n' '\t' | fgrep "object-1" | fgrep "object-2" | fgrep -v "object-3" > ${GREP_OUTPUT}
# HEAD~1 is the old HEAD
curl_graph_store_get --repository ${repository} revision-id=HEAD~1 | tr -s '\n' '\t' | fgrep "object-1" | fgrep "object-2" | fgrep "object-3" > ${GREP_OUTPUT}
# HEAD is just identical to HEAD~1
curl_graph_store_get --repository ${repository} revision-id=HEAD   | tr -s '\n' '\t' | fgrep "object-1" | fgrep "object-2" | fgrep "object-3" > ${GREP_OUTPUT}
