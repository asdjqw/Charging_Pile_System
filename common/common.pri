# Shared include/link for the static common library.
# Default layout is a sibling of this target under the shadow build dir.
isEmpty(COMMON_BUILD): COMMON_BUILD = $$OUT_PWD/../common

INCLUDEPATH += $$PWD
DEPENDPATH += $$PWD
LIBS += -L$$COMMON_BUILD -lcommon
PRE_TARGETDEPS += $$COMMON_BUILD/$${QMAKE_PREFIX_STATICLIB}common.$${QMAKE_EXTENSION_STATICLIB}
