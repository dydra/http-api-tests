#! /bin/sh

# First clear all logs of req/response pairs
source transcribe_clear.sh

# Start logging now
source transcribe_on.sh

# Make  3 requests
source count.sh
source select10.sh
source selectAll.sh
#source insert.sh

# Get the list of all uuids
source transcribe_list.sh

OUTPUT="$(wc -l tmp.lst | cut -f1 -d' ')"
echo ${OUTPUT}
# counts newlines, should be one less than lines
if [ "$OUTPUT" == "2" ]; then
	echo "Passed"
else
	echo "Failed"
fi
# Turn off the logging
source transcribe_off.sh

#rm tmp.lst
