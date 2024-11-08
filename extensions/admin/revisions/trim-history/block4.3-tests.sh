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

add_quad -X POST 4.4b
repository_number_of_revisions --repository ${repository} | fgrep -x "2" > ${GREP_OUTPUT}
curl_graph_store_get --repository ${repository} | tr -s '\n' '\t' \
    | fgrep    "object-4.4b" | fgrep -v "object-4.4c" | fgrep -v "object-extra" | fgrep -v "object-foo" > ${GREP_OUTPUT}

add_quad -X POST 4.4c
repository_number_of_revisions --repository ${repository} | fgrep -x "3" > ${GREP_OUTPUT}
curl_graph_store_get --repository ${repository} | tr -s '\n' '\t' \
    | fgrep    "object-4.4b" | fgrep    "object-4.4c" | fgrep -v "object-extra" | fgrep -v "object-foo" > ${GREP_OUTPUT}

add_quad -X POST extra
repository_number_of_revisions --repository ${repository} | fgrep -x "4" > ${GREP_OUTPUT}
curl_graph_store_get --repository ${repository} | tr -s '\n' '\t' \
    | fgrep    "object-4.4b" | fgrep    "object-4.4c" | fgrep    "object-extra" | fgrep -v "object-foo" > ${GREP_OUTPUT}

add_quad -X POST foo # boundary revision
repository_number_of_revisions --repository ${repository} | fgrep -x "5" > ${GREP_OUTPUT}
curl_graph_store_get --repository ${repository} | tr -s '\n' '\t' \
    | fgrep    "object-4.4b" | fgrep    "object-4.4c" | fgrep    "object-extra" | fgrep    "object-foo" > ${GREP_OUTPUT}

##echo "before put extra, press key"; read
add_quad -X PUT extra # no change to extra itself but all other quads are deleted
##echo "after put extra, press key"; read
repository_number_of_revisions --repository ${repository} | fgrep -x "6" > ${GREP_OUTPUT}
curl_graph_store_get --repository ${repository} | tr -s '\n' '\t' \
    | fgrep -v "object-4.4b" | fgrep -v "object-4.4c" | fgrep    "object-extra" | fgrep -v "object-foo" > ${GREP_OUTPUT}

add_quad -X POST 4.4c # insert 4.4c again so that it has another ID after the pivot ID
repository_number_of_revisions --repository ${repository} | fgrep -x "7" > ${GREP_OUTPUT}
curl_graph_store_get --repository ${repository} | tr -s '\n' '\t' \
    | fgrep -v "object-4.4b" | fgrep    "object-4.4c" | fgrep    "object-extra" | fgrep -v "object-foo" > ${GREP_OUTPUT}


#repository_list_revisions --repository ${repository}

# HEAD~2 is boundary revision
# object-4.4b was inserted in HEAD~5 and deleted after the boundary in HEAD~1,
# object-4.4c was inserted in HEAD~4 and deleted after the boundary in HEAD~1 and inserted in HEAD again
# object-extra was inserted HEAD~3 (and is PUT again in HEAD~1 but that makes no difference to it)
# object-foo was inserted in HEAD~2 and deleted in HEAD~1

# Note on object-extra:
#   It is added as a PUT just after the boundary and not touched anymore after that.
#   Because of that, it has a delete and an insert with the pivot ID (= the ID after
#   the boundary in the visibilty index of that statement/quad), which are both equal
#   to the last ID (= the last ID in that visibility index).
#   This needs to be treated as a 4.4c case, that is, the post position (= position
#   after the pivot in that visibility index) needs to be retained.
#   This was a bug in the first version of the algorithm, which incorrectly treated
#   it as a 4.4b case and thus dropped the quad completely.

echo "check visibilities of quads in all revisions" > ${INFO_OUTPUT}
rev="HEAD~6"
echo "check visibilities of quads in revisions ${rev}: empty revision" > ${INFO_OUTPUT}
# HEAD~4 is tail and results in HTTP 404 already
#curl_graph_store_get --repository ${repository} revision-id=${rev} | tr -s '\n' '\t' \
#    | fgrep -v "object-3.1" | fgrep -v "object-3.2" | fgrep -v "object-2.1" | fgrep -v "object-2.2" > ${GREP_OUTPUT}

curl_graph_store_get -w '%{http_code}\n' --repository ${repository} revision-id=${rev} \
  | test_not_found
# fails on osx
#result=$(curl_graph_store_get_code_nofail --repository ${repository} revision-id=${rev} 2>&1 > /dev/null)
#test "$result" -eq "404"

rev="HEAD~5"
echo "check visibilities of quads in revisions ${rev}" > ${INFO_OUTPUT}
curl_graph_store_get --repository ${repository} revision-id=${rev} | tr -s '\n' '\t' \
    | fgrep    "object-4.4b" | fgrep -v "object-4.4c" | fgrep -v "object-extra" | fgrep -v "object-foo" > ${GREP_OUTPUT}
rev="HEAD~4"
echo "check visibilities of quads in revisions ${rev}" > ${INFO_OUTPUT}
curl_graph_store_get --repository ${repository} revision-id=${rev} | tr -s '\n' '\t' \
    | fgrep    "object-4.4b" | fgrep    "object-4.4c" | fgrep -v "object-extra" | fgrep -v "object-foo" > ${GREP_OUTPUT}
rev="HEAD~3"
echo "check visibilities of quads in revisions ${rev}" > ${INFO_OUTPUT}
curl_graph_store_get --repository ${repository} revision-id=${rev} | tr -s '\n' '\t' \
    | fgrep    "object-4.4b" | fgrep    "object-4.4c" | fgrep    "object-extra" | fgrep -v "object-foo" > ${GREP_OUTPUT}
rev="HEAD~2"
echo "check visibilities of quads in revisions ${rev}" > ${INFO_OUTPUT}
curl_graph_store_get --repository ${repository} revision-id=${rev} | tr -s '\n' '\t' \
    | fgrep    "object-4.4b" | fgrep    "object-4.4c" | fgrep    "object-extra" | fgrep    "object-foo" > ${GREP_OUTPUT}
rev="HEAD~1"
echo "check visibilities of quads in revisions ${rev}" > ${INFO_OUTPUT}
curl_graph_store_get --repository ${repository} revision-id=${rev} | tr -s '\n' '\t' \
    | fgrep -v "object-4.4b" | fgrep -v "object-4.4c" | fgrep    "object-extra" | fgrep -v "object-foo" > ${GREP_OUTPUT}
rev="HEAD"
echo "check visibilities of quads in revisions ${rev}"   > ${INFO_OUTPUT}
curl_graph_store_get --repository ${repository} revision-id=${rev}   | tr -s '\n' '\t' \
    | fgrep -v "object-4.4b" | fgrep    "object-4.4c" | fgrep    "object-extra" | fgrep -v "object-foo" > ${GREP_OUTPUT}

echo "checking visibility vectors before trim-history" > ${INFO_OUTPUT}
get_visibility | tr -s '\n' '\t' | tee ${INFO_OUTPUT} \
    | fgrep    "\"object-4.4b,${r2},${r6}\"" \
    | fgrep    "\"object-4.4c,${r3},${r6},${r7}\"" \
    | fgrep    "\"object-extra,${r4},${r6},${r6}\"" \
    | fgrep    "\"object-foo,${r5},${r6}\"" > ${GREP_OUTPUT}


# repository_list_revisions --repository ${repository}

##echo "before trim history in $mode, press key"; read
rev="HEAD~2"
echo "calling ${mode}: remove all revisions prior to ${rev}" > ${INFO_OUTPUT}
delete_revisions --repository ${repository} revision-id=${rev} mode="$mode" | fgrep -x 200 > ${GREP_OUTPUT}
##echo "after trim history in $mode, press key"; read
repository_number_of_revisions --repository ${repository} | fgrep -x "4" > ${GREP_OUTPUT}
echo "have four revisions now: HEAD~2 through HEAD, and a new revision from the trim-history command itself" > ${INFO_OUTPUT}

#repository_list_revisions --repository ${repository}

case "${mode}" in
    "project-history")

echo "check visibilities of quads in all revisions again after trim-history in mode \"${mode}\"" > ${INFO_OUTPUT}
rev="HEAD~3"
echo "check visibilities of quads in revisions ${rev}" > ${INFO_OUTPUT}
curl_graph_store_get --repository ${repository} revision-id=${rev} | tr -s '\n' '\t' \
    | fgrep    "object-4.4b" | fgrep    "object-4.4c" | fgrep    "object-extra" | fgrep    "object-foo" > ${GREP_OUTPUT}
rev="HEAD~2"
echo "check visibilities of quads in revisions ${rev}" > ${INFO_OUTPUT}
curl_graph_store_get --repository ${repository} revision-id=${rev} | tr -s '\n' '\t' \
    | fgrep -v "object-4.4b" | fgrep -v "object-4.4c" | fgrep    "object-extra" | fgrep -v "object-foo" > ${GREP_OUTPUT}
rev="HEAD~1"
echo "check visibilities of quads in revisions ${rev}" > ${INFO_OUTPUT}
curl_graph_store_get --repository ${repository} revision-id=${rev} | tr -s '\n' '\t' \
    | fgrep -v "object-4.4b" | fgrep    "object-4.4c" | fgrep    "object-extra" | fgrep -v "object-foo" > ${GREP_OUTPUT}
rev="HEAD"
echo "check visibilities of quads in revisions ${rev} - trim operation revision (identical to previous)"   > ${INFO_OUTPUT}
curl_graph_store_get --repository ${repository} revision-id=${rev}   | tr -s '\n' '\t' \
    | fgrep -v "object-4.4b" | fgrep    "object-4.4c" | fgrep    "object-extra" | fgrep -v "object-foo" > ${GREP_OUTPUT}

echo "checking visibility vectors after trim-history in mode \"${mode}\"" > ${INFO_OUTPUT}
get_visibility | tr -s '\n' '\t' | tee ${INFO_OUTPUT} \
    | fgrep    "\"object-4.4b,${r5},${r6}\"" \
    | fgrep    "\"object-4.4c,${r5},${r6},${r7}\"" \
    | fgrep    "\"object-extra,${r5},${r6},${r6}\"" \
    | fgrep    "\"object-foo,${r5},${r6}\"" > ${GREP_OUTPUT}

;;
    "delete-history")

echo "check visibilities of quads in all revisions again after trim-history in mode \"${mode}\"" > ${INFO_OUTPUT}
rev="HEAD~3"
echo "check visibilities of quads in revisions ${rev}" > ${INFO_OUTPUT}
curl_graph_store_get --repository ${repository} revision-id=${rev} | tr -s '\n' '\t' \
    | fgrep -v "object-4.4b" | fgrep -v "object-4.4c" | fgrep -v "object-extra" | fgrep    "object-foo" > ${GREP_OUTPUT}
rev="HEAD~2"
echo "check visibilities of quads in revisions ${rev}" > ${INFO_OUTPUT}
curl_graph_store_get --repository ${repository} revision-id=${rev} | tr -s '\n' '\t' \
    | fgrep -v "object-4.4b" | fgrep -v "object-4.4c" | fgrep    "object-extra" | fgrep -v "object-foo" > ${GREP_OUTPUT}
rev="HEAD~1"
echo "check visibilities of quads in revisions ${rev}" > ${INFO_OUTPUT}
curl_graph_store_get --repository ${repository} revision-id=${rev} | tr -s '\n' '\t' \
    | fgrep -v "object-4.4b" | fgrep    "object-4.4c" | fgrep    "object-extra" | fgrep -v "object-foo" > ${GREP_OUTPUT}
rev="HEAD"
echo "check visibilities of quads in revisions ${rev} - trim operation revision (identical to previous)"   > ${INFO_OUTPUT}
curl_graph_store_get --repository ${repository} revision-id=${rev}   | tr -s '\n' '\t' \
    | fgrep -v "object-4.4b" | fgrep    "object-4.4c" | fgrep    "object-extra" | fgrep -v "object-foo" > ${GREP_OUTPUT}

echo "checking visibility vectors after trim-history in mode \"${mode}\"" > ${INFO_OUTPUT}
get_visibility | tr -s '\n' '\t' | tee ${INFO_OUTPUT} \
    | fgrep -v 'object-4.4b' \
    | fgrep    "\"object-4.4c,${r7}\"" \
    | fgrep    "\"object-extra,${r6}\"" \
    | fgrep    "\"object-foo,${r5},${r6}\"" > ${GREP_OUTPUT}

;;
    *) echo "Error: unknown mode \"${mode}\""
       exit 2
;;
esac

done
