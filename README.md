# FPGA based theremin

Open source digital FPGA based theremin project.

[Theremin](https://en.wikipedia.org/wiki/Theremin) is an electronic musical instrument controlled without physical contact by the thereminist (performer).
It is named after the Westernized name of its Soviet inventor, Léon Theremin (Лев Термéн), who patented the device in 1928. 

## Classic theremins

Theremin generates sound with pitch and volume depending on distance from hand to antenna.

![classic theremin block diagram](https://upload.wikimedia.org/wikipedia/commons/thumb/c/cb/Block_diagram_Theremin.png/330px-Block_diagram_Theremin.png)

The heart of theremin is variable oscillator controlled by capacity of antenna.

Antenna capacity varies in range ~ 7..9pF (increases when hand is getting closer to antenna).

It should be measured with 1/1000pF or even better.

Most sensitive method of capacity measure is using of LC tank resonant frequency changes depending on capacity value.

Classic way is to use heterodyning technique to convert frequency of LC oscillator to audible range using heterodyning.

There are some challenges:

- obtaining stable, sensitive oscillator with linear response (notes must be distributed almost equally based on hand-to-antenna distance)

- obtaining nice sounding timbre of produced signal


## Digital theremins

In general, digital theremin is digital synthesizer controlled by theremin antennas.

Theoretically, modern hardware allows to simulate any analog theremin cirquit behavior.

Digital theremins don't need to have audible frequency as input - it can do frequency conversion and linearization internally before output signal synthesis.

## FPGA

MCUs are not powerful enough for precise measure of oscillator frequencies.

