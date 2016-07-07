include_directories(
  ${PROJECT_SOURCE_DIR}/runtime/src
  ${PROJECT_SOURCE_DIR}/runtime/src/atn
  ${PROJECT_SOURCE_DIR}/runtime/src/dfa
  ${PROJECT_SOURCE_DIR}/runtime/src/misc
  ${PROJECT_SOURCE_DIR}/runtime/src/support
  ${PROJECT_SOURCE_DIR}/runtime/src/tree
  ${PROJECT_SOURCE_DIR}/runtime/src/tree/pattern
  ${PROJECT_SOURCE_DIR}/runtime/src/tree/xpath
)


file(GLOB libantlrcpp_SRC
  "${PROJECT_SOURCE_DIR}/runtime/src/*.cpp"
  "${PROJECT_SOURCE_DIR}/runtime/src/atn/*.cpp"
  "${PROJECT_SOURCE_DIR}/runtime/src/dfa/*.cpp"
  "${PROJECT_SOURCE_DIR}/runtime/src/misc/*.cpp"
  "${PROJECT_SOURCE_DIR}/runtime/src/support/*.cpp"
  "${PROJECT_SOURCE_DIR}/runtime/src/tree/*.cpp"
  "${PROJECT_SOURCE_DIR}/runtime/src/tree/pattern/*.cpp"
  "${PROJECT_SOURCE_DIR}/runtime/src/tree/xpath/*.cpp"
)

add_library(antlr4_shared SHARED ${libantlrcpp_SRC})
add_library(antlr4_static STATIC ${libantlrcpp_SRC})


if(CMAKE_SYSTEM_NAME MATCHES "Linux")
  target_link_libraries(antlr4_shared ${UUID_LIBRARIES})
  target_link_libraries(antlr4_static ${UUID_LIBRARIES})
elseif(APPLE)
  target_link_libraries(antlr4_shared ${COREFOUNDATION_LIBRARY})
  target_link_libraries(antlr4_static ${COREFOUNDATION_LIBRARY})
endif()

set(disabled_compile_warnings "-Wno-overloaded-virtual")
if ("${CMAKE_CXX_COMPILER_ID}" MATCHES "Clang")
  set(disabled_compile_warnings "${disabled_compile_warnings} -Wno-dollar-in-identifier-extension -Wno-four-char-constants")
elseif("${CMAKE_CXX_COMPILER_ID}" MATCHES "GNU")
  set(disabled_compile_warnings "${disabled_compile_warnings} -Wno-multichar")
endif()


set_target_properties(antlr4_shared
                      PROPERTIES VERSION   ${ANTLR_VERSION}
                                 SOVERSION ${ANTLR_VERSION}
                                 OUTPUT_NAME libantlr4-runtime
                                 COMPILE_FLAGS "${disabled_compile_warnings}")

set_target_properties(antlr4_static
                      PROPERTIES VERSION   ${ANTLR_VERSION}
                                 SOVERSION ${ANTLR_VERSION}
                                 OUTPUT_NAME libantlr4-runtime
                                 COMPILE_FLAGS "${disabled_compile_warnings}")

install(TARGETS antlr4_shared
        EXPORT antlr4_shared_targets
        DESTINATION lib
        INCLUDES DESINATION include/)
install(TARGETS antlr4_static
        EXPORT antlr4_static_targets
        ARCHIVE
        DESTINATION lib
        INCLUDES DESINATION include/)

install(DIRECTORY "${PROJECT_SOURCE_DIR}/runtime/src/"
        DESTINATION "include"
        COMPONENT dev
        FILES_MATCHING PATTERN "*.h"
        )

install(FILES "${PROJECT_SOURCE_DIR}/runtime/Antlr4Helpers.cmake"
        DESTINATION "lib/cmake/Antlr4"
        )

###
include(GenerateExportHeader)
include(CMakePackageConfigHelpers)

generate_export_header(antlr4_shared)
generate_export_header(antlr4_static)

write_basic_package_version_file(
        "${CMAKE_CURRENT_BINARY_DIR}/Antlr4/Antlr4ConfigVersion.cmake"
        VERSION ${ANTLR_VERSION}
        COMPATIBILITY AnyNewerVersion
)

#export(EXPORT antlr4_shared_targets
#        FILE "${CMAKE_CURRENT_BINARY_DIR}/Antlr4/Antlr4TargetsSharedEXPORT.cmake"
#        NAMESPACE antlr4::
#        )
#
#export(EXPORT antlr4_static_targets
#        FILE "${CMAKE_CURRENT_BINARY_DIR}/Antlr4/Antlr4TargetsStaticEXPORT.cmake"
#        NAMESPACE antlr4::
#        )

set(ConfigPackageLocation lib/cmake/Antlr4)
install(EXPORT      antlr4_shared_targets
        FILE        Antlr4TargetsShared.cmake
        NAMESPACE   Antlr4::
        DESTINATION ${ConfigPackageLocation}
        )

set(ConfigPackageLocation lib/cmake/Antlr4)
install(EXPORT      antlr4_static_targets
        FILE        Antlr4TargetsStatic.cmake
        NAMESPACE   Antlr4::
        DESTINATION ${ConfigPackageLocation}
        )

#configure_file(cmake/ClimbingStatsConfig.cmake
#        "${CMAKE_CURRENT_BINARY_DIR}/ClimbingStats/ClimbingStatsConfig.cmake"
#        COPYONLY
#        )
#install(
#        FILES
#        cmake/ClimbingStatsConfig.cmake
#        "${CMAKE_CURRENT_BINARY_DIR}/ClimbingStats/ClimbingStatsConfigVersion.cmake"
#        DESTINATION
#        ${ConfigPackageLocation}
#        COMPONENT
#        Devel
#)
