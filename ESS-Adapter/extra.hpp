//extra.hpp

#pragma once
#include <arduino.h>
#include "src/Nintendo/src/Nintendo.h"

void startButtonResets(Gamecube_Data_t& data);

void analogTriggerToDigitalPress(Gamecube_Data_t& data, int Threshold);

void blinkLED(int blinks, int blinkTime);
