QT += core gui widgets sql network dbus
CONFIG += c++17 utf8_source
TARGET = user_client
TEMPLATE = app

include(../common/common.pri)
include(../common/runtime_copy.pri)

HEADERS += \
    LoginDialog.h \
    LocationProvider.h \
    ServerApiClient.h \
    MainWindow.h

SOURCES += \
    main.cpp \
    LoginDialog.cpp \
    LocationProvider.cpp \
    ServerApiClient.cpp \
    MainWindow.cpp

win32: CONFIG += windows
macx: CONFIG += app_bundle
