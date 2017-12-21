#!/bin/sh
export HOME=/root #compat for openwrt
while [ 1 ]
	do
	GOTDATE=`date +%Y-%m-%d-%H-%M`
	echo "$GOTDATE"
	echo 'CONNECTING TO SERVER [reversihost]'
	/usr/bin/ssh -y -o ConnectTimeout=5 -p 22  -i [INSTALLDIR]/[reversisshkey] -N -R [reversiport]:[fwdhost]:[fwdport] [reversiuser]@[reversihost] -o 'ServerAliveInterval 10' -o 'ServerAliveCountMax 2' -o StrictHostKeyChecking=no
	GOTDATE=`date +%Y-%m-%d-%H-%M`; echo "$GOTDATE";echo 'LOST SERVER CONNECTION - WAITING FOR [cretrysecs]secs THEN RETRYING'
	sleep [cretrysecs]
done
