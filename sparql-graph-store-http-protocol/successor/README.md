## graph store update requests with successors

If a request which includes a `Successor-Location` header,
a follow-on query is executed when the initial request completes successfully.
The query content is to be retrieved from the given location.
The `Successor-Content-Type` header can specifiy the media type.
Otherwise it the default `application/sparql-query` applies.

The import status result is as for a normal update request.
The query itself is executed as an asynchronous request, from
which the result is directed according to the `Asynchronous-` headers.

