#ifndef SYNTH_UTILS_H_INCLUDED
#define SYNTH_UTILS_H_INCLUDED

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

// sin() for 32-bit phase arg (using interpolation table) - returns float value -1.0f..1.0f
float phaseSin(uint32_t phase);
// sin() for 32-bit phase arg (using interpolation table) - returns 24-bit value in range -0x7fffff..7fffff
int32_t phaseSin_i24(uint32_t phase);
// sin() for 32-bit phase arg (using interpolation table) - returns 16-bit value in range -0x7fff..7fff
int16_t phaseSin_i16(uint32_t phase);

#ifdef __cplusplus
}
#endif


#endif
