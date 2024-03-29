//extra.hpp

//The Following code is released under GNU GENERAL PUBLIC LICENSE Version 3 and uses a nicohood's nintendo library released under MIT license.

#pragma once
#include <arduino.h>
#include "src/Nintendo/src/Nintendo.h"

#define MENU_BUTTON_TIMEOUT 300
#define EEPROM_VERSION 2

// Define output pins for debug timing with Logic Analyzer.
#define DEBUG_READ 15
#define DEBUG_ESS 14
#define DEBUG_INPUT 16
#define DEBUG_WRITE 10

//LED Indicator pins
//#define COMMON_ANODE
#define COMMON_CATHODE
#define LED1_PIN_R 10
#define LED1_PIN_G 16
#define LED1_PIN_B 14
#define LED2_PIN_R 15
#define LED2_PIN_G 18 // A0
#define LED2_PIN_B 19 // A1

#ifdef COMMON_ANODE
#define LED_ON LOW
#define LED_OFF HIGH
#endif

#ifdef COMMON_CATHODE
#define LED_ON HIGH
#define LED_OFF LOW
#endif

#define GAME_OOT 0
#define GAME_YOSHI 1
#define GAME_GENERIC 2

#define ESS_OFF 0
#define ESS_ON 1

#define INPUT_DISPLAY_OFF 0
#define INPUT_DISPLAY_ON 1

#define TRIGGER_THRESHOLD_OFF 0
#define TRIGGER_THRESHOLD_ON 1
#define DEF_TRIGGER_THRESHOLD 100

typedef struct {
  uint8_t input_display_enabled : 1;
  uint8_t game_selection : 3;
  uint8_t ess_map : 3;
  uint8_t trigger_threshold_enabled : 1;
	uint8_t trigger_threshold;
} EEPROM_settings;

extern EEPROM_settings settings;
extern CGamecubeController GCcontroller;

void softReset();

void analogTriggerToDigitalPress(Gamecube_Report_t& GCreport);

//void blinkLED(uint8_t blinks, uint8_t blinkTime);

uint8_t enterSettingsMenuN64Controller(const N64_Report_t& N64report);

uint8_t changeSettings(Gamecube_Report_t& GCreport);

void loadSettings();

void printSetting();

void initializeDebug();

void initilizeStatusLights();

void IndicatorLights(uint8_t LEDNumber, uint8_t LEDcolor);

void rumbleMotor(uint16_t duration, uint16_t pause, uint8_t pulses);
