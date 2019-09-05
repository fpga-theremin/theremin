/*
 * Empty C++ Application
 */

#include "theremin_ip.h"



#include "xil_types.h"
#include "xstatus.h"
#include <xscugic.h>
#include <sleep.h>
#include <xil_io.h>
#include <xil_misc_psreset_api.h>
#include "xil_cache.h"
#include "xil_cache_l.h"

#include "xpseudo_asm.h"
#include "xil_mmu.h"
#include "lcd_screen.h"
#include "bitmap_fonts.h"

//uint16_t framebuffer[SCREEN_DX*SCREEN_DY + 64]  __attribute__ ((aligned(32)));

void setLeds(int phase) {
	switch(phase & 7) {
	default:
	case 0:
		thereminIO_setLed0Color(0x8000ff);
		break;
	case 1:
		thereminIO_setLed0Color(0x404080);
		break;
	case 2:
		thereminIO_setLed0Color(0x408080);
		break;
	case 3:
		thereminIO_setLed0Color(0xff8080);
		break;
	case 4:
		thereminIO_setLed0Color(0xff8080);
		break;
	case 5:
		thereminIO_setLed0Color(0xcf4040);
		break;
	case 6:
		thereminIO_setLed0Color(0x8f2020);
		break;
	case 7:
		thereminIO_setLed0Color(0x4f1010);
		break;
	}
}

void setLCDColor(uint32_t value) {
	thereminIO_writeReg(THEREMIN_WR_REG_LCD_CONTROL, 0x80000000|value);
}

// AMP3 PMOD JP6 loaded
#define AMP3_I2C_ADDRESS 0x34
// AMP3 PMOD JP6 unloaded
//#define AMP3_I2C_ADDRESS 0x36
#define I2C_STATUS_BIT_READY 0x100
#define I2C_STATUS_BIT_ERROR 0x200

void thereminAudio_i2cWrite(uint8_t addr, uint8_t data) {
	//
}

uint32_t thereminAudio_i2cRead(uint8_t reg) {

	uint32_t status = thereminIO_readReg(THEREMIN_RD_REG_AUDIO_I2C);
	while ( !(status & I2C_STATUS_BIT_READY) ) {
		xil_printf("i2c status is %3x - waiting for ready state\r\n", status);
		usleep(500000);
		status = thereminIO_readReg(THEREMIN_RD_REG_AUDIO_I2C);
	}
	uint32_t command = 0x000000; // read
	command |= AMP3_I2C_ADDRESS << 16;
	command |= ((uint32_t)reg) << 8;
	thereminIO_writeReg(THEREMIN_WR_REG_AUDIO_I2C, command);
	status = thereminIO_readReg(THEREMIN_RD_REG_AUDIO_I2C);
	while ( !(status & I2C_STATUS_BIT_READY) ) {
		status = thereminIO_readReg(THEREMIN_RD_REG_AUDIO_I2C);
	}
	xil_printf("i2c status is %3x\r\n", status);
	return status & 0xff;
}

#define THEREMIN_RD_REG_ENCODERS_RAW (11*4)

uint32_t readEncodersManual() {
	uint32_t res = 0;
	for (int i = 0; i < 16; i++) {
		thereminIO_writeReg(THEREMIN_RD_REG_ENCODERS_RAW, i);
		usleep(150000);
		res = (res << 1) | (thereminIO_readReg(THEREMIN_RD_REG_ENCODERS_RAW) & 1);
	}
	return res;
}

int main()
{
	print("FPGA Theremin Project\r\n");
	sleep(1);
	print("FPGA Theremin Project\r\n");
	print("(c) Vadim Lopatin, 2019\r\n");
	print("Resetting PL\r\n");
	thereminIO_init();
	//setLeds(0);
	print("    Done\r\n");
	usleep(1000);

	lcd_init();
    lcd_fill_rect(6, 5, 120, 50, 0x0f84);
    lcd_fill_rect(5, 55, 121, 100, 0x058e);


    for (int x = 50; x < SCREEN_DX; x+=5) {
        lcd_draw_line(5, 5, x, SCREEN_DY-1, 0x305020);
    }

    lcd_draw_text(BIG_FONT, 100, 50, 0xff0, "Hello world! BIG", -32768);
    lcd_draw_text(MEDIUM_FONT, 10, 10, 0x0f0, "Hello world! MEDIUM", -32768);
    lcd_draw_text(SMALL_FONT, 10, 200, 0x0ff, "Hello world! SMALL", -32768);

    lcd_draw_text(BIG_FONT, 100, 80, 0xfff, "WWWwww", -32768);

    lcd_draw_rect(400, 50, 500, 100, 5, CL_RED, CL_YELLOW);
    lcd_draw_rect(450, 70, 550, 120, 7, CL_BLUE, CL_TRANSPARENT);

    for (int i = 0; i < SCREEN_DX; i++) {
    	SCREEN[i] = 0xff0;
    	SCREEN[i+SCREEN_DX] = 0xf0f;
    	SCREEN[i+SCREEN_DX*2] = 0x0ff;
    }

    lcd_flush();
	//thereminIO_flushCache(framebuffer, SCREEN_DX*SCREEN_DX*2);
	//xil_printf("Setting framebuffer address to %08x\r\n", framebuffer);
	//thereminLCD_setFramebufferAddress(framebuffer);
	thereminIO_setBacklightBrightness(0x40);
	print("    Done\r\n");
	usleep(10000);

	for (int i = 0; i < 16; i++) {
		xil_printf("REG[%d] = %08x\r\n", i, thereminIO_readReg(i*4));
	}

	xil_printf("i2c reg 0 = %2x \r\n", thereminAudio_i2cRead(0));
	xil_printf("i2c reg 2 = %2x \r\n", thereminAudio_i2cRead(2));

	//thereminIO_setLed0Color(0x8000ff);
	//thereminIO_setLed1Color(0x000020);
	uint32_t prevEnc0 = thereminIO_readReg(THEREMIN_RD_REG_ENCODER_0);
	uint32_t prevEnc1 = thereminIO_readReg(THEREMIN_RD_REG_ENCODER_1);
	uint32_t prevEnc2 = thereminIO_readReg(THEREMIN_RD_REG_ENCODER_2);
	uint32_t prevEncRaw = 0; //thereminIO_readReg(10) & 0xffff;

	int phase = 0;
	for (;;) {
		//print("readreg: ");
		uint32_t rowIndex = thereminLCD_getCurrentRowIndex();
//		xil_printf("Row index=%6d   irqs=%d\r\n",
//				rowIndex, 0 //irq_counter
//				);
//		print("..");
		usleep(1000000);
//		print(".\r\n");
		phase = (phase + 1)&7;
		//setLeds(phase);
		if (phase & 1) {
			//setLCDColor(0xfc8);
			//thereminIO_setBacklightBrightness(0x80);
		} else {
			//setLCDColor(0x46a);
			//thereminIO_setBacklightBrightness(0x20);
		}
//		uint32_t newEnc0 = thereminIO_readReg(THEREMIN_RD_REG_ENCODER_0);
//		uint32_t newEnc1 = thereminIO_readReg(THEREMIN_RD_REG_ENCODER_1);
//		uint32_t newEnc2 = thereminIO_readReg(THEREMIN_RD_REG_ENCODER_2);
//		uint32_t newEncRaw = 0; //thereminIO_readReg(10) & 0xffff;
//		if (prevEnc0 != newEnc0 || prevEnc1 != newEnc1 || prevEnc2 != newEnc2 || prevEncRaw != newEncRaw) {
//			xil_printf("Encoders:    %08x   %08x    %08x     raw:%04x\r\n",
//					newEnc0, newEnc1, newEnc2, newEncRaw
//					);
//			prevEnc0 = newEnc0;
//			prevEnc1 = newEnc1;
//			prevEnc2 = newEnc2;
//			prevEncRaw = newEncRaw;
//		}
		uint32_t enc = readEncodersManual();
		xil_printf("Encoders \t%4x\r\n", enc);
		uint32_t s = thereminIO_readReg(0);
		int x = (s>>16)&0x3ff;
		int y = (s)&0x3ff;
		int vsync = (s>>15)&1;
		int hsync = (s>>14)&1;
		int de = (s>>13)&1;
		int expectedDE = ((x < 800) && (y < 480)) ? 1 : 0;
		int expectedVSYNC = (y >= 480+2 && y < 480+2+2) ? 0 : 1;
		int expectedHSYNC = (x >= 800+2 && x < 800+2+10) ? 0 : 1;
		if (de != expectedDE || vsync != expectedVSYNC || hsync != expectedHSYNC)
			xil_printf("LCD controls: VSYNC=%d (%d)\t HSYNC=%d (%d)\t DE=%d (%d)\t x=%d\t y=%d\r\n",
				vsync, expectedVSYNC,
				hsync, expectedHSYNC,
				de, expectedDE,
				//(s>>11)&1, (s>>10)&1,
				x,
				y
				);
	}
	return 0;
}
