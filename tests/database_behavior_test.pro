QT -= gui
QT += core sql widgets
CONFIG += console c++17 utf8_source
CONFIG -= app_bundle
TARGET = database_behavior_test
TEMPLATE = app

include(../common/common.pri)
include(../common/runtime_copy.pri)

SOURCES += DatabaseBehaviorTest.cpp
