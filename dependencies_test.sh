#!/bin/bash

declare -A PACKBINMAP=( [jq]=jq [json_reformat]=yajl-tools [rapper]=raptor2-utils [tidy]=tidy)

for BINARY in "${!PACKBINMAP[@]}"; do 
	#echo $BINARY "--->"  ${PACKBINMAP[$BINARY]}
	which $BINARY > /dev/null; [ $? -eq 1 ] && echo "installing missing package ${PACKBINMAP[$BINARY]}" && sudo apt install -y ${PACKBINMAP[$BINARY]} ;
done 

