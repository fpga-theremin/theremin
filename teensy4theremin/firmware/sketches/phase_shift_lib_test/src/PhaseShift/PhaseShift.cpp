/* PhaseShift Library, for measuring phase shift between reference frequency signal
 * and shifted one.
 * 
 * Copyright (c) 2019 Vadim Lopatin <coolreader.org@gmail.com>
 *
 * Version 0.1
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#include "PhaseShift.h"

#if defined(__IMXRT1062__)

#include <imxrt.h>
#include <DMAChannel.h>

typedef DMABaseClass::TCD_t tcd_t;

// extern uint16_t dma_channel_allocated_mask;

class PhaseShiftDMASetting : public DMASetting {
public:
	void sourceTwoValuesWithStep(volatile const unsigned short p[], uint16_t step) {
		TCD->SADDR = p;
		TCD->SOFF = step; //2;
		TCD->ATTR_SRC = 1;
		TCD->NBYTES = 2;
		TCD->SLAST = 0; //-len;
		TCD->BITER = 1; //len / 2;
		TCD->CITER = 1; //len / 2;
	}

};

// DMA channel able to fetch source data with step
class PhaseShiftDMA : public DMAChannel {
protected:
    uint8_t channel;
public:

};

PhaseShift::PhaseShift(int8_t refFreqPin, int8_t shiftedSignalPin) 
: _refFreqPin(refFreqPin), _shiftedSignalPin(shiftedSignalPin) 
, _refFreqPeriod(0), _refFreqPhase(0), _averagingBufferSize(0)
, _dmabuf(nullptr)
, _bufSizeLog2(0)
{

}

uint16_t PhaseShift::getPeriod()
{
	return _refFreqPeriod;
}

uint16_t PhaseShift::getPhase()
{
	return _refFreqPhase;
}	

struct PhaseShiftChannelConfig {
	IMXRT_FLEXPWM_t * pwm;
    uint16_t submodule;
	uint16_t muxval;
	// 0:x, 1:A, 2:B
	uint16_t channel;
};

static bool getChannelForPins(int8_t refFreqPin, int8_t readPin, PhaseShiftChannelConfig &cfg)
{
	if (refFreqPin == 2 && readPin == 3) {
		cfg.pwm = &IMXRT_FLEXPWM4;
		cfg.submodule = 2;
		cfg.muxval = 1;
		cfg.channel = 1;
		return true;
	} else {
		cfg.pwm = nullptr;
		cfg.submodule = 0;
		cfg.muxval = 0;
		cfg.channel = 0;
		return false;
	}
}


void PhaseShift::setPeriod(uint16_t period, uint16_t phase)
{
	PhaseShiftChannelConfig cfg;
	if (!getChannelForPins(_refFreqPin, _shiftedSignalPin, cfg))
		return;
	
    _refFreqPeriod = period;
    _refFreqPhase = phase % _refFreqPeriod;
	
    uint16_t phase0 = _refFreqPhase;
    uint16_t phase1 = (_refFreqPhase + (_refFreqPeriod / 2)) % _refFreqPeriod;

    uint16_t prescale = 0;
    uint16_t mask = 1 << cfg.submodule;

	IMXRT_FLEXPWM_t * pwm = cfg.pwm;
	
    // same as analogWriteFrequency()
	uint32_t olddiv = pwm->SM[cfg.submodule].VAL1;
	uint32_t newdiv = _refFreqPeriod;

    if (pwm->SM[cfg.submodule].VAL1 != newdiv - 1) {
		pwm->MCTRL |= FLEXPWM_MCTRL_CLDOK(mask);
		pwm->SM[cfg.submodule].CTRL = FLEXPWM_SMCTRL_FULL | FLEXPWM_SMCTRL_PRSC(prescale);
		pwm->SM[cfg.submodule].VAL1 = newdiv - 1;
		pwm->SM[cfg.submodule].VAL0 = (pwm->SM[cfg.submodule].VAL0 * newdiv) / olddiv;
		pwm->SM[cfg.submodule].VAL3 = (pwm->SM[cfg.submodule].VAL3 * newdiv) / olddiv;
		pwm->SM[cfg.submodule].VAL5 = (pwm->SM[cfg.submodule].VAL5 * newdiv) / olddiv;
		pwm->MCTRL |= FLEXPWM_MCTRL_LDOK(mask);
	}

    // similar to analogWrite, but uses phase
    // channel A
	pwm->MCTRL |= FLEXPWM_MCTRL_CLDOK(mask);
	switch (cfg.channel) {
		case 0:
			pwm->SM[cfg.submodule].VAL0 = newdiv / 2; // phase not supported for channel X
			pwm->OUTEN |= FLEXPWM_OUTEN_PWMX_EN(mask);
		    break;
		case 1:
			pwm->SM[cfg.submodule].VAL2 = phase0;
			pwm->SM[cfg.submodule].VAL3 = phase1;
			pwm->OUTEN |= FLEXPWM_OUTEN_PWMA_EN(mask);
		    break;
		case 2:
			pwm->SM[cfg.submodule].VAL4 = phase0;
			pwm->SM[cfg.submodule].VAL5 = phase1;
			pwm->OUTEN |= FLEXPWM_OUTEN_PWMB_EN(mask);
		    break;
	}
	

        //1b - PWM_A and PWM_B outputs are independent PWMs.
	pwm->SM[cfg.submodule].CTRL2 |= 1 << 13;
	pwm->MCTRL |= FLEXPWM_MCTRL_LDOK(mask);
	
	uint16_t capt = 0;
	uint16_t capt_watermark = 0; // 9-8 CFBWM Capture B FIFOs Water Mark
	capt |= capt_watermark << 8;
	// 7 Edge Counter B Enable, 0b - Edge counter disabled and held in reset
	// 6 Input Select B, 0b - Raw PWM_B input signal selected as source.
	// 5-4 Edge B 1: 10b - Capture falling edges
	capt |= 0b10 << 4;
	// 3-2 Edge B 0: 01b - Capture rising edges
	capt |= 0b01 << 2;
	// 1 One Shot Mode B: 0b - Free running mode is selected
	// 0 Arm B: 1b - Input capture operation as specified by CAPTCTRLB[EDGBx] is enabled.
	capt |= 1;
	pwm->SM[cfg.submodule].CAPTCTRLB = capt;

	*(portConfigRegister(_refFreqPin)) = cfg.muxval;
	
	//uint16_t octrl = 0;
	*(portConfigRegister(_shiftedSignalPin)) = cfg.muxval;
	//pwm->SM[cfg.submodule].OCTRL = octrl;
}

int PhaseShift::begin(uint16_t refFreqPeriod, uint16_t refFreqPhase, uint16_t averagingBufferSize)
{
    if (refFreqPeriod < 50 || refFreqPeriod > 3000)
        return 0;
    PhaseShiftChannelConfig cfg;
    if (!getChannelForPins(_refFreqPin, _shiftedSignalPin, cfg))
        return 0;

    // setup pin modes
    pinMode(_refFreqPin, OUTPUT);
    pinMode(_shiftedSignalPin, INPUT);

    // setup frequency
    setPeriod(refFreqPeriod, refFreqPhase);

	

    _averagingBufferSize = averagingBufferSize;
	


    return 1;
}

void PhaseShift::readRegs(uint16_t * values) {
    PhaseShiftChannelConfig cfg;
    if (!getChannelForPins(_refFreqPin, _shiftedSignalPin, cfg))
        return 0;
    IMXRT_FLEXPWM_t *pwm = cfg.pwm;
    values[0] = pwm->SM[cfg.submodule].OCTRL;
    values[1] = pwm->SM[cfg.submodule].STS;
    values[2] = pwm->SM[cfg.submodule].CVAL4;
    values[3] = pwm->SM[cfg.submodule].CVAL5;
    // clear capture status of B
    pwm->SM[cfg.submodule].STS &= ~(0x300);
    //return pwm->SM[cfg.submodule].OCTRL; //pwm->SM[submodule].STS;
    //return pwm->SM[cfg.submodule].CVAL0; //pwm->SM[submodule].STS;
}

int PhaseShift::setupDMA(volatile Edges * bufptr, uint8_t sizeLog2) {
    PhaseShiftChannelConfig cfg;
    if (!getChannelForPins(_refFreqPin, _shiftedSignalPin, cfg))
        return 0;
    IMXRT_FLEXPWM_t *pwm = cfg.pwm;
    if (sizeLog2 > 12)
        sizeLog2 = 12; // *4096
    else if (sizeLog2 < 4)
        sizeLog2 = 4; // *16
    _dmabuf = bufptr;
    _bufSizeLog2 = sizeLog2;
    return 1;
}


// wait for next captured value and return it
Edges PhaseShift::poll()
{
    PhaseShiftChannelConfig cfg;
    if (!getChannelForPins(_refFreqPin, _shiftedSignalPin, cfg))
        return Edges(0,0);

    IMXRT_FLEXPWM_t *pwm = cfg.pwm;
    while ((pwm->SM[cfg.submodule].STS & (0x300)) != 0x300) {
        // wait until capture flag is set
    }
    Edges res = Edges(pwm->SM[cfg.submodule].CVAL4, pwm->SM[cfg.submodule].CVAL5);
    // clear capture status of B
    pwm->SM[cfg.submodule].STS &= ~(0x300);
    return res;
}
    

void PhaseShift::end(void)
{
     // TODO
}

uint16_t PhaseShift::frequencyToPeriod(float frequencyHertz) {
    return (uint16_t)(((float)F_BUS_ACTUAL) / frequencyHertz + 0.5f);
}

#else
#error("Only Teensy4 with IMXRT1062 is supported for now")
#endif
