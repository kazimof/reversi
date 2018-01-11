#!/bin/sh
#wait [cbeforesecs] secs for the initial connections to be estabished
sleep [cbeforesecs]
until [ 1 = 0 ]; do
	#establish whether remote server can still reach me on this port
#REMOVE THE "-y" FOR NO NOPENWRT PRODUCTS
	echo "IMPORTANT!!!!!!!!!!!!!"
	echo "YOU MUST NOT CARRY another working key when you run this for testing or you will get erro such as - integer expression expected"
	echo "IMPORTANT!!!!!!!!!!!!!"
	UPCODE=$(ssh -y -o StrictHostKeyChecking=no -p [REVERSISSHPORT] -o ServerAliveInterval=5 -o ConnectTimeout=5 [reversiuser]@[reversihost] -i [INSTALLDIR]/[reversisshkey] '[nodename]' '[reversiport]' '[fwdportstr]')
	echo $UPCODE
	if [ "$UPCODE" -ne "0" ]
	then
		echo "STATUS is DOWN - server says retry in $UPCODE"
		sleep $UPCODE
		sleep [stuffsecs]
		screen -X -S [CSCNAME] -p0 stuff $'\003'
		sleep [stuffsecs]
		screen -X -S [CSCNAME] -p0 stuff "$(printf \\r)"
		sleep [stuffsecs]
		screen -X -S [CSCNAME] -p0 stuff \'[INSTALLDIR]/[OPNAME]\'
		sleep [stuffsecs]
		screen -X -S [CSCNAME] -p0 stuff "$(printf \\r)"
		sleep [stuffsecs]
	fi
	sleep [mretrysecs]
done
