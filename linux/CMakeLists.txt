cmake_minimum_required(VERSION 3.10)
project(echo LANGUAGES CXX)

set(BINARY_NAME "echo")

# This value is used when generating build files (e.g., for packaging).
# It can be overridden on the command line with -DVERSION=...
if(NOT DEFINED VERSION)
  set(VERSION "1.0.0")
endif()

# Top-level commands.
#
# Includes the Flutter library and tool.
add_subdirectory(flutter)
# Includes the application-specific sources.
add_subdirectory(runner)

# === Installation ===
# By default, "make install" will install everything required to run the
# application.
#
# The release bundle is a self-contained directory that can be copied to another
# machine.
install(
  DIRECTORY "build/linux/x64/release/bundle"
  DESTINATION "."
  COMPONENT "ReleaseBundle"
)
