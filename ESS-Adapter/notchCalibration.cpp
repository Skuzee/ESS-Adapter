// notchCalibration.cpp

#pragma once
#include <arduino.h>
#include "notchCalibration.hpp"


uint8_t pythagDist(uint8_t x1, uint8_t y1,uint8_t x2, uint8_t y2) {
	return round(sqrtf((x1-x2)*(x1-x2) + (y1-y2)*(y1-y2)));
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

/*

	//calc dist
	//constrain dist to 0 to diff/2
	//reverse map: diff to 0/2
	//add that as correction offset to X and Y

	for (uint8_t i = 0; i<4; i++) { // Calculate for each of 4 corner notches.

		// Calculate the correction factor to apply to make X == Y
		// if corner is 70,78 (unsigned values) the ideal diagonal is 74,74
		// which is the average.
		// Calculate X and Y seperately. In case the difference is odd, round 1 up and 1 down.
		int8_t diffX = ceil(float(abs(cornerNotches[i]) - abs(cornerNotches[i+1]))/2);
		int8_t diffY = floor(float(abs(cornerNotches[i]) - abs(cornerNotches[i+1]))/2);
		// Save whether diff is pos/neg. We need it later.
		int8_t sign = constrain(diffX,-1,1);
		// Remove sign to apply scaling map.
		diffX = abs(diffX);
		diffY = abs(diffY);
		
		// Calculate the distance between current coordinates and corner notch.
		uint8_t distX = pythagDist(ucoords[0],ucoords[1],cornerNotches[i]+128,cornerNotches[i+1]+128);
		uint8_t distY = distX;
		// Constrain the max value of dist to the difference.
		distX = constrain(distX,0,diffX);
		distY = constrain(distY,0,diffY);
		// Invert the map. This means that distance starts at "0" and the closer we get
		// to the corner notch the higher the value gets. The correction factor is strongest
		// when we are at the corner notch, and fades as we get farther.
		distX = map(distX, 0, diffX, diffX, 0);
		distY = map(distY, 0, diffY, diffY, 0);
		// The correction factor is to nudge the coordinate towards the true 45 line.
		// We need to add/subtract depending whether the correction factor is negative
		// or positive. (A negative dist means X < Y. We also need to flip the correction
		// if the axis is negative.
		ucoords[0] -= distX*constrain(ucoords[0]-128,-1,1)*sign;
		ucoords[1] += distY*constrain(ucoords[1]-128,-1,1)*sign;
	}
	
*/
