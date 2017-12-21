#!/bin/sh
#AB reversi 2017 v7
#openwrt if RAM too small to install screen need to do this after bootup
#if there is no internet available on boot then this wont happen
#pingtest pings an ip to see if network is up
#if no net then requests a  device reboot
#if net, tests to see whether screen is installed, installs if not and runs reversi
#if it is installed and reversi is not runing then runs reversi

/bin/ping -c 10 $1 > /root/testping
ln=`cat /root/testping | wc -l`
echo $ln
if [ "$ln" -gt "10" ]
then
        echo "ping is OK - now test screen"
        which screen  > /root/testscreen
        ln=`cat /root/testscreen | grep -v "not found" | wc -l`
        echo "$ln"
        if [ "$ln" -gt "0" ]
        then
                echo "screen is there"
                #now check to see that kam and kar are there
                screen -ls  > /root/testscreenstat
                ln=`cat /root/testscreenstat | grep "ka" | wc -l`
                echo "$ln"
                if [ "$ln" -gt "1" ]
                then
                        echo "screen connectors are here and running ok"
                else
                        echo "screen connectors not here somehow this should not happen"
                        /root/reversiclient-5/reversi.sh

                fi
        else
                echo "no screen available - install it please and make this shit happen"
                /root/reversiclient-5/setupscreen-ram.sh
                /root/reversiclient-5/reversi.sh
        fi
else
        echo "ping NOT ok - CTRL-C to stop reboot in 20 secs"
        sleep 10
        /sbin/reboot
fi

