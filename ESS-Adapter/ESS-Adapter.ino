//ESS-Adapter.ino -- master

//The Following code is released under GNU GENERAL PUBLIC LICENSE Version 3 and uses a nicohood's nintendo library released under MIT license.

/* Visit Github for more information: https://github.com/Skuzee/ESS-Adapter */

/*Basic Wiring Information for ATMEGA:
  (Any GPIO pin will work. Please check CONSOLE_PIN and CONT_PIN.)
  -CONSOLE_PIN --> DATA to Console
	
  ***One pull-up resistor per controller DATA pin.***
  -CONT_PIN --> DATA to Controller
  -CONT_PIN --> 750ohm Pull-up Resistor --> 3.3v supply from Console
	 	 
  -5v supply from console --> schottky diode --> Vcc Unregulated Voltage pin.
  -GND Pin --> Ground wires

	Make sure the Controller is still connected: insuring the following:
	 -5v supply from Console --> 5v to Controller (Rumble Motor)
	 -3.3v supply from Console --> 3.3v wire to Controller
	 -Grounds from Console --> Grounds to Controller

	 If your cable has a braided metal shieding, don't connect it to anything.
*/


// Both Controller types can use the same pin, HOWEVER!
// You CANNOT plug two controllers into the same pin at the same time without error.
// If you want two plugs on the same adapter use one pin per controller type.
// (i.e. PIN 4 for GC controller, PIN 3 for N64) Each with their own pull-up resistor.
#define CONT_PIN_GC 4  // GC Controller DATA Pin
#define CONT_PIN_N64 4  // N64 Controller DATA Pin
#define CONSOLE_PIN 2  // Console DATA Pin: 2 yellow, 8 master branch, 2 Dev board

#define INPUT_DISPLAY // - works on 32u4, needs newest compiled version of NintendoSpy/Retrospy.
#define TRIGGER_THRESHOLD // Makes the L and R triggers act like Gamecube version of OOT. range of sensitivity from 0 to 255. 0 being most sensitive. My controller has a range of ~30 to 240. Comment out to disable. Configurable with controller settings menu.
//#define DEBUG // overwrites IndicatorLights and used for data analyzer.

//Includes
#include "src/Nintendo/src/Nintendo.h"
#include "ESS.hpp"
#include "extra.hpp"
#include "input-display.hpp"

#if NINTENDO_VERSION != 1337
	#error "Incorrect Nintendo.h library! Compiling with the incorrect version WILL result in 5 volts being output to your controller/console! (Not good.) Make sure the custom Nintendo library (version 1337) is included in the ESS-Adapter/src folder and try again."
#endif

// Sets CONT_PIN on arduino to read from controller.
CGamecubeController GCcontroller(CONT_PIN_GC);
CN64Controller N64controller(CONT_PIN_N64);

// Sets CONSOLE_PIN on arduino to write data to console.
CGamecubeConsole console(CONSOLE_PIN);
Gamecube_Data_t data = defaultGamecubeData; // Initilize Gamecube data. Default needed for N64 data to convert correctly.
N64_Report_t N64report = defaultN64Data.report;

void setup() {
  Serial.begin(115200);
  loadSettings();

  #ifdef DEBUG
    initializeDebug();
  #else
    initilizeStatusLights();
  #endif
}

void loop() {
  static uint8_t deviceID = 0;

  // Need to flush serial buffer if it gets full. else program will halt

  switch (deviceID) {
    case 0: // No controller connected.
      deviceID = checkConnection();
      break;

    case 5: // N64 controller detected.
      deviceID = N64loop();
      break;

    default: // Assume anything else is a GC controller.
      deviceID = GCloop();
  }
}

uint8_t checkConnection() { // Tests for a connection and gets device ID. returns Device ID.
  N64_Status_t connectionStatus; // Create a generic Status (N64 and GC status are the same)
  connectionStatus.device = 0; // Reset device ID

	// Initilize controller to update device ID
  n64_init(CONT_PIN_GC, &connectionStatus); // Check first pin for a controller.
	// If CONT_PIN_GC == CONT_PIN_N64 then this will return either controller type.
	
	if(!connectionStatus.device) { // If no controller connected to first pin:
		n64_init(CONT_PIN_N64, &connectionStatus); // Check the other pin.
		// If CONT_PIN_GC != CONT_PIN_N64 then this will return n64 if connected.
	}
	
  tryPrint("Searching; ID:");
  tryPrintln(String(connectionStatus.device));
  delay(500);

  return char(connectionStatus.device);
}

void delayRead(uint8_t readDelay) { // OOT reads the controller twice every 16ms. (as in, two reads in quick succession ~1ms apart.) The ideal timing is to wait as long as possible to read the controller data, so it's fresh when the console requests it. We wait 14ms every other read cycle. Prevents the arduino from reading the controller data too early and then having to wait 15ms to send it to the wii. Input delay added to controller is between 0.6ms and 0.9ms. (average of 0.6ms).
  static uint8_t readDelayFlipFlop = 0;

  if (readDelayFlipFlop)
    delay(readDelay);

  readDelayFlipFlop = ! readDelayFlipFlop;
}

uint8_t GCloop() { // Wii vc version of OOT updates controller twice every ~16.68ms (with 1.04ms between the two rapid updates.)
  static uint8_t firstRead = 1; // 1 if the previous loop failed.

  delayRead(14); // This helps reduce input lag. remove if a game/controller combo is glitching.

  if (!GCcontroller.read()) { // Attempt to read controller.
    tryPrintln("Failed GC read:");
    firstRead = 1; // If it fails to read, assume next successful read will be the first.
  }
  else {
    data = GCcontroller.getData(); // Successful read: copy controller data to access.

    if (firstRead) { // Special case: first read: change settings.
      firstRead = changeSettings(data.report); // Loops while settings are being changed.
    }
    else {
			
		  #ifdef TRIGGER_THRESHOLD // If defined, makes Gamecube controller triggers act more like GC collectors edition. Analog press instead of having to click them all the way down.
		    analogTriggerToDigitalPress(data.report);
		  #endif
			
      #ifdef INPUT_DISPLAY
        writeToUSB_BYTE(data);
      #endif
    }
  }

  normalize_origin(&data.report.xAxis, &data.origin.inititalData.xAxis);

  if (settings.ess_map == ESS_ON && settings.game_selection == GAME_OOT) // if OOT and ESS on:
    invert_vc_gc(&data.report.xAxis);

  console.write(data); // Loop waits here until console requests an update.
  GCcontroller.setRumble(data.status.rumble); // Set controller rumble status.

  return GCcontroller.getDevice();
}

uint8_t N64loop() { // Wii vc version of OOT updates controller twice every ~16.68ms (with 1.04ms between the two rapid updates.)
  static uint8_t firstRead = 1; // 1 if the previous loop failed.
	

  delayRead(14); // This helps reduce input lag. remove if a game/controller combo is glitching.
	
  if (!N64controller.read()) { // Attempt to read controller.
    tryPrintln("Failed N64 read:");
    firstRead = 1; // If it fails to read, assume next successful read will be the first.
  }
  else {
		N64report = N64controller.getReport();
			
    if (firstRead || enterSettingsMenuN64Controller(N64report)) { // Special case: first read: change settings.
      N64toGC_buttonMap_Generic(N64report, data.report); // Use the generic button map for the settings menu to keep things consistent.
      firstRead = changeSettings(data.report); // Loops while settings are being changed.
    }
    else {
			
      #ifdef INPUT_DISPLAY
        writeToUSB_BYTE(N64report);
      #endif

      switch (settings.game_selection) { // Convert N64 data/buttons to GC data/buttons depending on what game/ess setting is selected

        case GAME_OOT:
          N64toGC_buttonMap_OOT(N64report, data.report);
          break;

        case GAME_YOSHI:
          N64toGC_buttonMap_Yoshi(N64report, data.report);
          break;

        default:
          N64toGC_buttonMap_Generic(N64report, data.report);
      }
    }
  }

  console.write(data); // Loop waits here until console requests an update.
  // N64 Rumble motor function???

  return N64controller.getDevice();
}
