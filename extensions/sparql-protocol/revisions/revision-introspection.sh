#! /bin/bash

# exercise revision introspection

if ( repository_has_revisions )
then
  # no successor for HEAD
  resultCount=11
else
  # no predecessor or successor
  resultCount=9
fi

curl_sparql_request revision-id=HEAD <<EOF \
   | tee $ECHO_OUTPUT | egrep -c '"revision.*: ' | fgrep -q "$resultCount"
prefix dydra: <http://dydra.com/sparql-functions#>
select (dydra:repository-revision-count() as ?revisionCount)
       (dydra:repository-revision-url() as ?revisionURL)
       (dydra:revision-ordinal() as ?revisionOrdinal)
       (dydra:revision-uri() as ?revisionURI)
       (dydra:revision-urn() as ?revisionURN)
       (dydra:revision-date-time() as ?revisionDateTime)
       (dydra:revision-commit-timestamp() as ?revisionCommitTimestamp)
       (dydra:revision-begin-timestamp() as ?revisionBeginTimestamp)
       (dydra:revision-predecessor-uuid() as ?revisionPredecessorUUID)
       (dydra:revision-uuid() as ?revisionUUID)
       (dydra:revision-successor-uuid() as ?revisionSuccessorUUID)
       (dydra:repository-revision-url(dydra:revision-predecessor-uuid()) as ?revisionPredecessorURL)
where {}

EOF






