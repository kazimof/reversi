# reversi-server and reversiclient
# Author: kazimof at zzero dot org

#    This program is free software: you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    http://www.gnu.org/licenses/.


WHAT DOES REVERSI DO?
---------------------
Uses reverse ssh tunnels to expose device ports on a reversi-client's network to a reversi-server anywhere on the internet.

A reverse ssh tunnel (ssh -R) can be established quite easily, the problem comes with connection stability, where the ssh connection can and does hang from either the server or client end. Reversi tests the validity of the connection from the client every X seconds and re-establishes it if the connection is not fit for purpose.

EXAMPLE USE 1:
-----------------
You need to manage a LAN but you have no access to their office broadband router to configure port forwarding.

EXAMPLE USE 2: 
-----------------
You have OpenWRT devices installed within a public mesh network and you need to be able to manage them.

EXAMPLE USE 3:
-----------------
A company router has died or their broadband has been cut or they have moved premises, so they are on a temporary 3/4G connection waiting for a new broadband router with a static IP. Obviously the server not getting mail since port 25 is no longer forwarded by router, and webmail is unavailable to user for the same reason. Using an openwrt inside the network I forward ports 25 and 443 of the mail server to internet allowing the company mail server to receive mail and service web mail requests.

HOW DOES IT WORK?
-----------------
reversi-clients are equipped with a password-free ssh key to a user on the reversi-server. Using this key the reversi-client is allowed to do 2 things:
1) run a script that forwards any local port on it's network the reversi-server
2) run a script on the reversi-server passing arguements that inform the reversi-server about which node they are, which port it is using and what kind of response to expect from that port

On the client side the scripts are both run in gnu-screen, one does the reverse connection and the other acts as a connections monitor, killing and re-establishing the reverse tunnel according to the server response from the script referenced in 2) above.

On the server side the script referenced in 2) above tests to see whether the port is responding with the expected response, if not it assumes the connection has hung, identifies the appropriate PID and kills it. Script then returns a number specifying a time which the client monitor script should wait before retyring the connection.

DESIGN PARAMETERS
-----------------
Needs to run on a variety of client OS, I am managing a mix of hundreds of openwrt devices, linux servers and OSX installs, I needed this solution for them all and I am too lazy to maintain multiple forks. 
The 2 programs available to all platforms are: 

screen
ssh


DESIGN
------
Reversi commprises of 2 components to be installed on the reversi server.

SERVER: hosts a script that clients are authorised to invoke to monitor and manage their reverse tunnel
RECOMMENDED INSTALL FOLDER: /home/reversi/reversi
CLIENT BUILDER: builds the scripts to be run on the client device 
RECOMMENDED INSTALL FOLDER: /root/reversi/client-builder

See INSTRUCTIONS.TXT for installation info.
