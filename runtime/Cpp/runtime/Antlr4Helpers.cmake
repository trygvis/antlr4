function(antlr4_add_target)
    set(options OPTIONAL VISITOR STATIC SHARED)
    set(oneValueArgs TARGET LEXER PARSER GRAMMAR)
    set(multiValueArgs)
    message("options: ${options}")
    cmake_parse_arguments(antlr4_add_target "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
    message("antlr4_add_target_UNPARSED_ARGUMENTS: ${antlr4_add_target_UNPARSED_ARGUMENTS}")
    message("antlr4_add_target_LEXER: ${antlr4_add_target_LEXER}")
    message("antlr4_add_target_PARSER: ${antlr4_add_target_PARSER}")

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
    message("LEXER_TOKENS: ${LEXER_TOKENS}")

    add_custom_command(OUTPUT "${LEXER_CPP}" "${LEXER_H}" "${LEXER_TOKENS}"
            COMMAND java -cp "${ANTLR4_JAR}" org.antlr.v4.Tool
                -Dlanguage=Cpp
                -o "${CMAKE_BINARY_DIR}/${TARGET}"
                "${CMAKE_SOURCE_DIR}/${lexer}"
            COMMENT "Generating Antlr4 lexer: ${TARGET}"
            DEPENDS "${lexer}")

    add_custom_command(OUTPUT "${PARSER_CPP}" "${PARSER_H}"
            COMMAND java -cp "${ANTLR4_JAR}" org.antlr.v4.Tool
                -Dlanguage=Cpp
                -o "${CMAKE_BINARY_DIR}/${TARGET}"
                "${CMAKE_SOURCE_DIR}/${parser}"
            COMMENT "Generating Antlr4 parser: ${TARGET}"
            DEPENDS "${parser}" "${LEXER_TOKENS}")

    get_target_property(ID Antlr4::antlr4_shared INTERFACE_INCLUDE_DIRECTORIES)
    message("ID: ${ID}")

    add_library(${TARGET} STATIC "${LEXER_CPP}" "${PARSER_CPP}")
    # TODO: use target_compile_features() instead of --std=..
    target_compile_options(${TARGET} PRIVATE "--std=c++11")
    target_include_directories("${TARGET}" PUBLIC "${CMAKE_BINARY_DIR}/${TARGET}" "${ID}")
    target_link_libraries("${TARGET}" PUBLIC "${lib}")

endfunction()

#function(antlr4_add_lexer G4_FILE)
#    if (NOT EXISTS "${ANTLR4_JAR}")
#        message(FATAL_ERROR "ANTLR4_JAR must be an existing file: ${ANTLR4_JAR}")
#        return()
#    endif ()
#
#    string(REGEX MATCH "^([^\\.]*)\\.g4" JUNK ${G4_FILE})
#    set(TARGET "${CMAKE_MATCH_1}")
#    message(STATUS "Creating target ${TARGET}")
#
#    set(LEXER_CPP "${CMAKE_BINARY_DIR}/${TARGET}/${TARGET}.cpp")
#    set(LEXER_H "${CMAKE_BINARY_DIR}/${TARGET}/${TARGET}.h")
#    add_custom_command(OUTPUT "${LEXER_CPP}" "${LEXER_H}"
#            COMMAND java -cp "${ANTLR4_JAR}" org.antlr.v4.Tool
#            -Dlanguage=Cpp
#            -o "${CMAKE_BINARY_DIR}/${TARGET}"
#            "${CMAKE_SOURCE_DIR}/${G4_FILE}"
#            COMMENT "Generating Antlr4 Lexer: ${TARGET}"
#            SOURCES "${G4_FILE}")
#
#    add_library(${TARGET} STATIC "${LEXER_CPP}")
#    target_compile_options(${TARGET} PRIVATE "--std=c++11")
#    target_include_directories("${TARGET}" PUBLIC ${CMAKE_BINARY_DIR}/${TARGET})
#    target_link_libraries("${TARGET}" PUBLIC Antlr4::antlr4_shared)
#endfunction()
#
#function(antlr4_add_parser G4_FILE)
#    if (NOT EXISTS "${ANTLR4_JAR}")
#        message(FATAL_ERROR "ANTLR4_JAR must be an existing file: ${ANTLR4_JAR}")
#        return()
#    endif ()
#
#    string(REGEX MATCH "^([^\\.]*)\\.g4" JUNK ${G4_FILE})
#    set(TARGET "${CMAKE_MATCH_1}")
#    message(STATUS "Creating target ${TARGET}")
#
#    set(PARSER_CPP "${CMAKE_BINARY_DIR}/${TARGET}/${TARGET}.cpp")
#    set(PARSER_H "${CMAKE_BINARY_DIR}/${TARGET}/${TARGET}.h")
#    add_custom_command(OUTPUT "${PARSER_CPP}" "${PARSER_H}"
#            COMMAND java -cp "${ANTLR4_JAR}" org.antlr.v4.Tool
#            -Dlanguage=Cpp
#            -o "${CMAKE_BINARY_DIR}/${TARGET}"
#            "${CMAKE_SOURCE_DIR}/${G4_FILE}"
#            COMMENT "Generating Antlr4 Parser: ${TARGET}"
#            SOURCES "${G4_FILE}")
#
#    add_library(${TARGET} STATIC "${PARSER_CPP}")
#    target_compile_options(${TARGET} PRIVATE "--std=c++11")
#    target_include_directories("${TARGET}" PUBLIC ${CMAKE_BINARY_DIR}/${TARGET})
#    target_link_libraries("${TARGET}" PUBLIC Antlr4::antlr4_shared)
#endfunction()
