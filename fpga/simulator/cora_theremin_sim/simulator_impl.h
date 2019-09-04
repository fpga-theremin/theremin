#ifndef SIMULATOR_IMPL_H
#define SIMULATOR_IMPL_H

#include "../../ip_repo/theremin_ip/drivers/theremin_ip/src/theremin_ip.h"
#include "../../theremin_sdk/common/src/noteutil.h"
#include "../../theremin_sdk/common/src/synth_control.h"
#include "../../theremin_sdk/theremin/src/synth_control_utils.h"


struct audio_sample_t {
    uint32_t left;
    uint32_t right;
    audio_sample_t() : left(0), right(0) {}
    audio_sample_t(const audio_sample_t & v) : left(v.left), right(v.right) {}
    audio_sample_t(uint32_t l, uint32_t r) : left(l), right(r) {}
};

void sensorSim_setPitchSensor(uint32_t value);
void sensorSim_setVolumeSensor(uint32_t value);

void sensorSim_setPitchSensorTarget(uint32_t value);
void sensorSim_setVolumeSensorTarget(uint32_t value);
uint32_t sensorSim_getPitchSensorTarget();
uint32_t sensorSim_getVolumeSensorTarget();

audio_sample_t audioSim_getLineOut();
audio_sample_t audioSim_getPhoneOut();
void audioSim_setLineIn(audio_sample_t sample);

// call audio interrupt handler, return LineOut value as a result
audio_sample_t audioSim_simulateAudioInterrupt(uint32_t pitchSensor, uint32_t volSensor);

void encodersSim_setEncoderState(int index, bool pressed, int deltaAngle);
void encodersSim_setButtonState(int index, bool pressed);

#define THEREMIN_RD_REG_PEDALS_0 (13*4)
#define THEREMIN_RD_REG_PEDALS_1 (14*4)
#define THEREMIN_RD_REG_PEDALS_2 (15*4)
void pedalSim_setPedalValue(int index, float value);

#define DEF_PITCH_MIN_PERIOD 0x35762147
#define DEF_PITCH_MAX_PERIOD 0x393428BA
#define DEF_VOLUME_MIN_PERIOD 0xAB6E2A8B
#define DEF_VOLUME_MAX_PERIOD 0xB76E32A4




extern SensorConvertor pitchConv;
extern SensorConvertor volumeConv;

#endif // SIMULATOR_IMPL_H
