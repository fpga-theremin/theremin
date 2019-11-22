#ifndef PhaseShift_h
#define PhaseShift_h

#include <Arduino.h>

class PhaseShift {
    int8_t _refFreqPin;
    int8_t _shiftedSignalPin;
    uint16_t _refFreqPeriod;
    uint16_t _refFreqPhase;
    uint16_t _averagingBufferSize;
public:
    PhaseShift(int8_t refFreqPin, int8_t shiftedSignalPin);
    // returns 1 if successfully initialized
    int begin(uint16_t refFreqPeriod, uint16_t refFreqPhase, uint16_t averagingBufferSize);
    void end(void);
    static uint16_t frequencyToPeriod(float frequencyHertz);
    void readRegs(uint16_t * values);
	uint16_t getPeriod();
	uint16_t getPhase();
	void setPeriod(uint16_t period, uint16_t phase);
};


#endif

