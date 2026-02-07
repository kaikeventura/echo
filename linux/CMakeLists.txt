cmake_minimum_required(VERSION 3.10)
project(echo LANGUAGES CXX)

# Set the name of the executable.
set(BINARY_NAME "echo")

# Set the project version.
if(NOT DEFINED VERSION)
  set(VERSION "1.0.0")
endif()

# Add the Flutter sub-project. This must be done before the runner.
add_subdirectory(flutter)

# Add the application-specific sources.
add_subdirectory(runner)

# === Installation ===
# By default, "make install" will install everything required to run the
# application.
install(
  DIRECTORY "build/linux/x64/release/bundle"
  DESTINATION "."
  COMPONENT "ReleaseBundle"
)
