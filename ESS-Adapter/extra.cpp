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

void changeSettings(Gamecube_Report_t& GCreport) { // read the initial buttons of the controller and set EEPROM accordingly.
	if(GCreport.l==1 && GCreport.r==1) {

		if(GCreport.dleft==1) {
			settings.ess_map = 0;
			Serial.println(".");
			Serial.println("ESS Disabled.");
			EEPROM.put(1, settings);
			delay(500);
		}

		if(GCreport.dup==1) {
			settings.ess_map = 1;
			Serial.println(".");
			Serial.println("OOT Map Selected.");
			EEPROM.put(1, settings);
			delay(500);
		}

		if(GCreport.dright==1) {
			settings.ess_map = 2;
			Serial.println(".");
			Serial.println("MM Map Selected.");
			EEPROM.put(1, settings);
			delay(500);
		}

		if(GCreport.ddown==1) {
			settings.ess_map = 3;
			Serial.println(".");
			Serial.println("M64 Map Selected.");
			EEPROM.put(1, settings);
			delay(500);
		}

		if(GCreport.z==1) {
			settings.read_delay_enabled = !settings.read_delay_enabled;
			Serial.println(".");
			Serial.print("14ms Read Delay ");
      Serial.println(settings.read_delay_enabled ? "Enabled" : "Disabled");
			EEPROM.put(1, settings);
			delay(500);
		}

		if(GCreport.a==1) {
			settings.input_display_enabled = !settings.input_display_enabled;
			Serial.println(".");
			Serial.print("Input Display ");
      Serial.println(settings.input_display_enabled ? "Enabled" : "Disabled");
			EEPROM.put(1, settings);
			delay(500);
		}

		if(GCreport.b==1) {
			settings.n64_extended_range_enabled = !settings.n64_extended_range_enabled;
			Serial.println(".");
			Serial.print("N64 Increased Range ");
      Serial.println(settings.n64_extended_range_enabled ? "Enabled" : "Disabled");
			EEPROM.put(1, settings);
			delay(500);
		}


		Serial.print(".");
		delay(100);
	}
}

void loadSettings() {
  if(EEPROM.read(0)) {
		settings = {1, 1, 1, 0, 1, 0, 0};
		EEPROM.put(1, settings);
		EEPROM.update(0,0);
		delay(5000);
		Serial.println("Factory Settings burned to EEPROM");
	}
	else {
		EEPROM.get(1, settings);
		Serial.println("Settings loaded from EEPROM");
	}

	printSetting();
}

void printSetting() {
			Serial.println(EEPROM.read(0) ? "EEPROM Unlocked" : "EEPROM locked");
			Serial.println("EEPROM settings:  ");
				Serial.print("Input Display:     ");
			Serial.println(settings.input_display_enabled ? "Enabled" : "Disabled");
				Serial.print("ESS Map:           ");
			Serial.print(settings.ess_map);
			Serial.println(" | 0:OFF,1:OOT,2:MM,3:M64");
				Serial.print("N64 OOT Buttons:   ");
			Serial.println(settings.n64_oot_buttons_enabled ? "Enabled" : "Disabled");
				Serial.print("N64 Extended Range:");
			Serial.println(settings.n64_extended_range_enabled ? "Enabled" : "Disabled");
				Serial.print("14ms Read Delay:   ");
			Serial.println(settings.read_delay_enabled ? "Enabled" : "Disabled");
}
/*void blinkLED(int blinks, int blinkTime) { //blink time in Milliseconds, be warned millis() is not accurate becuase of all the interupts so 100mS is ~ 1 second.
#ifdef LED_PIN

  for (blinks; blinks>0; blinks--) {
    digitalWrite(LED_PIN, HIGH);
    delay(blinkTime);
    digitalWrite(LED_PIN, LOW);
    delay(blinkTime);
  }

#endif
}*/


//#ifdef DEBUG
  void initializeDebug() {
    pinMode(DEBUG_READ, OUTPUT);
    pinMode(DEBUG_ESS, OUTPUT);
    pinMode(DEBUG_INPUT, OUTPUT);
    pinMode(DEBUG_WRITE, OUTPUT);
    pinMode(DEBUG_GND, OUTPUT);
    digitalWrite(DEBUG_GND, LOW);
  }
//#endif

/*#else
  void initializeDebug() {
  }

  void debugOutput(uint8_t pin, uint8_t state) {
  }
#endif*/
