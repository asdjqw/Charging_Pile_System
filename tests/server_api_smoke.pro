QT -= gui
QT += core network
CONFIG += console c++17 utf8_source
CONFIG -= app_bundle
TARGET = server_api_smoke
TEMPLATE = app

include(../common/common.pri)
INCLUDEPATH += $$PWD/../user_client

HEADERS += ../user_client/ServerApiClient.h
SOURCES += \
    ServerApiSmoke.cpp \
    ../user_client/ServerApiClient.cpp
