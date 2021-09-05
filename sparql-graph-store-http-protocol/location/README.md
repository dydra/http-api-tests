## graph store update requests with remote locations

If a request which includes a `Location` header, the graph content is to be retrieved from the
given location rather than conveyed in-line.
The `Content-Type` header is carried over from the request, is applied to the request to the
remote source and should be maintained in its response.

