#! /bin/bash

source init-revisions-tests.sh

echo "initial test after delete revisions" > ${INFO_OUTPUT}
delete_revisions --repository ${repository} | fgrep -x 200 > ${GREP_OUTPUT}
repository_number_of_revisions --repository ${repository} | fgrep -x "1" > ${GREP_OUTPUT}

add_quad foo
repository_number_of_revisions --repository ${repository} | fgrep -qx "2"
curl_graph_store_get --repository mem-rdf-revisioned | tr -s '\n' '\t' | fgrep "object-foo" > ${GREP_OUTPUT}

echo "delete revisions again and test" > ${INFO_OUTPUT}
delete_revisions --repository ${repository} | fgrep -x 200 > ${GREP_OUTPUT}
repository_number_of_revisions --repository ${repository} | fgrep -x "1" > ${GREP_OUTPUT}
