#! /bin/bash

# request sql transations for generic sparql queries and verify them against known results
#

## proceed iff the service supports sql translation
curl_sparql_request -X GET -H "Accept: text/turtle" -H "Content-Type: " \
  | fgrep -q "formats/SQL"
if [ "0" != "$?" ]
then
  exit 0
fi

## test and note any failure
set +e
ls queries/generic/*.rq | while read sparql  ; do \
  curl -s -X POST https://stage.dydra.com:81/jhacker/foaf/sparql \
   -H "Content-Type: application/sparql-query"\
   -H "Accept: application/sql" \
   --data-binary "@$sparql" > `basename $sparql .rq`.out
  diff -q `basename $sparql .rq`.out `dirname $sparql`/`basename $sparql .rq`.sql
 if [ "0" == "$?" ]
 then
   rm `basename $sparql .rq`.out
 else
   echo "failed: $sparql";
 fi
done

ls *.out > /dev/null
if [ "0" == "$?" ]
then
  exit 1
else
  exit 0
fi


