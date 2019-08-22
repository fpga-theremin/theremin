#ifndef SIMULATOR_IMPL_H
#define SIMULATOR_IMPL_H

#include "../../ip_repo/theremin_ip/drivers/theremin_ip/src/theremin_ip.h"
struct audio_sample_t {
    uint32_t left;
    uint32_t right;
    audio_sample_t() : left(0), right(0) {}
    audio_sample_t(const audio_sample_t & v) : left(v.left), right(v.right) {}
    audio_sample_t(uint32_t l, uint32_t r) : left(l), right(r) {}
};

audio_sample_t audioSim_getLineOut();
audio_sample_t audioSim_getPhoneOut();
void audioSim_setLineIn(audio_sample_t sample);

// call audio interrupt handler, return LineOut value as a result
audio_sample_t audioSim_simulateAudioInterrupt();



#endif // SIMULATOR_IMPL_H
