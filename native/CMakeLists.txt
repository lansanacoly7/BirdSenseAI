cmake_minimum_required(VERSION 3.14)
project(birdsense_vision VERSION 1.0.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Find ONNX Runtime package or include paths
find_package(ONNXRuntime QUIET)

add_library(birdsense_vision SHARED
    birdsense_onnx.cpp
    birdsense_onnx.h
)

target_include_directories(birdsense_vision PUBLIC 
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${ONNXRUNTIME_INCLUDE_DIRS}
)

if(TARGET ONNXRuntime::ONNXRuntime)
    target_link_libraries(birdsense_vision PRIVATE ONNXRuntime::ONNXRuntime)
endif()

if(WIN32)
    set_target_properties(birdsense_vision PROPERTIES WINDOWS_EXPORT_ALL_SYMBOLS ON)
endif()
