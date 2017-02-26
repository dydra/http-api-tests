#! /bin/bash

## test remote git integration
# start with a known dydra repository, create remote and local repositories,
# create local content (views and rdf), push them to the remote, check that
# they are present, modify/push/test, delete the remote and local repositories

# to run autonomously
# export AUTH_TOKEN="..."
# export STORE_URL="http://host"
# source ../../../define.sh

set -e

## create local and remote repositories
mkdir "git-integration-test"
cd "git-integration-test"
git init
git remote add dydra git@${STORE_HOST}:http-api-test.git
cat > README <<EOF
DO NOT SAVE ANYTHING HERE.
IT WILL BE DELETED WHEN THE TEST SUCCEEDS
EOF
mkdir -p jhacker/system
mkdir -p jhacker/test

ssh git@${STORE_HOST} create-repository http-api-test
ssh git@${STORE_HOST} list-repositories | fgrep -q http-api-test

## create local content
cat > jhacker/system/count.rq <<EOF
select (count(*) as ?count) where {?s ?p ?o}
EOF

cat > jhacker/system/drop.ru <<EOF
drop all
EOF

## push it
git add jhacker/system
git commit -m "initial commit" jhacker/system
git push dydra master

## create rdf content
cat > jhacker/system/config.ttl <<EOF
@prefix acl: <http://www.w3.org/ns/auth/acl#> .
@prefix foaf: <http://xmlns.com/foaf/0.1/> .
[] acl:accessTo <http://dydra.com/jhacker/test>;
   acl:mode acl:Read;
   acl:agentClass foaf:Agent .
EOF
git add jhacker/system/config.ttl
git commit -m "add configuration" -a
git push dydra master -o graph=http://dydra.com/jhacker/test

# add view to test
cat > jhacker/test/all.rq <<EOF
select ?s ?p ?o ?g
where { { graph ?g {?s ?p ?o} } union {?s ?p ?o} }
EOF
cat > jhacker/test/data.nq <<EOF
<http://example.org/subject> <http://example.org/predicate> "git default object" .
<http://example.org/subject> <http://example.org/predicate> "git graph object" <http://example.org/graph> .
EOF
cp jhacker/system/count.rq jhacker/test
git add jhacker/test
git commit -m "add view on test repository" -a
git push dydra master 

curl -s -X GET -u "$STORE_TOKEN:" -H "Accept: application/n-quads" "http://${STORE_HOST}/jhacker/test/all.srj" \
  | egrep -q '"git.*object"'

# if it progressed this far, it was successful, so cleanup
rm -r jhacker
git commit -m "remove test views" -a
git push dydra master 
cd ..
ssh git@${STORE_HOST} delete-repository http-api-test
rm -rf "git-integration-test"

