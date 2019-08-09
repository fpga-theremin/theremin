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

* [theremin_sensor](https://github.com/fpga-theremin/theremin/tree/master/fpga/ip_repo/theremin_sensor)
* [encoders_board](https://github.com/fpga-theremin/theremin/tree/master/fpga/ip_repo/encoders_board)
* [lcd_controller](https://github.com/fpga-theremin/theremin/tree/master/fpga/ip_repo/lcd_controller)



