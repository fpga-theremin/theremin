#-------------------------------------------------
#
# Project created by QtCreator 2019-08-21T16:20:07
#
#-------------------------------------------------

QT       += core gui multimedia

greaterThan(QT_MAJOR_VERSION, 4): QT += widgets

TARGET = cora_theremin_sim
TEMPLATE = app

DEFINES += THEREMIN_SIMULATOR

# The following define makes your compiler emit warnings if you use
# any feature of Qt which has been marked as deprecated (the exact warnings
# depend on your compiler). Please consult the documentation of the
# deprecated API in order to know how to port your code away from it.
DEFINES += QT_DEPRECATED_WARNINGS

# You can also make your code fail to compile if you use deprecated APIs.
# In order to do so, uncomment the following line.
# You can also select to disable deprecated APIs only up to a certain version of Qt.
#DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000    # disables all the APIs deprecated before Qt 6.0.0

CONFIG += c++11

SOURCES += \
    ../../theremin_sdk/theremin/src/lcd_screen.cpp \
    ../../theremin_sdk/common/src/noteutil.cpp \
    ../../theremin_sdk/synthesizer/src/synthesizer.cpp \
    encoder_widget.cpp \
    main.cpp \
    mainwindow.cpp \
    lcd_simulator.cpp \
    pedal_widget.cpp \
    reg_value_widget.cpp \
    simulator_impl.cpp \
    audiogen.cpp \
    audioplayer.cpp \
    tact_button_widget.cpp \
    theremin_sensor_simulator.cpp

HEADERS += \
    ../../theremin_sdk/theremin/src/lcd_screen.h \
    ../../theremin_sdk/common/src/noteutil.h \
    ../../theremin_sdk/common/src/synth_control.h \
    ../../theremin_sdk/synthesizer/src/synthesizer.h \
    encoder_widget.h \
    mainwindow.h \
    lcd_simulator.h \
    pedal_widget.h \
    reg_value_widget.h \
    tact_button_widget.h \
    theremin_sensor_simulator.h \
    audiogen.h \
    audioplayer.h \
    simulator_impl.h

RESOURCES += \
    cora_theremin_sim.qrc

# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target
