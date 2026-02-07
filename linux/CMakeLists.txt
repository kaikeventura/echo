cmake_minimum_required(VERSION 3.10)
project(runner LANGUAGES CXX)

# The name of the executable.
set(BINARY_NAME "echo")

# Add the Flutter sub-project.
# This must be done before the application-specific sources.
add_subdirectory(flutter)

# Add the application-specific sources.
add_subdirectory(runner)
