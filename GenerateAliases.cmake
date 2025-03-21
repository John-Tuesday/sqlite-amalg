function(Sqlite3_GenerateAliases target)
    set(options "")
    set(oneValueArgs FILE INCLUDE NAMESPACE
        INT64_TYPE INT64_NAME
        UINT64_TYPE UINT_64_NAME
    )
    set(multiValueArgs "")
    cmake_parse_arguments(PARSE_ARGV 0 arg
        "${optios}" "${oneValueArgs}" "${multiValueArgs}"
    )
    if(NOT DEFINED target)
        message(SEND_ERROR "No target specified. A target must be given.")
    endif()
    set(filepath "aliases.hpp")
    if(DEFINED arg_FILE)
        set(filepath "${arg_FILE}")
    endif()
    set(content "#pragma once\n\n")
    if(DEFINED arg_INCLUDE)
        string(APPEND content "#include <${arg_INCLUDE}>\n")
    endif()
    if(DEFINED arg_NAMESPACE)
        string(APPEND content "\nnamespace ${arg_NAMESPACE} {\n")
    endif()
    foreach(t IN ITEMS INT64 UINT64)
        if(DEFINED arg_${t}_TYPE AND arg_${t}_NAME)
            string(APPEND content "using ${arg_${t}_NAME} = ${arg_${t}_TYPE};\n")
        endif()
    endforeach()
    if(DEFINED arg_NAMESPACE)
        string(APPEND content "\n}\n")
    endif()
    file(CONFIGURE OUTPUT "${arg_FILE}"
        CONTENT "${content}"
    )
    add_custom_target(${target} DEPENDS "${arg_FILE}")
endfunction()

