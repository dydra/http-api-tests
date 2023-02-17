#! /bin/bash

# not really a tests but sourced in the other tests
# but can also ran as a simple test to make sure that
# ${STORE_REPOSITORY_REVISIONED} is really a revisioned repository

repository=${STORE_REPOSITORY_REVISIONED}
# repository=unrevisioned

if [[ "" == "${INFO_OUTPUT:-}" ]]
then
  export INFO_OUTPUT=${ECHO_OUTPUT} # /dev/null # /dev/tty
fi

if [[ "" == "${GREP_OUTPUT:-}" ]]
then
  export GREP_OUTPUT=${ECHO_OUTPUT} # /dev/null # /dev/tty
fi

if ( repository_is_revisioned --repository ${repository})
then
  echo -e "\n    ${0}: ${STORE_ACCOUNT}/${repository} is revisioned" > ${INFO_OUTPUT}
else
  echo -e "\n    ${0}: ${STORE_ACCOUNT}/${repository} is not revisioned" > ${INFO_OUTPUT}
  # We use the seperate repository ${STORE_REPOSITORY_REVISIONED} now,
  # which should always be revisioned. So error in case it is not:
  exit 1
fi

function add_quad() {
  local -a method=("-X" "POST")
  local object="object"
  while [[ "$#" > 0 ]] ; do
    case "$1" in
        -X) method[1]="${2}"; shift 2;;
        *) object+="-${1}"; shift 1;;
    esac
  done
  #echo "method: ${method[@]}" > ${INFO_OUTPUT}
  #echo "object: $object" > ${INFO_OUTPUT}

  before=$(repository_number_of_revisions --repository ${repository})

  echo "put in ${object}, thus adding revision" > ${INFO_OUTPUT}
  curl_graph_store_update --repository ${repository} ${method[@]} -o /dev/null <<EOF \
      | tee ${ECHO_OUTPUT}
<http://example.com/default-subject> <http://example.com/default-predicate> "${object}" <http://example.com/default-graph> .
EOF

  after=$(repository_number_of_revisions --repository ${repository})
  test $[$before+1] -eq $after
}

function get_visibility() {
  curl_sparql_request --repository ${repository} revision-id="*--*" \
    -H "Content-Type: application/sparql-query" \
    -H "Accept: application/json" <<EOF \
    | jq '.[] | join(",")' | tee ${ECHO_OUTPUT}
select ?o ?v where { graph ?g {?s ?p ?o {| <urn:dydra:copy> ?v |} } }
EOF
}
