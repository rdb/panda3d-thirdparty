This repository contains a CMake script to build the thirdparty packages that
are necessary for building Panda3D.

Usage example:

    mkdir build
    cd build
    cmake -DCMAKE_BUILD_TYPE=Release -G"Visual Studio 14 2015 Win64" ..
    cmake --build . --config Release

To build with Visual Studio 2015 for 64-bit Windows XP, change the command to:

    cmake -DCMAKE_BUILD_TYPE=Release -G"Visual Studio 14 2015 Win64" -DCMAKE_SYSTEM_VERSION=5.2 -T v140_xp ..

To build with Visual Studio 2015 for 32-bit Windows XP, change the command to:

    cmake -DCMAKE_BUILD_TYPE=Release -G"Visual Studio 14 2015" -DCMAKE_SYSTEM_VERSION=5.1 -T v140_xp ..

Some packages are still forthcoming.  The included packages are ticked.
- [x] artoolkit
- [x] assimp (except Mac)
- [x] bullet
- [x] eigen
- [x] fcollada
- [x] ffmpeg
- [ ] fmodex
- [x] freetype
- [x] harfbuzz
- [x] jpeg
- [x] nvidiacg
- [x] ode
- [x] openal
- [x] openexr
- [x] openssl
- [x] opus
- [x] png
- [ ] rocket
- [x] squish
- [x] tiff
- [x] vorbis
- [x] vrpn
- [x] zlib

A package can be explicitly disabled using the `BUILD_*` options, eg. `-DBUILD_VRPN=OFF` disables building VRPN.  Note that some packages have dependencies on other packages, so not all combinations are valid.

To build nothing but eg. vrpn, specify: `-DDISABLE_ALL=ON -DBUILD_VRPN=ON`.  This only affects the initial configuration.
