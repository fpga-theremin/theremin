#ifndef PhaseShift_h
#define PhaseShift_h

#include <Arduino.h>

class PhaseShift {
    int8_t _refFreqPin;
    int8_t _shiftedSignalPin;
public:
    PhaseShift(int8_t refFreqPin, int8_t shiftedSignalPin);
    void begin();
    void end(void);
};


#endif

