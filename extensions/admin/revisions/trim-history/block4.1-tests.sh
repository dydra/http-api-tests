#! /bin/bash

source ../test-if-revisioned-and-common-functions.sh

for mode in project-history delete-history; do

    echo "testing $0 in mode \"${mode}\"..." > ${INFO_OUTPUT}

echo "initialize repository \"${repository}\" by deleting all revisions" > ${INFO_OUTPUT}
delete_revisions --repository ${repository} | fgrep -x 200 > ${GREP_OUTPUT}
echo "initial test after delete revisions" > ${INFO_OUTPUT}
repository_number_of_revisions --repository ${repository} | fgrep -x "1" > ${GREP_OUTPUT}

rev="HEAD"
result=$(curl_graph_store_get_code_nofail --repository ${repository} revision-id=${rev} 2>&1 > /dev/null)
echo "result: ${result}" > ${INFO_OUTPUT}
test "$result" -eq "404"

add_quad -X POST 4.1
repository_number_of_revisions --repository ${repository} | fgrep -x "2" > ${GREP_OUTPUT}
curl_graph_store_get --repository ${repository} | tr -s '\n' '\t' \
    | fgrep    "object-4.1" | fgrep -v "object-4.2" | fgrep -v "object-extra" | fgrep -v "object-foo" > ${GREP_OUTPUT}

add_quad -X PUT 4.2 # also delete 4.1
repository_number_of_revisions --repository ${repository} | fgrep -x "3" > ${GREP_OUTPUT}
curl_graph_store_get --repository ${repository} | tr -s '\n' '\t' \
    | fgrep -v "object-4.1" | fgrep    "object-4.2" | fgrep -v "object-extra" | fgrep -v "object-foo" > ${GREP_OUTPUT}

add_quad -X PUT extra # also deletes 4.2 # boundary revision
repository_number_of_revisions --repository ${repository} | fgrep -x "4" > ${GREP_OUTPUT}
curl_graph_store_get --repository ${repository} | tr -s '\n' '\t' \
    | fgrep -v "object-4.1" | fgrep -v "object-4.2" | fgrep    "object-extra" | fgrep -v "object-foo" > ${GREP_OUTPUT}

add_quad -X POST 4.2 # inserts 4.2 again
repository_number_of_revisions --repository ${repository} | fgrep -x "5" > ${GREP_OUTPUT}
curl_graph_store_get --repository ${repository} | tr -s '\n' '\t' \
    | fgrep -v "object-4.1" | fgrep    "object-4.2" | fgrep    "object-extra" | fgrep -v "object-foo" > ${GREP_OUTPUT}

add_quad -X POST foo # just a new extra quad to have more revisions
repository_number_of_revisions --repository ${repository} | fgrep -x "6" > ${GREP_OUTPUT}
curl_graph_store_get --repository ${repository} | tr -s '\n' '\t' \
    | fgrep -v "object-4.1" | fgrep    "object-4.2" | fgrep    "object-extra" | fgrep    "object-foo" > ${GREP_OUTPUT}

add_quad -X POST 4.1 # inserts 4.1 again
repository_number_of_revisions --repository ${repository} | fgrep -x "7" > ${GREP_OUTPUT}
curl_graph_store_get --repository ${repository} | tr -s '\n' '\t' \
    | fgrep    "object-4.1" | fgrep    "object-4.2" | fgrep    "object-extra" | fgrep    "object-foo" > ${GREP_OUTPUT}

#repository_list_revisions --repository ${repository}

# HEAD~3 is boundary revision
# object-4.1 was inserted in HEAD~5 and deleted before the boundary in HEAD~4,
#    is inserted after the boundary in HEAD and was not visible at the boundary
# object-4.2 was inserted before the boundary in HEAD~4 and deleted at the boundary in HEAD~3,
#    is inserted after the boundary in HEAD~2 and was not visible at the boundary
# object-extra was inserted at the boundary in HEAD~3
# object-foo was inserted after the boundary in HEAD~1 and is not affected by the trim operation

echo "check visibilities of quads in all revisions" > ${INFO_OUTPUT}
rev="HEAD~6"
echo "check visibilities of quads in revisions ${rev}: empty revision" > ${INFO_OUTPUT}
# HEAD~4 is tail and gives 404 already
#curl_graph_store_get --repository ${repository} revision-id=${rev} | tr -s '\n' '\t' \
    #    | fgrep -v "object-3.1" | fgrep -v "object-3.2" | fgrep -v "object-2.1" | fgrep -v "object-2.2" > ${GREP_OUTPUT}
result=$(curl_graph_store_get_code_nofail --repository ${repository} revision-id=${rev} 2>&1 > /dev/null)
test "$result" -eq "404"
rev="HEAD~5"
echo "check visibilities of quads in revisions ${rev}" > ${INFO_OUTPUT}
curl_graph_store_get --repository ${repository} revision-id=${rev} | tr -s '\n' '\t' \
    | fgrep    "object-4.1" | fgrep -v "object-4.2" | fgrep -v "object-extra" | fgrep -v "object-foo" > ${GREP_OUTPUT}
rev="HEAD~4"
echo "check visibilities of quads in revisions ${rev}" > ${INFO_OUTPUT}
curl_graph_store_get --repository ${repository} revision-id=${rev} | tr -s '\n' '\t' \
    | fgrep -v "object-4.1" | fgrep    "object-4.2" | fgrep -v "object-extra" | fgrep -v "object-foo" > ${GREP_OUTPUT}
rev="HEAD~3"
echo "check visibilities of quads in revisions ${rev}" > ${INFO_OUTPUT}
curl_graph_store_get --repository ${repository} revision-id=${rev} | tr -s '\n' '\t' \
    | fgrep -v "object-4.1" | fgrep -v "object-4.2" | fgrep    "object-extra" | fgrep -v "object-foo" > ${GREP_OUTPUT}
rev="HEAD~2"
echo "check visibilities of quads in revisions ${rev}" > ${INFO_OUTPUT}
curl_graph_store_get --repository ${repository} revision-id=${rev} | tr -s '\n' '\t' \
    | fgrep -v "object-4.1" | fgrep    "object-4.2" | fgrep    "object-extra" | fgrep -v "object-foo" > ${GREP_OUTPUT}
rev="HEAD~1"
echo "check visibilities of quads in revisions ${rev}" > ${INFO_OUTPUT}
curl_graph_store_get --repository ${repository} revision-id=${rev} | tr -s '\n' '\t' \
    | fgrep -v "object-4.1" | fgrep    "object-4.2" | fgrep    "object-extra" | fgrep    "object-foo" > ${GREP_OUTPUT}
rev="HEAD"
echo "check visibilities of quads in revisions ${rev}"   > ${INFO_OUTPUT}
curl_graph_store_get --repository ${repository} revision-id=${rev}   | tr -s '\n' '\t' \
    | fgrep    "object-4.1" | fgrep    "object-4.2" | fgrep    "object-extra" | fgrep    "object-foo" > ${GREP_OUTPUT}

#repository_list_revisions --repository ${repository}

rev="HEAD~3"
echo "calling ${mode}: remove all revisions prior to ${rev}" > ${INFO_OUTPUT}
delete_revisions --repository ${repository} revision-id=${rev} mode="$mode" | fgrep -x 200 > ${GREP_OUTPUT}
repository_number_of_revisions --repository ${repository} | fgrep -x "5" > ${GREP_OUTPUT}
echo "have five revisions now: HEAD~3 through HEAD, and a new revision from the trim-history command itself" > ${INFO_OUTPUT}

#repository_list_revisions --repository ${repository}

echo "check visibilities of quads in all revisions again after trim-history in mode \"${mode}\"" > ${INFO_OUTPUT}

rev="HEAD~4"
echo "check visibilities of quads in revisions ${rev}" > ${INFO_OUTPUT}
curl_graph_store_get --repository ${repository} revision-id=${rev} | tr -s '\n' '\t' \
    | fgrep -v "object-4.1" | fgrep -v "object-4.2" | fgrep    "object-extra" | fgrep -v "object-foo" > ${GREP_OUTPUT}
rev="HEAD~3"
echo "check visibilities of quads in revisions ${rev}" > ${INFO_OUTPUT}
curl_graph_store_get --repository ${repository} revision-id=${rev} | tr -s '\n' '\t' \
    | fgrep -v "object-4.1" | fgrep    "object-4.2" | fgrep    "object-extra" | fgrep -v "object-foo" > ${GREP_OUTPUT}
rev="HEAD~2"
echo "check visibilities of quads in revisions ${rev}" > ${INFO_OUTPUT}
curl_graph_store_get --repository ${repository} revision-id=${rev} | tr -s '\n' '\t' \
    | fgrep -v "object-4.1" | fgrep    "object-4.2" | fgrep    "object-extra" | fgrep    "object-foo" > ${GREP_OUTPUT}
rev="HEAD~1"
echo "check visibilities of quads in revisions ${rev}" > ${INFO_OUTPUT}
curl_graph_store_get --repository ${repository} revision-id=${rev} | tr -s '\n' '\t' \
    | fgrep    "object-4.1" | fgrep    "object-4.2" | fgrep    "object-extra" | fgrep    "object-foo" > ${GREP_OUTPUT}
rev="HEAD"
echo "check visibilities of quads in revisions ${rev} - trim operation revision (identical to previous)"   > ${INFO_OUTPUT}
curl_graph_store_get --repository ${repository} revision-id=${rev}   | tr -s '\n' '\t' \
    | fgrep    "object-4.1" | fgrep    "object-4.2" | fgrep    "object-extra" | fgrep    "object-foo" > ${GREP_OUTPUT}

done
