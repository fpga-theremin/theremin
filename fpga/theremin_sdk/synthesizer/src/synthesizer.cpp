#include "synthesizer.h"
#include "synth_utils.h"
#include "../../common/src/synth_control.h"
#include "../../common/src/noteutil.h"
#include "theremin_ip.h"

//#include <QDebug>

//uint32_t audio_irq_counter = 0;

//float min_note = (8+2)*12*256;
//float max_note = (8+5)*12*256;
//float pitch_minPeriod = 0x35762147;
//float pitch_maxPeriod = 0x393428BA;
//float volume_minPeriod = 0xAB6E2A8B;
//float volume_maxPeriod = 0xB76E32A4;

static uint32_t currentPhase = 0;
static int dumpCount = 0;

void synth_audio_irq() {
    volatile SynthControl * control = getSynthControl();
    uint32_t pitchSensor = thereminSensor_readPitchPeriodFiltered();
    uint32_t volumeSensor = thereminSensor_readVolumePeriodFiltered();
    float pitchScaled = (pitchSensor - control->pitchPeriodFar)*control->pitchPeriodInvRange;
    float volumeScaled = (volumeSensor - control->volumePeriodFar)*control->volumePeriodInvRange;
    int32_t pitch24 = static_cast<int32_t>(pitchScaled * 0x1000000);
    int32_t volume24 = static_cast<int32_t>(volumeScaled * 0x1000000);
    int pindex = pitch24 >> (24-10); // 0..1023
    int32_t note;
    if (pindex < 0)
        note = control->pitchPeriodToNoteTable[0];
    else if (pindex >= 1023)
        note = control->pitchPeriodToNoteTable[1023];
    else {
        int32_t n0 = control->pitchPeriodToNoteTable[pindex];
        int32_t n1 = control->pitchPeriodToNoteTable[pindex + 1];
        int32_t partn = ((n1 - n0) * (volume24 & 0x3fff)) >> 14;
        note = n0 + partn;
    }
    int vindex = volume24 >> (24-10); // 0..1023
    int32_t amp;
    if (vindex < 0)
        amp = control->volumePeriodToAmpTable[0];
    else if (vindex >= 1023)
        amp = control->volumePeriodToAmpTable[1023];
    else {
        int32_t n0 = control->volumePeriodToAmpTable[vindex];
        int32_t n1 = control->volumePeriodToAmpTable[vindex + 1];
        int32_t partn = ((n1 - n0) * (volume24 & 0x3fff)) >> 14;
        amp = n0 + partn;
    }
    // amp is 16 bit unsigned, 0x0000..0xffff
    uint32_t phaseIncrement = noteToPhaseIncrementFast(note);
    currentPhase += phaseIncrement;
    //float sample = 0;
    // square wave
//    if (currentPhase & 0x80000000) {
//        sample = 0.5f;
//    } else {
//        sample = -0.5f;
//    }
    // sample 16 bit: +-0x7fff
    int32_t sample = phaseSin_i16(currentPhase); // * (1.0f / 0x7fffff);
    //sample = phaseSin(currentPhase);
    //amp = amp * 0.1f;
    amp = amp >> 1;

    // 16*16bit >> 8 = 24 bits signed sample
    sample = (sample * amp) >> 8;
    //int32_t sample24 = static_cast<int32_t>(sample * 0x7fffff);
    //int32_t sample24 = static_cast<int32_t>(sample);
    //if (dumpCount < 2000) {
        //qDebug("%d: %08x   phase=%08x phaseIncrement=%08x  amp=%f", dumpCount, sample24, currentPhase, phaseIncrement, amp);
    //    dumpCount++;
    //}
    thereminAudio_writeLineOutLR(sample);
}
