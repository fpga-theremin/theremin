/*
 * Copyright (c) 2010 by Cristian Maglie <c.maglie@bug.st>
 * Copyright (c) 2014 by Paul Stoffregen <paul@pjrc.com> (Transaction API)
 * Copyright (c) 2014 by Matthijs Kooijman <matthijs@stdin.nl> (SPISettings AVR)
 * SPI Master library for arduino.
 *
 * This file is free software; you can redistribute it and/or modify
 * it under the terms of either the GNU General Public License version 2
 * or the GNU Lesser General Public License version 2.1, both as
 * published by the Free Software Foundation.
 */

#ifndef _SPI_H_INCLUDED
#define _SPI_H_INCLUDED

#include "Arduino.h"

class SPISettings {
public:
    SPISettings(uint32_t clockIn, uint8_t bitOrderIn, uint8_t dataModeIn) {
    }

    SPISettings() {
    }
private:
    inline uint32_t clock() { return _clock; }

    uint32_t _clock;
    uint32_t tcr; // transmit command, pg 2664 (RT1050 ref, rev 2)
    friend class SPIClass;
};

class SPIClass { // Teensy 4
public:
public:
    constexpr SPIClass(uintptr_t myport, uintptr_t myhardware)
        : port_addr(myport), hardware_addr(myhardware) {
    }
    //	constexpr SPIClass(IMXRT_LPSPI_t *myport, const SPI_Hardware_t *myhardware)
    //		: port(myport), hardware(myhardware) {
    //	}
        // Initialize the SPI library
    void begin();

    // If SPI is to used from within an interrupt, this function registers
    // that interrupt with the SPI library, so beginTransaction() can
    // prevent conflicts.  The input interruptNumber is the number used
    // with attachInterrupt.  If SPI is used from a different interrupt
    // (eg, a timer), interruptNumber should be 255.
    //void usingInterrupt(uint8_t n) {
    //}
    //void usingInterrupt(IRQ_NUMBER_t interruptName);
    //void notUsingInterrupt(IRQ_NUMBER_t interruptName);

    // Before using SPI.transfer() or asserting chip select pins,
    // this function is used to gain exclusive access to the SPI bus
    // and configure the correct settings.
    void beginTransaction(SPISettings settings) {
    }

    // Write to the SPI bus (MOSI pin) and also receive (MISO pin)
    uint8_t transfer(uint8_t data) {
    }
    uint16_t transfer16(uint16_t data) {
    }

    void inline transfer(void *buf, size_t count) { transfer(buf, buf, count); }
    void setTransferWriteFill(uint8_t ch) { }
    void transfer(const void * buf, void * retbuf, size_t count) {}


    // After performing a group of transfers and releasing the chip select
    // signal, this function allows others to access the SPI bus
    void endTransaction(void) {
    }

    // Disable the SPI bus
    void end() {}

    // This function is deprecated.	 New applications should use
    // beginTransaction() to configure SPI settings.
    void setBitOrder(uint8_t bitOrder) {}

    // This function is deprecated.	 New applications should use
    // beginTransaction() to configure SPI settings.
    void setDataMode(uint8_t dataMode) {}

    // This function is deprecated.	 New applications should use
    // beginTransaction() to configure SPI settings.
    void setClockDivider(uint8_t clockDiv) {
    }
    void setClockDivider_noInline(uint32_t clk) {}

    // These undocumented functions should not be used.  SPI.transfer()
    // polls the hardware flag which is automatically cleared as the
    // AVR responds to SPI's interrupt
    void attachInterrupt() { }
    void detachInterrupt() { }

    // Teensy 3.x can use alternate pins for these 3 SPI signals.
    void setMOSI(uint8_t pin) {}
    void setMISO(uint8_t pin) {}
    void setSCK(uint8_t pin) {}

    // return true if "pin" has special chip select capability
    uint8_t pinIsChipSelect(uint8_t pin) {}
    bool pinIsMOSI(uint8_t pin) { return false; }
    bool pinIsMISO(uint8_t pin) { return false; }
    bool pinIsSCK(uint8_t pin) { return false; }
    // return true if both pin1 and pin2 have independent chip select capability
    bool pinIsChipSelect(uint8_t pin1, uint8_t pin2) { return false; }
    // configure a pin for chip select and return its SPI_MCR_PCSIS bitmask
    // setCS() is a special function, not intended for use from normal Arduino
    // programs/sketches.  See the ILI3941_t3 library for an example.
    uint8_t setCS(uint8_t pin) { return 0; }

private:
private:
    uintptr_t port_addr;
    uintptr_t hardware_addr;

    uint32_t _clock = 0;
    uint32_t _ccr = 0;

};

extern SPIClass SPI;
extern SPIClass SPI1;
extern SPIClass SPI2;

#endif
