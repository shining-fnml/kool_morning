#!/bin/bash
giturl="https://github.com/shining-fnml/icmpengine"
retcode=0
function check_exe()
{
	required=$1
	echo -n "Looking for $required... "
	which $required > /dev/null
	if [ $? -eq 0 ] ; then
		echo "[found]"
		return 0
	fi
	echo "[missing]"
	return 1
}
echo "This installation script requires super user powers"
power=""
while [ "x$power" = "x" ] ; do
	echo "How are you going to gain root privileges?"
	echo "1) sudo"
	echo "2) su"
	echo "3) I don't know / I can't"
	read
	case "$REPLY" in
		"1")
			power="sudo"
			break
			;;
		"2")
			power="su"
			break
			;;
		"3")
			echo
			echo "Sorry. You better ask your system administrator to install icmpengine"
			echo "from $giturl"
			power="no"
			retcode=1
			break
	esac
done
if [ "$power" != "no" ] ; then
	requires="cmake g++ git make"
	sum=0
	for checking in $requires ; do
		check_exe $checking
		sum=$(( sum + $? ))
	done
	if [ $sum -gt 0 ] ; then
		echo "A required program is missing. Sorry, I give up"
		retcode=2
	else
		tmpdir=`mktemp -d /tmp/icmpinstall.XXXXXX`
		cd $tmpdir
		git clone $giturl --branch plasma5 --single-branch
		cd icmpengine
		mkdir build
		cd build
		cmake -DCMAKE_INSTALL_PREFIX=/usr .. && make
		if [ "$power" = "sudo" ] ; then
			sudo make install || retcode=$?
		elif [ "$power" = "su" ] ; then
			su -c "make install" || retcode=$?
		fi
	fi
fi
echo
echo "Press return to exit"
echo "retcode: $retcode"
read a
[ "$retcode" -ne 0 ] && kill -USR1 $PPID
exit $retcode
