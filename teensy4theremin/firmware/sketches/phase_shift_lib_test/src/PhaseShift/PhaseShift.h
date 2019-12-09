#ifndef PhaseShift_h
#define PhaseShift_h

#include <Arduino.h>

// positions of two signal edges
struct Edges {
    uint16_t raising;
    uint16_t falling;
    Edges() : raising(0), falling(0) {}
    Edges(uint16_t r, uint16_t f) : raising(r), falling(f) {}
};

class PhaseShift {
    int8_t _refFreqPin;
    int8_t _shiftedSignalPin;
    uint16_t _refFreqPeriod;
    uint16_t _refFreqPhase;
    uint16_t _averagingBufferSize;
    volatile Edges * _dmabuf;
    uint8_t _bufSizeLog2;
public:
    PhaseShift(int8_t refFreqPin, int8_t shiftedSignalPin);
    // returns 1 if successfully initialized
    int begin(uint16_t refFreqPeriod, uint16_t refFreqPhase, uint16_t averagingBufferSize);
    int setupDMA(volatile Edges * bufptr, uint8_t sizeLog2);
    void end(void);
    static uint16_t frequencyToPeriod(float frequencyHertz);
    void readRegs(uint16_t * values);
    uint16_t getPeriod();
    uint16_t getPhase();
    void setPeriod(uint16_t period, uint16_t phase);
    // wait for next captured value and return it
    Edges poll();    
};


#endif

