QT -= gui
QT += core
CONFIG += console c++17 utf8_source
CONFIG -= app_bundle
TARGET = protocol_test
TEMPLATE = app

include(../common/common.pri)

SOURCES += ProtocolTest.cpp
