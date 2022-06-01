// usb_joystick.hpp

#pragma once
#include <arduino.h>
#include "src/Nintendo/src/Nintendo.h"
#include <Joystick.h>

void inititalizeJoystick();

void sendJoystickData(Gamecube_Report_t& GCreport);
