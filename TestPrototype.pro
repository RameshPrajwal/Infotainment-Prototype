QT += quick

# You can make your code fail to compile if it uses deprecated APIs.
# In order to do so, uncomment the following line.
#DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000    # disables all the APIs deprecated before Qt 6.0.0

# 1. Read the key from a local environment variable named THUNDERFOREST_KEY
API_KEY = $$(THUNDERFOREST_KEY)

# 2. Provide a safe development fallback string if the variable is missing
isEmpty(API_KEY) {
    API_KEY = "DEVELOPMENT_KEY_MISSING"
}

# 3. Pass it to the C++ compiler as a preprocessor definition macro
DEFINES += THUNDERFOREST_API_KEY=\\\"$$API_KEY\\\"


SOURCES += \
        Controllers/hvachandler.cpp \
        Controllers/system.cpp \
        main.cpp

RESOURCES += qml.qrc

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Additional import path used to resolve QML modules just for Qt Quick Designer
QML_DESIGNER_IMPORT_PATH =

# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target

HEADERS += \
    Controllers/hvachandler.h \
    Controllers/system.h
