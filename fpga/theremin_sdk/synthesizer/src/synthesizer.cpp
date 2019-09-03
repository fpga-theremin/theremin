#include "synthesizer.h"
#include "../../common/src/synth_control.h"
#include "../../common/src/noteutil.h"
#include "theremin_ip.h"

//uint32_t audio_irq_counter = 0;

//float min_note = (8+2)*12*256;
//float max_note = (8+5)*12*256;
//float pitch_minPeriod = 0x35762147;
//float pitch_maxPeriod = 0x393428BA;
//float volume_minPeriod = 0xAB6E2A8B;
//float volume_maxPeriod = 0xB76E32A4;

static uint32_t currentPhase = 0;

void synth_audio_irq() {
    volatile SynthControl * control = getSynthControl();
    uint32_t pitchSensor = thereminSensor_readPitchPeriodFiltered();
    uint32_t volumeSensor = thereminSensor_readVolumePeriodFiltered();
    float pitchScaled = (pitchSensor - control->pitchPeriodFar)*control->pitchPeriodInvRange;
    float volumeScaled = (volumeSensor - control->volumePeriodFar)*control->volumePeriodInvRange;
    int32_t pitch24 = static_cast<int32_t>(pitchScaled * 0x1000000);
    int32_t volume24 = static_cast<int32_t>(volumeScaled * 0x1000000);
    int pindex = pitch24 >> (24-10); // 0..1023
    float note;
    if (pindex < 0)
        note = control->pitchPeriodToNoteTable[0];
    else if (pindex >= 1023)
        note = control->pitchPeriodToNoteTable[1023];
    else {
        float n0 = control->pitchPeriodToNoteTable[pindex];
        float n1 = control->pitchPeriodToNoteTable[pindex + 1];
        float dn = n1 - n0;
        float partn = (pitch24 & 0x3fff) / 16384.0f;
        note = n0 + dn * partn;
    }
    int vindex = volume24 >> (24-10); // 0..1023
    float amp;
    if (vindex < 0)
        amp = control->volumePeriodToAmpTable[0];
    else if (vindex >= 1023)
        amp = control->volumePeriodToAmpTable[1023];
    else {
        float n0 = control->pitchPeriodToNoteTable[pindex];
        float n1 = control->pitchPeriodToNoteTable[pindex + 1];
        float dn = n1 - n0;
        float partn = (volume24 & 0x3fff) / 16384.0f;
        amp = n0 + dn * partn;
    }
    uint32_t phaseIncrement = noteToPhaseIncrementFast(static_cast<uint32_t>(note));
    currentPhase += phaseIncrement;
    float sample = 0;
    // square wave
    if (currentPhase & 0x80000000) {
        sample = 0.5f;
    } else {
        sample = -0.5f;
    }
    sample = sample * amp;
    int32_t sample24 = static_cast<int32_t>(sample * 0x7fffff);
    thereminAudio_writeLineOutLR(sample24);
}
