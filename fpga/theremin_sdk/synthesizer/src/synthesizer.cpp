#ifndef THEREMIN_SIMULATOR
#include "../../common/src/noteutil.cpp"
#endif


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
static uint32_t ampModulationPhase = 0;
static uint32_t freqModulationPhase = 0;
static uint32_t additivePhases[256] = {
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
};

uint16_t ampModulation(synth_control_ptr_t control, uint32_t phaseInc) {
    int32_t modulation = control->ampModulation.modulation;
    int32_t offset = control->ampModulation.offset;
    if (!modulation)
        return offset;
    uint32_t inc = control->ampModulation.phaseIncAdd;
    uint32_t div = control->ampModulation.phaseIncDiv;
    if (div)
        inc += phaseInc / div;
    ampModulationPhase += inc;
    int32_t s = phaseSin_i16(ampModulationPhase);
    s = (s * modulation) >> 16;
    s = s + offset;
    return static_cast<uint16_t>(s);
}

// modulate phase increment
uint32_t freqModulation(synth_control_ptr_t control, uint32_t phaseInc) {
    int32_t modulation = control->freqModulation.modulation;
    if (!modulation)
        return phaseInc;
    uint32_t inc = control->ampModulation.phaseIncAdd;
    uint32_t div = control->ampModulation.phaseIncDiv;
    if (div)
        inc += phaseInc / div;
    freqModulationPhase += inc;
    int32_t s = phaseSin_i16(freqModulationPhase);
    modulation = static_cast<uint32_t>((static_cast<uint64_t>(phaseInc) * modulation) >> 16);
    s = (s * modulation) >> 16;
    return static_cast<uint32_t>(s + phaseInc);
}

int32_t additiveSynth(synth_control_ptr_t control, int32_t note0, uint32_t phaseInc0) {
    int32_t sum = 0;
    for (int i = 0; i < SYNTH_ADDITIVE_MAX_HARMONICS; i++) {
        int32_t note = note0 + harmonicNoteOffset(i + 1);
        if (note >= MAX_AUDIBLE_NOTE)
            break;
        uint32_t phaseInc = phaseInc0 * (i+1);
        uint32_t phase = additivePhases[i];
        additivePhases[i] = phase + phaseInc;
        uint32_t amp = control->additiveHarmonicsAmp[i];

        //if (amp == 0 && i > 5)
        //    break;
        phase += static_cast<uint32_t>(control->additiveHarmonicsPhase[i]) << 16;
        // apply filter
        uint32_t filterAmp = 0;
        int vindex = note >> 6;
        if (vindex > 0 && vindex < 1023) {
            int32_t n0 = control->filterAmp[vindex];
            int32_t n1 = control->filterAmp[vindex + 1];
            int32_t part = note & 0x3f;
            int32_t diff = ((n1 - n0) * part) >> 6;
            filterAmp = static_cast<uint32_t>(n0 + diff);
        }
        if (!filterAmp)
            continue;
        amp = (amp * filterAmp) >> 16;
        if (amp < 3)
            continue;
        int32_t sample = phaseSin_i16(phase); // * (1.0f / 0x7fffff);
        sample = (sample * static_cast<int32_t>(amp)) >> 16;
        sum += sample;
    }
    return sum;
}

float additiveSynthF(synth_control_ptr_t control, int32_t note0, uint32_t phaseInc0) {
    float sum = 0;
    for (int i = 0; i < SYNTH_ADDITIVE_MAX_HARMONICS; i++) {
        int32_t note = note0 + harmonicNoteOffset(i + 1);
        if (note >= MAX_AUDIBLE_NOTE)
            break;
        uint32_t phaseInc = phaseInc0 * (i+1);
        uint32_t phase = additivePhases[i];
        additivePhases[i] = phase + phaseInc;
        uint32_t amp = control->additiveHarmonicsAmp[i];

        //if (amp == 0 && i > 5)
        //    break;
        phase += static_cast<uint32_t>(control->additiveHarmonicsPhase[i]) << 16;
        // apply filter
        uint32_t filterAmp = 0;
        int vindex = note >> 6;
        if (vindex > 0 && vindex < 1023) {
            int32_t n0 = control->filterAmp[vindex];
            int32_t n1 = control->filterAmp[vindex + 1];
            int32_t part = note & 0x3f;
            int32_t diff = ((n1 - n0) * part) >> 6;
            filterAmp = static_cast<uint32_t>(n0 + diff);
        }
        if (!filterAmp)
            continue;
        amp = (amp * filterAmp) >> 16;
        if (amp < 3)
            continue;
        float sample = phaseSin_i16(phase); // * (1.0f / 0x7fffff);
        sample = (sample * amp) / 0x10000;
        sum += sample;
    }
    return sum;
}


void synth_audio_irq() {
    synth_control_ptr_t control = getSynthControl();
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

    phaseIncrement = freqModulation(control, phaseIncrement);

    currentPhase += phaseIncrement;
    //float sample = 0;
    // square wave
//    if (currentPhase & 0x80000000) {
//        sample = 0.5f;
//    } else {
//        sample = -0.5f;
//    }
    // sample 16 bit: +-0x7fff
    float sample = 0;
    switch (control->synthType) {
    default:
    case SYNTH_MUTED:
        // silence
        break;
    case SYNTH_SINE:
        sample = phaseSin_i16(currentPhase); // * (1.0f / 0x7fffff);
        break;
    case SYNTH_TRIANGLE:
        sample = phaseTriangle_i16(currentPhase);
        break;
    case SYNTH_SAWTOOTH:
        sample = phaseSawtooth_i16(currentPhase);
        break;
    case SYNTH_SQUARE:
        sample = static_cast<float>((currentPhase & 0x80000000) ? 0x7fff : -0x7fff);
        amp = amp >> 2;
        break;
    case SYNTH_ADDITIVE:
        sample = additiveSynthF(control, note, phaseIncrement);
        break;
    }

    uint32_t ampMod = ampModulation(control, phaseIncrement);
    amp = (amp * ampMod) >> 16;

    //sample = phaseSin(currentPhase);
    //amp = amp * 0.1f;
    amp = amp >> 1;

    // 16*16bit >> 8 = 24 bits signed sample
    sample = (sample * amp) / 256;
    //int32_t sample24 = static_cast<int32_t>(sample * 0x7fffff);
    //int32_t sample24 = static_cast<int32_t>(sample);
//    if (dumpCount < 2000) {
//        //qDebug("%d: \t%f\t   phase=%08x phaseIncrement=%08x  amp=%f", dumpCount, sample/256, currentPhase, phaseIncrement, amp);
//        qDebug("%f", sample);
//        dumpCount++;
//    }


    thereminAudio_writeLineOutLR( static_cast<int32_t>(sample));
}
