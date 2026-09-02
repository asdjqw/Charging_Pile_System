add_executable(admin_server
    ApiDispatcher.cpp
    ApiDispatcher.h
    LocalServer.cpp
    LocalServer.h
    main.cpp
)

target_link_libraries(admin_server PRIVATE
    common
    Qt6::Core
    Qt6::Network
    Qt6::Sql
)
