#!/bin/sh
rm -fr build
mkdir build
cd build
cmake -DCMAKE_INSTALL_PREFIX=/usr ..
make
cd ..
kpackagetool5 -t Plasma/Applet --remove net.linuxcondom.plasma.koolmorning
kpackagetool5 -t Plasma/Applet --install package
