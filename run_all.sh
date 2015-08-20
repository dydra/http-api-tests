#! /bin/bash
date
initialize_all_repositories
bash  ./run.sh extensions/sparql-protocol/temporal-data
bash  ./run.sh extensions/sparql-protocol/collation
bash  ./run.sh extensions/sparql-protocol/provenance
bash  ./run.sh extensions/sparql-protocol/xpath-operators
bash  ./run.sh extensions/sparql-protocol/values
bash  ./run.sh extensions/sparql-protocol/meta-data
bash  ./run.sh extensions/sparql-protocol/describe
bash  ./run.sh extensions/sparql-protocol/meta-data
bash  ./run.sh extensions/sparql-protocol/sparql-operators
bash  ./run.sh extensions/sparql-protocol/describe
bash  ./run.sh sparql-protocol
bash  ./run.sh sparql-graph-store-http-protocol
