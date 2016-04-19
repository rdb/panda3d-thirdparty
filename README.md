This repository contains a CMake script to build the thirdparty packages that
are necessary for building Panda3D.

Currently it only works on Windows.

Usage example:

    mkdir build
    cd build
    cmake -DCMAKE_BUILD_TYPE=Release -G"Visual Studio 14 2015 Win64" ..
    cmake --build . --config Release


Included packages:
* assimp
* bullet
* freetype
* jpeg
* openal
* png
* vorbis
* zlib

Still missing:
* artoolkit
* eigen
* fcollada
* ffmpeg
* fmodex
* nvidiacg
* ode
* rocket
* squish
* tiff
* vrpn
