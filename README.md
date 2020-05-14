# Introduction
This adapter modifies analog stick input values. For use with Legend of Zelda: Ocarina of Time. 
This version is for Gamecube controllers!  I have a dev version that supports N64 controllers here:
[N64-Dev](https://github.com/Skuzee/ESS-Adapter/tree/n64-dev)

## About
Ocarina of Time (OOT) on Gamecube (GC) and Wii run on Nintendo’s emulator called Virtual Console (VC). VC maps the GC controller values to certain in-game values. The algorithm poorly recreates the feel of the N64 version of OOT. This ESS-Adapter interprets controller input and scales/maps it to compensate for the VC map. The end result is hopefully an analog stick with a more traditional feel. 

## Usage & Limitations
Currently this code only works with 16MHz Atmel AVR boards due to some of the supporting libraries having AVR specific assembly code.

## Wiring
![alt text](https://raw.githubusercontent.com/Skuzee/ESS-Adapter/master/ESS-Adapter-Schematic.png " Logo Title Text 1")
note 1: There are too many variations for me to correctly suggest how to hook power to the arduino directly from the Wii. 
each Arduino has different mosfets/diodes/regulators/wiring. The absolute SAFEST way to power your arduino is from USB only!
That means using a short usb cord to one of the wii usb ports, or to your PC (for use with the input display function.)
Alternativly, you could wire the 5v wire from the controller cable to the VIN or 5v pin of your arduino...
IF YOU DO THAT THEN YOU CANT PLUG IN USB AND WII AT THE SAME TIME!!!! You could always cut the 5v wire in your usb cable if you wanted to use the input display option while powering it from the wii.
I'm really sorry this is how it is.
I've been researching a simple way to fix this issue, but it's not as easy as it seems. 

The following wiring information will reference Nintendo's Gamecube coloring scheme!
Be warned, most gamecube extension cables are different.

|Color | Use | Notes|
|--- | --- | ---|
|Red | Data 3.3v | |
|Green | Ground | |
|White | Ground | (Shown as Grey in schematic) |
|Blue | 3.3v Supply | |
|Yellow | 5v Supply | |
|Black | Shielding | (May not be present on some cables) |

 ### Parts & Tools
 At a minimum you'll need:
- A 16MHz Atmel AVR Arduino/Clone.
- A 750ohm Resistor (500ohm-1000ohm would work in a pinch.)
- A soldering iron.
- Tools to cut and strip wire.

Depending on what components you use, you may want:
- Heatshrink tubing
- A project enclosure
- Small cable ties for strain relief.
- Prototype PCB/Perf board.
- Straight and Right Angle pin headers.
- Dupont female plug crimp terminals & crimping tool.
- Assorted lengths of jumper wire.
- Kaptop tape.

## 3D Printing
 I've designed an enclosure for the trinket pro, and I'm working on one for the sparkfun pro micro now. Stay tuned for links and info!
 
## Community
Join our [Ocarina of Time Speedrunning Discord](https://discord.gg/EYU785K) to chat and ask any questions: Contact Angst in the #adapters-and-inputdisplays channel.