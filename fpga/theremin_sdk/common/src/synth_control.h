#ifndef SYNTH_CONTROL_H_INCLUDED
#define SYNTH_CONTROL_H_INCLUDED

#include <stdint.h>


#define SYNTH_CONTROL_PITCH_TABLE_SIZE 1024
#define SYNTH_CONTROL_VOLUME_TABLE_SIZE 1024
#define SYNTH_CONTROL_FILTER_TABLE_SIZE 1024
#define SYNTH_ADDITIVE_MAX_HARMONICS 256

enum SynthType {
    SYNTH_MUTED,
    SYNTH_SINE,
    SYNTH_TRIANGLE,
    SYNTH_SQUARE,
    SYNTH_SAWTOOTH,
    SYNTH_ADDITIVE,
};

struct OscilEffectParams {
    uint16_t offset;
    uint16_t modulation;
    uint16_t phaseIncDiv;
    uint16_t phaseIncAdd;
};

struct SynthControl {
    uint32_t synthType;
    float pitchPeriodFar;
    float pitchPeriodRange;
    float pitchPeriodInvRange;
    float pitchLinearizationK;
    float volumePeriodFar;
    float volumePeriodRange;
    float volumePeriodInvRange;
    float volumeLinearizationK;
    uint16_t pitchPeriodToNoteTable[SYNTH_CONTROL_PITCH_TABLE_SIZE];
    uint16_t volumePeriodToAmpTable[SYNTH_CONTROL_VOLUME_TABLE_SIZE];
    uint32_t minNote;
    uint32_t maxNote;
    uint16_t filterAmp[SYNTH_CONTROL_FILTER_TABLE_SIZE];
    uint16_t additiveHarmonicsAmp[SYNTH_ADDITIVE_MAX_HARMONICS];
    uint16_t additiveHarmonicsPhase[SYNTH_ADDITIVE_MAX_HARMONICS];
    OscilEffectParams ampModulation;
    OscilEffectParams freqModulation;
};

#ifdef THEREMIN_SIMULATOR
typedef volatile SynthControl * synth_control_ptr_t;
#else
typedef SynthControl * synth_control_ptr_t;
#endif

synth_control_ptr_t getSynthControl();


#endif // SYNTH_CONTROL_H_INCLUDED
