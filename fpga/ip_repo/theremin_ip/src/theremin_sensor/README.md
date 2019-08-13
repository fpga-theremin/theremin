# Theremin Sensor module

Pitch and Volume oscillators produce 3.3V digital signal with frequency in range 200KHz..2MHz depending on inductor, duty cycle 50% (for implementation with flip-flop output).

Two input pins of FPGA board are used for receiving oscillator signals.

Frequency varies by ~7% depending on hand distance to antenna.

It's necessary to measure frequency of both signals with highest possible precision.

We can track changes of input signal and count number of clock cycles between its edges. Straightforward implementation in FPGA with counter may only provide limited resolution. 
200-300MHz is maximum possible resolution for simple counter based solution.

More sofisticated approach is required to get better precision.

There is a hardware deserielizer primitive in Xilinx Series 7 FPGAs.

ISERDESE2 in DDR mode allows to pack 8 sequencial samples of serial signal into parallel 8 bit output.

Max base frequency of ISERDESE2 on Cora Z7 device is 600MHz. In DDR mode, it samples input with 600MHz * 2 = 1.2GHz rate and provides new output each 600MHz / 4 = 150MHz clock cycle.

Parallel output of deserializer may be processed with lower frequency (150MHz) still providing 1.2GHz resolution.

This design still can be improved using Oversampling technique.

Measuring of the same signal several times with different delay and then averaging may allow to increase precision. Doubling of measures gives one additional bit of signal period data.

Simple oversampling solution used in this design uses 8 ISERDESE2 primitives with IDELAYE2 primitives on their inputs. Delay values are chosen to distribute subsamples evenly inside one 1.2GHz clock cycle.
It allows to get 64 bits (samples) of deserialized data each 150MHz clock cycle instead of 8 samples available with single ISERDESE2 deserializer.
Oversampling effectively gives 1.2GHz * 8 = 9.6GHz precision.

Once we have 64 bits of parallel data, we need to process them to measure intervals between sequential signal edges.

Steps of oversampling frequency measure processing:

* Deserialize input signal into 64 bits (samples) once per 150MHz cycle.
* Convert 64 bit values into single bit change flag and 6 bit changed bit number (0..63)
* Track changes to accumulate duration between signal edges - gives half period value (since last change, for either 0 or 1 signal value).
* Add two last half-period values to get full period value (number of 9.6GHz samples the same edge - positive or negative, new value is available after each input change).
* Filter measured period value using 4-stage IIR filter - to increase number of available bits
