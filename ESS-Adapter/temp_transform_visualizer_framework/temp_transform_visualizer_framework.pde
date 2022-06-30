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
 TODO: vizualizer option1 pas color/alpha/drawSize?
 TODO: inputCoord to visualizer is the ORIGINAL coords, and not the sequential coords. this might be an issue for multi-transformed visuals.
 -might want to pass the previous output as next input.
 TODO: XY diagonal visualizer for monotonic test.

 
 */


// Imports ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
import java.util.Iterator;

// Coord Class ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
public class Coord {
  // signed -127 to 128
  private int X=0;
  private int Y=0;
  private float mag=0; // distance to origin

  public int scaledX=0; // scaled coord values for graphing porportional to window size and zoom level
  public int scaledY=0;
  public int drawSize=1;
  public color HSBcolor = color(0, 100, 100);
  public int Acolor = 100;
  public boolean isRendered = true;

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
  private void update() {
    scaledX = int(map(X, -127, 128, 0, width*zoom));
    scaledY = int(map(Y, -127, 128, height*zoom, 0));
    mag = sqrt(pow(X, 2) + pow(Y, 2));
    isRendered();
  }

  public float distanceFrom(int inputX, int inputY) { 
    return sqrt(pow(inputX-scaledX, 2) + pow(inputY-scaledY, 2));
  }

  public float getMag() { 
    return mag;
  }

  public float distToCoord(Coord inputCoord) {
    return abs(this.mag - inputCoord.getMag());
  }

  public int getX() { 
    return X;
  }

  public int getY() { 
    return Y;
  }

  public void setXY(int inputX, int inputY) { 
    X = inputX; 
    Y = inputY; 
    this.update();
  }

  public void setX(int inputX) { 
    X = inputX; 
    this.update();
  }

  public void setY(int inputY) { 
    Y = inputY; 
    this.update();
  }

  public void incX() { 
    X++; 
    this.update();
  }

  public void incY() { 
    Y++; 
    this.update();
  }

  public void incX(int a) { 
    X+=a; 
    this.update();
  }

  public void incY(int a) { 
    Y+=a; 
    this.update();
  }
}

// Sequence Class ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
public class Sequence {
  private ArrayList<Transform> transformList = new ArrayList<Transform>();
  private ArrayList<ColorScheme> colorSchemeList = new ArrayList<ColorScheme>();
  private ArrayList<Visualizer> visualizerList = new ArrayList<Visualizer>();

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
    if ((visualizer != null) && inputCoord.isRendered) {
      visualizer.display(inputCoord, outputCoord);
    }
  }

  // Applies all Transforms and Visualizations to a single Coord before continuing.
  public void iterateDeep(Coord inputCoord) { 
    Iterator<Transform> transformIterator = transformList.iterator();
    Iterator<ColorScheme> colorSchemeIterator = colorSchemeList.iterator();
    Iterator<Visualizer> visualizerIterator = visualizerList.iterator();

    // Consider moving this inside first while loop if sequential transform visualization does not look right!!!!
    Coord outputCoord = inputCoord; // Transform returns new coord as to not accidentally edit original inputCoord by reference.

    while (transformIterator.hasNext() && visualizerIterator.hasNext() && colorSchemeIterator.hasNext()) {
      Transform transform = transformIterator.next();
      if (transform != null) {
        outputCoord = transform.apply(outputCoord); // applies transforms sequentially while preserving original inputCoord object.
      }
      
      ColorScheme colorScheme = colorSchemeIterator.next();
      if (colorScheme != null) {
        colorScheme.change(inputCoord, outputCoord);
      }
      
      Visualizer visualizer = visualizerIterator.next();
      if ((visualizer != null) && inputCoord.isRendered && outputCoord.isRendered) { // and output isRendered???
        visualizer.display(inputCoord, outputCoord);
      }
    }
  }
}

// "Pregen" assembled lists of pregenerated transforms and visualizations ~~~~~~~~~~~~~~~~~~~~~
public class PREGEN_WiiVCmap extends Sequence {
  PREGEN_WiiVCmap() {
    //this.addElement(null,        new SolidColor(),    new plotAsPoints());
    this.addElement(new VCmap(), new Gradient_Fade(), new VectorField());
    this.addElement(null,        new Solid_Fade(),    new plotAsPoints());
  }
}

public class PREGEN_MonotonicTest extends Sequence {
  PREGEN_MonotonicTest() {
    this.addElement(new VCmap(), new Gradient_Fade(), new MonotonicTest());
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
  public void change(Coord inputCoord1, Coord inputCoord2);
}

public class Gradient_Fade implements ColorScheme { 
  public void change(Coord inputCoord1, Coord inputCoord2) {
    inputCoord2.HSBcolor = color(40-inputCoord1.distToCoord(inputCoord2)*2, 100, 100);
    float dist1 = inputCoord1.distanceFrom(mouseX+mouseX*zoom-width/2, mouseY+mouseY*zoom-height/2); // Need to offset mouse transform, so wierd maths.
    float dist2 = inputCoord2.distanceFrom(mouseX+mouseX*zoom-width/2, mouseY+mouseY*zoom-height/2); // Need to offset mouse transform, so wierd maths.
    inputCoord2.Acolor = int(constrain(100-100*max(dist1, dist2)/(zoom*renderDistance), 0, 100)); // Set to fade in/out basd on renderDistance.
  }
}

public class SolidColor implements ColorScheme { 
  public void change(Coord inputCoord1, Coord inputCoord2) {
    inputCoord2.HSBcolor = color(66, 100, 100);
    inputCoord2.Acolor = 100;
  }
}

public class Solid_Fade implements ColorScheme { 
  public void change(Coord inputCoord1, Coord inputCoord2) {
    inputCoord2.HSBcolor = color(0, 0, 100);
    float dist1 = inputCoord1.distanceFrom(mouseX+mouseX*zoom-width/2, mouseY+mouseY*zoom-height/2); // Need to offset mouse transform, so wierd maths.
    float dist2 = inputCoord2.distanceFrom(mouseX+mouseX*zoom-width/2, mouseY+mouseY*zoom-height/2); // Need to offset mouse transform, so wierd maths.
    inputCoord2.Acolor = int(constrain(100-100*max(dist1, dist2)/(zoom*renderDistance), 0, 100)); // Set to fade in/out basd on renderDistance.;
  }
}

// Visualizer Interface & Definitions ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
public interface Visualizer {
  public void display(Coord inputCoord1, Coord inputCoord2);
}

public class plotAsPoints implements Visualizer { // DOTS
  public void display(Coord inputCoord1, Coord inputCoord2) {
    pushStyle();
    noStroke();
    fill(inputCoord2.HSBcolor, inputCoord2.Acolor);
    ellipse(inputCoord2.scaledX, inputCoord2.scaledY, inputCoord2.drawSize*zoom*2, inputCoord2.drawSize*zoom*2);
    popStyle();
  }
}

public class VectorField implements Visualizer { // Draws a line from inputCoord1 to inputCoord2
  public void display(Coord inputCoord1, Coord inputCoord2) {

    if ((inputCoord2.getX()!=0) && (inputCoord2.getY()!=0)) {
      pushStyle();
      stroke(inputCoord2.HSBcolor, inputCoord2.Acolor);
      strokeWeight(1+zoom);
      noFill();
      line(inputCoord1.scaledX, inputCoord1.scaledY, inputCoord2.scaledX, inputCoord2.scaledY);
      popStyle();
    }
  }
}

public class MonotonicTest implements Visualizer { // Draws a line from inputCoord1 to inputCoord2
  public void display(Coord inputCoord1, Coord inputCoord2) {

    pushStyle();
    noStroke();
    fill(inputCoord2.HSBcolor, 100);
    ellipse(inputCoord1.scaledX, inputCoord2.scaledY, inputCoord2.drawSize*zoom*2, inputCoord2.drawSize*zoom*2);
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
Coord coord;

int zoom = 1;
int renderDistance = 256;

// Setup ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
void setup() {
  colorMode(HSB, 100, 100, 100, 100);
  size(1024, 1024);   
  background(0);

  coord = new Coord();
}

// Draw ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
void draw() {
  background(0);

  pushMatrix();
  translate(-mouseX*zoom+width/2, -mouseY*zoom+height/2);
  //translate(width/2,height/2);
  drawAxisLines();

  PREGEN_WiiVCmap test = new PREGEN_WiiVCmap();
  for (coord.setY(-100); coord.getY()<=100; coord.incY(1)) {
    for (coord.setX(-100); coord.getX()<=100; coord.incX(1)) {
      test.iterateDeep(coord);
    }
  }
  
  //PREGEN_MonotonicTest test = new PREGEN_MonotonicTest();
  //for (coord.setX(0); coord.getX()<=128; coord.incX(1)) {
  //  coord.setY(coord.getX());
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
