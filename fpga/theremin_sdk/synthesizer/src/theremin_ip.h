
#ifndef THEREMIN_IP_H
#define THEREMIN_IP_H

#include "xparameters.h"
#include <stdint.h>

#define THEREMIN_REG_AUDIO_STATUS_INTERRUPT_ENABLED_FLAG 0x80000000
#define THEREMIN_REG_AUDIO_STATUS_INTERRUPT_PENDING_FLAG 0x40000000
#define THEREMIN_REG_STATUS_IIR_STAGES_MASK        0x38000000
#define THEREMIN_REG_STATUS_IIR_STAGES_SHIFT       27

enum reg_rd_addr_t {
    THEREMIN_RD_REG_STATUS = 0*4,
    THEREMIN_RD_REG_PITCH_PERIOD = 1*4,
    THEREMIN_RD_REG_VOLUME_PERIOD = 2*4,
    THEREMIN_RD_REG_ENCODER_0 = 3*4,
    THEREMIN_RD_REG_LINE_IN_L = 4*4,
    THEREMIN_RD_REG_LINE_IN_R = 5*4,
    THEREMIN_RD_REG_ENCODER_1 = 6*4,
    THEREMIN_RD_REG_ENCODER_2 = 7*4,
    THEREMIN_RD_REG_AUDIO_I2C = 8*4,
    THEREMIN_RD_REG_TOUCH_I2C = 9*4,
    THEREMIN_RD_REG_LCD_CONTROL = 10*4,
    THEREMIN_RD_REG_AUDIO_STATUS = 12*4
};

enum reg_wr_addr_t {
    THEREMIN_WR_REG_STATUS = 0*4,
    THEREMIN_WR_REG_LCD_FRAMEBUFFER_ADDR = 1*4,
    THEREMIN_WR_REG_PWM = 2*4,
    THEREMIN_WR_REG_LINE_OUT_L = 4*4,
    THEREMIN_WR_REG_LINE_OUT_R = 5*4,
    THEREMIN_WR_REG_PHONES_OUT_L = 6*4,
    THEREMIN_WR_REG_PHONES_OUT_R = 7*4,
    THEREMIN_WR_REG_AUDIO_I2C = 8*4,
    THEREMIN_WR_REG_TOUCH_I2C = 9*4,
    THEREMIN_WR_REG_LCD_CONTROL = 10*4,
    THEREMIN_WR_REG_AUDIO_STATUS = 12*4
};

#ifdef __cplusplus
extern "C" {
#endif

// Send reset signal to PL
void thereminIO_resetPL();

// Init all peripherials
void thereminIO_init();

// Flush CPU cache
void thereminIO_flushCache(void * addr, uint32_t size);

// Write Theremin IP register value
void thereminIO_writeReg(uint32_t offset, uint32_t value);
// Read Theremin IP register value
uint32_t thereminIO_readReg(uint32_t offset);

/*
    Audio interface.
*/

/** set audio IRQ handler */
void thereminAudio_setIrqHandler(void(*handler)());
/** enable audio IRQ */
void thereminAudio_enableIrq();
/** disable audio IRQ */
void thereminAudio_disableIrq();
/** read audio status reg 
              [31] is audio IRQ enable 
              [30] is pending IRQ
           [29:12] is sample count
            [11:0] is subsample count
*/
uint32_t thereminAudio_getStatus();

/** Write to LineOut left channel */
void thereminAudio_writeLineOutL(uint32_t sample);
/** Write to LineOut right channel */
void thereminAudio_writeLineOutR(uint32_t sample);
/** Write to LineOut both channels (mono) */
void thereminAudio_writeLineOutLR(uint32_t sample);
/** Write to PhonesOut left channel */
void thereminAudio_writePhonesOutL(uint32_t sample);
/** Write to PhonesOut right channel */
void thereminAudio_writePhonesOutR(uint32_t sample);
/** Write to PhonesOut both channels (mono) */
void thereminAudio_writePhonesOutLR(uint32_t sample);
/** Read left channel from LineIn */
uint32_t thereminAudio_readLineInL();
/** Read right channel from LineIn */
uint32_t thereminAudio_readLineInR();

/*
    Theremin Sensor.
*/

// Set number of stages for theremin sensor IIR filter (2..8)
void thereminSensor_setIIRFilterStages(uint32_t numberOfStages);
// Returns pitch sensor output filtered value
uint32_t thereminSensor_readPitchPeriodFiltered();
// Returns volume sensor output filtered value
uint32_t thereminSensor_readVolumePeriodFiltered();

/*
    LCD Controller.
*/


// Get LCD framebuffer start address
uint16_t * thereminLCD_getFramebufferAddress();
// Set LCD framebuffer start address (0 to disable)
void thereminLCD_setFramebufferAddress(uint16_t * address);

// set brightness of LCD backlight (0..255)
void thereminIO_setBacklightBrightness(uint32_t brightness);
// returns current brightness of LCD backlight (0..255)
uint32_t thereminIO_getBacklightBrightness();

// returns Y coordinate of row which is currently being displayed
uint32_t thereminLCD_getCurrentRowIndex();

/*
    Cora Z7 on-board RGB LEDs.
*/

// set color of Cora Z7 on-board LED0
void thereminIO_setLed0Color(uint32_t color);
// set color of Cora Z7 on-board LED1
void thereminIO_setLed1Color(uint32_t color);



#ifdef __cplusplus
}
#endif

#endif // THEREMIN_IP_H
