cmake_minimum_required(VERSION 3.13)
project(runner LANGUAGES CXX)

# Define the application target.
add_executable(${BINARY_NAME}
  "main.cc"
  "my_application.cc"
  "${FLUTTER_MANAGED_DIR}/generated_plugin_registrant.cc"
)

# Apply the standard set of build settings.
apply_standard_settings(${BINARY_NAME})

# Add preprocessor definitions for the application ID.
add_definitions(-DAPPLICATION_ID="${APPLICATION_ID}")

# Add dependency libraries.
target_link_libraries(${BINARY_NAME} PRIVATE flutter)
target_link_libraries(${BINARY_NAME} PRIVATE PkgConfig::GTK)

target_include_directories(${BINARY_NAME} PRIVATE "${CMAKE_SOURCE_DIR}")

# === Icon ===
# Define the path to your icon
set(ICON_SOURCE "${CMAKE_SOURCE_DIR}/../../assets/images/echo_logo.png")

# Create a resource file from the icon
set(RESOURCES_FILE "${CMAKE_CURRENT_BINARY_DIR}/resources.gresource.xml")
file(WRITE ${RESOURCES_FILE}
"<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<gresources>
  <gresource prefix=\"/br/com/kaikeventura/echo\">
    <file>${ICON_SOURCE}</file>
  </gresource>
</gresources>"
)

# Compile the resource file
add_custom_command(
  OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/resources.gresource"
  COMMAND glib-compile-resources --target=${CMAKE_CURRENT_BINARY_DIR}/resources.gresource --sourcedir=${CMAKE_CURRENT_BINARY_DIR} ${RESOURCES_FILE}
  DEPENDS ${RESOURCES_FILE} ${ICON_SOURCE}
)

# Add the compiled resources to the executable
add_custom_target(resources ALL DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/resources.gresource")
target_sources(${BINARY_NAME} PRIVATE "${CMAKE_CURRENT_BINARY_DIR}/resources.gresource")
