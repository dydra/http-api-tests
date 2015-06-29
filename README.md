# HTTP API tests

This repository comprises tests for the DYDRA RDF cloud service:
- The Sesame HTTP communication protocol,
- The SPARQL graph store HTTP protocol,
- The SPARQL query protocol,
- The DYDRA account administration HTTP API
- DYDRA extension tests for
 - language-specific collation
 - request meta-data
 - provenance
 - sort precedence
 - temporal operators
 - values request parameter
 - xpath operators

[![Build Status](https://travis-ci.org/dydra/http-api-tests.svg?branch=master)](https://travis-ci.org/dydra/http-api-tests)

---

These tests are implemented as shell scripts and arranged according to topic.
The root directory contains several utility scripts which establish the test environment,
administer the target repositories and execute tests.

- `define.sh`
Defines the shell environment variables and operators to be employed by the test scripts
- `ìnitialize.sh`
Creates the test target repositories with respective meta-data and content.
- `reset.sh`
Resets test target repository content
- `run.sh`
Runs a given collection of test scripts, reports the outcomes.
Observes known failures from `known-to-fail.txt`.
Records new failures in the file `failures.txt`.
Returns the error count as its result.

The scripts are arranged in directories which reflect the protocol resource paths.
The account (`openrdf-sesame`) and repository (`mem-rdf`) are defined such that,
for the sesame protocol tests, the openrdf documentation examples should
apply, as given in its documentation.


In order to execute scripts manually:

- Establish values for the shell variables:
  - `STORE_URL` : the HTTP URI to specify the remote host.
  - `STORE_ACCOUNT` : the account name.
  - `STORE_REPOSITORY` : the repository name eg.
  - `STORE_TOKEN` : an authentication if authentication is required.
- Define the shell environment: `source define.sh`
- Run the desired script(s) :
  - `run_tests <pathnames>`
  - `run.sh <directory`

For example

    export STORE_URL="https://dydra.com"
    export STORE_ACCOUNT="openrdf-sesame"
    export STORE_REPOSITORY="mem-rdf"
    export STORE_TOKEN="1234567890"
    source define.sh
    bash run.sh extensions/sparql-protocol/temporal-data

Note that numerous scripts modify the shell variable bindings to correspond to particular variations
in repository, graph, or user and, as such, must be run in a distinct sub-shell in order that the
modification not be pervasive.

The test environment includes a range of repositories and users, as described in the `initialize.sh`
script, in order to account for variations in access and authorization. As a rule, the default
repository, that is "${STORE_ACCOUNT}/${STORE_REPOSITORY}" is treated as read-only, in order that
most tests need to no set-up and/or tear-down.
Any modification is restricted to "${STORE_ACCOUNT}/${STORE_REPOSITORY}-write" and every tests which
modifies that repository also initializes it to the required state.

---

## Dependencies

The tests are coded as bash shell scripts. They depend on several utility programs:
- `jq` : `apt-get install jq`
- `json_reformat` : `apt-get install yajl-tools`
- `rapper` : `apt-get install raptor2-utils`

---

## Sesame HTTP communication protocol

These tests exercise the Sesame rest api, as per the OpenRDF "HTTP communication protocol"
[description](http://www.openrdf.org/doc/sesame2/system/ch08.html),
[or](http://openrdf.callimachus.net/sesame/2.7/docs/system.docbook?view#chapter-http-protocol).
For the v2.0 Sesame protocol, the concrete resources, with reference to
the described overview:

        ${STORE_URL}/${STORE_ACCOUNT}
          /protocol              : protocol version (GET)
          /repositories          : overview of available repositories (GET)
          /${STORE_REPOSITORY}   : query evaluation and administration tasks on 
                                   a repository (GET/POST/DELETE)
            /statements          : repository statements (GET/POST/PUT/DELETE)
            /contexts            : context overview (GET)
            /size                : #statements in repository (GET)
            /rdf-graphs          : named graphs overview (GET)
                /service         : Graph Store operations on indirectly referenced named graphs 
                                   in repository (GET/PUT/POST/DELETE)
                                   includes the query argument graph=${STORE_IGRAPH}
                /${STORE_RGRAPH} : Graph Store operations on directly referenced named graphs 
                                   in repository (GET/PUT/POST/DELETE)
            /namespaces          : overview of namespace definitions (GET/DELETE)
                /${STORE_PREFIX} : namespace-prefix definition (GET/PUT/DELETE)

The compact graph store patterns provide and alternative, less encumbered means
to address the resource and its content:

        ${STORE_URL}/${STORE_ACCOUNT}
          /${STORE_REPOSITORY}
          /${STORE_REPOSITORY}?default               : the default graph
          /${STORE_REPOSITORY}?graph=${STORE_IGRAPH} : an arbitrary indirect graph
                               graph=urn:dydra:service-description : the repository SPARQL endpoint service description
          /${STORE_REPOSITORY}/${STORE_RGRAPH}       : graph relative to the repository base url


In addition to these paths, the account and repository metadata is located along a path
distinct from possible repository linked-data resources:

        ${STORE_URL}/accounts/${STORE_ACCOUNT}
        /repositories
          /${STORE_REPOSITORY}
            /settings            : name, homepage, summary, description, and license url
            /collaborations      : enumerated collaborator account read/write privliges
            /context_terms       : respective extent of the default and named graps
            /describe_settings   : description mode and navigation depth
            /prefixes            : default namespace prefix bindings (cf. sesame namespaces)
            /privacy             : repository privacy setting
            /provenance_repository : respective provenanace repository identifier
            /service_description : the repository SPARQL endpoint service description
            /undefined_variable_behaviour : disposition for queries with unbound variables


The scripts test a subset of the accept formats:
- For repository content

    - RDF/XML :   `application/rdf+xml`
    - N-Triples : `text/plain, application/n-triples`
    - TriX :      `application/trix`
    - JSON :      `application/json`
    - N-Quads :   `application/n-quads`

- For query results and metadata

    - XML :       `application/sparql-results+xml`
    - JSON :      `application/sparql-results+json`

The scripts cover variations of access privileges, content- and accept-type,
and resource existence. 
Test successes are judged against either against the HTTP status code, or, for
requests with response content, against result prototypes as canonicalized per xmllint
and json_reformat. Test failures match against the HTTP status code.


### Graph store support through the Sesame HTTP protocol

The graph store support under [sesame](http://www.openrdf.org/doc/sesame2/system/ch08.html#d0e659)
provides two resource patterns. 

    <SESAME_URL>/repositories/<ID>/rdf-graphs/service
    <SESAME_URL>/repositories/<ID>/rdf-graphs/<NAME>

The first, for which the path ends in `service`, requires an additional `graph` query argument
to designated the referenced graph indirectly, while in the second case, the request url itself
designates that graph.

Note that, given the [discussion](http://www.openrdf.org/issues/browse/SES-895)
on the openrdf topic, the designator for a directly referenced named graph in a
sesame request URI is the literal URL. That is, it includes the "/repositories" text.

> The SPARQL 1.1 Graph Store HTTP Protocol is supported on a per-repository basis. 
> The functionality is accessible at <SESAME_URL>/repositories/<ID>/rdf-graphs/service 
> (for indirectly referenced named graphs), and <SESAME_URL>/repositories/<ID>/rdf-graphs/<NAME> 
> (for directly referenced named graphs). 
> A request on a directly referenced named graph entails that the request URL itself is used
> as the named graph identifier in the repository.


For a repository on a DYDRA host, the sesame request patterns manifest in terms of the host authority, the
user account and the repository name

    <HTTP-HOST>/<ACCOUNT-NAME>/repositories/<REPOSITORY-NAME>/service
    <HTTP-HOST>/<ACCOUNT-NAME>/repositories/<REPOSITORY-NAME>/<NAME>

The consequence is that, in order to designate the repository as a whole, the sesame request URL must take a form

    <HTTP-HOST>/<ACCOUNT-NAME>/repositories/<REPOSITORY-NAME>/service?graph=<HTTP-HOST>/<ACCOUNT-NAME>/<REPOSITORY-NAME>

and the default graph is designated as

    <HTTP-HOST>/<ACCOUNT-NAME>/repositories/<REPOSITORY-NAME>/service?default

While a request of the form

    <HTTP-HOST>/<ACCOUNT-NAME>/repositories/<REPOSITORY-NAME>/<NAME>

designate exactly that named graph in the store.


## SPARQL graph store protocol

The "SPARQL 1.1 Graph Store HTTP Protocol", is supported as per the W3C
[recommendation](http://www.w3.org/TR/sparql11-http-rdf-update/), with the several additions and restrictions.

### Graph store request Content type

A graph store request may include as content or specify as its response any of the following RDF document encodings
- application/n-triples
- application/n-quads
- application/turtle
- application/rdf+xml

Several forms are restricted

- application/rdf+json : supported for responses only
- application/trix : supported for responses only

Several forms are no longer supported, as they have been supplanted by registered media types

- text/plain
- application/rdf-triples
- text/x-nquads
- application/x-turtle

The `multipart/form-data` request media type described in the graph store
[protocol](http://www.w3.org/TR/2013/REC-sparql11-http-rdf-update-20130321/#graph-management)
is not supported. Each request must comprise a single document.

The `application/x-www-form-url-encoded` request type is not supported by the graph store protocol.
It applies to SPARQL ˚POST˚ requests only, as described in the SPARQL
protocol for [query](http://www.w3.org/TR/2013/REC-sparql11-protocol-20130321/#query-via-post-urlencoded)
and [update](http://www.w3.org/TR/2013/REC-sparql11-protocol-20130321/#update-via-post-urlencoded) operations. 



### Graph Specification
a request which omits a graph designator is understood to apply to the entire repository.
For a repository on a Dydra host, the native request patterns comprise just the host authority, the
user account and the repository name, with the `service` path extension.

    <HTTP-HOST>/<ACCOUNT-NAME>/<REPOSITORY-NAME>/service

with respect to which, the default graph is designated as

    <HTTP-HOST>/<ACCOUNT-NAME>/<REPOSITORY-NAME>/service?default

and an indirect graph reference takes the form

    <HTTP-HOST>/<ACCOUNT-NAME>/<REPOSITORY-NAME>/service?graph=<graph>


## Linked data designators

In addition to the root repository graph, it is also possible to link directly to
an arbitrary directly designated graph which extends beyon the root

    <HTTP-HOST>/<ACCOUNT-NAME>/<REPOSITORY-NAME>/<FURTHER>/<PATH>/<STEPS>


## Triples, quads and named graphs in import requests

The graph store management operations which involve an RDF payload - `PATCH`, `POST`, and `PUT`,
permit a request to target a specific graph as described above, as well as to transfer graph content
as TriX or N-Quads in order to stipulate the target graph for statements in the payload document itself.
The protocol and document specifications are not exclusive.

When both appear,
the protocol graph specifies which graph is to be cleared by a put and
that graph supersedes any specified in the document content
with respect to the destination graph.
Where no protocol graph is specified for a `POST` request, a new graph is generated.
Where none is specified for other methods, the entire repository is the target.

With the following possible values for a graph:
- <code><i>default</i></code> : the default graph
- <code><i>post</i></code> : a unique UUID generated for a POST request
- <code><i>statement</i></code> : the graph specified in the statement, or _default_ for triples.
The combinations yield the following effects for <code><b>PATCH</b></code>, <code><b>POST</b></code> and <code><b>PUT</b></code>:


<table  border=0 cellpadding=2px cellspacing=0 >

<tr >
<th >protocol graph designator<th  >content type<th  >effective graph</tr>
<tr >
  <td rowspan="2">-
  <td>n-triples, rdf+xml 
  <td > <code><b>PATCH</b></code>: <code><i>default</i></code> <br /> <code><b>POST</b></code>: <code><i>post</i></code><br /> <code><b>PUT</b></code>: <code><i>default</i></code> </tr>
<tr >
<td >n-quad, trix <td > <code><i>statement</i></code> </tr>

<td  rowspan="2"><code><b>default</b></code>
  <td>n-triples, rdf+xml
  <td ><code><i>default</i></code></tr>
<tr >
  <td  >n-quads, trix
  <td ><code><i>default</i></code></tr>

<tr >
  <td  rowspan="2" ><code><b>graph=</b><i>protocol</i></code>
  <td>n-triples, rdf+xml
  <td><code><i>protocol</i></code></tr>
<tr >
  <td  >n-quads, trix 
  <td><code><i>protocol</i></code></tr>

<tr>
  <td><code><i>protocol</i></code></td>
  <td colspan="2">not supported</td></tr>
</table>

The results for <code><b>DELETE</b></code> and <code><b>GET</b></code> operations are analogous to <code><b>PUT</b></code> with respect to repository modifications
or response content.
A <code><b>PATCH</b></code> operation without a protocol graph, in distinction to a <code><b>PUT</b></code>, clears just the graphs present in the content.

In order to validate the results, one script exists for the <code><b>POST</b></code> and <code><b>PUT</b></code> operations for
each of the combinations, named according to the pattern

    <method>-<contentTypes>-<protocolGraph>.sh

which performs a <code><b>PUT</b></code> request of the respective content type and graph combination
and validates the content of a subsequent <code><b>GET</b></code>
as a reflections of the expected store content.
The combination features are indicated as

 - method : code><b>POST</b></code> <code><b>PUT</b></code>
 - protocolGraph : <i>none</i>, direct, default, graph (indirect)
 - contentType : n-triples, n-quads, rdf+xml, turtle, trix

whereby, just the combinations for `PUT-ntriples+nquads` validate the full target graph complement and,
among these, the cases like `PUT-ntriples+nquads-default` intend to demonstrate the
effect when the payload or request content type differs from the protocol target graph.
In addition, for n-triples and n-quads content types, the acutual document contains both triples and quads
in order to demonstrate the consequence of the statement's given content on its destination.

<table style="background-color: red">
<tr><th>script</th><th>requirement</th></tr>

<tr><td>POST-ntriples+nquads-default.sh</td>
    <td>Each statement is added to the default graph. Graph terms in content are suppressed.</td>
    </tr>

<tr><td>POST-ntriples+nquads-direct.sh</td>
    <td>not supported</td>
    </tr>

<tr><td>POST-ntriples+nquads-graph.sh</td>
    <td>Each statement is added to the target graph. Graph terms in content are supplanted.</td>
    </tr>

<tr><td>POST-ntriples+nquads.sh</td>
    <td>When no protocol graph is specified, for declared triple media, each statement is added to
        a new, generated, graph and for declared quad content, each statement is added to
        its respective graph.</td>
    </tr>

<tr><td>PUT-ntriples+nquads-default.sh</td>
    <td>The default graph is cleared.
        Each statement is added to the default graph. Graph terms in content are suppressed.</td>
    </tr>

<tr><td>PUT-ntriples+nquads-direct.sh</td>
    <td>not supported</td>
    </tr>

<tr><td>PUT-ntriples+nquads-graph.sh</td>
    <td>The protocol graph is cleared.
        Each statement is added to the target graph. Graph terms in content are supplanted.</td>
    </tr>

<tr><td>PUT-ntriples+nquads.sh</td>
    <td>The entire repository is cleared.
        Each statement is added to the target graph. Graph terms in content are supplanted.</td>
    </tr>

</table>

## SPARQL query protocol

Each DYDRA repository constitutes a SPARQL endpoint which is identified by the resource

    <HTTP-HOST>/<ACCOUNT-NAME>/<REPOSITORY-NAME>

Requests which conform to the terms of a SPARQL request described in the
"SPARQL 1.1 Protocol" [recommendation](http://www.w3.org/TR/2013/REC-sparql11-protocol-20130321)
are processed as SPARQL requests. 
The tests for this facility are present in the directory `

## DYDRA account administration HTTP API

Test scripts for account and repository management operations are present under the directory
`accounts-api`.

## DYDRA service extensions

The DYDRA service provides several extensions to standard SPARQL facilities:
- It implements the temporal datatypes `xsd:date`, `xsd:dayTimeDuration`,
`xsd:time`, `xsd:yearMonthDuration`and the atomic Gregorian datatypes and implements the
respective constuctor, accessor and combination operators as described in 
["XPath and XQuery Functions and Operators 3.0"](http://www.w3.org/TR/xpath-functions-30).
- It implements the math operators from the
XPath [recommendation](http://www.w3.org/TR/xpath-functions-30/#trigonometry).
- It implements native statement reification and provides operators to identify and locate statements
and statement terms by content.
- It provides access to query operation meta-data.
- It affords access to repository revisions.
- It implements IRI component accessors.

Test scripts for these capabilities are present under the directory `extensions`
