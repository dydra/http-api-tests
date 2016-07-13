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
bash  ./run.sh extensions/sparql-protocol/temporal-data
bash  ./run.sh extensions/sparql-protocol/collation
bash  ./run.sh extensions/sparql-protocol/provenance
bash  ./run.sh extensions/sparql-protocol/xpath-operators
bash  ./run.sh extensions/sparql-protocol/values
bash  ./run.sh extensions/sparql-protocol/meta-data
bash  ./run.sh extensions/sparql-protocol/describe
bash  ./run.sh extensions/sparql-protocol/sparql-operators
bash  ./run.sh extensions/sparql-protocol/revisions
bash  ./run.sh sparql-protocol
bash  ./run.sh sparql-graph-store-http-protocol
bash  ./run.sh triple-pattern-fragments
fi