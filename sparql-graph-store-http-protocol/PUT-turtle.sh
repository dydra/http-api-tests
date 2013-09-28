#! /bin/bash

# the protocol target is a the repository, the statements include quads and the content type is n-triples:
# - triples are added to the default graph.
# - quads are added to the document graph. ?
# - each operation first clears the repository

curl -w "%{http_code}\n" -f -s -S -X PUT \
     -H "Content-Type: application/n-triples" \
     --data-binary @- \
     $STORE_URL/${STORE_ACCOUNT}/${STORE_REPOSITORY}?auth_token=${STORE_TOKEN} <<EOF \
  | fgrep -q "${PUT_SUCCESS}"
<http://example.com/default-subject>
    <http://example.com/default-predicate> "default object " , 
"named object PUT1" <${STORE_NAMED_GRAPH}-two> .
EOF


curl -f -s -S -X GET\
     -H "Accept: application/n-quads" \
     $STORE_URL/${STORE_ACCOUNT}/${STORE_REPOSITORY}?auth_token=${STORE_TOKEN} \
   | tr -s '\n' '\t' \
   | fgrep '"default object PUT1"' | fgrep '"named object PUT1"' | fgrep -v "<${STORE_NAMED_GRAPH}-two>" \
   | tr -s '\t' '\n' | wc -l | fgrep -q 2


initialize_repository | fgrep -q "${PUT_SUCCESS}"
