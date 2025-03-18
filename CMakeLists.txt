cmake_minimum_required(VERSION 3.28)

set(SQLITE_VERSION 3.49.1)

project(Sqlite3
    LANGUAGES C CXX
    HOMEPAGE_URL "sqlite.org"
    VERSION ${SQLITE_VERSION}
)
set(CMAKE_C_STANDARD 17)
set(CMAKE_C_STANDARD_REQUIRED TRUE)
set(CMAKE_C_EXTENSIONS OFF)

option(SQLITE_INCLUDE "Header to be passed to the source compiler" "")
option(SQLITE_INT64_TYPE "sqlite int64 type" "")
option(SQLITE_UINT64_TYPE "sqlite unsigned 64 bit integer type" "")
option(SQLITE_ALIAS_NAMESPACE "Namespace for generated alias header" "")
option(SQLITE_ALIAS_INCLUDE "Header for generated alias header" "")
option(SQLITE_ALIAS_INT64_TYPE "CXX equivalent to sqlite int64 type" "")
option(SQLITE_ALIAS_INT64_NAME "Type alias name" "")
option(SQLITE_ALIAS_UINT64_TYPE "CXX equivalent to sqlite uint64 type" "")
option(SQLITE_ALIAS_UINT64_NAME "Type alias name" "")

include(GNUInstallDirs)
include(CMakePackageConfigHelpers)

add_library(sqlite3_amalgamation_sources INTERFACE)
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
    INTERFACE
        "$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/sqlite3-amalgamation/sqlite3.c>"
        "$<INSTALL_INTERFACE:${CMAKE_INCLUDE_INSTALL_DIR}/sqlite3.c>"
)

instal(TARGETS sqlite3_amalgamation_sources
    EXPORT Sqlite3Targets
    COMPONENT AmalgamationSources
    FILE_SET HEADERS
    INCLUDES DESTINATION ${CMAKE_INCLUDE_INSTALL_DIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
)

add_library(sqlite3_static STATIC)
add_library(Sqlite3::${PROJECT_NAME} ALIAS sqlite3_static)

set_target_properties(sqlite3_static PROPERTIES
    EXPORT_NAME ${PROJECT_NAME}
    OUTPUT_NAME ${PROJECT_NAME}
    VERSION ${PROJECT_VERSION}
    SOVERSION ${PROJECT_VERSION_MAJOR}
    POSITION_INDEPENDENT_CODE ON
)

target_sources(sqlite3_static
    PUBLIC FILE_SET HEADERS
        BASE_DIRS
            "$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/sqlite3-amalgamation>"
            "$<INSTALL_INTERFACE:${CMAKE_INCLUDE_INSTALL_DIR}>"
        FILES
            sqlite3-amalgamation/sqlite3.h
    PRIVATE
        sqlite3-amalgamation/sqlite3.c
)

target_compile_options(sqlite3_static
    PRIVATE
        # "$<BUILD_INTERFACE:-Wno-undef;-Wno-discarded-qualifiers>"
        "$<BUILD_INTERFACE:-Wno-undef>"
        # "$<BUILD_INTERFACE:-fPIC>"
)
if(SQLITE_INCLUDE)
    target_compile_options(sqlite3_static
        PRIVATE
            "-include${SQLITE_INCLUDE}"
    )
endif()

target_compile_features(sqlite3_static
    PRIVATE
        $<BUILD_INTERFACE:c_std_17>
        $<INSTALL_INTERFACE:c_std_17>
)

target_compile_definitions(sqlite3_static
    PRIVATE
        SQLITE_ENABLE_COLUMN_METADATA
        SQLITE_DEFAULT_FOREIGN_KEYS=1
        SQLITE_OMIT_DEPRECATED
        SQLITE_DEFAULT_WAL_SYNCHRONOUS=1
)
if(SQLITE_INT64_TYPE)
    target_compile_definitions(sqlite3_static
        PUBLIC
            "SQLITE_INT64_TYPE=${SQLITE_INT64_TYPE}"
    )
endif()
if(SQLITE_UINT64_TYPE)
    target_compile_definitions(sqlite3_static
        PUBLIC
            "SQLITE_UINT64_TYPE=${SQLITE_UINT64_TYPE}"
    )
endif()


function(Sqlite3_generate_sqlite_alias)
    block(SCOPE_FOR VARIABLES)
        set(content "#pragma once\n\n")
        if(SQLITE_ALIAS_INCLUDE)
            string(APPEND content "#include <${SQLITE_ALIAS_INCLUDE}>\n")
        endif()
        if(SQLITE_ALIAS_NAMESPACE)
            string(APPEND content "\nnamespace ${SQLITE_ALIAS_NAMESPACE} {\n")
        endif()
        if(SQLITE_ALIAS_INT64_TYPE AND SQLITE_ALIAS_INT64_NAME)
            string(APPEND content "using ${SQLITE_ALIAS_INT64_NAME} = ${SQLITE_ALIAS_INT64_TYPE};\n")
        endif()
        if(SQLITE_ALIAS_UINT64_TYPE AND SQLITE_ALIAS_UINT64_NAME)
            string(APPEND content "using ${SQLITE_ALIAS_UINT64_NAME} = ${SQLITE_ALIAS_UINT64_TYPE};\n")
        endif()
        if(SQLITE_ALIAS_NAMESPACE)
            string(APPEND content "}\n")
        endif()
        file(CONFIGURE OUTPUT sqlite3-amalgamation/sqlite3_aliases.hpp
            CONTENT "${content}"
        )
        add_custom_target(generate_alias_header
            DEPENDS sqlite3-amalgamation/sqlite3_aliases.hpp
        )
    endblock()
endfunction()
cmake_language(DEFER CALL Sqlite3_generate_sqlite_alias)

add_library(sqlite3_cxx_aliases INTERFACE)
add_library(Sqlite3::Aliases ALIAS sqlite3_cxx_aliases)

set_target_properties(sqlite3_cxx_aliases PROPERTIES
    EXPORT_NAME Aliases
    OUTPUT_NAME Aliases
    VERSION ${PROJECT_VERSION}
    SOVERSION ${PROJECT_VERSION_MAJOR}
    POSITION_INDEPENDENT_CODE ON
)

target_sources(sqlite3_cxx_aliases
    PUBLIC FILE_SET HEADERS
    BASE_DIRS
        "$<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}/sqlite3-amalgamation>"
        "$<INSTALL_INTERFACE:${CMAKE_INCLUDE_INSTALL_DIR}>"
    FILES
        ${CMAKE_CURRENT_BINARY_DIR}/sqlite3-amalgamation/sqlite3_aliases.hpp
)

add_dependencies(sqlite3_cxx_aliases generate_alias_header)

install(TARGETS sqlite3_static
    EXPORT Sqlite3Targets
    FILE_SET HEADERS
    INCLUDES DESTINATION ${CMAKE_INCLUDE_INSTALL_DIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
)

install(TARGETS sqlite3_cxx_aliases
    EXPORT Sqlite3Targets
    FILE_SET HEADERS
    INCLUDES DESTINATION ${CMAKE_INCLUDE_INSTALL_DIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
)

install(EXPORT ${PROJECT_NAME}Targets
    FILE ${PROJECT_NAME}Targets.cmake
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

export(EXPORT ${PROJECT_NAME}Targets
    FILE "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}Targets.cmake"
    NAMESPACE Sqlite3::
)
