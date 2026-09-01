add_executable(admin_server
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
)

set_target_properties(admin_server PROPERTIES
    WIN32_EXECUTABLE TRUE
    MACOSX_BUNDLE TRUE
)
