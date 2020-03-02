cmake_minimum_required(VERSION 3.1.0)

project(teensy4_theremin_sim)

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

if(CMAKE_VERSION VERSION_LESS "3.7.0")
    set(CMAKE_INCLUDE_CURRENT_DIR ON)
endif()

find_package(Qt5 COMPONENTS Widgets Multimedia REQUIRED)

add_executable(teensy4_theremin_sim
	arduino/Arduino.h
	arduino/pins_arduino.h
	main.cpp
	mainwindow.cpp
	mainwindow.h
        audiogen.h
        audiogen.cpp
        audioplayer.h
        audioplayer.cpp
        teensy4_theremin_sim.qrc
	lcd_simulator.h
	lcd_simulator.cpp
	pedal_widget.h
	pedal_widget.cpp
	reg_value_widget.h
	reg_value_widget.cpp
	simulator_impl.h
	simulator_impl.cpp
	tact_button_widget.h
	tact_button_widget.cpp
	codeutils.h
	codeutils.cpp
	theremin_sensor_simulator.h
	theremin_sensor_simulator.cpp
	encoder_widget.h
    	encoder_widget.cpp
)

target_link_libraries(teensy4_theremin_sim Qt5::Widgets Qt5::Multimedia)
