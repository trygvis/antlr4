function(antlr4_add_lexer G4_FILE)
    if (NOT EXISTS "${ANTLR4_JAR}")
        message(FATAL_ERROR "ANTLR4_JAR must be an existing file: ${ANTLR4_JAR}")
        return()
    endif()

    string(REGEX MATCH "^([^\\.]*)\\.g4" JUNK ${G4_FILE})
    set(TARGET "${CMAKE_MATCH_1}")
    message(STATUS "Creating target ${TARGET}")

    set(LEXER_CPP "${CMAKE_BINARY_DIR}/${TARGET}/${TARGET}.cpp")
    set(LEXER_H "${CMAKE_BINARY_DIR}/${TARGET}/${TARGET}.h")
    add_custom_command(OUTPUT "${LEXER_CPP}" "${LEXER_H}"
            COMMAND java -cp "${ANTLR4_JAR}" org.antlr.v4.Tool
            -Dlanguage=Cpp
            -o "${CMAKE_BINARY_DIR}/${TARGET}"
            "${CMAKE_SOURCE_DIR}/${G4_FILE}"
            COMMENT "Generating Antlr4 Lexer: ${TARGET}"
            SOURCES "${G4_FILE}")

    add_library(${TARGET} STATIC "${LEXER_CPP}")
    target_compile_options(${TARGET} PRIVATE "--std=c++11")
    target_include_directories("${TARGET}" PUBLIC ${CMAKE_BINARY_DIR}/${TARGET})
    target_link_libraries("${TARGET}" PUBLIC Antlr4::antlr4_shared)
endfunction()

function(antlr4_add_parser G4_FILE)
    if (NOT EXISTS "${ANTLR4_JAR}")
        message(FATAL_ERROR "ANTLR4_JAR must be an existing file: ${ANTLR4_JAR}")
        return()
    endif()

    string(REGEX MATCH "^([^\\.]*)\\.g4" JUNK ${G4_FILE})
    set(TARGET "${CMAKE_MATCH_1}")
    message(STATUS "Creating target ${TARGET}")

    set(PARSER_CPP "${CMAKE_BINARY_DIR}/${TARGET}/${TARGET}.cpp")
    set(PARSER_H "${CMAKE_BINARY_DIR}/${TARGET}/${TARGET}.h")
    add_custom_command(OUTPUT "${PARSER_CPP}" "${PARSER_H}"
            COMMAND java -cp "${ANTLR4_JAR}" org.antlr.v4.Tool
            -Dlanguage=Cpp
            -o "${CMAKE_BINARY_DIR}/${TARGET}"
            "${CMAKE_SOURCE_DIR}/${G4_FILE}"
            COMMENT "Generating Antlr4 Parser: ${TARGET}"
            SOURCES "${G4_FILE}")

    add_library(${TARGET} STATIC "${PARSER_CPP}")
    target_compile_options(${TARGET} PRIVATE "--std=c++11")
    target_include_directories("${TARGET}" PUBLIC ${CMAKE_BINARY_DIR}/${TARGET})
    target_link_libraries("${TARGET}" PUBLIC Antlr4::antlr4_shared)
endfunction()
