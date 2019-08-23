#include <mutex>
#include "simulator_impl.h"

extern std::mutex audio_sim_mutex;


std::mutex audio_sim_mutex;

#define AUDIO_GUARD() \
    std::lock_guard<std::mutex> lock(audio_sim_mutex)


// Send reset signal to PL
void thereminIO_resetPL() {

}

// Init all peripherials
void thereminIO_init() {

}

// Flush CPU cache
void thereminIO_flushCache(void * addr, uint32_t size) {

}

static uint32_t REG_VALUES[16] = {
    0, 0, 0, 0,
    0, 0, 0, 0,
    0, 0, 0, 0,
    0, 0, 0, 0,
};

// Write Theremin IP register value
void thereminIO_writeReg(uint32_t offset, uint32_t value) {
    REG_VALUES[offset] = value;
}
// Read Theremin IP register value
uint32_t thereminIO_readReg(uint32_t offset) {
    return REG_VALUES[offset];
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

audio_sample_t audioSim_simulateAudioInterrupt() {
    AUDIO_GUARD();
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
