# Made by rdb, released in the public domain.

cmake_minimum_required(VERSION 2.8)
project(artoolkit)

option(BUILD_SHARED_LIBS "Enable to build libAR as a shared library." OFF)

configure_file(include/AR/config.h.in AR/config.h)
include_directories(${CMAKE_CURRENT_BINARY_DIR})
include_directories(include)

set(AR_SOURCES
  lib/SRC/AR/arDetectMarker.c
  lib/SRC/AR/arDetectMarker2.c
  lib/SRC/AR/arGetCode.c
  lib/SRC/AR/arGetMarkerInfo.c
  lib/SRC/AR/arGetTransMat.c
  lib/SRC/AR/arGetTransMat2.c
  lib/SRC/AR/arGetTransMat3.c
  lib/SRC/AR/arGetTransMatCont.c
  lib/SRC/AR/arLabeling.c
  lib/SRC/AR/arUtil.c
  lib/SRC/AR/mAlloc.c
  lib/SRC/AR/mAllocDup.c
  lib/SRC/AR/mAllocInv.c
  lib/SRC/AR/mAllocMul.c
  lib/SRC/AR/mAllocTrans.c
  lib/SRC/AR/mAllocUnit.c
  lib/SRC/AR/mDet.c
  lib/SRC/AR/mDisp.c
  lib/SRC/AR/mDup.c
  lib/SRC/AR/mFree.c
  lib/SRC/AR/mInv.c
  lib/SRC/AR/mMul.c
  lib/SRC/AR/mPCA.c
  lib/SRC/AR/mSelfInv.c
  lib/SRC/AR/mTrans.c
  lib/SRC/AR/mUnit.c
  lib/SRC/AR/paramChangeSize.c
  lib/SRC/AR/paramDecomp.c
  lib/SRC/AR/paramDisp.c
  lib/SRC/AR/paramDistortion.c
  lib/SRC/AR/paramFile.c
  lib/SRC/AR/paramGet.c
  lib/SRC/AR/vAlloc.c
  lib/SRC/AR/vDisp.c
  lib/SRC/AR/vFree.c
  lib/SRC/AR/vHouse.c
  lib/SRC/AR/vInnerP.c
  lib/SRC/AR/vTridiag.c
)

set(ARMULTI_SOURCES
  lib/src/ARMulti/arMultiActivate.c
  lib/src/ARMulti/arMultiGetTransMat.c
  lib/src/ARMulti/arMultiReadConfigFile.c
)

add_library(libAR ${AR_SOURCES})
add_library(libARMulti ${ARMULTI_SOURCES})

install(TARGETS libAR libARMulti DESTINATION lib)

install(FILES
  ${CMAKE_CURRENT_BINARY_DIR}/AR/config.h
  include/AR/ar.h
  include/AR/arMulti.h
  include/AR/arvrml.h
  include/AR/gsub.h
  include/AR/gsub_lite.h
  include/AR/gsubUtil.h
  include/AR/matrix.h
  include/AR/param.h
  include/AR/video.h
  DESTINATION include/AR
)

install(FILES
  ${CMAKE_CURRENT_BINARY_DIR}/AR/config.h
  include/AR/ar.h
  include/AR/arMulti.h
  include/AR/arvrml.h
  include/AR/gsub.h
  include/AR/gsub_lite.h
  include/AR/gsubUtil.h
  include/AR/matrix.h
  include/AR/param.h
  include/AR/video.h
  DESTINATION include/AR
)

install(FILES
  include/AR/sys/videoGStreamer.h
  include/AR/sys/videoLinux1394Cam.h
  include/AR/sys/videoLinuxDV.h
  include/AR/sys/videoLinuxV4L.h
  include/AR/sys/videoMacOSX.h
  include/AR/sys/videoSGI.h
  include/AR/sys/videoWin32DirectShow.h
  DESTINATION include/AR/sys
)
