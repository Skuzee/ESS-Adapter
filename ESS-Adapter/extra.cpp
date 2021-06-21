//extra.cpp

#include "extra.hpp"
#include <EEPROM.h>

EEPROM_settings settings;

void softReset() {
	asm volatile ("  jmp 0"); // Soft-reset, Assembly command that jumps to the start of the reset vector.
  }

void analogTriggerToDigitalPress(Gamecube_Report_t& GCreport, uint8_t Threshold) { // Maps analog L and R presses to digital presses. Range of sensitivity from 0 to 255. 0 being most sensitive. My controller has a range of ~30 to 240.
  if (GCreport.left > Threshold)
    GCreport.l = 1;
  if (GCreport.right > Threshold)
    GCreport.r = 1;
}

uint8_t enterSettingsMenuN64Controller(const N64_Report_t& N64report) {

	if(N64report.z==1 && N64report.start==1 && N64report.cup==1 && N64report.cdown==1 && N64report.cright==1 && N64report.cleft==1)
		return 1;
	else
		return 0;
}


uint8_t changeSettings_N64(const N64_Report_t& N64report) { // read the initial buttons of the controller and set EEPROM accordingly.

	if(N64report.z==1 && N64report.start==1) {

		if(N64report.r==1) { // Press R to reset settings to default.
			EEPROM.update(0,!EEPROM.read(0));
			Serial.println(".");
			Serial.println(EEPROM.read(0) ? "Restoring Factory Settings... Press R to undo." : "Factory Reset Canceled.");
			delay(500);
		}

		if(N64report.dleft==1) { // ESS Map 0: No ESS
			settings.ess_and_button_map = 0;
			Serial.println(".");
			Serial.println("ESS Disabled.");
			EEPROM.put(1, settings);
			delay(500);
		}

		if(N64report.dup==1) { // ESS Map 1: OOT
			settings.ess_and_button_map = 1;
			Serial.println(".");
			Serial.println("OOT Map Selected.");
			EEPROM.put(1, settings);
			delay(500);
		}

		if(N64report.dright==1) { // ESS Map 2: Yoshi Story
			settings.ess_and_button_map = 2;
			Serial.println(".");
			Serial.println("YOSHI Map Selected.");
			EEPROM.put(1, settings);
			delay(500);
		}

		// if(N64report.ddown==1) { // ESS Map: 3 NA
		// 	settings.ess_and_button_map = 3;
		// 	Serial.println(".");
		// 	Serial.println("Map 3 Selected.");
		// 	EEPROM.put(1, settings);
		// 	delay(500);
		// }

		if(N64report.a==1) { // Input Display Toggle.
			settings.input_display_enabled = !settings.input_display_enabled;
			Serial.println(".");
			Serial.print("Input Display ");
      Serial.println(settings.input_display_enabled ? "Enabled" : "Disabled");
			EEPROM.put(1, settings);
			delay(500);
		}

		if(N64report.b==1) { // 14ms Read Delay Toggle. Enabled = less controller input lag. Disable if there is connection issues. Game Dependant.
			settings.read_delay_enabled = !settings.read_delay_enabled;
			Serial.println(".");
			Serial.print("14ms Read Delay ");
      Serial.println(settings.read_delay_enabled ? "Enabled" : "Disabled");
			EEPROM.put(1, settings);
			delay(500);
		}

		// if(N64report.cleft==1) { // N64 Stick Range Toggle. Not implimented. Used on controllers with worn analog stick.
		// 	settings.n64_extended_range_enabled = !settings.n64_extended_range_enabled;
		// 	Serial.println(".");
		// 	Serial.print("N64 Extended Range (120) ");
    //   Serial.println(settings.n64_extended_range_enabled ? "Enabled" : "Disabled");
		// 	EEPROM.put(1, settings);
		// 	delay(500);
		// }


		Serial.print(".");
		delay(50);
		return 1; //if settings are being changed, continue to loop.
	}
	else {
		loadSettings();
		return 0; // else return 0, read controller normally now.
	}
}

uint8_t changeSettings_GC(const Gamecube_Report_t& GCreport) { // read the initial buttons of the controller and set EEPROM accordingly.

		if(GCreport.l==1 && GCreport.r==1) {

		if(GCreport.z==1) { // Press Z to reset settings to default.
			EEPROM.update(0,!EEPROM.read(0));
			Serial.println(".");
			Serial.println(EEPROM.read(0) ? "Restoring Factory Settings... Press Z to undo." : "Factory Reset Canceled.");
			delay(500);
		}


		if(GCreport.dleft==1) { // ESS Map 0: No ESS
			settings.ess_and_button_map = 0;
			Serial.println(".");
			Serial.println("ESS Disabled???");
			EEPROM.put(1, settings);
			delay(500);
		}

		if(GCreport.dup==1) { // ESS Map 1: OOT
			settings.ess_and_button_map = 1;
			Serial.println(".");
			Serial.println("OOT Map Selected.");
			EEPROM.put(1, settings);
			delay(500);
		}

		if(GCreport.dright==1) {  // ESS Map 2: Yoshi Story
			settings.ess_and_button_map = 2;
			Serial.println(".");
			Serial.println("Yoshi Map Selected.");
			EEPROM.put(1, settings);
			delay(500);
		}

		// if(GCreport.ddown==1) { // ESS Map: 3 NA
		// 	settings.ess_and_button_map = 3;
		// 	Serial.println(".");
		// 	Serial.println("??? Map Selected.");
		// 	EEPROM.put(1, settings);
		// 	delay(500);
		// }

		if(GCreport.a==1) { // Input Display Toggle.
			settings.input_display_enabled = !settings.input_display_enabled;
			Serial.println(".");
			Serial.print("Input Display ");
      Serial.println(settings.input_display_enabled ? "Enabled" : "Disabled");
			EEPROM.put(1, settings);
			delay(500);
		}

		if(GCreport.b==1) {  // 14ms Read Delay Toggle. Enabled = less controller input lag. Disable if there is connection issues. Game Dependant.
			settings.read_delay_enabled = !settings.read_delay_enabled;
			Serial.println(".");
			Serial.print("14ms Read Delay ");
			Serial.println(settings.read_delay_enabled ? "Enabled" : "Disabled");
			EEPROM.put(1, settings);
			delay(500);
		}

		Serial.print(".");
		delay(50);
		return 1; //if settings are being changed, continue to loop.
	}
	else {
		loadSettings();
		return 0; // else return 0, read controller normally now.
	}
}

void loadSettings() {
  if(EEPROM.read(0)) { // if EEPROM (position 0) == 1, write default settings to EEPROM and 'lock' EEPROM by setting position 0 to 0.
		settings = {1, 1, 0, 1, 0, 0, 0};
		EEPROM.put(1, settings);
		EEPROM.update(0,0);
		delay(5000);
		Serial.println();
		Serial.println("Factory Settings burned to EEPROM");
	}
	else {
		EEPROM.get(1, settings);
		Serial.println();
		Serial.println("Settings loaded from EEPROM");
	}

	printSetting();
}

void printSetting() {
			Serial.println(EEPROM.read(0) ? "EEPROM is Unlocked" : "EEPROM is locked");
			Serial.println("EEPROM settings:");
				Serial.print("Input Display:     ");
			Serial.println(settings.input_display_enabled ? "Enabled" : "Disabled");
				Serial.print("ESS Map:           ");
			Serial.print(settings.ess_and_button_map);
			Serial.println(" | 0:OFF,1:OOT,2:YOSHI,3:???");
				Serial.print("14ms Read Delay:   ");
			Serial.println(settings.read_delay_enabled ? "Enabled" : "Disabled");
}

  void initializeDebug() {
    pinMode(DEBUG_READ, OUTPUT);
    pinMode(DEBUG_ESS, OUTPUT);
    pinMode(DEBUG_INPUT, OUTPUT);
    pinMode(DEBUG_WRITE, OUTPUT);
    pinMode(DEBUG_GND, OUTPUT);
    digitalWrite(DEBUG_GND, LOW);
  }
