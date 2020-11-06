#! /bin/bash

function run () {
  bash ./run.sh $@
  let "all_errors += $?"
  cat failed.txt >> failed_all.txt
}

if [[ "$1" != "" ]]
then
  for ((i = 0; i < $1; i ++)) do
    echo -n "${i}: "
    bash run_all.sh
  done;
else
all_errors=0
date | tee failed_all.txt # no append to start with empty output file
initialize_all_repositories
# problems with the repository content
# run extensions/git
run extensions/graph-store-protocol
run extensions/sparql-protocol/collation
run extensions/sparql-protocol/meta-data
run extensions/sparql-protocol/describe
run extensions/sparql-protocol/parameters
run extensions/sparql-protocol/provenance
run extensions/sparql-protocol/revisions
run extensions/sparql-protocol/sparql-operators
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

echo "${all_errors} errors for run_all.sh" | tee -a failed_all.txt
fi
