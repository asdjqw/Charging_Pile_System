add_executable(admin_server
    ApiDispatcher.cpp
    ApiDispatcher.h
    LocalServer.cpp
    LocalServer.h
    main.cpp
    LoginDialog.cpp
    LoginDialog.h
    MainWindow.cpp
    MainWindow.h
)

target_link_libraries(admin_server PRIVATE
    common
    Qt6::Core
    Qt6::Gui
    Qt6::Widgets
    Qt6::Sql
    Qt6::Network
)

set_target_properties(admin_server PROPERTIES
    WIN32_EXECUTABLE TRUE
    MACOSX_BUNDLE TRUE
)
