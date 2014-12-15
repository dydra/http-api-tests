#! /bin/bash


# http api tests : repository creation and content initialization
set -e
source ./definitions.sh
export STORE_TOKEN_ADMIN=`cat ~/.dydra/token-admin@${STORE_HOST}`

# create one account/repository for each of various authorization combinations
#
#  $ACCOUNT                       : the base account
#  $ACCOUNT-anon                  : allowing anonymous access to its profile and repository list
#  $ACCOUNT-read                  : granted read authorization to the -byuser repository
#  $ACCOUNT-write                 : granted write authorization to the -byuser repository
#  $ACCOUNT-readwrite             : granted read/write authorization to the -byuser repository
#  $ACCOUNT/$REPOSITORY           : owner authorization for read/write - the normal case
#  $ACCOUNT/$REPOSITORY-write     : owner authorization for read/write - the normal case (this one is modified)
#  $ACCOUNT/$REPOSITORY-public    : owner plus anonymous (agent) read
#  $ACCOUNT/$REPOSITORY-user      : owner plus authenticated (user) read
#  $ACCOUNT/$REPOSITORY-byuser    : owner plus access specific to user
#  $ACCOUNT/$REPOSITORY-readbyip  : owner plus read for $STORE_CLIENT_IP for any agent
#  $ACCOUNT/$REPOSITORY-writebyip : owner plus write for $STORE_CLIENT_IP for any user (not just agent)
#
# n.b. creation requires admin priviledges


#  $ACCOUNT                     : the base account

${CURL} -w "%{http_code}\n" -f -s -X POST -H "Content-Type: application/json" --data-binary @- \
     ${STORE_URL}/accounts?auth_token=${STORE_TOKEN_ADMIN} <<EOF \
 |  egrep -q "${STATUS_POST_SUCCESS}"
{"account": {"name": "${STORE_ACCOUNT}"} }
EOF

# authorization and metadata :
# add authorization for authenticated users to read the repository list either from both accounts-api and the sesame resources

${CURL} -w "%{http_code}\n" -L -f -s -X POST \
     -H "Content-Type: application/n-quads" --data-binary @- \
     ${STORE_URL}/${STORE_ACCOUNT}/system?auth_token=${STORE_TOKEN_ADMIN} <<EOF \
 |  egrep -q "${STATUS_POST_SUCCESS}"
_:aclBase1 <http://www.w3.org/ns/auth/acl#accessTo> <http://${STORE_SITE}/accounts/${STORE_ACCOUNT}/repositories> <http://${STORE_SITE}/accounts/${STORE_ACCOUNT}> .
_:aclBase1 <http://www.w3.org/ns/auth/acl#accessTo> <http://${STORE_SITE}/${STORE_ACCOUNT}/repositories> <http://${STORE_SITE}/accounts/${STORE_ACCOUNT}> .
_:aclBase1 <http://www.w3.org/ns/auth/acl#mode> <http://www.w3.org/ns/auth/acl#Read> <http://${STORE_SITE}/accounts/${STORE_ACCOUNT}> .
_:aclBase1 <http://www.w3.org/ns/auth/acl#agentClass> <urn:dydra:User> <http://${STORE_SITE}/accounts/${STORE_ACCOUNT}> .
_:aclBase2 <http://www.w3.org/ns/auth/acl#accessTo> <http://${STORE_SITE}/accounts/${STORE_ACCOUNT}/repositories> <http://${STORE_SITE}/accounts/${STORE_ACCOUNT}> .
_:aclBase2 <http://www.w3.org/ns/auth/acl#accessTo> <http://${STORE_SITE}/${STORE_ACCOUNT}/repositories> <http://${STORE_SITE}/accounts/${STORE_ACCOUNT}> .
_:aclBase2 <http://www.w3.org/ns/auth/acl#mode> <http://www.w3.org/ns/auth/acl#Read> <http://${STORE_SITE}/accounts/${STORE_ACCOUNT}> .
_:aclBase2 <http://www.w3.org/ns/auth/acl#agentClass> <http://xmlns.com/foaf/0.1/Agent> <http://${STORE_SITE}/accounts/${STORE_ACCOUNT}> .
EOF


#  $ACCOUNT-anon                : allowing anonymous profile and repository list access

${CURL} -w "%{http_code}\n" -f -s -X POST -H "Content-Type: application/json" --data-binary @- \
     ${STORE_URL}/accounts?auth_token=${STORE_TOKEN_ADMIN} <<EOF \
 |  egrep -q "${STATUS_POST_SUCCESS}"
{"account": {"name": "${STORE_ACCOUNT}-anon"} }
EOF

# authorization and metadata

${CURL} -w "%{http_code}\n" -L -f -s -X POST \
     -H "Content-Type: application/n-quads" --data-binary @- \
     ${STORE_URL}/${STORE_ACCOUNT}-anon/system?auth_token=${STORE_TOKEN_ADMIN} <<EOF \
 |  egrep -q "${STATUS_POST_SUCCESS}"
_:acl1 <http://www.w3.org/ns/auth/acl#accessTo> <http://${STORE_SITE}/accounts/${STORE_ACCOUNT}-anon/profile> <http://${STORE_SITE}/accounts/${STORE_ACCOUNT}-anon> .
_:acl1 <http://www.w3.org/ns/auth/acl#mode> <http://www.w3.org/ns/auth/acl#Read> <http://${STORE_SITE}/accounts/${STORE_ACCOUNT}-anon> .
_:acl1 <http://www.w3.org/ns/auth/acl#agentClass> <http://xmlns.com/foaf/0.1/Agent> <http://${STORE_SITE}/accounts/${STORE_ACCOUNT}-anon> .
<http://${STORE_SITE}/accounts/${STORE_ACCOUNT}-anon> <http://purl.org/dc/elements/1.1/description> "An account to test anonymous access its profile" <http://${STORE_SITE}/accounts/${STORE_ACCOUNT}-anon> .
EOF



#  $ACCOUNT/$REPOSITORY         : owner authorization for read/write - the normal case
# the 'standard' account corresponds to the name in the sesame protocol documentation
# authorization:  owner authorization for read/write - the normal case

${CURL} -w "%{http_code}\n" -f -s -X POST -H "Content-Type: application/json" --data-binary @- \
     ${STORE_URL}/accounts?auth_token=${STORE_TOKEN_ADMIN} <<EOF \
 |  egrep -q "${STATUS_POST_SUCCESS}"
{"account": {"name": "${STORE_ACCOUNT}"} }
EOF

# the standard repository w/ an extensive configuration

${CURL} -w "%{http_code}\n" -f -s -X POST -H "Content-Type: application/json" --data-binary @- \
     -u "${STORE_TOKEN}:" \
     ${STORE_URL}/accounts/${STORE_ACCOUNT}/repositories <<EOF \
 |  egrep -q "${STATUS_POST_SUCCESS}"
{"repository": {"name": "${STORE_REPOSITORY}"} }
EOF

initialize_repository_configuration ;
initialize_repository_content ;

${CURL} -w "%{http_code}\n" -f -s -X POST -H "Content-Type: application/json" --data-binary @- \
     -u "${STORE_TOKEN}:" \
     ${STORE_URL}/accounts/${STORE_ACCOUNT}/repositories <<EOF \
 |  egrep -q "${STATUS_POST_SUCCESS}"
{"repository": {"name": "${STORE_REPOSITORY}-write"} }
EOF


#  $ACCOUNT/$REPOSITORY-public    : owner plus anonymous (agent) read

${CURL} -w "%{http_code}\n" -f -s -X POST -H "Content-Type: application/json" --data-binary @- \
     -u "${STORE_TOKEN}:" \
     ${STORE_URL}/accounts/${STORE_ACCOUNT}/repositories <<EOF \
 |  egrep -q "${STATUS_POST_SUCCESS}"
{"repository": {"name": "${STORE_REPOSITORY}-public"} }
EOF
# (initialize-repository-metadata (repository "openrdf-sesame/mem-rdf-public"))

# metadata w/ anonymous read access
${CURL} -w "%{http_code}\n" -L -f -s -X POST \
     -H "Content-Type: application/n-quads" --data-binary @- \
     -u "${STORE_TOKEN}:" \
     ${STORE_URL}/${STORE_ACCOUNT}/system <<EOF \
 |  egrep -q "${STATUS_POST_SUCCESS}"
_:aclAnon <http://www.w3.org/ns/auth/acl#accessTo> <http://${STORE_SITE}/${STORE_ACCOUNT}/${STORE_REPOSITORY}-public> <http://${STORE_SITE}/accounts/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}-public> .
_:aclAnon <http://www.w3.org/ns/auth/acl#accessTo> <http://${STORE_SITE}/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}-public> <http://${STORE_SITE}/accounts/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}-public> .
_:aclAnon <http://www.w3.org/ns/auth/acl#accessTo> <http://${STORE_SITE}/accounts/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}-public> <http://${STORE_SITE}/accounts/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}-public> .
_:aclAnon <http://www.w3.org/ns/auth/acl#mode> <http://www.w3.org/ns/auth/acl#Read> <http://${STORE_SITE}/accounts/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}-public> .
_:aclAnon <http://www.w3.org/ns/auth/acl#agentClass> <http://xmlns.com/foaf/0.1/Agent> <http://${STORE_SITE}/accounts/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}-public> .
<http://${STORE_SITE}/accounts/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}-public> <http://purl.org/dc/elements/1.1/description> "An account to test anonymous access to its content" <http://${STORE_SITE}/accounts/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}-public> .
EOF

# and minimal data
${CURL} -w "%{http_code}\n" -L -f -s -X PUT \
     -H "Accept: application/n-quads" \
     -H "Content-Type: application/n-quads" --data-binary @- \
     -u "${STORE_TOKEN}:" \
     ${STORE_URL}/${STORE_ACCOUNT}/${STORE_REPOSITORY}-public <<EOF \
  |  egrep -q "${STATUS_PUT_SUCCESS}"
<http://example.com/subject> <http://example.com/predicate> "object" <${STORE_URL}>.
EOF



#  $ACCOUNT/$REPOSITORY-user : owner plus authenticated (user) read

${CURL} -w "%{http_code}\n" -f -s -X POST -H "Content-Type: application/json" --data-binary @- \
     -u "${STORE_TOKEN}:" \
     ${STORE_URL}/accounts/${STORE_ACCOUNT}/repositories <<EOF \
 |  egrep -q "${STATUS_POST_SUCCESS}"
{"repository": {"name": "${STORE_REPOSITORY}-user"} }
EOF

# metadata w/ authenticated user read access
${CURL} -w "%{http_code}\n" -L -f -s -X POST \
     -H "Content-Type: application/n-quads" --data-binary @- \
     -u "${STORE_TOKEN}:" \
     ${STORE_URL}/${STORE_ACCOUNT}/system <<EOF \
 |  egrep -q "${STATUS_POST_SUCCESS}"
_:aclUser <http://www.w3.org/ns/auth/acl#accessTo> <http://${STORE_SITE}/${STORE_ACCOUNT}/${STORE_REPOSITORY}-user> <http://${STORE_SITE}/accounts/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}-user> .
_:aclUser <http://www.w3.org/ns/auth/acl#accessTo> <http://${STORE_SITE}/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}-user> <http://${STORE_SITE}/accounts/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}-user> .
_:aclUser <http://www.w3.org/ns/auth/acl#accessTo> <http://${STORE_SITE}/accounts/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}-user> <http://${STORE_SITE}/accounts/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}-user> .
_:aclUser <http://www.w3.org/ns/auth/acl#mode> <http://www.w3.org/ns/auth/acl#Read> <http://${STORE_SITE}/accounts/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}-user> .
_:aclUser <http://www.w3.org/ns/auth/acl#agentClass> <urn:dydra:User> <http://${STORE_SITE}/accounts/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}-user> .
<http://${STORE_SITE}/accounts/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}-user> <http://purl.org/dc/elements/1.1/description> "An account to test all-user access to its content" <http://${STORE_SITE}/accounts/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}-user> .
EOF

# and minimal data
${CURL} -w "%{http_code}\n" -L -f -s -X PUT \
     -H "Accept: application/n-quads" \
     -H "Content-Type: application/n-quads" --data-binary @- \
     -u "${STORE_TOKEN}:" \
     ${STORE_URL}/${STORE_ACCOUNT}/${STORE_REPOSITORY}-user <<EOF \
 |  egrep -q "${STATUS_PUT_SUCCESS}"
<http://example.com/subject> <http://example.com/predicate> "object" <${STORE_URL}>.
EOF



#  $ACCOUNT/$REPOSITORY-byuser : owner plus authenticated (user) read

${CURL} -w "%{http_code}\n" -f -s -X POST -H "Content-Type: application/json" --data-binary @- \
     -u "${STORE_TOKEN}:" \
     ${STORE_URL}/accounts/${STORE_ACCOUNT}/repositories <<EOF \
 |  egrep -q "${STATUS_POST_SUCCESS}"
{"repository": {"name": "${STORE_REPOSITORY}-byuser"} }
EOF
# to reset: (initialize-repository-metadata (repository "openrdf-sesame/mem-rdf-byuser"))

# metadata w/ anonymous access specific to user
${CURL} -w "%{http_code}\n" -L -f -s -X POST \
     -H "Content-Type: application/n-quads" --data-binary @- \
     -u "${STORE_TOKEN}:" \
     ${STORE_URL}/${STORE_ACCOUNT}/system <<EOF \
 |  egrep -q "${STATUS_POST_SUCCESS}"
_:aclRead <http://www.w3.org/ns/auth/acl#accessTo> <http://${STORE_SITE}/${STORE_ACCOUNT}/${STORE_REPOSITORY}-byuser> <http://${STORE_SITE}/accounts/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}-byuser> .
_:aclRead <http://www.w3.org/ns/auth/acl#accessTo> <http://${STORE_SITE}/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}-byuser> <http://${STORE_SITE}/accounts/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}-byuser> .
_:aclRead <http://www.w3.org/ns/auth/acl#accessTo> <http://${STORE_SITE}/accounts/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}-byuser> <http://${STORE_SITE}/accounts/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}-byuser> .
_:aclRead <http://www.w3.org/ns/auth/acl#mode> <http://www.w3.org/ns/auth/acl#Read> <http://${STORE_SITE}/accounts/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}-byuser> .
_:aclRead <http://www.w3.org/ns/auth/acl#agent> <http://${STORE_SITE}/users/${STORE_ACCOUNT}-read> <http://${STORE_SITE}/accounts/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}-byuser> .
_:aclWrite <http://www.w3.org/ns/auth/acl#accessTo> <http://${STORE_SITE}/${STORE_ACCOUNT}/${STORE_REPOSITORY}-byuser> <http://${STORE_SITE}/accounts/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}-byuser> .
_:aclWrite <http://www.w3.org/ns/auth/acl#accessTo> <http://${STORE_SITE}/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}-byuser> <http://${STORE_SITE}/accounts/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}-byuser> .
_:aclWrite <http://www.w3.org/ns/auth/acl#accessTo> <http://${STORE_SITE}/accounts/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}-byuser> <http://${STORE_SITE}/accounts/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}-byuser> .
_:aclWrite <http://www.w3.org/ns/auth/acl#mode> <http://www.w3.org/ns/auth/acl#Write> <http://${STORE_SITE}/accounts/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}-byuser> .
_:aclWrite <http://www.w3.org/ns/auth/acl#agent> <http://${STORE_SITE}/users/${STORE_ACCOUNT}-write> <http://${STORE_SITE}/accounts/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}-byuser> .
_:aclReadWrite <http://www.w3.org/ns/auth/acl#accessTo> <http://${STORE_SITE}/${STORE_ACCOUNT}/${STORE_REPOSITORY}-byuser> <http://${STORE_SITE}/accounts/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}-byuser> .
_:aclReadWrite <http://www.w3.org/ns/auth/acl#accessTo> <http://${STORE_SITE}/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}-byuser> <http://${STORE_SITE}/accounts/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}-byuser> .
_:aclReadWrite <http://www.w3.org/ns/auth/acl#accessTo> <http://${STORE_SITE}/accounts/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}-byuser> <http://${STORE_SITE}/accounts/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}-byuser> .
_:aclReadWrite <http://www.w3.org/ns/auth/acl#mode> <http://www.w3.org/ns/auth/acl#Read> <http://${STORE_SITE}/accounts/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}-byuser> .
_:aclReadWrite <http://www.w3.org/ns/auth/acl#mode> <http://www.w3.org/ns/auth/acl#Write> <http://${STORE_SITE}/accounts/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}-byuser> .
_:aclReadWrite <http://www.w3.org/ns/auth/acl#agent> <http://${STORE_SITE}/users/${STORE_ACCOUNT}-readwrite> <http://${STORE_SITE}/accounts/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}-byuser> .
<http://${STORE_SITE}/accounts/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}-byuser> <http://purl.org/dc/elements/1.1/description> "An account to test specific user access to its content" <http://${STORE_SITE}/accounts/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}-byuser> .
EOF


# with the necessary accounts

${CURL} -w "%{http_code}\n" -f -s -X POST -H "Content-Type: application/json" --data-binary @- \
     -u "${STORE_TOKEN_ADMIN}:" \
     ${STORE_URL}/accounts <<EOF \
 |  egrep -q "${STATUS_POST_SUCCESS}"
{"account": {"name": "${STORE_ACCOUNT}-read"} }
EOF
# to reset: (initialize-account-metadata (account "openrdf-sesame-read"))

${CURL} -w "%{http_code}\n" -f -s -X POST -H "Content-Type: application/json" --data-binary @- \
     -u "${STORE_TOKEN_ADMIN}:" \
     ${STORE_URL}/accounts <<EOF \
 |  egrep -q "${STATUS_POST_SUCCESS}"
{"account": {"name": "${STORE_ACCOUNT}-write"} }
EOF
# to reset: (initialize-account-metadata (account "openrdf-sesame-write"))

${CURL} -w "%{http_code}\n" -f -s -X POST -H "Content-Type: application/json" --data-binary @- \
     -u "${STORE_TOKEN_ADMIN}:" \
     ${STORE_URL}/accounts <<EOF \
 |  egrep -q "${STATUS_POST_SUCCESS}"
{"account": {"name": "${STORE_ACCOUNT}-readwrite"} }
EOF
# to reset: (initialize-account-metadata (account "openrdf-sesame-readwrite"))

# and authentication
${CURL} -w "%{http_code}\n" -L -f -s -X POST \
     -H "Content-Type: application/n-quads" --data-binary @- \
     -u "${STORE_TOKEN_ADMIN}:" \
     ${STORE_URL}/system/system <<EOF \
 |  egrep -q "${STATUS_POST_SUCCESS}"
<http://${STORE_SITE}/accounts/${STORE_ACCOUNT}-read> <urn:dydra:accessToken> "${STORE_TOKEN}_READ" <http://${STORE_SITE}/accounts/${STORE_ACCOUNT}-read> .
<http://${STORE_SITE}/accounts/${STORE_ACCOUNT}-write> <urn:dydra:accessToken> "${STORE_TOKEN}_WRITE" <http://${STORE_SITE}/accounts/${STORE_ACCOUNT}-write> .
<http://${STORE_SITE}/accounts/${STORE_ACCOUNT}-readwrite> <urn:dydra:accessToken> "${STORE_TOKEN}_READWRITE" <http://${STORE_SITE}/accounts/${STORE_ACCOUNT}-readwrite> .
EOF

# and minimal data
${CURL} -w "%{http_code}\n" -L -f -s -X PUT \
     -H "Accept: application/n-quads" \
     -H "Content-Type: application/n-quads" --data-binary @- \
     -u "${STORE_TOKEN}:" \
     ${STORE_URL}/${STORE_ACCOUNT}/${STORE_REPOSITORY}-byuser <<EOF \
 |  egrep -q "${STATUS_PUT_SUCCESS}"
<http://example.com/subject> <http://example.com/predicate> "object" <${STORE_URL}>.
EOF


#  $ACCOUNT/$REPOSITORY-readbyip : owner plus read for $STORE_CLIENT_IP for any agent

${CURL} -w "%{http_code}\n" -f -s -X POST -H "Content-Type: application/json" --data-binary @- \
     -u "${STORE_TOKEN}:" \
     ${STORE_URL}/accounts/${STORE_ACCOUNT}/repositories <<EOF \
 |  egrep -q "${STATUS_POST_SUCCESS}"
{"repository": {"name": "${STORE_REPOSITORY}-readbyip"} }
EOF
# to reset: (initialize-repository-metadata (repository "openrdf-sesame/mem-rdf-readbyip"))

# metadata w/ anonymous access specific to user

${CURL} -w "%{http_code}\n" -L -f -s -X POST \
     -H "Content-Type: application/n-quads" --data-binary @- \
     -u "${STORE_TOKEN}:" \
     ${STORE_URL}/${STORE_ACCOUNT}/system <<EOF \
 |  egrep -q "${STATUS_POST_SUCCESS}"
_:aclReadByIp <http://www.w3.org/ns/auth/acl#accessTo> <http://${STORE_SITE}/${STORE_ACCOUNT}/${STORE_REPOSITORY}-readbyip> <http://${STORE_SITE}/accounts/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}-readbyip> .
_:aclReadByIp <http://www.w3.org/ns/auth/acl#accessTo> <http://${STORE_SITE}/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}-readbyip> <http://${STORE_SITE}/accounts/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}-readbyip> .
_:aclReadByIp <http://www.w3.org/ns/auth/acl#accessTo> <http://${STORE_SITE}/accounts/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}-readbyip> <http://${STORE_SITE}/accounts/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}-readbyip> .
_:aclReadByIp <http://www.w3.org/ns/auth/acl#mode> <http://www.w3.org/ns/auth/acl#Read> <http://${STORE_SITE}/accounts/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}-readbyip> .
_:aclReadByIp <http://www.w3.org/ns/auth/acl#agentClass> <http://xmlns.com/foaf/0.1/Agent> <http://${STORE_SITE}/accounts/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}-readbyip> .
_:aclReadByIp <http://rdfs.org/sioc/ns#ip_address>  "${STORE_CLIENT_IP}" <http://${STORE_SITE}/accounts/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}-readbyip> .
<http://${STORE_SITE}/accounts/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}-byuser> <http://purl.org/dc/elements/1.1/description> "An account to test ip-restricted read access" <http://${STORE_SITE}/accounts/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}-readbyip> .
EOF

# and minimal data
${CURL} -w "%{http_code}\n" -L -f -s -X PUT \
     -H "Accept: application/n-quads" \
     -H "Content-Type: application/n-quads" --data-binary @- \
     -u "${STORE_TOKEN}:" \
     ${STORE_URL}/${STORE_ACCOUNT}/${STORE_REPOSITORY}-readbyip <<EOF \
 |  egrep -q "${STATUS_PUT_SUCCESS}"
<http://example.com/subject> <http://example.com/predicate> "object" <${STORE_URL}>.
EOF



#  $ACCOUNT/$REPOSITORY-writebyip : owner plus write for $STORE_CLIENT_IP for any user

${CURL} -w "%{http_code}\n" -f -s -X POST -H "Content-Type: application/json" --data-binary @- \
     -u "${STORE_TOKEN}:" \
     ${STORE_URL}/accounts/${STORE_ACCOUNT}/repositories <<EOF \
 |  egrep -q "${STATUS_POST_SUCCESS}"
{"repository": {"name": "${STORE_REPOSITORY}-writebyip"} }
EOF
# to reset: (initialize-repository-metadata (repository "openrdf-sesame/mem-rdf-writebyip"))

# metadata w/ anonymous access specific to user

${CURL} -w "%{http_code}\n" -L -f -s -X POST \
     -H "Content-Type: application/n-quads" --data-binary @- \
     -u "${STORE_TOKEN}:" \
     ${STORE_URL}/${STORE_ACCOUNT}/system <<EOF \
 |  egrep -q "${STATUS_POST_SUCCESS}"
_:aclWriteByIp <http://www.w3.org/ns/auth/acl#accessTo> <http://${STORE_SITE}/${STORE_ACCOUNT}/${STORE_REPOSITORY}-writebyip> <http://${STORE_SITE}/accounts/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}-writebyip> .
_:aclWriteByIp <http://www.w3.org/ns/auth/acl#accessTo> <http://${STORE_SITE}/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}-writeby> <http://${STORE_SITE}/accounts/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}-writebyip> .
_:aclWriteByIp <http://www.w3.org/ns/auth/acl#accessTo> <http://${STORE_SITE}/accounts/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}-writebyip> <http://${STORE_SITE}/accounts/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}-writebyip> .
_:aclWriteByIp <http://www.w3.org/ns/auth/acl#mode> <http://www.w3.org/ns/auth/acl#Write> <http://${STORE_SITE}/accounts/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}-writebyip> .
_:aclWriteByIp <http://www.w3.org/ns/auth/acl#agentClass> <urn:dydra:User> <http://${STORE_SITE}/accounts/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}-writebyip> .
_:aclWriteByIp <http://rdfs.org/sioc/ns#ip_address>  "${STORE_CLIENT_IP}" <http://${STORE_SITE}/accounts/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}-writebyip> .
<http://${STORE_SITE}/accounts/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}-byuser> <http://purl.org/dc/elements/1.1/description> "An account to test ip-restricted write access" <http://${STORE_SITE}/accounts/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}-writebyip> .
EOF

# and minimal data
${CURL} -w "%{http_code}\n" -L -f -s -X PUT \
     -H "Accept: application/n-quads" \
     -H "Content-Type: application/n-quads" --data-binary @- \
     -u "${STORE_TOKEN}:" \
     ${STORE_URL}/${STORE_ACCOUNT}/${STORE_REPOSITORY}-writebyip <<EOF \
 |  egrep -q "${STATUS_PUT_SUCCESS}"
<http://example.com/subject> <http://example.com/predicate> "object" <${STORE_URL}>.
EOF
