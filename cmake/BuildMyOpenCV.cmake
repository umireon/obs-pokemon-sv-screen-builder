include(ExternalProject)

set(OPENCV_URL
    https://github.com/umireon/opencv/archive/refs/tags/4.7.1.tar.gz
    CACHE STRING "URL of an OpenCV tarball")

set(OPENCV_MD5
    eef7d771cdfb15913d57954c83e365a3
    CACHE STRING "MD5 Hash of an OpenCV tarball")

string(REPLACE ";" "$<SEMICOLON>" CMAKE_OSX_ARCHITECTURES_ "${CMAKE_OSX_ARCHITECTURES}")

if(MSVC)
  if(${CMAKE_GENERATOR_PLATFORM} STREQUAL x64
     AND ${MSVC_VERSION} GREATER_EQUAL 1910
     AND ${MSVC_VERSION} LESS_EQUAL 1939)
    set(OpenCV_LIB_PATH x64/vc17/staticlib)
    set(OpenCV_LIB_PATH_3RD x64/vc17/staticlib)
    set(OpenCV_LIB_SUFFIX 470)
  else()
    message(FATAL_ERROR "Unsupported MSVC!")
  endif()
else()
  set(OpenCV_LIB_PATH lib)
  set(OpenCV_LIB_PATH_3RD lib/opencv4/3rdparty)
  set(OpenCV_LIB_SUFFIX "")
  set(OpenCV_INSTALL_CCACHE ":")
  set(OpenCV_PLATFORM_CMAKE_ARGS -DOPENCV_LIB_INSTALL_PATH=lib -DOPENCV_PYTHON_SKIP_DETECTION=ON)
endif()

if(OS_MACOS)
  set(OpenCV_PLATFORM_CMAKE_ARGS ${OpenCV_PLATFORM_CMAKE_ARGS} -DCMAKE_OSX_ARCHITECTURES=x86_64$<SEMICOLON>arm64)
endif()

if(${CMAKE_BUILD_TYPE} STREQUAL Release)
  set(OpenCV_BUILD_TYPE Release)
else()
  set(OpenCV_BUILD_TYPE Debug)
endif()

ExternalProject_Add(
  OpenCV_Build
  DOWNLOAD_EXTRACT_TIMESTAMP true
  URL ${OPENCV_URL}
  URL_HASH MD5=${OPENCV_MD5}
  PATCH_COMMAND ${OpenCV_INSTALL_CCACHE}
  BUILD_COMMAND ${CMAKE_COMMAND} --build <BINARY_DIR> --config ${OpenCV_BUILD_TYPE}
  BUILD_BYPRODUCTS
    <INSTALL_DIR>/${OpenCV_LIB_PATH}/${CMAKE_STATIC_LIBRARY_PREFIX}opencv_core${OpenCV_LIB_SUFFIX}${CMAKE_STATIC_LIBRARY_SUFFIX}
    <INSTALL_DIR>/${OpenCV_LIB_PATH}/${CMAKE_STATIC_LIBRARY_PREFIX}opencv_features2d${OpenCV_LIB_SUFFIX}${CMAKE_STATIC_LIBRARY_SUFFIX}
    <INSTALL_DIR>/${OpenCV_LIB_PATH}/${CMAKE_STATIC_LIBRARY_PREFIX}opencv_imgcodecs${OpenCV_LIB_SUFFIX}${CMAKE_STATIC_LIBRARY_SUFFIX}
    <INSTALL_DIR>/${OpenCV_LIB_PATH}/${CMAKE_STATIC_LIBRARY_PREFIX}opencv_imgproc${OpenCV_LIB_SUFFIX}${CMAKE_STATIC_LIBRARY_SUFFIX}
    <INSTALL_DIR>/${OpenCV_LIB_PATH_3RD}/${CMAKE_STATIC_LIBRARY_PREFIX}libpng${CMAKE_STATIC_LIBRARY_SUFFIX}
    <INSTALL_DIR>/${OpenCV_LIB_PATH_3RD}/${CMAKE_STATIC_LIBRARY_PREFIX}zlib${CMAKE_STATIC_LIBRARY_SUFFIX}
  CMAKE_GENERATOR ${CMAKE_GENERATOR}
  INSTALL_COMMAND ${CMAKE_COMMAND} --install <BINARY_DIR> --config ${OpenCV_BUILD_TYPE}
  CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=<INSTALL_DIR>
             -DCMAKE_BUILD_TYPE=${OpenCV_BUILD_TYPE}
             -DCMAKE_GENERATOR_PLATFORM=${CMAKE_GENERATOR_PLATFORM}
             -DENABLE_CCACHE=ON
             -DOPENCV_FORCE_3RDPARTY_BUILD=ON
             -DCMAKE_OSX_DEPLOYMENT_TARGET=10.13
             -DCMAKE_OSX_ARCHITECTURES=${CMAKE_OSX_ARCHITECTURES_}
             -DBUILD_SHARED_LIBS=OFF
             -DBUILD_opencv_apps=OFF
             -DBUILD_opencv_js=OFF
             -DBUILD_ANDROID_PROJECTS=OFF
             -DBUILD_ANDROID_EXAMPLES=OFF
             -DBUILD_DOCS=OFF
             -DBUILD_EXAMPLES=OFF
             -DBUILD_PACKAGE=OFF
             -DBUILD_PERF_TESTS=OFF
             -DBUILD_TESTS=OFF
             -DBUILD_WITH_DEBUG_INFO=OFF
             -DBUILD_WITH_STATIC_CRT=OFF
             -DBUILD_WITH_DYNAMIC_IPP=OFF
             -DBUILD_FAT_JAVA_LIB=OFF
             -DBUILD_ANDROID_SERVICE=OFF
             -DBUILD_CUDA_STUBS=OFF
             -DBUILD_JAVA=OFF
             -DBUILD_OBJC=OFF
             -DBUILD_opencv_python3=OFF
             -DINSTALL_CREATE_DISTRIB=OFF
             -DINSTALL_BIN_EXAMPLES=OFF
             -DINSTALL_C_EXAMPLES=OFF
             -DINSTALL_PYTHON_EXAMPLES=OFF
             -DINSTALL_ANDROID_EXAMPLES=OFF
             -DINSTALL_TO_MANGLED_PATHS=OFF
             -DINSTALL_TESTS=OFF
             -DBUILD_opencv_calib3d=OFF
             -DBUILD_opencv_core=ON
             -DBUILD_opencv_dnn=OFF
             -DBUILD_opencv_features2d=ON
             -DBUILD_opencv_flann=OFF
             -DBUILD_opencv_gapi=OFF
             -DBUILD_opencv_highgui=OFF
             -DBUILD_opencv_imgcodecs=ON
             -DBUILD_opencv_imgproc=ON
             -DBUILD_opencv_ml=OFF
             -DBUILD_opencv_objdetect=OFF
             -DBUILD_opencv_photo=OFF
             -DBUILD_opencv_stitching=OFF
             -DBUILD_opencv_video=OFF
             -DBUILD_opencv_videoio=OFF
             -DWITH_PNG=ON
             -DWITH_JPEG=OFF
             -DWITH_TIFF=OFF
             -DWITH_WEBP=OFF
             -DWITH_OPENJPEG=OFF
             -DWITH_JASPER=OFF
             -DWITH_OPENEXR=OFF
             -DWITH_FFMPEG=OFF
             -DWITH_GSTREAMER=OFF
             -DWITH_1394=OFF
             -DWITH_PROTOBUF=OFF
             -DBUILD_PROTOBUF=OFF
             -DWITH_CAROTENE=OFF
             -DWITH_EIGEN=OFF
             -DWITH_OPENVX=OFF
             -DWITH_CLP=OFF
             -DWITH_DIRECTX=OFF
             -DWITH_VA=OFF
             -DWITH_LAPACK=OFF
             -DWITH_QUIRC=OFF
             -DWITH_ADE=OFF
             -DWITH_ITT=OFF
             -DWITH_OPENCL=OFF
             -DWITH_IPP=OFF
             ${OpenCV_PLATFORM_CMAKE_ARGS})

ExternalProject_Get_Property(OpenCV_Build INSTALL_DIR)
if(MSVC)
  set(OpenCV_INCLUDE_PATH ${INSTALL_DIR}/include)
else()
  set(OpenCV_INCLUDE_PATH ${INSTALL_DIR}/include/opencv4)
endif(MSVC)

add_library(OpenCV::Features2d STATIC IMPORTED)
set_target_properties(
  OpenCV::Features2d
  PROPERTIES
    IMPORTED_LOCATION
    ${INSTALL_DIR}/${OpenCV_LIB_PATH}/${CMAKE_STATIC_LIBRARY_PREFIX}opencv_features2d${OpenCV_LIB_SUFFIX}${CMAKE_STATIC_LIBRARY_SUFFIX}
)

add_library(OpenCV::Imgcodecs STATIC IMPORTED)
set_target_properties(
  OpenCV::Imgcodecs
  PROPERTIES
    IMPORTED_LOCATION
    ${INSTALL_DIR}/${OpenCV_LIB_PATH}/${CMAKE_STATIC_LIBRARY_PREFIX}opencv_imgcodecs${OpenCV_LIB_SUFFIX}${CMAKE_STATIC_LIBRARY_SUFFIX}
)

add_library(OpenCV::Imgproc STATIC IMPORTED)
set_target_properties(
  OpenCV::Imgproc
  PROPERTIES
    IMPORTED_LOCATION
    ${INSTALL_DIR}/${OpenCV_LIB_PATH}/${CMAKE_STATIC_LIBRARY_PREFIX}opencv_imgproc${OpenCV_LIB_SUFFIX}${CMAKE_STATIC_LIBRARY_SUFFIX}
)

add_library(OpenCV::Core STATIC IMPORTED)
set_target_properties(
  OpenCV::Core
  PROPERTIES
    IMPORTED_LOCATION
    ${INSTALL_DIR}/${OpenCV_LIB_PATH}/${CMAKE_STATIC_LIBRARY_PREFIX}opencv_core${OpenCV_LIB_SUFFIX}${CMAKE_STATIC_LIBRARY_SUFFIX}
)

add_library(OpenCV::Libpng STATIC IMPORTED)
set_target_properties(
  OpenCV::Libpng
  PROPERTIES IMPORTED_LOCATION
             ${INSTALL_DIR}/${OpenCV_LIB_PATH_3RD}/${CMAKE_STATIC_LIBRARY_PREFIX}libpng${CMAKE_STATIC_LIBRARY_SUFFIX})

add_library(OpenCV::Zlib STATIC IMPORTED)
set_target_properties(
  OpenCV::Zlib
  PROPERTIES IMPORTED_LOCATION
             ${INSTALL_DIR}/${OpenCV_LIB_PATH_3RD}/${CMAKE_STATIC_LIBRARY_PREFIX}zlib${CMAKE_STATIC_LIBRARY_SUFFIX})

add_library(OpenCV INTERFACE)
add_dependencies(OpenCV OpenCV_Build)
target_link_libraries(OpenCV INTERFACE OpenCV::Features2d OpenCV::Imgcodecs OpenCV::Imgproc OpenCV::Core OpenCV::Libpng
                                       OpenCV::Zlib)
set_target_properties(OpenCV::Core OpenCV::Imgproc PROPERTIES INTERFACE_INCLUDE_DIRECTORIES ${OpenCV_INCLUDE_PATH})
if(APPLE)
  target_link_libraries(OpenCV INTERFACE "-framework Accelerate")
endif(APPLE)
