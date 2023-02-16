#! /bin/bash

source ../test-if-revisioned-and-common-functions.sh

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

echo "remove all revisions prior to HEAD should leave just one revision + the operation's revision (in mode \"${mode}\")" > ${INFO_OUTPUT}
delete_revisions --repository ${repository} revision-id=HEAD mode="$mode" | fgrep -x 200 > ${GREP_OUTPUT}
repository_number_of_revisions --repository ${repository} | fgrep -x "2" > ${GREP_OUTPUT}

done
