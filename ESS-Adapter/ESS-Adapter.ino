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


//Includes
#include "src/Nintendo/src/Nintendo.h"
#include "ESS.hpp"
#include "extra.hpp"
#include "input-display.hpp"


//Options
#define GAMECUBE_CONTROLLER
//#define N64_CONTROLLER - not used in this version - see n64-dev branch
//#define INPUT_DISPLAY // - works on 32u4, needs newest compiled version of NintendoSpy (not the old release from 2014).
#define CONT_PIN 6  // Controller DATA Pin
#define CONS_PIN 8  // Console DATA Pin
#define TRIGGER_THRESHOLD 40 // Makes the L and R triggers act more like Gamecube version of OOT. 0 to 125. 0 being most sensitive. Comment out to disable.


#if NINTENDO_VERSION != 1337
	#error "Incorrect Nintendo.h library! Compiling with the incorrect version WILL result in 5 volts being output to your controller/console! (Not good.) Make sure the custom Nintendo library (version 1337) is included in the ESS-Adapter/src folder and try again."
#endif


CGamecubeController controller(CONT_PIN); // Sets Controller Pin on arduino to read from controller.
CGamecubeConsole console(CONS_PIN); // Sets D8 on arduino to write data to console.


void setup() {
  Serial.begin(115200);

}

void loop() {

  controller.read();
  Gamecube_Data_t data = controller.getData();
  Gamecube_Data_t data_original;	
  memcpy((void*)&data_original, (void*)&data, sizeof(Gamecube_Data_t));	
	
  normalize_origin(&data.report.xAxis, &data.origin.inititalData.xAxis);
  invert_vc_gc(&data.report.xAxis);

  //startButtonResets(data);

  #ifdef TRIGGER_THRESHOLD
    analogTriggerToDigitalPress(data, TRIGGER_THRESHOLD);
  #endif

  #ifdef INPUT_DISPLAY
    writeToUSB_BYTE(data_original);
  #endif


  console.write(data);
  controller.setRumble(data.status.rumble);
}
