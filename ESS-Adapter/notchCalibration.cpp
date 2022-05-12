// notchCalibration.cpp

#pragma once
#include <arduino.h>
#include "notchCalibration.hpp"


float pythagDist(uint8_t x1, uint8_t y1,uint8_t x2, uint8_t y2) {
	return round(2*sqrtf((x1-x2)*(x1-x2) + (y1-y2)*(y1-y2)))/2;
}

// Finds the Quadrant the current coord is in and applies correction.
void notchCorrection(uint8_t ucoords[2]) {

	if (ucoords[1] > 128) {
		if (ucoords[0] > 128) {
			// Q1
			notches[0].applyCorrection(ucoords);
		} else if (ucoords[0] < 128) {
			// Q2
			notches[1].applyCorrection(ucoords);
		}
	} else if (ucoords[1] < 128) {
		if (ucoords[0] < 128) {
			// Q3
			notches[2].applyCorrection(ucoords);
		} else if (ucoords[0] > 128) {
			// Q4
			notches[3].applyCorrection(ucoords);
		}
	}
	// Does nothing if X or Y value equals 0.
}
