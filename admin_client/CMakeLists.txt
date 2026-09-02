add_executable(admin_client
    main.cpp
    LoginDialog.cpp
    LoginDialog.h
    AdminApiClient.cpp
    AdminApiClient.h
    MainWindow.cpp
    MainWindow.h
)

target_link_libraries(admin_client PRIVATE
    common
    Qt6::Core
    Qt6::Gui
    Qt6::Widgets
    Qt6::Network
    Qt6::Charts
)

set_target_properties(admin_client PROPERTIES
    WIN32_EXECUTABLE TRUE
    MACOSX_BUNDLE TRUE
)
