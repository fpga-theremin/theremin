# FPGA based theremin

Open source digital FPGA based theremin project.

[Theremin](https://en.wikipedia.org/wiki/Theremin) is an electronic musical instrument controlled without physical contact by the thereminist (performer).
It is named after the Westernized name of its Soviet inventor, Léon Theremin (Лев Термéн), who patented the device in 1928. 

This GitHub project is created to share some details of my design.

See [Wiki](https://github.com/fpga-theremin/theremin/wiki) for project details.

## HDL sources: fpga/ip_repo

Modules are written in SystemVerilog.

Some of modules use Xilinx Series 7 specific hardware blocks.

* [theremin_sensor](https://github.com/fpga-theremin/theremin/tree/master/fpga/ip_repo/theremin_sensor)
* [encoders_board](https://github.com/fpga-theremin/theremin/tree/master/fpga/ip_repo/encoders_board)

## Shared design files

* [Theremin cabinet plywood laser cut design](https://github.com/fpga-theremin/theremin/tree/master/hardware/cabinet)
* [Oscillator shematics and PCB design](https://github.com/fpga-theremin/theremin/tree/master/hardware/oscillator)


