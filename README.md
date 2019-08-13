# FPGA based theremin

Open source digital FPGA based theremin project.

Hardware design and build instructions can be found on [FPGA Theremin Project Page](https://fpga-theremin.github.io/theremin/)

[Theremin](https://en.wikipedia.org/wiki/Theremin) is an electronic musical instrument controlled without physical contact by the thereminist (performer).
It is named after the Westernized name of its Soviet inventor, Léon Theremin (Лев Термéн), who patented the device in 1928. 

FPGA Theremin project is attempt to build modern digital theremin with rich set of features.

## License 
FPGA Theremin is open source hardware and software project.

All hardware designed for this project 
is published under [TAPR Open Hardware License](https://www.tapr.org/TAPR_Open_Hardware_License_v1.0.txt)

All software (including both HDL and C/C++ code) 
is published under [GNU GENERAL PUBLIC LICENSE Version 2](https://www.gnu.org/licenses/old-licenses/gpl-2.0.txt)


## HDL sources

Modules are written in SystemVerilog.

Some of modules use Xilinx Series 7 specific hardware blocks.

HLD code for modules:

* [theremin_sensor](https://github.com/fpga-theremin/theremin/tree/master/fpga/ip_repo/theremin_ip/src/theremin_sensor) - double channel high precision frequency meter
* [encoders_board](https://github.com/fpga-theremin/theremin/tree/master/fpga/ip_repo/theremin_ip/src/encoders_board) - interfacing to 5 incremental encoders with buttons and one tact button
* [lcd_controller](https://github.com/fpga-theremin/theremin/tree/master/fpga/ip_repo/theremin_ip/src/lcd_controller) - LCD controller with RGB interface and DMA
* [audio_io](https://github.com/fpga-theremin/theremin/tree/master/fpga/ip_repo/theremin_ip/src/audio_io) - audio out 2 * stereo * 24bit * 48KHz I2S outputs and one stereo * 24bit * 48KHz I2S input
* [theremin_i2c](https://github.com/fpga-theremin/theremin/tree/master/fpga/ip_repo/theremin_ip/src/theremin_i2c) - I2C support
* [theremin_io](https://github.com/fpga-theremin/theremin/tree/master/fpga/ip_repo/theremin_ip/src/theremin_io) - Top Level Module combining all theremin peripherials



