setting up server:

PLACING THE SCRIPT
------------------
choose the reversi username and add user [reversi]
create a dir called reversi in this users home [/home/reversi/reversi]
in there place the followig files:
server_port_mon.sh
timeout3.sh
change file ownership [chown reversi:reversi *]
make a dir called: logs


AUTHENTICATION
--------------
create your authorized_keys file:
create a password-free ssh key and add the plublic key to [/home/reversi/.ssh/authorized_keys2]
prepend the key line with command="/root/reversi/server_port_mon.sh $SSH_ORIGINAL_COMMAND" {a space is needed, then continue with key here}
The resulting authorized_keys2 file will look something like this:
command="/root/reversi/server_port_mon.sh $SSH_ORIGINAL_COMMAND" ssh-rsa AAAAB3NzaC1yc2EAAAAAAAAB3NzaC1yc2EAAAAC1yc2EAAAAAAAAB3NzaC1yc2EAAAAC1yc2EAAAAAAAAB3NzaC1yc2EAAAAC1yc2EAAAAAAAAB3NzaC1yc2EAAAAC1yc2EAAAAAAAAB3NzaC1yc2EAAAAC1yc2EAAAAAAAAB3NzaC1yc2EAAAAC1yc2EAAAAAAAAB3NzaC1yc2EAAAA user@localhost

NOTE that bash ssh-keygen will not work for openwrt auth, dropbear has a specific method of generating the key, this can be done from any openwrt device and you can use that key.

TESTING
-------
on server, tail -f logs/ports.log
copy the ssh key to a test source, use ssh 
remove active keys (ssh-add -d) OR use ssh-agent bash to hide your existing keys
ssh -i reversiclient7.key reversi@myserver testing 55555 XXXXXXXXXXX
IF the auth is working you shouild see something like :

2016-12-25-00-02-55555.testing.XXXXXXXXXXX DOWN
killing PID...
2016-12-25-00-02-55555.testing.XXXXXXXXXXX UNKNOWN

###### also logged this error, due to server firewall issues (when using NULL for port fingerprint)
telnet: Unable to connect to remote host: Connection refused
60

- dont forget:
1) ensure all files are chown username, with chmod +x for scripts
2) server firewall is open on rsshport


SETTING UP CLIENT
##################
So this "service" needs to run on a variety of client OS, we are running a mix of openwrt devices, linux servers and OSX, I needed solutions for them all and I am too lazy to maintain multiple forks. The 2 programs available to all are: 
screen
ssh

There are some special measures to take for SOME openwrt devices such as those with too little space to install screen and dependencies upon boot and to reboot if the first install attempts happenned while the net was down.

CREATE client tar
##################
use the root account on your client devicei, or fix the need to have access to the temp folder  /reversiclientX
while in root dir: untar reversi-client.tar.gz
#tar xvfz reversi.tar.gz







TROUBLE========= 

BAD USER:  
/root/reversiclient-7/kam50012REV.sh: 12: [: Illegal number:


