#!/bin/bash
rm -fr build
mkdir build
cd build
cmake -DCMAKE_INSTALL_PREFIX=/usr ..
make
cd ..
if [ "x$1" = "x-f" ] ; then
	kpackagetool5 -t Plasma/Applet --remove net.linuxcondom.plasma.koolmorning
	kpackagetool5 -t Plasma/Applet --install package && echo "Package reinstalled"
elif [ -d "$HOME/.local/share/plasma/plasmoids/net.linuxcondom.plasma.koolmorning" ] ; then
	kpackagetool5 -t Plasma/Applet --upgrade package && echo "Package upgraded"
else
	kpackagetool5 -t Plasma/Applet --install package && echo "Package installed"
fi
