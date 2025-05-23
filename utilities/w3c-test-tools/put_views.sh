#! /bin/bash
set -e

# copy all sparql query texts to views on a remote repository.
# assume that the names are unique

toHost=$1
toAccount=$2
toRepository=$3

toToken=`cat ~/.dydra/${toHost}.token`

find . -name '*.rq' > views.txt
wc views.txt

cat views.txt | while read viewPathname ; do
    viewName=`basename $viewPathname .rq`
    echo "${viewPathname} -> ${toAccount}/${toRepository}/${viewName}"
    curl -s -X PUT -H "Accept: application/n-quads" -H "Content-Type: application/sparql" \
      --data-binary @- -u ":${toToken}" \
      "https://${toHost}/${toAccount}/${toRepository}/${viewName}" < "${viewPathname}"
    done


# bash put_views.sh dydra.com sparql-12 exists-tests
# bash put_views.sh dydra.com sparql-12 upload-test