QT += core sql widgets
TEMPLATE = lib
CONFIG += staticlib c++17 utf8_source
TARGET = common

HEADERS += \
    DatabaseManager.h \
    FramedJson.h \
    JsonCodec.h \
    Models.h \
    PasswordCrypto.h \
    StyleHelper.h

SOURCES += \
    DatabaseManager.cpp \
    FramedJson.cpp \
    JsonCodec.cpp
