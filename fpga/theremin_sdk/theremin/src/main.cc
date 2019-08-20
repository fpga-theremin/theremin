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

uint16_t framebuffer[SCREEN_DX*SCREEN_DY + 64]  __attribute__ ((aligned(32)));

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

int main()
{
	print("FPGA Theremin Project\r\n");
	sleep(1);
	print("FPGA Theremin Project\r\n");
	print("(c) Vadim Lopatin, 2019\r\n");
	for (int y = 0; y < SCREEN_DY; y++) {
		for (int x = 0; x < SCREEN_DX; x++) {
			uint16_t px = 0;
			px |= (y / 31) << 8;
			px |= (x / 50) << 4;
			px |= (x + y) / 100;
			if ((x & 15) == 0)
				px = 0xfff;
			if ((y & 15) == 0)
				px = 0x0ff;
			framebuffer[y*SCREEN_DX + x] = px; //0xf80 + x / 64; //y + ((x >> 6) * 4096);//(y&255) * 256 + (x &255);
		}
		thereminIO_flushCache(framebuffer + SCREEN_DX*y, SCREEN_DX*2);
	}
	//thereminIO_flushCache(framebuffer, SCREEN_DX*SCREEN_DX*2);
	print("Resetting PL\r\n");
	thereminIO_init();
	//setLeds(0);
	print("    Done\r\n");
	usleep(1000);
	xil_printf("Setting framebuffer address to %08x\r\n", framebuffer);
	thereminLCD_setFramebufferAddress(framebuffer);
	print("    Done\r\n");
	usleep(1000);

	xil_printf("i2c reg 0 = %2x \r\n", thereminAudio_i2cRead(0));
	xil_printf("i2c reg 2 = %2x \r\n", thereminAudio_i2cRead(2));

	//thereminIO_setLed0Color(0x8000ff);
	//thereminIO_setLed1Color(0x000020);
	uint32_t prevEnc0 = thereminIO_readReg(THEREMIN_RD_REG_ENCODER_0);
	uint32_t prevEnc1 = thereminIO_readReg(THEREMIN_RD_REG_ENCODER_1);
	uint32_t prevEnc2 = thereminIO_readReg(THEREMIN_RD_REG_ENCODER_2);

	int phase = 0;
	for (;;) {
		//print("readreg: ");
		uint32_t rowIndex = thereminLCD_getCurrentRowIndex();
//		xil_printf("Row index=%6d   irqs=%d\r\n",
//				rowIndex, 0 //irq_counter
//				);
//		print("..");
		usleep(100000);
//		print(".\r\n");
		phase = (phase + 1)&7;
		//setLeds(phase);
		if (phase & 1) {
			setLCDColor(0xfc8);
			//thereminIO_setBacklightBrightness(0x80);
		} else {
			setLCDColor(0x46a);
			//thereminIO_setBacklightBrightness(0x20);
		}
//		uint32_t newEnc0 = thereminIO_readReg(THEREMIN_RD_REG_ENCODER_0);
//		uint32_t newEnc1 = thereminIO_readReg(THEREMIN_RD_REG_ENCODER_1);
//		uint32_t newEnc2 = thereminIO_readReg(THEREMIN_RD_REG_ENCODER_2);
//		if (prevEnc0 != newEnc0 || prevEnc1 != newEnc1 || prevEnc2 != newEnc2) {
//			xil_printf("Encoders:    %08x   %08x    %08x\r\n",
//					newEnc0, newEnc1, newEnc2
//					);
//			prevEnc0 = newEnc0;
//			prevEnc1 = newEnc1;
//			prevEnc2 = newEnc2;
//		}
		uint32_t s = thereminIO_readReg(0);
		xil_printf("LCD controls: VSYNC=%d HSYNC=%d DE=%d PXCLK=%d\r\n", (s>>15)&1, (s>>14)&1, (s>>13)&1, (s>>12)&1);
	}
	return 0;
}
