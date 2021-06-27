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
	if(N64report.l && N64report.r && N64report.cup && N64report.cdown && N64report.cright && N64report.cleft)
		return 1;
	else
		return 0;
}

uint8_t changeSettings(Gamecube_Report_t& GCreport) { // read the initial buttons of the controller and set EEPROM accordingly.

	if(GCreport.l && GCreport.r) {

		if(GCreport.z) { // Press Z to reset settings to default.
			EEPROM.update(0,!EEPROM.read(0));
			Serial.println(".");
			Serial.println(EEPROM.read(0) ? "Restoring Factory Settings... Press Z to undo." : "Factory Reset Canceled.");
			delay(500);
		}

		if(GCreport.dright || GCreport.dleft) { // Cycle n64 game button maps

			settings.game_selection += GCreport.dright - GCreport.dleft + 3;
			settings.game_selection %= 3;

			Serial.println("");

			switch(settings.game_selection) {

				case 0:
				Serial.println("Game: Yoshi Story.");
				break;

				case 1:
				Serial.println("Game: OOT.");
				break;

				case 2:
				Serial.println("Simple Button Map: No ESS");
				break;
			}

			delay(500);
		}

		if(GCreport.dup || GCreport.ddown) { // Cycle n64 game button maps

			settings.ess_map += GCreport.dup - GCreport.ddown + 3;
			settings.ess_map %= 3;

			Serial.println("");

			switch(settings.ess_map) {

				case 0:
				Serial.println("ESS Map: OFF/BYPASS.");
				break;

				case 1:
				Serial.println("ESS Map: ON.");
				break;

				case 2:
				Serial.println("ESS Map: 3rd Option NO USE.");
				break;
			}

			delay(500);
		}

		if(GCreport.a) { // Input Display Toggle.
			settings.input_display_enabled = !settings.input_display_enabled;
			Serial.println("");
			Serial.print("Input Display ");
      Serial.println(settings.input_display_enabled ? "Enabled" : "Disabled");
			delay(500);
		}

		if(GCreport.b) {  // 14ms Read Delay Toggle. Enabled = less controller input lag. Disable if there is connection issues. Game Dependant.
			settings.read_delay_enabled = !settings.read_delay_enabled;
			Serial.println("");
			Serial.print("14ms Read Delay ");
			Serial.println(settings.read_delay_enabled ? "Enabled" : "Disabled");
			delay(500);
		}

		Serial.print(".");
		delay(50);

		return 1; //if settings are being changed, continue to loop.
	}
	else {
		EEPROM.put(1, settings); // store any changed settings.
		Serial.println();
		Serial.println("Any Changes Have Been Saved.");
		loadSettings(); // check to see if eeprom was factory reset.

		return 0; // return 0, read controller normally now.
	}
}

void loadSettings() {
  if(EEPROM.read(0)) { // if EEPROM (position 0) == 1, write default settings to EEPROM and 'lock' EEPROM by setting position 0 to 0.
		settings = {1, 0, 0, 1};
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

	Serial.print("Input Display:   ");
		Serial.println(settings.input_display_enabled ? "Enabled" : "Disabled");

		Serial.print("ESS Map:         ");
		switch(settings.ess_map) {

			case 0:
			Serial.println("OFF/BYPASS");
			break;

			case 1:
			Serial.println("ON");
			break;

			case 2:
			Serial.println("3rd Option NO USE");
			break;
		}

	Serial.print("Game Selection:  ");
		switch(settings.game_selection) {

			case 0:
			Serial.println("Yoshi Story");
			break;

			case 1:
			Serial.println("OOT");
			break;

			case 2:
			Serial.println("Simple Button Map: No ESS");
			break;
		}

	Serial.print("14ms Read Delay: ");
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

	bool makeMotorVibrate(uint8_t timePeriod) {

		static unsigned long startOfRumble;
		static uint8_t timePeriodSave;
		static bool motorEnabled = false;

		if (!motorEnabled && timePeriod) {
			motorEnabled = true;
			startOfRumble = millis();
		  timePeriodSave = timePeriod;
			Serial.print("ON");
		}

		if (millis() - startOfRumble > timePeriodSave && motorEnabled) {
			motorEnabled = false;
			Serial.print("OFF");
		}

		return motorEnabled;
	}
