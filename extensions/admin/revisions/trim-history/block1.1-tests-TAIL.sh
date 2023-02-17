#! /bin/bash

source ../test-if-revisioned-and-common-functions.sh

for mode in project-history delete-history; do

    echo "testing $0 in mode \"${mode}\"..." > ${INFO_OUTPUT}

echo "initial test after delete revisions" > ${INFO_OUTPUT}
delete_revisions --repository ${repository} | fgrep -x 200 > ${GREP_OUTPUT}
repository_number_of_revisions --repository ${repository} | fgrep -x "1" > ${GREP_OUTPUT}

rev="HEAD"
result=$(curl_graph_store_get_code_nofail --repository ${repository} revision-id=${rev} 2>&1 > /dev/null)
echo "result: ${result}" > ${INFO_OUTPUT}
test "$result" -eq "404"

add_quad 1
repository_number_of_revisions --repository ${repository} | fgrep -x "2" > ${GREP_OUTPUT}
curl_graph_store_get --repository ${repository} | tr -s '\n' '\t' \
    | fgrep "object-1" | fgrep -v "object-2" > ${GREP_OUTPUT}

add_quad 2
repository_number_of_revisions --repository ${repository} | fgrep -x "3" > ${GREP_OUTPUT}
curl_graph_store_get --repository ${repository} | tr -s '\n' '\t' \
    | fgrep "object-1" | fgrep    "object-2" > ${GREP_OUTPUT}

echo "checking visibility vectors before trim-history" > ${INFO_OUTPUT}
get_visibility | tr -s '\n' '\t' | tee ${INFO_OUTPUT} \
    | fgrep '"object-1,2"' | fgrep '"object-2,3"' > ${GREP_OUTPUT}


echo "remove all revisions prior to TAIL should do nothing as TAIL has no history (in mode \"${mode}\")" > ${INFO_OUTPUT}
# Note the test for HTTP 204 here, as delete-history of TAIL should lead to 204 no content:
delete_revisions --repository ${repository} revision-id=TAIL mode="$mode" | fgrep -x 204 > ${GREP_OUTPUT}
echo "... and it should even not add another revision" > ${INFO_OUTPUT}
repository_number_of_revisions --repository ${repository} | fgrep -x "3" > ${GREP_OUTPUT}

echo "checking visibility vectors after trim-history in mode \"${mode}\"" > ${INFO_OUTPUT}
get_visibility | tr -s '\n' '\t' | tee ${INFO_OUTPUT} \
    | fgrep '"object-1,2"' | fgrep '"object-2,3"' > ${GREP_OUTPUT}

done
