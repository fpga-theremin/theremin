#include <mutex>
#include "simulator_impl.h"
#include <QTime>
#include "math.h"


extern std::mutex audio_sim_mutex;


std::mutex audio_sim_mutex;

#define AUDIO_GUARD() \
    std::lock_guard<std::mutex> lock(audio_sim_mutex)


SensorConvertor pitchConv(DEF_PITCH_MIN_PERIOD, DEF_PITCH_MAX_PERIOD, 4.5f);
SensorConvertor volumeConv(DEF_VOLUME_MIN_PERIOD, DEF_VOLUME_MAX_PERIOD, 3.9f);


static volatile uint32_t pitchSensorTarget = DEF_PITCH_MAX_PERIOD;
static volatile uint32_t volumeSensorTarget = DEF_VOLUME_MAX_PERIOD;

void sensorSim_setPitchSensorTarget(uint32_t value) {
    pitchSensorTarget = value;
}

void sensorSim_setVolumeSensorTarget(uint32_t value) {
    volumeSensorTarget = value;
}

uint32_t sensorSim_getPitchSensorTarget() {
    return pitchSensorTarget;
}

uint32_t sensorSim_getVolumeSensorTarget() {
    return volumeSensorTarget;
}

// Send reset signal to PL
void thereminIO_resetPL() {

}

volatile static SynthControl synthControl;

synth_control_ptr_t  getSynthControl() {
    return &synthControl;
}

// Init all peripherials
void thereminIO_init() {
    initSynthControl(&synthControl);
}

// Flush CPU cache
void thereminIO_flushCache(void * addr, uint32_t size) {
    Q_UNUSED(addr);
    Q_UNUSED(size);
}

static volatile uint32_t REG_VALUES[16] = {
    0, 0, 0, 0,
    0, 0, 0, 0,
    0, 0, 0, 0,
    0, 0, 0, 0,
};

void sensorSim_setPitchSensor(uint32_t value) {
    REG_VALUES[THEREMIN_RD_REG_PITCH_PERIOD/4] = value;
}
void sensorSim_setVolumeSensor(uint32_t value) {
    REG_VALUES[THEREMIN_RD_REG_VOLUME_PERIOD/4] = value;
}

// Write Theremin IP register value
void thereminIO_writeReg(uint32_t offset, uint32_t value) {
    Q_ASSERT((offset & 3) == 0);
    REG_VALUES[offset / 4] = value;
}


static volatile bool audio_irq_enabled = false;
static void(*audio_irq_handler)() = nullptr;
static volatile audio_sample_t line_out;
static volatile audio_sample_t phones_out;
static volatile audio_sample_t line_in;

audio_sample_t audioSim_getLineOut() {
    return audio_sample_t(line_out.left, line_out.right);
}
audio_sample_t audioSim_getPhoneOut() {
    return audio_sample_t(phones_out.left, phones_out.right);
}

void audioSim_setLineIn(audio_sample_t sample) {
    AUDIO_GUARD();
    line_in.left = sample.left;
    line_in.right = sample.right;
}

/** set audio IRQ handler */
void thereminAudio_setIrqHandler(void(*handler)()) {
    AUDIO_GUARD();
    audio_irq_handler = handler;
}

/** enable audio IRQ */
void thereminAudio_enableIrq() {
    AUDIO_GUARD();
    audio_irq_enabled = true;
}

/** disable audio IRQ */
void thereminAudio_disableIrq() {
    AUDIO_GUARD();
    audio_irq_enabled = false;
}

// Returns pitch sensor output filtered value
uint32_t thereminSensor_readPitchPeriodFiltered() {
    return REG_VALUES[THEREMIN_RD_REG_PITCH_PERIOD/4];
}

// Returns volume sensor output filtered value
uint32_t thereminSensor_readVolumePeriodFiltered() {
    return REG_VALUES[THEREMIN_RD_REG_VOLUME_PERIOD/4];
}

audio_sample_t audioSim_simulateAudioInterrupt(uint32_t pitchSensor, uint32_t volSensor) {
    AUDIO_GUARD();
    REG_VALUES[THEREMIN_RD_REG_PITCH_PERIOD/4] = pitchSensor;
    REG_VALUES[THEREMIN_RD_REG_VOLUME_PERIOD/4] = volSensor;
    if (audio_irq_enabled && audio_irq_handler) {
        audio_irq_handler();
        return audio_sample_t(line_out.left, line_out.right);
    }
    // interrupt is disabled: return 0
    return audio_sample_t();
}


/** read audio status reg
              [31] is audio IRQ enable
              [30] is pending IRQ
           [29:12] is sample count
            [11:0] is subsample count
*/
uint32_t thereminAudio_getStatus() {
    return REG_VALUES[0];
}

/** Write to LineOut left channel */
void thereminAudio_writeLineOutL(uint32_t sample) {
    line_out.left = sample;
}
/** Write to LineOut right channel */
void thereminAudio_writeLineOutR(uint32_t sample) {
    line_out.right = sample;
}
/** Write to LineOut both channels (mono) */
void thereminAudio_writeLineOutLR(uint32_t sample) {
    line_out.left = sample;
    line_out.right = sample;
}
/** Write to PhonesOut left channel */
void thereminAudio_writePhonesOutL(uint32_t sample) {
    phones_out.left = sample;
}
/** Write to PhonesOut right channel */
void thereminAudio_writePhonesOutR(uint32_t sample) {
    phones_out.right = sample;
}
/** Write to PhonesOut both channels (mono) */
void thereminAudio_writePhonesOutLR(uint32_t sample) {
    phones_out.left = sample;
    phones_out.right = sample;
}
/** Read left channel from LineIn */
uint32_t thereminAudio_readLineInL() {
    return line_in.left;
}
/** Read right channel from LineIn */
uint32_t thereminAudio_readLineInR() {
    return line_in.right;
}


// screen buffer SCREEN_DX * SCREEN_DY
pixel_t * SCREEN = nullptr;


// Get LCD framebuffer start address
pixel_t * thereminLCD_getFramebufferAddress() {
    return SCREEN;
}
// Set LCD framebuffer start address (0 to disable)
void thereminLCD_setFramebufferAddress(pixel_t * address) {
    SCREEN = address;
}

static uint32_t screen_backlight = 255;

// set brightness of LCD backlight (0..255)
void thereminIO_setBacklightBrightness(uint32_t brightness) {
    screen_backlight = brightness;
}
// returns current brightness of LCD backlight (0..255)
uint32_t thereminIO_getBacklightBrightness() {
    return screen_backlight & 255;
}

// returns Y coordinate of row which is currently being displayed
uint32_t thereminLCD_getCurrentRowIndex() {
    return SCREEN_DY;
}

#define BUTTON_STATE_TIMER_RATE (1000/32)

struct ButtonState {
    bool pressed;
    QTime timer;
    ButtonState() : pressed(false) {
        timer.start();
    }
    bool setPressed(bool flg) {
        if (pressed == flg)
            return false;
        pressed = flg;
        timer.restart();
        return true;
    }
    uint32_t getButtonState() {
        uint16_t res = 0;
        if (pressed)
            res |= 0x8000;
        int elapsed = timer.elapsed() / BUTTON_STATE_TIMER_RATE; // to 1/10 seconds
        if (elapsed > 127)
            elapsed = 127;
        res |= (static_cast<uint16_t>(elapsed) << 8);
        return res;
    }
};


struct EncoderState : public ButtonState {
    int32_t normalAngle;
    int32_t pressedAngle;
    EncoderState() : ButtonState(), normalAngle(0), pressedAngle(0) {}
    bool updateAngle(int delta) {
        if (!delta)
            return false;
        timer.restart();
        if (pressed)
            pressedAngle = (pressedAngle + delta) & 0x0f;
        else
            normalAngle = (normalAngle + delta) & 0x0f;
        return true;
    }
    uint32_t getEncoderState() {
        uint32_t res = getButtonState();
        res |= ((normalAngle & 0x0f) << 0);
        res |= ((pressedAngle & 0x0f) << 4);
        return res;
    }
};

static ButtonState tactButtonState;
static EncoderState encoderStates[5];

void encodersSim_setEncoderState(int index, bool pressed, int delta) {
    if (index < 0 || index >= 5)
        return;
    encoderStates[index].setPressed(pressed);
    encoderStates[index].updateAngle(delta);
    int reg = 0;
    int shift = 0;
    switch(index) {
    case 0:
        reg = THEREMIN_RD_REG_ENCODER_0;
        shift = 0;
    break;
    case 1:
        reg = THEREMIN_RD_REG_ENCODER_0;
        shift = 1;
    break;
    case 2:
        reg = THEREMIN_RD_REG_ENCODER_1;
        shift = 0;
    break;
    case 3:
        reg = THEREMIN_RD_REG_ENCODER_1;
        shift = 1;
    break;
    case 4:
        reg = THEREMIN_RD_REG_ENCODER_2;
        shift = 0;
    break;
    }
}

void encodersSim_setButtonState(int index, bool pressed) {
    if (index != 0)
        return;
    tactButtonState.setPressed(pressed);
}

static uint16_t pedalValues[6] = {0,0,0,0,0,0};

void pedalSim_setPedalValue(int index, float value) {
    if (index < 0 || index >= 6)
        return;
    int val = static_cast<int>(value * 65535);
    if (val < 0)
        val = 0;
    else if (val > 65535)
        val = 65535;
    pedalValues[index] = static_cast<uint16_t>(val);
}


// Read Theremin IP register value
uint32_t thereminIO_readReg(uint32_t offset) {
    Q_ASSERT((offset & 3) == 0);
    switch(offset) {
    case THEREMIN_RD_REG_ENCODER_0:
        return encoderStates[0].getEncoderState() | (encoderStates[1].getEncoderState() << 16);
    case THEREMIN_RD_REG_ENCODER_1:
        return encoderStates[2].getEncoderState() | (encoderStates[3].getEncoderState() << 16);
    case THEREMIN_RD_REG_ENCODER_2:
        return encoderStates[4].getEncoderState() | (tactButtonState.getButtonState() << 16);
    case THEREMIN_RD_REG_PEDALS_0:
        return pedalValues[0] | (static_cast<uint32_t>(pedalValues[1]) << 16);
    case THEREMIN_RD_REG_PEDALS_1:
        return pedalValues[2] | (static_cast<uint32_t>(pedalValues[3]) << 16);
    case THEREMIN_RD_REG_PEDALS_2:
        return pedalValues[4] | (static_cast<uint32_t>(pedalValues[5]) << 16);

    default:
        return REG_VALUES[offset/4];
    }
}



