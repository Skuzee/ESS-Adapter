# Introduction
This adapter modifies analog stick input values. For use with Legend of Zelda: Ocarina of Time. 
Currently works only with Gamecube controllers!  Support N64 controllers coming soon.

## About
Ocarina of Time (OOT) on Gamecube (GC) and Wii run on Nintendo’s emulator called Virtual Console (VC). VC maps the GC controller values to certain in-game values. The algorithm poorly recreates the feel of the N64 version of OOT. This ESS-Adapter interprets controller input and scales/maps it to compensate for the VC map. The end result is hopefully an analog stick with a more traditional feel. 

## Usage & Limitations
Currently this code only works with 16MHz Atmel AVR boards due to some of the supporting libraries having AVR specific assembly code.

## Wiring
![alt text](https://raw.githubusercontent.com/Skuzee/ESS-Adapter/master/ESS-Adapter-Schematic.png " Logo Title Text 1")

The following wiring information will reference Nintendo's Gamecube coloring scheme!
Be warned, most gamecube extension cables are different.
Color | Use | Notes
--- | --- | ---
Red | Data 3.3v
Green | Ground
White | Ground | (Shown as Grey in schematic)
Blue | 3.3v Supply
Yellow | 5v Supply
Black | Shielding | (May not be present on some cables)

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
 I've designed an enclosure for the trinket pro, and I'm working on one for the Digispark attiny85. Stay tuned for links and info!
 
## Community
Join our [Ocarina of Time Speedrunning Discord](https://discord.gg/EYU785K) to chat and ask any questions: Contact Angst in the #adapters-and-inputdisplays channel.