#! /bin/bash

function run () {
  bash ./run.sh $@
  let "all_errors += $?"
  cat failed.txt >> failed_all.txt
}

set_store_features
echo "features: "
echo "STORE_STATEMENT_ANNOTATION = ${STORE_STATEMENT_ANNOTATION}"
echo "STORE_INDEXED_TIMES = ${STORE_INDEXED_TIMES}"
echo "STORE_INDEXED_EVENTS = ${STORE_INDEXED_EVENTS}"
echo "REVISIONED_REPOSITORY_CLASS = $REVISIONED_REPOSITORY_CLASS"
if [[ "$1" != "" ]]
then
  for ((i = 0; i < $1; i ++)) do
    echo -n "${i}: "
    bash run_all.sh
  done;
else
all_errors=0
echo -n > failed_all.txt # start with empty output file
date
initialize_all_repositories
# problems with the repository content
# run extensions/git
# 20230814 confuses the curl_sparql_request operator
#run extensions/admin/revisions
run extensions/graph-store-protocol
run extensions/sparql-protocol/collation
run extensions/sparql-protocol/meta-data
run extensions/sparql-protocol/describe
run extensions/sparql-protocol/free-text
run extensions/sparql-protocol/parameters
run extensions/sparql-protocol/provenance
run extensions/sparql-protocol/revisions
run extensions/sparql-protocol/sparql-operators
run extensions/quality-of-service
# some translations depend on gensym state
# run extensions/sparql-protocol/sql
run extensions/sparql-protocol/temporal-data
run extensions/sparql-protocol/values
run extensions/sparql-protocol/views
run extensions/sparql-protocol/xpath-operators
# no tests yet run linked-data-platform
run sparql-graph-store-http-protocol
run sparql-protocol
run tickets
run triple-pattern-fragments
run web-ui

run accounts-api/accounts/openrdf-sesame/authorization/

echo
echo "${all_errors} errors for run_all.sh"
fi
