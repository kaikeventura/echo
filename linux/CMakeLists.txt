# The version of CMake to use.
cmake_minimum_required(VERSION 3.10)

# The project name.
project(echo LANGUAGES CXX)

# The name of the executable to be created.
set(BINARY_NAME "echo")

# The version of the project.
# This value is used when generating build files (e.g., for packaging).
# It can be overridden on the command line with -DVERSION=...
if(NOT DEFINED VERSION)
  set(VERSION "1.0.0")
endif()

# === Flutter Definition ===
# Add the Flutter library and tool.
# This must be done before the application-specific sources.
add_subdirectory(flutter)

# === Application-specific Sources ===
# Add the application-specific sources.
add_subdirectory(runner)
