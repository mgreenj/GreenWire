cmake_minimum_required(VERSION 3.16)
project(GreenWire C)

# Set default build type to Release if not specified
if(NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE Release)
endif()

# Define include paths
include_directories(
  ${CMAKE_SOURCE_DIR}/greenwire/include
)

# Use pkg-config for dependencies if possible
find_package(PkgConfig REQUIRED)
pkg_check_modules(DPDK REQUIRED libdpdk)
pkg_check_modules(LIBBPF REQUIRED libbpf)

# Automatically pull all .c files from greenwire/
file(GLOB_RECURSE SOURCES CONFIGURE_DEPENDS greenwire/*.c)

# Create executable
add_executable(greenwire ${SOURCES})

# Apply include directories and link libraries
target_include_directories(greenwire PRIVATE 
  ${DPDK_INCLUDE_DIRS}
  ${LIBBPF_INCLUDE_DIRS}
)

target_link_libraries(greenwire PRIVATE 
  ${DPDK_LIBRARIES}
  ${LIBBPF_LIBRARIES}
)

# Optional: Print diagnostics
message(STATUS "DPDK include dirs: ${DPDK_INCLUDE_DIRS}")
message(STATUS "LIBBPF include dirs: ${LIBBPF_INCLUDE_DIRS}")
