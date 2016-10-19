
cmake_minimum_required(VERSION 3.1)
set(CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake)

project(huh)

set(EXT_DIR ${CMAKE_CURRENT_SOURCE_DIR}/ext)
set(LOCAL_DIR ${CMAKE_CURRENT_SOURCE_DIR}/local)
add_subdirectory(src)
