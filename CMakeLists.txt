# Many of this is based on the scripts in the Polycode project.  Many thanks
# to the respective authors for going through the work of figuring this out!

cmake_minimum_required(VERSION 2.8.3)

include(ExternalProject)

if(CMAKE_GENERATOR MATCHES "^Visual Studio [0-9]+ ")
  string(REPLACE " " ";" WORDS ${CMAKE_GENERATOR})
  list(GET WORDS 2 VCVER)
  set(THIRDPARTY_DIR ${CMAKE_SOURCE_DIR}/win-libs-vc${VCVER})

  if(CMAKE_GENERATOR MATCHES "Win64$")
    set(THIRDPARTY_DIR "${THIRDPARTY_DIR}-x64")
  endif()

elseif(CMAKE_SYSTEM_NAME STREQUAL "Darwin")
  set(THIRDPARTY_DIR ${CMAKE_SOURCE_DIR}/darwin-libs-a)

elseif(CMAKE_SYSTEM_NAME STREQUAL "Linux")
  if(CMAKE_SIZEOF_VOID_P EQUAL 8)
    set(THIRDPARTY_DIR ${CMAKE_SOURCE_DIR}/linux-libs-x64)
  else()
    set(THIRDPARTY_DIR ${CMAKE_SOURCE_DIR}/linux-libs-a)
  endif()

elseif(CMAKE_SYSTEM_NAME STREQUAL "FreeBSD")
  if(CMAKE_SIZEOF_VOID_P EQUAL 8)
    set(THIRDPARTY_DIR ${CMAKE_SOURCE_DIR}/freebsd-libs-x64)
  else()
    set(THIRDPARTY_DIR ${CMAKE_SOURCE_DIR}/freebsd-libs-a)
  endif()

else()
  message(FATAL_ERROR "Unknown platform.")
endif()

if(NOT MSVC)
  set(CMAKE_C_FLAGS "-fpic")
  set(CMAKE_CXX_FLAGS "-fpic")
endif()

message("thirdparty packages will be installed to ${THIRDPARTY_DIR}")

set(COMMON_CMAKE_ARGS
  -DCMAKE_C_FLAGS=${CMAKE_C_FLAGS}
  -DCMAKE_CXX_FLAGS=${CMAKE_CXX_FLAGS}
  -DCMAKE_INSTALL_PREFIX:PATH=<INSTALL_DIR>
  -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
  -DCMAKE_C_COMPILER=${CMAKE_C_COMPILER}
  -DCMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER}
  -DCMAKE_LINKER=${CMAKE_LINKER}
  -DCMAKE_TOOLCHAIN_FILE=${CMAKE_TOOLCHAIN_FILE}
  -DCMAKE_INSTALL_LIBDIR=lib
  -DBUILD_SHARED_LIBS=OFF
  -DSKIP_INSTALL_EXECUTABLES=ON
  -DSKIP_INSTALL_FILES=ON
)

if(APPLE)
  # Prevent the semicolon from becoming a space in the command.
  string(REPLACE ";" "$<SEMICOLON>" archs "${CMAKE_OSX_ARCHITECTURES}")
  set(COMMON_CMAKE_ARGS ${COMMON_CMAKE_ARGS}
    -DCMAKE_OSX_ARCHITECTURES=${archs}
    -DCMAKE_OSX_DEPLOYMENT_TARGET=${CMAKE_OSX_DEPLOYMENT_TARGET}
    -DCMAKE_OSX_SYSROOT=${CMAKE_OSX_SYSROOT}
  )
endif(APPLE)

ExternalProject_Add(
  zlib
  #GIT_REPOSITORY https://github.com/madler/zlib.git
  URL https://github.com/madler/zlib/archive/v1.2.11.tar.gz
  URL_HASH SHA256=629380c90a77b964d896ed37163f5c3a34f6e6d897311f1df2a7016355c45eff

  CMAKE_ARGS ${COMMON_CMAKE_ARGS}
    -DZLIB_TESTS=OFF
  INSTALL_DIR ${THIRDPARTY_DIR}/zlib
)

# Remove the shared libraries, which cannot be disabled in the CMake file.
if(WIN32)
  ExternalProject_Add_Step(zlib remove_extras
    COMMAND ${CMAKE_COMMAND} -E remove_directory "<INSTALL_DIR>/bin"
    COMMAND ${CMAKE_COMMAND} -E remove_directory "<INSTALL_DIR>/share"
    DEPENDEES install
  )
elseif(APPLE)
  ExternalProject_Add_Step(zlib remove_extras
    COMMAND ${CMAKE_COMMAND} -E remove "<INSTALL_DIR>/lib/libz.dylib"
                                       "<INSTALL_DIR>/lib/libz.1.dylib"
                                       "<INSTALL_DIR>/lib/libz.1.2.11.dylib"
    DEPENDEES install
  )
else()
  ExternalProject_Add_Step(zlib remove_extras
    COMMAND ${CMAKE_COMMAND} -E remove "<INSTALL_DIR>/lib/libz.so"
                                       "<INSTALL_DIR>/lib/libz.so.1"
                                       "<INSTALL_DIR>/lib/libz.so.1.2.11"
    DEPENDEES install
  )
endif()

ExternalProject_Add(
  png
  DEPENDS zlib
  #GIT_REPOSITORY https://github.com/glennrp/libpng.git
  URL https://github.com/glennrp/libpng/archive/v1.6.28.tar.gz
  URL_HASH SHA256=a8f0b08a99e8a8b1da43c28655647ff3c6b338388d6cdd608f4ee87a85cc6e08

  CMAKE_ARGS ${COMMON_CMAKE_ARGS}
    -DCMAKE_PREFIX_PATH=${THIRDPARTY_DIR}/zlib
    -DPNG_SHARED=OFF
    -DPNG_STATIC=ON
    -DPNG_TESTS=OFF
    -DPNG_DEBUG=OFF
  INSTALL_DIR ${THIRDPARTY_DIR}/png
)

if(NOT APPLE)
  ExternalProject_Add(
    assimp
    DEPENDS zlib
    GIT_REPOSITORY https://github.com/assimp/assimp.git

    CMAKE_ARGS ${COMMON_CMAKE_ARGS}
      -DCMAKE_PREFIX_PATH=${THIRDPARTY_DIR}/zlib
      -DASSIMP_BUILD_TESTS=OFF
      -DASSIMP_BUILD_ASSIMP_TOOLS=OFF
      -DASSIMP_NO_EXPORT=ON
      -DLIBRARY_SUFFIX=
    INSTALL_DIR ${THIRDPARTY_DIR}/assimp
  )
endif()

ExternalProject_Add(
  bullet
  #GIT_REPOSITORY https://github.com/bulletphysics/bullet3.git
  URL https://github.com/bulletphysics/bullet3/archive/2.83.7.tar.gz
  URL_HASH SHA256=00d1d8f206ee85ffd171643ac8e72f9f4e0bf6dbf3d4ac55f4495cb168b51243

  CMAKE_ARGS ${COMMON_CMAKE_ARGS}
    -DINSTALL_LIBS=ON
    -DUSE_MSVC_RUNTIME_LIBRARY_DLL=ON
    -DBUILD_DEMOS=OFF
    -DBUILD_CPU_DEMOS=OFF
    -DBUILD_OPENGL3_DEMOS=OFF
    -DBUILD_BULLET2_DEMOS=OFF
    -DBUILD_BULLET3=OFF
    -DBUILD_EXTRAS=OFF
    -DBUILD_UNIT_TESTS=OFF
    -DINCLUDE_INSTALL_DIR:STRING=include/
  INSTALL_DIR ${THIRDPARTY_DIR}/bullet
)

ExternalProject_Add(
  freetype
  DEPENDS zlib png
  URL http://download.savannah.gnu.org/releases/freetype/freetype-2.7.1.tar.gz
  URL_HASH SHA256=162ef25aa64480b1189cdb261228e6c5c44f212aac4b4621e28cf2157efb59f5

  CMAKE_ARGS ${COMMON_CMAKE_ARGS}
    -DCMAKE_PREFIX_PATH=${THIRDPARTY_DIR}/zlib;${THIRDPARTY_DIR}/png
    -DWITH_HarfBuzz=OFF
    -DWITH_BZip2=OFF
    -DPNG_INCLUDE_DIRS=${THIRDPARTY_DIR}/png/include
  INSTALL_DIR ${THIRDPARTY_DIR}/freetype
)

ExternalProject_Add(
  ogg
  URL http://downloads.xiph.org/releases/ogg/libogg-1.3.2.tar.gz
  URL_HASH SHA256=e19ee34711d7af328cb26287f4137e70630e7261b17cbe3cd41011d73a654692

  PATCH_COMMAND ${CMAKE_COMMAND} -E copy_if_different ${CMAKE_CURRENT_LIST_DIR}/libogg.cmake <SOURCE_DIR>/CMakeLists.txt

  CMAKE_ARGS ${COMMON_CMAKE_ARGS}
  INSTALL_DIR ${THIRDPARTY_DIR}/vorbis
)

ExternalProject_Add(
  vorbis
  DEPENDS ogg
  URL http://downloads.xiph.org/releases/vorbis/libvorbis-1.3.5.tar.gz
  URL_HASH SHA256=6efbcecdd3e5dfbf090341b485da9d176eb250d893e3eb378c428a2db38301ce

  PATCH_COMMAND ${CMAKE_COMMAND} -E copy_if_different ${CMAKE_CURRENT_LIST_DIR}/libvorbis.cmake <SOURCE_DIR>/CMakeLists.txt

  CMAKE_ARGS ${COMMON_CMAKE_ARGS}
    -DCMAKE_PREFIX_PATH=${THIRDPARTY_DIR}/vorbis
  INSTALL_DIR ${THIRDPARTY_DIR}/vorbis
)

ExternalProject_Add(
  openal
  GIT_REPOSITORY https://github.com/kcat/openal-soft.git
  GIT_TAG e270a9784bdacecedb98312a4e2e9ef75ef7df62

  CMAKE_ARGS ${COMMON_CMAKE_ARGS}
    -DLIBTYPE=STATIC
    -DALSOFT_HRTF_DEFS=OFF
    -DALSOFT_AMBDEC_PRESETS=OFF
    -DALSOFT_CONFIG=OFF
    -DALSOFT_NO_CONFIG_UTIL=ON
    -DALSOFT_EXAMPLES=OFF
    -DALSOFT_TESTS=OFF
    -DALSOFT_UTILS=OFF
  INSTALL_DIR ${THIRDPARTY_DIR}/openal
)

ExternalProject_Add(
  jpeg
  URL http://www.ijg.org/files/jpegsrc.v9b.tar.gz
  URL_HASH SHA256=240fd398da741669bf3c90366f58452ea59041cacc741a489b99f2f6a0bad052

  PATCH_COMMAND ${CMAKE_COMMAND} -E copy_if_different ${CMAKE_CURRENT_LIST_DIR}/libjpeg.cmake <SOURCE_DIR>/CMakeLists.txt
        COMMAND ${CMAKE_COMMAND} -E copy_if_different ${CMAKE_CURRENT_LIST_DIR}/libjpeg-jconfig.h.cmake <SOURCE_DIR>/jconfig.h.cmake

  CMAKE_ARGS ${COMMON_CMAKE_ARGS}
    -DBUILD_STATIC=ON
    -DBUILD_EXECUTABLES=OFF
    -DBUILD_TESTS=OFF
  INSTALL_DIR ${THIRDPARTY_DIR}/jpeg
)

ExternalProject_Add(
  squish
  DEPENDS png
  URL https://storage.googleapis.com/google-code-archive-downloads/v2/code.google.com/libsquish/squish-1.10.tar.gz
  URL_HASH SHA256=aec3428badafdbb3b0ed1ea3a385a8029e65694282459f61b4a538963e8cada3

  PATCH_COMMAND ${CMAKE_COMMAND} -E copy_if_different ${CMAKE_CURRENT_LIST_DIR}/libsquish.cmake <SOURCE_DIR>/CMakeLists.txt

  CMAKE_ARGS ${COMMON_CMAKE_ARGS}
    -DCMAKE_PREFIX_PATH=${THIRDPARTY_DIR}/png
  INSTALL_DIR ${THIRDPARTY_DIR}/squish
)

ExternalProject_Add(
  fcollada
  GIT_REPOSITORY https://github.com/rdb/fcollada.git

  CMAKE_ARGS ${COMMON_CMAKE_ARGS}
    -DBUILD_UNICODE=OFF
    -DBUILD_TESTS=OFF
  INSTALL_DIR ${THIRDPARTY_DIR}/fcollada
)

ExternalProject_Add(
  vrpn
  # Pull from git since 7.33 has some compile issues
  GIT_REPOSITORY https://github.com/vrpn/vrpn.git
  GIT_TAG 9cfc1a536f39e8815066c39a1cef0f8a515a2860

  CMAKE_ARGS ${COMMON_CMAKE_ARGS}
    -DQUATLIB_BUILD_EXAMPLES=OFF
    -DVRPN_BUILD_CLIENTS=OFF
    -DVRPN_BUILD_CLIENT_LIBRARY=ON
    -DVRPN_BUILD_JAVA=OFF
    -DVRPN_BUILD_PYTHON=OFF
    -DVRPN_BUILD_PYTHON_HANDCODED_2X=OFF
    -DVRPN_BUILD_PYTHON_HANDCODED_3X=OFF
    -DVRPN_BUILD_SERVERS=OFF
    -DVRPN_BUILD_SERVER_LIBRARY=OFF
    -DBUILD_TESTING=FALSE
  INSTALL_DIR ${THIRDPARTY_DIR}/vrpn
)

ExternalProject_Add(
  tiff
  DEPENDS zlib jpeg
  URL http://download.osgeo.org/libtiff/tiff-4.0.6.tar.gz
  URL_HASH SHA256=4d57a50907b510e3049a4bba0d7888930fdfc16ce49f1bf693e5b6247370d68c

  CMAKE_ARGS ${COMMON_CMAKE_ARGS}
    -DCMAKE_PREFIX_PATH=${THIRDPARTY_DIR}/zlib;${THIRDPARTY_DIR}/jpeg
    -Dzlib=ON -Djpeg=ON -Dlzma=OFF -Dcxx=OFF
  INSTALL_DIR ${THIRDPARTY_DIR}/tiff
)

# Remove the extra bin and share directories it created.
ExternalProject_Add_Step(tiff remove_extras
  COMMAND ${CMAKE_COMMAND} -E remove_directory "<INSTALL_DIR>/bin"
  COMMAND ${CMAKE_COMMAND} -E remove_directory "<INSTALL_DIR>/share"
  DEPENDEES install
)

ExternalProject_Add(
  eigen
  URL https://bitbucket.org/eigen/eigen/get/3.2.8.tar.gz
  URL_HASH SHA256=8d01d2d3a173c59065642a08d1dd661b399e4fed6edbda632143e7be937de7e0

  # No need to build anything; just copy over the Eigen directory.
  CONFIGURE_COMMAND ""
  BUILD_COMMAND ""

  INSTALL_COMMAND ${CMAKE_COMMAND} -E copy_directory <SOURCE_DIR>/Eigen <INSTALL_DIR>/include/Eigen
  INSTALL_DIR ${THIRDPARTY_DIR}/eigen
)

ExternalProject_Add(
  ode
  URL https://bitbucket.org/odedevs/ode/downloads/ode-0.13.1.tar.gz
  URL_HASH SHA256=35e55e05c6c6ebb813a546017285a7aceedb3e8e55c8ff102e80e26bd84c5658

  PATCH_COMMAND ${CMAKE_COMMAND} -E copy_if_different ${CMAKE_CURRENT_LIST_DIR}/libode.cmake <SOURCE_DIR>/CMakeLists.txt
        COMMAND ${CMAKE_COMMAND} -E copy_if_different ${CMAKE_CURRENT_LIST_DIR}/libode-config.h.cmake <SOURCE_DIR>/ode/src/config.h.cmake

  CMAKE_ARGS ${COMMON_CMAKE_ARGS}
  INSTALL_DIR ${THIRDPARTY_DIR}/ode
)

ExternalProject_Add(
  artoolkit
  URL http://www.panda3d.org/download/noversion/ARToolKit-2.72.1.tgz
  URL_HASH SHA256=1a49a67c6e196b0e9990e90255ce840287ac47b5a53371a68a6dd93a5425d259

  PATCH_COMMAND ${CMAKE_COMMAND} -E copy_if_different ${CMAKE_CURRENT_LIST_DIR}/artoolkit.cmake <SOURCE_DIR>/CMakeLists.txt
        COMMAND ${CMAKE_COMMAND} -E copy_if_different ${CMAKE_CURRENT_LIST_DIR}/artoolkit-config.h.cmake <SOURCE_DIR>/include/AR/config.h.cmake

  CMAKE_ARGS ${COMMON_CMAKE_ARGS} -DCMAKE_OSX_ARCHITECTURES=i386$<SEMICOLON>x86_64
  INSTALL_DIR ${THIRDPARTY_DIR}/artoolkit
)

if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
  if(CMAKE_SIZEOF_VOID_P EQUAL 8)
    ExternalProject_Add(
      nvidiacg
      URL http://www.panda3d.org/download/noversion/nvidiacg-win64.zip
      URL_HASH SHA256=955d6e38bcba7a48e0efc8f2f0f7d5de39901788806e411744c63b55c83edfe2
      CONFIGURE_COMMAND ""
      BUILD_COMMAND ""
      INSTALL_COMMAND ${CMAKE_COMMAND} -E copy_directory <SOURCE_DIR>/lib <INSTALL_DIR>/lib
              COMMAND ${CMAKE_COMMAND} -E copy_directory <SOURCE_DIR>/bin <INSTALL_DIR>/bin
              COMMAND ${CMAKE_COMMAND} -E copy_directory <SOURCE_DIR>/include <INSTALL_DIR>/include
      INSTALL_DIR ${THIRDPARTY_DIR}/nvidiacg
    )
  else()
    ExternalProject_Add(
      nvidiacg
      URL http://www.panda3d.org/download/noversion/nvidiacg-win32.zip
      URL_HASH SHA256=602ae301f3b68953a56a81ba89db0f53c0e10e8350faeb27842c5b827d9783a3
      CONFIGURE_COMMAND ""
      BUILD_COMMAND ""
      INSTALL_COMMAND ${CMAKE_COMMAND} -E copy_directory <SOURCE_DIR>/lib <INSTALL_DIR>/lib
              COMMAND ${CMAKE_COMMAND} -E copy_directory <SOURCE_DIR>/bin <INSTALL_DIR>/bin
              COMMAND ${CMAKE_COMMAND} -E copy_directory <SOURCE_DIR>/include <INSTALL_DIR>/include
      INSTALL_DIR ${THIRDPARTY_DIR}/nvidiacg
    )
  endif()
elseif(CMAKE_SYSTEM_NAME STREQUAL "Darwin")
  ExternalProject_Add(
    nvidiacg
    URL http://www.panda3d.org/download/noversion/NVIDIA_Cg.tgz
    URL_HASH SHA256=cd6b12cca647749101b0286353095c7435251097d1aed0171cfc8afdcededd29
    CONFIGURE_COMMAND ""
    BUILD_COMMAND ""
    INSTALL_COMMAND ${CMAKE_COMMAND} -E copy_directory <SOURCE_DIR>/Library/Frameworks/Cg.framework <INSTALL_DIR>/Cg.framework
    INSTALL_DIR ${THIRDPARTY_DIR}/nvidiacg
  )    
elseif(CMAKE_SYSTEM_NAME STREQUAL "Linux")
  if(CMAKE_SIZEOF_VOID_P EQUAL 8)
    ExternalProject_Add(
      nvidiacg
      URL http://developer.download.nvidia.com/cg/Cg_3.1/Cg-3.1_April2012_x86_64.tgz
      URL_HASH SHA256=e8ff01e6cc38d1b3fd56a083f5860737dbd2f319a39037528fb1a74a89ae9878
      CONFIGURE_COMMAND ""
      BUILD_COMMAND ""
      INSTALL_COMMAND ${CMAKE_COMMAND} -E copy_directory <SOURCE_DIR>/lib64 <INSTALL_DIR>/lib
              COMMAND ${CMAKE_COMMAND} -E copy_directory <SOURCE_DIR>/include <INSTALL_DIR>/include
      INSTALL_DIR ${THIRDPARTY_DIR}/nvidiacg
    )
  else()
    ExternalProject_Add(
      nvidiacg
      URL http://developer.download.nvidia.com/cg/Cg_3.1/Cg-3.1_April2012_x86.tgz
      URL_HASH SHA256=cef3591e436f528852db0e8c145d3842f920e0c89bcfb219c466797cb7b18879
      CONFIGURE_COMMAND ""
      BUILD_COMMAND ""
      INSTALL_COMMAND ${CMAKE_COMMAND} -E copy_directory <SOURCE_DIR>/lib <INSTALL_DIR>/lib
              COMMAND ${CMAKE_COMMAND} -E copy_directory <SOURCE_DIR>/include <INSTALL_DIR>/include
      INSTALL_DIR ${THIRDPARTY_DIR}/nvidiacg
    )
  endif()
endif()

if(MSVC)
  if(CMAKE_SIZEOF_VOID_P EQUAL 8)
    set(ssl_config VC-WIN64A)
  else()
    set(ssl_config VC-WIN32)
  endif()

  ExternalProject_Add(
    openssl
    URL https://www.openssl.org/source/openssl-1.0.2k.tar.gz
    URL_HASH SHA256=6b3977c61f2aedf0f96367dcfb5c6e578cf37e7b8d913b4ecb6643c3cb88d8c0

    CONFIGURE_COMMAND perl Configure ${ssl_config} no-asm no-shared --prefix=<INSTALL_DIR>
              COMMAND ${CMAKE_CURRENT_LIST_DIR}/openssl-ms.bat ${ssl_config}
    BUILD_COMMAND nmake -f ms\\nt.mak
    BUILD_IN_SOURCE 1

    INSTALL_COMMAND nmake -f ms\\nt.mak install
    INSTALL_DIR ${THIRDPARTY_DIR}/openssl
  )
elseif(NOT APPLE)
  ExternalProject_Add(
    openssl
    URL https://www.openssl.org/source/openssl-1.0.2j.tar.gz
    URL_HASH SHA256=e7aff292be21c259c6af26469c7a9b3ba26e9abaaffd325e3dccc9785256c431

    CONFIGURE_COMMAND ./config no-asm no-shared --prefix=<INSTALL_DIR> ${CMAKE_C_FLAGS}
    BUILD_COMMAND ${MAKE}
    BUILD_IN_SOURCE 1

    INSTALL_DIR ${THIRDPARTY_DIR}/openssl
  )
endif()

if(NOT APPLE)
  # Delete the bin and ssl directories in the install folder.
  ExternalProject_Add_Step(openssl remove_extras
    COMMAND ${CMAKE_COMMAND} -E remove_directory "<INSTALL_DIR>/bin"
    COMMAND ${CMAKE_COMMAND} -E remove_directory "<INSTALL_DIR>/ssl"
    DEPENDEES install
  )
endif()

ExternalProject_Add(
  openexr
  DEPENDS zlib
  URL https://github.com/openexr/openexr/archive/v2.2.0.tar.gz
  URL_HASH SHA256=8c219754af33fee199bdd72a0441f73dd4b3ce5363ac3c5cd7b2c6306f5442a6

  PATCH_COMMAND ${CMAKE_COMMAND} -E copy_if_different ${CMAKE_CURRENT_LIST_DIR}/openexr.cmake <SOURCE_DIR>/CMakeLists.txt

  CMAKE_ARGS ${COMMON_CMAKE_ARGS}
    -DCMAKE_PREFIX_PATH=${THIRDPARTY_DIR}/zlib
    -DNAMESPACE_VERSIONING=OFF
  INSTALL_DIR ${THIRDPARTY_DIR}/openexr
)

# Remove the extra bin and share directories it created.
ExternalProject_Add_Step(openexr remove_extras
  COMMAND ${CMAKE_COMMAND} -E remove_directory "<INSTALL_DIR>/bin"
  COMMAND ${CMAKE_COMMAND} -E remove_directory "<INSTALL_DIR>/share"
  DEPENDEES install
)

if(NOT WIN32)
  EXTERNALPROJECT_ADD(
    ffmpeg
    DEPENDS ogg vorbis freetype zlib
    URL https://ffmpeg.org/releases/ffmpeg-3.2.2.tar.gz
    URL_HASH SHA256=228d3acf6be3180a4f38b94f582e550e72f1575d94725bfa82eaaf30a904eba1

    CONFIGURE_COMMAND ./configure --prefix=<INSTALL_DIR> --datadir=${CMAKE_BINARY_DIR}/etc --disable-shared --enable-static --enable-pic --disable-doc --disable-debug --disable-programs --disable-outdevs --enable-runtime-cpudetect
    BUILD_COMMAND ${MAKE}
    BUILD_IN_SOURCE 1

    INSTALL_DIR ${THIRDPARTY_DIR}/ffmpeg
  )
endif()
