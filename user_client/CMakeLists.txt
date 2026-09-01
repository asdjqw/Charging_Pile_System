add_executable(user_client
    main.cpp
    LoginDialog.cpp
    LoginDialog.h
    LocationProvider.cpp
    LocationProvider.h
    ServerApiClient.cpp
    ServerApiClient.h
    MainWindow.cpp
    MainWindow.h
)

target_link_libraries(user_client PRIVATE
    common
    Qt6::Core
    Qt6::Gui
    Qt6::Widgets
    Qt6::Sql
    Qt6::Network
    Qt6::DBus
)

set_target_properties(user_client PROPERTIES
    WIN32_EXECUTABLE TRUE
    MACOSX_BUNDLE TRUE
)
