This repository contains a CMake script to build the thirdparty packages that
are necessary for building Panda3D.

Currently it only works on Windows.

Usage example:

    mkdir build
    cd build
    cmake -DCMAKE_BUILD_TYPE=Release -G"Visual Studio 14 2015 Win64" ..
    cmake --build . --config Release


Some packages are still forthcoming.  The included packages are ticked.
- [ ] artoolkit
- [x] assimp
- [x] bullet
- [ ] eigen
- [x] fcollada
- [ ] ffmpeg
- [ ] fmodex
- [x] freetype
- [x] jpeg
- [ ] nvidiacg
- [ ] ode
- [x] openal
- [x] png
- [ ] rocket
- [x] squish
- [ ] tiff
- [x] vorbis
- [ ] vrpn
- [x] zlib
