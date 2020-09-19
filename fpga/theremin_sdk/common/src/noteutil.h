#ifndef NOTEUTIL_H_INCLUDED
#define NOTEUTIL_H_INCLUDED

#include <stdint.h>

#define SAMPLE_RATE 48000.0f

#ifdef __cplusplus
extern "C" {
#endif

// notes (log scale frequency) are 16 bit unsigned values
// upper 8 bits: note (halftone number) equal to midi note number - 7*12 (7 octaves shift)
// lower 8 bits: part of semitone (1/256)


// note to frequency using interpolation table
float noteToFrequencyFast(int32_t note);
// note to phase increment using interpolation table
uint32_t noteToPhaseIncrementFast(int32_t note);


#ifdef __cplusplus
}
#endif


#endif // NOTEUTIL_H_INCLUDED
