cmake_minimum_required(VERSION 3.15)
project(IDA-Fusion VERSION 1.0.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE Release)
endif()

option(BUILD_64BIT "Build 64-bit plugin" ON)
option(BUILD_32BIT "Build 32-bit plugin" OFF)

set(IDA_SDK "${CMAKE_CURRENT_SOURCE_DIR}/sdk/src" CACHE PATH "Path to IDA SDK")

if(WIN32)
    set(IDA_PLATFORM "win")
    set(PLUGIN_EXT ".dll")
elseif(APPLE)
    set(IDA_PLATFORM "mac")
    set(PLUGIN_EXT ".dylib")
elseif(UNIX)
    set(IDA_PLATFORM "linux")
    set(PLUGIN_EXT ".so")
endif()

if(MSVC)
    set(IDA_COMPILER "vc")
elseif(CMAKE_CXX_COMPILER_ID MATCHES "Clang")
    set(IDA_COMPILER "clang")
elseif(CMAKE_CXX_COMPILER_ID MATCHES "GNU")
    set(IDA_COMPILER "gcc")
endif()

function(add_ida_plugin TARGET_NAME BITNESS)
    if(BITNESS EQUAL 64)
        set(ARCH_SUFFIX "64")
        set(EA64_FLAG "__EA64__")
        if(WIN32)
            set(LIB_DIR "${IDA_SDK}/lib/x64_${IDA_PLATFORM}_${IDA_COMPILER}_64")
        elseif(APPLE)
            if(CMAKE_SYSTEM_PROCESSOR MATCHES "arm64")
                set(LIB_DIR "${IDA_SDK}/lib/arm64_${IDA_PLATFORM}_${IDA_COMPILER}_64")
            else()
                set(LIB_DIR "${IDA_SDK}/lib/x64_${IDA_PLATFORM}_${IDA_COMPILER}_64")
            endif()
        else()
            set(LIB_DIR "${IDA_SDK}/lib/x64_${IDA_PLATFORM}_${IDA_COMPILER}_64")
        endif()
    else()
        set(ARCH_SUFFIX "")
        set(EA64_FLAG "")
        set(LIB_DIR "${IDA_SDK}/lib/x64_${IDA_PLATFORM}_${IDA_COMPILER}_32")
        add_definitions(-D__X86__)
    endif()

    set(SOURCE_FILES src/main.cpp)

    add_library(${TARGET_NAME} SHARED ${SOURCE_FILES})

    set_target_properties(${TARGET_NAME} PROPERTIES
        OUTPUT_NAME "fusion${ARCH_SUFFIX}"
        PREFIX ""
        SUFFIX "${PLUGIN_EXT}"
    )

    target_include_directories(${TARGET_NAME} PRIVATE
        ${IDA_SDK}/include
        src
    )

    target_compile_definitions(${TARGET_NAME} PRIVATE
        ${EA64_FLAG}
        $<$<PLATFORM_ID:Windows>:__NT__>
        $<$<PLATFORM_ID:Linux>:__LINUX__>
        $<$<PLATFORM_ID:Darwin>:__MAC__>
        $<$<STREQUAL:${BITNESS},64>:__X64__>
    )

    if(MSVC)
        target_compile_options(${TARGET_NAME} PRIVATE
            /W3
            /MP
            /permissive-
            $<$<CONFIG:Release>:/O2 /GL>
        )
        target_compile_definitions(${TARGET_NAME} PRIVATE
            _SILENCE_CXX20_IS_POD_DEPRECATION_WARNING
        )
        target_link_options(${TARGET_NAME} PRIVATE
            $<$<CONFIG:Release>:/LTCG>
            /EXPORT:PLUGIN
        )
    else()
        target_compile_options(${TARGET_NAME} PRIVATE
            -Wall
            -Wextra
            -Wno-unused-parameter
            -fpermissive
            $<$<CONFIG:Release>:-O3>
        )
        
        if(UNIX AND NOT APPLE)
            target_compile_options(${TARGET_NAME} PRIVATE -fPIC)
        endif()
    endif()

    if(WIN32)
        target_link_libraries(${TARGET_NAME} PRIVATE "${LIB_DIR}/ida.lib")
        if(NOT MSVC)
            target_link_options(${TARGET_NAME} PRIVATE
                -static
                -Wl,--exclude-all-symbols,--kill-at
            )
        endif()
    elseif(APPLE)
        target_link_libraries(${TARGET_NAME} PRIVATE "${LIB_DIR}/libida.dylib")
    else()
        target_link_libraries(${TARGET_NAME} PRIVATE "${LIB_DIR}/libida.so")
    endif()

    if(BITNESS EQUAL 32 AND (UNIX OR MINGW) AND NOT MSVC)
        target_compile_options(${TARGET_NAME} PRIVATE -m32)
        target_link_options(${TARGET_NAME} PRIVATE -m32)
    endif()

    if(NOT DEFINED IDA_INSTALL_DIR)
        if(WIN32)
            set(IDA_INSTALL_DIR "C:/Program Files/IDA" CACHE PATH "IDA installation directory")
        elseif(APPLE)
            set(IDA_INSTALL_DIR "/Applications/IDA Pro" CACHE PATH "IDA installation directory")
        else()
            set(IDA_INSTALL_DIR "$ENV{HOME}/ida" CACHE PATH "IDA installation directory")
        endif()
    endif()

    install(TARGETS ${TARGET_NAME}
        LIBRARY DESTINATION "${IDA_INSTALL_DIR}/plugins"
        RUNTIME DESTINATION "${IDA_INSTALL_DIR}/plugins"
    )
endfunction()

if(BUILD_64BIT)
    add_ida_plugin(fusion64 64)
endif()

if(BUILD_32BIT)
    add_ida_plugin(fusion32 32)
endif()

message(STATUS "IDA-Fusion Configuration:")
message(STATUS "  Platform: ${IDA_PLATFORM}")
message(STATUS "  Compiler: ${IDA_COMPILER}")
message(STATUS "  IDA SDK: ${IDA_SDK}")
message(STATUS "  Build 64-bit: ${BUILD_64BIT}")
message(STATUS "  Build 32-bit: ${BUILD_32BIT}")
message(STATUS "  Install directory: ${IDA_INSTALL_DIR}")
