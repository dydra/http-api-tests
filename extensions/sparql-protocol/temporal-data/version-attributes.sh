#! /bin/bash

# set a revisioned repository to a known state
# in order to apply queries with version attributes

### first, clear the repository
### checks, also that it exists
curl -X DELETE -H "Accept: text/turtle" --user ":${STORE_TOKEN}" \
  "https://${STORE_HOST}/system/accounts/test/repositories/test__rev/revisions"


## create three revisions
for i in 1 2 3; do
  curl_graph_store_update -X PUT -o /dev/null \
     -H "Content-Type: text/turtle" \
     --account test --repository test__rev <<EOF
<http://example.com/default-subject>
    <http://example.com/default-predicate> "default object PUT${i}" .
EOF
done

## verify single head
curl_sparql_request revision-id=HEAD \
   --account test --repository test__rev <<EOF \
   | tee $ECHO_OUTPUT | fgrep -c 'PUT3' | fgrep -q "1"
prefix dydra: <urn:dydra>
prefix time: <http://www.w3.org/2006/time#>
prefix : <http://example.org#>
select ?subject ?predicate ?object ?addedOrdinal ?deletedOrdinal
where {
   ?subject ?predicate ?object
}
EOF

## verify three revisions
curl_sparql_request 'revision-id=*--*' \
   --account test --repository test__rev <<EOF \
   | tee $ECHO_OUTPUT | fgrep -c 'PUT' | fgrep -q "3"
prefix dydra: <urn:dydra>
prefix time: <http://www.w3.org/2006/time#>
prefix : <http://example.org#>
select ?subject ?predicate ?object ?addedOrdinal ?deletedOrdinal
where {
   ?subject ?predicate ?object
}
EOF

## verify version attributes
curl_sparql_request 'revision-id=*--*' \
   --account test --repository test__rev <<EOF \
   | tee $ECHO_OUTPUT | fgrep -c 'PUT2' | fgrep -q "1"
prefix dydra: <urn:dydra>
prefix dydraOp: <http://dydra.com/sparql-functions#>
prefix time: <http://www.w3.org/2006/time#>
prefix : <http://example.org#>

select ?subject ?predicate ?object
       ?predecessorDeletedOrdinal ?addedOrdinal ?deletedOrdinal ?successorAddedOrdinal
where {
   # dydra:met-by is the end of previous visibility
   # dydra:starts is the current visibility with modified content
   # the added ordinal is 0, then the statements were added for the first time
   ?subject ?predicate ?object
          {| dydra:met-by ?predecessorDeletedOrdinal;
             dydra:starts ?addedOrdinal;
             dydra:finishes ?deletedOrdinal;
             dydra:meets ?successorAddedOrdinal |}.
    filter (?deletedOrdinal = dydraOp:repository-end-ordinal())
}
EOF
