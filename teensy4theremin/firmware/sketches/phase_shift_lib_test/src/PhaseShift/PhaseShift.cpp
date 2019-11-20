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

PhaseShift::PhaseShift(int8_t refFreqPin, int8_t shiftedSignalPin) 
: _refFreqPin(refFreqPin), _shiftedSignalPin(shiftedSignalPin) 
, _refFreqPeriod(0), _refFreqPhase(0), _averagingBufferSize(0)
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
	pwm->MCTRL |= FLEXPWM_MCTRL_LDOK(mask);
	*(portConfigRegister(_refFreqPin)) = cfg.muxval;
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

uint16_t PhaseShift::readStatusReg() {
    IMXRT_FLEXPWM_t *pwm = nullptr;
    int submodule = 0;
    if (_refFreqPin == 2) {
        // {1, M(4, 2), 1, 1},  // FlexPWM4_2_A   2  // EMC_04
        // {1, M(4, 2), 2, 1},  // FlexPWM4_2_B   3  // EMC_05
        pwm = &IMXRT_FLEXPWM4;
        submodule = 2;
    }
    if (!pwm)
        return 0;
    return pwm->SM[submodule].STS;
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
