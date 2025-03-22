cmake_minimum_required(VERSION 3.28)

set(SQLITE_VERSION 3.49.1)

project(Sqlite3
    LANGUAGES C
    HOMEPAGE_URL "sqlite.org"
    VERSION ${SQLITE_VERSION}
)

set(SQLITE_RECOMMENDED_OPTIONS
    SQLITE_DQS=0
    SQLITE_DEFAULT_MEMSTATUS=0
    SQLITE_DEFAULT_WAL_SYNCHRONOUS=1
    SQLITE_LIKE_DOESNT_MATCH_BLOBS
    SQLITE_MAX_EXPR_DEPTH=0
    SQLITE_OMIT_DECLTYPE
    SQLITE_OMIT_DEPRECATED
    SQLITE_OMIT_PROGRESS_CALLBACK
    SQLITE_OMIT_SHARED_CACHE
    # SQLITE_USE_ALLOCA
    # SQLITE_OMIT_AUTOINIT
    SQLITE_STRICT_SUBTYPE=1
)

include(GNUInstallDirs)
include(CMakePackageConfigHelpers)

add_library(sqlite3_amalgamation_sources OBJECT)
add_library(Sqlite3::AmalgamationSources ALIAS sqlite3_amalgamation_sources)

set_target_properties(sqlite3_amalgamation_sources PROPERTIES
    EXPORT_NAME ${PROJECT_NAME}AmalgamationSouces
    OUTPUT_NAME ${PROJECT_NAME}AmalgamationSouces
    VERSION ${PROJECT_VERSION}
    SOVERSION ${PROJECT_VERSION_MAJOR}
)

target_sources(sqlite3_amalgamation_sources
    PUBLIC FILE_SET HEADERS
        BASE_DIRS
            "$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/sqlite3-amalgamation>"
            "$<INSTALL_INTERFACE:${CMAKE_INCLUDE_INSTALL_DIR}>"
        FILES
            sqlite3-amalgamation/sqlite3.h
    PRIVATE
        "$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/sqlite3-amalgamation/sqlite3.c>"
        "$<INSTALL_INTERFACE:${CMAKE_INCLUDE_INSTALL_DIR}/sqlite3.c>"
)

target_compile_options(sqlite3_amalgamation_sources
    PRIVATE
        "$<BUILD_INTERFACE:-w>"
)

target_compile_features(sqlite3_amalgamation_sources
    PRIVATE
        c_std_99
)

install(TARGETS sqlite3_amalgamation_sources
    EXPORT Sqlite3Targets
    FILE_SET HEADERS
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    INCLUDES DESTINATION ${CMAKE_INCLUDE_INSTALL_DIR}
)

install(EXPORT ${PROJECT_NAME}Targets
    FILE Sqlite3Targets.cmake
    NAMESPACE Sqlite3::
    DESTINATION "${CMAKE_INSTALL_LIBDIR}/cmake/${PROJECT_NAME}"
)

configure_package_config_file(${CMAKE_CURRENT_SOURCE_DIR}/Sqlite3Config.cmake.in
    "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}Config.cmake"
    INSTALL_DESTINATION "${CMAKE_INSTALL_LIBDIR}/cmake/${PROJECT_NAME}"
)

write_basic_package_version_file(
    "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}ConfigVersion.cmake"
    VERSION "${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}"
    COMPATIBILITY AnyNewerVersion
)

install(
    FILES
        ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}Config.cmake
        ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}ConfigVersion.cmake
    DESTINATION "${CMAKE_INSTALL_LIBDIR}/cmake/${PROJECT_NAME}"
)

export(EXPORT Sqlite3Targets
    FILE "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}Targets.cmake"
    NAMESPACE Sqlite3::
)
