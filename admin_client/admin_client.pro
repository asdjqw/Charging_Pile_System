QT += core gui widgets network charts
CONFIG += c++17 utf8_source
TARGET = admin_client
TEMPLATE = app

include(../common/common.pri)

HEADERS += \
    LoginDialog.h \
    AdminApiClient.h \
    MainWindow.h

SOURCES += \
    main.cpp \
    LoginDialog.cpp \
    AdminApiClient.cpp \
    MainWindow.cpp

FORMS += \
    LoginDialog.ui \
    MainWindow.ui \
    EditPileDialog.ui \
    EditStationDialog.ui \
    UserOrdersDialog.ui

win32: CONFIG += windows
macx: CONFIG += app_bundle
