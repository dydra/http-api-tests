#! /bin/bash

# the protocol target is the repository - as a direct graph, the content is trix:
# - triples are added to the document (default) graph.
# - quads are added to the document graph.
# - statements are removed from the document graphs only
# with the repository as the target, the effect is a PUT on the individual document graphs.

curl -w "%{http_code}\n" -f -s -X PATCH \
     -H "Content-Type: application/trix" \
     --data-binary @- \
     $STORE_URL/${STORE_ACCOUNT}/${STORE_REPOSITORY}?auth_token=${STORE_TOKEN} <<EOF \
   | grep_patch_success
<?xml version="1.0" encoding="utf-8"?>
<trix xmlns="http://www.w3.org/2004/03/trix/trix-1/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.w3.org/2004/03/trix/trix-1/ http://www.w3.org/2004/03/trix/trix-1/trix-1.0.xsd">
 <graph>
   <uri>${STORE_NAMED_GRAPH}-two</uri>
   <triple>
    <uri>http://example.com/default-subject</uri> <uri>http://example.com/named-predicate</uri> <plainLiteral>named object PATCH1</plainLiteral>
   </triple>
   </graph>
 <triple>
  <uri>http://example.com/default-subject</uri> <uri>http://example.com/default-predicate</uri> <plainLiteral>default object PATCH1</plainLiteral>
   </triple>
</trix>
EOF


curl -f -s -S -X GET\
     -H "Accept: application/n-quads" \
     $STORE_URL/${STORE_ACCOUNT}/${STORE_REPOSITORY}?auth_token=${STORE_TOKEN} \
   | tr -s '\n' '\t' \
   | fgrep -v '"default object"' | fgrep '"named object"' | fgrep "<${STORE_NAMED_GRAPH}>" \
   | fgrep '"default object PATCH1"' | fgrep '"named object PATCH1"' | fgrep  "<${STORE_NAMED_GRAPH}-two>" \
   | tr -s '\t' '\n' | wc -l | fgrep -q 3


curl -w "%{http_code}\n" -f -s -X PATCH \
     -H "Content-Type: application/trix" \
     --data-binary @- \
     $STORE_URL/${STORE_ACCOUNT}/${STORE_REPOSITORY}?auth_token=${STORE_TOKEN} <<EOF \
   | grep_patch_success
<?xml version="1.0" encoding="utf-8"?>
<trix xmlns="http://www.w3.org/2004/03/trix/trix-1/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.w3.org/2004/03/trix/trix-1/ http://www.w3.org/2004/03/trix/trix-1/trix-1.0.xsd">
 <graph>
   <uri>${STORE_NAMED_GRAPH}-two</uri>
   <triple>
    <uri>http://example.com/default-subject</uri> <uri>http://example.com/named-predicate</uri> <plainLiteral>named object PATCH2</plainLiteral>
   </triple>
   </graph>
 <triple>
  <uri>http://example.com/default-subject</uri> <uri>http://example.com/default-predicate</uri> <plainLiteral>default object PATCH2</plainLiteral>
   </triple>
</trix>
EOF


curl -f -s -S -X GET\
     -H "Accept: application/n-quads" \
     $STORE_URL/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}?auth_token=${STORE_TOKEN} \
   | tr -s '\n' '\t' \
   | fgrep -v '"default object"' | fgrep '"named object"' | fgrep "<${STORE_NAMED_GRAPH}>" \
   | fgrep -v '"default object PATCH1"' | fgrep -v '"named object PATCH1"' \
   | fgrep '"default object PATCH2"' | fgrep '"named object PATCH2"' | fgrep  "<${STORE_NAMED_GRAPH}-two>" \
   | tr -s '\t' '\n' | wc -l | fgrep -q 3


initialize_repository | grep_put_success
