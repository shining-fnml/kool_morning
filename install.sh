#!/bin/sh
force="n"
plasma_restart="n"
scratch="n"
systemwide="n"
usage="n"
uninstall="n"
program=$0
CMAKE_INSTALL_PREFIX="/usr"
package="net.linuxcondom.plasma.koolmorning"
local_install_dir="$HOME/.local/share/plasma/plasmoids/$package"
systemwide_install_dir="$CMAKE_INSTALL_PREFIX/share/plasma/plasmoids/$package"

detect()
{
	count=0
	[ -d "$systemwide_install_dir" ] && count=$(( count + 1 ))
	[ -r "$CMAKE_INSTALL_PREFIX/share/metainfo/$package.appdata.xml" ] && count=$(( count + 1 ))
	[ -r "$CMAKE_INSTALL_PREFIX/share/kservices5/plasma-applet-$package.desktop" ] && count=$(( count + 1 ))
	case "$count" in
		0) echo -n "no" ;;
		3) echo -n "working" ;; 
		*) echo -n "partial (broken)" ;;
	esac
	echo " system wide installation detected"
	[ -d "$local_install_dir" ] || echo -n "no "
	echo "user installation detected"
	exit 0
}

systemwide_uninstall()
{
	sudo rm -rf $systemwide_install_dir $CMAKE_INSTALL_PREFIX/share/metainfo/$package.appdata.xml $CMAKE_INSTALL_PREFIX/share/kservices5/plasma-applet-$package.desktop
}

usage()
{
	echo "Usage:\t$program [[-d] | [-h] | [[-f][-l] | [-w]] [[-p][-s]|[-u]]]"
	echo "\t\t-d = detect current installations"
	echo "\t\t-f = force. Uninstall and then install again instead of upgrade"
	echo "\t\t-h = print this help message and exit"
	echo "\t\t-l = local operations [default]"
	echo "\t\t-p = restart plasma shell"
	echo "\t\t-s = rebuild from scratch"
	echo "\t\t-u = uninstall"
	echo "\t\t-w = system wide operations"
	exit 0
}

while getopts dfhlpsuw arg; do
	case "$arg" in
		d)	detect;;
		f)	force="y";;
		h)	usage;;
		l)	systemwide="n";;
		p)	plasma_restart="y";;
		s)	scratch="y";;
		u)	uninstall="y";;
		w)	systemwide="y";;
		[?])	echo "run '$0 -h' for usage " > /dev/stderr
			exit 1;;
		esac
done
# shift $OPTIND-1
if [ "$plasma_restart" = "y" -a "$uninstall" = "y" ] ; then
	echo "-p and -u are mutually exclusive. Exiting" > /dev/stderr
	exit 3
fi
[ "$scratch" = "y" ] && rm -fr build
[ -d "build" ] || mkdir build
if [ "$uninstall" = "n" ] ; then
	cd build
	cmake -DCMAKE_INSTALL_PREFIX=$CMAKE_INSTALL_PREFIX ..
	make
fi
if [ "$systemwide" = "n" ] ; then
	cd ..
	old="n"
	[ -d "$HOME/.local/share/plasma/plasmoids/$package" ] && old="y"
	if [ "$uninstall" = "y" ] ; then
		if [ "$old" = "n" ] ; then
			echo "No previous installation found. Exiting" > /dev/stderr
			exit 2
		fi
		kpackagetool5 -t Plasma/Applet --remove $package
	elif [ "$force" = "y" ] ; then
		kpackagetool5 -t Plasma/Applet --remove $package
		kpackagetool5 -t Plasma/Applet --install package && echo "Package reinstalled"
	elif [ "$old" = "y" ] ; then
		kpackagetool5 -t Plasma/Applet --upgrade package && echo "Package upgraded"
	else
		kpackagetool5 -t Plasma/Applet --install package && echo "Package installed"
	fi
else
	if [ "$uninstall" = "y" ] ; then
		systemwide_uninstall
	else
		if [ -d "$systemwide_install_dir" ] ; then
			echo "Removing old installation" > /dev/stderr
			systemwide_uninstall
		fi
		sudo make install
	fi
fi

if [ "$plasma_restart" = "y" ] ; then
	kbuildsycoca5 && kquitapp5 plasmashell && kstart5 plasmashell
fi
