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
echo "This installation script requires root privileges."
echo -n "Can you gain them? [y/n] "
read
if [ "x$REPLY" != "xy" ] ; then
	echo
	echo "Ask you system administrator to install icmpengine"
	echo "from $giturl"
	retcode=1
else
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
		sudo make install || su -c "make install"
	fi
fi
echo
echo "Press return to exit"
read a
exit $retcode
