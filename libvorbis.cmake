# CMakeLists.txt to build static libvorbis for Polycode, adapted for Panda3D

CMAKE_MINIMUM_REQUIRED(VERSION 2.6)

PROJECT(libvorbis C)

IF(NOT CMAKE_BUILD_TYPE)
    #SET(CMAKE_BUILD_TYPE "Debug")
    SET(CMAKE_BUILD_TYPE "Release")
    MESSAGE("No CMAKE_BUILD_TYPE specified, defaulting to ${CMAKE_BUILD_TYPE}")
ENDIF(NOT CMAKE_BUILD_TYPE)

FIND_PATH(OGG_INCLUDE_DIR NAMES ogg/ogg.h)

IF(MSVC)
    SET(CMAKE_DEBUG_POSTFIX "d")
    FIND_LIBRARY(OGG_RELEASE_LIBRARY NAMES libogg_static)
    FIND_LIBRARY(OGG_DEBUG_LIBRARY NAMES libogg_staticd)
ELSE()
    FIND_LIBRARY(OGG_RELEASE_LIBRARY NAMES ogg)
    FIND_LIBRARY(OGG_DEBUG_LIBRARY NAMES ogg)
ENDIF()

IF(OGG_DEBUG_LIBRARY)
    LIST(APPEND OGG_LIBRARY debug ${OGG_DEBUG_LIBRARY})
ENDIF(OGG_DEBUG_LIBRARY)
IF(OGG_RELEASE_LIBRARY)
    LIST(APPEND OGG_LIBRARY optimized ${OGG_RELEASE_LIBRARY})
ENDIF(OGG_RELEASE_LIBRARY)

MESSAGE("CMAKE_PREFIX_PATH=${CMAKE_PREFIX_PATH}")
MESSAGE("OGG_LIBRARY=${OGG_LIBRARY}")

SET(libvorbis_SRCS
    lib/analysis.c
    lib/bitrate.c
    lib/block.c
    lib/codebook.c
    lib/envelope.c
    lib/floor0.c
    lib/floor1.c
    lib/info.c
    lib/lookup.c
    lib/lpc.c
    lib/lsp.c
    lib/mapping0.c
    lib/mdct.c
    lib/psy.c
    lib/registry.c
    lib/res0.c
    lib/sharedbook.c
    lib/smallft.c
    lib/synthesis.c
    lib/vorbisenc.c
    lib/window.c
)

SET(libvorbis_HDRS
    lib/backends.h
    lib/bitrate.h
    lib/codebook.h
    lib/codec_internal.h
    lib/envelope.h
    lib/modes/floor_all.h
    lib/books/floor/floor_books.h
    lib/highlevel.h
    lib/lookup.h
    lib/lookup_data.h
    lib/lpc.h
    lib/lsp.h
    lib/masking.h
    lib/mdct.h
    lib/misc.h
    lib/os.h
    lib/psy.h
    lib/modes/psych_11.h
    lib/modes/psych_16.h
    lib/modes/psych_44.h
    lib/modes/psych_8.h
    lib/registry.h
    lib/books/coupled/res_books_stereo.h
    lib/books/uncoupled/res_books_uncoupled.h
    lib/modes/residue_16.h
    lib/modes/residue_44.h
    lib/modes/residue_44u.h
    lib/modes/residue_8.h
    lib/scales.h
    lib/modes/setup_11.h
    lib/modes/setup_16.h
    lib/modes/setup_22.h
    lib/modes/setup_32.h
    lib/modes/setup_44.h
    lib/modes/setup_44u.h
    lib/modes/setup_8.h
    lib/modes/setup_X.h
    lib/smallft.h
    lib/window.h
)

SET(vorbis_public_HDRS
    include/vorbis/codec.h
    include/vorbis/vorbisenc.h
    include/vorbis/vorbisfile.h)

INCLUDE_DIRECTORIES(${OGG_INCLUDE_DIR} include lib)

IF(MSVC)
    ADD_DEFINITIONS(/D_UNICODE /DUNICODE)
    LIST(APPEND libvorbis_SRCS win32/vorbis.def)
ENDIF(MSVC)

IF(MSVC)
    ADD_LIBRARY(libvorbis_static STATIC ${libvorbis_SRCS} ${libvorbis_HDRS} ${vorbis_public_HDRS})
    ADD_LIBRARY(libvorbisfile_static STATIC lib/vorbisfile.c include/vorbis/vorbisfile.h)

    INSTALL(TARGETS vorbis vorbisfile DESTINATION lib)
ELSE()
    ADD_LIBRARY(vorbis STATIC ${libvorbis_SRCS} ${libvorbis_HDRS} ${vorbis_public_HDRS})
    ADD_LIBRARY(vorbisfile STATIC lib/vorbisfile.c include/vorbis/vorbisfile.h)

    INSTALL(TARGETS vorbis vorbisfile DESTINATION lib)
ENDIF()

INSTALL(FILES ${vorbis_public_HDRS} DESTINATION include/vorbis)
