#!/bin/bash -e
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
initial_input_lines=$(echo "${initial_input}" | wc -l)

function check_content() {
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
        echo -n "    "
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
}

function check_results() {
    local name="$1"
    input=${!name}
    input_lines_var="${name}_lines"
    input_lines=${!input_lines_var}
    echo -n "  checking ${name}: "
    #echo -e "--\n${input}\n++"
    #echo "lines: ${input_lines}"

    # check content
    let same_count=0
    let moved_count=0
    let deleted_count=0
    for i in $(seq "${input_lines}"); do
        statement=$(echo "${input}" | sed "${i}q;d")
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
                let same_count++
                #echo "    graph ${statement_graph} found"
            else
                let moved_count++
                #echo "    graph ${statement_graph} moved, ${statement_object} now in graph ${found_graph}"
            fi
        else
            let deleted_count++
            #echo "    graph ${statement_graph} deleted"
        fi
    done
    if [ "${same_count}" -eq "${input_lines}" ]; then
        echo "all found"
    elif [ "${deleted_count}" -eq "${input_lines}" ]; then
        echo "nothing found"
    else
        echo "same: ${same_count}  moved: ${moved_count}  deleted: ${deleted_count}"
    fi
}

let count=0
for method in GET PUT DELETE POST HEAD PATCH; do
    for graph in none default graph-name-protocol; do
        for content in n-triples n-quads; do
            for content_type in application/n-triples application/n-quads; do
                for accept_type in application/n-triples application/n-quads; do
                    
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
                            body_content="${input_triples}"
                            ;;
                        n-quads)
                            body_content="${input_quads}"
                            ;;
                        *)
                            echo "unknown convent value: ${content}"
                            exit 4
                            ;;
                    esac
                    body_content_lines=$(echo "${body_content}" | wc -l)

                    union=$(echo -e "${initial_input}\n${body_content}")
                    #echo "${union}"
                    union_lines=$(echo "${union}" | wc -l)

                    let count++
                    echo "${count}."
                    echo -n "method: ${method} "
                    echo -n "content: ${content} "
                    echo -n "content_type: ${content_type} "
                    echo -n "accept_type: ${accept_type} "
                    echo -n "graph: ${graph} "
                    echo -n "graphvar: ${graphvar}"
                    echo
                    
                    delete_revisions --repository "${STORE_REPOSITORY_WRITABLE}" > /dev/null
                    echo "${initial_input}" | \
                         curl_graph_store_update -X POST  -o /dev/null \
                                            -H "Content-Type: application/n-quads" \
                                            --repository "${STORE_REPOSITORY_WRITABLE}"
                    
                    #output=$(curl_graph_store_get -i --repository "${STORE_REPOSITORY_WRITABLE}")
                    #echo "$output" | egrep "^Content-Type: " |cut -d' ' -f2 | sed 's/;//g'
                    #echo -e "body_content:\n++\n${body_content}\n--"
                    output=$(echo "$body_content" | \
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

                    # echo -n "activitystream: ${activitystream} "
                    echo -n "  "
                    if [ "${activitystream}" -eq 1 ]; then
                        echo "activity stream"
                    else
                        if [ "$lines" -eq 1 ] && [ "$empty" -eq 1 ]; then
                            echo "no output"
                        else
                            echo -n "normal output "
                            echo "lines: $lines  empty: ${empty}  triples: ${triples}  quads: ${quads}  unknown: ${unknown}"
                        fi
                    fi
                    
                    if [ "$unknown" -ne 0 ]; then
                        echo -e "--\n$response\n++"
                    fi
                    if [ "${activitystream}" -ne 1 ]; then
                        let sum="$triples"+"$quads"
                        if [ "$sum" -gt 0 ]; then
                            echo "  no. statements: $sum"
                            check_content
                            check_results initial_input
                            check_results body_content
                        fi
                    fi

                    echo -n "GET             "
                    output=$(curl_graph_store_get --repository "${STORE_REPOSITORY_WRITABLE}" \
                                                  -w '%{content_type}\n%{http_code}' \
                                                  -H "Accept: application/n-quads")
                    code=$(echo "$output"| tail -n 1)
                    if [ "$code" -eq "404" ]; then
                        echo "<empty repository> (404 NOT FOUND)"
                    else
                        output=$(echo "$output"| head -n -1)
                        response_type=$(echo "$output"| tail -n 1 | cut -d' ' -f1 | sed 's/;//g')
                        if [ "${response_type}" != "application/n-quads" ]; then
                            echo "wrong response: ${response_type}"
                            exit 2
                        fi
                        response=$(echo "$output"| head -n -1)
                        lines=$(echo "$response" | wc -l)
                        echo -n "lines: $lines  "
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
                        echo "empty: ${empty}  triples: ${triples}  quads: ${quads}  unknown: ${unknown}"

                        let sum="$triples"+"$quads"
                        echo "  no. statements: $sum"
                        check_content
                        check_results initial_input
                        check_results body_content
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
    
    
    