QT += quick

# You can make your code fail to compile if it uses deprecated APIs.
# In order to do so, uncomment the following line.
#DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000    # disables all the APIs deprecated before Qt 6.0.0

SOURCES += \
        Controllers/audiocontroller.cpp \
        Controllers/hvachandler.cpp \
        Controllers/system.cpp \
        Controllers/vehiclestate.cpp \
        Testing/uilocator.cpp \
        main.cpp

RESOURCES += qml.qrc

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Additional import path used to resolve QML modules just for Qt Quick Designer
QML_DESIGNER_IMPORT_PATH =

# Default rules for deployment.
# On a target board (e.g. Raspberry Pi) Qt Creator copies the binary to
# target.path. Override with: qmake DEPLOY_PATH=/home/pi/TestPrototype
isEmpty(DEPLOY_PATH): DEPLOY_PATH = /opt/$${TARGET}/bin
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = $$DEPLOY_PATH
!isEmpty(target.path): INSTALLS += target

HEADERS += \
    Controllers/audiocontroller.h \
    Controllers/hvachandler.h \
    Controllers/system.h \
    Controllers/vehiclestate.h \
    Testing/uilocator.h
