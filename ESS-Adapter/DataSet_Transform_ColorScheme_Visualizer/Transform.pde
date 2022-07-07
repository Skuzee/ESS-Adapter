// Transforms Interface & Definitions ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
public interface Transform {
  public Coord apply(Coord inputCoord);
}

public class VCmap implements Transform { // Subtraction
  public Coord apply(Coord inputCoord) {
    Coord outputCoord = new Coord();
    outputCoord.isRendered = inputCoord.isRendered;

    int signX = constrain(int(inputCoord.getX()), -1, 1);
    int signY = constrain(int(inputCoord.getY()), -1, 1);

    float outputX = ((inputCoord.getX() * signX)-15)*signX;
    outputX = int(outputX * 127 / 56); // trunc error is on purpose.
    outputX /= 127;
    outputX = 1 - sqrt(1 - abs(outputX));
    outputX *= 127;
    outputX *= signX;

    float outputY = ((inputCoord.getY() * signY)-15)*signY; 
    outputY = int(outputY * 127 / 56);
    outputY /= 127;
    outputY = 1 - sqrt(1 - abs(outputY));
    outputY *= 127;
    outputY *= signY;

    outputCoord.setXY(int(outputX), int(outputY));
    //outputCoord.HSBcolor = color(40-inputCoord.distToCoord(outputCoord)*2, 100, 100);
    return outputCoord;
  }
}

public class NotchSnapping implements Transform {
  private int notch_Snap_Strength = 2;
  private CornerNotch gateArray[];
  private Coord correctionVector = new Coord();
  NotchSnapping() {
  }

  NotchSnapping(CornerNotch gateArray[], int notch_Snap_Strength) {
    this.notch_Snap_Strength = notch_Snap_Strength;
    this.gateArray = gateArray;

  }
  
  private int findQuandrant(Coord inputCoord) {
    if (inputCoord.getY() > 0) {
      if (inputCoord.getX() > 0) { // Q1
        return 0;
      } else if (inputCoord.getX() < 0) { // Q2
        return 1;
      }
    } else if (inputCoord.getY() < 0) {
      if (inputCoord.getX() < 0) { // Q3
        return 2;
      } else if (inputCoord.getX() > 0) { // Q4
        return 3;
      }
    }
    return -1; // Does nothing if X or Y value equals 0.
  }

  public Coord apply(Coord inputCoord) {
    Coord outputCoord = new Coord(inputCoord);
    int quadrant = findQuandrant(inputCoord);
    // inputX - unsigned NotchX - Correction
    if(quadrant!=-1) {
      correctionVector = new Coord(inputCoord.getX()-(gateArray[quadrant].Xvalue)-(gateArray[quadrant].correction*gateArray[quadrant].Xsign), 
                           inputCoord.getY()-(gateArray[quadrant].Yvalue)+(gateArray[quadrant].correction*gateArray[quadrant].Ysign));
    }
    if (correctionVector.getMag() <= notch_Snap_Strength) {
      //v1 /= 2;
      outputCoord.setXY(inputCoord.getX()-correctionVector.getX(), inputCoord.getY()-correctionVector.getY());
    }
    return outputCoord;
  }
}
