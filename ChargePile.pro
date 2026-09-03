TEMPLATE = subdirs
CONFIG += ordered

lessThan(QT_MAJOR_VERSION, 6): error("This project requires Qt 6 (use qmake6).")

SUBDIRS = \
    common \
    user_client \
    admin_client \
    admin_server \
    protocol_test \
    database_behavior_test \
    server_api_smoke

user_client.depends = common
admin_client.depends = common
admin_server.depends = common

protocol_test.file = tests/protocol_test.pro
protocol_test.depends = common

database_behavior_test.file = tests/database_behavior_test.pro
database_behavior_test.depends = common

server_api_smoke.file = tests/server_api_smoke.pro
server_api_smoke.depends = common
