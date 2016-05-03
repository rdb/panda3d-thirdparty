This repository contains a CMake script to build the thirdparty packages that
are necessary for building Panda3D.

Usage example:

    mkdir build
    cd build
    cmake -DCMAKE_BUILD_TYPE=Release -G"Visual Studio 14 2015 Win64" ..
    cmake --build . --config Release


Some packages are still forthcoming.  The included packages are ticked.
- [x] artoolkit
- [x] assimp
- [x] bullet
- [x] eigen
- [x] fcollada
- [ ] ffmpeg
- [ ] fmodex
- [x] freetype
- [x] jpeg
- [ ] nvidiacg
- [x] ode
- [x] openal
- [x] openexr
- [ ] openssl
- [x] png
- [ ] rocket
- [x] squish
- [x] tiff
- [x] vorbis
- [x] vrpn
- [x] zlib
