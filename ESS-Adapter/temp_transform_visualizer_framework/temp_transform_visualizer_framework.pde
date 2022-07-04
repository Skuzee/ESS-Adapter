/* This is a framework for a more complicated plotter / visualizer program.
 The program will take a SET of data points (analog stick coordinates) and apply
 a TRANSFORM to the coordinate (one at a time) and plot / display the output with
 a VISUALIZER. The design is modular such that any transform and any visualizer can 
 be used on any set of coordinate points. 
 Currently there is a Sequence class that holds a lists of Transforms and Visualizer objects.
 use NULL to skip transform or visualizations. 
 extending the Sequence class is a "pregen" a custom list of transforms/visualizer steps.
 calling singleElement(Coord, index) or iterateAll(Coord) will apply and display the steps.
 
 a pregen might look something like this:
 this.addElement(null,         new SolidColor,      new plotAsPoints()); // No transform, change color scheme, display intial coordinate points as dots.
 this.addElement(new trans1(), new Gradient_Fade(), new VectorField());  // apply first transform, change color scheme, display as lines.  
 this.addElement(null,         new Solid_Fade(),    new plotAsPoints()); // No transform, change color scheme, display coordinate points as dots.
 
 isRendered is a property of each coord and is calc each time coord is updated 
 Color is calculated by coloreScheme, stored in outputCoord
 Alpha is calculated by colorScheme, stored in outputCoord
 
 
 TODO: a way to open pregens from files.
 TODO: handle SETs either dynamically, or predefined data.
 TODO: make some array list of PREGEN transforms for known uses.
 -pregen that is just one of each transform/visualizer for demo mode.
 ENUM of pregens: swap between pregens with keys.
 TODO: inputCoord to visualizer is the ORIGINAL coords, and not the sequential coords. this might be an issue for multi-transformed visuals.
 -might want to pass the previous output as next input.
 TODO: XY diagonal visualizer for monotonic test.
 TODO: consider a FORCERENDER option for visualizer?
 
 ERROR: why does my DataSet.next() not remain static? it keeps resetting indexX/Y
 
 ERROR: the draw() function is SUPER slow. taking 17ms per cycle. need to call interateDeep in some sort of while loop,
 until dataSet.next returns false. then draw it all at once. Review all the fucky changes I made to see what parts should stay changed.
 grandient_fade color not correct.
 
 TODO: https://processing.org/reference/thread_.html
 threading for updating coord scaledXY. storing and syncing all the data sounds like an issue, but
 perhaps every time a Coord setter is called it can update the scaledXY in a thread.
 
 
 */


// Imports ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
import java.util.Iterator;

// Coord Class ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
public class Coord {
  // signed -127 to 128
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

  private void updateX() {
    scaledX = int(map(X, -127, 128, 0, width*zoom));
    XneedsUpdate = false;
  }  

  private void updateY() {
    scaledY = int(map(Y, -127, 128, height*zoom, 0));
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
    return abs(this.mag - inputCoord.getMag());
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

// Sequence Class ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
public class Sequence {
  private ArrayList<Transform> transformList = new ArrayList<Transform>();
  private ArrayList<ColorScheme> colorSchemeList = new ArrayList<ColorScheme>();
  private ArrayList<Visualizer> visualizerList = new ArrayList<Visualizer>();
  protected DataSet dataSet;

  public void addElement(Transform transform, ColorScheme colorScheme, Visualizer visualizer) {
    transformList.add(transform);
    colorSchemeList.add(colorScheme);
    visualizerList.add(visualizer);
  }

  // applies single transform. Used to render all coordinates of a given transform before applying the next.
  public void singleElement(Coord inputCoord, int index) {
    Coord outputCoord = inputCoord; // Transform returns new coord as to not accidentally edit original inputCoord by reference.
    Transform transform = transformList.get(index);
    if (transform != null) {
      outputCoord = transform.apply(outputCoord);
    }

    ColorScheme colorScheme = colorSchemeList.get(index);
    if (colorScheme != null) {
      colorScheme.change(inputCoord, outputCoord);
    }

    Visualizer visualizer = visualizerList.get(index);
    if ((visualizer != null)) {
      visualizer.display(inputCoord, outputCoord);
    }
  }

  // Applies all Transforms and Visualizations to a single Coord before continuing.
  public void iterate(Coord inputCoord) {
    dataSet.next(inputCoord);
    iterateDeep(inputCoord);
  }
  public void iterateDeep(Coord inputCoord) { 
    while (dataSet.next(inputCoord)) { // get the next data point
      Iterator<Transform> transformIterator = transformList.iterator();
      Iterator<ColorScheme> colorSchemeIterator = colorSchemeList.iterator();
      Iterator<Visualizer> visualizerIterator = visualizerList.iterator();
      // Consider moving this inside first while loop if sequential transform visualization does not look right!!!!
      Coord outputCoord = inputCoord; // Transform returns new coord as to not accidentally edit original inputCoord by reference.

      while (transformIterator.hasNext() && visualizerIterator.hasNext() && colorSchemeIterator.hasNext()) { // iterate through each transform/scheme/visulizer
        Transform transform = transformIterator.next();
        if (transform != null) {
          outputCoord = transform.apply(outputCoord); // applies transforms sequentially while preserving original inputCoord object.
        }

        ColorScheme colorScheme = colorSchemeIterator.next();
        if (colorScheme != null) {
          colorScheme.change(inputCoord, outputCoord);
        }

        Visualizer visualizer = visualizerIterator.next();
        if ((visualizer != null)) { // and output isRendered???
          visualizer.display(inputCoord, outputCoord);
        }
      }
    }
  }
}

// "Pregen" assembled lists of pregenerated transforms and visualizations ~~~~~~~~~~~~~~~~~~~~~
public class PREGEN_WiiVCmap extends Sequence { 
  PREGEN_WiiVCmap() {
    dataSet = new SweepRadar_Angle();
    //this.addElement(null,        new SolidColor(),    new plotAsPoints());
    this.addElement(new VCmap(), new Gradient_Fade(), new VectorField()); // new VCmap()
    //this.addElement(null,        new Solid_Fade(),    new plotAsPoints());
  }
}

public class PREGEN_MonotonicXYPlot extends Sequence {
  PREGEN_MonotonicXYPlot() {
    //dataSet = new SweepXY(0,127,1,0,0,1);
    dataSet = new SweepRadar_Mag();
    this.addElement(new VCmap(), new Gradient_Fade(), new MonotonicXYPlot()); // new SolidColor(color(33, 100, 100))
  }
}

// Types of Transforms ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
public static enum TypesOfTransforms { 
  addition, subtraction;

  private static TypesOfTransforms[] vals = values();

  public static TypesOfTransforms first()
  {
    return vals[0];
  }

  public static int length()
  {
    return vals.length;
  }

  public TypesOfTransforms next()
  {
    return vals[(this.ordinal()+1) % vals.length];
  }
  public TypesOfTransforms prev()
  {
    return vals[(this.ordinal()+vals.length-1) % vals.length];
  }
}

// Select Transform ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//void selectTransform() {
//  switch (activeTransform) {

//  case addition:
//    transform = new addition();
//    break;

//  case subtraction:
//    transform = new subtraction();
//    break;
//  }
//}

// DataSet Interface & Definitions ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
public interface DataSet {
  public boolean next(Coord coord);
  public void reset();
}

public class SweepXY implements DataSet { // Subtraction
  private int minX=-127; 
  private int maxX=128; 
  private int stepX=1; 
  private int indexX=minX;

  private int minY=-127; 
  private int maxY=128; 
  private int stepY=1;
  private int indexY=minY;

  SweepXY() {
  }

  SweepXY(int i_minX, int i_maxX, int i_stepX, int i_minY, int i_maxY, int i_stepY) {
    minX=-i_minX; 
    maxX=i_maxX; 
    stepX=i_stepX; 
    indexX=i_minX;

    minY=i_minY; 
    maxY=i_maxY; 
    stepY=i_stepY;
    indexY=i_minY;
  }

  public boolean next(Coord coord) {
    coord.setXY(indexX, indexY);

    indexX+=stepX;

    if (indexX>=maxX) {
      indexX=minX;
      indexY+=stepY;

      if (indexY>=maxY) {
        indexY=minY;
        return false;
      }
    }
    return true;
  }


  public void reset() {
    indexX=minX;
    indexY=minY;
  }
}

public class SweepRadar_Angle implements DataSet { // Subtraction
  private int maxMag=128; 
  private int mag=0;
  private int stepMag=1;
  private float angle=0;
  private int angleResolution=360;
  private float stepAngle = 360/angleResolution;

  private int outputX=0;
  private int outputY=0;

  public boolean next(Coord coord) {
    outputX = int(sin(radians(angle))*mag);
    outputY = int(cos(radians(angle))*mag);
    
    coord.setXY(outputX, outputY);
    angle+=stepAngle;
    if (angle>=360) {
      angle=0;
      mag+=stepMag;
      if(mag>maxMag) {
        mag=0;
        return false;
      }
    }
    return true;
  }

  public void reset() {
  }
}

public class SweepRadar_Mag implements DataSet { // Subtraction
  private int maxMag=128; 
  private int mag=0;
  private int stepMag=2;
  private float angle=0;
  private float angleResolution=360;
  private float stepAngle = 360/angleResolution;

  private int outputX=0;
  private int outputY=0;

  public boolean next(Coord coord) {
    outputX = int(sin(radians(angle))*mag);
    outputY = int(cos(radians(angle))*mag);
    
    coord.setXY(outputX, outputY);
    
    mag+=stepMag;
    if (mag>maxMag) {
      mag=0;
      angle+=stepAngle;
      if(angle>=360) {
        angle=0;
        return false;
      }
    }
    return true;
  }

  public void reset() {
  }
}

// Transforms Interface & Definitions ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
public interface Transform {
  public Coord apply(Coord inputCoord);
}

public class addition implements Transform { // Addition 
  public Coord apply(Coord inputCoord) {
    return new Coord(inputCoord.getX()+10, inputCoord.getY()+10);
  }
}

public class subtraction implements Transform { // Subtraction
  public Coord apply(Coord inputCoord) {
    return new Coord(inputCoord.getX()-10, inputCoord.getY()-10);
  }
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

// ColorScheme Interface & Definitions ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
public interface ColorScheme {
  public void change(Coord inputCoord, Coord outputCoord);
}

public class Gradient_Fade implements ColorScheme { 
  public void change(Coord inputCoord, Coord outputCoord) {
    outputCoord.HSBcolor = color(40-inputCoord.distToCoord(outputCoord)*2, 100, 100);
    float dist1 = inputCoord.distanceFrom(mouseX+mouseX*zoom-width/2, mouseY+mouseY*zoom-height/2); // Need to offset mouse transform, so wierd maths.
    float dist2 = outputCoord.distanceFrom(mouseX+mouseX*zoom-width/2, mouseY+mouseY*zoom-height/2); // Need to offset mouse transform, so wierd maths.  
    outputCoord.Acolor = int(constrain(100-100*max(dist1, dist2)/(zoom*renderDistance), 0, 100)); // Set to fade in/out basd on renderDistance.
    
    if (outputCoord.Acolor <= 0) {
      outputCoord.isRendered = false;  
    } else {
      outputCoord.isRendered = true;
    }
  }
}

public class SolidColor implements ColorScheme { 
  private color solidColor=0;
  private int colorAlpha=100;

  SolidColor(color inputColor) {
    solidColor = inputColor;
  }

  SolidColor(color inputColor, int inputAlpha) {
    solidColor = inputColor;
    colorAlpha = inputAlpha;
  }

  public void change(Coord inputCoord, Coord outputCoord) {
    outputCoord.HSBcolor = solidColor;
    outputCoord.Acolor = colorAlpha;
  }
}

public class Solid_Fade implements ColorScheme { 
  public color fillColor=color(0, 0, 100);

  public void change(Coord inputCoord, Coord outputCoord) {
    outputCoord.HSBcolor = this.fillColor;
    float dist1 = outputCoord.distanceFrom(mouseX+mouseX*zoom-width/2, mouseY+mouseY*zoom-height/2); // Need to offset mouse transform, so wierd maths.
    float dist2 = outputCoord.distanceFrom(mouseX+mouseX*zoom-width/2, mouseY+mouseY*zoom-height/2); // Need to offset mouse transform, so wierd maths.
    outputCoord.Acolor = int(constrain(100-100*max(dist1, dist2)/(zoom*renderDistance), 0, 100)); // Set to fade in/out basd on renderDistance.;
  }
}

// Visualizer Interface & Definitions ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
public interface Visualizer {
  public void display(Coord inputCoord, Coord outputCoord);
}

public class plotAsPoints implements Visualizer { // DOTS
  public void display(Coord inputCoord, Coord outputCoord) {
    pushStyle();
    noStroke();
    fill(outputCoord.HSBcolor, outputCoord.Acolor);
    ellipse(outputCoord.getScaledX(), outputCoord.getScaledY(), outputCoord.drawSize*zoom*2, outputCoord.drawSize*zoom*2);
    popStyle();
  }
}

public class VectorField implements Visualizer { // Draws a line from inputCoord to outputCoord
  public void display(Coord inputCoord, Coord outputCoord) {

    //println(outputCoord.getX() + " " + outputCoord.getY());
    if ((outputCoord.getX()!=0) && (outputCoord.getY()!=0) && outputCoord.isRendered) {
      pushStyle();
      stroke(outputCoord.HSBcolor, outputCoord.Acolor);
      strokeWeight(1+zoom);
      noFill();
      line(inputCoord.getScaledX(), inputCoord.getScaledY(), outputCoord.getScaledX(), outputCoord.getScaledY());
      popStyle();
    }
  }
}

public class MonotonicXYPlot implements Visualizer { // Draws a line from inputCoord to outputCoord
  Coord lastCoord = new Coord();

  public void display(Coord inputCoord, Coord outputCoord) {
    pushStyle();
    stroke(outputCoord.HSBcolor, 100);
    strokeWeight(1+zoom);
    noFill();
    pushMatrix();
    translate(0,0,outputCoord.getMag());
    //outputCoord.setY(outputCoord.getX());
    ellipse(inputCoord.getScaledX(), inputCoord.getScaledY(),zoom,zoom);

    //if ((outputCoord.getY()!=0)) {
    //  //line(lastCoord.getScaledX(), lastCoord.getScaledY(), inputCoord.getScaledX(), outputCoord.getScaledY());
    //line(lastCoord.getScaledX(), lastCoord.getScaledY(), lastCoord.getMag(),inputCoord.getScaledX(), inputCoord.getScaledY(),outputCoord.getMag());
    //}
    lastCoord.setXY(inputCoord.getX(), inputCoord.getY());
    //inputCoord.setY(inputCoord.getX());
    //outputCoord.setY(outputCoord.getX());
    popMatrix();
    popStyle();
  }
}

// Draw Axis Lines ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
void drawAxisLines() {  
  // white x and Y axis lines
  pushStyle();
  stroke(0, 0, 120);
  strokeWeight(1);
  line((width-4)*zoom/2, 0, (width-4)*zoom/2, height*zoom);
  line(0, (height+4)*zoom/2, width*zoom, (height+4)*zoom/2);

  // white diagonal lines
  //line(0,4*zoom,width*zoom,(height+4)*zoom);
  //line(width*zoom,0,0,height*zoom);
  popStyle();
}

//Globals ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
int zoom = 1;
int renderDistance = 256;
PREGEN_MonotonicXYPlot pregen;
//PREGEN_MonotonicXYPlot pregen;
Coord coord = new Coord();
long startTime=0;
// Setup ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
void setup() {
  colorMode(HSB, 100, 100, 100, 100);
  size(1024, 1024, P3D);   
  background(0);
  pregen = new PREGEN_MonotonicXYPlot();
  //pregen = new PREGEN_MonotonicXYPlot();
}

// Draw ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
void draw() {
  background(0);

  pushMatrix();
  translate(-mouseX*zoom+width/2, -mouseY*zoom+height/2);
  rotateX(PI/4);
  drawAxisLines();
  

  //for (coord.setY(-100); coord.getY()<=100; coord.incY(1)) {
  //for (coord.setX(-100); coord.getX()<=100; coord.incX(1)) {
  //println(millis() - startTime);

  pregen.iterateDeep(coord);


  //startTime = millis();
  //PREGEN_MonotonicXYPlot test = new PREGEN_MonotonicXYPlot();
  //test.iterateDeep();
  //for (coord.setXY(0,0); coord.getX()<=128; coord.incXY()) {
  //  test.iterateDeep(coord);
  //}

  popMatrix();
}

// Mouse Events ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//void mousePressed() {
//  if (mouseButton==LEFT) {
//    activeTransform = activeTransform.next();
//    selectTransform();
//  }

//  if (mouseButton==RIGHT) {
//    activeVisualizer = activeVisualizer.next();
//    selectVisualizer();
//  }

//  println("TRANSFORM: " + activeTransform + " | VISUALIZER: " + activeVisualizer);
//}

void mouseClicked() {
  if (mouseButton==LEFT) {
    // renderDistance+=10;
    renderDistance=renderDistance<<1;
  }

  if (mouseButton==RIGHT) {
    //renderDistance-=10;
    renderDistance=renderDistance>>1;
  }
  renderDistance = constrain(renderDistance, 5, 1024);
}

void mouseWheel(MouseEvent event) {
  zoom -= event.getCount();
  zoom = constrain(zoom, 1, 40);
}
