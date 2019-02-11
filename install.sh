#!/bin/sh
# Copyright (C) 2019 by Shining the Master of Warders <shining@linuxcondom.net>                            *
# This file is part of "Kool Morning"
# Read COPYING for license details
detect="n"
force="n"
plasma_restart="n"
scratch="n"
systemwide="n"
usage="n"
uninstall="n"
program=$0
CMAKE_INSTALL_PREFIX="/usr"
local_install_dir="$HOME/.local/share/plasma/plasmoids/$package"
systemwide_install_dir="$CMAKE_INSTALL_PREFIX/share/plasma/plasmoids/$package"

detect_installations()
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
	echo "Usage:\t$program [[-d] | [-h] | [[-f][-l] | [-w]] [[-p][-s]|[-u]]] [dir]"
	echo "\t-d = detect current installations"
	echo "\t-f = force. Uninstall and then install again instead of upgrade"
	echo "\t-h = print this help message and exit"
	echo "\t-l = local operations (default)"
	echo "\t-p = restart plasma shell"
	echo "\t-s = rebuild from scratch"
	echo "\t-u = uninstall"
	echo "\t-w = system wide operations"
	echo "\tdir = the directory containing metadata.desktop (defaults to 'package')"
	exit 0
}

while getopts dfhlpsuw arg; do
	case "$arg" in
		d)	detect="y";;
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
shift $(( OPTIND-1 ))
metadir="${1:-package}"
metadata="$metadir/metadata.desktop"
if [ ! -r "$metadata" ] ; then
	echo "cannot read $metadata. Exiting"
	exit 4
fi
package=`grep X-KDE-PluginInfo-Name $metadata|cut -f2 -d = | tr -d '[:space:]'`
plasmoid=${package##*.}

[ "$detect" = "y" ] && detect_installations

if [ "$plasma_restart" = "y" -a "$uninstall" = "y" ] ; then
	echo "-p and -u are mutually exclusive. Exiting" > /dev/stderr
	exit 3
fi
[ "$scratch" = "y" ] && rm -fr build
[ -d "build" ] || mkdir build
if [ "$uninstall" = "n" ] ; then
	cd build
	cmake -DCMAKE_INSTALL_PREFIX=$CMAKE_INSTALL_PREFIX .. && make || exit $?
fi
if [ "$systemwide" = "y" ] ; then
	if [ "$uninstall" = "y" ] ; then
		systemwide_uninstall
	else
		if [ -d "$systemwide_install_dir" ] ; then
			echo "Removing old installation" > /dev/stderr
			systemwide_uninstall
		fi
		sudo make install
		cd ..
	fi
else
	cd ..
	old="n"
	[ -d "$HOME/.local/share/plasma/plasmoids/$package" ] && old="y"
	if [ "$uninstall" = "y" ] ; then
		if [ "$old" = "n" ] ; then
			echo "No previous installation found. Exiting" > /dev/stderr
			exit 2
		fi
		kpackagetool5 -t Plasma/Applet --remove $package || exit $?
	elif [ "$force" = "y" ] ; then
		kpackagetool5 -t Plasma/Applet --remove $package || exit $?
		kpackagetool5 -t Plasma/Applet --install package && echo "Package reinstalled" || exit $?
	elif [ "$old" = "y" ] ; then
		kpackagetool5 -t Plasma/Applet --upgrade package && echo "Package upgraded" || exit $?
	else
		kpackagetool5 -t Plasma/Applet --install package && echo "Package installed" || exit $?
	fi
fi

if [ "$uninstall" = "n" ] ; then
	echo "plasmoid: $plasmoid"
	ln -s package $plasmoid
	echo $PWD
	echo -n "plasmoid dir: "
	ls -d $plasmoid
	echo zip -r $plasmoid $plasmoid -x \*.qmlc
	zip -r $plasmoid.plasmoid $plasmoid -x \*.qmlc .\*.swp
	rm $plasmoid
fi
if [ "$plasma_restart" = "y" ] ; then
	kbuildsycoca5 && kquitapp5 plasmashell && kstart5 plasmashell || exit $?
fi
exit 0
