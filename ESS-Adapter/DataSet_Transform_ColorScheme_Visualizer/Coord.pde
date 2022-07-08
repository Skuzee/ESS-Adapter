// Coord Class ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
public class Coord {
  // signed -128 to 127
  private int X=0;
  private int Y=0;
  private float mag=0; // distance to origin

  private int scaledX=0; // scaled coord values for graphing porportional to window size and zoom level
  private int scaledY=0;
  public int drawSize=1;
  public color HSBcolor = color(0, 100, 100);
  public int Acolor = 100;
  public boolean isRendered = true;
  public boolean XneedsUpdate = false;
  public boolean YneedsUpdate = false;
  public boolean MneedsUpdate = false;

  // Constructors
  Coord() {
  }

  Coord(int inputX, int inputY) { 
    this.setXY(inputX, inputY);
  } 

  Coord(Coord inputCoord) { 
    this.setXY(inputCoord.getX(), inputCoord.getY());
  }

  Coord(int inputX, int inputY, color inputColor) { 
    this.setXY(inputX, inputY);
    HSBcolor = inputColor;
  } 

  void isRendered() { // Calculates the distance from the scaled XY coordinate and the mouse position.
    float dist = this.distanceFrom(mouseX+mouseX*zoom-width/2, mouseY+mouseY*zoom-height/2); // Need to offset mouse transform, so wierd maths.
    //inputCoord.Acolor = int(constrain(100-100*dist/(zoom*renderDistance), 0, 100));

    //return (dist<=renderDistance*zoom && inputCoord.Acolor!=0) ? true : false;
    this.isRendered = (dist<=renderDistance*zoom) ? true : false;
  }

  // Updater

  public void updateAll() {
    if (this.XneedsUpdate) {
      this.updateX();
    }
    if (this.YneedsUpdate) {
      this.updateY();
    }
    if (this.MneedsUpdate) {
      this.updateM();
    } 
  }

  private void updateX() {
    scaledX = int(map(X, -128, 128, -width*zoom/2, width*zoom/2));
    XneedsUpdate = false;
  }  

  private void updateY() {
    scaledY = int(map(Y, -128, 128, height*zoom/2, -height*zoom/2));
    YneedsUpdate = false;
  }

  private void updateM() {
    mag = sqrt(pow(X, 2) + pow(Y, 2));
    MneedsUpdate = false;
  }


  public float distanceFrom(int inputX, int inputY) { 
    if (this.XneedsUpdate) {
      this.updateX();
    }
    if (this.YneedsUpdate) {
      this.updateY();
    }
    return sqrt(pow(inputX-scaledX, 2) + pow(inputY-scaledY, 2));
  }

  public float distToCoord(Coord inputCoord) {
    if (this.MneedsUpdate) {
      this.updateM();
    } 
    return (this.mag - inputCoord.getMag());
  }

  // getters
  public float getMag() { 
    if (this.MneedsUpdate) {
      this.updateM();
    }
    return mag;
  }

  public int getX() { 
    return X;
  }

  public int getY() { 
    return Y;
  }

  public int getScaledX() { 
    if (this.XneedsUpdate) {
      this.updateX();
    }
    return scaledX;
  }

  public int getScaledY() { 
    if (this.YneedsUpdate) {
      this.updateY();
    }
    return scaledY;
  }

  // setters
  public void setXY(int inputX, int inputY) { 
    X = inputX; 
    Y = inputY; 
    XneedsUpdate = true;
    YneedsUpdate = true;
    MneedsUpdate = true;
  }
  
  public void setXY(Coord inputCoord) { 
    X = inputCoord.getX(); 
    Y = inputCoord.getY(); 
    XneedsUpdate = true;
    YneedsUpdate = true;
    MneedsUpdate = true;
  }

  public void setX(int inputX) { 
    X = inputX; 
    XneedsUpdate = true;
    MneedsUpdate = true;
  }

  public void setY(int inputY) { 
    Y = inputY; 
    YneedsUpdate = true;
    MneedsUpdate = true;
  }

  public void incX() { 
    X++; 
    XneedsUpdate = true;
    MneedsUpdate = true;
  }

  public void incXY() { 
    X++; 
    Y++; 
    XneedsUpdate = true;
    YneedsUpdate = true;
    MneedsUpdate = true;
  }

  public void incY() { 
    Y++; 
    YneedsUpdate = true;
    MneedsUpdate = true;
  }

  public void incXY(int a) { 
    X+=a; 
    Y+=a; 
    XneedsUpdate = true;
    YneedsUpdate = true;
    MneedsUpdate = true;
  }
  
  public void incXY(int a, int b) { 
    X+=a; 
    Y+=b; 
    XneedsUpdate = true;
    YneedsUpdate = true;
    MneedsUpdate = true;
  }

  public void incX(int a) { 
    X+=a; 
    XneedsUpdate = true;
    MneedsUpdate = true;
  }

  public void incY(int a) { 
    Y+=a; 
    YneedsUpdate = true;
    MneedsUpdate = true;
  }
}
