
# HTTP API tests

This repository comprises tests for the DYDRA RDF cloud service:
- The Sesame HTTP communication protocol,
- The SPARQL graph store HTTP protocol,
- The SPARQL query protocol,
- The DYDRA account administration HTTP API
- DYDRA extension tests

[![Build Status](https://travis-ci.org/dydra/http-api-tests.svg?branch=master)](https://travis-ci.org/dydra/http-api-tests)

---

The tests implemented as a collection of shell scripts and arranged in a directory hierarchy according to topic.
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


In order to execute simple scripts manually:

- Establish values for the shell variables
  - `STORE_URL` : the HTTP URI to specify the remote host.
  - `STORE_ACCOUNT` : the account name.
  - `STORE_REPOSITORY` : the repository name eg.
  - `STORE_TOKEN` : an authentication if authentication is required.
- Define the shell environment
- Run the desired script(s)

For example

    export STORE_URL="http://dydra.com"
    export STORE_ACCOUNT="openrdf-sesame"
    export STORE_REPOSITORY="mem-rdf"
    export STORE_TOKEN="1234567890"
    source define.sh
    bash run.sh extensions/sparql-protocol/temporal-data

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
[recommendation](http://www.w3.org/TR/sparql11-http-rdf-update/).
For a repository on a DYDRA host, the native request patterns comprise just the host authority, the
user account and the repository name

    <HTTP-HOST>/<ACCOUNT-NAME>/<REPOSITORY-NAME>

with respect to which, the default graph is designated as

    <HTTP-HOST>/<ACCOUNT-NAME>/<REPOSITORY-NAME>?default

and an indirect graph reference takes the form

    <HTTP-HOST>/<ACCOUNT-NAME>/<REPOSITORY-NAME>?graph=<graph>

## Linked data designators

In addition to the root repository graph, it is also possible to link directly to
an arbitrary directly designated graph which extends beyon the root

    <HTTP-HOST>/<ACCOUNT-NAME>/<REPOSITORY-NAME>/<FURTHER>/<PATH>/<STEPS>


### Graph store content types

The `multipart/form-data` request content type described in the graph store
[protocol](http://www.w3.org/TR/2013/REC-sparql11-http-rdf-update-20130321/#graph-management)
is not supported. Each request must target an individual graph.

The `application/x-www-form-url-encoded` request type is supported for `GET` requests only, as described in the SPARQL
protocol for [query](http://www.w3.org/TR/2013/REC-sparql11-protocol-20130321/#query-via-post-urlencoded)
 and [update](http://www.w3.org/TR/2013/REC-sparql11-protocol-20130321/#update-via-post-urlencoded) operations. 


## Triples, quads and named graphs in import requests

The graph store management operations which involve an RDF payload - `PATCH`, `POST`, and `PUT`,
permit a request to target a specific graph as described above, as well as to transfer graph content
as TriX or N-Quads in order to stipulate the target graph for statements in the payload document itself.
The protocol and document specifications are not exclusive.
When both appear, the graph encoded in the document supersedes that specified in the protocol request
with respect to the destination graph, while the protocol graph specifies which graph is to be cleared by a put.
Where no protocol graph is specified for a `POST` request, a new graph is generated.
The combinations yield the following effects:

<table  border=0 cellpadding=2px cellspacing=0 >

<td class=hd>
<td >protocol graph designator<td  >content type<td  >statement graph designator<td  >effective graph</tr>
<tr >
<td class=hd>
<td >-<td>n-triple, rdf<td >-<td >-/&lt;post&gt;</tr>
<tr >
<td class=hd>
<td >-<td>n-quad, trix<td >-<td >-/&lt;post&gt;</tr>
<tr >
<td class=hd>
<td >-<td>n-triple, rdf<td>&lt;statement&gt; : invalid<td><i>skipped</i></tr>
<tr >
<td class=hd>
<td >-<td>n-quad, trix<td>&lt;statement&gt;<td>&lt;statement&gt;</tr>
<tr >
<td class=hd>
<td  >default, null<td>n-triple, rdf<td >-<td >-</tr>
<tr >
<td class=hd>
<td  >default, null<td>n-quad, trix<td >-<td >-</tr>
<tr >
<td class=hd>
<td  >default, null<td>n-triple, rdf<td>&lt;statement&gt; : invalid<td><i>skipped</i></tr>
<tr >
<td class=hd>
<td  >default, null<td>n-quad, trix<td>&lt;statement&gt;<td>&lt;statement&gt;</tr>
<tr >
<td class=hd>
<td  >graph=&lt;protocol&gt;<td>n-triple, rdf<td >-<td>&lt;protocol&gt;</tr>
<tr >
<td class=hd>
<td  >graph=&lt;protocol&gt;<td>n-quad, trix<td >-<td>&lt;statement&gt;</tr>
<tr >
<td class=hd>
<td  >graph=&lt;protocol&gt;<td>n-triple, rdf<td>&lt;statement&gt; : invalid<td><i>skipped</i></tr>
<tr >
<td class=hd>
<td  >graph=&lt;protocol&gt;<td>n-quad, trix<td>&lt;statement&gt;<td>&lt;statement&gt;</tr>
</table>


In order to validate the results, one script exists for the PUT operations for
each of the combinations, named according to the pattern

    PUT-<protocolGraph>-<contentType>.sh

which performs a PUT request of the respective graph and content type combination
and validates the content of a subsequent GET
against the expected store content. The combination features are indicated as

 - protocolGraph : direct, default, graph (indirect)
 - contentType : n-triples, n-quads, rdf, turtle, trix

whereby, just the combinations for `PUT-direct` validate the full content type complement and,
among these, the cases like `PUT-default-nquads` intend to demonstrate the
effect when the payload or request content type does not correspond to the protocol target graph.
In addition, for ntriples and nguads content types, the acutual document contains both triples and quads
in order to demonstrate the consequence of the statement's given content on its destination.

<table>
<tr><th>script</th><th>result</th><th>test</th></tr>

<tr><td>POST-default-nquads.sh</td>
    <td>PUT-default-nquads-GET-response.nq</td>
    <td>each statement (default and context) is added to its respective statement context.
        </td>
    </tr>
<tr><td>POST-default-ntriples.sh</td>
    <td>POST-default-ntriples-GET-response.nt</td>
    <td>the default statement is added to the default graph.</td>
    </tr>
<tr><td>POST-direct-nquads.sh</td>
    <td>PUT-direct-nquads-GET-response.nq</td>
    <td>each statement (default and context) is added to its respective statement context.
        </td>
    </tr>
<tr><td>POST-direct-ntriples.sh</td>
    <td>POST-direct-triples-GET-response.nq</td>
    <td>the default statement is added to the default graph.</td>
    </tr>
<tr><td>POST-graph-nquads.sh</td>
    <td>POST-graph-nquads-GET-response.nq</td>
    <td>each statement (default and context) is added to its respective statement context.
        that is, <span style='color: red'>the default statement is not added to the protocol graph</span>.</td>
    </tr>
<tr><td>POST-graph-ntriples.sh</td>
    <td>POST-graph-ntriples-GET-response.nq</td>
    <td>the default statement is added to the named (indirectly specified) graph.</td>
    </tr>

<tr><td>PUT-default-nquads.sh</td>
    <td>PUT-default-nquads-GET-response.nq</td>
    <td>each statement (default and context) is added to its respective statement context.
        </td>
    </tr>
<tr><td>PUT-default-nquads-as-ntriples</td>
    <td>PUT-default-nquads-GET-response.nq</td>
    <td>the default graph only is cleared, which means the extant named graph remains.
        the default statement is added to the default (indirectly specified) graph.
        the context statement is added to its respective graph.</td>
    </tr>
<tr><td>PUT-default-ntriples.sh</td>
    <td>PUT.nt</td>
    <td>the default graph only is cleared, which means the extant named graph remains.
        the default statement is added to the default graph.</td>
    </tr>

<tr><td>PUT-direct-json.sh</td>
    <td>PUT.rj</td>
    <td><span style="color: red">400: bad request</span></td>
    </tr>
<tr><td>PUT-direct-nquads.sh</td>
    <td>PUT.nq</td>
    <td>the repository is cleared.
        each statement (default and context) is added to its respective statement context.</td>
    </tr>
<tr><td>PUT-direct-nquads-as-ntriples</td>
    <td>PUT-graph-nquads-as-ntriples-GET-response.nq</td>
    <td>the repository is cleared.
        each statement (default and context) is added to its respective statement context</td>
    </tr>
<tr><td>PUT-direct-trig.sh</td>
    <td>PUT.trig</td>
    <td><span style="color: red">400: bad request</span></td>
    </tr>
<tr><td>PUT-direct-triples.sh</td>
    <td>PUT.nt</td>
    <td>the repository is cleared.
        the default statement is added to the default graph.</td>
    </tr>
<tr><td>PUT-direct-trix.sh</td>
    <td>PUT.trix</td>
    <td><span style="color: red">400: bad request</span></td>
    </tr>
<tr><td>PUT-direct-turtle.sh</td>
    <td>PUT.nt</td>
    <td>the repository is cleared.
        the default statement is added to the default graph.</td>
    </tr>

<tr><td>PUT-graph-nquads.sh</td>
    <td>PUT-graph-nquads-GET-response.nq</td>
    <td>the named (indirectly specified) graph is cleared, which means the extant default and named graphs remain.
        each statement (default and context) is added to its respective statement context.
        that is, <span style='color: red'>the default statement is not added to the protocol graph</span>.</td>
    </tr>
<tr><td>PUT-graph-triples.sh</td>
    <td>PUT-graph-ntriples-GET-response.nq</td>
    <td>the named (indirectly specified) graph is cleared, which means the extant default and named graphs remain.
        the default statement is added to named (indirectly specified) graph.</td>
    </tr>
<tr><td>PUT-graph=direct-nquads.sh</td>
    <td>PUT.nq</td>
    <td>the repository is cleared.
        each statement (default and context) is added to its respective statement context</td>
    </tr>
<tr><td>PUT-graph-nquads-as-ntriples</td>
    <td>PUT-graph-nquads-as-ntriples-GET-response.nq</td>
    <td>the named (indirectly specified) graph is cleared, which means the extant default and named graphs remain.
        all statements (default and context) go into the named (indirectly specified) graph.</td>
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
