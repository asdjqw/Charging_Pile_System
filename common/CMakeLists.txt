add_library(common STATIC
    DatabaseManager.cpp
    DatabaseManager.h
    Models.h
    StyleHelper.h
)

target_include_directories(common PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})
target_link_libraries(common PUBLIC Qt6::Core Qt6::Sql Qt6::Widgets)
