# Many of this is based on the scripts in the Polycode project.  Many thanks
# to the respective authors for going through the work of figuring this out!

cmake_minimum_required(VERSION 2.8)

include(ExternalProject)

if(${CMAKE_GENERATOR} MATCHES "^Visual Studio 14 2015")
set(THIRDPARTY_DIR ${CMAKE_SOURCE_DIR}/win-libs-vc14)
elseif(${CMAKE_GENERATOR} MATCHES "^Visual Studio 12 2013")
set(THIRDPARTY_DIR ${CMAKE_SOURCE_DIR}/win-libs-vc12)
elseif(${CMAKE_GENERATOR} MATCHES "^Visual Studio 11 2012")
set(THIRDPARTY_DIR ${CMAKE_SOURCE_DIR}/win-libs-vc11)
elseif(${CMAKE_GENERATOR} MATCHES "^Visual Studio 10 2010")
set(THIRDPARTY_DIR ${CMAKE_SOURCE_DIR}/win-libs-vc10)
elseif(${CMAKE_GENERATOR} MATCHES "^Visual Studio 9 2008")
set(THIRDPARTY_DIR ${CMAKE_SOURCE_DIR}/win-libs-vc9)
elseif(${CMAKE_GENERATOR} MATCHES "^Visual Studio 8 2005")
set(THIRDPARTY_DIR ${CMAKE_SOURCE_DIR}/win-libs-vc8)
endif()

if(${CMAKE_GENERATOR} MATCHES "Win64$")
set(THIRDPARTY_DIR "${THIRDPARTY_DIR}-x64")
endif()

message("thirdparty packages will be installed to ${THIRDPARTY_DIR}")

set(COMMON_CMAKE_ARGS
  -DCMAKE_CXX_FLAGS=${CMAKE_CXX_FLAGS}
  -DCMAKE_INSTALL_PREFIX:PATH=<INSTALL_DIR>
  -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
  -DCMAKE_C_COMPILER=${CMAKE_C_COMPILER}
  -DCMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER}
  -DCMAKE_LINKER=${CMAKE_LINKER}
  -DCMAKE_TOOLCHAIN_FILE=${CMAKE_TOOLCHAIN_FILE}
  -DCMAKE_OSX_ARCHITECTURES=${CMAKE_OSX_ARCHITECTURES}
  -DBUILD_SHARED_LIBS=FALSE
  -DSKIP_INSTALL_FILES=1
)

ExternalProject_Add(
  zlib
  #GIT_REPOSITORY https://github.com/madler/zlib.git
  URL http://zlib.net/zlib-1.2.8.tar.gz
  URL_HASH SHA256=36658cb768a54c1d4dec43c3116c27ed893e88b02ecfcb44f2166f9c0b7f2a0d

  CMAKE_ARGS ${COMMON_CMAKE_ARGS}
  INSTALL_DIR ${THIRDPARTY_DIR}/zlib
)

ExternalProject_Add(
  png
  DEPENDS zlib
  #GIT_REPOSITORY https://github.com/glennrp/libpng.git
  URL http://prdownloads.sourceforge.net/libpng/libpng-1.6.21.tar.gz
  URL_HASH SHA256=b36a3c124622c8e1647f360424371394284f4c6c4b384593e478666c59ff42d3

  CMAKE_ARGS ${COMMON_CMAKE_ARGS}
    -DCMAKE_PREFIX_PATH=${THIRDPARTY_DIR}/zlib
    -DPNG_SHARED=OFF
    -DPNG_STATIC=ON
    -DPNG_TESTS=OFF
    -DPNG_DEBUG=OFF
  INSTALL_DIR ${THIRDPARTY_DIR}/png
)

ExternalProject_Add(
  assimp
  DEPENDS zlib
  GIT_REPOSITORY https://github.com/assimp/assimp.git

  CMAKE_ARGS ${COMMON_CMAKE_ARGS}
    -DCMAKE_PREFIX_PATH=${THIRDPARTY_DIR}/zlib
    -DASSIMP_BUILD_TESTS=OFF
    -DASSIMP_BUILD_ASSIMP_TOOLS=OFF
    -DLIBRARY_SUFFIX=
  INSTALL_DIR ${THIRDPARTY_DIR}/assimp
)

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
  URL http://download.savannah.gnu.org/releases/freetype/freetype-2.6.3.tar.gz
  URL_HASH SHA256=7942096c40ee6fea882bd4207667ad3f24bff568b96b10fd3885e11a7baad9a3

  CMAKE_ARGS ${COMMON_CMAKE_ARGS}
    -DCMAKE_PREFIX_PATH=${THIRDPARTY_DIR}/zlib;${THIRDPARTY_DIR}/png
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
  URL http://openal-soft.org/openal-releases/openal-soft-1.17.2.tar.bz2
  URL_HASH SHA256=a341f8542f1f0b8c65241a17da13d073f18ec06658e1a1606a8ecc8bbc2b3314

  CMAKE_ARGS ${COMMON_CMAKE_ARGS}
    -DALSOFT_TESTS=OFF
    -DALSOFT_UTILS=OFF
  INSTALL_DIR ${THIRDPARTY_DIR}/openal
)

ExternalProject_Add(
  jpeg
  URL https://github.com/libjpeg-turbo/libjpeg-turbo/archive/1.4.90.tar.gz
  URL_HASH SHA256=ba731ccc34839af7ee985c77e7734c56c72ef5f148d1abc236b9185c166f129c

  CMAKE_ARGS ${COMMON_CMAKE_ARGS}
    -DENABLE_SHARED=ON # otherwise it bugs
    -DENABLE_STATIC=ON
    -DWITH_SIMD=OFF
    -DWITH_TURBOJPEG=OFF
  INSTALL_DIR ${THIRDPARTY_DIR}/jpeg
)
