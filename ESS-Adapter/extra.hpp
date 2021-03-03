//extra.hpp

#pragma once
#include <arduino.h>
#include "src/Nintendo/src/Nintendo.h"

#define DEBUG_READ 15
#define DEBUG_ESS 14
#define DEBUG_INPUT 16
#define DEBUG_WRITE 10
#define DEBUG_GND 9

typedef struct {
	uint8_t input_display_enabled : 1;
	uint8_t ess_map : 2;
	uint8_t n64_oot_buttons_enabled : 1;
	uint8_t n64_extended_range_enabled : 1;
	uint8_t read_delay_enabled : 1;
	uint8_t x_enabled : 1;
	uint8_t y_enabled : 1;
	uint8_t z_enabled : 1;
} EEPROM_settings;

extern EEPROM_settings settings;

void softReset();

void analogTriggerToDigitalPress(Gamecube_Report_t& GCreport, uint8_t Threshold);

//void blinkLED(uint8_t blinks, uint8_t blinkTime);

void changeSettings(Gamecube_Report_t& GCreport);

void loadSettings();

void printSetting();

void initializeDebug();
