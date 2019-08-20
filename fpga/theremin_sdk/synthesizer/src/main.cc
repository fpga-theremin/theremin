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





static volatile int32_t delay_counter = 0;
void delay(int n) {
	for (int i = 0; i < n; i++)
		delay_counter++;
}

void setLeds(int phase) {
	switch(phase & 7) {
	default:
	case 0:
		//thereminIO_setLed0Color(0x8000ff);
		thereminIO_setLed1Color(0x000020);
		break;
	case 1:
		//thereminIO_setLed0Color(0x404080);
		thereminIO_setLed1Color(0x003020);
		break;
	case 2:
		//thereminIO_setLed0Color(0x408080);
		thereminIO_setLed1Color(0x403020);
		break;
	case 3:
		//thereminIO_setLed0Color(0xff8080);
		thereminIO_setLed1Color(0x4030ff);
		break;
	case 4:
		//thereminIO_setLed0Color(0xff8080);
		thereminIO_setLed1Color(0x4030ff);
		break;
	case 5:
		//thereminIO_setLed0Color(0xcf4040);
		thereminIO_setLed1Color(0x201080);
		break;
	case 6:
		//thereminIO_setLed0Color(0x8f2020);
		thereminIO_setLed1Color(0x100040);
		break;
	case 7:
		//thereminIO_setLed0Color(0x4f1010);
		thereminIO_setLed1Color(0x000020);
		break;
	}
}


uint32_t irq_counter = 0;
void my_audio_irq() {
	irq_counter++;
	int subphase = irq_counter % (48 * 200);
	int phase = irq_counter / 48 / 200;
	if (subphase == 0)
		setLeds(phase & 7);
}

int main()
{
	thereminIO_init();
	//print("Setting audio irq handler\r\n");
	thereminAudio_setIrqHandler(&my_audio_irq);
	//print("Enabling audio IRQ\r\n");

	thereminAudio_enableIrq();
	delay(1000000);
	for(;;) {
		delay(2000000);
	}
	return 0;
}
