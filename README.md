﻿# Introduction
This adapter modifies analog stick input values. For use with Legend of Zelda: Ocarina of Time.  
This version supports both N64 and Gamecube controllers. Selection is automatic. Just plug in a controller.  
This version has an input display and works with the newest version of nintendospy (not the 2014 release).  
This adapter also functions as a generic n64 to gamecube controller adapter, although I cannot guarantee that the button mapping will work for all games.  

## About
Ocarina of Time (OOT) on Gamecube (GC) and Wii run on Nintendo’s emulator called Virtual Console (VC). VC maps the GC controller values to certain in-game values. The algorithm poorly recreates the feel of the N64 version of OOT. This ESS-Adapter interprets controller input and scales/maps it to compensate for the VC map. Applying the inverse of the function means that we cancel out the bad VC map and get a result as close as possible to the original N64 analog stick range.  

## Usage & Limitations
Currently this code only works with 16MHz Atmel AVR boards due to some of the supporting libraries having AVR specific assembly code.

## Settings Menu Controller Shortcuts
Connecting the adapter to a computer via usb and opening a serial monitor (like the one in the Arduino IDE) will allow you to view the current settings.

Gamecube Controller: 
Press and Hold L and R triggers all the way in.  
Press X Y and Start for ~3 seconds to reset the controller.  
Keep L and R held.  
D-pad Left/Right will change between N64 button mappings. Currently There is OOT, Yoshi Story, and a Generic Map.  
D-pad Up/Down will change between ESS options. Currently There is ESS ON and ESS OFF for OOT and Yoshi Story. When OOT/Yoshi game is selected, the ESS defaults to ON. Generic Map does not have ESS functionality.  

## Wiring
Any digital input pins will work. **Make sure you have them set correctly at the top of the .ino file.** Depending on the board and layout sometimes I use different pins, so double check. Pins 10,14,15,16,18,19 are used for optional RGB indicator lights.  
Both Common Cathode and Common Anode LEDs work and setting can be set in extras.hpp  
LED 1: Red pin 10, Green pin 16, Blue pin 14  
LED 2: Red pin 15, Green pin 18(A0), Blue pin 19(A1)  

#### A Note About Powering different Arduinos
There are too many variations for me to correctly suggest how to hook power to the arduino directly from the Wii.Each Arduino has different mosfets/diodes/regulators/wiring. The absolute SAFEST way to power your arduino is from USB only! That means using a short usb cord to one of the wii usb ports, or to your PC (for use with the input display function.)  
If you don't intend to use the input display, or you want it to work without the usb cable, it's possible to connect the 5v wire from the controller cable to the arduino directly. As stated above, every arduino is different and I highly suggest you use a diode and know what you are doing.  
- Arduino UNO: The safest way to power would be either from a USB cable only (connected to the Wii or computer). It's possible to power it from the Wii 5v controller wire using a step-up DC-DC boost converter (~7v-9v) to the barrel jack.  
- Arduino Nano: Power the board from the Wii 5v wire through a Schottky diode to the 5v pin (not the VIN pin)  
- Sparkfun Pro Micro 5v: Power from the Wii 5v wire through a Schottky diode to the VCC pin (not the RAW pin). Make sure PCB jumper J1 is not soldered closed.  
![Jumper J1](https://raw.githubusercontent.com/Skuzee/ESS-Adapter/master/JumperJ1.jpg "Jumper J1")  
![Wiring](https://raw.githubusercontent.com/Skuzee/ESS-Adapter/master/GC-Schematic.png "Basic Pro Micro Schematic")  
The following wiring information will reference Nintendo's Gamecube coloring scheme!  
Be warned, most gamecube extension cables are different.  

|Nintendo Color | Use | Notes
|--- | --- | ---|
|Yellow | 5v Supply | |
|Red | Data 3.3v | |
|Green | Ground | |
|White | Ground | (Shown as Grey in schematic) |
|Black | Shielding | (May not be present on some cables) |
|Blue | 3.3v Supply | |

## Parts & Tools
 At a minimum you'll need:
- A 16MHz Atmel AVR Arduino/Clone.
- A 750 ohm Resistor (500ohm-1000ohm would work in a pinch.)
- A soldering iron.
- Tools to cut and strip wire.

Depending on what components you use, you may want:
- Heat shrink tubing
- A project enclosure
- Small cable ties for strain relief.
- Prototype PCB/Perf board.
- Straight and Right Angle pin headers.
- Dupont female plug crimp terminals & crimping tool.
- Assorted lengths of jumper wire.
- Kapton tape.

## Community
Join our [Ocarina of Time Speedrunning Discord](https://discord.gg/EYU785K) to chat and ask any questions: Contact Angst#4857 in the #adapters-and-inputdisplays channel.

## Changelog
- man so much I lost track.
- added single menu navigation with n64 or gc controller
- added hotkey to reset n64 controller connection to access settings menu
- factory settings burn to eeprom and load on start.
- factory setting reset.
- added indicator lights for optional game/ess indication.
- fixed bug: loss of serial connection would fill serial buffer and halt program. added a "tryPrint" that only prints to the serial buffer if it can fit. Having issues with missing debug data and printing settings to serial because the characters fill the buffer too fast. Possible fix is having an additional ring buffer that's larger than 64bytes to send data without halting program.
- expanded settings to allow 8 games and 8 ess map options. not all implemented.
- added generic n64 button map and a yoshi story map because my friend wanted it. <3