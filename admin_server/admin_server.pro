QT = core network sql widgets
CONFIG += console c++17 utf8_source
CONFIG -= app_bundle
TARGET = admin_server
TEMPLATE = app

CHARGEPILE_COPY_WEB = 1
include(../common/common.pri)
include(../common/runtime_copy.pri)

HEADERS += \
    ApiDispatcher.h \
    LocalServer.h

SOURCES += \
    ApiDispatcher.cpp \
    LocalServer.cpp \
    main.cpp
