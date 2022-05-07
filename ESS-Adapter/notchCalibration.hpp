// notchCalibration.hpp

uint8_t pythagDist(uint8_t x1, uint8_t y1,uint8_t x2, uint8_t y2);

class CornerNotch{ 

	public:
		int8_t Xvalue, Yvalue;  // signed
		int8_t Xdiff, Ydiff, Xsign, Ysign, diffSign;
 
	CornerNotch(int8_t inX, int8_t inY) {
		this->setXY(inX, inY);
	}
	
	void setXY(int8_t inX, int8_t inY) {
		Xvalue = inX;
		Yvalue = inY;
		int8_t diff = (abs(Xvalue) - abs(Yvalue));
		Xdiff = ceil(diff/2.0);
		Ydiff = floor(diff/2.0);
		diffSign = constrain(diff,-1,1);
		Xsign = constrain(Xvalue,-1,1);
		Ysign = constrain(Yvalue,-1,1);
		Xdiff = abs(Xdiff);
		Ydiff = abs(Ydiff);
	}
	
	
	// Applies a slight correction to the diagonal corner values to nudge the analog value towards the ideal 45 degree angle. The end result is a correction proportional to the closeness of the current coordinate to the physical notch.
	void applyCorrection(uint8_t ucoords[2]) {
		uint8_t Xdist = pythagDist(ucoords[0],ucoords[1],Xvalue+128,Yvalue+128);
		uint8_t Ydist = Xdist;
		// Constrain the max value of dist to the difference.
		Xdist = constrain(Xdist,0,Xdiff);
		Ydist = constrain(Ydist,0,Ydiff);
		// Invert the map. This means that distance starts at "0" and the closer we get
		// to the corner notch the higher the value gets. The correction factor is strongest
		// when we are at the corner notch, and fades as we get farther.
		Xdist = map(Xdist, 0, Xdiff, Xdiff, 0);
		Ydist = map(Ydist, 0, Ydiff, Ydiff, 0);
		// The correction factor is to nudge the coordinate towards the true 45 line.
		// We need to add/subtract depending whether the correction factor is negative
		// or positive. (A negative dist means X < Y. We also need to flip the correction
		// if the axis is negative.
		ucoords[0] -= Xdist*Xsign*diffSign;
		ucoords[1] += Ydist*Ysign*diffSign;
	}
};

extern CornerNotch notches[4];

void notchCorrection(uint8_t ucoords[2]);
