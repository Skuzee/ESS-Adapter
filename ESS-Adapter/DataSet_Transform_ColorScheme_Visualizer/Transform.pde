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

  //final char one_dimensional_map[] = {'0', '0', '0x10', '0x10', '0x11', '0x11', '0x12', '0x12', '0x13', '0x13', '0x14', '0x14', '0x15', '0x15', '0x16', '0x16', '0x16', '0x17', '0x17', '0x17', '0x18', '0x18', '0x19', '0x19', '0x1a', '0x1a', '0x1a', '0x1b', '0x1b', '0x1b', '0x1c', '0x1c', '0x1d', '0x1d', '0x1d', '0x1e', '0x1e', '0x1e', '0x1f', '0x1f, ' ', ' '!', '!', '!', '\\', '\"', '\\', '\"', '\\', '\"', '#', '#', '#', '$', '$', '$', '%', '%', '%', '&', '&', '&', '\'', '\'', '\'', '(', '(', '(', ')', ')', ')', '*', '*', '*', '+', '+', '+', ',', ',', ',', ',', '-', '-', '-', '.', '.', '.', '/', '/', '/', '0', '0', '0', '0', '1', '1', '1', '1', '2', '2', '2', '3', '3', '3', '3', '4', '4', '4', '4', '5', '5', '5', '5', '6', '6', '6', '6', '7', '7', '7', '7', '8', '8', '8', '8', '8', '9', '9', '9', '9', '9', ':', ':', ':', ':', ';', ';', ';', ';', ';', '<', '<', '<', '<', '<', '=', '=', '=', '=', '=', '>', '>', '>', '>', '>', '?', '?', '?', '?', '?', '?', '@', '@', '@'};
  //String trimap = ",,-,.,.,/,0,0,1,1,2,2,3,3,4,4,5,5,6,6,7,7,8,8,9,9,9,:,:,;,;,<,<,<,=,=,>,>,>,?,?,?,@,--.-.-/-0-0-1-1-2-2-3-3-4-4-5-5-6-6-7-7-8-8-9-9-9-:-:-;-;-<-<-<-=-=->->->-?-?-?-@,..../.0.0.1.1.2.2.3.3.4.4.5.5.6.6.7.7.8.8.9.9.9.:.:.;.;.<.<.<.=.=.>.>.>.?-?-?-?-../.0.0.1.1.2.2.3.3.4.4.5.5.6.6.7.7.8.8.9.9.9.:.:.;.;.<.<.<.=.=.>.>.>.?-?-?-?-//0/0/1/1/2/2/3/3/4/4/5/5/6/6/7/7/8/8/9/9/9/:/:/;/;/</</</=/=/>/>/>/>/>/?-?-000010102020303040405050606070708080909090:0:0;0;0<0<0<0=0=0>/>/>/>/>/>/>/0010102020303040405050606070708080909090:0:0;0;0<0<0<0=0=0=0>/>/>/>/>/>/11112121313141415151616171718181919191:1:1;1;1<1<1<1=0=0=0>/>/>/>/>/>/112121313141415151616171718181919191:1:1;1;1<1<1<1<1<1=0=0>/>/>/>/>/2222323242425252626272728282929292:2:2;2;2<1<1<1<1<1<1=0=0>/>/>/>/22323242425252626272728282929292:2:2;2;2;2<1<1<1<1<1<1<1=0=0>/>/333343435353636373738383939393:3:3;3;3;3;3<1<1<1<1<1<1<1=0=0>/3343435353636373738383939393:3:3;3;3;3;3;3<1<1<1<1<1<1<1<1=044445454646474748484949494:4:4:4;3;3;3;3;3<1<1<1<1<1<1<1<1445454646474748484949494:4:4:4:4;3;3;3;3;3;3<1<1<1<1<1<1555565657575858595959595:4:4:4:4;3;3;3;3;3;3<1<1<1<1<1556565757585859595959595:4:4:4:4;3;3;3;3;3;3<1<1<1<1666676768686869595959595:4:4:4:4;3;3;3;3;3;3;3<1<1667676868686959595959595:4:4:4:4:4;3;3;3;3;3;3<1777777868686959595959595:4:4:4:4:4;3;3;3;3;3;3777777868686869595959595:4:4:4:4:4;3;3;3;3;377777786868686959595959595:4:4:4:4:4;3;3;377777786868686959595959595:4:4:4:4:4;3;377777786868686959595959595:4:4:4:4:4;377777786868686959595959595:4:4:4:4:477777786868686959595959595:4:4:4:47777778686868695959595959595:4:47777778686868695959595959595:4777777868686869595959595959577777786868686959595959595777777868686869595959595777777868686869595959577777786868686869595777777868686868695777777868686868677777786868686777777868686777777868677777786777777777777";
  byte[] one_dimensional_map = {0, 0, 16, 16, 17, 17, 18, 18, 19, 19, 20, 20, 21, 21, 22, 22, 22, 23, 23, 23, 24, 24, 25,
        25, 26, 26, 26, 27, 27, 27, 28, 28, 29, 29, 29, 30, 30, 30, 31, 31, 32, 32, 33, 33, 33, 34, 34, 34, 35,
        35, 35, 36, 36, 36, 37, 37, 37, 38, 38, 38, 39, 39, 39, 40, 40, 40, 41, 41, 41, 42, 42, 42, 43, 43, 43,
        44, 44, 44, 44, 45, 45, 45, 46, 46, 46, 47, 47, 47, 48, 48, 48, 48, 49, 49, 49, 49, 50, 50, 50, 51, 51,
        51, 51, 52, 52, 52, 52, 53, 53, 53, 53, 54, 54, 54, 54, 55, 55, 55, 55, 56, 56, 56, 56, 56, 57, 57, 57,
        57, 57, 58, 58, 58, 58, 59, 59, 59, 59, 59, 60, 60, 60, 60, 60, 61, 61, 61, 61, 61, 62, 62, 62, 62, 62,
        63, 63, 63, 63, 63, 63, 64, 64, 64};
  String tri_map = "";
  final char triangular_map[] = tri_map.toCharArray();

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
    
    X*=2;
    Y*=2;
    

    println(0x10);
    

    // INVERT VC HERE
    /* Assume 0 <= y <= x <= 2*127 - double resolution */
    /* Approach is documented in the python implementation */
    if (X > (2 * OOT_MAX)) X = 2 * OOT_MAX;
    if (Y > (2 * OOT_MAX)) Y = 2 * OOT_MAX;

    if ((X >= (2*BOUNDARY)) && (Y >= (2*BOUNDARY))) {
      int remainder = OOT_MAX + 1 - BOUNDARY;
      X = (X / 2) - BOUNDARY;
      Y = (Y / 2) - BOUNDARY;
      int  index = (remainder * (remainder - 1) / 2) - (remainder - Y) * ((remainder - Y) - 1) / 2 + X;
      X = triangular_map[2 * index];
      Y = triangular_map[2 * index + 1];
    } else {
      X = one_dimensional_map[X];
      Y = one_dimensional_map[Y];
    }

    // Restore coord to correct quadrants.
    if (swap) {
      int temp = X;
      X = Y;
      Y = temp;
    }

    if (!x_positive) {
      X = -X;
    }

    if (!y_positive) {
      Y = -Y;
    }
    
    outputCoord.setXY(X,Y);
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
    if (quadrant!=-1) {
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
