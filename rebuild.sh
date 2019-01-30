#!/bin/sh
rm -fr build
mkdir build
cd build
cmake -DCMAKE_INSTALL_PREFIX=/usr ..
make
