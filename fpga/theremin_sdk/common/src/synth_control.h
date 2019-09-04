#ifndef SYNTH_CONTROL_H_INCLUDED
#define SYNTH_CONTROL_H_INCLUDED

#include <stdint.h>


#define SYNTH_CONTROL_PITCH_TABLE_SIZE 1024
#define SYNTH_CONTROL_VOLUME_TABLE_SIZE 1024

struct SynthControl {
    float pitchPeriodFar;
    float pitchPeriodInvRange;
    float volumePeriodFar;
    float volumePeriodInvRange;
    uint16_t pitchPeriodToNoteTable[SYNTH_CONTROL_PITCH_TABLE_SIZE];
    uint16_t volumePeriodToAmpTable[SYNTH_CONTROL_VOLUME_TABLE_SIZE];
    uint32_t minNote;
    uint32_t maxNote;
};

volatile SynthControl * getSynthControl();


#endif // SYNTH_CONTROL_H_INCLUDED
