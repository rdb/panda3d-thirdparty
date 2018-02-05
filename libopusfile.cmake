# adapted from https://github.com/eppixx/opusfile-cmake

cmake_minimum_required(VERSION 2.8)
project(opusfile)

find_path(OGG_INCLUDE_DIRS NAMES ogg/ogg.h HINTS ${OGG_ROOT}/include PATH_SUFFIXES ogg)
find_library(OGG_LIBRARIES NAMES ogg HINTS ${OGG_ROOT}/lib ${OGG_ROOT}/lib64)
find_path(OPUS_INCLUDE_DIRS NAMES opus.h HINTS ${OPUS_ROOT}/include PATH_SUFFIXES opus)
find_library(OPUS_LIBRARIES NAMES opus HINTS ${OPUS_ROOT}/lib ${OPUS_ROOT}/lib64)

set(OPUSFILE_LIBS
  ${OPUSFILE_LIBS}
  ${OGG_LIBRARIES}
  ${OPUS_LIBRARIES}
  m
)

set(OPUSFILE_INCLUDE_DIRS
  include
)

set(OPUSFILE_HDR
  include/opusfile.h
)

set(OPUSFILE_SRC
  src/http.c
  src/info.c
  src/internal.c
  src/internal.h
  src/opusfile.c
  src/stream.c
  src/wincerts.c
  src/winerrno.h
)

set(OPUSFILE_CODE
  ${OPUSFILE_SRC}
  ${OPUSFILE_HDR}
)

# These options affect performance
# HAVE_LRINTF: Use C99 intrinsics to speed up float-to-int conversion
add_definitions(-DHAVE_LRINTF)

if(MINGW)
  set(CMAKE_C_FLAGS
  "${CMAKE_C_FLAGS} -U__STRICT_ANSI__"
  )
endif(MINGW)

add_library(opusfile STATIC ${OPUSFILE_CODE})
target_link_libraries(opusfile ${OPUSFILE_LIBS})

target_compile_options(opusfile PRIVATE $<$<OR:$<C_COMPILER_ID:Clang>,$<C_COMPILER_ID:GNU>>:
  -std=c89
  -pedantic
  -Wall
  -Wextra
  -Wno-parentheses
  -Wno-long-long
>)
target_include_directories(opusfile PRIVATE
  ${CMAKE_CURRENT_SOURCE_DIR}/include
  ${CMAKE_CURRENT_SOURCE_DIR}/src
)
target_include_directories(opusfile PUBLIC
  ${OPUSFILE_INCLUDE_DIRS}
  ${OGG_INCLUDE_DIRS}
  ${OPUS_INCLUDE_DIRS}
)

install(TARGETS opusfile DESTINATION lib)
install(FILES ${OPUSFILE_HDR} DESTINATION include/opus)

# Helper function to configure pkg-config files
function(configure_pkg_config_file pkg_config_file_in)
    set(prefix ${CMAKE_INSTALL_PREFIX})
    set(exec_prefix ${CMAKE_INSTALL_FULL_BINDIR})
    set(libdir ${CMAKE_INSTALL_FULL_LIBDIR})
    set(includedir ${CMAKE_INSTALL_FULL_INCLUDEDIR})
    set(PACKAGE_VERSION 0.11)
    string(REPLACE ".in" "" pkg_config_file ${pkg_config_file_in})
    configure_file(${pkg_config_file_in} ${pkg_config_file} @ONLY)
endfunction()

configure_pkg_config_file(opusfile.pc.in)
set(VERSION 1.3)
configure_pkg_config_file(${OPUS_ROOT}/lib/pkgconfig/opus.pc.in)

install(
    FILES
    ${CMAKE_CURRENT_BINARY_DIR}/opusfile.pc
    DESTINATION
    ${CMAKE_INSTALL_LIBDIR}/pkgconfig
)
