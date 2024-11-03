#! /bin/bash

source ../test-if-revisioned-and-common-functions.sh

for mode in project-history delete-history; do

    echo "testing $0 in mode \"${mode}\"..." > ${INFO_OUTPUT}

echo "initialize repository \"${repository}\" by deleting all revisions" > ${INFO_OUTPUT}
delete_revisions --repository ${repository} | fgrep -x 200 > ${GREP_OUTPUT}
echo "initial test after delete revisions" > ${INFO_OUTPUT}
repository_number_of_revisions --repository ${repository} | fgrep -x "1" > ${GREP_OUTPUT}

check_empty_repository
make_base_revision_ordinals

add_quad -X POST 3.1
repository_number_of_revisions --repository ${repository} | fgrep -x "2" > ${GREP_OUTPUT}
curl_graph_store_get --repository ${repository} | tr -s '\n' '\t' \
    | fgrep "object-3.1" | fgrep -v "object-3.2" | fgrep -v "object-2.1" | fgrep -v "object-2.2" > ${GREP_OUTPUT}

add_quad -X PUT 3.2 # also delete 3.1
repository_number_of_revisions --repository ${repository} | fgrep -x "3" > ${GREP_OUTPUT}
curl_graph_store_get --repository ${repository} | tr -s '\n' '\t' \
    | fgrep -v "object-3.1" | fgrep "object-3.2" | fgrep -v "object-2.1" | fgrep -v "object-2.2" > ${GREP_OUTPUT}

add_quad -X PUT 2.1 # also deletes 3.2 # will be boundary revision
repository_number_of_revisions --repository ${repository} | fgrep -x "4" > ${GREP_OUTPUT}
curl_graph_store_get --repository ${repository} | tr -s '\n' '\t' \
    | fgrep -v "object-3.1" | fgrep -v "object-3.2" | fgrep "object-2.1" | fgrep -v "object-2.2" > ${GREP_OUTPUT}

add_quad -X POST 2.2
repository_number_of_revisions --repository ${repository} | fgrep -x "5" > ${GREP_OUTPUT}
curl_graph_store_get --repository ${repository} | tr -s '\n' '\t' \
    | fgrep -v "object-3.1" | fgrep -v "object-3.2" | fgrep "object-2.1" | fgrep "object-2.2" > ${GREP_OUTPUT}

# HEAD~1 is boundary revision
# object-3.1 is deleted before boundary and not inserted again
# object-3.2 is deleted at the boundary and not inserted again
# object-2.1 is inserted at the boundary
# object-2.2 is insearted after the boundary

echo "check visibilities of quads in all revisions" > ${INFO_OUTPUT}
rev="HEAD~4"
echo "check visibilities of quads in revisions ${rev}: empty revision" > ${INFO_OUTPUT}
# HEAD~4 is tail and gives 404 already
#curl_graph_store_get --repository ${repository} revision-id=${rev}| tr -s '\n' '\t' \
    #    | fgrep -v "object-3.1" | fgrep -v "object-3.2" | fgrep -v "object-2.1" | fgrep -v "object-2.2" > ${GREP_OUTPUT}

curl_graph_store_get -w '%{http_code}\n' --repository ${repository} revision-id=${rev} \
  | test_not_found
# fails on osx
#result=$(curl_graph_store_get_code_nofail --repository ${repository} revision-id=${rev} 2>&1 > /dev/null)
#test "$result" -eq "404"

rev="HEAD~3"
echo "check visibilities of quads in revisions ${rev}" > ${INFO_OUTPUT}
curl_graph_store_get --repository ${repository} revision-id=${rev} | tr -s '\n' '\t' \
    | fgrep    "object-3.1" | fgrep -v "object-3.2" | fgrep -v "object-2.1" | fgrep -v "object-2.2" > ${GREP_OUTPUT}
rev="HEAD~2"
echo "check visibilities of quads in revisions ${rev}" > ${INFO_OUTPUT}
curl_graph_store_get --repository ${repository} revision-id=${rev} | tr -s '\n' '\t' \
    | fgrep -v "object-3.1" | fgrep    "object-3.2" | fgrep -v "object-2.1" | fgrep -v "object-2.2" > ${GREP_OUTPUT}
rev="HEAD~1"
echo "check visibilities of quads in revisions ${rev}" > ${INFO_OUTPUT}
curl_graph_store_get --repository ${repository} revision-id=${rev} | tr -s '\n' '\t' \
    | fgrep -v "object-3.1" | fgrep -v "object-3.2" | fgrep    "object-2.1" | fgrep -v "object-2.2" > ${GREP_OUTPUT}
rev="HEAD"
echo "check visibilities of quads in revisions ${rev}" > ${INFO_OUTPUT}
curl_graph_store_get --repository ${repository} revision-id=${rev}   | tr -s '\n' '\t' \
    | fgrep -v "object-3.1" | fgrep -v "object-3.2" | fgrep    "object-2.1" | fgrep   "object-2.2" > ${GREP_OUTPUT}

echo "checking visibility vectors before trim-history" > ${INFO_OUTPUT}
get_visibility | tr -s '\n' '\t' | tee ${INFO_OUTPUT} \
    | fgrep    "\"object-3.1,${r2},${r3}\"" \
    | fgrep    "\"object-3.2,${r3},${r4}\"" \
    | fgrep    "\"object-2.1,${r4}\"" \
    | fgrep    "\"object-2.2,${r5}\"" > ${GREP_OUTPUT}


#repository_list_revisions --repository ${repository}

rev="HEAD~1"
echo "calling ${mode}: remove all revisions prior to ${rev}" > ${INFO_OUTPUT}
delete_revisions --repository ${repository} revision-id=${rev} mode="$mode" | fgrep -x 200 > ${GREP_OUTPUT}
repository_number_of_revisions --repository ${repository} | fgrep -x "3" > ${GREP_OUTPUT}
echo "have three revisions now: HEAD~1, HEAD, and a new revision from the trim-history command itself" > ${INFO_OUTPUT}

# repository_list_revisions --repository ${repository}


echo "check visibilities of quads in all revisions again after trim-history in mode \"${mode}\"" > ${INFO_OUTPUT}
rev="HEAD~2"
echo "check visibilities of quads in revisions ${rev} - boundary revision" > ${INFO_OUTPUT}
curl_graph_store_get --repository ${repository} revision-id=${rev} | tr -s '\n' '\t' \
    | fgrep -v "object-3.1" | fgrep -v "object-3.2" | fgrep    "object-2.1" | fgrep -v "object-2.2" > ${GREP_OUTPUT}
rev="HEAD~1"
echo "check visibilities of quads in revisions ${rev} - pivot revision" > ${INFO_OUTPUT}
curl_graph_store_get --repository ${repository} revision-id=${rev} | tr -s '\n' '\t' \
    | fgrep -v "object-3.1" | fgrep -v "object-3.2" | fgrep    "object-2.1" | fgrep    "object-2.2" > ${GREP_OUTPUT}
rev="HEAD"
echo "check visibilities of quads in revisions ${rev} - trim operation revision (identical to previous)" > ${INFO_OUTPUT}
curl_graph_store_get --repository ${repository} revision-id=${rev}   | tr -s '\n' '\t' \
    | fgrep -v "object-3.1" | fgrep -v "object-3.2" | fgrep    "object-2.1" | fgrep    "object-2.2" > ${GREP_OUTPUT}

echo "checking visibility vectors after trim-history in mode \"${mode}\"" > ${INFO_OUTPUT}
get_visibility | tr -s '\n' '\t' | tee ${INFO_OUTPUT} \
    | fgrep -v 'object-3.1' \
    | fgrep -v 'object-3.2' \
    | fgrep    "\"object-2.1,${r4}\"" \
    | fgrep    "\"object-2.2,${r5}\"" > ${GREP_OUTPUT}

done
