cmake_minimum_required(VERSION 3.5)
include(ExternalProject)
enable_language(Fortran)
set(CMAKE_CXX_STANDARD 14)

set(PROJECT_ROOT "${CMAKE_CURRENT_LIST_DIR}")

if(APPLE)
   set(CMAKE_CXX_FLAGS "${CMAKE_C_FLAGS} -framework Accelerate")
endif()

message(${CMAKE_HOST_SYSTEM_NAME})
message(${CMAKE_SOURCE_DIR})
message("${cmake_current_source_dir}")

find_package(BLAS)
if(BLAS_FOUND)
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -I${BLAS_INCLUDE_DIR} -DEIGEN_USE_BLAS")
endif()

set(third_PARTY_DIR "${PROJECT_ROOT}/third_party")
set(EIGEN3_INCLUDE_DIRS "${third_PARTY_DIR}/eigen")
set(SPECTRA_INCLUDE_DIRS "${third_PARTY_DIR}/spectra/include")

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -DEIGEN_FAST_MATH=1 -DEIGEN_NO_DEBUG -DTHREAD_SAFE")

project(sample CXX )
add_executable(main ${PROJECT_ROOT}/src/main.cpp)
target_include_directories(main
  PUBLIC
  ${EIGEN3_INCLUDE_DIRS}
  ${SPECTRA_INCLUDE_DIRS}
  )
target_link_libraries(main m blas ${BLAS_LIBRARIES})
message("${CMAKE_CXX_FLAGS}")
