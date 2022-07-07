public class CornerNotch{ 
    public int Xvalue, Yvalue;  // signed
    public int   correction;
    public int Xsign, Ysign, diffSign;
 
  CornerNotch(int inX, int inY) {
    this.setXY(inX, inY);
  }
  
  void setXY(int inX, int inY) {
    Xvalue = inX;
    Yvalue = inY;
    correction = int((abs(Xvalue) - abs(Yvalue))/2.0);
    diffSign = int(constrain(correction,-1,1));
    Xsign = constrain(Xvalue,-1,1);
    Ysign = constrain(Yvalue,-1,1);
    correction = abs(correction);
  }
  
  void applyCorrection(int ucoords[]) {
    //notchSnapping(ucoords);
    //gateSnapping(ucoords);
    //notchGravity(ucoords);
  }
  
  // Applies a slight correction to the diagonal corner values to nudge the analog value towards the ideal 45 degree angle. The end result is a correction proportional to the closeness of the current coordinate to the physical notch.
  //void notchGravity(int ucoords[]) {

  //  // ********************************************* 
  //  // I made a simplification trying to fix a small bug.
  //  // I made x and y distance compensation identical trying to
  //  // make it symetrical. It did not help and might be incorrect.
  //  // The value wants to tend towards an uneven value; like -73,74
  //  // intead of -74,-74. This might be because the range is uneven,
  //  // being -127 to 0 to 128, so negative values need to be compensated
  //  // to hit the ideal diagonal. It works rn, but could be better.

  //  float dist = pythagDist(ucoords[0],ucoords[1],Xvalue+128,Yvalue+128);
  //  // Constrain the max value of dist to the difference.
  //  dist = dist<correction?dist:correction;

  //  // Invert the map. This means that distance starts at "0" and the closer we get
  //  // to the corner notch the higher the value gets. The correction factor is strongest
  //  // when we are at the corner notch, and fades as we get farther.
  //  dist = -(dist-correction);
    
  //  // The correction factor is to nudge the coordinate towards the true 45 line.
  //  // We need to add/subtract depending whether the correction factor is negative
  //  // or positive. (A negative dist means X < Y. We also need to flip the correction
  //  // if the axis is negative.
  //  ucoords[0] = int(ucoords[0] - (dist*Xsign*diffSign));
  //  ucoords[1] = int(ucoords[1] + (dist*Ysign*diffSign));
  //}


/*
  // Applies a slight correction to the diagonal corner values to nudge the analog value towards the ideal 45 degree angle. The end result is a correction proportional to the closeness of the current coordinate to the physical notch.
  void notchGravity(uint ucoords[2]) {
    
    uint Xdist = pythagDist(ucoords[0],ucoords[1],Xvalue+128,Yvalue+128);
    // Constrain the max value of dist to the difference.
    uint Ydist = Xdist<Ydiff?Xdist:Ydiff;
    Xdist = Xdist<Xdiff?Xdist:Xdiff;

    // Invert the map. This means that distance starts at "0" and the closer we get
    // to the corner notch the higher the value gets. The correction factor is strongest
    // when we are at the corner notch, and fades as we get farther.
    Xdist = -(Xdist-Xdiff);
    Ydist = -(Ydist-Ydiff);
    
    // The correction factor is to nudge the coordinate towards the true 45 line.
    // We need to add/subtract depending whether the correction factor is negative
    // or positive. (A negative dist means X < Y. We also need to flip the correction
    // if the axis is negative.
    ucoords[0] -= Xdist*Xsign*diffSign;
    ucoords[1] += Xdist*Ysign*diffSign;
  }
*/

  //void notchSnapping(int ucoords[]) {
  //  // inputX - unsigned NotchX - Correction
  //  vec3_t v1 = {ucoords[0]-(Xvalue+128)-(correction*Xsign),ucoords[1]-(Yvalue+128)+(correction*Ysign)};

  //  serialDebug(int(v1.mag()),6);

  //  if (v1.mag() <= Notch_Snap_Strength) {
  //    //v1 /= 2;
  //    ucoords[0]-=v1.x;
  //    ucoords[1]-=v1.y;
  //  }
  //}
  
  //void gateSnapping(int ucoords[]) {
  //    vec3_t v1 = {ucoords[0]-(Xvalue+128),ucoords[1]-(Yvalue+128)};
  
  //    serialDebug(int(v1.mag()),7);
  
  //    if (v1.mag() <= Gate_Snap_Strength) {
  //      //v1 /= 2;
  //      ucoords[0]-=v1.x-(correction*Xsign);
  //      ucoords[1]-=v1.y+(correction*Ysign);
  //    }
  //  }
};
