Modified! Arduino Nintendo Library 1337  
==============================  
This version of Nicohood's Library has been modified to work on 5v logic level 16MHz ARM processors without the use of a Logic Level Converter.  
This version requires a 740ohm pullup resistor (500 to 1000ohm) between the controller data pin and 3.3v  
By switching the data pin between OUTPUT LOW and INPUT (NO PUULUP) We can pull the data line low to communicate without outputting 5v to the 3.3 data line.  
Checkout https://github.com/Skuzee/ESS-Adapter for my main hardware project where I use this library to make a n64/gamecube controller adapter and input display.  


![header](header.jpg)

This library is made to connect Nintendo Controllers to your Arduino very easy.
Make sure you grab the right hardware, tear off some cables to use your controllers
on your PC for example. The requirement are written in each library readme part.

<a href="https://www.buymeacoffee.com/nicohood" target="_blank"><img src="https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png" alt="Buy Me A Coffee" style="height: auto !important;width: auto !important;" ></a>

##### Supported devices
Host mode means that you can hook up an controller to your Arduino and read its buttons.
Controller mode means that your Arduino can act as controller.

* GamecubeConsole (Device Mode)
* GamecubeController (Host Mode)
* N64Console (Device Mode)
* N64Controller (Host Mode)

##### Planned features
* Wii-Mote (USB Host shield)
* Wii Nunchuk (I2C)
* Wii Classic Controller (I2C)
* Wii-Mote plus(USB Host shield)
* Wiiu Pro Controller (USB Host shield)
* SNES Controller (I don't have any)

##### Todo:
* N64 rumble -> example
* N64 -> USB example
* GC to N64 example

##### Possible projects:
* Gamecube HID Controller
* Gamecube to X Adapter
* X to Gamecube Adapter
* Selfmade Gamecube Controller
* Wireless Gamecube Controller
* 2 Player merged Controller
* Manipulated (shortcut) Gamecube Controller
* Gamecube Controller as Arduino input

Download
========

Download the zip, extract and remove the "-master" of the folder.
Install the library [as described here](http://arduino.cc/en/pmwiki.php?n=Guide/Libraries).
You can also use the Arduino Library Manager to get the latest version.

Checkout the ['dev' branch](https://github.com/NicoHood/Nintendo/tree/dev) to test the bleeding edge of this software. It might now work at all or has a lot of debugging stuff in it.

Wiki
====

All documentation moved to the [wiki page](https://github.com/NicoHood/Nintendo/wiki).

Contact
=======

Contact information can be found here:

www.nicohood.de
