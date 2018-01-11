#!/bin/bash
#reversi client setup  version 201712/1

echo "TODO SECURITY"
echo "send also a password per port to authenicate the device this was installed on"
echo "secure with http://askubuntu.com/questions/48129/how-to-create-a-restricted-ssh-user-for-port-forwarding"
echo "patch logger for monitoring https://blog.rootshell.be/2009/03/01/keep-an-eye-on-ssh-forwarding/"

echo "TODO USABILITY"
echo "Sanity check port duplicates by scanning sources directory for duplicate port allocations"
echo "ensure cvorrect args passed or abort"

REVUSER="reversi" #AAAAAA
V=7
APPDIR=$( cd "$( dirname "$0" )" && pwd )
cd $APPDIR 
. $APPDIR/libs/reversiclientlib.sh
BUILDDIR=$APPDIR/build
SOURCEDIR=$APPDIR/sources
SOURCEARCHIVE=$APPDIR/sourcestore
TEMPLATESDIR=$APPDIR/templates
RESOURCEDIR=$APPDIR/resources
KEYSDIR=$APPDIR/keys
INSTALLDIR="/root/reversiclient-$V"
BUILDROOTDIR="/reversiclient-$V"


USAGE="Usage: $0 build|compile"
numargs="$#"
if [ "$#" == "0" ]; then
        echo "$USAGE"
        exit 0
fi

if [ -z $1 ]; then
        echo "No command provided. $USAGE"
        exit 0
fi

FUNC=$1
if [ "$FUNC" = "build" ]; then
	rm -f $BUILDDIR/*
fi


#name the file that sets up screens
exename="$BUILDDIR/reversi.sh"	
#for each config file.. we need to set up screens 
for cfile in $SOURCEDIR/*.rev; do
	declare -A keys
	READFILE="$cfile"
	while IFS=":" read name value
	do
		keys[$name]="$value"
	done < $READFILE
	#name the files to be created
	opname="$BUILDDIR/${keys[cscreenname]}${keys[reversiport]}REV.sh"
	monname="$BUILDDIR/${keys[mscreenname]}${keys[reversiport]}REV.sh"
	monname_simple="${keys[mscreenname]}${keys[reversiport]}REV.sh"
	opname_simple="${keys[cscreenname]}${keys[reversiport]}REV.sh"
	subname="$TEMPLATESDIR/rev_screen.sh"
	#set up master file
	#MASTERDIR="$SOURCEDIR/${keys[nodename]}"
	#mkdir "$MASTERDIR"
	echo "opname:$opname"
	echo "monname:$monname"
	case $FUNC in
	# create the sh files
	build)
		exename="$BUILDDIR/reversi.sh"
		cscname="${keys[cscreenname]}${keys[reversiport]}"
		mscname="${keys[mscreenname]}${keys[reversiport]}"
		stuffsecs="${keys[stuffsecs]}"
		echo "creating $exename"
		if [ ! -f "$exename" ]; then 
			cp -a $TEMPLATESDIR/${keys[exetemplatename]} $exename
		fi
		echo "creating $opname"
		cp -a $TEMPLATESDIR/${keys[tuntemplatename]} $opname
		echo "creating $monname"
		cp -a $TEMPLATESDIR/${keys[montemplatename]} $monname
		FIXMONNAME=$(echo "${keys[mscreenname]}${keys[reversiport]}REV.sh"|sed 's!\([]\*\$\/&[]\)!\\\1!g')
		FIXOPNAME=$(echo "${keys[cscreenname]}${keys[reversiport]}REV.sh"|sed 's!\([]\*\$\/&[]\)!\\\1!g')
		sed -i "s/\[OPNAME\]/$FIXOPNAME/g" $monname
		cat $TEMPLATESDIR/rev_screen.sh >> $exename
		sed -i "s/\[CSCNAME\]/$cscname/g" $exename
		sed -i "s/\[MSCNAME\]/$mscname/g" $exename
		sed -i "s/\[OPNAME\]/$FIXOPNAME/g" $exename
		sed -i "s/\[MONNAME\]/$monname_simple/g" $exename
		sed -i "s/\[MONNAME\]/$monname_simple/g" $monname
		sed -i "s/\[STUFFSECS\]/$stuffsecs/g" $exename
		FIXINSTALLDIR=$(echo "$INSTALLDIR"|sed 's!\([]\*\$\/&[]\)!\\\1!g')
		sed -i "s/\[INSTALLDIR\]/$FIXINSTALLDIR/g" $exename
		sed -i "s/\[INSTALLDIR\]/$FIXINSTALLDIR/g" $monname
		sed -i "s/\[INSTALLDIR\]/$FIXINSTALLDIR/g" $opname
		sed -i "s/\[CSCNAME\]/$cscname/g" $opname
		sed -i "s/\[MSCNAME\]/$mscname/g" $opname
		sed -i "s/\[CSCNAME\]/$cscname/g" $monname
		sed -i "s/\[MSCNAME\]/$mscname/g" $monname
		sed -i "s/\[REVERSISSHPORT\]/${keys[reversisshport]}/g" $opname
		sed -i "s/\[REVERSISSHPORT\]/${keys[reversisshport]}/g" $monname
		if [ "${keys[allowinternet]}" == "1" ] 
		then
			sed -i "s/\[ALLOWINTERNET\]/-g/g" $opname
		else
			sed -i "s/\[ALLOWINTERNET\]/ /g" $opname
		fi
		for i in "${!keys[@]}"; do 
			ele="$i"
			dat=${keys[$i]}
			fixdat=$(echo "$dat"|sed 's!\([]\*\$\/&[]\)!\\\1!g')
			sed -i "s/\[$ele\]/$fixdat/g" $opname	
			sed -i "s/\[$ele\]/$fixdat/g" $monname
		done
		cp $KEYSDIR/${keys[reversisshkey]} $BUILDDIR
	;;
	compile)
		echo "tarring file for distribution via $BUILDROOTDIR"
		mkdir "$BUILDROOTDIR"
		rm -f $BUILDROOTDIR/*
		cp $RESOURCEDIR/* $SOURCEDIR/*.rev $BUILDROOTDIR/
		mv $BUILDDIR/* $BUILDROOTDIR/ 
		echo "tarred and removing files from $BUILDROOTDIR (a copy is made to $SOURCEARCHIVE/${keys[nodename]})"
		/bin/tar -cf $APPDIR/${keys[nodename]}-reversiclient-$V.tar -C $BUILDROOTDIR $BUILDROOTDIR
		mkdir $SOURCEARCHIVE/${keys[nodename]}
		mv $BUILDROOTDIR/* $SOURCEARCHIVE/${keys[nodename]}/
		exit
	;;
	esac
done

echo "reversi script all done"

#KB
#	printf "%s\t%s\n" "$i" "${keys[$i]}"
