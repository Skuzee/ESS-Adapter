//ESS-Adapter.ino -- master

/* Visit Github for more information: https://github.com/Skuzee/ESS-Adapter */

/*Basic Wiring Information for ATMEGA:
   (Any GPIO pin will work. Please check CONT_PIN and CONS_PIN.)
   -CONT_PIN --> DATA to Controller
   -CONT_PIN --> 750ohm Pull-up Resistor --> 3.3v supply from Console
   -CONS_PIN --> DATA to Console
   -5v supply from console --> schottky diode --> Vcc Unregulated Voltage pin.
   -GND Pin --> Ground wires

	Make sure the Controller is still connected: insuring the following:
	 -5v supply from Console --> 5v to Controller (Rumble Motor)
	 -3.3v supply from Console --> 3.3v wire to Controller
	 -Grounds from Console --> Grounds to Controller

	 If your cable has a braided metal shieding, don't connect it to anything.
*/

//Options
#define INPUT_DISPLAY // - works on 32u4, needs newest compiled version of NintendoSpy (not the old release from 2014).
#define CONT_PIN 4  // Controller DATA Pin: 4 yellow, 6 master, 3 Dev board
#define CONS_PIN 2  // Console DATA Pin: 2 yellow, 8 master branch, 2 Dev board
//#define TRIGGER_THRESHOLD 100 // Makes the L and R triggers act like Gamecube version of OOT. range of sensitivity from 0 to 255. 0 being most sensitive. My controller has a range of ~30 to 240. Comment out to disable.
//#define DEBUG // overwrites IndicatorLights and used for data analyzer.

//Includes
#include "src/Nintendo/src/Nintendo.h"
#include "ESS.hpp"
#include "extra.hpp"
#include "input-display.hpp"

#if NINTENDO_VERSION != 1337
#error "Incorrect Nintendo.h library! Compiling with the incorrect version WILL result in 5 volts being output to your controller/console! (Not good.) Make sure the custom Nintendo library (version 1337) is included in the ESS-Adapter/src folder and try again."
#endif

#define Q1_NOTCH_X 77
#define Q1_NOTCH_Y 82

#define Q2_NOTCH_X -70
#define Q2_NOTCH_Y 79

#define Q3_NOTCH_X -72
#define Q3_NOTCH_Y -76

#define Q4_NOTCH_X 78
#define Q4_NOTCH_Y -78
													//Q1	  //Q2			//Q3			//Q4
int8_t cornerNotches[] = {77, 82, -70, 79, -72, -76, 78, -78};

// Sets CONT_PIN on arduino to read from controller.
CGamecubeController GCcontroller(CONT_PIN);
CN64Controller N64controller(CONT_PIN);

// Sets CONS_PIN on arduino to write data to console.
CGamecubeConsole console(CONS_PIN);
Gamecube_Data_t data = defaultGamecubeData; // Initilize Gamecube data. Default needed for N64 data to convert correctly.


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

  n64_init(CONT_PIN, &connectionStatus); // Initilize controller to update device ID
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
      #ifdef INPUT_DISPLAY
            writeToUSB_BYTE(data);
      #endif
    }
  }

  #ifdef TRIGGER_THRESHOLD // If defined, makes Gamecube controller triggers act more like GC collectors edition. Analog press instead of having to click them all the way down.
    analogTriggerToDigitalPress(data.report, TRIGGER_THRESHOLD);
  #endif

  normalize_origin(&data.report.xAxis, &data.origin.inititalData.xAxis);

  Serial.print("S ");
	Serial.print(data.report.xAxis);
  Serial.print(' ');
	Serial.print(data.report.yAxis);

	notchCorrection(&data.report.xAxis);

  Serial.print(' ');
	Serial.print(data.report.xAxis);
  Serial.print(' ');
	Serial.print(data.report.yAxis);

  if (settings.ess_map == ESS_ON && settings.game_selection == GAME_OOT) // if OOT and ESS on:
    invert_vc_gc(&data.report.xAxis);


  Serial.print(' ');
	Serial.print(data.report.xAxis);
  Serial.print(' ');
	Serial.print(data.report.yAxis);
	Serial.println(" E");

	delay(10);

  //console.write(data); // Loop waits here until console requests an update.
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
    if (firstRead || enterSettingsMenuN64Controller(N64controller.getReport())) { // Special case: first read: change settings.
      N64toGC_buttonMap_Generic(N64controller.getReport(), data.report); // Use the generic button map for the settings menu to keep things consistent.
      firstRead = changeSettings(data.report); // Loops while settings are being changed.
    }
    else {
      switch (settings.game_selection) { // Convert N64 data/buttons to GC data/buttons depending on what game/ess setting is selected

        case GAME_OOT:
          N64toGC_buttonMap_OOT(N64controller.getReport(), data.report);
          break;

        case GAME_YOSHI:
          N64toGC_buttonMap_Yoshi(N64controller.getReport(), data.report);
          break;

        default:
          N64toGC_buttonMap_Generic(N64controller.getReport(), data.report);
      }

      #ifdef INPUT_DISPLAY
            writeToUSB_BYTE(data);
      #endif
    }
  }

  console.write(data); // Loop waits here until console requests an update.
  // N64 Rumble motor function???

  return N64controller.getDevice();
}

void notchCorrection(uint8_t ucoords[2]) {
//	uint8_t dist = pythagDist(coords[0],coords[1],NW_NOTCH_X-128,NW_NOTCH_Y-128);

	// if(dist <= abs(notchCorrectionNW)) {
	// 	coords[0] += (dist + notchCorrectionNW);
	// 	coords[1] += (dist + notchCorrectionNW);
	// }


	// int8_t diff = (abs(ucoords[0]-128) - abs(ucoords[1]-128));
	// if (ucoords[0] == 128 || ucoords[1] == 128)
	// 	diff = 0;
	// ucoords[0] -= diff*constrain(ucoords[0]-128,-1,1)/2;
	// ucoords[1] += diff*constrain(ucoords[1]-128,-1,1)/2;

	//remember un/signed
	//calc dist
	//constrain dist to 0 to diff/2
	//reverse map: diff to 0/2
	//add that as correction offset to X and Y
	for (uint8_t i = 0; i<8; i+=2) {

		int8_t diff = abs(cornerNotches[i]) - abs(cornerNotches[i+1]);
		uint8_t sign = constrain(diff,-1,1);
		diff = abs(diff);
		uint8_t dist = pythagDist(ucoords[0],ucoords[1],cornerNotches[i]+128,cornerNotches[i+1]+128);
		dist = constrain(dist,0,diff/2);
		dist = map(dist, 0, diff/2, diff/2, 0);

		ucoords[0] -= dist*constrain(ucoords[0]-128,-1,1)*sign;
		ucoords[1] += dist*constrain(ucoords[1]-128,-1,1)*sign;
	}
}

uint8_t pythagDist(uint8_t x1, uint8_t y1,uint8_t x2, uint8_t y2) {
	return round(sqrt(pow(x1-x2,2) + pow(y1-y2,2)));
}
