#! /bin/bash

# retrieve all views from the remote sparql service
# if there is a local file of the corresponding name, put the content there
# otherwise, add it to the `./new` directory

set -e

fromHost=$1
fromAccount=$2
fromRepository=$3

fromToken=`cat ~/.dydra/${fromHost}.token`

curl -s -u ":${fromToken}" -H "Accept: text/plain" \
  https://${fromHost}/system/accounts/${fromAccount}/repositories/${fromRepository}/views > views-${fromHost}_${fromRepository}.txt
wc views-${fromHost}_${fromRepository}.txt

cat views-${fromHost}_${fromRepository}.txt | while read viewName ; do
    pathname=`find . -name "${viewName}.rq"`
    if [[ -z $pathname ]]; then pathname="./new/${viewName}.rq"; mkdir -p ./new ; fi
    echo "${viewName} -> ${pathname}"
    curl -s -H "Accept: application/sparql-query" -u ":${fromToken}" \
       "https://${fromHost}/system/accounts/${fromAccount}/repositories/${fromRepository}/views/${viewName}" > "${pathname}"
    echo
done

# bash get_views.sh dydra.com sparql-12 exists-tests