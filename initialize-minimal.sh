#! /bin/bash


# create one account/repository for each of various authorization combinations
#
#  $STORE_ACCOUNT                           : the base account
#  $STORE_ACCOUNT/$STORE_REPOSITORY         : owner authorization for read/write - the normal case
#  $STORE_ACCOUNT/$STORE_REPOSITORY-write   : owner authorization for read/write - the normal case (this one is modified)
#  $STORE_ACCOUNT/$STORE_REPOSITORY_PUBLIC  : owner plus anonymous (agent) read
#  $STORE_ACCOUNT/collation
#  $STORE_ACCOUNT/inference
#  $STORE_ACCOUNT/ldp
#  $STORE_ACCOUNT/tpf


#
# n.b. creation requires admin priviledges

# the general process is

# unset STORE_URL
# unset STORE_TOKEN
# unset STORE_TOKEN_COLLABORATOR
# unset STORE_TOKEN_ADMIN
# export STORE_HOST=<host>.dydra.com
# bash initialize-minimal.sh


# http api tests : repository creation and content initialization
set -e
if [[ "" == "${STORE_TOKEN}" ]]
then source ./define.sh
fi

for account in ${STORE_ACCOUNT} jhacker test; do create_account $account; done

for repository in ${STORE_REPOSITORY} ${STORE_REPOSITORY_WRITABLE} ${STORE_REPOSITORY_PUBLIC} ${STORE_REPOSITORY_PROVENANCE} \
                  foaf collation inference ldp public tpf; do
    create_repository --repository $repository --class ${STORE_REPOSITORY_CLASS}
done
create_repository --account test --repository test --class ${STORE_REPOSITORY_CLASS}
create_repository --account test --repository foaf --class ${STORE_REPOSITORY_CLASS}
create_repository --account system --repository null --class ${STORE_REPOSITORY_CLASS}

# authorization and metadata :
# add authorization for authenticated users to read the repository list either from both accounts-api and the sesame resources

${CURL} -w "%{http_code}\n" -L -f -s -X POST \
     -H "Content-Type: application/n-quads" --data-binary @- \
     -u ":${STORE_TOKEN_ADMIN}" \
     ${STORE_URL}/${STORE_ACCOUNT}/system/service <<EOF \
     | tee ${ECHO_OUTPUT} |  egrep -q "${STATUS_POST_SUCCESS}"
_:aclBase1 <http://www.w3.org/ns/auth/acl#accessTo> <http://${STORE_SITE}/accounts/${STORE_ACCOUNT}/repositories> <http://${STORE_SITE}/accounts/${STORE_ACCOUNT}> .
_:aclBase1 <http://www.w3.org/ns/auth/acl#accessTo> <http://${STORE_SITE}/${STORE_ACCOUNT}/repositories> <http://${STORE_SITE}/accounts/${STORE_ACCOUNT}> .
_:aclBase1 <http://www.w3.org/ns/auth/acl#mode> <http://www.w3.org/ns/auth/acl#Read> <http://${STORE_SITE}/accounts/${STORE_ACCOUNT}> .
_:aclBase1 <http://www.w3.org/ns/auth/acl#agent> <urn:dydra:User> <http://${STORE_SITE}/accounts/${STORE_ACCOUNT}> .
_:aclBase2 <http://www.w3.org/ns/auth/acl#accessTo> <http://${STORE_SITE}/accounts/${STORE_ACCOUNT}/repositories> <http://${STORE_SITE}/accounts/${STORE_ACCOUNT}> .
_:aclBase2 <http://www.w3.org/ns/auth/acl#accessTo> <http://${STORE_SITE}/${STORE_ACCOUNT}/repositories> <http://${STORE_SITE}/accounts/${STORE_ACCOUNT}> .
_:aclBase2 <http://www.w3.org/ns/auth/acl#mode> <http://www.w3.org/ns/auth/acl#Read> <http://${STORE_SITE}/accounts/${STORE_ACCOUNT}> .
_:aclBase2 <http://www.w3.org/ns/auth/acl#agent> <http://xmlns.com/foaf/0.1/Agent> <http://${STORE_SITE}/accounts/${STORE_ACCOUNT}> .
EOF

# twice, in order to get a second revision
initialize_repository_content
initialize_repository_content
initialize_repository_public

${CURL} -w "%{http_code}\n" -L -f -s -X POST \
     -H "Content-Type: text/turtle" --data-binary @- \
     -u ":${STORE_TOKEN}" \
     ${STORE_URL}/${STORE_ACCOUNT}/foaf/service <<EOF \
     | tee ${ECHO_OUTPUT} |  egrep -q "${STATUS_POST_SUCCESS}"
@base <http://dydra.com/> .
@prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .

<http://www.setf.de/#self>
    a <http://xmlns.com/foaf/0.1/Project> ;
    <http://xmlns.com/foaf/0.1/homepage> <https://rdf4j.org> ;
    <http://xmlns.com/foaf/0.1/mbox> <rdf4j-dev@eclipse.org> ;
    <http://xmlns.com/foaf/0.1/name> "Eclipse RDF4J" .
EOF



#  ${STORE_ACCOUNT}/${STORE_REPOSITORY_PUBLIC}    : owner plus anonymous (agent) read
# metadata w/ anonymous read access
${CURL} -w "%{http_code}\n" -L -f -s -X POST \
     -H "Content-Type: application/n-quads" --data-binary @- \
     -u ":${STORE_TOKEN}" \
     ${STORE_URL}/${STORE_ACCOUNT}/system/service <<EOF \
     | tee ${ECHO_OUTPUT} | egrep -q "${STATUS_POST_SUCCESS}"
_:aclAnon <http://www.w3.org/ns/auth/acl#accessTo> <http://${STORE_SITE}/${STORE_ACCOUNT}/${STORE_REPOSITORY_PUBLIC}> <http://${STORE_SITE}/accounts/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY_PUBLIC}> .
_:aclAnon <http://www.w3.org/ns/auth/acl#accessTo> <http://${STORE_SITE}/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY_PUBLIC}> <http://${STORE_SITE}/accounts/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY_PUBLIC}> .
_:aclAnon <http://www.w3.org/ns/auth/acl#accessTo> <http://${STORE_SITE}/accounts/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY_PUBLIC}> <http://${STORE_SITE}/accounts/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY_PUBLIC}> .
_:aclAnon <http://www.w3.org/ns/auth/acl#mode> <http://www.w3.org/ns/auth/acl#Read> <http://${STORE_SITE}/accounts/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY_PUBLIC}> .
_:aclAnon <http://www.w3.org/ns/auth/acl#agent> <http://xmlns.com/foaf/0.1/Agent> <http://${STORE_SITE}/accounts/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY_PUBLIC}> .
<http://${STORE_SITE}/accounts/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY_PUBLIC}> <http://purl.org/dc/elements/1.1/description> "An account to test anonymous access to its content" <http://${STORE_SITE}/accounts/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY_PUBLIC}> .
EOF

# and minimal data
${CURL} -w "%{http_code}\n" -L -f -s -X PUT \
     -H "Accept: application/n-quads" \
     -H "Content-Type: application/n-quads" --data-binary @- \
     -u "${STORE_TOKEN}:" \
     ${STORE_URL}/${STORE_ACCOUNT}/${STORE_REPOSITORY_PUBLIC}/service <<EOF \
     | tee ${ECHO_OUTPUT} |  egrep -q "${STATUS_PUT_SUCCESS}"
<http://example.com/subject> <http://example.com/predicate> "object" <${STORE_URL}>.
EOF

## also for the test/foaf repository
${CURL} -w "%{http_code}\n" -L -f -s -X POST \
     -H "Content-Type: application/n-quads" --data-binary @- \
     -u ":${STORE_TOKEN}" \
     ${STORE_URL}/test/foaf/service <<EOF \
     | tee ${ECHO_OUTPUT} |  egrep -q "${STATUS_POST_SUCCESS}"
<http://www.setf.de/#self> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://xmlns.com/foaf/0.1/Agent> .
<http://www.setf.de/#self> <http://xmlns.com/foaf/0.1/name> "test" .
<http://www.setf.de/#self> <http://xmlns.com/foaf/0.1/homepage> <http://dydra.com/test> .
<http://www.setf.de/#self> <http://xmlns.com/foaf/0.1/mbox> <mailto:test@dydra.com> .
EOF

echo done
