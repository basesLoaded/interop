# Find a C# Project builder
# - Mono: xbuild
# - .NET: msbuild
# - .NET CoreCLR: dotnet


list(APPEND CMAKE_MODULE_PATH "${PROJECT_SOURCE_DIR}/cmake/Modules/csharp")
include( FindPackageHandleStandardArgs )

if(CSBUILD_TOOL MATCHES "DotNet|Mono|DotNetCore")
    set(DOTNET_FOUND FALSE)
    set(MONO_FOUND FALSE)
    set(DOTNET_CORE_FOUND FALSE)
    find_package( ${CSBUILD_TOOL} REQUIRED )
endif()
if(NOT DOTNET_FOUND AND NOT MONO_FOUND AND NOT DOTNET_CORE_FOUND)
    if(CSBUILD_TOOL)
        message(WARNING "Ignored -DCSBUILD_TOOL=${CSBUILD_TOOL} it does not match DotNet|Mono|DotNetCore or program not found")
    endif()
    if( WIN32 )
        find_package( DotNet )
        if( NOT DOTNET_FOUND )
            find_package( Mono )
            if( NOT MONO_FOUND )
                find_package( DotNetCore )
            endif()
        endif()
    else( UNIX )
        find_package( Mono )
        if( NOT MONO_FOUND )
            find_package( DotNetCore )
        endif()
    endif()

endif()

set(MSBUILD_TOOLSET "12.0" CACHE STRING "C# .NET framework" )
set(CSHARP_TARGET_FRAMEWORK_VERSION "2.0" CACHE STRING "C# .NET framework for msbuild and xbuild" )
set(CSHARP_TARGET_FRAMEWORK "netcoreapp2.0" CACHE STRING "C# .NET framework for dotnet" )

if(CMAKE_SIZEOF_VOID_P EQUAL "4" OR FORCE_X86)
    set(CSHARP_PLATFORM "x86" CACHE STRING "C# target platform: x86, x64, anycpu, or itanium")
elseif( CMAKE_SIZEOF_VOID_P EQUAL "8" )
    if(MONO_FOUND AND "${MONO_VERSION}" VERSION_LESS "2.10.10")
        set(CSHARP_PLATFORM "anycpu" CACHE STRING "C# target platform: x86, x64, anycpu, or itanium")
    else()
        set(CSHARP_PLATFORM "x64" CACHE STRING "C# target platform: x86, x64, anycpu, or itanium")
    endif()
else()
    message(FATAL_ERROR "Only 32-bit and 64-bit are supported: ${CMAKE_SIZEOF_VOID_P}")
endif()


if(MSVC)
    set(CSHARP_BUILDER_OUTPUT_PATH "${CMAKE_CURRENT_BINARY_DIR}/$<CONFIG>")
else()
    set(CSHARP_BUILDER_OUTPUT_PATH "${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_BUILD_TYPE}")
endif()

string(REPLACE "." "" _version "${CSHARP_TARGET_FRAMEWORK_VERSION}")
set(CSBUILD_FOUND TRUE)
set(CSBUILD_RESTORE_FLAGS "/version")
set(CSBUILD_BUILD_FLAGS "")
if(DOTNET_FOUND)
    set(CSBUILD_EXECUTABLE "${MSBUILD_EXECUTABLE}")
    set(CSBUILD_CSPROJ "msbuild.csproj")
    set(CSBUILD_OUPUT_PREFIX "")
    message(STATUS "Found .NET: ${DOTNET_EXECUTABLE_VERSION}")
    set(CSHARP_INTERPRETER "")
    set(CSHARP_TYPE "net${_version}")
    set(CSHARP_BUILDER_VERSION ".NET ${DOTNET_EXECUTABLE_VERSION} - net${_version}")
elseif(MONO_FOUND)
    message(STATUS "Found Mono: ${MONO_VERSION}")
    set(CSBUILD_EXECUTABLE "${XBUILD_EXECUTABLE}")
    set(CSBUILD_CSPROJ "msbuild.csproj")
    set(CSBUILD_OUPUT_PREFIX "")
    set(CSHARP_INTERPRETER "${MONO_EXECUTABLE}")
    set(CSHARP_TYPE "net${_version}")
    set(CSHARP_BUILDER_VERSION "Mono ${MONO_VERSION} - net${_version}")
elseif(DOTNET_CORE_FOUND)
    message(STATUS "Found .NET Core: ${DOTNET_CORE_VERSION}")
    set(CSBUILD_EXECUTABLE "${DOTNET_CORE_EXECUTABLE}")
    set(CSBUILD_CSPROJ "dotnetcore.csproj")
    set(CSBUILD_BUILD_FLAGS "publish")
    set(CSBUILD_OUPUT_PREFIX "${CSHARP_TARGET_FRAMEWORK}/publish/")
    set(CSHARP_INTERPRETER "${DOTNET_CORE_EXECUTABLE}")
    set(CSBUILD_RESTORE_FLAGS "restore")
    set(CSHARP_TYPE "${CSHARP_TARGET_FRAMEWORK}")
    set(CSHARP_BUILDER_VERSION ".NET Standard ${DOTNET_CORE_VERSION} - ${CSHARP_TARGET_FRAMEWORK}")
else()
    set(CSBUILD_FOUND FALSE)
endif()

if(NOT CSHARP_PLATFORM)
    message(FATAL_ERROR "CSHARP_PLATFORM not set")
endif()

if(NOT CSHARP_TARGET_FRAMEWORK)
    message(FATAL_ERROR "CSHARP_TARGET_FRAMEWORK not set")
endif()

if(CSBUILD_FOUND)
    message(STATUS "Using Framework: ${CSHARP_TARGET_FRAMEWORK}")
    if(DOTNET_CORE_FOUND)
        message(STATUS "Using Framework: ${CSHARP_TARGET_FRAMEWORK}")
        message(STATUS "Using Platform: ${CSHARP_PLATFORM}")
    else()
        find_program(NUGET_EXE nuget)
        set(RESTORE_EXE ${NUGET_EXE})
        message(STATUS "Using Framework: v${CSHARP_TARGET_FRAMEWORK_VERSION}")
        message(STATUS "Using Platform: ${CSHARP_PLATFORM}")
    endif()
    set(CSBUILD_CSPROJ_IN "${CMAKE_SOURCE_DIR}/cmake/Modules/csharp/${CSBUILD_CSPROJ}.in")
    set(CSBUILD_USE_FILE "${CMAKE_SOURCE_DIR}/cmake/Modules/csharp/UseCSharpProjectBuilder.cmake")
endif()
