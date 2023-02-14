#! /bin/bash

source ../init-revisions-tests.sh

for mode in project-history delete-history; do

    echo "testing $0 in mode \"${mode}\"..." > ${INFO_OUTPUT}

echo "initial test after delete revisions" > ${INFO_OUTPUT}
delete_revisions --repository ${repository} | fgrep -x 200 > ${GREP_OUTPUT}
repository_number_of_revisions --repository ${repository} | fgrep -x "1" > ${GREP_OUTPUT}

add_quad 1
repository_number_of_revisions --repository ${repository} | fgrep -x "2" > ${GREP_OUTPUT}
curl_graph_store_get --repository ${repository} | tr -s '\n' '\t' | fgrep "object-1" > ${GREP_OUTPUT}

add_quad 2
repository_number_of_revisions --repository ${repository} | fgrep -x "3" > ${GREP_OUTPUT}
curl_graph_store_get --repository ${repository} | tr -s '\n' '\t' | fgrep "object-1" | fgrep "object-2" > ${GREP_OUTPUT}

echo "remove all revisions prior to TAIL should do nothing as TAIL has no history (in mode \"${mode}\")" > ${INFO_OUTPUT}
# Note the test for HTTP 204 here, as delete-history of TAIL should lead to 204 no content:
delete_revisions --repository ${repository} revision-id=TAIL mode="$mode" | fgrep -x 204 > ${GREP_OUTPUT}
echo "... and it should even not add another revision" > ${INFO_OUTPUT}
repository_number_of_revisions --repository ${repository} | fgrep -x "3" > ${GREP_OUTPUT}

done
