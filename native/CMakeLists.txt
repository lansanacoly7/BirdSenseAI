cmake_minimum_required(VERSION 3.10)
project(birdsense_vision VERSION 1.0.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

add_library(birdsense_vision SHARED
    birdsense_onnx.cpp
    birdsense_onnx.h
)

target_include_directories(birdsense_vision PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})

if(WIN32)
    set_target_properties(birdsense_vision PROPERTIES WINDOWS_EXPORT_ALL_SYMBOLS ON)
endif()
