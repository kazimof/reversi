echo "screen creator and stuffer"
#create the csreenname 
screen -S [CSCNAME] -X quit 
sleep [STUFFSECS] 
screen -dm [CSCNAME] 
sleep [STUFFSECS] 
#create the mscreenname 
screen -S [MSCNAME] -X quit 
sleep [STUFFSECS] 
screen -dm [MSCNAME]  
sleep [STUFFSECS] 
screen -X -S [MSCNAME] -p0 stuff \"[INSTALLDIR]/[MONNAME]\" 
sleep [STUFFSECS] 
screen -X -S [MSCNAME] -p0 stuff "$(printf \\r)" 
sleep [STUFFSECS]
 
