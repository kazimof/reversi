#!/bin/bash
REVLOG=logs/ports.log
for m in {1..12}
do 
  for d in {1..31}
  do
    ln=$( cat  $REVLOG | grep $1 | grep 2017-$m-$d | wc -l )
	uptime=$( echo "$ln" "1980" | /usr/bin/awk '{print  ($1 / $2) * 100}' )
	uptimeround=$( echo "($uptime)/1" | bc )
	echo "Date: 2017-$m-$d Uptime: $uptimeround%"
  done 
done
