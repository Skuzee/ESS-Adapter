// usb_joystick.cpp

#include "usb_joystick.hpp"

Joystick_ Joystick(JOYSTICK_DEFAULT_REPORT_ID,JOYSTICK_TYPE_GAMEPAD,
  12, 0,                  // Button Count, Hat Switch Count
  true, true, false,     // X and Y, but no Z Axis
  true, true, false,   // No Rx, Ry, or Rz
  true, true,          // No rudder or throttle
  false, false, false);  // No accelerator, brake, or steering

void inititalizeJoystick() {
  // Initialize Joystick Library
  Joystick.begin();
  Joystick.setXAxisRange(-127, 128);
  Joystick.setYAxisRange(-127, 128);
  Joystick.setRxAxisRange(-127, 128);
  Joystick.setRyAxisRange(-127, 128);
  Joystick.setThrottleRange(-127, 128);
  Joystick.setRudderRange(-127, 128);
}

void sendJoystickData(Gamecube_Report_t& GCreport) {
	Joystick.setXAxis(GCreport.xAxis-128);
	Joystick.setYAxis(GCreport.yAxis-128);
	Joystick.setRxAxis(GCreport.cxAxis-128);
	Joystick.setRyAxis(GCreport.cyAxis-128);
	Joystick.setThrottle(GCreport.left-128);
	Joystick.setRudder(GCreport.right-128);
	
		
	Joystick.setButton(0, GCreport.a);
	Joystick.setButton(1, GCreport.b);
	Joystick.setButton(2, GCreport.x);
	Joystick.setButton(3, GCreport.y);
	Joystick.setButton(4, GCreport.start);
	Joystick.setButton(5, GCreport.dleft);
	Joystick.setButton(6, GCreport.dright);
	Joystick.setButton(7, GCreport.ddown);
	Joystick.setButton(8, GCreport.dup);
	Joystick.setButton(9, GCreport.z);
	Joystick.setButton(10, GCreport.r);
	Joystick.setButton(11, GCreport.l);


	
}
