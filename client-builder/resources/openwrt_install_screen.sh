#!/bin/sh -x 
#on devices with little space you need ot install screen to /tmp
#run this script first in /etc/rc.local

#only fully tested on OpenWRT 15.4, may work with newer, but NOT 14.x

#waiting for network to come up
sleep 60
opkg update
opkg install libncurses -d ram
opkg install screen -d ram
ln -s /tmp/usr/lib/libncurses.so.5 /usr/lib/
ln -s /tmp/usr/sbin/screen /usr/sbin/
ln -s /tmp/usr/share/terminfo /usr/share/
