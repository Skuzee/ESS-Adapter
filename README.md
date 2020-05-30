# Introduction
This adapter modifies analog stick input values. For use with Legend of Zelda: Ocarina of Time. 
Check out the other version for n64 controller support!(https://github.com/Skuzee/ESS-Adapter/tree/n64-dev)
There is also an input display function, but it only works with Atmega 32u4 boards and the latest compiled version of NintendoSpy.

## About
Ocarina of Time (OOT) on Gamecube and Wii run on Nintendo’s emulator called Virtual Console (VC). VC maps the Gamecube controller values to certain in-game values. The algorithm poorly recreates the feel of the N64 version of OOT. This ESS-Adapter interprets controller input and scales/maps it to compensate for the VC map. The end result is hopefully an analog stick with a more traditional feel. 
This mapping is specific to OOT only, and should work with GZ The Practice Rom.
 
## Usage & Limitations
Currently this code only works with 16MHz Atmel AVR boards due to some of the supporting libraries having AVR specific assembly code. 
There are some limitations on how some boards can be powered directly from the Wii. Failure to use caution may damage your Wii or PC USB port!
I suggest the Sparkfun Pro Micro 5v 16MHz (or a clone). 

## Wiring
![Wiring](https://raw.githubusercontent.com/Skuzee/ESS-Adapter/master/ESS-Adapter-Schematic.png "Basic Pro Micro Schematic")

There are too many variations for me to correctly suggest how to hook power to the Arduino directly from the Wii for each type. 
Each Arduino/variant has different mosfets/diodes/regulators/wiring; it is not always safe to power the board from the Wii and the USB simultaniously. 
The absolute SAFEST way to power your Arduino is from USB only!
That means using a short USB cord to one of the Wii USB ports, or to your PC (for use with the input display function.)
Just make sure that whichever board you choose, that you take precautions to avoid accidentally powering it from the Wii and USB power at the same time. Some boards do not have built in protection and it could damage the board, Wii, or your PC!
This can usually be prevented with a step-up booster board, diodes, relays, or other wiring, but methods may vary. 

-Arduino UNO: The safest way to power would be either from a USB cable only (connected to the Wii or computer) OR from the Wii 5v wire using a step-up converter to the barrel jack. (The power protection diode does not protect the VIN pin, so if you use the VIN pin, use an external diode to prevent USB voltage from back-feeding into the Wii.)
-Arduino Nano: Power the board from the Wii 5v wire through a Schottky diode to the 5v pin (not the VIN pin)
-Sparkfun Pro Micro 5v: Power from the Wii 5v wire through a Schottky diode to the VCC pin (not the RAW pin). Make sure PCB jumper J1 is not soldered closed.

![Jumper J1](https://raw.githubusercontent.com/Skuzee/ESS-Adapter/master/JumperJ1.jpg "Jumper J1")


 ### Parts & Tools
 At a minimum you'll need:
- A 16MHz Atmel AVR Arduino/Clone. I suggest a sparkfun Pro Micro or similar 32u4 clone with USB port.
- A 740ohm Resistor (500ohm-1000ohm would work in a pinch.)
- A soldering iron.
- Tools to cut and strip wire.

Depending on what components you use, you may want:
- Heatshrink tubing
- A project enclosure
- Small cable ties for strain relief.
- Prototype PCB/Perf board.
- Straight and Right Angle pin headers.
- DuPont female plug crimp terminals & crimping tool.
- Assorted lengths of jumper wire.
- Kapton tape.

## 3D Printing
 I've designed an enclosure for the Adafruit Trinket Pro, and I'm working on one for the Sparkfun Pro Micro now. Stay tuned for links and info!
 
## Community
Join our [Ocarina of Time Speedrunning Discord](https://discord.gg/EYU785K) to chat and ask any questions: Contact Angst in the #adapters-and-inputdisplays channel.