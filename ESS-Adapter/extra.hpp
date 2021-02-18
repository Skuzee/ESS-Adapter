//extra.hpp

#pragma once
#include <arduino.h>
#include "src/Nintendo/src/Nintendo.h"

//#ifdef DEBUG
  #define DEBUG_READ 10
  #define DEBUG_ESS 14
  #define DEBUG_INPUT 15
  #define DEBUG_WRITE 16
  #define DEBUG_GND 9
//#endif

void startButtonResets(Gamecube_Data_t& data);

void analogTriggerToDigitalPress(Gamecube_Data_t& data, int Threshold);

void blinkLED(uint8_t blinks, uint8_t blinkTime);

void initializeDebug();

void debugOutput(uint8_t pin, uint8_t state);
