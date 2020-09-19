
#include "FreqMeasureDMA.h"

#if defined(__IMXRT1062__)

#define M(a, b) ((((a) - 1) << 2) | (b))   // should translate from 0-15

struct freq_pwm_pin_info_struct_t4 {
	IMXRT_FLEXPWM_t *pflexpwm;
	uint8_t 		module;  	// 0-3, 0-3
	uint8_t 		channel; 	// 0=X, 1=A, 2=B
	uint8_t 		muxval;  	//
	uint8_t			dmamux;		// which DMA request source to use
	volatile 		uint32_t	*select_input_register; // Which register controls the selection
	const uint32_t	select_val;	// Value for that selection
};


static const struct freq_pwm_pin_info_struct_t4 freq_pwm_pin_info[] = {
	{&IMXRT_FLEXPWM1, M(1,1), 0, 4 | 0x10, DMAMUX_SOURCE_FLEXPWM1_READ1, nullptr, 0},  // FlexPWM1_1_X   0  // AD_B0_03
	{&IMXRT_FLEXPWM1, M(1,0), 0, 4 | 0x10, DMAMUX_SOURCE_FLEXPWM1_READ0, nullptr, 0},  // FlexPWM1_0_X   1  // AD_B0_02
	{&IMXRT_FLEXPWM4, M(4,2), 1, 1 | 0x10, DMAMUX_SOURCE_FLEXPWM4_READ2, &IOMUXC_FLEXPWM4_PWMA2_SELECT_INPUT, 0},  // FlexPWM4_2_A   2  // EMC_04
	{&IMXRT_FLEXPWM4, M(4,2), 2, 1 | 0x10, DMAMUX_SOURCE_FLEXPWM4_READ2, nullptr, 0},  // FlexPWM4_2_B   3  // EMC_05
	{&IMXRT_FLEXPWM2, M(2,0), 1, 1 | 0x10, DMAMUX_SOURCE_FLEXPWM2_READ0, &IOMUXC_FLEXPWM2_PWMA0_SELECT_INPUT, 0},  // FlexPWM2_0_A   4  // EMC_06
	{&IMXRT_FLEXPWM2, M(2,1), 1, 1 | 0x10, DMAMUX_SOURCE_FLEXPWM2_READ1, &IOMUXC_FLEXPWM2_PWMA1_SELECT_INPUT, 0},  // FlexPWM2_1_A   5  // EMC_08
	{&IMXRT_FLEXPWM2, M(2,2), 1, 2 | 0x10, DMAMUX_SOURCE_FLEXPWM2_READ2, &IOMUXC_FLEXPWM2_PWMA2_SELECT_INPUT, 1},  // FlexPWM2_2_A   6  // B0_10
	{&IMXRT_FLEXPWM1, M(1,3), 2, 6 | 0x10, DMAMUX_SOURCE_FLEXPWM1_READ3, &IOMUXC_FLEXPWM1_PWMB3_SELECT_INPUT, 4},  // FlexPWM1_3_B   7  // B1_01
	{&IMXRT_FLEXPWM1, M(1,3), 1, 6 | 0x10, DMAMUX_SOURCE_FLEXPWM1_READ3, &IOMUXC_FLEXPWM1_PWMA3_SELECT_INPUT, 4},  // FlexPWM1_3_A   8  // B1_00
	{&IMXRT_FLEXPWM2, M(2,2), 2, 2 | 0x10, DMAMUX_SOURCE_FLEXPWM2_READ2, &IOMUXC_FLEXPWM2_PWMB2_SELECT_INPUT, 1},  // FlexPWM2_2_B   9  // B0_11
	{nullptr, 0, 0, 1 | 0x10, 0, nullptr, 0},  // QuadTimer1_0  10  // B0_00
	{nullptr, 0, 0, 1 | 0x10, 0, nullptr, 0},  // QuadTimer1_2  11  // B0_02
	{nullptr, 0, 0, 1 | 0x10, 0, nullptr, 0},  // QuadTimer1_1  12  // B0_01
	{nullptr, 0, 0, 1 | 0x10, 0, nullptr, 0},  // QuadTimer2_0  13  // B0_03
	{nullptr, 0, 0, 1 | 0x10, 0, nullptr, 0},  // QuadTimer3_2  14  // AD_B1_02
	{nullptr, 0, 0, 1 | 0x10, 0, nullptr, 0},  // QuadTimer3_3  15  // AD_B1_03
	{nullptr, 0, 0, 0 | 0x10, 0, nullptr, 0},
	{nullptr, 0, 0, 0 | 0x10, 0, nullptr, 0},
	{nullptr, 0, 0, 1 | 0x10, 0, nullptr, 0},  // QuadTimer3_1  18  // AD_B1_01
	{nullptr, 0, 0, 1 | 0x10, 0, nullptr, 0},  // QuadTimer3_0  19  // AD_B1_00
	{nullptr, 0, 0, 0 | 0x10, 0, nullptr, 0},
	{nullptr, 0, 0, 0 | 0x10, 0, nullptr, 0},
	{&IMXRT_FLEXPWM4, M(4,0), 1, 1 | 0x10, DMAMUX_SOURCE_FLEXPWM4_READ0, &IOMUXC_FLEXPWM4_PWMA0_SELECT_INPUT, 1},  // FlexPWM4_0_A  22  // AD_B1_08
	{&IMXRT_FLEXPWM4, M(4,1), 1, 1 | 0x10, DMAMUX_SOURCE_FLEXPWM4_READ1, &IOMUXC_FLEXPWM4_PWMA1_SELECT_INPUT, 1},  // FlexPWM4_1_A  23  // AD_B1_09
	{&IMXRT_FLEXPWM1, M(1,2), 0, 4 | 0x10, DMAMUX_SOURCE_FLEXPWM1_READ2, nullptr, 0},  // FlexPWM1_2_X  24  // AD_B0_12
	{&IMXRT_FLEXPWM1, M(1,3), 0, 4 | 0x10, DMAMUX_SOURCE_FLEXPWM1_READ3, nullptr, 0},  // FlexPWM1_3_X  25  // AD_B0_13
	{nullptr, 0, 0, 0 | 0x10, 0, nullptr, 0},
	{nullptr, 0, 0, 0 | 0x10, 0, nullptr, 0},
	{&IMXRT_FLEXPWM3, M(3,1), 2, 1 | 0x10, DMAMUX_SOURCE_FLEXPWM3_READ1, nullptr, 0},  // FlexPWM3_1_B  28  // EMC_32
	{&IMXRT_FLEXPWM3, M(3,1), 1, 1 | 0x10, DMAMUX_SOURCE_FLEXPWM3_READ1, nullptr, 0},  // FlexPWM3_1_A  29  // EMC_31
	{nullptr, 0, 0, 0 | 0x10, 0, nullptr, 0},
	{nullptr, 0, 0, 0 | 0x10, 0, nullptr, 0},
	{nullptr, 0, 0, 0 | 0x10, 0, nullptr, 0},
	{&IMXRT_FLEXPWM2, M(2,0), 2, 1 | 0x10, DMAMUX_SOURCE_FLEXPWM2_READ0, &IOMUXC_FLEXPWM2_PWMB0_SELECT_INPUT, 0},  // FlexPWM2_0_B  33  // EMC_07
#ifdef ARDUINO_TEENSY40
	{&IMXRT_FLEXPWM1, M(1,1), 2, 1 | 0x10, DMAMUX_SOURCE_FLEXPWM1_READ1, &IOMUXC_FLEXPWM1_PWMB1_SELECT_INPUT, 1},  // FlexPWM1_1_B  34  // SD_B0_03
	{&IMXRT_FLEXPWM1, M(1,1), 1, 1 | 0x10, DMAMUX_SOURCE_FLEXPWM1_READ1, &IOMUXC_FLEXPWM1_PWMA1_SELECT_INPUT, 1},  // FlexPWM1_1_A  35  // SD_B0_02
	{&IMXRT_FLEXPWM1, M(1,0), 2, 1 | 0x10, DMAMUX_SOURCE_FLEXPWM1_READ0, &IOMUXC_FLEXPWM1_PWMB0_SELECT_INPUT, 1},  // FlexPWM1_0_B  36  // SD_B0_01
	{&IMXRT_FLEXPWM1, M(1,0), 1, 1 | 0x10, DMAMUX_SOURCE_FLEXPWM1_READ0, &IOMUXC_FLEXPWM1_PWMA0_SELECT_INPUT, 1},  // FlexPWM1_0_A  37  // SD_B0_00
	{&IMXRT_FLEXPWM1, M(1,2), 2, 1 | 0x10, DMAMUX_SOURCE_FLEXPWM1_READ2, &IOMUXC_FLEXPWM1_PWMB2_SELECT_INPUT, 1},  // FlexPWM1_2_B  38  // SD_B0_05
	{&IMXRT_FLEXPWM1, M(1,2), 1, 1 | 0x10, DMAMUX_SOURCE_FLEXPWM1_READ2, &IOMUXC_FLEXPWM1_PWMA2_SELECT_INPUT, 1},  // FlexPWM1_2_A  39  // SD_B0_04
#endif
#ifdef  ARDUINO_TEENSY41
	{nullptr, 0, 0, 0 | 0x10, 0, nullptr, 0},
	{nullptr, 0, 0, 0 | 0x10, 0, nullptr, 0},
	{&IMXRT_FLEXPWM2, M(2,3), 1, 6 | 0x10, DMAMUX_SOURCE_FLEXPWM2_READ3, &IOMUXC_FLEXPWM2_PWMA3_SELECT_INPUT, 4},  // FlexPWM2_3_A  36  // B1_02
	{&IMXRT_FLEXPWM2, M(2,3), 2, 6 | 0x10, DMAMUX_SOURCE_FLEXPWM2_READ3, &IOMUXC_FLEXPWM2_PWMB3_SELECT_INPUT, 3},  // FlexPWM2_3_B  37  // B1_03
	{nullptr, 0, 0, 0 | 0x10, 0, nullptr, 0},
	{nullptr, 0, 0, 0 | 0x10, 0, nullptr, 0},
	{nullptr, 0, 0, 0 | 0x10, 0, nullptr, 0},
	{nullptr, 0, 0, 0 | 0x10, 0, nullptr, 0},
	{&IMXRT_FLEXPWM1, M(1,1), 2, 1 | 0x10, DMAMUX_SOURCE_FLEXPWM1_READ1, &IOMUXC_FLEXPWM1_PWMB1_SELECT_INPUT, 1},  // FlexPWM1_1_B  42  // SD_B0_03
	{&IMXRT_FLEXPWM1, M(1,1), 1, 1 | 0x10, DMAMUX_SOURCE_FLEXPWM1_READ1, &IOMUXC_FLEXPWM1_PWMA1_SELECT_INPUT, 1},  // FlexPWM1_1_A  43  // SD_B0_02
	{&IMXRT_FLEXPWM1, M(1,0), 2, 1 | 0x10, DMAMUX_SOURCE_FLEXPWM1_READ0, &IOMUXC_FLEXPWM1_PWMB0_SELECT_INPUT, 1},  // FlexPWM1_0_B  44  // SD_B0_01
	{&IMXRT_FLEXPWM1, M(1,0), 1, 1 | 0x10, DMAMUX_SOURCE_FLEXPWM1_READ0, &IOMUXC_FLEXPWM1_PWMA0_SELECT_INPUT, 1},  // FlexPWM1_0_A  45  // SD_B0_00
	{&IMXRT_FLEXPWM1, M(1,2), 2, 1 | 0x10, DMAMUX_SOURCE_FLEXPWM1_READ2, &IOMUXC_FLEXPWM1_PWMB2_SELECT_INPUT, 1},  // FlexPWM1_2_B  46  // SD_B0_05
	{&IMXRT_FLEXPWM1, M(1,2), 1, 1 | 0x10, DMAMUX_SOURCE_FLEXPWM1_READ2, &IOMUXC_FLEXPWM1_PWMA2_SELECT_INPUT, 1},  // FlexPWM1_2_A  47  // SD_B0_04
	{&IMXRT_FLEXPWM1, M(1,0), 0, 0 | 0x10, DMAMUX_SOURCE_FLEXPWM1_READ0, &IOMUXC_FLEXPWM1_PWMB0_SELECT_INPUT, 0},  // duplicate FlexPWM1_0_B
	{&IMXRT_FLEXPWM1, M(1,0), 0, 0 | 0x10, DMAMUX_SOURCE_FLEXPWM1_READ0, &IOMUXC_FLEXPWM1_PWMA2_SELECT_INPUT, 0},  // duplicate FlexPWM1_2_A
	{&IMXRT_FLEXPWM1, M(1,0), 0, 0 | 0x10, DMAMUX_SOURCE_FLEXPWM1_READ0, &IOMUXC_FLEXPWM1_PWMB2_SELECT_INPUT, 0},  // duplicate FlexPWM1_2_B
	{&IMXRT_FLEXPWM3, M(3,3), 2, 1 | 0x10, DMAMUX_SOURCE_FLEXPWM3_READ3, nullptr, 0},  // FlexPWM3_3_B  51  // EMC_22
	{&IMXRT_FLEXPWM1, M(1,0), 0, 0 | 0x10, DMAMUX_SOURCE_FLEXPWM1_READ0, &IOMUXC_FLEXPWM1_PWMB1_SELECT_INPUT, 0},  // duplicate FlexPWM1_1_B
	{&IMXRT_FLEXPWM1, M(1,0), 0, 0 | 0x10, DMAMUX_SOURCE_FLEXPWM1_READ0, &IOMUXC_FLEXPWM1_PWMA1_SELECT_INPUT, 0},  // duplicate FlexPWM1_1_A
	{&IMXRT_FLEXPWM3, M(3,0), 1, 1 | 0x10, DMAMUX_SOURCE_FLEXPWM3_READ0, nullptr, 0},  // FlexPWM3_0_A  54  // EMC_29
#endif
};


FreqMeasureDMA::FreqMeasureDMA()
	:_pin(255)	// remember the pin number;
	//uint8_t _mode;	// remember the mode we are using. 
	,_channel(255)
        ,_pvalue(nullptr) // captured value reg pointer
        ,_pctrl(nullptr)  // capture control reg pointer
        ,_dmabuf(nullptr)
        ,_dmabufsize(0)
{
	
}

bool FreqMeasureDMA::begin(uint32_t pin)
{
	return begin(pin, nullptr, 0);
}

bool FreqMeasureDMA::begin(uint32_t pin, volatile uint16_t * buf, uint16_t buflen) {
        _dmabuf = buf;
	_dmabufsize = buflen;
        _dmabuf_read_pos = 50;
	if (_dmabuf && _dmabufsize) {
	        // limit buffer size by power of two
		uint16_t szpow2 = 1;
		while ((szpow2 << 1) <= buflen)
			szpow2 = szpow2 << 1;
		_dmabufsize = szpow2;
		_dmabufsize_mask = szpow2 - 1;
	}
	Serial.printf("Buf size rounded to power of two: %d, mask = %x\n", _dmabufsize, _dmabufsize_mask);
	if (pin > (sizeof(freq_pwm_pin_info)/sizeof(freq_pwm_pin_info[0]))) return false;
	if (freq_pwm_pin_info[pin].pflexpwm == nullptr) return false;	
	_pin = pin;	// remember the pin
	//_mode = mode;	
	_channel = freq_pwm_pin_info[pin].channel; // remember the channel 

	// So we may now have a valid pin, lets configure it. 
	*(portConfigRegister(pin)) = freq_pwm_pin_info[pin].muxval;
	if (freq_pwm_pin_info[pin].select_input_register)
		*freq_pwm_pin_info[pin].select_input_register = freq_pwm_pin_info[pin].select_val;

	IMXRT_FLEXPWM_t *pflexpwm = freq_pwm_pin_info[pin].pflexpwm;
	uint8_t sub_module = freq_pwm_pin_info[pin].module & 3;
	uint8_t sub_module_bit = 1 << sub_module;

	pflexpwm->FCTRL0 |= FLEXPWM_FCTRL0_FLVL(sub_module_bit);
	pflexpwm->FSTS0 = sub_module_bit;
	pflexpwm->MCTRL |= FLEXPWM_MCTRL_CLDOK(sub_module_bit);
	pflexpwm->SM[sub_module].CTRL2 = FLEXPWM_SMCTRL2_INDEP;
	pflexpwm->SM[sub_module].CTRL = FLEXPWM_SMCTRL_HALF;
	pflexpwm->SM[sub_module].INIT = 0;
	pflexpwm->SM[sub_module].VAL0 = 0;
	pflexpwm->SM[sub_module].VAL1 = 65535;
	pflexpwm->SM[sub_module].VAL2 = 0;
	pflexpwm->SM[sub_module].VAL3 = 0;
	pflexpwm->SM[sub_module].VAL4 = 0;
	pflexpwm->SM[sub_module].VAL5 = 0;
	pflexpwm->MCTRL |= FLEXPWM_MCTRL_LDOK(sub_module_bit) | FLEXPWM_MCTRL_RUN(sub_module_bit);


        // Can maybe capture two different values. 
        //00b - Disabled
	//01b - Capture falling edges
	//10b - Capture rising edges
	//11b - Capture any edge
	switch (_channel) {
		case 0: //  X channel
			pflexpwm->SM[sub_module].CAPTCTRLX = FLEXPWM_SMCAPTCTRLX_EDGX0(3) | FLEXPWM_SMCAPTCTRLX_ARMX;
			pflexpwm->SM[sub_module].DMAEN |= FLEXPWM_SMDMAEN_CX0DE | FLEXPWM_SMDMAEN_CAPTDE(1);   // CVAL0 contains captured value
                        _pvalue = &pflexpwm->SM[sub_module].CVAL0;
			_pctrl = &pflexpwm->SM[sub_module].CAPTCTRLX;
			break;
		case 1: // A Channel
			pflexpwm->SM[sub_module].CAPTCTRLA = FLEXPWM_SMCAPTCTRLA_EDGA0(3) | FLEXPWM_SMCAPTCTRLA_ARMA;
			pflexpwm->SM[sub_module].DMAEN |= FLEXPWM_SMDMAEN_CA0DE | FLEXPWM_SMDMAEN_CAPTDE(1);   // CVAL2 contains captured value
                        _pvalue = &pflexpwm->SM[sub_module].CVAL2;
			_pctrl = &pflexpwm->SM[sub_module].CAPTCTRLA;
			break;
		case 2: // B Channel;
			pflexpwm->SM[sub_module].CAPTCTRLB = FLEXPWM_SMCAPTCTRLB_EDGB0(3) | FLEXPWM_SMCAPTCTRLB_ARMB;
			pflexpwm->SM[sub_module].DMAEN |= FLEXPWM_SMDMAEN_CB0DE | FLEXPWM_SMDMAEN_CAPTDE(1);   // CVAL4 contains captured value
                        _pvalue = &pflexpwm->SM[sub_module].CVAL4;
			_pctrl = &pflexpwm->SM[sub_module].CAPTCTRLB;
			break;
	}

        uint16_t len = _dmabufsize*2;
	if (_dmabuf) {

		_dmachannel.source(*_pvalue);
		_dmachannel.destinationBuffer(_dmabuf, len);
		// disable channel linking, keep DMA running continously
		_dmachannel.TCD->CSR = 0; //(1<<4); // ESG - enable scatter gather
		//Serial.printf("Src addr %x dst addr %x len=%x DLASTSGA=%x\n", _dmachannel->TCD->SADDR, _dmachannel->TCD->DADDR, len, _dmachannel->TCD->DLASTSGA);
		_dmachannel.triggerAtHardwareEvent(freq_pwm_pin_info[pin].dmamux);
 		//Serial.println("Enabling DMA");
		_dmachannel.enable();
	}
	return true;
}

uint32_t FreqMeasureDMA::peek(void) {
    return *_pvalue;
}

// read all fifo items, return last one
uint32_t FreqMeasureDMA::peekClearFifo(void) {
    uint16_t res = *_pvalue;
    while ( ((*_pctrl) & 0x1c00) != 0) // check number of values in capture fifo
	res = *_pvalue;
    res = poll();
    return res;
}

uint32_t FreqMeasureDMA::poll(void) {
    while ( ((*_pctrl) & 0x1c00) == 0) // check number of values in capture fifo
	; // wait
    return *_pvalue;
}

void FreqMeasureDMA::end(void) {
	IMXRT_FLEXPWM_t *pflexpwm = freq_pwm_pin_info[_pin].pflexpwm;
	uint8_t sub_module = freq_pwm_pin_info[_pin].module & 3;
	pflexpwm->SM[sub_module].INTEN = 0;
	pflexpwm->SM[sub_module].CAPTCTRLA = 0;
	pflexpwm->SM[sub_module].DMAEN = 0;
	if (_dmabuf) {
		_dmachannel.disable();
	}
}
    



#endif // defined(__IMXRT1062__)
