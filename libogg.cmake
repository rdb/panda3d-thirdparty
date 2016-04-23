# CMakeLists.txt to build static libogg for Polycode, adapted for Panda3D

CMAKE_MINIMUM_REQUIRED(VERSION 2.6)

PROJECT(libogg C)

IF(NOT CMAKE_BUILD_TYPE)
    #SET(CMAKE_BUILD_TYPE "Debug")
    SET(CMAKE_BUILD_TYPE "Release")
    MESSAGE("No CMAKE_BUILD_TYPE specified, defaulting to ${CMAKE_BUILD_TYPE}")
ENDIF(NOT CMAKE_BUILD_TYPE)

SET(libogg_SRCS src/bitwise.c src/framing.c)
SET(libogg_HDRS include/ogg/ogg.h include/ogg/os_types.h)

INCLUDE_DIRECTORIES(include)

IF(MSVC)
    SET(CMAKE_DEBUG_POSTFIX "d")
    ADD_DEFINITIONS(/D_UNICODE /DUNICODE)
    LIST(APPEND libogg_SRCS win32/ogg.def)
ENDIF(MSVC)

IF("${CMAKE_SYSTEM_NAME}" STREQUAL "Linux")
    # libogg expects configure to be called on linux to
    # generate config_types.h
    LIST(APPEND libogg_HDRS include/ogg/config_types.h)

    add_custom_command(OUTPUT include/ogg/config_types.h
                        COMMAND ./configure
                        DEPENDS include/ogg/ogg.h # Hopefully if the libogg version changes, so does this file
                                                  # so configure_types.h will be regenerated.
                        WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
                       )
ENDIF()

IF(MSVC)
    ADD_LIBRARY(libogg_static STATIC ${libogg_SRCS} ${libogg_HDRS})
    INSTALL(TARGETS libogg_static DESTINATION lib)
ELSE()
    ADD_LIBRARY(ogg STATIC ${libogg_SRCS} ${libogg_HDRS})
    INSTALL(TARGETS ogg DESTINATION lib)
ENDIF()

INSTALL(FILES ${libogg_HDRS} DESTINATION include/ogg)
