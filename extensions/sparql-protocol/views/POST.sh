#! /bin/bash

# a POST will always fail as it is not possible to modify the view properties,
# just to replace it and that is accomplished with a PUT
#

# POST fails
curl_sparql_view -X POST -w "%{http_code}\n" \
    -H "Content-Type: application/sparql-query" \
    --data-binary @- allput <<EOF | fgrep -q $STATUS_NOT_IMPLEMENTED
select * where {?s ?s ?d} # post
EOF
