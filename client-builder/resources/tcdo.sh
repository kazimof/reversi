#!/bin/sh
insmod sch_tbf
sleep 2
/usr/sbin/tc qdisc del dev br-lan root
/usr/sbin/tc qdisc add dev br-lan root tbf rate $1mbit burst 4mb latency 100ms
/usr/sbin/tc qdisc list dev br-lan

/usr/sbin/tc qdisc del dev wlan0 root
/usr/sbin/tc qdisc add dev wlan0 root tbf rate $2mbit burst 2mb latency 100ms
/usr/sbin/tc qdisc list dev wlan0

