cmake_minimum_required(VERSION 3.16)
project(ChargePile VERSION 1.0.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

find_package(Qt6 REQUIRED COMPONENTS Core Gui Widgets Sql Charts Network)

add_subdirectory(common)
add_subdirectory(user_client)
add_subdirectory(admin_server)

# 构建后把数据库脚本复制到输出目录，便于首次运行初始化
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
    COMMENT "Copy database scripts next to executables"
    DEPENDS user_client admin_server
)
