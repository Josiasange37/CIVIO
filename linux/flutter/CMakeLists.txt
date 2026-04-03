cmake_minimum_required(VERSION 3.10)

set(WRAPPER_ROOT "${CMAKE_CURRENT_SOURCE_DIR}")

# === Global include for flutter_linux headers ===
include_directories("${CMAKE_CURRENT_SOURCE_DIR}/ephemeral/flutter_linux")
add_compile_options(-I"${CMAKE_CURRENT_SOURCE_DIR}/ephemeral/flutter_linux")

# === Flutter Library ===
set(FLUTTER_LIBRARY "${CMAKE_BINARY_DIR}/flutter/libflutter_linux_gtk.so")

# Published to parent scope for install step.
set(FLUTTER_LIBRARY ${FLUTTER_LIBRARY} PARENT_SCOPE)
set(FLUTTER_ICU_DATA_FILE "${CMAKE_BINARY_DIR}/flutter/icudtl.dat" PARENT_SCOPE)
set(PROJECT_BUILD_DIR "${PROJECT_DIR}/build/" PARENT_SCOPE)

# === Sources ===
set(WRAPPER_SOURCES
  "flutter_wrapper_plugin_registrant.cc"
)

# === Headers ===
set(WRAPPER_HEADERS
  "flutter_wrapper_plugin_registrant.h"
)

list(APPEND WRAPPER_SOURCES ${WRAPPER_HEADERS})
add_library(flutter_wrapper_plugin STATIC ${WRAPPER_SOURCES})
target_link_libraries(flutter_wrapper_plugin PUBLIC flutter)
set_target_properties(flutter_wrapper_plugin PROPERTIES
  POSITION_INDEPENDENT_CODE ON)

set(FLUTTER_GENERATED_PLUGIN_DIR "${CMAKE_BINARY_DIR}/generated_plugins")

# === Plugin Registry ===
list(APPEND PLUGIN_SOURCES
  "${FLUTTER_GENERATED_PLUGIN_DIR}/generated_plugin_registrant.cc"
)

# Wrapper sources needed for plugins
target_sources(flutter_wrapper_plugin PUBLIC
  ${WRAPPER_SOURCES}
)

target_include_directories(flutter_wrapper_plugin PUBLIC
  "${FLUTTER_GENERATED_PLUGIN_DIR}"
  "${CMAKE_CURRENT_SOURCE_DIR}/ephemeral/flutter_linux"
)

# === Dependency Imports ===
include(FindPkgConfig)

# GTK
find_package(PkgConfig REQUIRED)
pkg_check_modules(GTK REQUIRED IMPORTED_TARGET gtk+-3.0)

# === Build Bundle ===
function(build_flutter_bundle target_name)
  set(BUNDLE_DIR "${CMAKE_BINARY_DIR}/bundle")
  set(DATA_DIR "${BUNDLE_DIR}/data")
  set(FLUTTER_ASSETS_DIR "${DATA_DIR}/flutter_assets")
  
  add_custom_target(${target_name} ALL
    COMMAND ${CMAKE_COMMAND} -E make_directory ${FLUTTER_ASSETS_DIR}
    COMMAND ${CMAKE_COMMAND} -E copy_directory
      "${PROJECT_DIR}/build/flutter_assets"
      ${FLUTTER_ASSETS_DIR}
    COMMENT "Building Flutter bundle"
  )
endfunction()

# === Install Bundle ===
function(install_flutter_bundle target_name)
  install(TARGETS ${target_name} RUNTIME DESTINATION "${CMAKE_INSTALL_PREFIX}/bin")
  install(DIRECTORY "${PROJECT_BUILD_DIR}/flutter_assets" DESTINATION "${CMAKE_INSTALL_PREFIX}/data")
  install(FILES "${FLUTTER_ICU_DATA_FILE}" DESTINATION "${CMAKE_INSTALL_PREFIX}/data" RENAME "icudtl.dat")
endfunction()
