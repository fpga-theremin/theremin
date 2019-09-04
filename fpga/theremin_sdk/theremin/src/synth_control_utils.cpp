#ifndef THEREMIN_SIMULATOR
#include "../../common/src/noteutil.cpp"
#endif

#include "synth_control_utils.h"
#include "../../common/src/noteutil.h"
#include <math.h>


#define SCIENTIFIC_NOTATION_A4_FREQUENCY 440.0
// C0 = SCIENTIFIC_NOTATION_A4_FREQUENCY*2^(-4.75)
#define SCIENTIFIC_NOTATION_C0_FREQUENCY 16.3515978313
// C(-1)
#define SCIENTIFIC_NOTATION_C_1_FREQUENCY 8.17579891564
// C(-2)
#define SCIENTIFIC_NOTATION_C_2_FREQUENCY 4.08789945782
// C(-3)
#define SCIENTIFIC_NOTATION_C_3_FREQUENCY 2.04394972891
// C(-4)
#define SCIENTIFIC_NOTATION_C_4_FREQUENCY 1.02197486446
// C(-5)
#define SCIENTIFIC_NOTATION_C_5_FREQUENCY 0.51098743222
// C(-6)  440*2^(-10.75)
#define SCIENTIFIC_NOTATION_C_6_FREQUENCY 0.25549371611
// C(-7)  440*2^(-11.75)
#define SCIENTIFIC_NOTATION_C_7_FREQUENCY 0.12774685805
// C(-8)  440*2^(-12.75)
#define SCIENTIFIC_NOTATION_C_8_FREQUENCY 0.06387342902

#define BASE_C_FREQUENCY SCIENTIFIC_NOTATION_C_8_FREQUENCY

#define OCTAVES_SHIFT (-7)
#define ONE_BY_12 0.08333333333
#define ONE_BY_12_BY_256 0.00032552083333

float noteToFrequency(int32_t note) {
    float n = note * ONE_BY_12_BY_256; // /12.0f;
    float f = BASE_C_FREQUENCY * exp2f(n);
    return f;
}

double noteToFrequencyD(int32_t note) {
    double n = note * ONE_BY_12_BY_256; // /12.0f;
    double f = BASE_C_FREQUENCY * exp2(n);
    return f;
}

int32_t frequencyToNote(float freq) {
    float k = 12 * log2f(freq / BASE_C_FREQUENCY) * 256;
    return static_cast<int32_t>(k + 0.5f);
}

uint32_t noteToPhaseIncrement(int32_t note) {
    float f = noteToFrequency(note);
    float df = f / SAMPLE_RATE;
    if (df >= 0.5f)
        df = 0.5f;
    else if (df < 0.0f)
        df = 0.0f;
    float d = 0x100000000 * df + 0.5f;
    return static_cast<uint32_t>(d);
}

uint32_t noteToPhaseIncrementD(int32_t note) {
    double f = noteToFrequencyD(note);
    double df = f / SAMPLE_RATE;
    if (df >= 0.5)
        df = 0.5;
    else if (df < 0.0)
        df = 0.0;
    double d = 0x100000000 * df + 0.5;
    return static_cast<uint32_t>(d);
}




#define DEF_PITCH_MIN_PERIOD 0x35762147
#define DEF_PITCH_MAX_PERIOD 0x393428BA
#define DEF_VOLUME_MIN_PERIOD 0xAB6E2A8B
#define DEF_VOLUME_MAX_PERIOD 0xB76E32A4


void synthControl_initPitchSensor(synth_control_ptr_t control, uint32_t maxSensorPeriod, uint32_t minSensorPeriod, float linearizationK) {
    control->pitchPeriodFar = static_cast<float>(maxSensorPeriod);
    control->pitchPeriodRange = (static_cast<float>(minSensorPeriod) - maxSensorPeriod);
    control->pitchPeriodInvRange = 1.0f / control->pitchPeriodRange;
    control->pitchLinearizationK = linearizationK;
}

void synthControl_initVolumeSensor(synth_control_ptr_t control, uint32_t maxSensorPeriod, uint32_t minSensorPeriod, float linearizationK) {
    control->volumePeriodFar = static_cast<float>(maxSensorPeriod);
    control->volumePeriodRange = (static_cast<float>(minSensorPeriod) - maxSensorPeriod);
    control->volumePeriodInvRange = 1.0f / control->volumePeriodRange;
    control->volumeLinearizationK = linearizationK;
}

void synthControl_setVolumeRange(synth_control_ptr_t control, float muteDist) {
    SensorConvertor volumeConv(control->volumePeriodFar + control->volumePeriodRange, control->volumePeriodFar, control->volumeLinearizationK);
    for (int i = 0; i < SYNTH_CONTROL_VOLUME_TABLE_SIZE; i++) {
        float period = control->volumePeriodFar + control->volumePeriodRange * i / SYNTH_CONTROL_VOLUME_TABLE_SIZE;
        float linear = 1.0f - volumeConv.periodToLinear(period);
        float amp = linear * linear;
        int32_t ampi = static_cast<int32_t>(amp * 0xffff);
        if (ampi > 0xffff)
            ampi = 0xffff;
        if (ampi < 0)
            ampi = 0;
        control->volumePeriodToAmpTable[i] = static_cast<uint16_t>(ampi);
    }
}

void synthControl_setNoteRange(synth_control_ptr_t control, int32_t minNote, int32_t maxNote) {
    control->minNote = minNote;
    control->maxNote = maxNote;

    SensorConvertor pitchConv(control->pitchPeriodFar + control->pitchPeriodRange, control->pitchPeriodFar, control->pitchLinearizationK);
    for (int i = 0; i < SYNTH_CONTROL_PITCH_TABLE_SIZE; i++) {
        float period = control->pitchPeriodFar + control->pitchPeriodRange * i / SYNTH_CONTROL_PITCH_TABLE_SIZE;
        float linear = pitchConv.periodToLinear(period);
        float note = control->minNote + (control->maxNote - control->minNote) * linear;
        int32_t notei = static_cast<int32_t>(note);
        if (notei < 0)
            notei = 0;
        if (notei > 0xffff)
            notei = 0xffff;
        control->pitchPeriodToNoteTable[i] = static_cast<uint16_t>(notei);
    }
}

void synthControl_setDefautFilter(synth_control_ptr_t control) {
    float filterAmp[SYNTH_CONTROL_FILTER_TABLE_SIZE];
    for (int i = 0; i < SYNTH_CONTROL_FILTER_TABLE_SIZE; i++) {
        int32_t note = i << 6;
        float freq = noteToFrequency(note);
        float boundsK = 1.0f;
        if (freq < 5.0f)
            boundsK = 0.0f;
        else if (freq < 10.0f)
            boundsK = (freq - 5.0f) / (10.0f - 5.0f);
        else if (freq >= 24000.0f)
            boundsK = 0.0f;
        else if (freq >= 20000.0f)
            boundsK = (24000.0f - freq) / (24000.0f - 20000.0f);
        filterAmp[i] = boundsK;
    }
    for (int i = 0; i < SYNTH_CONTROL_FILTER_TABLE_SIZE; i++) {
        float n = filterAmp[i];
        int32_t k = n * 0xffff;
        if (k < 0)
            k = 0;
        else if (k > 0xffff)
            k = 0xffff;
        control->filterAmp[i] = static_cast<uint16_t>(k);
    }
}

void synthControl_setSimpleAdditiveSynth(synth_control_ptr_t control, float evenAmp, float oddAmp, float evenPow, float oddPow, uint32_t phaseInc) {
    control->synthType = SYNTH_ADDITIVE;
    uint32_t phase = 0;
    for (int i = 0; i < SYNTH_ADDITIVE_MAX_HARMONICS; i++) {
        float n = i + 1.0f;
        float k = 0.0f;
        if (i & 1) {
            // odd
            k = oddAmp / powf(n, oddPow);
        } else {
            // even
            k = evenAmp / powf(n, evenPow);
        }
        if (k > 1.0f)
            k = 1.0f;
        if (k < 0.0f)
            k = 0.0f;
        uint16_t ki = static_cast<uint16_t>(k * 0xffff);
        control->additiveHarmonicsAmp[i] = ki;
        control->additiveHarmonicsPhase[i] = phase >> 16;
        phase = phase + phaseInc;
    }
}

void synthControl_setAmpModulation(synth_control_ptr_t control, float amount, float freqAdd, uint16_t freqDiv) {
    // amp modulation
    uint16_t ampModulationAmount = static_cast<uint16_t>(0xffff * amount); //0x3fff;
    control->ampModulation.offset = 0xffff - ampModulationAmount;
    control->ampModulation.modulation = ampModulationAmount;
    control->ampModulation.phaseIncAdd = freqAdd > 1.0f ? noteToPhaseIncrementFast(frequencyToNote(freqAdd)) : 0;
    control->ampModulation.phaseIncDiv = freqDiv;
}

void synthControl_setFreqModulation(synth_control_ptr_t control, float amount, float freqAdd, uint16_t freqDiv) {
    // freq modulation
    control->freqModulation.offset = 0;
    control->freqModulation.modulation = static_cast<uint16_t>(0xffff * amount);
    control->freqModulation.phaseIncAdd = freqAdd > 1.0f ? noteToPhaseIncrementFast(frequencyToNote(freqAdd)) : 0;
    control->freqModulation.phaseIncDiv = freqDiv;
}

void synthControl_setAdditiveSquare(synth_control_ptr_t control, float amp) {
    synthControl_setSimpleAdditiveSynth(control,
                                        amp, 0.0f, 1.0f, 1.0f, 0x80000000);
}

void synthControl_setAdditiveTriangle(synth_control_ptr_t control, float amp) {
//    synthControl_setSimpleAdditiveSynth(control,
//                                        amp, amp, 2.0f, 2.0f, 0x80000000);
    synthControl_setSimpleAdditiveSynth(control,
                                        amp, 0, 2.0f, 2.0f, 0x40000000);
}

void synthControl_setAdditiveSawtooth(synth_control_ptr_t control, float amp) {
    synthControl_setSimpleAdditiveSynth(control,
                                        amp, amp, 1.0f, 1.0f, 0x00000000);
}

void initSynthControl(synth_control_ptr_t control) {
    //control->synthType = SYNTH_TRIANGLE; //SYNTH_ADDITIVE;
    control->synthType = SYNTH_ADDITIVE;

    synthControl_initPitchSensor(control, DEF_PITCH_MAX_PERIOD, DEF_PITCH_MIN_PERIOD, 4.5f);

    synthControl_initVolumeSensor(control, DEF_VOLUME_MAX_PERIOD, DEF_VOLUME_MIN_PERIOD, 3.9f);

    synthControl_setNoteRange(control, (8 + 2)*12*256, (8 + 6)*12*256);

    synthControl_setVolumeRange(control, 0.1f);

    synthControl_setDefautFilter(control);

    //synthControl_setAdditiveSquare(control,  0.5f);
    synthControl_setAdditiveTriangle(control,  0.8f);
    synthControl_setAdditiveSawtooth(control,  0.5f);

    synthControl_setAmpModulation(control, 0.0f, 4.5678f, 13);
    synthControl_setFreqModulation(control, 0.0f, 5.9789f, 11);
}

#define toFloat(x) static_cast<float>(x)

// using exp range (0..k1) <-> (1..exp(k1))
SensorConvertor::SensorConvertor(uint32_t minv, uint32_t maxv, float linK1)
    : minValue(minv), maxValue(maxv), k1(linK1)
{
    expk1 = toFloat(exp(k1));
    updateTables();
}

void SensorConvertor::setLinK(float linK1) {
    k1 = linK1;
    updateTables();
}

void SensorConvertor::setRange(uint32_t minv, uint32_t maxv) {
    minValue = minv;
    maxValue = maxv;
    updateTables();
}

void SensorConvertor::updateTables() {
    expk1 = expf(k1);
    invK1 = 1.0f / k1;
    expkDiff = expk1 - 1.0f;
    invExpkDiff = 1.0f / expkDiff;
    valueRange = static_cast<int32_t>(minValue - maxValue);
    invValueRange = 1.0f / valueRange;
}


uint32_t SensorConvertor::linearToPeriod(float v) {
    // v is 0..1 (0 is far, 1 is near)
    if (v < -0.1f)
        v = -0.1f;
    else if (v > 1.1f)
        v = 1.1f;
    //// convert 0..1 to expk0..expk1
    // convert 0..1 to 0..k1
    v = v * k1;
    //v = v * (expk1-expk0) + expk0;
    // convert 0..k1 to exp(0)..exp(k1)
    v = expf(v);
    // convert exp(0)..exp(k1) to 0..1
    v = (v - 1.0f) * invExpkDiff;
    // convert 0..1 to maxPeriod..minPeriod
    int32_t n = maxValue + static_cast<int32_t>(v * valueRange); // valueRange == (toFloat(minValue) - toFloat(maxValue));
    return static_cast<uint32_t>(n);
}

float SensorConvertor::periodToLinear(uint32_t periodValue) {
    // convert maxPeriod..minPeriod to 0..1
    float n = static_cast<int32_t>(periodValue - maxValue) * invValueRange;
//    if (n < -0.05f)
//        n = -0.05f;
//    else if (n > 1.05f)
//        n = 1.05f;
    // convert 0..1 to exp(0)..exp(k1)
    float v = 1.0f + n * expkDiff;

    // ensure v is > 0
    if (v < 0.000001f)
        v = 0.000001f;

    // convert exp(0)..exp(k1) to 0..k1
    v = logf(v);
    // convert 0..k1 to 0..1
    v = (v) * invK1;
//    if (v < -0.05f)
//        v = -0.05f;
//    else if (v > 1.05f)
//        v = 1.05f;
    return v;
}

