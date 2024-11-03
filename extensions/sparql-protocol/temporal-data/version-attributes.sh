#! /bin/bash

# set a revisioned repository to a known state
# in order to apply queries with version attributes

if [[ "true" != "${STORE_STATEMENT_ANNOTATION:-}" ]]
then
  echo "no statement annotation";
  exit 0
fi

echo "first, create or clear the repository" > $ECHO_OUTPUT
create_repository --repository test__rev --class $STORE_REVISIONED_REPOSITORY_CLASS \
  | test_success
curl -s -X DELETE -H "Accept: text/turtle" --user ":${STORE_TOKEN}" -o $ECHO_OUTPUT \
  "https://${STORE_HOST}/system/accounts/test/repositories/test__rev/revisions"


echo "create three revisions" > $ECHO_OUTPUT
for i in 1 2 3; do
  curl_graph_store_update -X PUT -o $ECHO_OUTPUT \
     -H "Content-Type: text/turtle" \
     --account test --repository test__rev <<EOF
<http://example.com/default-subject>
    <http://example.com/default-predicate> "default object PUT${i}" .
EOF
done

echo "next, verify single head" > $ECHO_OUTPUT
curl_sparql_request revision-id=HEAD \
   --account test --repository test__rev <<EOF \
   | tee $ECHO_OUTPUT | fgrep -c 'PUT3' | fgrep -q "1"
prefix dydra: <urn:dydra>
prefix time: <http://www.w3.org/2006/time#>
prefix : <http://example.org#>
select ?subject ?predicate ?object
where {
   ?subject ?predicate ?object
}
EOF

echo "next, verify three revisions w/o attribute" > $ECHO_OUTPUT
curl_sparql_request 'revision-id=*--*' \
   --account test --repository test__rev <<EOF \
   | tee $ECHO_OUTPUT | fgrep -c 'PUT' | fgrep -q "3"
prefix dydra: <urn:dydra>
prefix time: <http://www.w3.org/2006/time#>
prefix : <http://example.org#>
select ?subject ?predicate ?object
where {
   ?subject ?predicate ?object
}
EOF


echo "next, verify three revisions w/ attribute" > $ECHO_OUTPUT
curl_sparql_request 'revision-id=*--*' \
   --account test --repository test__rev <<EOF \
   | tee $ECHO_OUTPUT | fgrep -c 'PUT' | fgrep -q "3"
prefix dydra: <urn:dydra>
prefix time: <http://www.w3.org/2006/time#>
prefix : <http://example.org#>
select ?subject ?predicate ?object ?addedOrdinal
where {
   ?subject ?predicate ?object {| dydra:starts ?addedOrdinal |}
}
EOF


echo "next, verify version attributes of the second revision" > $ECHO_OUTPUT
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
    # the end ordinal is for the third revision
    filter (?deletedOrdinal = dydraOp:repository-end-ordinal())
}
EOF


echo "next pass, with collated statements and PUT imports" > $ECHO_OUTPUT
### checks, also that it exists
curl -s -X DELETE -H "Accept: text/turtle" --user ":${STORE_TOKEN}" -o $ECHO_OUTPUT \
  "https://${STORE_HOST}/system/accounts/test/repositories/test__rev/revisions"


echo "create three revisions of collated statements" > $ECHO_OUTPUT
# the dataset includes the statement in distinct revisions
# the result is that HEAD or any specific revision sees just one set
# and an explicit interval is required to see the content of multiple revisions.
for i in 1 2 3; do
  curl_graph_store_update -X PUT -o $ECHO_OUTPUT \
     -H "Content-Type: text/turtle" \
     --account test --repository test__rev <<EOF
<http://example.com/default-subject>
    <http://example.com/default-predicate1> "default object PUT-o1${i}" ;
    <http://example.com/default-predicate2> "default object PUT-o2${i}" ;
    <http://example.com/default-predicate3> "default object PUT-o3${i}" .
EOF
done

echo "next, verify the consitution of each revision" > $ECHO_OUTPUT

for revision in "HEAD" "HEAD~" "HEAD~2"; do
  curl_sparql_request revision-id=${revision} \
     --account test --repository test__rev <<EOF \
     | tee $ECHO_OUTPUT | fgrep -c 'PUT' | fgrep -q "3"
  select ?subject ?predicate ?object
where {
   ?subject ?predicate ?object
}
EOF
done

echo "next, verify version attributes of the second revision with the filter" > $ECHO_OUTPUT
curl_sparql_request 'revision-id=*--*' \
   --account test --repository test__rev <<EOF \
   | tee $ECHO_OUTPUT | fgrep -c 'default-subject' | fgrep -q "9"
prefix dydra: <urn:dydra>
prefix dydraOp: <http://dydra.com/sparql-functions#>
prefix time: <http://www.w3.org/2006/time#>
prefix : <http://example.org#>

select ?subject ?predicate ?object
       ?predecessorDeletedOrdinal ?addedOrdinal ?deletedOrdinal ?successorAddedOrdinal ( dydraOp:repository-end-ordinal() as ?eo)
where {
   # dydra:met-by is the end of previous visibility
   # dydra:starts is the current visibility with modified content
   # the added ordinal is 0, then the statements were added for the first time
   # dydra:met-by is the end of previous visibility
   # dydra:starts is the current visibility with modified content
   # the added ordinal is 0, then the statements were added for the first time
   ?subject <http://example.com/default-predicate1> ?object1 .
   ?subject <http://example.com/default-predicate2> ?object2 {| dydra:met-by ?predecessorDeletedOrdinal; dydra:starts ?addedOrdinal; |} .
   ?subject <http://example.com/default-predicate3> ?object3 {| dydra:finishes ?deletedOrdinal; dydra:meets ?successorAddedOrdinal |}.
   filter (?deletedOrdinal = dydraOp:repository-end-ordinal())
}
EOF

### j-walker additions

echo "next pass, with POST imports which yield incrementally inserted statements" > $ECHO_OUTPUT
### checks, also that it exists
curl -s -X DELETE -H "Accept: text/turtle" --user ":${STORE_TOKEN}" -o $ECHO_OUTPUT \
  "https://${STORE_HOST}/system/accounts/test/repositories/test__rev/revisions"

echo "create three revisions" > $ECHO_OUTPUT
for i in 1 2 3; do
  curl_graph_store_update -X POST -o $ECHO_OUTPUT \
     -H "Content-Type: text/turtle" \
     --account test --repository test__rev default <<EOF
<http://example.com/default-subject>
    <http://example.com/default-predicate> "default object POST${i}" .
EOF
done

echo "next, verify revisions with the correct number of statements" > $ECHO_OUTPUT
curl_sparql_request revision-id=HEAD \
   --account test --repository test__rev <<EOF \
   | tee $ECHO_OUTPUT | fgrep -c 'POST' | fgrep -q "3"
select ?subject ?predicate ?object
where {
   ?subject ?predicate ?object
}
EOF
curl_sparql_request revision-id=HEAD~ \
   --account test --repository test__rev <<EOF \
   | tee $ECHO_OUTPUT | fgrep -c 'POST' | fgrep -q "2"
select ?subject ?predicate ?object
where {
   ?subject ?predicate ?object
}
EOF
curl_sparql_request revision-id=HEAD~2 \
   --account test --repository test__rev <<EOF \
   | tee $ECHO_OUTPUT | fgrep -c 'POST' | fgrep -q "1"
select ?subject ?predicate ?object
where {
   ?subject ?predicate ?object
}
EOF

echo "next, verify annotated statement pattern also returns the correct number of statements" > $ECHO_OUTPUT
curl_sparql_request revision-id=HEAD \
   --account test --repository test__rev <<EOF \
   | tee $ECHO_OUTPUT | fgrep -c 'POST' | fgrep -q "3"
prefix dydra: <urn:dydra>
select ?subject ?predicate ?object ?addedOrdinal
where {
   ?subject ?predicate ?object {| dydra:starts ?addedOrdinal |}
}
EOF
curl_sparql_request revision-id=HEAD~ \
   --account test --repository test__rev <<EOF \
   | tee $ECHO_OUTPUT | fgrep -c 'POST' | fgrep -q "2"
prefix dydra: <urn:dydra>
select ?subject ?predicate ?object ?addedOrdinal
where {
   ?subject ?predicate ?object {| dydra:starts ?addedOrdinal |}
}
EOF
curl_sparql_request revision-id=HEAD~2 \
   --account test --repository test__rev <<EOF \
   | tee $ECHO_OUTPUT | fgrep -c 'POST' | fgrep -q "1"
prefix dydra: <urn:dydra>
select ?subject ?predicate ?object ?addedOrdinal
where {
   ?subject ?predicate ?object {| dydra:starts ?addedOrdinal |}
}
EOF

echo "next, verify that three annotated statement pattern are visible for *--*" > $ECHO_OUTPUT
curl_sparql_request revision-id='*--*' \
   --account test --repository test__rev <<EOF \
   | tee $ECHO_OUTPUT | fgrep -c 'POST' | fgrep -q "3"
prefix dydra: <urn:dydra>
select ?subject ?predicate ?object ?addedOrdinal
where {
   ?subject ?predicate ?object {| dydra:starts ?addedOrdinal |}
}
EOF







