#AB reversi lib VER 2015-10-06

func_cleanbadvar () {
	#func_vartype "$1"
	#if a var is empty or simply / or // or /// this can screw the umount so make it invalid
	rtn="$1"
	if [ "xxx$1" == "xxx/" ] || [ "xxx$1" == "xxx//" ] || [ "xxx$1" == "xxx///" ]; then rtn="$var.invalid"; fi
	if [ "xxx$1" == "xxx" ]; then rtn="$var.invalid"; fi
	echo $rtn

}


func_createexcludefile () {
	#   func_createexcludefile "${keys[MOUNT_BASE]}/${keys[LOCAL_SRC_MOUNT]} ${keys[SRC_EXCLUDE_FILE]} $APPDIR/${keys[SRC_SERVERNAME]}.exclude.duplicity"
	#compile an adapted explusions file:
	INSERTDATA="$1"
	INFILE="$2"
	OUTFILE="$3"
#touch "$OUTFILE"
	echo "$INSERTDATA"
	echo "$INFILE"
	echo "$OUTFILE"
#	rm "$OUTFILE"
	while IFS=" " read type value
	do
	        echo "$type $INSERTDATA $value"
	        #echo "$type $INSERTDATA $value" | tee -a $OUTFILE
	done < $INFILE

}

func_sshfsmount () {

#   func_isshfsmount "${keys[DEST_USER]} ${keys[DEST_SERVERNAME]} $MNTLOCAL $MNTREMOTE $L"
    USER_NAME="$1"
    HOST_NAME="$2"
    MOUNTDIR_REMOTE="$3"
    MOUNTDIR_LOCAL="$4"
    LOGFILE="$5"
    sshfs $USER_NAME@$HOST_NAME:$MOUNTDIR_REMOTE $MOUNTDIR_LOCAL | tee -a $LOGFILE
    EXITSTATUS=$?
    if [ "$EXITSTATUS" = "0" ]
    then
	rtn=1
    else
	rtn=0
    fi
    echo $rtn
}

func_destavailable () {
#   func_destavailable "${keys[DEST_USER]} ${keys[DEST_SERVERNAME]}"
    DESTUSER="$1"
    DESTSERVERIP="$2"
#   create a local file
    echo "testing remote connectivity - lib.sh" > /tmp/upfile.txt
#   create an md5sum
    /usr/bin/md5sum /tmp/upfile.txt > /tmp/upfile.md5sum
#   scp file into dest
    /usr/bin/scp /tmp/upfile.txt "$DESTUSER@$DESTSERVERIP:"
#DEBUG echo "/usr/bin/scp /tmp/upfile.txt $DESTUSER@$DESTSERVERIP:"
#   mv original
    rm -f /tmp/upfile.txt
#   scp it back
    /usr/bin/scp $DESTUSER@$DESTSERVERIP:upfile.txt /tmp/
#   check it exists
    if [ -e "/tmp/upfile.txt" ]
	then
		rtn=1
	else
		rtn=0
	fi
	rm /tmp/upfile.txt
	echo $rtn
#still need to check md5sum
}

func_sshtest() {
#is the source available
#func_srcavailable "ro|rw ${keys[SRC_USER]} ${keys[SRC_SERVERNAME]} ${keys[SSH_KEY]}"
	SSHT_TYPE="$1"
	SSHT_USER="$2"
	SSHT_HOST="$3"
	SSHT_KEY="$4"
#list a file
	if [ "$SSHT_TYPE" = "ro" ]
	then
#		ssh $SSHT_USER@$SSHT_HOST "/bin/ls /etc/hosts" > /tmp/ninja_temp
		cmd="ssh $SSHT_USER@$SSHT_HOST "
		cmd2="ls /etc/hosts"
		cmd3="$cmd \""$cmd2\"""
		cmd4="$cmd3 > /tmp/ninja_temp"
		echo "$cmd4"
		$cmd4
		echo "#CANT GET THIS SYNTAX RIGHT!!! - use rw instead please"
exit

		TMPCONTENT=$( cat /tmp/ninja_temp )
		if [ "$TMPCONTENT" = "/etc/hosts" ] 
		then
			rtn=1
		else
			rtn=0
		fi
	else
		rtn=$(func_destavailable "$SSHT_USER" "$SSHT_HOST" "$SSHT_KEY")
		
	fi
	echo $rtn
}

func_isfileexists() {
        whatfile="$1"
        if [ -f "$whatfile" ]
        #if [ -e "$whatfile" ]
        then
                rtn=1
        else
                rtn=0
        fi
	echo $rtn
}

func_touchfile() {
	touch $1
	if [ -f $1 ]
	then
		rtn=1
	else
		rtn=0
	fi
	echo $rtn
}	

func_killfile () {
	rm -f $1
	EXITSTATUS=$?
	if [ "$EXITSTATUS" = "0" ]
	then
		rtn=1
	else
		rtn=0
	fi
	echo $rtn
}	

func_add () {
	rtn=$( expr $1+$2 )
	echo $rtn
}


func_compare () {
	if [ "$1" == "$2" ]
	then
		rtn=1
	else
		rtn=0
	fi
	echo $rtn
}

func_drivemounted () {
	HDLABEL="$1"
	MOUNTPOINT="$2"
	sblk=$( /bin/mount | grep "$HDLABEL" | grep "$MOUNTPOINT" | wc -l )
	if [ "$sblk" = "1" ]
	then
		rtn=1
	else
		rtn=0
	fi
	echo $rtn
}


func_drivepresent () {
	HDLABEL="$1"
	sblk=$( /sbin/blkid | grep "$HDLABEL" | wc -l )
	if [ "$sblk" = "1" ]
	then
		rtn=1
	else
		rtn=0
	fi
	echo $rtn
}

func_dismountdrive () {
	/bin/umount -l "$1"
         RESULT=$?
         if [ "$RESULT" = "0" ]
         then
                 rtn=1
         else
                 rtn=0
         fi

	echo $rtn
}

func_dismountusbdrive () {
	/bin/umount -l "$2"
	#now check if its still mounted
	R=$(func_drivemounted "$1" "$2")	
	if [ "$R" = "0" ]
	then
		rtn=1
		
	else
		rtn=0
	fi
	echo $rtn
}

func_mountdrive () {
#args: label mountpoint
	/bin/mount -L $1 $2
	RESULT=$?
	if [ "$RESULT" = "0" ]
	then
		rtn=1
	else
		rtn=0
	fi
	#test if its already mounted, in which case modify back to rtn1
	rtn=$( mount | grep "$1" | grep "$2" | wc -l)
	
	echo $rtn
return $rtn
}

func_getfreepc () {
	MOUNTPOINT="$1"
#	SPACE=$( df "$1" | grep ^\/ | awk '{ print $5 }' | tr  -d "%")
	SPACE=$( df "$1" | tail -n 1 | awk '{ print $5 }' | tr  -d "%")
	SPACEFREE=$( expr 100 - $SPACE )
	echo "$SPACEFREE"
}

func_getfilesize () {
	FNAME="$1"
	FSIZE=$( du -s "$FNAME" | awk '{ print $1 }' )
	echo "$FSIZE"
}


func_concatstring () {
	rtn="$1 $2"
echo "$rtn"
}

func_mkdir () {
	mkdir $1
#needs rtn
}


func_replaceparaminfile() {

        TMPLTFNAME=$1
        TMPLTFLDPARAM=$2
        TMPLFLDARG="$3"

        #first fix the arg, it may have // characters innit
        TMPLFLDARGFIXED=$(echo "$TMPLFLDARG"|sed 's!\([]\*\$\/&[]\)!\\\1!g')
        TMPLTFLDARG=$TMPLFLDARGFIXED
        result=$(sed -i "s/$TMPLTFLDPARAM/$TMPLTFLDARG/1" "$TMPLTFNAME")
        replaceparaminfile=$?
}

