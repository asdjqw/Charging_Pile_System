cmake_minimum_required(VERSION 3.16)
project(ChargePile VERSION 1.0.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

find_package(Qt6 REQUIRED COMPONENTS Core Gui Widgets Sql Network DBus Charts)
include(CTest)

add_subdirectory(common)
add_subdirectory(user_client)
add_subdirectory(admin_client)
add_subdirectory(admin_server)
if(BUILD_TESTING)
    add_subdirectory(tests)
endif()

add_custom_target(copy_database ALL
    COMMAND ${CMAKE_COMMAND} -E copy_directory
        ${CMAKE_SOURCE_DIR}/database
        ${CMAKE_BINARY_DIR}/database
    COMMAND ${CMAKE_COMMAND} -E copy_directory
        ${CMAKE_SOURCE_DIR}/database
        $<TARGET_FILE_DIR:user_client>/database
    COMMAND ${CMAKE_COMMAND} -E copy_directory
        ${CMAKE_SOURCE_DIR}/database
        $<TARGET_FILE_DIR:admin_server>/database
    COMMAND ${CMAKE_COMMAND} -E copy_directory
        ${CMAKE_SOURCE_DIR}/web
        ${CMAKE_BINARY_DIR}/web
    COMMAND ${CMAKE_COMMAND} -E copy_directory
        ${CMAKE_SOURCE_DIR}/web
        $<TARGET_FILE_DIR:admin_server>/web
    COMMAND ${CMAKE_COMMAND} -E make_directory $<TARGET_FILE_DIR:user_client>/data
    COMMAND ${CMAKE_COMMAND} -E make_directory $<TARGET_FILE_DIR:admin_server>/data
    COMMAND ${CMAKE_COMMAND} -E make_directory $<TARGET_FILE_DIR:admin_client>/data
    COMMAND ${CMAKE_COMMAND} -E copy_if_different
        ${CMAKE_SOURCE_DIR}/data/北京市充电桩数据.csv
        $<TARGET_FILE_DIR:user_client>/data/北京市充电桩数据.csv
    COMMAND ${CMAKE_COMMAND} -E copy_if_different
        ${CMAKE_SOURCE_DIR}/data/北京市充电桩数据.csv
        $<TARGET_FILE_DIR:admin_server>/data/北京市充电桩数据.csv
    COMMENT "Copy database, CSV, and web dashboard assets"
    DEPENDS user_client admin_client admin_server
)
