# HTTP API tests : property path variations

given a repository with a path in several segments, of which two segments each are present in
each of several graphs (the default graph and the named graphs :g1, :g2 and :g3), verify the
distinction in results among various combinations of the query
dataset and query patterns.

the dataset declarations combine "FROM" and "FROM NAMED" clauses to declare the concrete datasets
as combinations of
- none (no declaration clause)
- a constant graph (here :g1, :g2 or :g3)
- a graph group ( <urn:dydra:default>, <urn:dydra:named> or <urn:dydra:all>)

<table border="0" width="100%">
<tr><th style="width: 16em">dataset definition</th>
    <th style="width: 24em">patterns</th>
    <th>behaviour</th></tr>


<tr  style="">
    <td  style="border-top: 1px solid black; padding-top: 10px" colspan="3">paths-none.sh</td></tr>

<tr style=" background-color: #f0f0f0">
    <td rowspan="4" style="border-bottom: 1px solid black; width: 16em">none</td>
    <td colspan="2">Absent a dataset definition, the default dataset definition comprises the
      default graph and all named graphs, for which, ...</td></tr>

<tr style="background-color: #f0f0f0">
    <td style="width: 24em; white-space: pre">{?s :p1/:p2 ?o}</td>
    <td style="width: auto">... a path outside of a graph clause matches statements
        in the default graph only.</td></tr>

<tr style=" background-color: #f0f0f0">
    <td style="width: 24em; white-space: pre">graph ?g {?s :p1/:p2 ?o}</td>
    <td style="width: auto">... a path in an abstract graph clause matches statements
        in individual named graphs only.</td></tr>

<tr style=" background-color: #f0f0f0">
    <td style="border-bottom: 1px solid black; width: 24em; white-space: pre">graph :g1 {?s :p1/:p2 ?o}</td>
    <td style="border-bottom: 1px solid black; width: auto">
        ... a path within a specific graph clause matches statements in the respective individual named graph
        in the default dataset only.</td></tr>


<tr  style="">
    <td  style="border-top: 1px solid black; padding-top: 10px" colspan="3">paths-from-all.sh</td></tr>

<tr style="background-color: #f0f0f0">
    <td rowspan="4" style="border-bottom: 1px solid black;">FROM &lt;urn:dydra:all&gt;</td>
    <td colspan="2">Given a dataset definition which combines all graphs into the default,
      but declares no named graphs[1], ...</td></tr>

<tr style="background-color: #f0f0f0">
    <td style="width: 24em; white-space: pre">{?s :p1/:p2 ?o}</td>
    <td>... a path outside of a graph clause matches statements
        in and among all graphs.</td></tr>

<tr style="background-color: #f0f0f0">
    <td style="width: 24em; white-space: pre">graph ?g {?s :p1/:p2 ?o}</td>
    <td>... a path within an abstract graph clause matches no statement,
     as the concrete dataset has no named graphs.</td></tr>

<tr style="background-color: #f0f0f0">
    <td style="width: 24em; white-space: pre; border-bottom: 1px solid black;">graph :g1 {?s :p1/:p2 ?o}</td>
    <td style="border-bottom: 1px solid black;">
     ... a path within a specific graph clause matches no statement,
     as the concrete dataset has no named graphs.</td></tr>


<tr style="">
    <td  style="border-top: 1px solid black; padding-top: 10px" colspan="3">paths-from-named.sh</td></tr>

<tr style="background-color: #f0f0f0;">
    <td style=" border-bottom: 1px solid black;"><div>FROM &lt;urn:dydra:named&gt;</div></td>
    <td colspan="2" style="border-bottom: 1px solid black;">A dataset definition
        which combines just the named graphs into the default,
        has an effect analogous to &lt;urn:dydra:all&gt;, but leaves out the
        default graph.</td></tr>


<tr style="">
    <td  style="border-top: 1px solid black; padding-top: 10px" colspan="3">paths-from-constant.sh</td></tr>

<tr style="background-color: #f0f0f0;">
    <td style=" border-bottom: 1px solid black;"><div>FROM :g1</dIv><br />
        <dIv>FROM :g2</div></td>
    <td colspan="2" style="border-bottom: 1px solid black;">A dataset definition
        which combines specific graphs into the default graph,
        has an effect analogous to &lt;urn:dydra:all&gt;, but includes just those specific graphs.</td></tr>


<tr  style="">
    <td  style="border-top: 1px solid black; padding-top: 10px" colspan="3">paths-from-named-named.sh</td></tr>

<tr style="background-color: #f0f0f0">
    <td rowspan="4" style="border-bottom: 1px solid black;">FROM &lt;urn:dydra:named&gt;</td>
    <td colspan="2">Given a dataset definition which permits all graphs as named graphs,
      but declares no default graphs, ...</td></tr>

<tr style="background-color: #f0f0f0">
    <td style="width: 24em; white-space: pre">{?s :p1/:p2 ?o}</td>
    <td>... a path outside of a graph clause matches no statement,
        as the default graph is empty.</td></tr>

<tr style="background-color: #f0f0f0">
    <td style="width: 24em; white-space: pre">graph ?g {?s :p1/:p2 ?o}</td>
    <td>... a path outside of a graph clause matches statements
        in and among all named graphs - and retains each respective graph in the solution.</td></tr>

<tr style="background-color: #f0f0f0">
    <td style="width: 24em; white-space: pre; border-bottom: 1px solid black;">graph :g1 {?s :p1/:p2 ?o}</td>
    <td style="border-bottom: 1px solid black;">
        ... a path within a specific graph clause matches statements in the respective specific named graph
        only.</td></tr>


<tr style="">
    <td  style="border-top: 1px solid black; padding-top: 10px" colspan="3">paths-from-named-all.sh</td></tr>

<tr style="background-color: #f0f0f0;">
    <td style=" border-bottom: 1px solid black;"><div>FROM &lt;urn:dydra:all&gt;</div></td>
    <td colspan="2" style="border-bottom: 1px solid black;">A dataset definition
        which combines just the named graphs into the default,
        has an effect analogous to &lt;urn:dydra:named&gt;, but includes the
        default graph.</td></tr>


<tr style="">
    <td  style="border-top: 1px solid black; padding-top: 10px" colspan="3">paths-from-named-constant.sh</td></tr>

<tr style="background-color: #f0f0f0">
    <td rowspan="4" style="border-bottom: 1px solid black;">FROM NAMED :g1<br />
        FROM NAMED :g2</td>
    <td colspan="2">Given a dataset definition which limits the named graphs to a specific set, ...</td></tr>

<tr style="background-color: #f0f0f0">
    <td style="width: 24em; white-space: pre">{?s :p1/:p2 ?o}</td>
    <td >... a path outside of a graph clause matches nothing, as the default
        graph is empty.</td></tr>

<tr style="background-color: #f0f0f0">
    <td style="width: 24em; white-space: pre">graph ?g {?s :p1/:p2 ?o}</td>
    <td >... a path within an abstract graph clause matches statements in individual named graphs
        from the named only.</td></tr>

<tr style="background-color: #f0f0f0">
    <td style="border-bottom: 1px solid black; width: 24em; white-space: pre">graph :g1 {?s :p1/:p2 ?o}</td>
    <td style="border-bottom: 1px solid black;">... a path within constant graph clause,
        which is among those declared, matches statements
        in that individual named graph only.
        If the graph was not declared, it is not part of the dataset.</td></tr>

</table>

---
1: http://www.w3.org/TR/2013/REC-sparql11-query-20130321/#rdfDataset   
2: http://www.w3.org/TR/2013/REC-sparql11-query-20130321/#sparqlDataset   