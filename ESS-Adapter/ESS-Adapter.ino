//ESS-split.ino

/* Visit Github for more information: https://github.com/Skuzee/ESS-Adapter */

/*Basic Wiring Information for ATMEGA:
   -Pins 6 & 8 are default DATA Pins, but any GPIO pin will work.
   -Pin 6 --> DATA to Controller
   -Pin 6 --> 750ohm Pull-up Resistor --> 3.3v supply from Console.=
   -Pin 8 --> DATA to Console
   -Currently, I suggest only powering the board from usb only.
   -GND Pin --> Ground wires
   -optional: Pin 4 --> RST Pin (used to reset adapter via Controller by holding the start button for ~6 seconds. Only Used for debugging and programming.)

	Make sure the Controller is still connected: insuring the following:
	 -5v supply from Console --> 5v to Controller (Rumble Motor)
	 -3.3v supply from Console --> 3.3v wire to Controller
	 -Grounds from Console --> Grounds to Controller

	 If your cable has a braided metal shieding, don't connect it to anything.
*/

//Options
//#define INPUT_DISPLAY // - works on 32u4, needs newest compiled version of NintendoSpy (not the old release from 2014).
#define CONT_PIN 4  // Controller DATA Pin
#define CONS_PIN 2  // Console DATA Pin
#define TRIGGER_THRESHOLD 40 // Makes the L and R triggers act more like Gamecube version of OOT. 0 to 125. 0 being most sensitive. Comment out to disable.
//#define DEBUG

//Includes
#include "src/Nintendo/src/Nintendo.h"
#include "ESS.hpp"
#include "extra.hpp"
#include "input-display.hpp"

#if NINTENDO_VERSION != 1337
	#error "Incorrect Nintendo.h library! Compiling with the incorrect version WILL result in 5 volts being output to your controller/console! (Not good.) Make sure the custom Nintendo library (version 1337) is included in the ESS-Adapter/src folder and try again."
#endif

CGamecubeController GCcontroller(CONT_PIN); // Sets Gamecube Controller Pin on arduino to read from controller.
CN64Controller N64controller(CONT_PIN); // Sets N64 Controller Pin on arduino to read from controller.
CGamecubeConsole console(CONS_PIN); // Sets D8 on arduino to write data to console.
Gamecube_Data_t data = defaultGamecubeData; // initilize Gamecube data. Default needed for N64 data to convert correctly.


void setup() {
  
  Serial.begin(115200); 
}


void loop() {

  //try connecting to controllers until one is found
  //while GCcontroller is connected:
  GCloop();
  //while N64controller is conencted:
  //N64loop();

}


void GCloop() {

  GCcontroller.read();  // Read controller
  data = GCcontroller.getData(); // Copy controller data to access.

  #ifdef TRIGGER_THRESHOLD // If defined, makes Gamecube controller triggers act more like GC collectors edition. Analog press instead of having to click them all the way down.
    analogTriggerToDigitalPress(data, TRIGGER_THRESHOLD);
  #endif

  #ifdef INPUT_DISPLAY // Copies data to serial buffer and sends to NintendoSpy. Data format is from Nicohood's Nintendo Library and only works with the newest version of Nintendospy. (It's a different data order than the NintendoSpy uses by default.)
    writeToUSB_BYTE(data);
  #endif

  //ESS
  normalize_origin(&data.report.xAxis, &data.origin.inititalData.xAxis);
  invert_vc_gc(&data.report.xAxis);

  console.write(data); // Loop waits here until console requests an update.
  GCcontroller.setRumble(data.status.rumble); // Set controller rumble status.
}


void N64loop() {

  N64controller.read();
  convertToGC(N64controller.getReport(), data.report);

  #ifdef TRIGGER_THRESHOLD
    analogTriggerToDigitalPress(data, TRIGGER_THRESHOLD);
  #endif

  #ifdef INPUT_DISPLAY
    writeToUSB_BYTE(data);
  #endif

  console.write(data);
}
