add_executable(protocol_test ProtocolTest.cpp)
target_link_libraries(protocol_test PRIVATE common Qt6::Core)
add_test(NAME protocol_test COMMAND protocol_test)

add_executable(database_behavior_test DatabaseBehaviorTest.cpp)
target_link_libraries(database_behavior_test PRIVATE common Qt6::Core)
add_test(NAME database_behavior_test COMMAND database_behavior_test)

add_executable(server_api_smoke
    ServerApiSmoke.cpp
    ${CMAKE_SOURCE_DIR}/user_client/ServerApiClient.cpp
    ${CMAKE_SOURCE_DIR}/user_client/ServerApiClient.h
)
target_include_directories(server_api_smoke PRIVATE ${CMAKE_SOURCE_DIR}/user_client)
target_link_libraries(server_api_smoke PRIVATE common Qt6::Core Qt6::Network)
