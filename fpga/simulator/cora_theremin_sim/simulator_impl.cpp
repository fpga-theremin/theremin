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

volatile SynthControl * getSynthControl() {
    return &synthControl;
}

void initSynthControl(volatile SynthControl * control) {
    control->minNote = (8 + 2)*12*256;
    control->maxNote = (8 + 6)*12*256;
    control->pitchPeriodFar = static_cast<float>(DEF_PITCH_MAX_PERIOD);
    float pitchPeriodRange = (static_cast<float>(DEF_PITCH_MIN_PERIOD) - DEF_PITCH_MAX_PERIOD);
    control->pitchPeriodInvRange = 1.0f / pitchPeriodRange;
    control->volumePeriodFar = static_cast<float>(DEF_VOLUME_MAX_PERIOD);
    float volumePeriodRange = (static_cast<float>(DEF_VOLUME_MIN_PERIOD) - DEF_VOLUME_MAX_PERIOD);
    control->volumePeriodInvRange = 1.0f / volumePeriodRange;
    for (int i = 0; i < SYNTH_CONTROL_PITCH_TABLE_SIZE; i++) {
        float period = control->pitchPeriodFar + pitchPeriodRange * i / SYNTH_CONTROL_PITCH_TABLE_SIZE;
        float linear = pitchConv.periodToLinear(period);
        float note = control->minNote + (control->maxNote - control->minNote) * linear;
        control->pitchPeriodToNoteTable[i] = note;
    }
    for (int i = 0; i < SYNTH_CONTROL_VOLUME_TABLE_SIZE; i++) {
        float period = control->volumePeriodFar + volumePeriodRange * i / SYNTH_CONTROL_VOLUME_TABLE_SIZE;
        float linear = volumeConv.periodToLinear(period);
        float amp = linear * linear;
        if (amp > 1.0f)
            amp = 1.0f;
        if (amp < 0.0f)
            amp = 1.0f;
        control->volumePeriodToAmpTable[i] = amp;
    }
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

}


