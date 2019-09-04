#include "codeutils.h"
#include <QDebug>
#include "simulator_impl.h"


int32_t sin_i24(double phase) {
    double s = sin(phase);
    s *= 0x7fffff;
    return static_cast<int32_t>(s + 0.5);
}

int16_t sin_i16(double phase) {
    double s = sin(phase);
    s *= 0x7fff;
    return static_cast<int16_t>(s + 0.5);
}



#define M_PI 3.14159265359
void generateNoteTables() {
    qDebug("// Note to phase increment linear interpolation table pairs value + diff/64, step = 1/4 of note");
    qDebug("static const float NOTE_FREQ_TABLE[2048] {");
    for (int i = 0; i < 0x10000; i+=256) {
        double freq0 = noteToFrequencyD(i+0*64);
        double freq1 = noteToFrequencyD(i+1*64);
        double freq2 = noteToFrequencyD(i+2*64);
        double freq3 = noteToFrequencyD(i+3*64);
        double freq4 = noteToFrequencyD(i+4*64);
        qDebug("    %ff, %ef, %ff, %ef, %ff, %ef, %ff, %ef, // %d",
               freq0, (freq1-freq0)/64,
               freq1, (freq2-freq1)/64,
               freq2, (freq3-freq2)/64,
               freq3, (freq4-freq3)/64,
               i/256);
    }
    qDebug("};");
    qDebug("");

    qDebug("");
    qDebug("// Note to frequency linear interpolation table pairs value + diff/64, step = 1/4 of note");
    qDebug("static const uint32_t NOTE_PHASE_INC_TABLE[2048] {");
    for (int i = 0; i < 0x10000; i+=256) {
        uint32_t freq0 = noteToPhaseIncrementD(i+0*64);
        uint32_t freq1 = noteToPhaseIncrementD(i+1*64);
        uint32_t freq2 = noteToPhaseIncrementD(i+2*64);
        uint32_t freq3 = noteToPhaseIncrementD(i+3*64);
        uint32_t freq4 = noteToPhaseIncrementD(i+4*64);
        qDebug("    0x%08x, 0x%x, 0x%08x, 0x%x, 0x%08x, 0x%x, 0x%08x, 0x%x, // %d",
               freq0, (freq1-freq0 + 32)/64,
               freq1, (freq2-freq1 + 32)/64,
               freq2, (freq3-freq2 + 32)/64,
               freq3, (freq4-freq3 + 32)/64,
               i/256);
    }
    qDebug("};");
    qDebug("");

    qDebug("");
    qDebug("// Sine interpolation table");
    qDebug("static const float SIN_TABLE_1024[1025] {");
    for (int i = 0; i <= 1024; i+=8) {
        double phi = M_PI * 2 * i / 1024;
        double step = M_PI * 2 / 1024;
        double s0 = sin(phi + step * 0);
        double s1 = sin(phi + step * 1);
        double s2 = sin(phi + step * 2);
        double s3 = sin(phi + step * 3);
        double s4 = sin(phi + step * 4);
        double s5 = sin(phi + step * 5);
        double s6 = sin(phi + step * 6);
        double s7 = sin(phi + step * 7);
        if (i == 1024) {
            qDebug("    %ef, // %d",
                   s0,
                   i
            );
            break;
        }
        qDebug("    %ef, %ef, %ef, %ef, %ef, %ef, %ef, %ef, // %d",
               s0, s1, s2, s3, s4, s5, s7, s7,
               i
        );
    }
    qDebug("};");
    qDebug("");

    qDebug("");
    qDebug("// Sine interpolation table - int24");
    qDebug("static const int32_t SIN_TABLE_1024_I[1025] {");
    for (int i = 0; i <= 1024; i+=8) {
        double phi = M_PI * 2 * i / 1024;
        double step = M_PI * 2 / 1024;
        int32_t s0 = sin_i24(phi + step * 0);
        int32_t s1 = sin_i24(phi + step * 1);
        int32_t s2 = sin_i24(phi + step * 2);
        int32_t s3 = sin_i24(phi + step * 3);
        int32_t s4 = sin_i24(phi + step * 4);
        int32_t s5 = sin_i24(phi + step * 5);
        int32_t s6 = sin_i24(phi + step * 6);
        int32_t s7 = sin_i24(phi + step * 7);
        if (i == 1024) {
            qDebug("    %d, // %d",
                   s0,
                   i
            );
            break;
        }
        qDebug("    %d, %d, %d, %d, %d, %d, %d, %d, // %d",
               s0, s1, s2, s3, s4, s5, s6, s7,
               i
        );
    }
    qDebug("};");
    qDebug("");

    qDebug("");
    qDebug("// Sine interpolation table - int16");
    qDebug("static const int16_t SIN_TABLE_1024_I16[1025] {");
    for (int i = 0; i <= 1024; i+=8) {
        double phi = M_PI * 2 * i / 1024;
        double step = M_PI * 2 / 1024;
        int32_t s0 = sin_i16(phi + step * 0);
        int32_t s1 = sin_i16(phi + step * 1);
        int32_t s2 = sin_i16(phi + step * 2);
        int32_t s3 = sin_i16(phi + step * 3);
        int32_t s4 = sin_i16(phi + step * 4);
        int32_t s5 = sin_i16(phi + step * 5);
        int32_t s6 = sin_i16(phi + step * 6);
        int32_t s7 = sin_i16(phi + step * 7);
        if (i == 1024) {
            qDebug("    %d, // %d",
                   s0,
                   i
            );
            break;
        }
        qDebug("    %d, %d, %d, %d, %d, %d, %d, %d, // %d",
               s0, s1, s2, s3, s4, s5, s6, s7,
               i
        );
    }
    qDebug("};");
    qDebug("");

    qDebug("");
    qDebug("// Harmonic number to note offset table [0] is f0, [1] is f0*2, ...");
    qDebug("static const uint16_t HARMONICS_NOTE_OFFSET_TABLE[SYNTH_ADDITIVE_MAX_HARMONICS] {");
    float f0 = 110.0f;
    int32_t note0 = frequencyToNote(f0);
    for (int i = 0; i < SYNTH_ADDITIVE_MAX_HARMONICS; i+=8) {
        int32_t note1 = frequencyToNote((i+1) * f0) - note0;
        int32_t note2 = frequencyToNote((i+2) * f0) - note0;
        int32_t note3 = frequencyToNote((i+3) * f0) - note0;
        int32_t note4 = frequencyToNote((i+4) * f0) - note0;
        int32_t note5 = frequencyToNote((i+5) * f0) - note0;
        int32_t note6 = frequencyToNote((i+6) * f0) - note0;
        int32_t note7 = frequencyToNote((i+7) * f0) - note0;
        int32_t note8 = frequencyToNote((i+8) * f0) - note0;
        qDebug("    %d, %d, %d, %d, %d, %d, %d, %d, // %d", note1, note2, note3, note4, note5, note6, note7, note8, i);
    }
    qDebug("};");
    qDebug("");

}

