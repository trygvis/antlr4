function(antlr4_add_target)
    set(options STATIC SHARED)
    set(oneValueArgs TARGET LEXER PARSER GRAMMAR)
    set(multiValueArgs)
    cmake_parse_arguments(antlr4_add_target "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    if (NOT antlr4_add_target_TARGET)
        message(FATAL_ERROR "TARGET <target name> has to be specified")
        return()
    endif ()
    set(TARGET "${antlr4_add_target_TARGET}")

    set(lexer ${antlr4_add_target_LEXER})
    set(parser ${antlr4_add_target_PARSER})

    if (antlr4_add_target_STATIC)
        set(library Antlr4::antlr4_static)
    elseif (antlr4_add_target_SHARED)
        set(library Antlr4::antlr4_shared)
    else ()
        message(FATAL_ERROR "Either STATIC or SHARED has to be specified")
        return()
    endif ()

    if (antlr4_add_target_STATIC AND antlr4_add_target_SHARED)
        message(FATAL_ERROR "Only one of STATIC and SHARED can be used")
        return()
    endif ()

    string(REGEX MATCH "^([^\\.]*)\\.g4" JUNK ${lexer})
    set(LEXER_CPP "${CMAKE_BINARY_DIR}/${TARGET}/${CMAKE_MATCH_1}.cpp")
    set(LEXER_H "${CMAKE_BINARY_DIR}/${TARGET}/${CMAKE_MATCH_1}.h")
    set(LEXER_TOKENS "${CMAKE_BINARY_DIR}/${TARGET}/${CMAKE_MATCH_1}.tokens")
    string(REGEX MATCH "^([^\\.]*)\\.g4" JUNK ${parser})
    set(PARSER_CPP "${CMAKE_BINARY_DIR}/${TARGET}/${CMAKE_MATCH_1}.cpp")
    set(PARSER_H "${CMAKE_BINARY_DIR}/${TARGET}/${CMAKE_MATCH_1}.h")

    add_custom_command(OUTPUT "${LEXER_CPP}" "${LEXER_H}" "${LEXER_TOKENS}"
            COMMAND java -cp "${ANTLR4_JAR}" org.antlr.v4.Tool
                -Dlanguage=Cpp
                -o "${CMAKE_BINARY_DIR}/${TARGET}"
                "${CMAKE_CURRENT_SOURCE_DIR}/${lexer}"
            COMMENT "Generating Antlr4 lexer: ${TARGET}"
            DEPENDS "${lexer}")

    add_custom_command(OUTPUT "${PARSER_CPP}" "${PARSER_H}"
            COMMAND java -cp "${ANTLR4_JAR}" org.antlr.v4.Tool
                -Dlanguage=Cpp
                -o "${CMAKE_BINARY_DIR}/${TARGET}"
                "${CMAKE_CURRENT_SOURCE_DIR}/${parser}"
            COMMENT "Generating Antlr4 parser: ${TARGET}"
            DEPENDS "${parser}" "${LEXER_TOKENS}")

    # This doesn't quite feel right, these directories should be included automatically by CMake.
    if (antlr4_add_target_STATIC)
        get_target_property(include_directories Antlr4::antlr4_static INTERFACE_INCLUDE_DIRECTORIES)
    elseif (antlr4_add_target_SHARED)
        get_target_property(include_directories Antlr4::antlr4_shared INTERFACE_INCLUDE_DIRECTORIES)
    endif()

    add_library(${TARGET} OBJECT "")
    target_sources(${TARGET} PRIVATE "${LEXER_CPP}" "${LEXER_H}" "${LEXER_TOKENS}")
    target_sources(${TARGET} PRIVATE "${PARSER_CPP}" "${PARSER_H}")

    # TODO: use target_compile_features() instead of --std=..

    target_compile_options(${TARGET} PRIVATE "--std=c++11")
    target_include_directories(${TARGET} PUBLIC "${CMAKE_BINARY_DIR}/${TARGET}")
    target_include_directories(${TARGET} PUBLIC "${include_directories}")
endfunction()
