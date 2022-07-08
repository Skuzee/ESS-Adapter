// Transforms Interface & Definitions ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
public interface Transform {
  public Coord apply(Coord inputCoord);
}

public class VCmap implements Transform { // Subtraction
  private Coord outputCoord = new Coord();

  public Coord apply(Coord inputCoord) {
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

public class Deadzone15 implements Transform {
    private Coord outputCoord = new Coord();
    
    public Coord apply(Coord inputCoord) {
      if (abs(inputCoord.getX()) <= 15) {
        outputCoord.setX(0);
      } else {
        outputCoord.setX(inputCoord.getX());
      }
      
      if (abs(inputCoord.getY()) <= 15) {
        outputCoord.setY(0);
      } else {
        outputCoord.setY(inputCoord.getY());
      }

      return outputCoord;
    }
}

public class InvertVC implements Transform {
    private Coord outputCoord = new Coord();
    private boolean x_positive = true;
    private boolean y_positive = true;
    private boolean swap = false;
    private int X=0;
    private int Y=0;
    private final int OOT_MAX=  80;
    private final int BOUNDARY = 39;
    
    final char one_dimensional_map[] = "adsad";
    final char triangular_map[] = 
    
    // Fold the quadrants into a 1/8th slice.
    public Coord apply(Coord inputCoord) {
      if (inputCoord.getX() < 0) {
        x_positive = false;
        X = -1-inputCoord.getX();
      } else {
        X= inputCoord.getX();
      }
      
      if (inputCoord.getY() < 0) {
        y_positive = false;
        Y = -1-inputCoord.getY();
      } else {
        Y = inputCoord.getY();
      }
      
      if (Y > X) {
        swap = true;
        int temp = X;
        X = Y;
        Y = temp;
      }

      // INVERT VC HERE
      /* Assume 0 <= y <= x <= 2*127 - double resolution */
      /* Approach is documented in the python implementation */
      if (X > 2 * OOT_MAX) X = 2 * OOT_MAX;
      if (Y > 2 * OOT_MAX) Y = 2 * OOT_MAX;
    
      if (X >= 2 * BOUNDARY && Y >= 2 * BOUNDARY) {
        int remainder = OOT_MAX + 1 - BOUNDARY;
        X = (X / 2) - BOUNDARY;
        Y = (X / 2) - BOUNDARY;
        int  index = triangular_to_linear_index(Y, X, remainder);
        X = pgm_read_byte(triangular_map + 2 * index);
        Y = pgm_read_byte(triangular_map + 2 * index + 1);
      } else {
        outputCoord.setXY(pgm_read_byte(one_dimensional_map + X),pgm_read_byte(one_dimensional_map + Y));
      }
      
      // Restore coord to correct quadrants.
      if (swap) {
        outputCoord.setXY(outputCoord.getY(),outputCoord.getX());
      }
      
      if(!x_positive) {
        outputCoord.setX(-outputCoord.getX());
      }
      
      if(!y_positive) {
        outputCoord.setY(-outputCoord.getY());
      }

      return outputCoord;
    }
}

public class NotchSnapping implements Transform {
  private Coord outputCoord = new Coord();
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
    outputCoord.setXY(inputCoord.getX(), inputCoord.getY());
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
