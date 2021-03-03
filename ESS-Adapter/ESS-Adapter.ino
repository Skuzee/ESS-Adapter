//ESS-Adapter.ino -- dev1

/* Visit Github for more information: https://github.com/Skuzee/ESS-Adapter */

/*Basic Wiring Information for ATMEGA:
   (Pins 6 & 8 are default DATA Pins, but any GPIO pin will work if you change CONT_PIN and CONS_PIN.)
   -Pin 6 --> DATA to Controller
   -Pin 6 --> 750ohm Pull-up Resistor --> 3.3v supply from Console
   -Pin 8 --> DATA to Console
   -5v supply from console --> schottky diode --> Vcc/Vin
   -GND Pin --> Ground wires

	Make sure the Controller is still connected: insuring the following:
	 -5v supply from Console --> 5v to Controller (Rumble Motor)
	 -3.3v supply from Console --> 3.3v wire to Controller
	 -Grounds from Console --> Grounds to Controller

	 If your cable has a braided metal shieding, don't connect it to anything.
*/

//Options
#define INPUT_DISPLAY // - works on 32u4, needs newest compiled version of NintendoSpy (not the old release from 2014).
#define CONT_PIN 6  // Controller DATA Pin
#define CONS_PIN 8  // Console DATA Pin
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

CGamecubeController GCcontroller(CONT_PIN); // Sets Gamecube Controller Pin on arduino to read from controller.
CN64Controller N64controller(CONT_PIN); // Sets N64 Controller Pin on arduino to read from controller.
CGamecubeConsole console(CONS_PIN); // Sets D8 on arduino to write data to console.
Gamecube_Data_t data = defaultGamecubeData; // initilize Gamecube data. Default needed for N64 data to convert correctly.
//extern EEPROM_settings settings;

void setup() {
  Serial.begin(115200);
	loadSettings();

#ifdef DEBUG
  initializeDebug();
#endif
}

void loop() {
 	static uint16_t deviceID = 0;

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

/*
	if(deviceID == 5)
		N64loop();
	else if (deviceID != 0)
    deviceID = GCloop(); // standard controller is 0009, but attempt to read any non-0 device ID as a gamecube controller.*/

	// idea; instead of using failedReadCounter:
	// deviceID = GCloop();
	// GCloop returns data.status.device.
	// might need to reset device ID every loop or on failed read?
	// if deviceID is 0, then deviceID = checkConnection() to get new id.
	// case select deviceID
	//prehaps still account for failed reads?
}

uint16_t checkConnection() {

  N64_Status_t connectionStatus; // create a generic Status (N64 and GC status are the same)
  connectionStatus.device = 0; // reset device ID

  n64_init(CONT_PIN, &connectionStatus); // initilize controller to update device ID
  Serial.print("Searching... Device ID:");
  Serial.println(char(connectionStatus.device), DEC);
	delay(1000);

	return connectionStatus.device;
}

void delayRead() {
		static uint8_t readDelayFlipFlop = 0;

		if(readDelayFlipFlop)
			delay(14);	// waits 14ms every other read cycle. Prevents the arduino from reading the controller data too early and then having to wait 15ms to send it to the wii. Delay added to controller is between 0.635ms and 1.225ms. (average of 0.930ms)
	  readDelayFlipFlop=!readDelayFlipFlop;
}

uint16_t GCloop() { // Wii vc version of OOT updates controller twice every ~16.68ms (with 1.04ms between the two rapid updates.)
	static uint8_t firstRead = 1;

  delayRead();

	if (!GCcontroller.read()) { // failed read: increase failedReadCounter
		Serial.println("Failed to read GC controller:");
		data.status.device = 0;
		firstRead = 1;
	}
	else {
  	data = GCcontroller.getData(); // successful read: copy controller data to access.
		if(firstRead) { // special case: first read: change settings.
			changeSettings(data.report);
			if(data.report.l==0 || data.report.r==0)
				firstRead = 0;
		}
	}

#ifdef TRIGGER_THRESHOLD // If defined, makes Gamecube controller triggers act more like GC collectors edition. Analog press instead of having to click them all the way down.
  analogTriggerToDigitalPress(data.report, TRIGGER_THRESHOLD);
#endif

#ifdef INPUT_DISPLAY // Copies data to serial buffer and sends to NintendoSpy. Data format is from Nicohood's Nintendo Library and only works with the newest version of Nintendospy. (It's a different data order than the NintendoSpy uses by default.)
		writeToUSB_BYTE(data);
#endif

  normalize_origin(&data.report.xAxis, &data.origin.inititalData.xAxis);
  invert_vc_gc(&data.report.xAxis);

  console.write(data); // Loop waits here until console requests an update.
  GCcontroller.setRumble(data.status.rumble); // Set controller rumble status.

	return data.status.device;
}

uint16_t N64loop() { // Wii vc version of OOT updates controller twice every ~16.68ms (with 1.04ms between the two rapid updates.)
	static uint8_t firstRead = 1;

  delayRead();

	if (!N64controller.read()) {
		Serial.println("Failed to read N64 controller:");
		data.status.device = 0;
		firstRead = 1;
	}
	else {
    convertToGC(N64controller.getReport(), data.report);
		if(firstRead) { // special case: first read: change settings.
			changeSettings(data.report);
			if(data.report.l==0 || data.report.r==0)
				firstRead = 0;
		}
	}

#ifdef INPUT_DISPLAY
  	writeToUSB_BYTE(data);
#endif

  console.write(data);

	return data.status.device;
}
