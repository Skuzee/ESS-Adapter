//ESS-Adapter.ino

/* Visit Github for more information: https://github.com/Skuzee/ESS-Adapter */

/*Basic Wiring Information for ATMEGA:
   (Pins 6 & 8 are default DATA Pins, but any GPIO pin will work if you change CONT_PIN and CONS_PIN.)
   -Pin 6 --> DATA to Controller
   -Pin 6 --> 750ohm Pull-up Resistor --> 3.3v supply from Console
   -Pin 8 --> DATA to Console
   -5v supply from console --> schottky diode --> Vcc/Vin Unregulated Voltage pin.
   -GND Pin --> Ground wires

	Make sure the Controller is still connected: insuring the following:
	 -5v supply from Console --> 5v to Controller (Rumble Motor)
	 -3.3v supply from Console --> 3.3v wire to Controller
	 -Grounds frFom Console --> Grounds to Controller

	 If your cable has a braided metal shieding, don't connect it to anything.
*/

//Options
#define INPUT_DISPLAY // - works on 32u4, needs newest compiled version of NintendoSpy (not the old release from 2014).
#define CONT_PIN 6  // Controller DATA Pin: 4 yellow, 6 master
#define CONS_PIN 8  // Console DATA Pin: 2 yellow, 8 master
//#define TRIGGER_THRESHOLD 100 // Makes the L and R triggers act like Gamecube version of OOT. range of sensitivity from 0 to 255. 0 being most sensitive. My controller has a range of ~30 to 240. Comment out to disable.
//#define DEBUG

//Includes
#include "src/Nintendo/src/Nintendo.h"
#include "ESS.hpp"
#include "extra.hpp"
#include "input-display.hpp"

#if NINTENDO_VERSION != 1337
#error "Incorrect Nintendo.h library! Compiling with the incorrect version WILL result in 5 volts being output to your controller/console! (Not good.) Make sure the custom Nintendo library (version 1337) is included in the ESS-Adapter/src folder and try again."
#endif

// Sets CONT_PIN on arduino to read from controller.
CGamecubeController GCcontroller(CONT_PIN);
CN64Controller N64controller(CONT_PIN);

// Sets CONS_PIN on arduino to write data to console.
CGamecubeConsole console(CONS_PIN);
Gamecube_Data_t data = defaultGamecubeData; // Initilize Gamecube data. Default needed for N64 data to convert correctly.


void setup() {
  Serial.begin(115200);
	loadSettings();

	initilizeStatusLights();

#ifdef DEBUG
  initializeDebug();
#endif
}

void loop() {
 	static uint8_t deviceID = 0;

	//need to flush serial buffer if it gets full. else program will halt

	switch(deviceID) {
		case 0:
			deviceID = checkConnection();
			break;

		case 5:
			deviceID = N64loop();
			break;

		default:
			deviceID = GCloop();
	}
}

uint8_t checkConnection() { // tests connection and gets device ID. returns Device ID.

  N64_Status_t connectionStatus; // create a generic Status (N64 and GC status are the same)
  connectionStatus.device = 0; // reset device ID

  n64_init(CONT_PIN, &connectionStatus); // initilize controller to update device ID
  tryPrint("Searching; ID:");
  tryPrintln(String(connectionStatus.device));
	delay(500);

	return char(connectionStatus.device);
}

void delayRead(uint8_t readDelay) { // OOT reads the controller twice every 16ms. The ideal timing is to wait as long as possible to read the controller data, so it's fresh when the console requests it. We wait 14ms every other read cycle. Prevents the arduino from reading the controller data too early and then having to wait 15ms to send it to the wii. Delay added to controller is between 0.635ms and 1.225ms. (average of 0.930ms).

		static uint8_t readDelayFlipFlop = 0;

		if(readDelayFlipFlop)
			delay(readDelay);

	  readDelayFlipFlop=!readDelayFlipFlop;
}

uint8_t GCloop() { // Wii vc version of OOT updates controller twice every ~16.68ms (with 1.04ms between the two rapid updates.)
	static uint8_t firstRead = 1; // 1 if the previous loop failed.

  delayRead(14);

	if (!GCcontroller.read()) { // failed read: increase failedReadCounter
		tryPrintln("Failed GC read:");
		firstRead = 1; // if it fails to read, assume next successful read will be the first.
	}
	else {
  	data = GCcontroller.getData(); // successful read: copy controller data to access.

		if(firstRead) { // special case: first read: change settings.
			firstRead = changeSettings(data.report);
		}
		else {
			#ifdef INPUT_DISPLAY
				writeToUSB_BYTE(data);
			#endif
		}
	}

#ifdef TRIGGER_THRESHOLD // If defined, makes Gamecube controller triggers act more like GC collectors edition. Analog press instead of having to click them all the way down.
  analogTriggerToDigitalPress(data.report, TRIGGER_THRESHOLD);
#endif

  normalize_origin(&data.report.xAxis, &data.origin.inititalData.xAxis);

	if(settings.ess_map == 1 && settings.game_selection == 0) // if OOT and ESS on:
  	invert_vc_gc(&data.report.xAxis);



  console.write(data); // Loop waits here until console requests an update.
  GCcontroller.setRumble(data.status.rumble); // Set controller rumble status.

	return GCcontroller.getDevice();
}

uint8_t N64loop() { // Wii vc version of OOT updates controller twice every ~16.68ms (with 1.04ms between the two rapid updates.)
	static uint8_t firstRead = 1;

  delayRead(14);

	if (!N64controller.read()) {
		tryPrintln("Failed N64 read:");
		firstRead = 1; // if it fails to read, assume next successful read will be the first.
	}
	else {
		if(firstRead || enterSettingsMenuN64Controller(N64controller.getReport())) { // special case: first read: change settings.
			N64toGC_buttonMap_Simple(N64controller.getReport(), data.report);
			firstRead = changeSettings(data.report);
		}
		else {
			switch(settings.game_selection) {

				case 0:
				N64toGC_buttonMap_OOT(N64controller.getReport(), data.report);
				break;

	      case 1:
				N64toGC_buttonMap_Yoshi(N64controller.getReport(), data.report);
				break;

				default:
				N64toGC_buttonMap_Simple(N64controller.getReport(), data.report);
			}

			#ifdef INPUT_DISPLAY
				writeToUSB_BYTE(data);
			#endif
		}


	}

  console.write(data);

	return N64controller.getDevice();
}
