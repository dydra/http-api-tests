#!/bin/bash
protocolgraph="<${STORE_NAMED_GRAPH}-protocol>"
read -d '' initial_input <<EOF
<http://example.com/default-subject> <http://example.com/default-predicate> "default-object-org" .
<http://example.com/named-subject> <http://example.com/named-predicate> "named-object-GRAPH1-org" <${STORE_NAMED_GRAPH}-one> .
<http://example.com/named-subject> <http://example.com/named-predicate> "named-object-GRAPH2-org" <${STORE_NAMED_GRAPH}-two> .
<http://example.com/named-subject> <http://example.com/named-predicate> "named-object-GRAPH3-org" ${protocolgraph} .
EOF
read -d '' input_triples <<EOF
<http://example.com/default-subject> <http://example.com/default-predicate> "default-object-new" .
EOF
read -d '' input_quads <<EOF
<http://example.com/default-subject> <http://example.com/default-predicate> "default-object-new" .
<http://example.com/named-subject> <http://example.com/named-predicate> "named-object-GRAPH1-new" <${STORE_NAMED_GRAPH}-one> .
<http://example.com/named-subject> <http://example.com/named-predicate> "named-object-GRAPH2-new" <${STORE_NAMED_GRAPH}-three> .
EOF

for content in n-triples n-quads; do
    for content_type in application/n-triples application/n-quads; do
        for accept_type in application/n-triples application/n-quads; do
            for graph in none default graph-name-protocol; do
                for method in GET PUT DELETE POST HEAD PATCH; do
                    case $graph in
                        none)
                            graphvar=""
                            ;;
                        default)
                            graphvar=default
                            ;;
                        graph-name-protocol)
                            graphvar="graph=${protocolgraph}"
                            ;;
                        *)
                            echo "unknown graph value: ${graph}"
                            exit 3
                            ;;
                    esac
                    case "$content" in
                        n-triples)
                            contentvar="${input_triples}"
                            ;;
                        n-quads)
                            contentvar="${input_quads}"
                            ;;
                        *)
                            echo "unknown convent value: ${content}"
                            exit 4
                            ;;
                    esac

                    union=$(echo -e "${initial_input}\n${contentvar}")
                    #echo "${union}"
                    union_lines=$(echo "${union}" | wc -l)

                    echo -n "content: ${content} "
                    echo "content_type: ${content_type} accept_type: ${accept_type} graph: ${graph} method: ${method} graphvar: ${graphvar}"
                    delete_revisions --repository "${STORE_REPOSITORY_WRITABLE}" > /dev/null
                    echo "${initial_input}" | \
                         curl_graph_store_update -X POST  -o /dev/null \
                                            -H "Content-Type: application/n-quads" \
                                            --repository "${STORE_REPOSITORY_WRITABLE}"
                    
                    #output=$(curl_graph_store_get -i --repository "${STORE_REPOSITORY_WRITABLE}")
                    #echo "$output" | egrep "^Content-Type: " |cut -d' ' -f2 | sed 's/;//g'
                    #echo -e "contentvar:\n++\n${contentvar}\n--"
                    output=$(echo "$contentvar" | \
                                 curl_graph_store_update --repository "${STORE_REPOSITORY_WRITABLE}" \
                                                  -w '%{content_type}' \
                                                  -X "${method}" \
                                                  -H "Accept: ${accept_type}" \
                                                  -H "Content-Type: ${content_type}" \
                                                  ${graphvar}
                          )
                    #echo -e "++\n${output}\n--"
                    response_type=$(echo "$output"| tail -n 1 |cut -d' ' -f1 | sed 's/;//g')
                    response=$(echo "$output"| head -n -1)
                    echo -n "RESPONSE "
                    echo "type: ${response_type}"
                    lines=$(echo "$response" | wc -l)
                    let activitystream=0
                    if [ "$lines" -eq 8 ]; then
                        echo "$response" | head -n 1 | cut -d' ' -f2 | grep -q '<http://www.w3.org/ns/activitystreams#id>'
                        if [ "$?" -eq 0 ]; then
                            let activitystream=1
                        fi
                    fi
                    # echo -n "activitystream: ${activitystream} "
                    if [ "${activitystream}" -eq 1 ]; then
                        echo -n "activity stream "
                    else
                        #echo -n "normal output   "
                        echo -n "output          "
                    fi
                    echo -n "lines: $lines "
                    let triples=0
                    let quads=0
                    let unknown=0
                    let empty=0
                    for i in $(seq $lines); do
                        elem=$(echo "$response" | sed "${i}q;d" | awk '{print NF}')
                        if [ "$elem" -eq 4 ]; then
                            let triples++
                        elif [ "$elem" -eq 5 ]; then
                            let quads++
                        elif [ "$elem" -eq 0 ]; then
                            let empty=1
                        else
                            let unknown++
                            #echo "+$elem+"
                        fi
                    done
                    if [ "$unknown" -ne 0 ]; then
                        echo -e "--\n$response\n++"
                    fi
                    echo "empty: ${empty} triples: ${triples} quads: ${quads} unknown: ${unknown}"

                    echo -n "GET             "
                    output=$(curl_graph_store_get --repository "${STORE_REPOSITORY_WRITABLE}" \
                                                  -w '%{content_type}\n%{http_code}' \
                                                  -H "Accept: application/n-quads")
                    code=$(echo "$output"| tail -n 1)
                    if [ "$code" -eq "404" ]; then
                        echo "404 NOT FOUND"
                    else
                        output=$(echo "$output"| head -n -1)
                        response_type=$(echo "$output"| tail -n 1 | cut -d' ' -f1 | sed 's/;//g')
                        if [ "${response_type}" != "application/n-quads" ]; then
                            echo "wrong response: ${response_type}"
                            exit 2
                        fi
                        response=$(echo "$output"| head -n -1)
                        lines=$(echo "$response" | wc -l)
                        echo -n "lines: $lines "
                        let triples=0
                        let quads=0
                        let unknown=0
                        let empty=0
                        for i in $(seq $lines); do
                            elem=$(echo "$response" | sed "${i}q;d" | awk '{print NF}')
                            if [ "$elem" -eq 4 ]; then
                                let triples++
                            elif [ "$elem" -eq 5 ]; then
                                let quads++
                            elif [ "$elem" -eq 0 ]; then
                                let empty=1
                            else
                                let unknown++
                                #echo "+$elem+"
                            fi
                        done
                        if [ "$unknown" -ne 0 ]; then
                            echo -e "--\n$response\n++"
                        fi
                        echo "empty: ${empty} triples: ${triples} quads: ${quads} unknown: ${unknown}"

                        # check content
                        for i in $(seq $union_lines); do
                            statement=$(echo "${union}" | sed "${i}q;d")
                            elem=$(echo "${statement}" | awk '{print NF}')
                            if [ "$elem" -eq 4 ]; then
                                statement_object=$(echo "${statement}" | cut -d' ' -f3)
                                statement_graph=default
                            elif [ "$elem" -eq 5 ]; then
                                statement_object=$(echo "${statement}" | cut -d' ' -f3)
                                statement_graph=$(echo "${statement}" | cut -d' ' -f4)
                            elif [ "$elem" -eq 0 ]; then
                                echo empty statement
                                exit 3
                            else
                                echo unknown statement type
                                exit 3
                            fi
                            
                            #echo "looking for ${statement_object} in ${statement_graph}"
                            #echo -n "            "
                            found=$(echo "${response}" | grep ${statement_object})
                            if [ -n "${found}" ]; then
                                elem=$(echo "${found}" | awk '{print NF}')
                                if [ "$elem" -eq 4 ]; then
                                    found_object=$(echo "${found}" | cut -d' ' -f3)
                                    found_graph=default
                                elif [ "$elem" -eq 5 ]; then
                                    found_object=$(echo "${found}" | cut -d' ' -f3)
                                    found_graph=$(echo "${found}" | cut -d' ' -f4)
                                elif [ "$elem" -eq 0 ]; then
                                    echo "empty statement in result"
                                    exit 3
                                else
                                    echo "unknown statement type in result"
                                    exit 3
                                fi
                                if [ "${statement_graph}" = "${found_graph}" ]; then
                                    echo "${statement_object} found in graph ${statement_graph}"
                                else
                                    echo "${statement_object} found in graph ${found_graph} (was in ${statement_graph})"
                                fi
                            else
                                echo "${statement_object} not found"
                            fi
                        done
                    fi
                    echo
                    #sed 's/"[^"]*"/STRING/g' | sed 's/<[^>]*>/URL/g' | awk '{print NF}'
                    # deleted graph
                    # inserted into graph
                    # actual content
                    # content 
                done
            done
        done
    done
done
    
    
    
