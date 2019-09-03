#ifndef SYNTH_UTILS_H_INCLUDED
#define SYNTH_UTILS_H_INCLUDED

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

// sin() for 32-bit phase arg (using interpolation table)
float phaseSin(uint32_t phase);

#ifdef __cplusplus
}
#endif


#endif
