
#ifndef THEREMIN_IP_H
#define THEREMIN_IP_H

#include "xparameters.h"
#include <stdint.h>

#define SCREEN_DX 800
#define SCREEN_DY 480

#define THEREMIN_REG_STATUS_INTERRUPT_ENABLED_FLAG 0x80000000
#define THEREMIN_REG_STATUS_INTERRUPT_PENDING_FLAG 0x40000000

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
	THEREMIN_RD_REG_TOUCH_I2C = 9*4
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
	THEREMIN_WR_REG_TOUCH_I2C = 9*4
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


typedef uint16_t pixel_t;

// screen buffer SCREEN_DX * SCREEN_DY
extern pixel_t * SCREEN;


// Get LCD framebuffer start address
pixel_t * thereminLCD_getFramebufferAddress();
// Set LCD framebuffer start address (0 to disable)
void thereminLCD_setFramebufferAddress(pixel_t * address);

// set brightness of LCD backlight (0..255)
void thereminIO_setBacklightBrightness(uint32_t brightness);
// returns current brightness of LCD backlight (0..255)
uint32_t thereminIO_getBacklightBrightness();

// set color of Cora Z7 on-board LED0
void thereminIO_setLed0Color(uint32_t color);
// set color of Cora Z7 on-board LED1
void thereminIO_setLed1Color(uint32_t color);


// returns Y coordinate of row which is currently being displayed
uint32_t thereminLCD_getCurrentRowIndex();

#ifdef __cplusplus
}
#endif

#endif // THEREMIN_IP_H
