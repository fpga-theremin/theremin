// Arduino/Teensy4 environment simulation
#ifndef ARDUINO_H_INCLUDED
#define ARDUINO_H_INCLUDED

#include <stdlib.h>
#include <string.h>
#include <math.h>

#define DMAMEM
#define FASTRUN

#define __attribute__(x)

#include "pins_arduino.h"
#include "Print.h"

// fix C++ boolean issue
// https://github.com/arduino/Arduino/pull/2151
#ifdef __cplusplus
typedef bool boolean;
#else
typedef uint8_t boolean;
#endif


#endif //ARDUINO_H_INCLUDED
