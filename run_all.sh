#! /bin/bash

if [[ "$1" != "" ]]
then
  for ((i = 0; i < $1; i ++)) do
    echo -n "${i}: "
    bash run_all.sh
  done;
else
date
initialize_all_repositories
bash  ./run.sh extensions/git
bash  ./run.sh extensions/graph-store-protocol
bash  ./run.sh extensions/sparql-protocol/collation
bash  ./run.sh extensions/sparql-protocol/meta-data
bash  ./run.sh extensions/sparql-protocol/describe
bash  ./run.sh extensions/sparql-protocol/parameters
bash  ./run.sh extensions/sparql-protocol/provenance
bash  ./run.sh extensions/sparql-protocol/revisions
bash  ./run.sh extensions/sparql-protocol/sparql-operators
# some translations depend on gensym state
# bash  ./run.sh extensions/sparql-protocol/sql
bash  ./run.sh extensions/sparql-protocol/temporal-data
bash  ./run.sh extensions/sparql-protocol/values
bash  ./run.sh extensions/sparql-protocol/views
bash  ./run.sh extensions/sparql-protocol/xpath-operators
# no tests yet bash  ./run.sh linked-data-platform
bash  ./run.sh sparql-graph-store-http-protocol
bash  ./run.sh sparql-protocol
bash  ./run.sh tickets
bash  ./run.sh triple-pattern-fragments
bash  ./run.sh web-ui

bash  ./run.sh accounts-api/accounts/openrdf-sesame/authorization/
fi