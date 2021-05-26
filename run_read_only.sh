#! /bin/bash

# run those tests which are read-only.
# this means they can be run in parallel.

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
echo -n > failed_all.txt # start with empty output file
date
initialize_all_repositories
# problems with the repository content
# run extensions/git
# yes, although update as it intended to test asynchronous update
run extensions/graph-store-protocol
# no, writes the collation data # run extensions/sparql-protocol/collation
run extensions/sparql-protocol/meta-data
run extensions/sparql-protocol/describe
run extensions/sparql-protocol/parameters
# no, creates a provenance record run extensions/sparql-protocol/provenance
# no, creates revisions # run extensions/sparql-protocol/revisions
run extensions/sparql-protocol/sparql-operators
# some translations depend on gensym state
# run extensions/sparql-protocol/sql
run extensions/sparql-protocol/temporal-data
run extensions/sparql-protocol/values
# no, the CRD.sh modifies views # run extensions/sparql-protocol/views
run extensions/sparql-protocol/xpath-operators
# no, not this one, it modifies repitories # run sparql-graph-store-http-protocol
run sparql-protocol
run tickets
run triple-pattern-fragments
run web-ui

run accounts-api/accounts/openrdf-sesame/authorization/

echo
echo "${all_errors} errors for run_all.sh"
fi
