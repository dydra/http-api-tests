#! /bin/bash
set -e

# upload datasets texts to a remote repository.
# place in a graph corresponding to its directory
# assume that the directory names are unique
# assume that all are ttl

# cd SPARQL-exists
# bash ../test-tools/put_data.sh dydra.com sparql-12 sparql-exists 

toHost=$1
toAccount=$2
toRepository=$3

toToken=`cat ~/.dydra/${toHost}.token`

find . -name '*.ttl' > datasets.txt
wc datasets.txt

cat datasets.txt | fgrep -v manifest | sort | while read dataPathname ; do
    graphLeaf=`basename $dataPathname .ttl`
    graphPath=`dirname $dataPathname`
    graphName="http://www.w3c.org/"`basename ${graphPath}`/${graphLeaf}
    echo "${dataPathname} -> ${graphName}"
    curl -H "Content-Type: text/turtle" --user ":${toToken}" "https://dydra.com/sparql-12/exists-tests/service?graph=${graphName}" -X PUT --data-binary @${dataPathname}
    echo
    done

find . -name '*.nt' > datasets.txt
wc datasets.txt
cat datasets.txt | fgrep -v manifest | sort | while read dataPathname ; do
    graphLeaf=`basename $dataPathname .ttl`
    graphPath=`dirname $dataPathname`
    graphName="http://www.w3c.org/"`basename ${graphPath}`/${graphLeaf}
    echo "${dataPathname} -> ${graphName}"
    curl -H "Content-Type: application/n-triples" --user ":${toToken}" "https://dydra.com/sparql-12/exists-tests/service?graph=${graphName}" -X PUT --data-binary @${dataPathname}
    echo
    done

curl -X POST -H "Content-Type: application/sparql-query" -H "Accept: text/csv" \
     --user ":${toToken}" --data-binary @- \
     "https://dydra.com/sparql-12/exists-tests/sparql" <<EOF 
select distinct ?g where { graph ?g {?s ?p ?o} } order by ?g
EOF


# bash put_data.sh dydra.com sparql-12 exists-tests