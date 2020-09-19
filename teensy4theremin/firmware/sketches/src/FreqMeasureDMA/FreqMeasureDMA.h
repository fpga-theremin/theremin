#ifndef FREQ_MEASURE_DMA_H
#define FREQ_MEASURE_DMA_H

#include <Arduino.h>

#if defined(__IMXRT1062__)

#include "DMAChannel.h"

struct freq_pwm_pin_info_struct_t4;

template <int maxSizePower>
class MovingAverageFilter {
private:
	uint16_t _sizePower;
	uint16_t _size;
	uint16_t _mask;
	uint16_t _pos;
	bool _initialized;
	uint32_t _acc;
	uint32_t _buf[1 << maxSizePower];
public:
	uint16_t windowSizeBits() {
		return _sizePower;
	}
	// initialize moving average filter with window size bit count (window size will be 1<<sizePower)
	void begin(uint16_t sizePower) {
		Serial.printf("MovingAvgFilter window:%d\n", sizePower);
		_acc = 0;
		_sizePower = sizePower;
		if (_sizePower < 2)
			_sizePower = 2;
		else if (_sizePower > maxSizePower)
	                _sizePower = maxSizePower;
		_size = 1 << _sizePower;
		_mask = _size - 1;
		_pos = 0;
		_initialized = false;
	}

	// process new input, returns accumulated delta for buffer size recent inputs, 0 if buffer is not yet filled
	uint32_t filter(uint32_t delta) {
		_acc += delta;
		uint32_t res;
		if (_initialized) {
			res = _acc - _buf[_pos];
		} else {
			if (_pos == _mask)
				_initialized = true;
			res = 0;
		}
		_buf[_pos] = _acc;
		_pos = (_pos + 1) & _mask;
		return res;
	}
};

template <int maxStages>
class SimpleShiftIIRFilter {
	uint16_t _stages;
	uint16_t _shift;
	uint32_t _state[maxStages];
public:
	SimpleShiftIIRFilter() {
		begin(6, 8, 0);
	}
	void begin(uint16_t stages, uint16_t shift, uint32_t initValue) {
		Serial.printf("IIRFilter stages:%d shift:%d init:%x\n", stages, shift, initValue);
		setShift(shift);
		setStages(stages);
		init(initValue);
	}
	uint16_t getShift() { return _shift; }
	uint16_t getStages() { return _stages; }

	void setShift(uint16_t shift) {
		_shift = shift;
		if (_shift > 24)
			_shift = 24;
	}
	void setStages(uint16_t stages) {
		_stages = stages;
		if (_stages > maxStages)
			_stages = maxStages;
		init(_state[0]);
	}
	void init(uint32_t initValue) {
		for (uint16_t i = 0; i < maxStages; i++)
			_state[i] = initValue;
	}
	uint32_t filter(uint32_t value) {
#if 1
		switch(_stages) {
			default:
			case 2:
				{
					uint32_t state0 = _state[0];
					uint32_t state1 = _state[1];
					state0 += ((int32_t)(value - state0)) >> _shift;
					state1 += ((int32_t)(state0 - state1)) >> _shift;
					_state[0] = state0;
					_state[1] = state1;
					return state1;
				}
			case 3:
				{
					uint32_t state0 = _state[0];
					uint32_t state1 = _state[1];
					uint32_t state2 = _state[2];
					state0 += ((int32_t)(value - state0)) >> _shift;
					state1 += ((int32_t)(state0 - state1)) >> _shift;
					state2 += ((int32_t)(state1 - state2)) >> _shift;
					_state[0] = state0;
					_state[1] = state1;
					_state[2] = state2;
					return state2;
				}
			case 4:
				{
					uint32_t state0 = _state[0];
					uint32_t state1 = _state[1];
					uint32_t state2 = _state[2];
					uint32_t state3 = _state[3];
					state0 += ((int32_t)(value - state0)) >> _shift;
					state1 += ((int32_t)(state0 - state1)) >> _shift;
					state2 += ((int32_t)(state1 - state2)) >> _shift;
					state3 += ((int32_t)(state2 - state3)) >> _shift;
					_state[0] = state0;
					_state[1] = state1;
					_state[2] = state2;
					_state[3] = state3;
					return state3;
				}
			case 5:
				{
					uint32_t state0 = _state[0];
					uint32_t state1 = _state[1];
					uint32_t state2 = _state[2];
					uint32_t state3 = _state[3];
					uint32_t state4 = _state[4];
					state0 += ((int32_t)(value - state0)) >> _shift;
					state1 += ((int32_t)(state0 - state1)) >> _shift;
					state2 += ((int32_t)(state1 - state2)) >> _shift;
					state3 += ((int32_t)(state2 - state3)) >> _shift;
					state4 += ((int32_t)(state3 - state4)) >> _shift;
					_state[0] = state0;
					_state[1] = state1;
					_state[2] = state2;
					_state[3] = state3;
					_state[4] = state4;
					return state4;
				}
			case 6:
				{
					uint32_t state0 = _state[0];
					uint32_t state1 = _state[1];
					uint32_t state2 = _state[2];
					uint32_t state3 = _state[3];
					uint32_t state4 = _state[4];
					uint32_t state5 = _state[5];
					state0 += ((int32_t)(value - state0)) >> _shift;
					state1 += ((int32_t)(state0 - state1)) >> _shift;
					state2 += ((int32_t)(state1 - state2)) >> _shift;
					state3 += ((int32_t)(state2 - state3)) >> _shift;
					state4 += ((int32_t)(state3 - state4)) >> _shift;
					state5 += ((int32_t)(state4 - state5)) >> _shift;
					_state[0] = state0;
					_state[1] = state1;
					_state[2] = state2;
					_state[3] = state3;
					_state[4] = state4;
					_state[5] = state5;
					return state5;
				}
	
		}
#else
		uint32_t v = value;
		//if (!_state[0])
		//	init(v);
		for (uint16_t i = 0; i < _stages; i++) {
			uint32_t state = _state[i];
			int32_t delta = v - state;
			v = state + (delta >> _shift);
			_state[i] = v;
		}
		return v;
#endif
	}
};

class FreqMeasureDMA
{
protected:
	uint8_t _pin;	// remember the pin number;
	//uint8_t _mode;	// remember the mode we are using. 
	uint8_t _channel;
        volatile uint16_t * _pvalue; // captured value reg pointer
        volatile uint16_t * _pctrl;  // capture control reg pointer
        volatile uint16_t * _dmabuf; // circular buffer for writing captured data by DMA
	// DMA buf size in 16-bit words, power of two
        uint16_t _dmabufsize;
	uint16_t _dmabufsize_mask;
        uint16_t _dmabuf_read_pos;

        DMAChannel _dmachannel;

public:
	FreqMeasureDMA();

	bool begin(uint32_t pin);
	bool begin(uint32_t pin, volatile uint16_t * buf, uint16_t buflen);

	// read position in DMA buffer (points to next edge to be read)
	uint16_t dmaReadPos() const { return _dmabuf_read_pos; }
	// write position in DMA buffer (points to place to write captured edge position on next DMA transfer)
	uint16_t dmaWritePos() { return (uint16_t)(((uint32_t)_dmachannel.destinationAddress() - (uint32_t)_dmabuf) >> 1); }
	// unread records available in DMA circular buffer
	uint32_t dmaAvailable() { return (dmaWritePos() - _dmabuf_read_pos) & _dmabufsize_mask; }
	// returns true if DMA error occured
	bool dmaError() {  return _dmachannel.error(); }
	// returns true if DMA operation is complete
	bool dmaComplete() {  return _dmachannel.complete(); }
        // drops DMA buffer region from data cache, otherwise CPU may see cached data instead of values written by DMA
        void dmaBufDropCache() { arm_dcache_delete((void*)_dmabuf, _dmabufsize * 2); }

	// returns next delta between values in circular buffer, 0 if no more data
	uint32_t readDelta(void) {
		uint16_t available = dmaAvailable();
		if (available < 2)
			return 0;
		dmaBufDropCache();
		uint16_t prev = _dmabuf[_dmabuf_read_pos];
		_dmabuf_read_pos = (_dmabuf_read_pos + 1) & _dmabufsize_mask;
		uint16_t newvalue = _dmabuf[_dmabuf_read_pos];
		uint32_t delta = newvalue - prev;
		return delta;
	}
        // get recent capture value, no wait
	uint32_t peek(void);

        // read all fifo items, return last one
	uint32_t peekClearFifo(void);
        // wait for available data, then return value
	uint32_t poll(void);
	void end(void);


};


template <int movingAverageFilterMaxSizePower2, int iirFilterMaxStages>
class FreqMeasureDMAWithFilter : public FreqMeasureDMA
{
protected:
	MovingAverageFilter<movingAverageFilterMaxSizePower2> _movingAverageFilter;
	SimpleShiftIIRFilter<iirFilterMaxStages> _iirFilter;
	uint16_t _scalingShiftBits;
	uint32_t _lastValue;
	uint32_t _lastMovAvgValue;
	uint16_t _iirFilterShift;
	uint16_t _iirFilterStages;
	uint16_t _movingAverageWindowBits;
public:
	FreqMeasureDMAWithFilter() {}
	bool begin(uint32_t pin, volatile uint16_t * buf, uint16_t buflen, 
			uint16_t movingAverageFilterWindowSizeBits, uint16_t scalingShiftBits, uint16_t iirFilterStages, uint16_t iirFilterShift) {
		_scalingShiftBits = scalingShiftBits;
		_lastValue = 0;
		_lastMovAvgValue = 0;
		bool res = FreqMeasureDMA::begin(pin, buf, buflen);
		if (!res)
			return false;
		Serial.printf("FreqMeasureDMAWithFilter initialize filters\n");
		_movingAverageFilter.begin(movingAverageFilterWindowSizeBits);
		_iirFilter.begin(iirFilterStages, iirFilterShift, 1);
		_iirFilterShift = _iirFilter.getShift();
		_iirFilterStages = _iirFilter.getStages();
		_movingAverageWindowBits = _movingAverageFilter.windowSizeBits();

		return true;
	}       
	// peel 
	uint32_t peek() {
		return _lastValue;
	}
	// read recent value with filtering - process all available data and return most recent value
	uint32_t read() {
		uint16_t available = dmaAvailable();
		if (available < 2)
			return _lastValue;
		dmaBufDropCache();
		uint16_t prev = _dmabuf[_dmabuf_read_pos];
		while (available > 1) {
			_dmabuf_read_pos = (_dmabuf_read_pos + 1) & _dmabufsize_mask;
			uint16_t newvalue = _dmabuf[_dmabuf_read_pos];
			uint16_t delta = newvalue - prev;
			uint32_t firFilterResult = _movingAverageFilter.filter(delta) << _scalingShiftBits;
			_lastValue = _lastMovAvgValue + firFilterResult;
			_lastMovAvgValue = firFilterResult;
			//if (_iirFilterShift) {
				_lastValue = _iirFilter.filter(_lastValue);
			//}
			prev = newvalue;
			available--;
		}
		return _lastValue;
	}
	// converts read() output scaled period value to signal frequency
	float periodToFrequency(uint32_t periodValue) {
		int divider = (1<<(_scalingShiftBits + _movingAverageFilter.windowSizeBits()));
		float periodBusCycles = (float)periodValue / divider;
		return F_BUS_ACTUAL / periodBusCycles;
	}
};

#endif // defined(__IMXRT1062__)

#endif // FREQ_MEASURE_DMA_H
