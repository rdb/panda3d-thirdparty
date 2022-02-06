This repository contains a CMake script to build the thirdparty packages that
are necessary for building Panda3D.

Usage example on Windows:

    mkdir build
    cd build
    cmake -G"Visual Studio 16 2019" -A x64 ..
    cmake --build . --config Release

Usage example on other systems:

    mkdir build
    cd build
    cmake ..
    make ffmpeg # just build ffmpeg and dependencies
    make all # build everything

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
- [x] mimalloc
- [x] nvidiacg (except arm64 or Android)
- [x] ode
- [x] openal
- [x] opencv (macOS only)
- [x] openexr
- [x] openssl
- [x] opus
- [x] png
- [x] squish
- [x] tiff
- [x] vorbis
- [x] vrpn
- [x] zlib

A package can be explicitly disabled using the `BUILD_*` options, eg. `-DBUILD_VRPN=OFF` disables building VRPN.  Note that some packages have dependencies on other packages, so not all combinations are valid.

To build nothing but eg. vrpn, specify: `-DDISABLE_ALL=ON -DBUILD_VRPN=ON`.  This only affects the initial configuration.  However, it is easier to just specify a target to the build command, such as using `make vrpn`, since this will do dependency resolution properly.
