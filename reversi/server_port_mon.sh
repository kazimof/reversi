#!/bin/bash
#name of this file must be referenced as the permitted execute file for reversi-client keys in ~/.ssh/authorized_keys
#it uses netcat or telnet to check whether the tcp port the client is forwarding is responding or dead
#if dead then it kills the local PID of that connection and returns a number of seconds
#if alive then returns 0
#the standard reversi client monitor script should sleep those seconds before attempting a retry 
#the standard reversi client monitor script will ignore a 0 RETURN


# returns 0 for open OR the number of seconds the client must wait before killing process and attempting again
APPDIR=$( cd "$( dirname "$0" )" && pwd )
logfile="$APPDIR/logs/ports.log"
lowestport=50000
#number of initial characters to use for the string comparison from nc/telnet checks
nctestchars=15
devicename="$1"
deviceport="$2"
portstring="$3"
#for logging illegal attempts
legal=0

#set debug="1" to send debugging info to logs 
debugme="1"
debugme="0"
#enable debug for ONLY the device named here
debugdevicename="nodename"

#we dont want reversi to subvert any ports lower than the reversi range  
if [ "$deviceport" -lt "$lowestport" ]
then
	echo "WARNING: $GOTDATE-$deviceport.$devicename.$portstring suspicious request" | tee -a $logfile >/dev/null 2>/dev/null	
	echo 0
	exit
fi


if [ "$debugdevicename" == "$devicename" ]; then
	echo "DEVICES: $debugdevicename / $devicename" | tee -a $logfile    >/dev/null 2>/dev/null
	debugme=1
fi

if [ "$debugme" == "1" ]; then
	echo "DEBUGON" | tee -a $logfile    >/dev/null 2>/dev/null 
fi

if [ "$portstring" = "NULL" ]; then
	#we are unable to test this port against the registered string so we have to do these with telnets
	result=$($APPDIR/timeout3.sh -t 10 telnet localhost $deviceport | grep Connected | wc -l) 
	if [ "$result" == "1" ] ; then
		rh=0
		lh=0
	else
		lhc=0	
		rhc=1
	fi
	if [ "$debugme" == "1" ]; then
	     	 echo "telnetmethod: $result" | tee -a $logfile    >/dev/null 2>/dev/null
	fi
else
	#thanksfull this is a proper port so has strings we can use netcat
	ncresult=$(nc -w 3 localhost $deviceport) >/dev/null 2>/dev/null
	ncresult_clean="${ncresult//[^[:alnum:]]/}" >/dev/null 2>/dev/null
	portstring_clean="${portstring//[^[:alnum:]]/}" >/dev/null 2>/dev/null
	lh="x${ncresult_clean}" 
	rh="x${portstring_clean}" 
	lhc=${lh:1:nctestchars} >/dev/null 2>/dev/null
	rhc=${rh:1:nctestchars} >/dev/null 2>/dev/null

        if [ "$debugme" == "1" ]; then
                 echo "ncfullrevclient: $ncresult_clean" | tee -a $logfile    >/dev/null 2>/dev/null
                 echo "f10CLIENT: $lhc" | tee -a $logfile    >/dev/null 2>/dev/null
                 echo "f10RULE: $rhc"  | tee -a $logfile    >/dev/null 2>/dev/null
        fi
fi

if [ "$lhc" == "$rhc" ]; then
	# the string passed by client is the same as their telnet/netcat result so this is PROBABLY not an imposter
	GOTDATE=`date +%Y-%m-%d-%H-%M`
	echo "$GOTDATE-$deviceport.$devicename.$portstring UP" | tee -a $logfile  >/dev/null 2>/dev/null
	echo "0"
else
	
	# this means although the device has a connection - it aint working
	# we kill the PID on server end and prompt the monitor to exit the current attempts and retry
	#find PID on server
	gotpid=$(fuser "$deviceport/tcp" 2>/dev/null | awk '{ for (i=1; i<=NF; i++) print $i }')
	echo "tunnel process ID: $gotpid" | tee -a $logfile >/dev/null 2>/dev/null
	GOTDATE=`date +%Y-%m-%d-%H-%M`
	#we need to let the client know that their connection has been trashed
	if [ -z "$gotpid" ] 
	then
		echo "WARNING: NO PID ACCOCIATED WITH $deviceport" | tee -a $logfile >/dev/null 2>/dev/null
	else
		echo "PID to kill: $gotpid" | tee -a $logfile >/dev/null 2>/dev/null
	fi
	echo "$GOTDATE-$deviceport.$devicename.$portstring DOWN" | tee -a $logfile >/dev/null 2>/dev/null

	if [ "$debugme" == "1" ]; then
		echo "DEBUGON: skipping kill $gotpid" | tee -a $logfile    >/dev/null 2>/dev/null 
		#return standard success so client takes no action
		echo "0"
	else

		
		echo "killing PID...$gotpid" | tee -a $logfile >/dev/null 2>/dev/null
		kill $gotpid  >/dev/null 2>/dev/null
		GOTDATE=`date +%Y-%m-%d-%H-%M`
		attemptargs="$GOTDATE-$deviceport.$devicename.$portstring UNKNOWN"
		echo "$attemptargs" | tee -a $logfile >/dev/null 2>/dev/null
		echo "60" 
	fi
fi
