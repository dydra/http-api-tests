## graph store update requests with successors

If a request which includes a `Successor-Location` header,
the query content is to be retrieved from the
given location rather than conveyed in-line.
The `Successor-Content-Type` header can specifiy the media type.
Otherwise it the default `application/sparql-query` applies.

The import status result is as for a normal update request.
The query itsle is executed as an asynchronous requests, for
which the result is handled based on the `Asynchronous-` headers.


