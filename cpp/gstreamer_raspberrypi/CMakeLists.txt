cmake_minimum_required(VERSION 3.12)
project(gstreamer)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

add_executable(gstreamer main.cpp calc.h Window_control.cpp Window_control.h QtWidgetsApplication1.cpp QtWidgetsApplication1.ui SafeQueue.hpp)
include_directories(/usr/include/gstreamer-1.0/ /usr/include/glib-2.0/ /usr/lib/arm-linux-gnueabihf/glib-2.0/include/ /usr/include/arm-linux-gnueabihf/qt5/  ./)
find_package(PkgConfig)
pkg_search_module(GLIB REQUIRED glib-2.0)
pkg_check_modules(GSTREAMER REQUIRED gstreamer-1.0)
pkg_check_modules(GST_APP REQUIRED gstreamer-app-1.0)
pkg_check_modules(GST_VIDEO REQUIRED gstreamer-video-1.0)


# find OpenCV
set(OpenCV_DIR "/home/pi/opencv-3.4.0/build")
set(OpenCV_INCLUDE_DIRS "/home/pi/opencv-3.4.0/include")
set(OpenCV_LIBRARIES "/home/pi/opencv-3.4.0/build/lib")
find_package(OpenCV 3.4.0 REQUIRED)

set(THREADS_PREFER_PTHREAD_FLAG ON)
find_package(Threads REQUIRED)

find_package(Qt5 COMPONENTS Widgets REQUIRED)


target_link_libraries(${PROJECT_NAME} ${GST_APP_LIBRARIES} ${GST_VIDEO_LIBRARIES} ${OpenCV_LIBRARIES} Threads::Threads Qt5::Widgets)
