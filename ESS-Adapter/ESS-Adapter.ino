//ESS-Adapter.ino -- Multi-Controller

/* Visit Github for more information: https://github.com/Skuzee/ESS-Adapter */

/*
	This is my Dev board that supports 4 controllers.
	All pins are broken out.
	4 pins have external 750ohm pull-up resistors. (3,4,5,6)
	The pinout is as follows:
	2 Console DATA
	3 Controller 1
	4 Controller 2
	5 Controller 3 ? double check
	6 Controller 4 ?
*/

//Options
#define INPUT_DISPLAY // - works on 32u4, needs newest compiled version of NintendoSpy (not the old release from 2014).
#define CONS_PIN 2  // Console DATA Pin: 2 yellow, 8 master
#define TRIGGER_THRESHOLD 100 // Makes the L and R triggers act like Gamecube version of OOT. range of sensitivity from 0 to 255. 0 being most sensitive. My controller has a range of ~30 to 240. Comment out to disable.
//#define DEBUG

//Includes
#include "src/Nintendo/src/Nintendo.h"
#include "ESS.hpp"
#include "extra.hpp"
#include "input-display.hpp"

#if NINTENDO_VERSION != 1337
#error "Incorrect Nintendo.h library! Compiling with the incorrect version WILL result in 5 volts being output to your controller/console! (Not good.) Make sure the custom Nintendo library (version 1337) is included in the ESS-Adapter/src folder and try again."
#endif

const uint8_t CONT_PIN[] = {3,4,5,6};

CGamecubeController GCcontroller[] = {
	CGamecubeController(CONT_PIN[0]),
	CGamecubeController(CONT_PIN[1]),
	CGamecubeController(CONT_PIN[3]),
	CGamecubeController(CONT_PIN[4])
	};

CN64Controller N64controller[] = {
	CN64Controller(CONT_PIN[0]),
	CN64Controller(CONT_PIN[1]),
	CN64Controller(CONT_PIN[2]),
	CN64Controller(CONT_PIN[3])
	};

CGamecubeConsole console(CONS_PIN); // Sets D8 on arduino to write data to console.

Gamecube_Data_t data[4];


void setup() {

	for(uint8_t i=0; i<2;i++) {
		data[i]= defaultGamecubeData; // initilize Gamecube data. Default needed for N64 data to convert correctly.
		data[i].status.device = 0;
	}

  Serial.begin(115200);
	loadSettings();

	initilizeStatusLights();

#ifdef DEBUG
  initializeDebug();
#endif
}

void loop() {

	delay(100); // ******************* slow down controller polling

	//need to flush serial buffer if it gets full. else program will halt
	for(uint8_t i=0; i<2; i++) {

		switch(data[i].status.device) {

			case 0:
				data[i].status.device = checkConnection(CONT_PIN[i]);
				break;

			case 5:
				data[i].status.device = N64loop(i);
				break;

			default:
				data[i].status.device = GCloop(i);
		}
	}
}

uint8_t checkConnection(uint8_t cont_pin) { // tests connection and gets device ID. returns Device ID.

  N64_Status_t connectionStatus; // create a generic Status (N64 and GC status are the same)
  connectionStatus.device = 0; // reset device ID

  n64_init(cont_pin, &connectionStatus); // initilize controller to update device ID
  tryPrintln(String(cont_pin));
  //tryPrintln(String(connectionStatus.device));
	delay(500);

	return char(connectionStatus.device);
}

void delayRead(uint8_t readDelay) { // OOT reads the controller twice every 16ms. The ideal timing is to wait as long as possible to read the controller data, so it's fresh when the console requests it. We wait 14ms every other read cycle. Prevents the arduino from reading the controller data too early and then having to wait 15ms to send it to the wii. Delay added to controller is between 0.635ms and 1.225ms. (average of 0.930ms).

		static uint8_t readDelayFlipFlop = 0;

		if(readDelayFlipFlop)
			delay(readDelay);

	  readDelayFlipFlop=!readDelayFlipFlop;
}

uint8_t GCloop(uint8_t controller) { // Wii vc version of OOT updates controller twice every ~16.68ms (with 1.04ms between the two rapid updates.)
	static uint8_t firstRead = 1; // 1 if the previous loop failed.

  //delayRead(14);

	if (!GCcontroller[controller].read()) { // failed read: increase failedReadCounter
		tryPrintln("Failed to read GC controller:");
		firstRead = 1; // if it fails to read, assume next successful read will be the first.
	}
	else {
  	data[controller] = GCcontroller[controller].getData(); // successful read: copy controller data to access.

		if(firstRead) { // special case: first read: change settings.
			firstRead = changeSettings(data[controller].report);
		}
		else {
			#ifdef INPUT_DISPLAY
				writeToUSB_BIT(data[controller]);
			#endif
		}
	}

#ifdef TRIGGER_THRESHOLD // If defined, makes Gamecube controller triggers act more like GC collectors edition. Analog press instead of having to click them all the way down.
  analogTriggerToDigitalPress(data[controller].report, TRIGGER_THRESHOLD);
#endif

  normalize_origin(&data[controller].report.xAxis, &data[controller].origin.inititalData.xAxis);

	if(settings.ess_map == 1 && settings.game_selection == 0) // if OOT and ESS on:
  	invert_vc_gc(&data[controller].report.xAxis);



  //console.write(data); // Loop waits here until console requests an update.
  //GCcontroller.setRumble(data.status.rumble); // Set controller rumble status.

	return GCcontroller[controller].getDevice();
}

uint8_t N64loop(uint8_t controller) { // Wii vc version of OOT updates controller twice every ~16.68ms (with 1.04ms between the two rapid updates.)
	static uint8_t firstRead = 1;

  //delayRead(14);

	if (!N64controller[controller].read()) {
		tryPrintln("Failed to read N64 controller:");
		firstRead = 1; // if it fails to read, assume next successful read will be the first.
	}
	else {
		if(firstRead || enterSettingsMenuN64Controller(N64controller[controller].getReport())) { // special case: first read: change settings.
			N64toGC_buttonMap_Simple(N64controller[controller].getReport(), data[controller].report);
			firstRead = changeSettings(data[controller].report);
		}
		else {
			switch(settings.game_selection) {

				case 0:
				N64toGC_buttonMap_OOT(N64controller[controller].getReport(), data[controller].report);
				break;

	      case 1:
				N64toGC_buttonMap_Yoshi(N64controller[controller].getReport(), data[controller].report);
				break;

				default:
				N64toGC_buttonMap_Simple(N64controller[controller].getReport(), data[controller].report);
			}

			#ifdef INPUT_DISPLAY
				writeToUSB_BIT(data[controller]);
			#endif
		}


	}

  //console.write(data);

	return N64controller[controller].getDevice();
}
