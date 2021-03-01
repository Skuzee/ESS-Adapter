//extra.hpp

#pragma once
#include <arduino.h>
#include "src/Nintendo/src/Nintendo.h"

#define DEBUG_READ 15
#define DEBUG_ESS 14
#define DEBUG_INPUT 16
#define DEBUG_WRITE 10
#define DEBUG_GND 9


void startButtonResets(Gamecube_Data_t& data);

void analogTriggerToDigitalPress(Gamecube_Report_t& GCreport, uint8_t Threshold);

void blinkLED(uint8_t blinks, uint8_t blinkTime);

void initializeDebug();
